# Godot Client Architecture Specification

## Overview

The Godot 4.x client lives at `components/client/`. It is the primary game
interface and will eventually connect to the Go server at `components/server/`
for game state, render a zoomable world, and handle player interaction.

### Bootstrap Milestone (M0)

Before implementing world rendering, networking, tilemaps, combat, or UI, the
client must provide one independently runnable scene with these requirements:

- A `Node2D` main scene at `res://scenes/main.tscn`.
- A grass background covering the complete viewport.
- One visible, programmatically drawn character centered at
  `get_viewport_rect().size / 2`.
- Re-centering and redraw when the viewport changes size.
- Escape uses Godot's built-in `ui_cancel` action and exits via
  `get_tree().quit()`.
- No dependency on third-party demo scenes, assets, combat, dialogue, server
  processes, or generated sprite sheets.

M0 is complete only when Godot can import the project and run the main scene
without parser or runtime errors. It is intentionally a rendering and input
baseline, not a vertical slice of the final RPG.

This spec defines the scene architecture, data flow, and conventions that
make the Godot client easy to build and maintain.

---

## Design Principles

### P1: One Scene Per Responsibility

Each `.tscn` file represents one distinct screen or UI layer. Scenes are
small, focused, and independently testable. A scene should not exceed
500 lines of GDScript in its attached script.

### P2: Autoloads for Shared State, Not for Rendering

Autoloads (`GameState`, `WsClient`, `ServerProcess`) hold data and
connections. They never create nodes, draw anything, or manage scene
transitions. Scenes read from autoloads and react to their signals.

### P3: Signals Over Direct Calls

Scenes communicate upward via signals. Parent nodes connect to child
signals. Children never call methods on their parent — they emit signals
and let the parent decide what to do.

### P4: Server Is the Source of Truth

The client never computes game rules (movement cost, encounters, time
passage, experience). It sends requests to the server and renders the
response. The client may compute *visual-only* things: terrain color,
camera position, hex geometry, UI layout.

### P5: Separate Data Scripts From Scene Scripts

Scripts attached to scene nodes handle rendering and input. Pure data
scripts (`class_name` scripts with no `extends Node`) handle addressing,
math, terrain lookup, and tier metadata. Data scripts have no side
effects and are trivially unit-testable.

---

## Scene Hierarchy

### Main Scene Tree

```
Main (Node2D)                       ← Entry point, manages scene transitions
├── CurrentView (Node2D)            ← Swapped on tier change / screen change
│   └── (one of the view scenes below, instanced at runtime)
├── HUD (CanvasLayer)               ← Always visible overlay
│   ├── TierLabel
│   ├── TerrainLabel
│   ├── CharacterLabel
│   ├── TimeLabel
│   ├── StatusLabel
│   ├── HintLabel
│   └── ToolbarButtons              ← Sprite Atlas, Settings, etc.
└── Dialogs (CanvasLayer)           ← Modal overlays (connect, char create, etc.)
```

### View Scenes (instanced into CurrentView)

| Scene | Purpose | When Shown |
|-------|---------|------------|
| `connect_screen.tscn` | Server URL input, connect button | On launch, before character exists |
| `world_tier.tscn` | Hex map at world depth (depth 1) | After character created, at world zoom |
| `sub_tier.tscn` | Hex map at depths 2–6 | Zoomed into any sub-hex tier |
| `map_view.tscn` | Pre-rendered tile pyramid viewer | Viewing server-rendered tile images |
| `sprite_atlas.tscn` | Sprite sheet browser | Toggled from toolbar |

### Why Separate Scenes for World vs Sub-Tier?

The world tier uses a small hex size (3px) and infinite procedural
coordinates (`/-190,155`). Sub-tiers use a large hex size (32px) and
finite 6-child grids. These are fundamentally different rendering modes:

- **World tier**: Generates a viewport-sized grid of hexes around the
  player's world coordinate. Camera pans by shifting the grid origin.
  No parent/child relationship — the world is flat and infinite.

