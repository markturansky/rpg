package models

import (
	"database/sql"
	"testing"

	_ "github.com/mattn/go-sqlite3"
)

func setupTestDB(t *testing.T) *sql.DB {
	t.Helper()
	db, err := sql.Open("sqlite3", ":memory:?_foreign_keys=on")
	if err != nil {
		t.Fatalf("failed to open test db: %v", err)
	}

	_, err = db.Exec(`
		CREATE TABLE IF NOT EXISTS terrain (
			id TEXT PRIMARY KEY,
			name TEXT NOT NULL,
			color TEXT NOT NULL,
			move_cost REAL NOT NULL,
			lost_chance INTEGER DEFAULT 0,
			vision_range INTEGER DEFAULT 2,
			encounter_freq TEXT DEFAULT '1-in-6',
			created_at DATETIME DEFAULT CURRENT_TIMESTAMP
		);

		INSERT INTO terrain (id, name, color, move_cost) VALUES
			('deep-water', 'Deep Water', '#000080', 999.0),
			('shallow-water', 'Shallow Water', '#4169E1', 2.0),
			('beach', 'Beach', '#F4E4C1', 1.0),
			('marsh', 'Marsh', '#556B2F', 3.0),
			('grassland', 'Grassland', '#7CFC00', 1.0),
			('plains', 'Plains', '#F0E68C', 1.0),
			('forest', 'Forest', '#228B22', 2.0),
			('dense-forest', 'Dense Forest', '#006400', 2.5),
			('hills', 'Hills', '#8B7355', 2.0),
			('mountain', 'Mountain', '#808080', 3.0),
			('desert', 'Desert', '#EDC9AF', 2.0),
			('tundra', 'Tundra', '#B0C4DE', 2.0),
			('road', 'Road', '#A0522D', 0.5);

		CREATE TABLE IF NOT EXISTS tiles (
			address TEXT PRIMARY KEY,
			parent_address TEXT REFERENCES tiles(address),
			depth INTEGER NOT NULL,
			grid_col INTEGER NOT NULL DEFAULT 0,
			grid_row INTEGER NOT NULL DEFAULT 0,
			terrain_id TEXT NOT NULL REFERENCES terrain(id),
			world_seed INTEGER NOT NULL,
			created_at DATETIME DEFAULT CURRENT_TIMESTAMP
		);
	`)
	if err != nil {
		t.Fatalf("failed to setup schema: %v", err)
	}
	return db
}

func TestTileServiceGetOrCreate(t *testing.T) {
	db := setupTestDB(t)
	defer db.Close()
	svc := NewTileService(db)

	tile, err := svc.GetOrCreate("map2_55", 42)
	if err != nil {
		t.Fatalf("GetOrCreate(map2_55, 42) failed: %v", err)
	}
	if tile.Address != "map2_55" {
		t.Errorf("address = %q, want map2_55", tile.Address)
	}
	if tile.Depth != 1 {
		t.Errorf("depth = %d, want 1", tile.Depth)
	}
	if tile.TerrainID == "" {
		t.Error("terrain_id should not be empty")
	}
	if tile.GridCol != 5 {
		t.Errorf("grid_col = %d, want 5", tile.GridCol)
	}
	if tile.GridRow != 5 {
		t.Errorf("grid_row = %d, want 5", tile.GridRow)
	}
}

func TestTileServiceGetOrCreateIdempotent(t *testing.T) {
	db := setupTestDB(t)
	defer db.Close()
	svc := NewTileService(db)

	tile1, err := svc.GetOrCreate("map2_55", 42)
	if err != nil {
		t.Fatalf("first GetOrCreate failed: %v", err)
	}
	tile2, err := svc.GetOrCreate("map2_55", 42)
	if err != nil {
		t.Fatalf("second GetOrCreate failed: %v", err)
	}
	if tile1.Address != tile2.Address || tile1.TerrainID != tile2.TerrainID {
		t.Error("GetOrCreate is not idempotent")
	}
}

