package models

import (
	"database/sql"
	"fmt"
	"time"
)

type ExploredTile struct {
	ID           int       `json:"id"`
	CharacterID  int       `json:"character_id"`
	Address      string    `json:"address"`
	TerrainID    *string   `json:"terrain_id,omitempty"`
	DiscoveredAt time.Time `json:"discovered_at"`
}

type ExploredTileService struct {
	db *sql.DB
}

func NewExploredTileService(db *sql.DB) *ExploredTileService {
	return &ExploredTileService{db: db}
}

func (s *ExploredTileService) MarkExplored(characterID int, address string, terrainID *string) error {
	_, err := s.db.Exec(`
		INSERT OR IGNORE INTO explored_tiles (character_id, address, terrain_id)
		VALUES (?, ?, ?)
	`, characterID, address, terrainID)
	if err != nil {
		return fmt.Errorf("failed to mark tile explored: %w", err)
	}
	return nil
}

func (s *ExploredTileService) GetExploredByDepth(characterID int, depth int) ([]ExploredTile, error) {
	rows, err := s.db.Query(`
		SELECT id, character_id, address, terrain_id, discovered_at
		FROM explored_tiles
		WHERE character_id = ?
		  AND length(address) - length(replace(address, '_', '')) = ?
		ORDER BY discovered_at
	`, characterID, depth)
	if err != nil {
		return nil, fmt.Errorf("failed to query explored tiles: %w", err)
	}
	defer rows.Close()

	var tiles []ExploredTile
	for rows.Next() {
		var t ExploredTile
		if err := rows.Scan(&t.ID, &t.CharacterID, &t.Address, &t.TerrainID, &t.DiscoveredAt); err != nil {
			return nil, fmt.Errorf("failed to scan explored tile: %w", err)
		}
		tiles = append(tiles, t)
	}
	return tiles, nil
}

func (s *ExploredTileService) GetAllExplored(characterID int) ([]ExploredTile, error) {
	rows, err := s.db.Query(`
		SELECT id, character_id, address, terrain_id, discovered_at
		FROM explored_tiles WHERE character_id = ? ORDER BY discovered_at
	`, characterID)
	if err != nil {
		return nil, fmt.Errorf("failed to query explored tiles: %w", err)
	}
	defer rows.Close()

	var tiles []ExploredTile
	for rows.Next() {
		var t ExploredTile
		if err := rows.Scan(&t.ID, &t.CharacterID, &t.Address, &t.TerrainID, &t.DiscoveredAt); err != nil {
			return nil, fmt.Errorf("failed to scan explored tile: %w", err)
		}
		tiles = append(tiles, t)
	}
	return tiles, nil
}

func (s *ExploredTileService) IsExplored(characterID int, address string) (bool, error) {
	var count int
	err := s.db.QueryRow(
		"SELECT COUNT(*) FROM explored_tiles WHERE character_id = ? AND address = ?",
		characterID, address,
	).Scan(&count)
	if err != nil {
		return false, fmt.Errorf("failed to check explored tile: %w", err)
	}
	return count > 0, nil
}