- **Sub-tiers**: Shows 6 child hexes of the current parent hex. Camera
  is fixed. Clicking a hex sends `zoom_in` to the server. ESC sends
  `zoom_out`. The server manages the address stack.

Trying to handle both in one scene creates branching (`if depth == 1`)
that makes the code harder to follow. Two focused scenes are cleaner.

---

## Scene Transition Flow

```
connect_screen ──(connected + character exists)──→ world_tier
connect_screen ──(connected + no character)──→ char_create_dialog
world_tier ──(zoom_in response)──→ sub_tier
sub_tier ──(zoom_in response, depth < 6)──→ sub_tier (re-render)
sub_tier ──(zoom_out response, to depth 1)──→ world_tier
sub_tier ──(zoom_out response, depth > 1)──→ sub_tier (re-render)
any view ──(toolbar button)──→ sprite_atlas / map_view
sprite_atlas ──(back button / ESC)──→ previous view
map_view ──(back button / ESC)──→ previous view
```

Transitions are managed by `Main`. View scenes emit signals like
`zoom_requested(address)` or `back_requested()`. Main handles
instancing and freeing view scenes.

---

## Autoloads

### GameState (scripts/game_state.gd)

Holds the current character state, address, time. Emits signals when
state changes. Does NOT make server calls directly — view scenes call
`WsClient.send_message()` and listen for responses.

**Current signals:**
- `character_updated(data)` — Character state changed
- `move_result_received(result)` — Server responded to a move
- `zoom_result_received(result)` — Server responded to a zoom

### WsClient (scripts/ws_client.gd)

WebSocket connection manager. Sends JSON envelopes, emits
`message_received(type, payload)` for all server responses. No game
logic — just transport.

### ServerProcess (scripts/server_process.gd)

Optional: launches the Go server as a child process for single-player
mode. Not needed when connecting to a remote server.

---

## Data Scripts (class_name, no extends Node)

| Script | Purpose |
|--------|---------|
| `HexAddress` | Address parsing, parent/child, depth, seed, terrain lookup |
| `HexMath` | Hex geometry: pixel↔axial conversion, hex corners |
| `TierData` | Tier enum, names, scale labels, scene paths, parent/child tier |
| `TerrainData` | Terrain enum, colors, names, elevation→terrain mapping |

These scripts are stateless. Every function is `static`. They can be
called from any scene or test without side effects.

---

## Tile Image Rendering

### Two Rendering Modes

The client supports two ways to display the map:

**Mode A: Procedural Hex Rendering (current `world_tier.gd` / `sub_tier.gd`)**

The client generates terrain procedurally using `HexAddress.terrain_for_address()`
and renders colored hexagons via `HexMap._draw()`. Fast, no server tile
images needed. Used for gameplay.

**Mode B: Server-Rendered Tile Images (current `map_view.gd`)**

The client fetches pre-rendered PNG tile images from the server's
`GET /tiles/{address}` endpoint (see `tile_rendering.spec.md`). Used
for the painted world map at depths 0–2 and sprite-composited tiles
at depths 3–5. Provides beautiful visual quality.

### Target Architecture: Hybrid

The final client will combine both modes:

1. **Background layer**: Server-rendered tile image (painted map or
   sprite composite) displayed as a `TextureRect` or `Sprite2D`
2. **Overlay layer**: Hex grid drawn on top for selection, movement
   highlights, fog of war
3. **Content layer**: Player token, NPC markers, item glints
4. **HUD layer**: Character stats, terrain info, controls

The hex grid overlay aligns to the tile image using the normalized
bounds coordinate system defined in `tile_rendering.spec.md`.

---

## Tile Loading

### HTTP Tile Requests

