package models

import (
	"database/sql"
	"fmt"
	"time"
)

type Spell struct {
	ID          string    `json:"id"`
	Name        string    `json:"name"`
	ClassID     string    `json:"class_id"`
	Level       int       `json:"level"`
	Effect      *string   `json:"effect,omitempty"`
	Damage      *string   `json:"damage,omitempty"`
	Duration    *string   `json:"duration,omitempty"`
	Range       *string   `json:"range,omitempty"`
	SaveType    *string   `json:"save_type,omitempty"`
	CastingTime int       `json:"casting_time"`
	CreatedAt   time.Time `json:"created_at"`
}

type SpellService struct {
	db *sql.DB
}

func NewSpellService(db *sql.DB) *SpellService {
	return &SpellService{db: db}
}

func (s *SpellService) GetAll() ([]Spell, error) {
	rows, err := s.db.Query(`
		SELECT id, name, class_id, level, effect, damage, duration, range, save_type, casting_time, created_at
		FROM spells ORDER BY class_id, level, name
	`)
	if err != nil {
		return nil, fmt.Errorf("failed to query spells: %w", err)
	}
	defer rows.Close()

	var spells []Spell
	for rows.Next() {
		var sp Spell
		if err := rows.Scan(&sp.ID, &sp.Name, &sp.ClassID, &sp.Level, &sp.Effect,
			&sp.Damage, &sp.Duration, &sp.Range, &sp.SaveType, &sp.CastingTime, &sp.CreatedAt); err != nil {
			return nil, fmt.Errorf("failed to scan spell: %w", err)
		}
		spells = append(spells, sp)
	}
	return spells, nil
}

func (s *SpellService) GetByClassAndLevel(classID string, level int) ([]Spell, error) {
	rows, err := s.db.Query(`
		SELECT id, name, class_id, level, effect, damage, duration, range, save_type, casting_time, created_at
		FROM spells WHERE class_id = ? AND level = ? ORDER BY name
	`, classID, level)
	if err != nil {
		return nil, fmt.Errorf("failed to query spells for %s level %d: %w", classID, level, err)
	}
	defer rows.Close()

	var spells []Spell
	for rows.Next() {
		var sp Spell
		if err := rows.Scan(&sp.ID, &sp.Name, &sp.ClassID, &sp.Level, &sp.Effect,
			&sp.Damage, &sp.Duration, &sp.Range, &sp.SaveType, &sp.CastingTime, &sp.CreatedAt); err != nil {
			return nil, fmt.Errorf("failed to scan spell: %w", err)
		}
		spells = append(spells, sp)
	}
	return spells, nil
}
