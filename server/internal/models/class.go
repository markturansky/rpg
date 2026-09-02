package models

import (
	"database/sql"
	"fmt"
	"time"
)

type Class struct {
	ID              string           `json:"id"`
	Name            string           `json:"name"`
	HitDie          int              `json:"hit_die"`
	Prime           string           `json:"prime"`
	ArmorAllowed    string           `json:"armor_allowed"`
	ShieldAllowed   bool             `json:"shield_allowed"`
	WeaponsAllowed  string           `json:"weapons_allowed"`
	GoldDice        int              `json:"gold_dice"`
	GoldDie         int              `json:"gold_die"`
	GoldMultiplier  int              `json:"gold_multiplier"`
	CreatedAt       time.Time        `json:"created_at"`
	MinScores       map[string]int   `json:"min_scores"`
	SavingThrows    []SavingThrowRow `json:"saving_throws"`
	BTHBProgression []BTHBRow        `json:"bthb_progression"`
	XPTable         []XPRow          `json:"xp_table"`
	SpellSlots      []SpellSlotRow   `json:"spell_slots,omitempty"`
}

type SavingThrowRow struct {
	MinLevel int `json:"min_level"`
	MaxLevel int `json:"max_level"`
	Aimed    int `json:"aimed"`
	Breath   int `json:"breath"`
	Death    int `json:"death"`
	Petrify  int `json:"petrify"`
	Spells   int `json:"spells"`
}

type BTHBRow struct {
	Level int `json:"level"`
	Bonus int `json:"bonus"`
}

type XPRow struct {
	Level      int    `json:"level"`
	XPRequired int    `json:"xp_required"`
	Title      string `json:"title"`
}

type SpellSlotRow struct {
	CasterLevel int `json:"caster_level"`
	SpellLevel  int `json:"spell_level"`
	Slots       int `json:"slots"`
}

type ClassService struct {
	db *sql.DB
}

func NewClassService(db *sql.DB) *ClassService {
	return &ClassService{db: db}
}

func (s *ClassService) GetAll() ([]Class, error) {
	rows, err := s.db.Query(`
		SELECT id, name, hit_die, prime, armor_allowed, shield_allowed,
		       weapons_allowed, gold_dice, gold_die, gold_multiplier, created_at
		FROM classes ORDER BY name
	`)
	if err != nil {
		return nil, fmt.Errorf("failed to query classes: %w", err)
	}
	defer rows.Close()

	var classes []Class
	for rows.Next() {
		var c Class
		if err := rows.Scan(&c.ID, &c.Name, &c.HitDie, &c.Prime, &c.ArmorAllowed,
			&c.ShieldAllowed, &c.WeaponsAllowed, &c.GoldDice, &c.GoldDie,
			&c.GoldMultiplier, &c.CreatedAt); err != nil {
			return nil, fmt.Errorf("failed to scan class: %w", err)
		}
		if err := s.populateClassDetails(&c); err != nil {
			return nil, err
		}
		classes = append(classes, c)
	}
	return classes, nil
}

func (s *ClassService) GetByID(id string) (*Class, error) {
	var c Class
	err := s.db.QueryRow(`
		SELECT id, name, hit_die, prime, armor_allowed, shield_allowed,
		       weapons_allowed, gold_dice, gold_die, gold_multiplier, created_at
		FROM classes WHERE id = ?
	`, id).Scan(&c.ID, &c.Name, &c.HitDie, &c.Prime, &c.ArmorAllowed,
		&c.ShieldAllowed, &c.WeaponsAllowed, &c.GoldDice, &c.GoldDie,
		&c.GoldMultiplier, &c.CreatedAt)
	if err != nil {
		return nil, fmt.Errorf("failed to get class %s: %w", id, err)
	}
	if err := s.populateClassDetails(&c); err != nil {
		return nil, err
	}
	return &c, nil
}

func (s *ClassService) MeetsMinimumScores(classID string, scores map[string]int) (bool, error) {
	rows, err := s.db.Query(
		"SELECT ability, minimum FROM class_min_scores WHERE class_id = ?", classID,
	)
	if err != nil {
		return false, fmt.Errorf("failed to check min scores: %w", err)
	}
	defer rows.Close()
	for rows.Next() {
		var ability string
		var min int
		if err := rows.Scan(&ability, &min); err != nil {
			return false, err
		}
		if scores[ability] < min {
			return false, nil
		}
	}
	return true, nil
}

func (s *ClassService) populateClassDetails(c *Class) error {
	c.MinScores = make(map[string]int)
	rows, err := s.db.Query(
		"SELECT ability, minimum FROM class_min_scores WHERE class_id = ?", c.ID,
	)
	if err != nil {
		return fmt.Errorf("failed to query min scores for %s: %w", c.ID, err)
	}
	defer rows.Close()
	for rows.Next() {
		var ability string
		var min int
		if err := rows.Scan(&ability, &min); err != nil {
			return err
		}
		c.MinScores[ability] = min
	}

	savRows, err := s.db.Query(
		"SELECT min_level, max_level, aimed, breath, death, petrify, spells FROM saving_throws WHERE class_id = ? ORDER BY min_level", c.ID,
	)
	if err != nil {
		return fmt.Errorf("failed to query saving throws for %s: %w", c.ID, err)
	}
	defer savRows.Close()
	for savRows.Next() {
		var r SavingThrowRow
		if err := savRows.Scan(&r.MinLevel, &r.MaxLevel, &r.Aimed, &r.Breath, &r.Death, &r.Petrify, &r.Spells); err != nil {
			return err
		}
		c.SavingThrows = append(c.SavingThrows, r)
	}

	bthbRows, err := s.db.Query(
		"SELECT level, bonus FROM bthb_progression WHERE class_id = ? ORDER BY level", c.ID,
	)
	if err != nil {
		return fmt.Errorf("failed to query bthb for %s: %w", c.ID, err)
	}
	defer bthbRows.Close()
	for bthbRows.Next() {
		var r BTHBRow
		if err := bthbRows.Scan(&r.Level, &r.Bonus); err != nil {
			return err
		}
		c.BTHBProgression = append(c.BTHBProgression, r)
	}

	xpRows, err := s.db.Query(
		"SELECT level, xp_required, title FROM xp_table WHERE class_id = ? ORDER BY level", c.ID,
	)
	if err != nil {
		return fmt.Errorf("failed to query xp table for %s: %w", c.ID, err)
	}
	defer xpRows.Close()
	for xpRows.Next() {
		var r XPRow
		if err := xpRows.Scan(&r.Level, &r.XPRequired, &r.Title); err != nil {
			return err
		}
		c.XPTable = append(c.XPTable, r)
	}

	slotRows, err := s.db.Query(
		"SELECT caster_level, spell_level, slots FROM spell_slots WHERE class_id = ? ORDER BY caster_level, spell_level", c.ID,
	)
	if err != nil {
		return fmt.Errorf("failed to query spell slots for %s: %w", c.ID, err)
	}
	defer slotRows.Close()
	for slotRows.Next() {
		var r SpellSlotRow
		if err := slotRows.Scan(&r.CasterLevel, &r.SpellLevel, &r.Slots); err != nil {
			return err
		}
		c.SpellSlots = append(c.SpellSlots, r)
	}

	return nil
}
