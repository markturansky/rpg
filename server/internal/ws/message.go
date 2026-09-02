package ws

import "encoding/json"

type Envelope struct {
	Type    string          `json:"type"`
	Payload json.RawMessage `json:"payload"`
}

type ErrorPayload struct {
	Error string `json:"error"`
}

type CreateCharacterPayload struct {
	Name       string `json:"name"`
	AncestryID string `json:"ancestry_id"`
	ClassID    string `json:"class_id"`
	Str        int    `json:"str"`
	Dex        int    `json:"dex"`
	Con        int    `json:"con"`
	Int        int    `json:"int_"`
	Wis        int    `json:"wis"`
	Cha        int    `json:"cha"`
	ExceptStr  *int   `json:"exceptional_str,omitempty"`
	WorldSeed  int    `json:"world_seed"`
}

type MovePayload struct {
	CharacterID int    `json:"character_id"`
	Direction   string `json:"direction"`
}

type MoveResultPayload struct {
	Success     bool                    `json:"success"`
	NewTile     string                  `json:"new_tile"`
	TerrainID   string                  `json:"terrain_id"`
	TerrainName string                  `json:"terrain_name"`
	TierName    string                  `json:"tier_name"`
	Depth       int                     `json:"depth"`
	GameDay     int                     `json:"game_day"`
	GameHour    float64                 `json:"game_hour"`
	GotLost     bool                    `json:"got_lost"`
	NeedsRest   bool                    `json:"needs_rest"`
	Encounter   *EncounterResultPayload `json:"encounter,omitempty"`
}

type EncounterResultPayload struct {
	MonsterID   string `json:"monster_id"`
	MonsterName string `json:"monster_name"`
	Count       int    `json:"count"`
	XP          int    `json:"xp"`
	Notes       string `json:"notes,omitempty"`
}

type ZoomPayload struct {
	CharacterID int `json:"character_id"`
	ChildIndex  int `json:"child_index,omitempty"`
}

type ZoomResultPayload struct {
	Success    bool        `json:"success"`
	NewAddress string      `json:"new_address"`
	TierName   string      `json:"tier_name"`
	Depth      int         `json:"depth"`
	TerrainID  string      `json:"terrain_id"`
	Siblings   []TileBrief `json:"siblings,omitempty"`
}

type TileBrief struct {
	Address   string `json:"address"`
	TerrainID string `json:"terrain_id"`
}

type GetCharacterPayload struct {
	CharacterID int `json:"character_id"`
}

type QueryPayload struct {
	ID string `json:"id,omitempty"`
}

func NewEnvelope(msgType string, payload interface{}) ([]byte, error) {
	p, err := json.Marshal(payload)
	if err != nil {
		return nil, err
	}
	env := Envelope{
		Type:    msgType,
		Payload: p,
	}
	return json.Marshal(env)
}

func NewErrorEnvelope(msgType string, errMsg string) ([]byte, error) {
	return NewEnvelope(msgType+"_error", ErrorPayload{Error: errMsg})
}
