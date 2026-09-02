package models

import (
	"database/sql"
	"fmt"
	"time"
)

type QuestTemplate struct {
	ID          int       `json:"id"`
	Type        string    `json:"type"`
	Difficulty  string    `json:"difficulty"`
	Description *string   `json:"description,omitempty"`
	GoldMin     int       `json:"gold_min"`
	GoldMax     int       `json:"gold_max"`
	XPReward    int       `json:"xp_reward"`
	ItemReward  *string   `json:"item_reward,omitempty"`
	CreatedAt   time.Time `json:"created_at"`
}

type CharacterQuest struct {
	ID              int       `json:"id"`
	CharacterID     int       `json:"character_id"`
	QuestTemplateID int       `json:"quest_template_id"`
	Status          string    `json:"status"`
	TargetTerrain   *string   `json:"target_terrain,omitempty"`
	TargetCount     int       `json:"target_count"`
	CurrentCount    int       `json:"current_count"`
	RewardGold      int       `json:"reward_gold"`
	RewardXP        int       `json:"reward_xp"`
	CreatedAt       time.Time `json:"created_at"`
	UpdatedAt       time.Time `json:"updated_at"`
}

type QuestService struct {
	db *sql.DB
}

func NewQuestService(db *sql.DB) *QuestService {
	return &QuestService{db: db}
}

func (s *QuestService) GetTemplates() ([]QuestTemplate, error) {
	rows, err := s.db.Query("SELECT id, type, difficulty, description, gold_min, gold_max, xp_reward, item_reward, created_at FROM quest_templates ORDER BY difficulty, type")
	if err != nil {
		return nil, fmt.Errorf("failed to query quest templates: %w", err)
	}
	defer rows.Close()

	var templates []QuestTemplate
	for rows.Next() {
		var t QuestTemplate
		if err := rows.Scan(&t.ID, &t.Type, &t.Difficulty, &t.Description, &t.GoldMin, &t.GoldMax, &t.XPReward, &t.ItemReward, &t.CreatedAt); err != nil {
			return nil, fmt.Errorf("failed to scan quest template: %w", err)
		}
		templates = append(templates, t)
	}
	return templates, nil
}

func (s *QuestService) GetCharacterQuests(characterID int) ([]CharacterQuest, error) {
	rows, err := s.db.Query(`
		SELECT id, character_id, quest_template_id, status, target_terrain, target_count,
		       current_count, reward_gold, reward_xp, created_at, updated_at
		FROM character_quests WHERE character_id = ? ORDER BY created_at DESC
	`, characterID)
	if err != nil {
		return nil, fmt.Errorf("failed to query quests for character %d: %w", characterID, err)
	}
	defer rows.Close()

	var quests []CharacterQuest
	for rows.Next() {
		var q CharacterQuest
		if err := rows.Scan(&q.ID, &q.CharacterID, &q.QuestTemplateID, &q.Status,
			&q.TargetTerrain, &q.TargetCount, &q.CurrentCount, &q.RewardGold,
			&q.RewardXP, &q.CreatedAt, &q.UpdatedAt); err != nil {
			return nil, fmt.Errorf("failed to scan character quest: %w", err)
		}
		quests = append(quests, q)
	}
	return quests, nil
}

func (s *QuestService) AcceptQuest(characterID, templateID, rewardGold, rewardXP int, targetTerrain *string, targetCount int) (*CharacterQuest, error) {
	var q CharacterQuest
	err := s.db.QueryRow(`
		INSERT INTO character_quests (character_id, quest_template_id, status, target_terrain, target_count, current_count, reward_gold, reward_xp)
		VALUES (?, ?, 'active', ?, ?, 0, ?, ?)
		RETURNING id, character_id, quest_template_id, status, target_terrain, target_count, current_count, reward_gold, reward_xp, created_at, updated_at
	`, characterID, templateID, targetTerrain, targetCount, rewardGold, rewardXP).
		Scan(&q.ID, &q.CharacterID, &q.QuestTemplateID, &q.Status,
			&q.TargetTerrain, &q.TargetCount, &q.CurrentCount,
			&q.RewardGold, &q.RewardXP, &q.CreatedAt, &q.UpdatedAt)
	if err != nil {
		return nil, fmt.Errorf("failed to accept quest: %w", err)
	}
	return &q, nil
}

func (s *QuestService) UpdateQuestProgress(questID, currentCount int, status string) error {
	_, err := s.db.Exec(`
		UPDATE character_quests SET current_count = ?, status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?
	`, currentCount, status, questID)
	if err != nil {
		return fmt.Errorf("failed to update quest %d: %w", questID, err)
	}
	return nil
}
