package models

import (
	"database/sql"
	"fmt"
	"time"
)

type Item struct {
	ID        string    `json:"id"`
	Name      string    `json:"name"`
	Effect    *string   `json:"effect,omitempty"`
	Cost      float64   `json:"cost"`
	Weight    float64   `json:"weight"`
	CreatedAt time.Time `json:"created_at"`
}

type StartingEquipmentEntry struct {
	ClassID  string `json:"class_id"`
	ItemType string `json:"item_type"`
	ItemID   string `json:"item_id"`
	Quantity int    `json:"quantity"`
}

type ItemService struct {
	db *sql.DB
}

func NewItemService(db *sql.DB) *ItemService {
	return &ItemService{db: db}
}

func (s *ItemService) GetAll() ([]Item, error) {
	rows, err := s.db.Query("SELECT id, name, effect, cost, weight, created_at FROM items ORDER BY name")
	if err != nil {
		return nil, fmt.Errorf("failed to query items: %w", err)
	}
	defer rows.Close()

	var items []Item
	for rows.Next() {
		var i Item
		if err := rows.Scan(&i.ID, &i.Name, &i.Effect, &i.Cost, &i.Weight, &i.CreatedAt); err != nil {
			return nil, fmt.Errorf("failed to scan item: %w", err)
		}
		items = append(items, i)
	}
	return items, nil
}

func (s *ItemService) GetStartingEquipment(classID string) ([]StartingEquipmentEntry, error) {
	rows, err := s.db.Query(
		"SELECT class_id, item_type, item_id, quantity FROM starting_equipment WHERE class_id = ?", classID,
	)
	if err != nil {
		return nil, fmt.Errorf("failed to query starting equipment for %s: %w", classID, err)
	}
	defer rows.Close()

	var entries []StartingEquipmentEntry
	for rows.Next() {
		var e StartingEquipmentEntry
		if err := rows.Scan(&e.ClassID, &e.ItemType, &e.ItemID, &e.Quantity); err != nil {
			return nil, fmt.Errorf("failed to scan starting equipment: %w", err)
		}
		entries = append(entries, e)
	}
	return entries, nil
}