```gdscript
func _request_tile(address: String) -> ImageTexture:
    var url := "http://%s/tiles/%s" % [server_host, address]
    var http := HTTPRequest.new()
    add_child(http)
    http.request(url)
    var result = await http.request_completed
    http.queue_free()
    # result[3] is the response body (PackedByteArray)
    var img := Image.new()
    img.load_png_from_buffer(result[3])
    return ImageTexture.create_from_image(img)
```

### Texture Cache

Keep a `Dictionary[String, ImageTexture]` of loaded tiles keyed by
address. Maximum 120 entries. Evict tiles that are >2 depth levels
from the current view or fully outside the viewport.

### Progressive Loading

1. Show parent tile (lower resolution) immediately
2. Request child tiles asynchronously
3. Replace parent region with child tiles as they arrive
4. On zoom out, discard children and show parent

---

## Input Handling

### Input Map Actions (Project Settings)

Define named actions instead of hardcoding keycodes:

| Action | Default Binding | Purpose |
|--------|----------------|---------|
| `move_ne` | Key 1 / Numpad 1 | Hex movement direction 0 |
| `move_e` | Key 2 / Numpad 2 | Hex movement direction 1 |
| `move_se` | Key 3 / Numpad 3 | Hex movement direction 2 |
| `move_sw` | Key 4 / Numpad 4 | Hex movement direction 3 |
| `move_w` | Key 5 / Numpad 5 | Hex movement direction 4 |
| `move_nw` | Key 6 / Numpad 6 | Hex movement direction 5 |
| `zoom_out` | Escape | Zoom out one tier |
| `pan_up` | W / Arrow Up | Camera pan |
| `pan_down` | S / Arrow Down | Camera pan |
| `pan_left` | A / Arrow Left | Camera pan |
| `pan_right` | D / Arrow Right | Camera pan |

Using `Input.is_action_pressed("pan_up")` instead of
`Input.is_key_pressed(KEY_W)` allows key rebinding and gamepad support.

### Mouse Input

- **Left click on hex**: Zoom in (if at current position) or select
- **Right click**: Zoom out
- **Mouse wheel**: Camera zoom (adjust `Camera2D.zoom`)
- **Mouse motion**: Hex hover highlight

---

## File Conventions

### Naming

- Scene files: `snake_case.tscn`
- Script files: `snake_case.gd`
- Data scripts: `snake_case.gd` with `class_name PascalCase`
- Autoloads: `PascalCase` (Godot convention for global singletons)

### Script Structure

Every `.gd` file follows this order:

1. `extends` / `class_name`
2. Constants (`const`)
3. Exported variables (`@export`)
4. Instance variables (`var`)
5. Signals (`signal`)
6. `_ready()` / lifecycle
7. Public functions
8. Private functions (prefixed with `_`)

### File Size

Maximum 500 lines per script. If a script exceeds this, extract a
data script (`class_name`) or split the scene into sub-scenes.

---

## Directory Structure

```
client-godot/
├── project.godot
├── scenes/
│   ├── main.tscn                  ← Entry point
│   ├── connect_screen.tscn        ← Server connection UI
│   ├── world_tier.tscn            ← World-level hex map
│   ├── sub_tier.tscn              ← Sub-tier hex map (depths 2-6)
│   ├── map_view.tscn              ← Tile image pyramid viewer
│   ├── sprite_atlas.tscn          ← Sprite sheet browser
│   └── child_tier_base.tscn       ← (legacy, to be merged into sub_tier)
├── scripts/
│   ├── main.gd
│   ├── connect_screen.gd
│   ├── world_tier.gd
│   ├── child_tier.gd              ← (legacy, to be merged into sub_tier)
│   ├── map_view.gd
│   ├── sprite_atlas.gd
│   ├── hud.gd
│   ├── hex_map.gd                 ← Hex grid renderer (Node2D, custom _draw)
│   ├── map_camera.gd              ← Camera2D with pan/zoom
│   ├── game_state.gd              ← Autoload: character state
│   ├── ws_client.gd               ← Autoload: WebSocket transport
│   ├── server_process.gd          ← Autoload: optional server launcher
│   ├── hex_address.gd             ← class_name HexAddress (static, pure)
│   ├── hex_math.gd                ← class_name HexMath (static, pure)
│   ├── tier_data.gd               ← class_name TierData (static, pure)
│   └── terrain_data.gd            ← class_name TerrainData (static, pure)
├── tests/
│   ├── test_hex_address.gd
│   ├── test_zoom_terrain.gd
│   └── test_client_integration.gd
└── build/
    └── (export artifacts)
```

