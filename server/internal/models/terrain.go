package models

import (
	"database/sql"
	"fmt"
	"time"
)

type Terrain struct {
	ID            string    `json:"id"`
	Name          string    `json:"name"`
	Color         string    `json:"color"`
	MoveCost      float64   `json:"move_cost"`
	LostChance    int       `json:"lost_chance"`
	VisionRange   int       `json:"vision_range"`
	EncounterFreq string    `json:"encounter_freq"`
	CreatedAt     time.Time `json:"created_at"`
}

type TerrainService struct {
	db *sql.DB
}

func NewTerrainService(db *sql.DB) *TerrainService {
	return &TerrainService{db: db}
}

func (s *TerrainService) GetAll() ([]Terrain, error) {
	rows, err := s.db.Query(`
		SELECT id, name, color, move_cost, lost_chance, vision_range, encounter_freq, created_at
		FROM terrain ORDER BY name
	`)
	if err != nil {
		return nil, fmt.Errorf("failed to query terrain: %w", err)
	}
	defer rows.Close()

	var terrains []Terrain
	for rows.Next() {
		var t Terrain
		if err := rows.Scan(&t.ID, &t.Name, &t.Color, &t.MoveCost, &t.LostChance,
			&t.VisionRange, &t.EncounterFreq, &t.CreatedAt); err != nil {
			return nil, fmt.Errorf("failed to scan terrain: %w", err)
		}
		terrains = append(terrains, t)
	}
	return terrains, nil
}

func (s *TerrainService) GetByID(id string) (*Terrain, error) {
	var t Terrain
	err := s.db.QueryRow(`
		SELECT id, name, color, move_cost, lost_chance, vision_range, encounter_freq, created_at
		FROM terrain WHERE id = ?
	`, id).Scan(&t.ID, &t.Name, &t.Color, &t.MoveCost, &t.LostChance,
		&t.VisionRange, &t.EncounterFreq, &t.CreatedAt)
	if err != nil {
		return nil, fmt.Errorf("failed to get terrain %s: %w", id, err)
	}
	return &t, nil
}
