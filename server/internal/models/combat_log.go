package models

import (
	"database/sql"
	"fmt"
	"time"
)

type CombatLog struct {
	ID          int       `json:"id"`
	CharacterID int       `json:"character_id"`
	MonsterID   *string   `json:"monster_id,omitempty"`
	Outcome     string    `json:"outcome"`
	XPEarned    int       `json:"xp_earned"`
	GoldEarned  int       `json:"gold_earned"`
	GameDay     int       `json:"game_day"`
	CreatedAt   time.Time `json:"created_at"`
}

type CombatLogService struct {
	db *sql.DB
}

func NewCombatLogService(db *sql.DB) *CombatLogService {
	return &CombatLogService{db: db}
}

func (s *CombatLogService) Create(characterID int, monsterID *string, outcome string, xpEarned, goldEarned, gameDay int) (*CombatLog, error) {
	var cl CombatLog
	err := s.db.QueryRow(`
		INSERT INTO combat_log (character_id, monster_id, outcome, xp_earned, gold_earned, game_day)
		VALUES (?, ?, ?, ?, ?, ?)
		RETURNING id, character_id, monster_id, outcome, xp_earned, gold_earned, game_day, created_at
	`, characterID, monsterID, outcome, xpEarned, goldEarned, gameDay).
		Scan(&cl.ID, &cl.CharacterID, &cl.MonsterID, &cl.Outcome,
			&cl.XPEarned, &cl.GoldEarned, &cl.GameDay, &cl.CreatedAt)
	if err != nil {
		return nil, fmt.Errorf("failed to create combat log: %w", err)
	}
	return &cl, nil
}

func (s *CombatLogService) GetByCharacter(characterID int) ([]CombatLog, error) {
	rows, err := s.db.Query(`
		SELECT id, character_id, monster_id, outcome, xp_earned, gold_earned, game_day, created_at
		FROM combat_log WHERE character_id = ? ORDER BY created_at DESC
	`, characterID)
	if err != nil {
		return nil, fmt.Errorf("failed to query combat log for character %d: %w", characterID, err)
	}
	defer rows.Close()

	var logs []CombatLog
	for rows.Next() {
		var cl CombatLog
		if err := rows.Scan(&cl.ID, &cl.CharacterID, &cl.MonsterID, &cl.Outcome,
			&cl.XPEarned, &cl.GoldEarned, &cl.GameDay, &cl.CreatedAt); err != nil {
			return nil, fmt.Errorf("failed to scan combat log: %w", err)
		}
		logs = append(logs, cl)
	}
	return logs, nil
}
