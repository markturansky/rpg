package render

import (
	"bytes"
	"io"
	"net/http"
	"net/http/httptest"
	"testing"
)

func setupTestServer(t *testing.T) *httptest.Server {
	t.Helper()
	atlas, err := NewSpriteAtlas(spritesDir(t))
	if err != nil {
		t.Fatalf("NewSpriteAtlas failed: %v", err)
	}
	renderer := NewTileRenderer(atlas, 42, 256)

	mux := http.NewServeMux()
	mux.HandleFunc("GET /tiles/{address...}", NewTileHandler(renderer))
	return httptest.NewServer(mux)
}

func TestHTTPTileEndpoint(t *testing.T) {
	srv := setupTestServer(t)
	defer srv.Close()

	resp, err := http.Get(srv.URL + "/tiles/map2_35")
	if err != nil {
		t.Fatalf("GET /tiles/map2_35 failed: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		t.Errorf("expected 200, got %d", resp.StatusCode)
	}

	ct := resp.Header.Get("Content-Type")
	if ct != "image/png" {
		t.Errorf("expected Content-Type image/png, got %q", ct)
	}

	cc := resp.Header.Get("Cache-Control")
	if cc == "" {
		t.Error("expected Cache-Control header, got empty")
	}
}

func TestHTTPTileCache(t *testing.T) {
	srv := setupTestServer(t)
	defer srv.Close()

	resp1, err := http.Get(srv.URL + "/tiles/map2_55")
	if err != nil {
		t.Fatalf("first GET failed: %v", err)
	}
	body1, err := io.ReadAll(resp1.Body)
	resp1.Body.Close()
	if err != nil {
		t.Fatalf("failed to read first response: %v", err)
	}

	resp2, err := http.Get(srv.URL + "/tiles/map2_55")
	if err != nil {
		t.Fatalf("second GET failed: %v", err)
	}
	body2, err := io.ReadAll(resp2.Body)
	resp2.Body.Close()
	if err != nil {
		t.Fatalf("failed to read second response: %v", err)
	}

	if !bytes.Equal(body1, body2) {
		t.Errorf("cached response should return identical bytes: %d vs %d bytes", len(body1), len(body2))
	}
}

func TestHTTPTileInvalidAddress(t *testing.T) {
	srv := setupTestServer(t)
	defer srv.Close()

	tests := []struct {
		path string
		desc string
	}{
		{"/tiles/invalid", "non-map2 root"},
		{"/tiles/map2_abc", "non-numeric index"},
		{"/tiles/map2_35_07_42_55_00_99", "too deep (depth 6)"},
	}

	for _, tt := range tests {
		resp, err := http.Get(srv.URL + tt.path)
		if err != nil {
			t.Fatalf("GET %s failed: %v", tt.path, err)
		}
		resp.Body.Close()

		if resp.StatusCode != http.StatusBadRequest {
			t.Errorf("%s: expected 400, got %d", tt.desc, resp.StatusCode)
		}
	}
}

func TestHTTPTileRootAddress(t *testing.T) {
	srv := setupTestServer(t)
	defer srv.Close()

	resp, err := http.Get(srv.URL + "/tiles/map2")
	if err != nil {
		t.Fatalf("GET /tiles/map2 failed: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		t.Errorf("expected 200 for root tile, got %d", resp.StatusCode)
	}
}
