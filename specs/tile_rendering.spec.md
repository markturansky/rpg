# Tile Rendering Specification

## Overview

The world is a recursive 10×10 tile hierarchy. Each tile subdivides into a
10×10 grid of 100 children, giving clean power-of-10 scaling from continent
level down to a 10'×10' combat square.

The tile pyramid serves a dual purpose: it is both the rendering hierarchy for
progressive zoom and the game world's spatial grid. A tile address like
`map2_35_07` is simultaneously the rendering coordinate and the game location.
See `datamodel.spec.md` for the unified addressing system.

All tile images are rendered dynamically by the Go server using **sprite
compositing** at every depth. The server loads sprite sheets from `sprites/`
at startup, composites tiles on demand using terrain data from the address
system, and caches encoded results in an LRU. The client requests tile images
via HTTP. No pre-rendered tile directories exist.

---

## Scale Hierarchy

The world map covers approximately 200 miles (~1,056,000 feet) across.

| Depth | Grid | Children | Cumulative Tiles | Tile Scale | Game Tier |
|-------|------|----------|-----------------|------------|-----------|
| 0 | 1×1 | 100 | 1 | ~200 mi (full continent) | **World** |
| 1 | 10×10 | 100 | 100 | ~20 mi | **Regional** |
| 2 | 10×10 | 100 | 10,000 | ~2 mi (~10,560') | **Area** |
| 3 | 10×10 | 100 | 1,000,000 | ~1,056' | **District** |
| 4 | 10×10 | 100 | 100,000,000 | ~106' | **Block** |
| 5 | 10×10 | 0 (leaf) | 10,000,000,000 | ~10.6' | **Tactical** |

Depth 5 is the leaf — a ~10'×10' square, one tactical combat cell. Tiles are
lazily materialized; the 10B theoretical maximum is never fully instantiated.
Only visited tiles exist in the database.

---

## Grid Layout

Children are indexed 00–99 in a 10×10 grid, left-to-right, top-to-bottom:

```
00  01  02  03  04  05  06  07  08  09    (row 0, top)
10  11  12  13  14  15  16  17  18  19    (row 1)
20  21  22  23  24  25  26  27  28  29    (row 2)
30  31  32  33  34  35  36  37  38  39    (row 3)
40  41  42  43  44  45  46  47  48  49    (row 4)
50  51  52  53  54  55  56  57  58  59    (row 5)
60  61  62  63  64  65  66  67  68  69    (row 6)
70  71  72  73  74  75  76  77  78  79    (row 7)
80  81  82  83  84  85  86  87  88  89    (row 8)
90  91  92  93  94  95  96  97  98  99    (row 9, bottom)
```

Grid position from index:
- `col = index % 10`
- `row = index / 10`

Index from position:
- `index = row * 10 + col`

---

## Naming Convention

Each tile name encodes the full path through the hierarchy:
- `map2` — root (depth 0)
- `map2_35` — child 35 of root (col=5, row=3)
- `map2_35_07` — child 07 of map2_35 (col=7, row=0 within map2_35)
- `map2_35_07_42` — child 42 of map2_35_07 (col=2, row=4)

The suffix after each `_` is the 2-digit grid index (00–99) within the
parent's 10×10 grid. Depth = number of underscore-delimited segments after
the root name.

---

## Coordinate System — Normalized Bounds

Every tile has a `bounds` array: `[x0, y0, x1, y1]` in normalized
coordinates where `(0,0)` is the top-left of the root image and
`(1,1)` is the bottom-right.

### Computing Bounds

Root bounds: `[0, 0, 1, 1]`

For a child at grid position `(col, row)` within a parent whose
bounds are `[px0, py0, px1, py1]`:

```
parent_w = px1 - px0
parent_h = py1 - py0
child_x0 = px0 + parent_w * col / 10
child_y0 = py0 + parent_h * row / 10
child_x1 = px0 + parent_w * (col + 1) / 10
child_y1 = py0 + parent_h * (row + 1) / 10
```

### Rendering Position

To place a tile on screen, convert normalized bounds to world
pixel coordinates:

```
screen_x = bounds[0] * map_world_width
screen_y = bounds[1] * map_world_height
screen_w = (bounds[2] - bounds[0]) * map_world_width
screen_h = (bounds[3] - bounds[1]) * map_world_height
```

---

## Sprite Compositing Architecture

The server uses a single rendering strategy for all depths: **sprite
compositing**. Every tile image is assembled by selecting sprites from
the atlas based on each child cell's terrain type.

### Sprite Atlas

Three sprite sheets live in `sprites/` with an index at `sprites/sprites.json`:

| Sheet | Purpose | Sprites |
|-------|---------|---------|
| `overworld-tileset.png` | Terrain surfaces, roads, bridges, buildings | 60 |
| `terrain-tileset.png` | Natural terrain: plains, water, forests, hills | 33 |
| `interior-tileset.png` | Building interiors, floors, walls, furniture | 52 |

Total: **145 sprites** across 3 sheets, all 1984×2164 RGBA PNGs.

The Go server loads all three sheets and the JSON index at startup. Each
sprite has a `name`, `category`, `subcategory`, and pixel region `{x, y, w, h}`.

### Terrain-to-Sprite Mapping

The server maps each of the 14 terrain IDs from the database to one or more
sprite names. When multiple sprites map to the same terrain, the variant is
selected deterministically: `variant = SeedForAddress(address) % len(variants)`.

| Terrain ID | Primary Sheet | Sprite Names (variants) |
|-----------|---------------|------------------------|
| `deep-water` | overworld | `water-deep` |
| `deep-water` | terrain | `terrain-ocean-deep` |
| `shallow-water` | terrain | `terrain-ocean-shallow`, `terrain-coastline-a`, `terrain-coastline-b` |
| `beach` | overworld | `sand-beach` |
| `plains` | overworld | `grassland-plain`, `grassland-rocky` |
| `plains` | terrain | `terrain-grassland-a`, `terrain-grassland-b`, `terrain-grassland-c`, `terrain-grassland-d` |
| `grassland` | terrain | `terrain-grassland-a`, `terrain-grassland-b`, `terrain-grassland-c`, `terrain-grassland-d` |
| `forest` | overworld | `forest-deciduous`, `forest-conifer`, `forest-bush` |
| `forest` | terrain | `terrain-forest-deciduous`, `terrain-forest-conifer`, `terrain-forest-mixed`, `terrain-forest-edge` |
| `dense-forest` | overworld | `forest-dark`, `forest-palm`, `forest-dense-canopy`, `forest-mixed-dense`, `forest-ancient` |
| `hills` | overworld | `hills-grassy`, `hills-contour`, `hills-desert`, `hills-rocky` |
| `hills` | terrain | `terrain-hills-rolling`, `terrain-hills-contour`, `terrain-hills-rocky` |
| `mountain` | overworld | `mountain-range`, `mountain-snow-peak`, `mountain-volcano`, `mountain-large` |
| `mountain` | terrain | `terrain-mountain-range`, `terrain-mountain-peak`, `terrain-mountain-snow`, `terrain-cliff-face` |
| `desert` | overworld | `sand-desert`, `hills-desert` |
| `marsh` | terrain | `terrain-swamp-fungal`, `terrain-swamp-murky` |
| `marsh` | overworld | `water-river-forest` |
| `tundra` | terrain | `terrain-mountain-snow` |
| `road` | overworld | `road-cobblestone`, `road-stone-paved`, `road-dirt-straight`, `road-dirt-worn` |
| `river` | terrain | `terrain-river-bend`, `terrain-lake-pond` |

The mapping is defined in code as a `map[string][]SpriteRef` where each
`SpriteRef` holds the sheet index and sprite name. This is the single source
of truth for which sprite represents which terrain.

### Depth-Aware Sheet Selection

Different depths favor different sprite sheets to give visual variety as
the player zooms:

| Depth | Primary Sheet | Rationale |
|-------|---------------|-----------|
| 0–2 | `overworld-tileset.png` | World/regional view — larger, more distinctive terrain tiles |
| 3–4 | `terrain-tileset.png` | District/block — natural terrain detail, individual trees/hills |
| 5 | `interior-tileset.png` | Tactical — building interiors, floors, walls (when inside) |

The server checks depth and terrain type to select the appropriate sheet.
Outdoor terrain at depth 5 still uses `terrain-tileset.png`; interior
tiles use `interior-tileset.png` (triggered by terrain ID `road` or
a future `building-interior` terrain type).

### Compositing Algorithm

For any tile at depth 0–4, the server renders its 100 children:

```go
func (r *TileRenderer) CompositeTile(address string, worldSeed, renderSize int) *image.RGBA {
    dst := image.NewRGBA(image.Rect(0, 0, renderSize, renderSize))
    cellSize := renderSize / 10

    for row := 0; row < 10; row++ {
        for col := 0; col < 10; col++ {
            childIndex := row*10 + col
            childAddr := TileAddress(address, childIndex)
            terrainID := TerrainForAddress(childAddr, worldSeed)
            spriteRef := r.atlas.SpriteForTerrain(terrainID, childAddr, Depth(childAddr))
            srcRect := spriteRef.Region()
            dstRect := image.Rect(col*cellSize, row*cellSize, (col+1)*cellSize, (row+1)*cellSize)
            draw.CatmullRom.Scale(dst, dstRect, spriteRef.Sheet, srcRect, draw.Over, nil)
        }
    }
    return dst
}
```

For depth-5 (leaf) tiles, the tile IS a single cell — render one sprite
scaled to `renderSize × renderSize`.

### Leaf Tile Rendering (Depth 5)

Depth-5 tiles have no children. The server renders a single sprite for the
tile's own terrain type, scaled to fill the render size:

```go
func (r *TileRenderer) RenderLeaf(address string, worldSeed, renderSize int) *image.RGBA {
    dst := image.NewRGBA(image.Rect(0, 0, renderSize, renderSize))
    terrainID := TerrainForAddress(address, worldSeed)
    spriteRef := r.atlas.SpriteForTerrain(terrainID, address, 5)
    draw.CatmullRom.Scale(dst, dst.Bounds(), spriteRef.Sheet, spriteRef.Region(), draw.Over, nil)
    return dst
}
```

---

## Server Implementation

### Startup

```go
type SpriteAtlas struct {
    sheets       []*image.RGBA
    sprites      map[string]SpriteEntry
    terrainMap   map[string][]SpriteRef
}

type SpriteRef struct {
    SheetIndex int
    Name       string
    X, Y, W, H int
}

type TileRenderer struct {
    atlas      *SpriteAtlas
    renderSize int
    cache      map[string][]byte
    mu         sync.RWMutex
}

func NewSpriteAtlas(jsonPath string, sheetPaths []string) (*SpriteAtlas, error)
func NewTileRenderer(atlas *SpriteAtlas, renderSize int) *TileRenderer
```

1. Load `sprites/sprites.json` to get sprite regions and sheet references
2. Load all three PNG sheets into memory as `*image.RGBA` (~50 MB total)
3. Build terrain-to-sprite mapping table
4. Initialize a `map[string][]byte` cache (simple map; LRU optional later)

### HTTP Tile Endpoint

```
GET /tiles/{address}?size={renderSize}
```

Response: PNG image (256×256 default), `Content-Type: image/png`,
`Cache-Control: public, max-age=86400`.

Handler flow:

```
1. Parse address from URL path
2. Validate address format (must start with "map2", valid depth)
3. Check cache → hit? Return cached bytes
4. Compute depth from address
5. If depth <= 4: CompositeTile(address, worldSeed, renderSize)
6. If depth == 5: RenderLeaf(address, worldSeed, renderSize)
7. Encode to PNG
8. Store in cache
9. Return encoded bytes with Content-Type: image/png
```

### Performance Budget

| Operation | Time | Throughput |
|-----------|------|-----------|
| Cache hit (byte slice lookup) | <1 μs | >1,000,000/sec |
| Depth 0–4 composite 10×10 + PNG encode | ~4 ms | ~250/sec |
| Depth 5 leaf single sprite + PNG encode | ~1 ms | ~1000/sec |

### Memory Budget

| Component | Memory |
|-----------|--------|
| 3 sprite sheets (1984×2164 RGBA each) | ~50 MB |
| Cache (10,000 tiles × ~10 KB avg) | ~100 MB |
| Per-request RGBA buffer (256×256) | ~256 KB (pooled via `sync.Pool`) |

Total: ~150 MB steady state.

### Cache Invalidation

Terrain-based tiles never change for a given world seed. The cache key is
`address + ":" + renderSize`. Cache entries live until server restart.

Dynamic overlays (NPCs, items, fog-of-war markers) are NOT baked into
the tile image. They are rendered client-side by Godot as sprite overlays
on top of the base tile.

---

## Content Overlay (Client-Side)

Dynamic content is rendered as an overlay by the Godot client, not baked
into the server-rendered base tile. The server provides content data via
WebSocket. The client composites:

```
Layer 0: Server-rendered base tile (from /tiles/{address})
Layer 1: Fog of war mask (from explored_tiles)
Layer 2: Content markers (from tile_contents response — NPC dots, item glints, quest icons)
Layer 3: Time-of-day tint (from game_hour)
Layer 4: Player token
```

This keeps the server's rendering pipeline stateless and cacheable.

---

## Tile Reassembly

The 100 children of any parent tile reassemble seamlessly when placed
according to their normalized bounds. Verification:

- Children at row 0: `y0 = parent.y0`, `y1 = parent.y0 + parent.h/10`
- Children at col 0: `x0 = parent.x0`, `x1 = parent.x0 + parent.w/10`
- No gaps or overlaps between adjacent children
- The union of all 100 children equals the parent's bounds exactly

---

## Client Rendering Requirements

### R1: Request tiles via HTTP

The client fetches tile images from the server's `/tiles/{address}` endpoint.
No manifest file is needed — the tile hierarchy is implicit in the address
system (append `_XX` to zoom in, remove last `_XX` to zoom out).

### R2: Determine visible tiles for current viewport

Given the camera's viewport and the current depth:

1. Compute which grid cells within the current parent are visible
2. Request those tile images from the server
3. Only request tiles that are not already cached client-side

### R3: Zoom-level-to-depth mapping

The client maintains a current depth. Zooming in increments depth and
selects a child tile. Zooming out decrements depth and returns to the parent.

### R4: Progressive tile loading

1. Always render the best available tile immediately (parent first)
2. When zooming in, begin loading child tiles asynchronously
3. Once a child tile loads, replace the parent region with the child
4. When zooming out past a depth boundary, discard children and
   show the parent tile

### R5: Tile positioning

For each visible tile, position it on the game canvas using its grid
position within the current parent:

```gdscript
var cell_size := viewport_size / 10.0
var pos := Vector2(col * cell_size.x, row * cell_size.y)
var size := cell_size
```

### R6: Fallback rendering

If a tile image fails to load (network error, server timeout):
1. Render a solid color rectangle using TerrainData.TERRAIN_COLORS
2. Log the error but do not block rendering
3. Retry loading after a backoff period (1s, 2s, 4s exponential)

---

## Testing Requirements

### Server Tests

| Test | What it verifies |
|------|-----------------|
| `TestSpriteAtlasLoad` | `sprites.json` parses, all sprite regions valid, all sheets load |
| `TestSpriteAtlasTerrainMapping` | Every terrain ID maps to at least one sprite |
| `TestSpriteAtlasVariantSelection` | Deterministic variant from address seed |
| `TestCompositeTileOutputDimensions` | Output is exactly `renderSize × renderSize` |
| `TestCompositeTileDeterministic` | Same address + seed → identical PNG bytes |
| `TestCompositeTileAllCellsFilled` | No transparent pixels in output (all 100 cells drawn) |
| `TestLeafTileRendering` | Depth-5 tiles render single sprite correctly |
| `TestHTTPTileEndpoint` | GET `/tiles/map2_35` returns 200, content-type image/png |
| `TestHTTPTileCache` | Second request for same tile returns cached bytes |
| `TestHTTPTileInvalidAddress` | Invalid address returns 400 |

### Client Tests (GDScript)

| Test | What it verifies |
|------|-----------------|
| `test_tile_url_construction` | Address → URL formatting correct |
| `test_terrain_color_fallback` | All 14 terrain IDs have a fallback color |
| `test_tile_grid_positioning` | 10×10 grid cells computed correctly for viewport |
| `test_tile_cache_eviction` | Cache respects max size, evicts oldest entries |
