package models

import (
	"database/sql"
	"fmt"
)

type AbilityMod struct {
	Ability      string `json:"ability"`
	ScoreMin     int    `json:"score_min"`
	ScoreMax     int    `json:"score_max"`
	ToHit        int    `json:"to_hit"`
	Damage       int    `json:"damage"`
	ACMod        int    `json:"ac_mod"`
	HPMod        int    `json:"hp_mod"`
	HPModFighter int    `json:"hp_mod_fighter"`
	Encumbrance  int    `json:"encumbrance"`
	Surprise     int    `json:"surprise"`
	MaxHenchmen  int    `json:"max_henchmen"`
	LoyaltyPct   int    `json:"loyalty_pct"`
	ReactionPct  int    `json:"reaction_pct"`
}

type AbilityModService struct {
	db *sql.DB
}

func NewAbilityModService(db *sql.DB) *AbilityModService {
	return &AbilityModService{db: db}
}

func (s *AbilityModService) GetModsForScore(ability string, score int) (*AbilityMod, error) {
	var m AbilityMod
	err := s.db.QueryRow(`
		SELECT ability, score_min, score_max, to_hit, damage, ac_mod,
		       hp_mod, hp_mod_fighter, encumbrance, surprise,
		       max_henchmen, loyalty_pct, reaction_pct
		FROM ability_mods
		WHERE ability = ? AND ? BETWEEN score_min AND score_max
	`, ability, score).Scan(&m.Ability, &m.ScoreMin, &m.ScoreMax, &m.ToHit,
		&m.Damage, &m.ACMod, &m.HPMod, &m.HPModFighter, &m.Encumbrance,
		&m.Surprise, &m.MaxHenchmen, &m.LoyaltyPct, &m.ReactionPct)
	if err != nil {
		return nil, fmt.Errorf("failed to get %s mod for score %d: %w", ability, score, err)
	}
	return &m, nil
}

func (s *AbilityModService) GetAllForAbility(ability string) ([]AbilityMod, error) {
	rows, err := s.db.Query(`
		SELECT ability, score_min, score_max, to_hit, damage, ac_mod,
		       hp_mod, hp_mod_fighter, encumbrance, surprise,
		       max_henchmen, loyalty_pct, reaction_pct
		FROM ability_mods WHERE ability = ? ORDER BY score_min
	`, ability)
	if err != nil {
		return nil, fmt.Errorf("failed to query %s mods: %w", ability, err)
	}
	defer rows.Close()

	var mods []AbilityMod
	for rows.Next() {
		var m AbilityMod
		if err := rows.Scan(&m.Ability, &m.ScoreMin, &m.ScoreMax, &m.ToHit,
			&m.Damage, &m.ACMod, &m.HPMod, &m.HPModFighter, &m.Encumbrance,
			&m.Surprise, &m.MaxHenchmen, &m.LoyaltyPct, &m.ReactionPct); err != nil {
			return nil, fmt.Errorf("failed to scan ability mod: %w", err)
		}
		mods = append(mods, m)
	}
	return mods, nil
}