---

## Testing

### Unit Tests

Data scripts (`HexAddress`, `HexMath`, `TierData`, `TerrainData`) are
tested with GDScript test files in `tests/`. Each test function is
prefixed with `test_` and uses `assert()`.

Run tests via: `./test.sh`

### Integration Tests

`test_client_integration.gd` tests the full flow: connect to server,
create character, move, zoom in/out. Requires a running server.

---

## Sprite Sheet Integration

The sprite sheet (`sprites.png`, 2816×1536) contains 130 terrain,
road, and building sprites indexed by `map_tiles/sprites.json`.

### Usage in Tile Rendering

The Go server uses the sprite sheet for compositing tiles at depths 3–5
(see `tile_rendering.spec.md`). The client does NOT need to parse the
sprite sheet for gameplay rendering — the server delivers finished
tile images.

### Sprite Atlas View

The `sprite_atlas.tscn` scene provides a browsable view of all sprites
for development and art review. It loads `sprites.png` as an
`ImageTexture` and uses `AtlasTexture` regions from `sprites.json`
to display individual sprites in a grid.

---

## Migration Path from Current State

### Current State (two parallel systems)

1. **`map_view.gd`**: Standalone tile pyramid viewer. Reads from
   `map_tiles/map2/` directory with `manifest.json`. Uses absolute
   file paths. No server connection. 4×3 grid with neighbor rendering.

2. **`world_tier.gd` + `child_tier.gd`**: Server-connected hex game.
   Procedural terrain via `HexAddress.terrain_for_address()`. WebSocket
   move/zoom. 6-child hex hierarchy.

### Target State (unified)

One integrated system where:
- The painted map tile images come from the server's `/tiles/` endpoint
- The hex grid is drawn over the tile images for interaction
- Movement and zoom go through the server
- The client only renders what the server tells it

### Migration Steps

1. **Add `/tiles/{address}` endpoint to server** — Implement crop +
   composite rendering per `tile_rendering.spec.md`
2. **Add tile image loading to `world_tier.gd`** — Request tile image
   for current view, display as background behind hex grid
3. **Merge `child_tier.gd` into `world_tier.gd`** — `world_tier.gd`
   already handles both depth 1 and sub-depths; `child_tier.gd` is
   the legacy version
4. **Retire `map_view.gd` for gameplay** — Keep as a dev tool for
   viewing the raw tile pyramid, but gameplay uses `world_tier.gd`
5. **Remove absolute file paths** — Replace with server HTTP requests
   or `res://` paths for bundled assets

---

## Performance Considerations

### Hex Grid Rendering

`HexMap._draw()` redraws the entire grid every frame when scrolling.
For large viewport grids (100+ hexes), this is fine — Godot's `_draw()`
batches polygon calls efficiently. If profiling shows a bottleneck,
switch to a `TileMapLayer` with hex tiles.

### Texture Memory

At any given time, the client should hold at most:
- 1 background tile image (~256 KB at 256×256 RGBA)
- Up to 12 neighbor tile images for context (~3 MB)
- The sprite atlas texture (~32 MB for the 2816×1536 source, loaded
  only in the sprite atlas view)

### Network

Tile image requests are cached. A typical zoom or pan triggers 1–12
tile requests. At ~10 KB per tile PNG, that's <120 KB per interaction.
The WebSocket connection handles move/zoom messages at <1 KB each.
