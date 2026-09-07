package api

import (
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"strconv"
	"strings"

	"worldbuilder/internal/database"
)

type tileDefinition struct {
	ID       string `json:"id"`
	Category string `json:"category"`
	Name     string `json:"name"`
}

type placement struct {
	X                int64  `json:"x"`
	Y                int64  `json:"y"`
	TileDefinitionID string `json:"tile_definition_id"`
}

type handler struct {
	db *database.DB
}

func NewHandler(db *database.DB) http.Handler {
	h := handler{db: db}
	mux := http.NewServeMux()
	mux.HandleFunc("GET /health", h.health)
	mux.HandleFunc("GET /api/tile-definitions", h.listTileDefinitions)
	mux.HandleFunc("GET /api/worlds/{world_name}/tiles", h.listTiles)
	mux.HandleFunc("PUT /api/worlds/{world_name}/tiles/{x}/{y}", h.upsertTile)
	mux.HandleFunc("DELETE /api/worlds/{world_name}/tiles/{x}/{y}", h.deleteTile)
	return mux
}

func (h handler) health(w http.ResponseWriter, _ *http.Request) {
	writeJSON(w, http.StatusOK, struct {
		Status string `json:"status"`
	}{Status: "ok"})
}

func (h handler) listTileDefinitions(w http.ResponseWriter, r *http.Request) {
	category := r.URL.Query().Get("category")
	rows, err := h.db.Query(`SELECT id, category, name FROM tile_definitions WHERE (? = '' OR category = ?) ORDER BY category, id`, category, category)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "query tile definitions")
		return
	}
	defer rows.Close()
	definitions := make([]tileDefinition, 0)
	for rows.Next() {
		var definition tileDefinition
		if err := rows.Scan(&definition.ID, &definition.Category, &definition.Name); err != nil {
			writeError(w, http.StatusInternalServerError, "read tile definitions")
			return
		}
		definitions = append(definitions, definition)
	}
	if err := rows.Err(); err != nil {
		writeError(w, http.StatusInternalServerError, "read tile definitions")
		return
	}
	writeJSON(w, http.StatusOK, struct {
		TileDefinitions []tileDefinition `json:"tile_definitions"`
	}{definitions})
}

func (h handler) listTiles(w http.ResponseWriter, r *http.Request) {
	worldName, ok := validWorldName(r.PathValue("world_name"))
	if !ok {
		writeError(w, http.StatusBadRequest, "world_name must not be empty")
		return
	}
	rows, err := h.db.Query(`SELECT x, y, tile_definition_id FROM world_tiles WHERE world_name = ? ORDER BY y, x`, worldName)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "query world tiles")
		return
	}
	defer rows.Close()
	tiles := make([]placement, 0)
	for rows.Next() {
		var tile placement
		if err := rows.Scan(&tile.X, &tile.Y, &tile.TileDefinitionID); err != nil {
			writeError(w, http.StatusInternalServerError, "read world tiles")
			return
		}
		tiles = append(tiles, tile)
	}
	if err := rows.Err(); err != nil {
		writeError(w, http.StatusInternalServerError, "read world tiles")
		return
	}
	writeJSON(w, http.StatusOK, struct {
		WorldName string      `json:"world_name"`
		Tiles     []placement `json:"tiles"`
	}{worldName, tiles})
}

func (h handler) upsertTile(w http.ResponseWriter, r *http.Request) {
	worldName, x, y, ok := parseLocation(r)
	if !ok {
		writeError(w, http.StatusBadRequest, "world_name and coordinates must be valid")
		return
	}
	var input struct {
		TileDefinitionID string `json:"tile_definition_id"`
	}
	decoder := json.NewDecoder(r.Body)
	decoder.DisallowUnknownFields()
	if err := decoder.Decode(&input); err != nil || input.TileDefinitionID == "" {
		writeError(w, http.StatusBadRequest, "tile_definition_id is required")
		return
	}
	_, err := h.db.Exec(`INSERT INTO world_tiles (world_name, x, y, tile_definition_id, updated_at) VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP) ON CONFLICT(world_name, x, y) DO UPDATE SET tile_definition_id = excluded.tile_definition_id, updated_at = CURRENT_TIMESTAMP`, worldName, x, y, input.TileDefinitionID)
	if err != nil {
		if isForeignKeyError(err) {
			writeError(w, http.StatusBadRequest, "unknown tile_definition_id")
			return
		}
		writeError(w, http.StatusInternalServerError, "persist tile placement")
		return
	}
	writeJSON(w, http.StatusOK, placement{X: x, Y: y, TileDefinitionID: input.TileDefinitionID})
}

func (h handler) deleteTile(w http.ResponseWriter, r *http.Request) {
	worldName, x, y, ok := parseLocation(r)
	if !ok {
		writeError(w, http.StatusBadRequest, "world_name and coordinates must be valid")
		return
	}
	if _, err := h.db.Exec(`DELETE FROM world_tiles WHERE world_name = ? AND x = ? AND y = ?`, worldName, x, y); err != nil {
		writeError(w, http.StatusInternalServerError, "delete tile placement")
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func parseLocation(r *http.Request) (string, int64, int64, bool) {
	worldName, ok := validWorldName(r.PathValue("world_name"))
	if !ok {
		return "", 0, 0, false
	}
	x, err := strconv.ParseInt(r.PathValue("x"), 10, 64)
	if err != nil {
		return "", 0, 0, false
	}
	y, err := strconv.ParseInt(r.PathValue("y"), 10, 64)
	if err != nil {
		return "", 0, 0, false
	}
	return worldName, x, y, true
}

func validWorldName(name string) (string, bool) {
	name = strings.TrimSpace(name)
	return name, name != ""
}

func isForeignKeyError(err error) bool {
	return errors.Is(err, sql.ErrNoRows) || strings.Contains(strings.ToLower(fmt.Sprint(err)), "foreign key")
}

func writeJSON(w http.ResponseWriter, status int, value any) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(value)
}

func writeError(w http.ResponseWriter, status int, message string) {
	writeJSON(w, status, struct {
		Error string `json:"error"`
	}{message})
}
