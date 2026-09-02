package models

import (
	"database/sql"
	"fmt"
	"time"
)

type Character struct {
	ID              int       `json:"id"`
	Name            string    `json:"name"`
	AncestryID      string    `json:"ancestry_id"`
	ClassID         string    `json:"class_id"`
	Level           int       `json:"level"`
	XP              int       `json:"xp"`
	HP              int       `json:"hp"`
	MaxHP           int       `json:"max_hp"`
	AC              int       `json:"ac"`
	Gold            int       `json:"gold"`
	Str             int       `json:"str"`
	Dex             int       `json:"dex"`
	Con             int       `json:"con"`
	Int             int       `json:"int_"`
	Wis             int       `json:"wis"`
	Cha             int       `json:"cha"`
	ExceptionalStr  *int      `json:"exceptional_str,omitempty"`
	MovementRate    int       `json:"movement_rate"`
	CurrentTile     string    `json:"current_tile"`
	GameDay         int       `json:"game_day"`
	GameHour        float64   `json:"game_hour"`
	TravelHoursDay  float64   `json:"travel_hours_today"`
	Rations         int       `json:"rations"`
	WorldSeed       int       `json:"world_seed"`
	CreatedAt       time.Time `json:"created_at"`
	UpdatedAt       time.Time `json:"updated_at"`
}

type CharacterService struct {
	db *sql.DB
}

func NewCharacterService(db *sql.DB) *CharacterService {
	return &CharacterService{db: db}
}

func (s *CharacterService) Create(c *Character) (*Character, error) {
	err := s.db.QueryRow(`
		INSERT INTO characters (
			name, ancestry_id, class_id, level, xp, hp, max_hp, ac, gold,
			str, dex, con, int_, wis, cha, exceptional_str, movement_rate,
			current_tile, game_day, game_hour,
			travel_hours_today, rations, world_seed
		) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
		RETURNING id, created_at, updated_at
	`, c.Name, c.AncestryID, c.ClassID, c.Level, c.XP, c.HP, c.MaxHP, c.AC,
		c.Gold, c.Str, c.Dex, c.Con, c.Int, c.Wis, c.Cha, c.ExceptionalStr,
		c.MovementRate, c.CurrentTile, c.GameDay,
		c.GameHour, c.TravelHoursDay, c.Rations, c.WorldSeed,
	).Scan(&c.ID, &c.CreatedAt, &c.UpdatedAt)
	if err != nil {
		return nil, fmt.Errorf("failed to create character: %w", err)
	}
	return c, nil
}

func (s *CharacterService) GetByID(id int) (*Character, error) {
	var c Character
	err := s.db.QueryRow(`
		SELECT id, name, ancestry_id, class_id, level, xp, hp, max_hp, ac, gold,
		       str, dex, con, int_, wis, cha, exceptional_str, movement_rate,
		       current_tile, game_day, game_hour,
		       travel_hours_today, rations, world_seed, created_at, updated_at
		FROM characters WHERE id = ?
	`, id).Scan(&c.ID, &c.Name, &c.AncestryID, &c.ClassID, &c.Level, &c.XP,
		&c.HP, &c.MaxHP, &c.AC, &c.Gold, &c.Str, &c.Dex, &c.Con, &c.Int,
		&c.Wis, &c.Cha, &c.ExceptionalStr, &c.MovementRate, &c.CurrentTile,
		&c.GameDay, &c.GameHour,
		&c.TravelHoursDay, &c.Rations, &c.WorldSeed, &c.CreatedAt, &c.UpdatedAt)
	if err != nil {
		return nil, fmt.Errorf("failed to get character %d: %w", id, err)
	}
	return &c, nil
}

func (s *CharacterService) Update(c *Character) error {
	result, err := s.db.Exec(`
		UPDATE characters SET
			hp = ?, max_hp = ?, ac = ?, gold = ?, level = ?, xp = ?,
			movement_rate = ?, current_tile = ?,
			game_day = ?, game_hour = ?, travel_hours_today = ?, rations = ?,
			updated_at = CURRENT_TIMESTAMP
		WHERE id = ?
	`, c.HP, c.MaxHP, c.AC, c.Gold, c.Level, c.XP, c.MovementRate,
		c.CurrentTile, c.GameDay, c.GameHour,
		c.TravelHoursDay, c.Rations, c.ID)
	if err != nil {
		return fmt.Errorf("failed to update character %d: %w", c.ID, err)
	}
	rowsAffected, _ := result.RowsAffected()
	if rowsAffected == 0 {
		return fmt.Errorf("character %d not found", c.ID)
	}
	return nil
}

func (s *CharacterService) Delete(id int) error {
	result, err := s.db.Exec("DELETE FROM characters WHERE id = ?", id)
	if err != nil {
		return fmt.Errorf("failed to delete character %d: %w", id, err)
	}
	rowsAffected, _ := result.RowsAffected()
	if rowsAffected == 0 {
		return fmt.Errorf("character %d not found", id)
	}
	return nil
}
