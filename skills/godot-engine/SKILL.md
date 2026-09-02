---
name: godot-engine
description: "Use this skill when working with the Godot 4 client. Covers project shape, GDScript patterns, scene structure, camera, tilemaps, WebSocket client, export, headless capture, and silent-failure traps. Triggers on: Godot, GDScript, scene, tscn, project.godot, export, headless, client-godot."
---

# Godot 4 Engine Guide
> Godot 4.x with GDScript. Covers project layout, scene conventions, tile-based rendering with the 10×10 depth hierarchy, WebSocket client integration, camera controls, export, headless capture, and silent-failure traps specific to this RPG.

**Key source paths:** `client-godot/project.godot`, `client-godot/scripts/`, `client-godot/scenes/`, `client-godot/tests/`
**Related skills:** ../SKILL.md (entry point), ../websocket-api/01-project-structure.md, ../asset-gen/SKILL.md

## Quick Start

```bash
# Godot binary location
/home/mturansk/Downloads/Godot_v4.6.3-stable_linux.x86_64

# Run the project
/home/mturansk/Downloads/Godot_v4.6.3-stable_linux.x86_64 --path client-godot/

# Headless import (after asset changes)
/home/mturansk/Downloads/Godot_v4.6.3-stable_linux.x86_64 --headless --import --path client-godot/

# Export (Linux)
/home/mturansk/Downloads/Godot_v4.6.3-stable_linux.x86_64 --headless --export-release "Linux" client-godot/build/hex-world-rpg.x86_64
```

## Project Shape

```
client-godot/
├── project.godot          # Config, input actions, display, physics
├── export_presets.cfg      # Export preset configuration
├── scripts/
│   ├── main.gd            # Entry point / scene controller
│   ├── ws_client.gd       # WebSocket client for server communication
│   ├── game_state.gd      # Game state management
│   ├── map_view.gd        # Map rendering/view management
│   ├── hex_map.gd         # Tile grid map logic
│   ├── hex_math.gd        # Tile coordinate math utilities
│   ├── hex_address.gd     # Tile addressing/coordinate system
│   ├── map_camera.gd      # Camera controls for the map
│   ├── hud.gd             # Heads-up display
│   ├── terrain_data.gd    # Terrain type definitions
│   ├── tier_data.gd       # Zoom tier data definitions
│   ├── world_tier.gd      # World-level (top) zoom tier
│   ├── child_tier.gd      # Child zoom tier (shared logic)
│   ├── sprite_atlas.gd    # Sprite atlas/texture management
│   ├── server_process.gd  # Local server process management
│   └── connect_screen.gd  # Server connection UI
├── scenes/
│   ├── main.tscn
│   ├── connect_screen.tscn
│   ├── map_view.tscn
│   ├── sprite_atlas.tscn
│   ├── world_tier.tscn
│   ├── child_tier_base.tscn
│   ├── regional_tier.tscn
│   ├── local_tier.tscn
│   ├── district_tier.tscn
│   ├── street_tier.tscn
│   └── tactical_tier.tscn
├── tests/
│   ├── test_hex_address.gd
│   ├── test_zoom_terrain.gd
│   └── test_client_integration.gd
└── build/                  # Export artifacts + bundled server
```

## Tile Hierarchy (10×10 Grid)

The game uses a 6-depth tile pyramid. Each tile has 100 children (10×10 grid, indices 00–99).

| Depth | Tier       | Scale   | Content                        |
|-------|------------|---------|--------------------------------|
| 0     | World      | ~200 mi | Source map crop                 |
| 1     | Regional   | ~20 mi  | Kingdoms, biomes                |
| 2     | Area       | ~2 mi   | Towns, dungeons, terrain        |
| 3     | District   | ~1,000' | Sprite composited from terrain  |
| 4     | Block      | ~100'   | Buildings, encounters           |
| 5     | Tactical   | ~10'    | D&D combat square (10×10 grid)  |

Address format: `map2_35_07_42` — each `_XX` appends a child index where `col = XX % 10`, `row = XX / 10`.

Tiles are rendered server-side via HTTP (`GET /tiles/{address}`) and served as PNG. The Godot client fetches tile images and composites overlay layers (fog, NPCs, items, time-of-day, player).

