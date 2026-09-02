package models

import (
	"database/sql"
	"fmt"
	"time"
)

type Tile struct {
	Address       string    `json:"address"`
	ParentAddress *string   `json:"parent_address,omitempty"`
	Depth         int       `json:"depth"`
	GridCol       int       `json:"grid_col"`
	GridRow       int       `json:"grid_row"`
	TerrainID     string    `json:"terrain_id"`
	WorldSeed     int       `json:"world_seed"`
	CreatedAt     time.Time `json:"created_at"`
}

type TileService struct {
	db *sql.DB
}

func NewTileService(db *sql.DB) *TileService {
	return &TileService{db: db}
}

func (s *TileService) GetOrCreate(address string, worldSeed int) (*Tile, error) {
	var t Tile
	err := s.db.QueryRow(
		"SELECT address, parent_address, depth, grid_col, grid_row, terrain_id, world_seed, created_at FROM tiles WHERE address = ?",
		address,
	).Scan(&t.Address, &t.ParentAddress, &t.Depth, &t.GridCol, &t.GridRow, &t.TerrainID, &t.WorldSeed, &t.CreatedAt)
	if err == nil {
		return &t, nil
	}
	if err != sql.ErrNoRows {
		return nil, fmt.Errorf("failed to query tile %s: %w", address, err)
	}

	depth := Depth(address)
	terrainID := TerrainForAddress(address, worldSeed)

	index := LastIndex(address)
	col := 0
	row := 0
	if index >= 0 {
		col = IndexToCol(index)
		row = IndexToRow(index)
	}

	var parentAddr *string
	if depth > 0 {
		p := Parent(address)
		if p != "" {
			parentAddr = &p
			_, err := s.GetOrCreate(p, worldSeed)
			if err != nil {
				return nil, fmt.Errorf("failed to ensure parent tile %s: %w", p, err)
			}
		}
	}

	_, err = s.db.Exec(`
		INSERT OR IGNORE INTO tiles (address, parent_address, depth, grid_col, grid_row, terrain_id, world_seed)
		VALUES (?, ?, ?, ?, ?, ?, ?)
	`, address, parentAddr, depth, col, row, terrainID, worldSeed)
	if err != nil {
		return nil, fmt.Errorf("failed to create tile %s: %w", address, err)
	}

	err = s.db.QueryRow(
		"SELECT address, parent_address, depth, grid_col, grid_row, terrain_id, world_seed, created_at FROM tiles WHERE address = ?",
		address,
	).Scan(&t.Address, &t.ParentAddress, &t.Depth, &t.GridCol, &t.GridRow, &t.TerrainID, &t.WorldSeed, &t.CreatedAt)
	if err != nil {
		return nil, fmt.Errorf("failed to read tile %s after insert: %w", address, err)
	}
	return &t, nil
}

func (s *TileService) GetByAddress(address string) (*Tile, error) {
	var t Tile
	err := s.db.QueryRow(
		"SELECT address, parent_address, depth, grid_col, grid_row, terrain_id, world_seed, created_at FROM tiles WHERE address = ?",
		address,
	).Scan(&t.Address, &t.ParentAddress, &t.Depth, &t.GridCol, &t.GridRow, &t.TerrainID, &t.WorldSeed, &t.CreatedAt)
	if err != nil {
		return nil, fmt.Errorf("failed to get tile %s: %w", address, err)
	}
	return &t, nil
}

func (s *TileService) GetChildren(address string) ([]Tile, error) {
	rows, err := s.db.Query(
		"SELECT address, parent_address, depth, grid_col, grid_row, terrain_id, world_seed, created_at FROM tiles WHERE parent_address = ? ORDER BY address",
		address,
	)
	if err != nil {
		return nil, fmt.Errorf("failed to query children of %s: %w", address, err)
	}
	defer rows.Close()

	var tiles []Tile
	for rows.Next() {
		var t Tile
		if err := rows.Scan(&t.Address, &t.ParentAddress, &t.Depth, &t.GridCol, &t.GridRow, &t.TerrainID, &t.WorldSeed, &t.CreatedAt); err != nil {
			return nil, fmt.Errorf("failed to scan tile: %w", err)
		}
		tiles = append(tiles, t)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("failed iterating tile rows: %w", err)
	}
	return tiles, nil
}

