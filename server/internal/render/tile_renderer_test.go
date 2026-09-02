package render

import (
	"bytes"
	"image/png"
	"testing"
)

func loadTestRenderer(t *testing.T) *TileRenderer {
	t.Helper()
	atlas, err := NewSpriteAtlas(spritesDir(t))
	if err != nil {
		t.Fatalf("NewSpriteAtlas failed: %v", err)
	}
	return NewTileRenderer(atlas, 42, 256)
}

func TestCompositeTileOutputDimensions(t *testing.T) {
	renderer := loadTestRenderer(t)

	img := renderer.CompositeTile("map2")
	bounds := img.Bounds()
	if bounds.Dx() != 256 || bounds.Dy() != 256 {
		t.Errorf("expected 256x256, got %dx%d", bounds.Dx(), bounds.Dy())
	}
}

func TestCompositeTileDeterministic(t *testing.T) {
	renderer := loadTestRenderer(t)

	data1, err := renderer.RenderTile("map2_35")
	if err != nil {
		t.Fatalf("first render failed: %v", err)
	}

	renderer.mu.Lock()
	delete(renderer.cache, "map2_35")
	renderer.mu.Unlock()

	data2, err := renderer.RenderTile("map2_35")
	if err != nil {
		t.Fatalf("second render failed: %v", err)
	}

	if !bytes.Equal(data1, data2) {
		t.Errorf("same address + seed should produce identical PNG bytes (got %d vs %d bytes)", len(data1), len(data2))
	}
}

func TestCompositeTileAllCellsFilled(t *testing.T) {
	renderer := loadTestRenderer(t)

	img := renderer.CompositeTile("map2")
	bounds := img.Bounds()

	transparentCount := 0
	totalPixels := bounds.Dx() * bounds.Dy()
	for y := bounds.Min.Y; y < bounds.Max.Y; y++ {
		for x := bounds.Min.X; x < bounds.Max.X; x++ {
			_, _, _, a := img.At(x, y).RGBA()
			if a == 0 {
				transparentCount++
			}
		}
	}

	maxTransparent := totalPixels / 20
	if transparentCount > maxTransparent {
		t.Errorf("too many transparent pixels: %d/%d (max allowed %d)", transparentCount, totalPixels, maxTransparent)
	}
}

func TestLeafTileRendering(t *testing.T) {
	renderer := loadTestRenderer(t)

	leafAddress := "map2_35_07_42_55_00"
	data, err := renderer.RenderTile(leafAddress)
	if err != nil {
		t.Fatalf("leaf render failed: %v", err)
	}

	img, err := png.Decode(bytes.NewReader(data))
	if err != nil {
		t.Fatalf("failed to decode leaf PNG: %v", err)
	}

	bounds := img.Bounds()
	if bounds.Dx() != 256 || bounds.Dy() != 256 {
		t.Errorf("leaf tile should be 256x256, got %dx%d", bounds.Dx(), bounds.Dy())
	}
}

func TestRenderTileCache(t *testing.T) {
	renderer := loadTestRenderer(t)

	data1, err := renderer.RenderTile("map2_55")
	if err != nil {
		t.Fatalf("first render failed: %v", err)
	}

	data2, err := renderer.RenderTile("map2_55")
	if err != nil {
		t.Fatalf("cached render failed: %v", err)
	}

	if &data1[0] != &data2[0] {
		t.Error("cached render should return the exact same byte slice")
	}
}

func TestRenderTileValidPNG(t *testing.T) {
	renderer := loadTestRenderer(t)

	data, err := renderer.RenderTile("map2")
	if err != nil {
		t.Fatalf("render failed: %v", err)
	}

	if len(data) < 8 {
		t.Fatal("PNG data too short")
	}

	pngHeader := []byte{0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a}
	if !bytes.Equal(data[:8], pngHeader) {
		t.Error("output does not start with PNG magic header")
	}

	_, err = png.Decode(bytes.NewReader(data))
	if err != nil {
		t.Fatalf("output is not a valid PNG: %v", err)
	}
}
