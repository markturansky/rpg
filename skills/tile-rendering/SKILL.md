---
name: tile-rendering
description: "Server-side sprite compositing and HTTP tile endpoint. Loads sprite sheets + sprites.json at startup, composites 10x10 tile grids on demand, serves PNG via GET /tiles/{address}. Triggers on: tile render, sprite atlas, composite, tile image, tile endpoint, tile HTTP."
---

# Tile Rendering Skill

> Implements `tile_rendering.spec.md` — server-side sprite compositing and HTTP tile serving.

## Spec

`specs/tile_rendering.spec.md`

## Code Target

`server/internal/render/` (new package) + HTTP endpoint in `server/cmd/rpg-server/main.go`

## Dependencies

- `server/internal/models/tile_address.go` — address parsing, depth, terrain generation
- `sprites/sprites.json` — sprite index (145 sprites across 3 sheets)
- `sprites/*.png` — three 1984×2164 RGBA sprite sheets
- Go stdlib: `image`, `image/draw`, `image/png`, `encoding/json`, `sync`
- `golang.org/x/image/draw` — for `CatmullRom` scaling (add to go.mod)

## Package Layout

```
server/internal/render/
├── sprite_atlas.go        # SpriteAtlas: load sprites.json + PNG sheets, terrain mapping
├── sprite_atlas_test.go   # Tests: load, terrain mapping, variant selection
├── tile_renderer.go       # TileRenderer: CompositeTile, RenderLeaf, cache
├── tile_renderer_test.go  # Tests: output dimensions, determinism, all cells filled
├── handler.go             # HTTP handler: GET /tiles/{address}?size=256
└── handler_test.go        # Tests: endpoint, cache, invalid address
```

## Structs

### SpriteAtlas

```go
type SpriteEntry struct {
    Name        string `json:"name"`
    Category    string `json:"category"`
    Subcategory string `json:"subcategory"`
    X           int    `json:"x"`
    Y           int    `json:"y"`
    W           int    `json:"w"`
    H           int    `json:"h"`
}

type SheetData struct {
    File        string        `json:"file"`
    ImageWidth  int           `json:"image_width"`
    ImageHeight int           `json:"image_height"`
    Description string        `json:"description"`
    Sprites     []SpriteEntry `json:"sprites"`
}

type SpriteIndex struct {
    Version     int         `json:"version"`
    Description string      `json:"description"`
    Sheets      []SheetData `json:"sheets"`
}

type SpriteRef struct {
    SheetIndex int
    Name       string
    X, Y, W, H int
}

type SpriteAtlas struct {
    sheets     []*image.RGBA
    sprites    map[string]SpriteRef
    terrainMap map[string][]SpriteRef
}
```

### TileRenderer

```go
type TileRenderer struct {
    atlas      *SpriteAtlas
    renderSize int
    cache      map[string][]byte
    mu         sync.RWMutex
    worldSeed  int
}
```

## Construction

### NewSpriteAtlas(spritesDir string) (*SpriteAtlas, error)

1. Read `{spritesDir}/sprites.json`, unmarshal into `SpriteIndex`
2. For each sheet in `SpriteIndex.Sheets`:
   a. Open `{spritesDir}/{sheet.File}`
   b. Decode PNG into `image.Image`
   c. Convert to `*image.RGBA` if needed
   d. Validate all sprite regions fit within sheet dimensions
3. Build `sprites` map: name → SpriteRef (with sheet index)
4. Build `terrainMap`: terrain ID → []SpriteRef using the mapping table from spec

### NewTileRenderer(atlas *SpriteAtlas, worldSeed, renderSize int) *TileRenderer

1. Store atlas, worldSeed, renderSize
2. Initialize empty cache map

## Terrain-to-Sprite Mapping

Defined as a Go map literal in `sprite_atlas.go`. Source of truth is `tile_rendering.spec.md` §Terrain-to-Sprite Mapping.

