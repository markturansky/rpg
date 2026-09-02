# Hex World RPG - Project Conventions

## Commands

### Test (run all tests)
- `./test.sh` — Build server, run all Go + GDScript tests

### Client (Godot)
- Godot binary: `/home/mturansk/Downloads/Godot_v4.6.3-stable_linux.x86_64`

### Server (Go)
- `go run ./cmd/rpg-server/` — Start WebSocket server (from `server/` directory)
- `go run ./cmd/rpg-server/ -addr :8080 -db rpg.db` — With explicit flags
- `go build -o rpg-server ./cmd/rpg-server/` — Build binary
- `go test ./...` — Run Go tests

## Architecture

### Client
- **Framework:** Godot 4.x with GDScript
- **File size target:** 300-500 lines per file max. If a file exceeds 500 lines, split it.
- **No comments in code** unless explicitly requested.

### Server
- **Language:** Go 1.24, standard library HTTP + nhooyr.io/websocket
- **Database:** SQLite via github.com/mattn/go-sqlite3, WAL mode, embedded schema via `//go:embed`
- **Protocol:** WebSocket with JSON envelope messages (`{"type": "...", "payload": {...}}`)
- **Pattern:** Service layer — each model has an `XxxService` struct holding `*sql.DB`, raw SQL, no ORM
- **Keys:** Natural TEXT keys for reference data (ancestry, class, weapon IDs), INTEGER AUTOINCREMENT for mutable game state

## Directory Structure

### Client
- `client-godot/scripts/` — GDScript game logic
- `client-godot/scenes/` — Godot scene files (.tscn)
- `client-godot/tests/` — GDScript test scripts
- `client-godot/assets/` — Sprites, tile data, textures

### Server
- `server/cmd/rpg-server/` — Entry point (main.go)
- `server/internal/database/` — DB wrapper, schema.sql DDL, migrations/ seed data
- `server/internal/models/` — Domain structs + service layer
- `server/internal/ws/` — WebSocket layer (hub, client, message envelope, handlers)

### Skills (Reconcilers)
- `skills/SKILL.md` — **Entry point.** Read this first. Maps specs to skills to code.
- `skills/godot-engine/` — Godot 4 client reconciler
- `skills/asset-gen/` — Asset generation reconciler
- `skills/websocket-api/` — Go server reconciler (6 files: project structure, database, models, WebSocket, handlers, setup)

### Specs (Desired State)
- `specs/` — 9 spec files defining the complete game design

### Tile Pipeline
- `map_tiles/` — Tile generation tools (plan_tiles.py, generate_subtiles.sh)

## Server WebSocket Protocol
Messages use a JSON envelope: `{"type": "message_type", "payload": {...}}`

### Reference data (no payload needed)
`get_ancestries`, `get_classes`, `get_weapons`, `get_armor`, `get_shields`, `get_terrain`, `get_monsters`, `get_spells`, `get_items`

### Parameterized queries
- `get_ability_mod` — `{"ability": "str", "score": 18}`
- `get_encounters` — `{"id": "plains"}`
- `get_starting_equipment` — `{"id": "fighter"}`

### Game actions
- `create_character` — `{"name": "...", "ancestry_id": "dwarf", "class_id": "fighter", "str": 16, ...}`
- `get_character` — `{"character_id": 1}`
- `move` — `{"character_id": 1, "direction": "n"}` (directions: n, s, e, w)

### Errors
Error responses use type `original_type_error` with payload `{"error": "message"}`.

## Workflow

### Skill-Driven Reconciliation
1. **ALWAYS** start by reading `skills/SKILL.md` (the entry-point reconciler).
2. The entry-point maps every spec to the skill and code that implements it.
3. For any task, find the relevant row in the reconciliation map, read the spec, read the skill, read the code, then reconcile.
4. **NEVER** implement code without first reading the owning skill.

### Spec-First Development
- **ALWAYS** add or edit a spec in `specs/` BEFORE writing any implementation code.
- Every feature, refactor, or architectural change must have a corresponding spec.
- If a spec already exists for the area being changed, update it first.
- Get user approval on the spec before proceeding to implementation.

## Conventions
- Use semantic naming throughout.
- Game rules follow OSRIC 3.0 / AD&D 1e as specified in the game spec.
- Server migrations follow stonks pattern: `YYYYMMDDHHMMSS_description.sql`, tracked in `schema_migrations` table.

## Game Design Reference
- See `specs/` directory for complete game design specifications.
- See `skills/SKILL.md` for the reconciliation map (specs -> skills -> code).
- See `skills/websocket-api/` for server implementation reference.
- See `skills/godot-engine/` for Godot client reference.

# important-instruction-reminders
Do what has been asked; nothing more, nothing less.
NEVER create files unless they're absolutely necessary for achieving your goal.
ALWAYS prefer editing an existing file to creating a new one.
NEVER proactively create documentation files (*.md) or README files. Only create documentation files if explicitly requested by the User.