func TestTileServiceGetOrCreateChild(t *testing.T) {
	db := setupTestDB(t)
	defer db.Close()
	svc := NewTileService(db)

	tile, err := svc.GetOrCreate("map2_55_07", 42)
	if err != nil {
		t.Fatalf("GetOrCreate(map2_55_07, 42) failed: %v", err)
	}
	if tile.Depth != 2 {
		t.Errorf("depth = %d, want 2", tile.Depth)
	}
	if tile.ParentAddress == nil || *tile.ParentAddress != "map2_55" {
		t.Errorf("parent_address should be map2_55, got %v", tile.ParentAddress)
	}

	parent, err := svc.GetByAddress("map2_55")
	if err != nil {
		t.Fatalf("parent should have been auto-created: %v", err)
	}
	if parent.Depth != 1 {
		t.Errorf("parent depth = %d, want 1", parent.Depth)
	}
}

func TestTileServiceGetByAddress(t *testing.T) {
	db := setupTestDB(t)
	defer db.Close()
	svc := NewTileService(db)

	_, err := svc.GetOrCreate("map2_55", 42)
	if err != nil {
		t.Fatal(err)
	}

	tile, err := svc.GetByAddress("map2_55")
	if err != nil {
		t.Fatalf("GetByAddress failed: %v", err)
	}
	if tile.Address != "map2_55" {
		t.Errorf("address = %q, want map2_55", tile.Address)
	}

	_, err = svc.GetByAddress("map2_99")
	if err == nil {
		t.Error("expected error for nonexistent address")
	}
}

func TestTileServiceGetChildren(t *testing.T) {
	db := setupTestDB(t)
	defer db.Close()
	svc := NewTileService(db)

	_, err := svc.GetOrCreate("map2_55", 42)
	if err != nil {
		t.Fatal(err)
	}

	children, err := svc.GetChildren("map2_55")
	if err != nil {
		t.Fatalf("GetChildren failed: %v", err)
	}
	if len(children) != 0 {
		t.Error("should have no children yet (lazy)")
	}
}

func TestTileServiceMaterializeChildren(t *testing.T) {
	db := setupTestDB(t)
	defer db.Close()
	svc := NewTileService(db)

	children, err := svc.MaterializeChildren("map2_55", 42)
	if err != nil {
		t.Fatalf("MaterializeChildren failed: %v", err)
	}
	if len(children) != 100 {
		t.Fatalf("expected 100 children, got %d", len(children))
	}
	for _, child := range children {
		if child.Depth != 2 {
			t.Errorf("child depth = %d, want 2", child.Depth)
		}
		if child.ParentAddress == nil || *child.ParentAddress != "map2_55" {
			t.Errorf("child parent should be map2_55")
		}
	}

	stored, err := svc.GetChildren("map2_55")
	if err != nil {
		t.Fatal(err)
	}
	if len(stored) != 100 {
		t.Errorf("stored children = %d, want 100", len(stored))
	}
}

func TestTileServiceDeepChain(t *testing.T) {
	db := setupTestDB(t)
	defer db.Close()
	svc := NewTileService(db)

	tile, err := svc.GetOrCreate("map2_55_07_42", 42)
	if err != nil {
		t.Fatalf("GetOrCreate deep address failed: %v", err)
	}
	if tile.Depth != 3 {
		t.Errorf("depth = %d, want 3", tile.Depth)
	}

	for _, addr := range []string{"map2", "map2_55", "map2_55_07"} {
		_, err := svc.GetByAddress(addr)
		if err != nil {
			t.Errorf("ancestor %q should exist: %v", addr, err)
		}
	}
}

func TestTileServiceTerrainConsistency(t *testing.T) {
	db := setupTestDB(t)
	defer db.Close()
	svc := NewTileService(db)

	tile, err := svc.GetOrCreate("map2_55", 42)
	if err != nil {
		t.Fatal(err)
	}

	expectedTerrain := TerrainForAddress("map2_55", 42)
	if tile.TerrainID != expectedTerrain {
		t.Errorf("terrain = %q, want %q (from pure function)", tile.TerrainID, expectedTerrain)
	}
}

