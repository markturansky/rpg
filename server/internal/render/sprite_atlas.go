package render

import (
	"encoding/json"
	"fmt"
	"image"
	"image/draw"
	"image/png"
	"os"
	"path/filepath"

	"rpg/internal/models"
)

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

func (r SpriteRef) Region() image.Rectangle {
	return image.Rect(r.X, r.Y, r.X+r.W, r.Y+r.H)
}

type SpriteAtlas struct {
	sheets     []*image.RGBA
	sprites    map[string]SpriteRef
	terrainMap map[string][]SpriteRef
}

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

func NewSpriteAtlas(spritesDir string) (*SpriteAtlas, error) {
	jsonPath := filepath.Join(spritesDir, "sprites.json")
	data, err := os.ReadFile(jsonPath)
	if err != nil {
		return nil, fmt.Errorf("failed to read sprites.json: %w", err)
	}

	var index SpriteIndex
	if err := json.Unmarshal(data, &index); err != nil {
		return nil, fmt.Errorf("failed to parse sprites.json: %w", err)
	}

	atlas := &SpriteAtlas{
		sheets:  make([]*image.RGBA, len(index.Sheets)),
		sprites: make(map[string]SpriteRef),
	}

	for i, sheet := range index.Sheets {
		sheetPath := filepath.Join(spritesDir, sheet.File)
		img, err := loadPNG(sheetPath)
		if err != nil {
			return nil, fmt.Errorf("failed to load sheet %q: %w", sheet.File, err)
		}
		atlas.sheets[i] = img

		bounds := img.Bounds()
		for _, sprite := range sheet.Sprites {
			spriteRect := image.Rect(sprite.X, sprite.Y, sprite.X+sprite.W, sprite.Y+sprite.H)
			if !spriteRect.In(bounds) {
				return nil, fmt.Errorf("sprite %q region %v exceeds sheet %q bounds %v", sprite.Name, spriteRect, sheet.File, bounds)
			}
			atlas.sprites[sprite.Name] = SpriteRef{
				SheetIndex: i,
				Name:       sprite.Name,
				X:          sprite.X,
				Y:          sprite.Y,
				W:          sprite.W,
				H:          sprite.H,
			}
		}
	}

	atlas.terrainMap = make(map[string][]SpriteRef)
	for terrainID, spriteNames := range terrainSpriteMapping {
		var refs []SpriteRef
		for _, name := range spriteNames {
			if ref, ok := atlas.sprites[name]; ok {
				refs = append(refs, ref)
			}
		}
		if len(refs) > 0 {
			atlas.terrainMap[terrainID] = refs
		}
	}

	return atlas, nil
}

func (a *SpriteAtlas) SpriteForTerrain(terrainID, address string, worldSeed, depth int) SpriteRef {
	refs, ok := a.terrainMap[terrainID]
	if !ok || len(refs) == 0 {
		return a.fallbackSprite()
	}
	seed := models.SeedForAddress(address, worldSeed)
	return refs[int(seed%uint64(len(refs)))]
}

func (a *SpriteAtlas) fallbackSprite() SpriteRef {
	if ref, ok := a.sprites["grassland-plain"]; ok {
		return ref
	}
	for _, ref := range a.sprites {
		return ref
	}
	return SpriteRef{}
}

func loadPNG(path string) (*image.RGBA, error) {
	f, err := os.Open(path)
	if err != nil {
		return nil, err
	}
	defer f.Close()

	img, err := png.Decode(f)
	if err != nil {
		return nil, err
	}

	if rgba, ok := img.(*image.RGBA); ok {
		return rgba, nil
	}

	bounds := img.Bounds()
	rgba := image.NewRGBA(bounds)
	draw.Draw(rgba, bounds, img, bounds.Min, draw.Src)
	return rgba, nil
}

func TileAddressForTest(parent string, index int) string {
	return models.TileAddress(parent, index)
}