## Scene Conventions

Each zoom tier has its own scene file (`world_tier.tscn`, `regional_tier.tscn`, etc.) extending a shared `child_tier_base.tscn`. Scenes are hand-authored `.tscn` files, not generated at build time.

Tier scenes attach scripts from `scripts/` that handle:
- Tile image loading from the server tile endpoint
- Grid layout of 10×10 child tiles
- Zoom in/out transitions between tiers
- Overlay rendering (fog of war, NPCs, items)

## WebSocket Client

`ws_client.gd` implements the JSON envelope protocol:

```gdscript
# Send
var msg = {"type": "move", "payload": {"character_id": 1, "direction": "ne"}}
_ws.send_text(JSON.stringify(msg))

# Receive (in _process)
while _ws.get_available_packet_count() > 0:
    var text = _ws.get_packet().get_string_from_utf8()
    var parsed = JSON.parse_string(text)
    var msg_type = parsed["type"]
    var payload = parsed["payload"]
```

Message types follow the server protocol defined in CLAUDE.md.

## Camera

`map_camera.gd` handles pan, zoom, and bounds for the tile map view. The camera constrains to the current tier's tile bounds and supports smooth zoom transitions between tiers.

## GDScript Conventions

- All scripts use `class_name` for type registration where needed
- Use typed variables (`var x: int = 0`) for clarity
- Signals for decoupled communication between scenes
- `@onready` for node references resolved at `_ready()` time
- `@export` for inspector-configurable properties

## Silent-Failure Traps (Godot 4)

These pass compilation but break at runtime or produce wrong results:

- **`preload()` vs `load()`** — `preload()` resolves at parse time and fails silently if the path doesn't exist yet (e.g., generated assets). Use `load()` for runtime-resolved paths.
- **`@onready` timing** — `@onready` runs during `_ready()`, not `_init()`. Accessing `@onready` vars in `_init()` gives `null`.
- **`await` during `--write-movie`** — Each `await` advances the frame counter, producing unexpected frame output in movie captures.
- **Type inference with `:=`** — `instantiate()` returns `Variant`, polymorphic math functions (`abs`, `clamp`, `lerp`, `min`, `max`) return `Variant`. Using `:=` with these silently breaks type inference. Explicitly type the variable instead.
- **`.gdignore`** in a directory makes the importer skip it silently — never place `.gdignore` in asset directories.
- **Raycast failures** — Raycasts don't reliably hit `ConcavePolygonShape3D` (trimesh). Use shape queries or analytical intersection.
- **Frame-rate-independent damping** — Use `speed *= exp(-rate * delta)`, not `speed *= (1 - drag)` per tick.

## Headless Capture (Proof Video)

```bash
xvfb-run -a -s '-screen 0 1920x1080x24' \
  /home/mturansk/Downloads/Godot_v4.6.3-stable_linux.x86_64 \
  --headless --import --path client-godot/

xvfb-run -a -s '-screen 0 1920x1080x24' \
  /home/mturansk/Downloads/Godot_v4.6.3-stable_linux.x86_64 \
  --write-movie screenshots/result/frame.png --fixed-fps 30 --quit-after 450 \
  --path client-godot/

ffmpeg -y -framerate 30 -pattern_type glob -i 'screenshots/result/frame*.png' \
  -c:v libx264 -pix_fmt yuv420p -movflags +faststart screenshots/result/video.mp4
```

`--fixed-fps` makes motion deterministic (450 frames @30fps = 15s). Pre-position the camera before first frame renders.

## Build & Test

```bash
# Run all tests (Go + GDScript)
./test.sh

# Run Go server
cd server && go run ./cmd/rpg-server/

# Build Go server
cd server && go build -o rpg-server ./cmd/rpg-server/

# Go tests only
cd server && go test ./...
```

## System Dependencies

```bash
# Required for headless rendering and capture
sudo dnf install vulkan-tools xvfb ffmpeg ImageMagick  # Fedora
sudo apt-get install vulkan-tools xvfb ffmpeg imagemagick  # Debian/Ubuntu
```