func TestMaterializeWorld(t *testing.T) {
	db := setupTestDB(t)
	defer db.Close()
	svc := NewTileService(db)

	count, err := svc.MaterializeWorld(42)
	if err != nil {
		t.Fatalf("MaterializeWorld failed: %v", err)
	}
	if count != 100 {
		t.Errorf("MaterializeWorld inserted %d tiles, want 100", count)
	}

	tiles, err := svc.GetWorldTiles()
	if err != nil {
		t.Fatalf("GetWorldTiles failed: %v", err)
	}
	if len(tiles) != 100 {
		t.Errorf("GetWorldTiles returned %d tiles, want 100", len(tiles))
	}

	for _, tile := range tiles {
		if tile.Depth != 1 {
			t.Errorf("tile %s depth = %d, want 1", tile.Address, tile.Depth)
			break
		}
		if tile.TerrainID == "" {
			t.Errorf("tile %s has empty terrain", tile.Address)
			break
		}
		expected := TerrainForAddress(tile.Address, 42)
		if tile.TerrainID != expected {
			t.Errorf("tile %s terrain = %q, pure function says %q", tile.Address, tile.TerrainID, expected)
			break
		}
	}
}

func TestMaterializeWorldIdempotent(t *testing.T) {
	db := setupTestDB(t)
	defer db.Close()
	svc := NewTileService(db)

	svc.MaterializeWorld(42)
	count2, err := svc.MaterializeWorld(42)
	if err != nil {
		t.Fatalf("second MaterializeWorld failed: %v", err)
	}
	if count2 != 100 {
		t.Errorf("second call count = %d, want 100", count2)
	}

	tiles, _ := svc.GetWorldTiles()
	if len(tiles) != 100 {
		t.Errorf("expected 100 tiles after double materialize, got %d", len(tiles))
	}
}

func TestWorldEagerRegionalLazy(t *testing.T) {
	db := setupTestDB(t)
	defer db.Close()
	svc := NewTileService(db)

	svc.MaterializeWorld(42)

	worldTiles, _ := svc.GetWorldTiles()
	if len(worldTiles) != 100 {
		t.Fatalf("expected 100 world tiles, got %d", len(worldTiles))
	}

	children, _ := svc.GetChildren("map2_55")
	if len(children) != 0 {
		t.Errorf("regional children should not exist yet (lazy), got %d", len(children))
	}

	regional, err := svc.MaterializeChildren("map2_55", 42)
	if err != nil {
		t.Fatalf("MaterializeChildren failed: %v", err)
	}
	if len(regional) != 100 {
		t.Fatalf("expected 100 regional children, got %d", len(regional))
	}
	for _, r := range regional {
		if r.Depth != 2 {
			t.Errorf("regional tile %s depth = %d, want 2", r.Address, r.Depth)
		}
	}

	grandchildren, _ := svc.GetChildren(regional[0].Address)
	if len(grandchildren) != 0 {
		t.Errorf("area children should not exist yet, got %d", len(grandchildren))
	}
}

func TestWorldTerrainDistribution(t *testing.T) {
	terrainCounts := map[string]int{}
	for i := 0; i < 100; i++ {
		addr := TileAddress("map2", i)
		terrain := TerrainForAddress(addr, 42)
		terrainCounts[terrain]++
	}

	if len(terrainCounts) < 2 {
		t.Errorf("expected at least 2 terrain types in world, got %d: %v", len(terrainCounts), terrainCounts)
	}
}

func TestWorldGridDimensions(t *testing.T) {
	totalTiles := GridCols * GridRows
	if totalTiles != 100 {
		t.Errorf("expected 100 world tiles, got %d", totalTiles)
	}

	childrenPerTile := ChildrenPerTile
	totalRegional := totalTiles * childrenPerTile
	if totalRegional != 10000 {
		t.Errorf("expected 10000 regional tiles, got %d", totalRegional)
	}
}
