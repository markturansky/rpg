package render

import (
	"bytes"
	"fmt"
	"image"
	"image/png"
	"sync"

	"rpg/internal/models"

	xdraw "golang.org/x/image/draw"
)

type TileRenderer struct {
	atlas      *SpriteAtlas
	renderSize int
	worldSeed  int
	cache      map[string][]byte
	mu         sync.RWMutex
}

func NewTileRenderer(atlas *SpriteAtlas, worldSeed, renderSize int) *TileRenderer {
	return &TileRenderer{
		atlas:      atlas,
		worldSeed:  worldSeed,
		renderSize: renderSize,
		cache:      make(map[string][]byte),
	}
}

func (r *TileRenderer) CompositeTile(address string) *image.RGBA {
	dst := image.NewRGBA(image.Rect(0, 0, r.renderSize, r.renderSize))
	cellSize := r.renderSize / 10

	for row := 0; row < 10; row++ {
		for col := 0; col < 10; col++ {
			childIndex := row*10 + col
			childAddr := models.Child(address, childIndex)
			terrainID := models.TerrainForAddress(childAddr, r.worldSeed)
			depth := models.Depth(childAddr)
			ref := r.atlas.SpriteForTerrain(terrainID, childAddr, r.worldSeed, depth)
			srcRect := ref.Region()
			dstRect := image.Rect(col*cellSize, row*cellSize, (col+1)*cellSize, (row+1)*cellSize)
			xdraw.CatmullRom.Scale(dst, dstRect, r.atlas.sheets[ref.SheetIndex], srcRect, xdraw.Over, nil)
		}
	}
	return dst
}

func (r *TileRenderer) RenderLeaf(address string) *image.RGBA {
	dst := image.NewRGBA(image.Rect(0, 0, r.renderSize, r.renderSize))
	terrainID := models.TerrainForAddress(address, r.worldSeed)
	ref := r.atlas.SpriteForTerrain(terrainID, address, r.worldSeed, 5)
	srcRect := ref.Region()
	xdraw.CatmullRom.Scale(dst, dst.Bounds(), r.atlas.sheets[ref.SheetIndex], srcRect, xdraw.Over, nil)
	return dst
}

func (r *TileRenderer) RenderTile(address string) ([]byte, error) {
	r.mu.RLock()
	if cached, ok := r.cache[address]; ok {
		r.mu.RUnlock()
		return cached, nil
	}
	r.mu.RUnlock()

	depth := models.Depth(address)
	var img *image.RGBA
	if depth >= models.MaxDepth {
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
