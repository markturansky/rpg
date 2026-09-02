package models

import (
	"database/sql"
	"fmt"
)

type EncounterEntry struct {
	ID         int     `json:"id"`
	TerrainID  string  `json:"terrain_id"`
	RollValue  int     `json:"roll_value"`
	MonsterID  *string `json:"monster_id,omitempty"`
	CountDice  int     `json:"count_dice"`
	CountDie   int     `json:"count_die"`
	XPOverride *int    `json:"xp_override,omitempty"`
	Notes      *string `json:"notes,omitempty"`
}

type EncounterService struct {
	db *sql.DB
}

func NewEncounterService(db *sql.DB) *EncounterService {
	return &EncounterService{db: db}
}

func (s *EncounterService) GetByTerrain(terrainID string) ([]EncounterEntry, error) {
	rows, err := s.db.Query(`
		SELECT id, terrain_id, roll_value, monster_id, count_dice, count_die, xp_override, notes
		FROM encounter_tables WHERE terrain_id = ? ORDER BY roll_value
	`, terrainID)
	if err != nil {
		return nil, fmt.Errorf("failed to query encounters for %s: %w", terrainID, err)
	}
	defer rows.Close()

	var entries []EncounterEntry
	for rows.Next() {
		var e EncounterEntry
		if err := rows.Scan(&e.ID, &e.TerrainID, &e.RollValue, &e.MonsterID,
			&e.CountDice, &e.CountDie, &e.XPOverride, &e.Notes); err != nil {
			return nil, fmt.Errorf("failed to scan encounter: %w", err)
		}
		entries = append(entries, e)
	}
	return entries, nil
}

func (s *EncounterService) GetByTerrainAndRoll(terrainID string, roll int) (*EncounterEntry, error) {
	var e EncounterEntry
	err := s.db.QueryRow(`
		SELECT id, terrain_id, roll_value, monster_id, count_dice, count_die, xp_override, notes
		FROM encounter_tables WHERE terrain_id = ? AND roll_value = ?
	`, terrainID, roll).Scan(&e.ID, &e.TerrainID, &e.RollValue, &e.MonsterID,
		&e.CountDice, &e.CountDie, &e.XPOverride, &e.Notes)
	if err != nil {
		return nil, fmt.Errorf("failed to get encounter %s roll %d: %w", terrainID, roll, err)
	}
	return &e, nil
}
