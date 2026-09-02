package models

import (
	"fmt"
	"math"
	"strconv"
	"strings"
)

const (
	MaxDepth        = 5
	ChildrenPerTile = 100
	GridCols        = 10
	GridRows        = 10
	RootAddress     = "map2"
)

type Direction string

const (
	North Direction = "n"
	South Direction = "s"
	East  Direction = "e"
	West  Direction = "w"
)

var ValidDirections = map[Direction]bool{
	North: true, South: true, East: true, West: true,
}

var TierNames = [MaxDepth + 1]string{
	"world", "regional", "area", "district", "block", "tactical",
}

var TierScales = [MaxDepth + 1]string{
	"~200 mi", "~20 mi", "~2 mi", "~1,056 ft", "~106 ft", "~10 ft",
}

type TerrainBias struct {
	Elevation float64
	Moisture  float64
}

var TerrainBiases = map[string]TerrainBias{
	"deep-water":    {-0.5, 0.5},
	"shallow-water": {-0.2, 0.5},
	"beach":         {-0.05, 0.4},
	"plains":        {0.1, 0.3},
	"grassland":     {0.15, 0.5},
	"forest":        {0.2, 0.65},
	"dense-forest":  {0.35, 0.75},
	"hills":         {0.55, 0.4},
	"mountain":      {0.75, 0.3},
	"desert":        {0.2, 0.1},
	"marsh":         {0.05, 0.85},
	"tundra":        {0.3, 0.15},
	"road":          {0.1, 0.3},
}

var AllowedChildTerrains = map[string][]string{
	"deep-water":    {"deep-water", "shallow-water"},
	"shallow-water": {"shallow-water", "deep-water", "beach"},
	"beach":         {"beach", "shallow-water", "plains", "grassland", "marsh"},
	"plains":        {"plains", "grassland", "forest", "hills", "desert", "road"},
	"grassland":     {"grassland", "plains", "forest", "marsh", "road"},
	"forest":        {"forest", "dense-forest", "grassland", "hills", "road"},
	"dense-forest":  {"dense-forest", "forest", "marsh", "hills"},
	"hills":         {"hills", "mountain", "grassland", "forest", "plains"},
	"mountain":      {"mountain", "hills", "tundra"},
	"desert":        {"desert", "plains", "hills"},
	"marsh":         {"marsh", "grassland", "shallow-water", "forest"},
	"tundra":        {"tundra", "hills", "mountain", "plains"},
}

func ValidAddress(address string) bool {
	if address == "" {
		return false
	}
	parts := strings.Split(address, "_")
	if parts[0] != "map2" {
		return false
	}
	if len(parts) > MaxDepth+1 {
		return false
	}
	for _, seg := range parts[1:] {
		if len(seg) != 2 {
			return false
		}
		v, err := strconv.Atoi(seg)
		if err != nil || v < 0 || v >= ChildrenPerTile {
			return false
		}
	}
	return true
}

func IndexToCol(index int) int {
	return index % GridCols
}

func IndexToRow(index int) int {
	return index / GridCols
}

func ColRowToIndex(col, row int) int {
	return row*GridCols + col
}

func TileAddress(parent string, index int) string {
	return fmt.Sprintf("%s_%02d", parent, index)
}

func Depth(address string) int {
	if address == "" {
		return -1
	}
	return strings.Count(address, "_")
}

func Root(address string) string {
	idx := strings.Index(address, "_")
	if idx < 0 {
		return address
	}
	return address[:idx]
}

func Parent(address string) string {
	idx := strings.LastIndex(address, "_")
	if idx < 0 {
		return ""
	}
	return address[:idx]
}

func LastIndex(address string) int {
	idx := strings.LastIndex(address, "_")
	if idx < 0 {
		return -1
	}
	segment := address[idx+1:]
	v, err := strconv.Atoi(segment)
	if err != nil {
		return -1
	}
	return v
}

