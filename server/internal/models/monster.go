package models

import (
	"database/sql"
	"fmt"
	"time"
)

type Monster struct {
	ID            string    `json:"id"`
	Name          string    `json:"name"`
	HitDiceCount  int       `json:"hit_dice_count"`
	HitDiceBonus  int       `json:"hit_dice_bonus"`
	XP            int       `json:"xp"`
	AC            int       `json:"ac"`
	Morale        int       `json:"morale"`
	Size          string    `json:"size"`
	Attacks       *string   `json:"attacks,omitempty"`
	Damage        *string   `json:"damage,omitempty"`
	Special       *string   `json:"special,omitempty"`
	CreatedAt     time.Time `json:"created_at"`
}

type MonsterService struct {
	db *sql.DB
}

func NewMonsterService(db *sql.DB) *MonsterService {
	return &MonsterService{db: db}
}

func (s *MonsterService) GetAll() ([]Monster, error) {
	rows, err := s.db.Query(`
		SELECT id, name, hit_dice_count, hit_dice_bonus, xp, ac, morale, size,
		       attacks, damage, special, created_at
		FROM monsters ORDER BY name
	`)
	if err != nil {
		return nil, fmt.Errorf("failed to query monsters: %w", err)
	}
	defer rows.Close()

	var monsters []Monster
	for rows.Next() {
		var m Monster
		if err := rows.Scan(&m.ID, &m.Name, &m.HitDiceCount, &m.HitDiceBonus,
			&m.XP, &m.AC, &m.Morale, &m.Size, &m.Attacks, &m.Damage,
			&m.Special, &m.CreatedAt); err != nil {
			return nil, fmt.Errorf("failed to scan monster: %w", err)
		}
		monsters = append(monsters, m)
	}
	return monsters, nil
}

func (s *MonsterService) GetByID(id string) (*Monster, error) {
	var m Monster
	err := s.db.QueryRow(`
		SELECT id, name, hit_dice_count, hit_dice_bonus, xp, ac, morale, size,
		       attacks, damage, special, created_at
		FROM monsters WHERE id = ?
	`, id).Scan(&m.ID, &m.Name, &m.HitDiceCount, &m.HitDiceBonus,
		&m.XP, &m.AC, &m.Morale, &m.Size, &m.Attacks, &m.Damage,
		&m.Special, &m.CreatedAt)
	if err != nil {
		return nil, fmt.Errorf("failed to get monster %s: %w", id, err)
	}
	return &m, nil
}
