package api_test

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"path/filepath"
	"testing"

	"worldbuilder/internal/api"
	"worldbuilder/internal/database"
)

func newTestServer(t *testing.T, dbPath string) *httptest.Server {
	t.Helper()
	db, err := database.New(dbPath)
	if err != nil {
		t.Fatalf("open database: %v", err)
	}
	t.Cleanup(func() { db.Close() })
	return httptest.NewServer(api.NewHandler(db))
}

func request(t *testing.T, client *http.Client, method, url string, body any) *http.Response {
	t.Helper()
	var input *bytes.Reader
	if body == nil {
		input = bytes.NewReader(nil)
	} else {
		encoded, err := json.Marshal(body)
		if err != nil {
			t.Fatal(err)
		}
		input = bytes.NewReader(encoded)
	}
	req, err := http.NewRequest(method, url, input)
	if err != nil {
		t.Fatal(err)
	}
	if body != nil {
		req.Header.Set("Content-Type", "application/json")
	}
	resp, err := client.Do(req)
	if err != nil {
		t.Fatal(err)
	}
	return resp
}

func decode[T any](t *testing.T, response *http.Response) T {
	t.Helper()
	defer response.Body.Close()
	var value T
	if err := json.NewDecoder(response.Body).Decode(&value); err != nil {
		t.Fatal(err)
	}
	return value
}

func TestWorldBuilderHTTPAPI(t *testing.T) {
	srv := newTestServer(t, filepath.Join(t.TempDir(), "world.db"))
	defer srv.Close()

	resp := request(t, srv.Client(), http.MethodGet, srv.URL+"/health", nil)
	if resp.StatusCode != http.StatusOK {
		t.Fatalf("health status = %d", resp.StatusCode)
	}
	var health struct {
		Status string `json:"status"`
	}
	health = decode[struct {
		Status string `json:"status"`
	}](t, resp)
	if health.Status != "ok" {
		t.Fatalf("health = %#v", health)
	}

	resp = request(t, srv.Client(), http.MethodGet, srv.URL+"/api/tile-definitions?category=terrain", nil)
	if resp.StatusCode != http.StatusOK {
		t.Fatalf("catalog status = %d", resp.StatusCode)
	}
	var catalog struct {
		TileDefinitions []struct {
			ID       string `json:"id"`
			Category string `json:"category"`
			Name     string `json:"name"`
		} `json:"tile_definitions"`
	}
	catalog = decode[struct {
		TileDefinitions []struct {
			ID       string `json:"id"`
			Category string `json:"category"`
			Name     string `json:"name"`
		} `json:"tile_definitions"`
	}](t, resp)
	if len(catalog.TileDefinitions) < 2 || catalog.TileDefinitions[0].ID != "terrain.dirt" || catalog.TileDefinitions[1].ID != "terrain.grass" {
		t.Fatalf("unexpected catalog: %#v", catalog)
	}

	placement := map[string]string{"tile_definition_id": "terrain.grass"}
	resp = request(t, srv.Client(), http.MethodPut, srv.URL+"/api/worlds/starter/tiles/-2/5", placement)
	if resp.StatusCode != http.StatusOK {
		t.Fatalf("put status = %d", resp.StatusCode)
	}
	var saved struct {
		X, Y             int
		TileDefinitionID string `json:"tile_definition_id"`
	}
	saved = decode[struct {
		X, Y             int
		TileDefinitionID string `json:"tile_definition_id"`
	}](t, resp)
	if saved.X != -2 || saved.Y != 5 || saved.TileDefinitionID != "terrain.grass" {
		t.Fatalf("saved = %#v", saved)
	}

	resp = request(t, srv.Client(), http.MethodPut, srv.URL+"/api/worlds/starter/tiles/-2/5", map[string]string{"tile_definition_id": "terrain.dirt"})
	if resp.StatusCode != http.StatusOK {
		t.Fatalf("upsert status = %d", resp.StatusCode)
	}
	resp.Body.Close()
	resp = request(t, srv.Client(), http.MethodGet, srv.URL+"/api/worlds/starter/tiles", nil)
	var world struct {
		WorldName string `json:"world_name"`
		Tiles     []struct {
			X, Y             int
			TileDefinitionID string `json:"tile_definition_id"`
		} `json:"tiles"`
	}
	world = decode[struct {
		WorldName string `json:"world_name"`
		Tiles     []struct {
			X, Y             int
			TileDefinitionID string `json:"tile_definition_id"`
		} `json:"tiles"`
	}](t, resp)
	if world.WorldName != "starter" || len(world.Tiles) != 1 || world.Tiles[0].TileDefinitionID != "terrain.dirt" {
		t.Fatalf("world = %#v", world)
	}

	resp = request(t, srv.Client(), http.MethodDelete, srv.URL+"/api/worlds/starter/tiles/-2/5", nil)
	if resp.StatusCode != http.StatusNoContent {
		t.Fatalf("delete status = %d", resp.StatusCode)
	}
	resp.Body.Close()
	resp = request(t, srv.Client(), http.MethodGet, srv.URL+"/api/worlds/starter/tiles", nil)
	world = decode[struct {
		WorldName string `json:"world_name"`
		Tiles     []struct {
			X, Y             int
			TileDefinitionID string `json:"tile_definition_id"`
		} `json:"tiles"`
	}](t, resp)
	if len(world.Tiles) != 0 {
		t.Fatalf("tiles after delete = %#v", world.Tiles)
	}
}

func TestWorldBuilderRejectsUnknownTileDefinition(t *testing.T) {
	srv := newTestServer(t, filepath.Join(t.TempDir(), "world.db"))
	defer srv.Close()
	resp := request(t, srv.Client(), http.MethodPut, srv.URL+"/api/worlds/starter/tiles/0/0", map[string]string{"tile_definition_id": "unknown"})
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusBadRequest {
		t.Fatalf("status = %d", resp.StatusCode)
	}
}

func TestPlacementsPersistAcrossDatabaseReopen(t *testing.T) {
	dbPath := filepath.Join(t.TempDir(), "world.db")
	srv := newTestServer(t, dbPath)
	resp := request(t, srv.Client(), http.MethodPut, srv.URL+"/api/worlds/persisted/tiles/1/-1", map[string]string{"tile_definition_id": "structure.wall"})
	if resp.StatusCode != http.StatusOK {
		t.Fatalf("put status = %d", resp.StatusCode)
	}
	resp.Body.Close()
	srv.Close()

	srv = newTestServer(t, dbPath)
	defer srv.Close()
	resp = request(t, srv.Client(), http.MethodGet, srv.URL+"/api/worlds/persisted/tiles", nil)
	world := decode[struct {
		Tiles []struct {
			X, Y             int
			TileDefinitionID string `json:"tile_definition_id"`
		} `json:"tiles"`
	}](t, resp)
	if len(world.Tiles) != 1 || world.Tiles[0].X != 1 || world.Tiles[0].Y != -1 || world.Tiles[0].TileDefinitionID != "structure.wall" {
		t.Fatalf("reopened world = %#v", world)
	}
}
