package models

import (
	"database/sql"
	"fmt"
	"time"
)

type Ancestry struct {
	ID             string    `json:"id"`
	Name           string    `json:"name"`
	StrAdj         int       `json:"str_adj"`
	DexAdj         int       `json:"dex_adj"`
	ConAdj         int       `json:"con_adj"`
	IntAdj         int       `json:"int_adj"`
	WisAdj         int       `json:"wis_adj"`
	ChaAdj         int       `json:"cha_adj"`
	MovementRate   int       `json:"movement_rate"`
	Infravision    int       `json:"infravision"`
	CreatedAt      time.Time `json:"created_at"`
	Abilities      []string  `json:"abilities"`
	AllowedClasses []AncestryClassEntry `json:"allowed_classes"`
}

type AncestryClassEntry struct {
	ClassID    string `json:"class_id"`
	LevelLimit *int   `json:"level_limit,omitempty"`
}

type AncestryService struct {
	db *sql.DB
}

func NewAncestryService(db *sql.DB) *AncestryService {
	return &AncestryService{db: db}
}

func (s *AncestryService) GetAll() ([]Ancestry, error) {
	rows, err := s.db.Query(`
		SELECT id, name, str_adj, dex_adj, con_adj, int_adj, wis_adj, cha_adj,
		       movement_rate, infravision, created_at
		FROM ancestries ORDER BY name
	`)
	if err != nil {
		return nil, fmt.Errorf("failed to query ancestries: %w", err)
	}
	defer rows.Close()

	var ancestries []Ancestry
	for rows.Next() {
		var a Ancestry
		if err := rows.Scan(&a.ID, &a.Name, &a.StrAdj, &a.DexAdj, &a.ConAdj,
			&a.IntAdj, &a.WisAdj, &a.ChaAdj, &a.MovementRate,
			&a.Infravision, &a.CreatedAt); err != nil {
			return nil, fmt.Errorf("failed to scan ancestry: %w", err)
		}
		if err := s.populateAbilities(&a); err != nil {
			return nil, err
		}
		if err := s.populateAllowedClasses(&a); err != nil {
			return nil, err
		}
		ancestries = append(ancestries, a)
	}
	return ancestries, nil
}

func (s *AncestryService) GetByID(id string) (*Ancestry, error) {
	var a Ancestry
	err := s.db.QueryRow(`
		SELECT id, name, str_adj, dex_adj, con_adj, int_adj, wis_adj, cha_adj,
		       movement_rate, infravision, created_at
		FROM ancestries WHERE id = ?
	`, id).Scan(&a.ID, &a.Name, &a.StrAdj, &a.DexAdj, &a.ConAdj,
		&a.IntAdj, &a.WisAdj, &a.ChaAdj, &a.MovementRate,
		&a.Infravision, &a.CreatedAt)
	if err != nil {
		return nil, fmt.Errorf("failed to get ancestry %s: %w", id, err)
	}
	if err := s.populateAbilities(&a); err != nil {
		return nil, err
	}
	if err := s.populateAllowedClasses(&a); err != nil {
		return nil, err
	}
	return &a, nil
}

func (s *AncestryService) populateAbilities(a *Ancestry) error {
	rows, err := s.db.Query(
		"SELECT ability FROM ancestry_abilities WHERE ancestry_id = ?", a.ID,
	)
	if err != nil {
		return fmt.Errorf("failed to query abilities for %s: %w", a.ID, err)
	}
	defer rows.Close()
	for rows.Next() {
		var ab string
		if err := rows.Scan(&ab); err != nil {
			return err
		}
		a.Abilities = append(a.Abilities, ab)
	}
	return nil
}

func (s *AncestryService) populateAllowedClasses(a *Ancestry) error {
	rows, err := s.db.Query(
		"SELECT class_id, level_limit FROM ancestry_classes WHERE ancestry_id = ? ORDER BY class_id", a.ID,
	)
	if err != nil {
		return fmt.Errorf("failed to query allowed classes for %s: %w", a.ID, err)
	}
	defer rows.Close()
	for rows.Next() {
		var entry AncestryClassEntry
		if err := rows.Scan(&entry.ClassID, &entry.LevelLimit); err != nil {
			return err
		}
		a.AllowedClasses = append(a.AllowedClasses, entry)
	}
	return nil
}
