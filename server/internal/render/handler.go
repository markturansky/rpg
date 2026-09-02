package render

import (
	"net/http"

	"rpg/internal/models"
)

func NewTileHandler(renderer *TileRenderer) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		address := r.PathValue("address")
		if !models.ValidAddress(address) {
			http.Error(w, "invalid tile address", http.StatusBadRequest)
			return
		}

		data, err := renderer.RenderTile(address)
		if err != nil {
			http.Error(w, "render failed", http.StatusInternalServerError)
			return
		}

		w.Header().Set("Content-Type", "image/png")
		w.Header().Set("Cache-Control", "public, max-age=86400")
		w.Write(data)
	}
}