func SubIndices(address string) []int {
	parts := strings.Split(address, "_")
	if len(parts) <= 1 {
		return nil
	}
	indices := make([]int, len(parts)-1)
	for i, s := range parts[1:] {
		v, _ := strconv.Atoi(s)
		indices[i] = v
	}
	return indices
}

func Child(address string, index int) string {
	if index < 0 || index >= ChildrenPerTile {
		return address
	}
	if Depth(address) >= MaxDepth {
		return address
	}
	return TileAddress(address, index)
}

func Children(address string) []string {
	if Depth(address) >= MaxDepth {
		return nil
	}
	result := make([]string, ChildrenPerTile)
	for i := 0; i < ChildrenPerTile; i++ {
		result[i] = TileAddress(address, i)
	}
	return result
}

func IsAncestor(ancestor, descendant string) bool {
	if ancestor == descendant {
		return false
	}
	return strings.HasPrefix(descendant, ancestor+"_")
}

func TierName(address string) string {
	d := Depth(address)
	if d < 0 || d > MaxDepth {
		return ""
	}
	return TierNames[d]
}

func TierScale(address string) string {
	d := Depth(address)
	if d < 0 || d > MaxDepth {
		return ""
	}
	return TierScales[d]
}

func TotalTilesBelow(depth int) int {
	if depth <= 0 {
		return 1
	}
	return 1 + ChildrenPerTile*TotalTilesBelow(depth-1)
}

func Neighbor(address string, dir Direction) string {
	if address == "" || address == RootAddress {
		return address
	}

	depth := Depth(address)
	if depth < 1 {
		return address
	}

	index := LastIndex(address)
	if index < 0 {
		return address
	}

	col := IndexToCol(index)
	row := IndexToRow(index)

	switch dir {
	case North:
		row--
	case South:
		row++
	case East:
		col++
	case West:
		col--
	}

	if col >= 0 && col < GridCols && row >= 0 && row < GridRows {
		parentAddr := Parent(address)
		return TileAddress(parentAddr, ColRowToIndex(col, row))
	}

	parentAddr := Parent(address)
	neighborParent := Neighbor(parentAddr, dir)

	if neighborParent == parentAddr {
		return address
	}

	switch dir {
	case North:
		row = GridRows - 1
	case South:
		row = 0
	case East:
		col = 0
	case West:
		col = GridCols - 1
	}

	return TileAddress(neighborParent, ColRowToIndex(col, row))
}

func hashCombine(current, value, salt uint64) uint64 {
	const (
		prime1 = 73856093
		prime2 = 19349663
		prime3 = 83492791
		prime4 = 4256249
	)
	h := current ^ (value * prime1)
	h ^= salt * prime2
	h = (h ^ (h >> 16)) * prime3
	h ^= h >> 13
	h *= prime4
	h ^= h >> 16
	return h
}

func SeedForAddress(address string, worldSeed int) uint64 {
	parts := strings.Split(address, "_")
	if len(parts) == 0 {
		return uint64(worldSeed)
	}

	current := uint64(worldSeed)

	rootHash := uint64(0)
	for _, ch := range parts[0] {
		rootHash = hashCombine(rootHash, uint64(ch), 1)
	}
	current = hashCombine(current, rootHash, 0)

	for i, s := range parts[1:] {
		v, _ := strconv.Atoi(s)
		current = hashCombine(current, uint64(v), uint64(i+1))
	}

	return current
}

func seedToFloat(seed uint64, channel int) float64 {
	mixed := seed ^ (uint64(channel) * 2654435761)
	mixed = (mixed ^ (mixed >> 30)) * 0xbf58476d1ce4e5b9
	mixed = (mixed ^ (mixed >> 27)) * 0x94d049bb133111eb
	mixed ^= mixed >> 31
	normalized := float64(mixed&0x7FFFFFFFFFFFFFFF) / float64(0x7FFFFFFFFFFFFFFF)
	return normalized*2.0 - 1.0
}