func (s *TileService) MaterializeChildren(address string, worldSeed int) ([]Tile, error) {
	children := Children(address)
	if children == nil {
		return nil, nil
	}

	_, err := s.GetOrCreate(address, worldSeed)
	if err != nil {
		return nil, fmt.Errorf("failed to ensure parent tile %s: %w", address, err)
	}

	tx, err := s.db.Begin()
	if err != nil {
		return nil, fmt.Errorf("failed to begin transaction: %w", err)
	}
	defer tx.Rollback()

	stmt, err := tx.Prepare(`
		INSERT OR IGNORE INTO tiles (address, parent_address, depth, grid_col, grid_row, terrain_id, world_seed)
		VALUES (?, ?, ?, ?, ?, ?, ?)
	`)
	if err != nil {
		return nil, fmt.Errorf("failed to prepare statement: %w", err)
	}
	defer stmt.Close()

	childDepth := Depth(address) + 1
	for i, childAddr := range children {
		col := IndexToCol(i)
		row := IndexToRow(i)
		terrainID := TerrainForAddress(childAddr, worldSeed)
		if _, err := stmt.Exec(childAddr, address, childDepth, col, row, terrainID, worldSeed); err != nil {
			return nil, fmt.Errorf("failed to insert child tile %s: %w", childAddr, err)
		}
	}

	if err := tx.Commit(); err != nil {
		return nil, fmt.Errorf("failed to commit child materialization: %w", err)
	}

	return s.GetChildren(address)
}

func (s *TileService) MaterializeWorld(worldSeed int) (int, error) {
	rootAddr := RootAddress

	tx, err := s.db.Begin()
	if err != nil {
		return 0, fmt.Errorf("failed to begin transaction: %w", err)
	}
	defer tx.Rollback()

	_, err = tx.Exec(`
		INSERT OR IGNORE INTO tiles (address, parent_address, depth, grid_col, grid_row, terrain_id, world_seed)
		VALUES (?, NULL, 0, 0, 0, 'plains', ?)
	`, rootAddr, worldSeed)
	if err != nil {
		return 0, fmt.Errorf("failed to insert root tile: %w", err)
	}

	stmt, err := tx.Prepare(`
		INSERT OR IGNORE INTO tiles (address, parent_address, depth, grid_col, grid_row, terrain_id, world_seed)
		VALUES (?, ?, 1, ?, ?, ?, ?)
	`)
	if err != nil {
		return 0, fmt.Errorf("failed to prepare statement: %w", err)
	}
	defer stmt.Close()

	count := 0
	for i := 0; i < ChildrenPerTile; i++ {
		childAddr := TileAddress(rootAddr, i)
		col := IndexToCol(i)
		row := IndexToRow(i)
		terrainID := TerrainForAddress(childAddr, worldSeed)
		if _, err := stmt.Exec(childAddr, rootAddr, col, row, terrainID, worldSeed); err != nil {
			return 0, fmt.Errorf("failed to insert world tile %s: %w", childAddr, err)
		}
		count++
	}

	if err := tx.Commit(); err != nil {
		return 0, fmt.Errorf("failed to commit world materialization: %w", err)
	}
	return count, nil
}

func (s *TileService) GetWorldTiles() ([]Tile, error) {
	rows, err := s.db.Query(
		"SELECT address, parent_address, depth, grid_col, grid_row, terrain_id, world_seed, created_at FROM tiles WHERE depth = 1 ORDER BY address",
	)
	if err != nil {
		return nil, fmt.Errorf("failed to query world tiles: %w", err)
	}
	defer rows.Close()

	var tiles []Tile
	for rows.Next() {
		var t Tile
		if err := rows.Scan(&t.Address, &t.ParentAddress, &t.Depth, &t.GridCol, &t.GridRow, &t.TerrainID, &t.WorldSeed, &t.CreatedAt); err != nil {
			return nil, fmt.Errorf("failed to scan world tile: %w", err)
		}
		tiles = append(tiles, t)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("failed iterating world tile rows: %w", err)
	}
	return tiles, nil
}
