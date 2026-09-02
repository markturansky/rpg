package render

import (
	"image"
	"os"
	"path/filepath"
	"testing"
)

func spritesDir(t *testing.T) string {
	t.Helper()
	wd, err := os.Getwd()
	if err != nil {
		t.Fatalf("cannot get working directory: %v", err)
	}
	for dir := wd; dir != "/"; dir = filepath.Dir(dir) {
		candidate := filepath.Join(dir, "sprites", "sprites.json")
		if _, err := os.Stat(candidate); err == nil {
			return filepath.Join(dir, "sprites")
		}
	}
	for dir := wd; dir != "/"; dir = filepath.Dir(dir) {
		parent := filepath.Dir(dir)
		candidate := filepath.Join(parent, "sprites", "sprites.json")
		if _, err := os.Stat(candidate); err == nil {
			return filepath.Join(parent, "sprites")
		}
	}
	t.Fatal("cannot find sprites directory")
	return ""
}

func TestSpriteAtlasLoad(t *testing.T) {
	atlas, err := NewSpriteAtlas(spritesDir(t))
	if err != nil {
		t.Fatalf("NewSpriteAtlas failed: %v", err)
	}

	if len(atlas.sheets) != 3 {
		t.Errorf("expected 3 sheets, got %d", len(atlas.sheets))
	}

	if len(atlas.sprites) == 0 {
		t.Error("no sprites loaded")
	}

	expectedMinSprites := 140
	if len(atlas.sprites) < expectedMinSprites {
		t.Errorf("expected at least %d sprites, got %d", expectedMinSprites, len(atlas.sprites))
	}

	for name, ref := range atlas.sprites {
		sheet := atlas.sheets[ref.SheetIndex]
		bounds := sheet.Bounds()
		spriteRect := image.Rect(ref.X, ref.Y, ref.X+ref.W, ref.Y+ref.H)
		if !spriteRect.In(bounds) {
			t.Errorf("sprite %q region %v exceeds sheet %d bounds %v", name, spriteRect, ref.SheetIndex, bounds)
		}
	}
}

func TestSpriteAtlasTerrainMapping(t *testing.T) {
	atlas, err := NewSpriteAtlas(spritesDir(t))
	if err != nil {
		t.Fatalf("NewSpriteAtlas failed: %v", err)
	}

	requiredTerrains := []string{
		"deep-water", "shallow-water", "beach", "plains", "grassland",
		"forest", "dense-forest", "hills", "mountain", "desert",
		"marsh", "tundra", "road", "river",
	}

	for _, terrainID := range requiredTerrains {
		refs, ok := atlas.terrainMap[terrainID]
		if !ok {
			t.Errorf("terrain %q has no sprite mapping", terrainID)
			continue
		}
		if len(refs) == 0 {
			t.Errorf("terrain %q has empty sprite list", terrainID)
			continue
		}
		for _, ref := range refs {
			if ref.SheetIndex < 0 || ref.SheetIndex >= len(atlas.sheets) {
				t.Errorf("terrain %q sprite %q has invalid sheet index %d", terrainID, ref.Name, ref.SheetIndex)
			}
		}
	}
}

func TestSpriteAtlasVariantSelection(t *testing.T) {
	atlas, err := NewSpriteAtlas(spritesDir(t))
	if err != nil {
		t.Fatalf("NewSpriteAtlas failed: %v", err)
	}

	ref1 := atlas.SpriteForTerrain("plains", "map2_35", 42, 1)
	ref2 := atlas.SpriteForTerrain("plains", "map2_35", 42, 1)
	if ref1.Name != ref2.Name {
		t.Errorf("same address should produce same variant: %q != %q", ref1.Name, ref2.Name)
	}

	differentCount := 0
	for i := 0; i < 100; i++ {
		addr := TileAddressForTest("map2", i)
		ref := atlas.SpriteForTerrain("plains", addr, 42, 1)
		if ref.Name != ref1.Name {
			differentCount++
		}
	}
	if differentCount == 0 {
		t.Log("warning: all 100 addresses selected the same variant (possible but unlikely)")
	}
}

func TestSpriteAtlasMissingTerrain(t *testing.T) {
	atlas, err := NewSpriteAtlas(spritesDir(t))
	if err != nil {
		t.Fatalf("NewSpriteAtlas failed: %v", err)
	}

	ref := atlas.SpriteForTerrain("nonexistent-terrain", "map2_35", 42, 1)
	if ref.Name == "" {
		t.Error("missing terrain should return a fallback sprite, got empty name")
	}
	if ref.W <= 0 || ref.H <= 0 {
		t.Errorf("fallback sprite has invalid dimensions: %dx%d", ref.W, ref.H)
	}
}
