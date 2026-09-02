package models

import (
	"database/sql"
	"fmt"
	"time"
)

type Armor struct {
	ID        string    `json:"id"`
	Name      string    `json:"name"`
	AC        int       `json:"ac"`
	Weight    int       `json:"weight"`
	Cost      int       `json:"cost"`
	MoveCap   int       `json:"move_cap"`
	CreatedAt time.Time `json:"created_at"`
}

type Shield struct {
	ID        string    `json:"id"`
	Name      string    `json:"name"`
	ACBonus   int       `json:"ac_bonus"`
	Weight    int       `json:"weight"`
	Cost      int       `json:"cost"`
	CreatedAt time.Time `json:"created_at"`
}

type ArmorService struct {
	db *sql.DB
}

func NewArmorService(db *sql.DB) *ArmorService {
	return &ArmorService{db: db}
}

func (s *ArmorService) GetAll() ([]Armor, error) {
	rows, err := s.db.Query("SELECT id, name, ac, weight, cost, move_cap, created_at FROM armor ORDER BY ac")
	if err != nil {
		return nil, fmt.Errorf("failed to query armor: %w", err)
	}
	defer rows.Close()

	var armors []Armor
	for rows.Next() {
		var a Armor
		if err := rows.Scan(&a.ID, &a.Name, &a.AC, &a.Weight, &a.Cost, &a.MoveCap, &a.CreatedAt); err != nil {
			return nil, fmt.Errorf("failed to scan armor: %w", err)
		}
		armors = append(armors, a)
	}
	return armors, nil
}

func (s *ArmorService) GetByID(id string) (*Armor, error) {
	var a Armor
	err := s.db.QueryRow("SELECT id, name, ac, weight, cost, move_cap, created_at FROM armor WHERE id = ?", id).
		Scan(&a.ID, &a.Name, &a.AC, &a.Weight, &a.Cost, &a.MoveCap, &a.CreatedAt)
	if err != nil {
		return nil, fmt.Errorf("failed to get armor %s: %w", id, err)
	}
	return &a, nil
}

type ShieldService struct {
	db *sql.DB
}

func NewShieldService(db *sql.DB) *ShieldService {
	return &ShieldService{db: db}
}

func (s *ShieldService) GetAll() ([]Shield, error) {
	rows, err := s.db.Query("SELECT id, name, ac_bonus, weight, cost, created_at FROM shields ORDER BY name")
	if err != nil {
		return nil, fmt.Errorf("failed to query shields: %w", err)
	}
	defer rows.Close()

	var shields []Shield
	for rows.Next() {
		var sh Shield
		if err := rows.Scan(&sh.ID, &sh.Name, &sh.ACBonus, &sh.Weight, &sh.Cost, &sh.CreatedAt); err != nil {
			return nil, fmt.Errorf("failed to scan shield: %w", err)
		}
		shields = append(shields, sh)
	}
	return shields, nil
}