```go
var terrainSpriteMapping = map[string][]string{
    "deep-water":    {"water-deep", "terrain-ocean-deep"},
    "shallow-water": {"terrain-ocean-shallow", "terrain-coastline-a", "terrain-coastline-b"},
    "beach":         {"sand-beach"},
    "plains":        {"grassland-plain", "grassland-rocky", "terrain-grassland-a", "terrain-grassland-b", "terrain-grassland-c", "terrain-grassland-d"},
    "grassland":     {"terrain-grassland-a", "terrain-grassland-b", "terrain-grassland-c", "terrain-grassland-d"},
    "forest":        {"forest-deciduous", "forest-conifer", "forest-bush", "terrain-forest-deciduous", "terrain-forest-conifer", "terrain-forest-mixed", "terrain-forest-edge"},
    "dense-forest":  {"forest-dark", "forest-palm", "forest-dense-canopy", "forest-mixed-dense", "forest-ancient"},
    "hills":         {"hills-grassy", "hills-contour", "hills-desert", "hills-rocky", "terrain-hills-rolling", "terrain-hills-contour", "terrain-hills-rocky"},
    "mountain":      {"mountain-range", "mountain-snow-peak", "mountain-volcano", "mountain-large", "terrain-mountain-range", "terrain-mountain-peak", "terrain-mountain-snow", "terrain-cliff-face"},
    "desert":        {"sand-desert", "hills-desert"},
    "marsh":         {"terrain-swamp-fungal", "terrain-swamp-murky", "water-river-forest"},
    "tundra":        {"terrain-mountain-snow"},
    "road":          {"road-cobblestone", "road-stone-paved", "road-dirt-straight", "road-dirt-worn"},
    "river":         {"terrain-river-bend", "terrain-lake-pond"},
}
```

## Variant Selection

Deterministic variant from address:

```go
func (a *SpriteAtlas) SpriteForTerrain(terrainID, address string, depth int) SpriteRef {
    variants := a.terrainMap[terrainID]
    if len(variants) == 0 {
        return a.fallbackSprite()
    }
    seed := models.SeedForAddress(address)
    return variants[seed % len(variants)]
}
```

Uses `models.SeedForAddress()` from `tile_address.go` (FNV hash of address string).

## Compositing Algorithm

### CompositeTile (depth 0–4)

```go
func (r *TileRenderer) CompositeTile(address string) *image.RGBA {
    dst := image.NewRGBA(image.Rect(0, 0, r.renderSize, r.renderSize))
    cellSize := r.renderSize / 10

    for row := 0; row < 10; row++ {
        for col := 0; col < 10; col++ {
            childIndex := row*10 + col
            childAddr := models.ChildAddress(address, childIndex)
            terrainID := models.TerrainForAddress(childAddr, r.worldSeed)
            depth := models.DepthFromAddress(childAddr)
            ref := r.atlas.SpriteForTerrain(terrainID, childAddr, depth)
            srcRect := image.Rect(ref.X, ref.Y, ref.X+ref.W, ref.Y+ref.H)
            dstRect := image.Rect(col*cellSize, row*cellSize, (col+1)*cellSize, (row+1)*cellSize)
            draw.CatmullRom.Scale(dst, dstRect, r.atlas.sheets[ref.SheetIndex], srcRect, draw.Over, nil)
        }
    }
    return dst
}
```

### RenderLeaf (depth 5)

```go
func (r *TileRenderer) RenderLeaf(address string) *image.RGBA {
    dst := image.NewRGBA(image.Rect(0, 0, r.renderSize, r.renderSize))
    terrainID := models.TerrainForAddress(address, r.worldSeed)
    ref := r.atlas.SpriteForTerrain(terrainID, address, 5)
    srcRect := image.Rect(ref.X, ref.Y, ref.X+ref.W, ref.Y+ref.H)
    draw.CatmullRom.Scale(dst, dst.Bounds(), r.atlas.sheets[ref.SheetIndex], srcRect, draw.Over, nil)
    return dst
}
```

### RenderTile (dispatch)

