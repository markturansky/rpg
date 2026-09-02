package models

import (
	"database/sql"
	"fmt"
	"time"
)

type Weapon struct {
	ID              string    `json:"id"`
	Name            string    `json:"name"`
	DamageSmCount   int       `json:"damage_sm_count"`
	DamageSmDie     int       `json:"damage_sm_die"`
	DamageSmBonus   int       `json:"damage_sm_bonus"`
	DamageLgCount   int       `json:"damage_lg_count"`
	DamageLgDie     int       `json:"damage_lg_die"`
	DamageLgBonus   int       `json:"damage_lg_bonus"`
	Weight          float64   `json:"weight"`
	Cost            float64   `json:"cost"`
	Type            string    `json:"type"`
	Thrown           bool      `json:"thrown"`
	AttacksPerRound float64   `json:"attacks_per_round"`
	CreatedAt       time.Time `json:"created_at"`
}

type WeaponService struct {
	db *sql.DB
}

func NewWeaponService(db *sql.DB) *WeaponService {
	return &WeaponService{db: db}
}

func (s *WeaponService) GetAll() ([]Weapon, error) {
	rows, err := s.db.Query(`
		SELECT id, name, damage_sm_count, damage_sm_die, damage_sm_bonus,
		       damage_lg_count, damage_lg_die, damage_lg_bonus,
		       weight, cost, type, thrown, attacks_per_round, created_at
		FROM weapons ORDER BY name
	`)
	if err != nil {
		return nil, fmt.Errorf("failed to query weapons: %w", err)
	}
	defer rows.Close()

	var weapons []Weapon
	for rows.Next() {
		var w Weapon
		if err := rows.Scan(&w.ID, &w.Name, &w.DamageSmCount, &w.DamageSmDie, &w.DamageSmBonus,
			&w.DamageLgCount, &w.DamageLgDie, &w.DamageLgBonus,
			&w.Weight, &w.Cost, &w.Type, &w.Thrown, &w.AttacksPerRound, &w.CreatedAt); err != nil {
			return nil, fmt.Errorf("failed to scan weapon: %w", err)
		}
		weapons = append(weapons, w)
	}
	return weapons, nil
}

func (s *WeaponService) GetByID(id string) (*Weapon, error) {
	var w Weapon
	err := s.db.QueryRow(`
		SELECT id, name, damage_sm_count, damage_sm_die, damage_sm_bonus,
		       damage_lg_count, damage_lg_die, damage_lg_bonus,
		       weight, cost, type, thrown, attacks_per_round, created_at
		FROM weapons WHERE id = ?
	`, id).Scan(&w.ID, &w.Name, &w.DamageSmCount, &w.DamageSmDie, &w.DamageSmBonus,
		&w.DamageLgCount, &w.DamageLgDie, &w.DamageLgBonus,
		&w.Weight, &w.Cost, &w.Type, &w.Thrown, &w.AttacksPerRound, &w.CreatedAt)
	if err != nil {
		return nil, fmt.Errorf("failed to get weapon %s: %w", id, err)
	}
	return &w, nil
}
