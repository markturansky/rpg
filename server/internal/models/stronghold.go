package models

import (
	"database/sql"
	"fmt"
	"time"
)

type StrongholdStructure struct {
	ID               string    `json:"id"`
	Name             string    `json:"name"`
	Cost             int       `json:"cost"`
	BuildWeeks       int       `json:"build_weeks"`
	GarrisonCapacity int       `json:"garrison_capacity"`
	Notes            *string   `json:"notes,omitempty"`
	CreatedAt        time.Time `json:"created_at"`
}

type StrongholdUpgrade struct {
	ID            string    `json:"id"`
	Name          string    `json:"name"`
	Cost          int       `json:"cost"`
	Prerequisite  *string   `json:"prerequisite,omitempty"`
	PopRequired   int       `json:"pop_required"`
	Benefit       *string   `json:"benefit,omitempty"`
	CreatedAt     time.Time `json:"created_at"`
}

type CharacterStronghold struct {
	ID            int       `json:"id"`
	CharacterID   int       `json:"character_id"`
	HexAddress    string    `json:"hex_address"`
	Population    int       `json:"population"`
	MonthlyIncome int       `json:"monthly_income"`
	GarrisonCount int       `json:"garrison_count"`
	CreatedAt     time.Time `json:"created_at"`
	UpdatedAt     time.Time `json:"updated_at"`
}

type DomainEvent struct {
	ID        int       `json:"id"`
	RollValue int       `json:"roll_value"`
	Name      string    `json:"name"`
	Effect    string    `json:"effect"`
	CreatedAt time.Time `json:"created_at"`
}

type StrongholdService struct {
	db *sql.DB
}

func NewStrongholdService(db *sql.DB) *StrongholdService {
	return &StrongholdService{db: db}
}

func (s *StrongholdService) GetStructures() ([]StrongholdStructure, error) {
	rows, err := s.db.Query("SELECT id, name, cost, build_weeks, garrison_capacity, notes, created_at FROM stronghold_structures ORDER BY cost")
	if err != nil {
		return nil, fmt.Errorf("failed to query structures: %w", err)
	}
	defer rows.Close()

	var structures []StrongholdStructure
	for rows.Next() {
		var st StrongholdStructure
		if err := rows.Scan(&st.ID, &st.Name, &st.Cost, &st.BuildWeeks, &st.GarrisonCapacity, &st.Notes, &st.CreatedAt); err != nil {
			return nil, fmt.Errorf("failed to scan structure: %w", err)
		}
		structures = append(structures, st)
	}
	return structures, nil
}

func (s *StrongholdService) GetUpgrades() ([]StrongholdUpgrade, error) {
	rows, err := s.db.Query("SELECT id, name, cost, prerequisite, pop_required, benefit, created_at FROM stronghold_upgrades ORDER BY cost")
	if err != nil {
		return nil, fmt.Errorf("failed to query upgrades: %w", err)
	}
	defer rows.Close()

	var upgrades []StrongholdUpgrade
	for rows.Next() {
		var u StrongholdUpgrade
		if err := rows.Scan(&u.ID, &u.Name, &u.Cost, &u.Prerequisite, &u.PopRequired, &u.Benefit, &u.CreatedAt); err != nil {
			return nil, fmt.Errorf("failed to scan upgrade: %w", err)
		}
		upgrades = append(upgrades, u)
	}
	return upgrades, nil
}

func (s *StrongholdService) GetCharacterStronghold(characterID int) (*CharacterStronghold, error) {
	var cs CharacterStronghold
	err := s.db.QueryRow(`
		SELECT id, character_id, hex_address, population, monthly_income, garrison_count, created_at, updated_at
		FROM character_stronghold WHERE character_id = ?
	`, characterID).Scan(&cs.ID, &cs.CharacterID, &cs.HexAddress,
		&cs.Population, &cs.MonthlyIncome, &cs.GarrisonCount, &cs.CreatedAt, &cs.UpdatedAt)
	if err != nil {
		return nil, fmt.Errorf("failed to get stronghold for character %d: %w", characterID, err)
	}
	return &cs, nil
}

func (s *StrongholdService) GetDomainEvents() ([]DomainEvent, error) {
	rows, err := s.db.Query("SELECT id, roll_value, name, effect, created_at FROM domain_events ORDER BY roll_value")
	if err != nil {
		return nil, fmt.Errorf("failed to query domain events: %w", err)
	}
	defer rows.Close()

	var events []DomainEvent
	for rows.Next() {
		var e DomainEvent
		if err := rows.Scan(&e.ID, &e.RollValue, &e.Name, &e.Effect, &e.CreatedAt); err != nil {
			return nil, fmt.Errorf("failed to scan domain event: %w", err)
		}
		events = append(events, e)
	}
	return events, nil
}
