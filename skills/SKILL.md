---
name: project-reconciler
description: "Top-level entry point. Read this skill FIRST for any build, audit, or implementation task. Maps every spec to the skill and code that implements it, defines reconciliation order, and provides the check/act loop for driving specs to completion. Triggers on: build, reconcile, audit, verify, implement, start, status, plan."
---

# Project Reconciler (Entry Point)

> This is the root skill. It reconciles the game specs against the codebase. Read this before touching any code.

## Architecture

```
specs/           <- desired state (what the game should be)
skills/          <- reconciler instructions (how to build it)
server/          <- Go WebSocket server + SQLite
client-godot/    <- Godot 4 GDScript client
map_tiles/       <- tile generation pipeline
```

## Reconciliation Map

Each spec has an owning skill and a code target. Reconcile in this order (dependencies flow top-down):

| # | Spec | Skill | Code Target | Check |
|---|------|-------|-------------|-------|
| 1 | `datamodel.spec.md` | `websocket-api/02-database-layer.md` | `server/internal/database/schema.sql`, `migrations/` | Tables, columns, keys match spec |
| 2 | `game.spec.md` | `websocket-api/03-model-layer.md` | `server/internal/models/` | Structs, services, SQL match spec rules |
| 3 | `game.spec.md` | `websocket-api/04-websocket-layer.md`, `05-handler-layer.md` | `server/internal/ws/` | Message types, payloads, handlers match spec protocol |
| 4 | `tile_rendering.spec.md` | `websocket-api/06-server-setup.md` | `server/cmd/rpg-server/main.go`, `server/internal/render/` | HTTP `/tiles/{address}` endpoint, TileRenderer, LRU cache |
| 5 | `materialization.spec.md` | `websocket-api/03-model-layer.md` | `server/internal/models/tile*.go` | ContentProvider, TileContentService, materialization pipeline |
| 6 | `godot_client.spec.md` | `godot-engine/SKILL.md` | `client-godot/` | Scenes, scripts, addressing, grid, input, tile loading |
| 7 | `tile_rendering.spec.md` | `asset-gen/SKILL.md` | `map_tiles/` | 10x10 grid, sprite sheet, tile pipeline |
| 8 | `world.spec.md` | `websocket-api/02-database-layer.md` | `server/internal/database/migrations/` | Seed data: kingdoms, cities, terrain |
| 9 | `campaign.spec.md` | `websocket-api/03-model-layer.md` | `server/internal/models/quest.go` | Quest templates, phase progression |
| 10 | `npcs.spec.md` | `websocket-api/03-model-layer.md` | `server/internal/models/` | NPC structs, disposition, dialogue |
| 11 | `narrator.spec.md` | `godot-engine/SKILL.md` | `client-godot/scripts/` | Narrator voice, terrain descriptions, session flow |

## Reconciliation Loop

For each row in the table above:

```
1. READ   the spec (desired state)
2. READ   the skill (how to implement)
3. READ   the code target (current state)
4. DIFF   spec vs code -> list of discrepancies
5. PLAN   changes needed to resolve each discrepancy
6. ACT    implement changes following the skill's patterns
7. TEST   run `./test.sh` (Go tests + GDScript tests)
8. VERIFY re-read code target, confirm spec is satisfied
```

Never skip steps. Never implement without reading the skill first.

## Quick Status Check

Run this sequence to audit the entire project:

1. Read `specs/datamodel.spec.md` -> compare `server/internal/database/schema.sql`
2. Read `specs/game.spec.md` -> compare `server/internal/models/` and `server/internal/ws/handlers.go`
3. Read `specs/tile_rendering.spec.md` -> check for `server/internal/render/` and HTTP endpoint in `main.go`
4. Read `specs/materialization.spec.md` -> check for `ContentProvider` interface and `TileContentService`
5. Read `specs/godot_client.spec.md` -> compare `client-godot/scripts/` and `client-godot/scenes/`
6. Run `./test.sh` -> all tests pass

## Build Order (Fresh Start)

When building from scratch or after a major refactor:

1. **Schema** — `datamodel.spec.md` -> `schema.sql` + migrations
2. **Models** — `game.spec.md` -> model structs + services
3. **Handlers** — `game.spec.md` -> WebSocket message types + handlers
4. **Tile Renderer** — `tile_rendering.spec.md` -> HTTP endpoint + renderer
5. **Materialization** — `materialization.spec.md` -> content pipeline
6. **Client Scenes** — `godot_client.spec.md` -> Godot scenes + scripts
7. **Assets** — `tile_rendering.spec.md` -> sprite sheets + tile pipeline
8. **World Data** — `world.spec.md` + `npcs.spec.md` -> seed migrations
9. **Quests** — `campaign.spec.md` -> quest templates + progression
10. **Narrator** — `narrator.spec.md` -> client-side narration
11. **Distribution** — `build/SKILL.md` -> compile server + export client -> `dist/run.sh`

## Sub-Skills

| Skill | Scope | Files |
|-------|-------|-------|
| `godot-engine/SKILL.md` | Godot 4 client: scenes, scripts, GDScript patterns, export, testing | `client-godot/` |
| `asset-gen/SKILL.md` | Image/3D generation, sprite sheets, background removal | `map_tiles/`, external tools |
| `websocket-api/*.md` | Go server: project structure, database, models, WebSocket, handlers, setup | `server/` |
| `tile-rendering/SKILL.md` | Server-side sprite compositing, HTTP tile endpoint, sprite atlas | `server/internal/render/`, `sprites/` |
| `build/SKILL.md` | Compile server, export client, assemble `dist/`, launch script | `dist/` |

## Commands

```bash
./test.sh                                    # full suite (Go + GDScript)
cd server && go test ./...                   # Go tests only
cd server && go build -o rpg-server ./cmd/rpg-server/  # build server
/home/mturansk/Downloads/Godot_v4.6.3-stable_linux.x86_64 --headless --path client-godot/ --script tests/test_hex_address.gd  # GDScript unit tests
dist/run.sh                                  # launch the game (server + client)
```

## Key Invariants

- 10x10 grid: every tile has 100 children (indices 00-99)
- 6-depth hierarchy: world -> regional -> area -> district -> block -> tactical
- Address format: `map2_35_07_42` (each `_XX` is col + row*10)
- NSEW movement (4 cardinal directions)
- Server renders tiles as PNG via HTTP `GET /tiles/{address}`
- Client fetches tile images from server, composites overlays locally
- OSRIC/AD&D 1e rules for combat, spells, saving throws, XP
- JSON envelope protocol: `{"type": "...", "payload": {...}}`
- Spec-first: update spec before writing code
- Skill-first: read the skill before implementing