```go
func (r *TileRenderer) RenderTile(address string) ([]byte, error) {
    r.mu.RLock()
    if cached, ok := r.cache[address]; ok {
        r.mu.RUnlock()
        return cached, nil
    }
    r.mu.RUnlock()

    depth := models.DepthFromAddress(address)
    var img *image.RGBA
    if depth >= 5 {
        img = r.RenderLeaf(address)
    } else {
        img = r.CompositeTile(address)
    }

    var buf bytes.Buffer
    if err := png.Encode(&buf, img); err != nil {
        return nil, fmt.Errorf("failed to encode tile PNG: %w", err)
    }

    encoded := buf.Bytes()
    r.mu.Lock()
    r.cache[address] = encoded
    r.mu.Unlock()

    return encoded, nil
}
```

## HTTP Handler

### Route

```
GET /tiles/{address}?size={renderSize}
```

Registered in `main.go` alongside `/ws` and `/health`.

### Handler

```go
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
```

### main.go Wiring

Add to `main.go` after service creation:

```go
spritesDir := filepath.Join("..", "..", "sprites")
atlas, err := render.NewSpriteAtlas(spritesDir)
if err != nil {
    log.Fatalf("[STARTUP] failed to load sprite atlas: %v", err)
}
renderer := render.NewTileRenderer(atlas, worldSeed, 256)
mux.HandleFunc("GET /tiles/{address...}", render.NewTileHandler(renderer))
```

## Required Model Functions

The render package depends on these functions from `models/tile_address.go`:

| Function | Signature | Purpose |
|----------|-----------|---------|
| `ChildAddress` | `func ChildAddress(parent string, index int) string` | Build child address |
| `DepthFromAddress` | `func DepthFromAddress(address string) int` | Count depth segments |
| `TerrainForAddress` | `func TerrainForAddress(address string, worldSeed int) string` | Deterministic terrain |
| `SeedForAddress` | `func SeedForAddress(address string) int` | FNV hash for variant selection |
| `ValidAddress` | `func ValidAddress(address string) bool` | Validate address format |

If any of these are missing, they must be added to `tile_address.go` with tests.

## Testing Requirements

### sprite_atlas_test.go

| Test | Assertion |
|------|-----------|
| `TestSpriteAtlasLoad` | All 3 sheets loaded, all 145 sprites parsed, regions within bounds |
| `TestSpriteAtlasTerrainMapping` | Every terrain ID in terrainSpriteMapping has ≥1 valid sprite |
| `TestSpriteAtlasVariantSelection` | Same address → same variant; different addresses → different variants (statistical) |
| `TestSpriteAtlasMissingTerrain` | Unknown terrain ID returns fallback sprite |

### tile_renderer_test.go

| Test | Assertion |
|------|-----------|
| `TestCompositeTileOutputDimensions` | Output is exactly renderSize × renderSize |
| `TestCompositeTileDeterministic` | Same address + seed → identical PNG bytes |
| `TestCompositeTileAllCellsFilled` | No fully-transparent pixels in output |
| `TestLeafTileRendering` | Depth-5 tile renders correctly sized output |

### handler_test.go

| Test | Assertion |
|------|-----------|
| `TestHTTPTileEndpoint` | GET `/tiles/map2_35` returns 200 + content-type image/png |
| `TestHTTPTileCache` | Second GET returns same bytes (cache hit) |
| `TestHTTPTileInvalidAddress` | Invalid address returns 400 |

## Reconciliation Checklist

```
[ ] sprites.json loads without error
[ ] All 3 PNG sheets load and decode
[ ] All 145 sprite regions are within sheet bounds
[ ] Every terrain ID maps to at least one sprite
[ ] Variant selection is deterministic per address
[ ] CompositeTile produces renderSize × renderSize output
[ ] CompositeTile is deterministic (same input → same output)
[ ] No transparent gaps in composited tiles
[ ] Leaf tiles render single sprite correctly
[ ] HTTP endpoint returns valid PNG with correct headers
[ ] Cache serves identical bytes on repeat requests
[ ] Invalid addresses return 400
[ ] main.go wires atlas + renderer + HTTP route
[ ] All tests pass via ./test.sh
```
