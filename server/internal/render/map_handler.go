package render

import (
	"encoding/json"
	"net/http"

	"rpg/internal/models"
)

func NewMapHandler() http.HandlerFunc {
	gridData := models.GenerateWorldGrid()
	cached, _ := json.Marshal(gridData)

	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.Header().Set("Cache-Control", "public, max-age=86400")
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Write(cached)
	}
}
