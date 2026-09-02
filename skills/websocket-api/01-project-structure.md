# 01 — Project Structure

This document describes the Go WebSocket game server layout. Follow these conventions exactly when adding new features.

## Directory Layout

```
server/
├── cmd/
│   └── rpg-server/
│       └── main.go              # entry point, wires all services
├── internal/
│   ├── database/
│   │   ├── db.go                # DB wrapper, schema init, migration runner
│   │   ├── schema.sql           # DDL (CREATE TABLE IF NOT EXISTS)
│   │   └── migrations/
│   │       └── YYYYMMDDHHMMSS_description.sql
│   ├── models/
│   │   ├── ancestry.go          # Ancestry + AncestryService
│   │   ├── class.go             # Class + ClassService
│   │   ├── weapon.go            # Weapon + WeaponService
│   │   ├── armor.go             # Armor + ArmorService, Shield + ShieldService
│   │   ├── terrain.go           # Terrain + TerrainService
│   │   ├── monster.go           # Monster + MonsterService
│   │   ├── character.go         # Character + CharacterService (CRUD)
│   │   ├── ability_mod.go       # AbilityMod + AbilityModService
│   │   ├── encounter.go         # EncounterEntry + EncounterService
│   │   ├── spell.go             # Spell + SpellService
│   │   ├── item.go              # Item + ItemService
│   │   ├── quest.go             # QuestTemplate, CharacterQuest + QuestService
│   │   ├── stronghold.go        # StrongholdStructure, StrongholdUpgrade, etc.
│   │   ├── combat_log.go        # CombatLog + CombatLogService
│   │   └── explored_hex.go      # ExploredHex + ExploredHexService
│   └── ws/
│       ├── message.go           # Envelope type + payload structs
│       ├── hub.go               # Connection hub (register/unregister/broadcast)
│       ├── client.go            # Per-connection read/write pumps
│       └── handlers.go          # Handler struct + message dispatch + game logic
└── go.mod
```

## Key Decisions

| Decision | Choice | Rationale |
|---|---|---|
| HTTP library | `net/http` (stdlib) | No third-party router needed. Single `/ws` endpoint. |
| WebSocket library | `nhooyr.io/websocket v1.8.17` | Modern, stdlib-friendly, works with any client (browser, native binary). |
| Database | SQLite via `github.com/mattn/go-sqlite3` | Embedded, single-file, zero config. WAL mode for concurrent reads. |
| ORM | None | Raw SQL with `?` placeholders. `RETURNING` clause for INSERT auto-fields. |
| Schema management | `//go:embed` | DDL and migrations compiled into the binary. No external files at runtime. |
| Reference data keys | TEXT PRIMARY KEY | Natural keys like `"dwarf"`, `"fighter"`, `"longsword"`. |
| Game state keys | INTEGER AUTOINCREMENT | Surrogate keys for characters, quests, combat logs, explored hexes. |

## Adding a New Feature (Checklist)

1. **Schema** — Add `CREATE TABLE IF NOT EXISTS` to `schema.sql`. If seeding data, create a new migration file.
2. **Model** — Create `server/internal/models/thing.go` with struct + `ThingService` + SQL methods.
3. **Payload** — Add request/response types to `server/internal/ws/message.go`.
4. **Handler** — Add a `case "get_things":` to the switch in `handlers.go`, write the handler method.
5. **Wiring** — Add `NewThingService(sqlDB)` in `main.go`, pass it to `ws.NewHandler(...)`.
6. **Build** — Run `go build ./...` to verify compilation.

## go.mod

```go
module rpg

go 1.24

require (
    github.com/mattn/go-sqlite3 v1.14.28
    nhooyr.io/websocket v1.8.17
)
```

Only two dependencies. Do not add more without explicit approval.