func classifyTerrain(elevation, moisture float64) string {
	if elevation < -0.3 {
		return "deep-water"
	}
	if elevation < -0.1 {
		return "shallow-water"
	}
	if elevation < 0.0 {
		return "beach"
	}
	if elevation > 0.7 {
		return "mountain"
	}
	if elevation > 0.5 {
		return "hills"
	}
	if elevation > 0.3 {
		if moisture < 0.3 {
			return "desert"
		}
		if moisture > 0.7 {
			return "dense-forest"
		}
		return "forest"
	}
	if moisture < 0.2 {
		return "desert"
	}
	if moisture < 0.4 {
		return "plains"
	}
	if moisture > 0.8 {
		return "marsh"
	}
	if moisture > 0.6 {
		return "forest"
	}
	return "grassland"
}

func lerp(a, b, t float64) float64 {
	return a + (b-a)*t
}

func clampFloat(v, lo, hi float64) float64 {
	return math.Max(lo, math.Min(hi, v))
}

func TerrainForAddress(address string, worldSeed int) string {
	d := Depth(address)
	if d < 0 {
		return ""
	}

	if d == 0 {
		return "plains"
	}

	if d == 1 {
		index := LastIndex(address)
		if index < 0 {
			return "plains"
		}
		col := IndexToCol(index)
		row := IndexToRow(index)
		return worldTerrain(col, row)
	}

	parentAddr := Parent(address)
	parentTerrain := TerrainForAddress(parentAddr, worldSeed)
	seed := SeedForAddress(address, worldSeed)
	elevation := seedToFloat(seed, 0)
	moisture := seedToFloat(seed, 1)
	if bias, ok := TerrainBiases[parentTerrain]; ok {
		elevation = clampFloat(lerp(elevation, bias.Elevation, 0.7), -1.0, 1.0)
		moisture = clampFloat(lerp(moisture, bias.Moisture, 0.7), -1.0, 1.0)
	}
	candidate := classifyTerrain(elevation, moisture)
	if allowed, ok := AllowedChildTerrains[parentTerrain]; ok {
		for _, a := range allowed {
			if candidate == a {
				return candidate
			}
		}
		return allowed[0]
	}
	return candidate
}

var WorldMap = [GridRows][GridCols]string{
	{"deep-water", "shallow-water", "tundra", "mountain", "tundra", "forest", "mountain", "mountain", "tundra", "deep-water"},
	{"deep-water", "mountain", "hills", "plains", "forest", "forest", "hills", "forest", "hills", "mountain"},
	{"shallow-water", "hills", "plains", "grassland", "forest", "dense-forest", "grassland", "forest", "shallow-water", "deep-water"},
	{"deep-water", "shallow-water", "forest", "grassland", "plains", "dense-forest", "forest", "grassland", "forest", "shallow-water"},
	{"deep-water", "hills", "forest", "grassland", "grassland", "dense-forest", "forest", "forest", "shallow-water", "deep-water"},
	{"deep-water", "shallow-water", "forest", "hills", "grassland", "forest", "hills", "shallow-water", "deep-water", "deep-water"},
	{"deep-water", "shallow-water", "hills", "forest", "grassland", "dense-forest", "hills", "shallow-water", "deep-water", "deep-water"},
	{"desert", "deep-water", "shallow-water", "forest", "hills", "forest", "shallow-water", "deep-water", "deep-water", "deep-water"},
	{"deep-water", "deep-water", "deep-water", "shallow-water", "forest", "forest", "shallow-water", "deep-water", "deep-water", "deep-water"},
	{"deep-water", "deep-water", "deep-water", "deep-water", "shallow-water", "shallow-water", "deep-water", "deep-water", "deep-water", "deep-water"},
}

func worldTerrain(col, row int) string {
	if row < 0 || row >= GridRows || col < 0 || col >= GridCols {
		return "deep-water"
	}
	return WorldMap[row][col]
}
