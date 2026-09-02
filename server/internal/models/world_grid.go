package models

const (
	WorldGridSize = 100
	WorldSeed     = 42
)

type SpriteInfo struct {
	Name string `json:"name"`
	X    int    `json:"x"`
	Y    int    `json:"y"`
	W    int    `json:"w"`
	H    int    `json:"h"`
}

type WorldGridData struct {
	Width   int          `json:"width"`
	Height  int          `json:"height"`
	Sprites []SpriteInfo `json:"sprites"`
	Grid    [][]int      `json:"grid"`
}

var TerrainSprites = []SpriteInfo{
	{Name: "terrain-grassland-a", X: 34, Y: 1401, W: 205, H: 233},
	{Name: "terrain-grassland-b", X: 269, Y: 1401, W: 207, H: 233},
	{Name: "terrain-grassland-c", X: 505, Y: 1401, W: 211, H: 233},
	{Name: "terrain-grassland-d", X: 747, Y: 1401, W: 212, H: 233},
	{Name: "terrain-coastline-a", X: 1025, Y: 1401, W: 211, H: 233},
	{Name: "terrain-coastline-b", X: 1268, Y: 1401, W: 210, H: 233},
	{Name: "terrain-ocean-deep", X: 1509, Y: 1401, W: 209, H: 233},
	{Name: "terrain-ocean-shallow", X: 1744, Y: 1401, W: 207, H: 233},
	{Name: "terrain-river-bend", X: 33, Y: 1662, W: 206, H: 228},
	{Name: "terrain-lake-pond", X: 270, Y: 1662, W: 206, H: 228},
	{Name: "terrain-swamp-fungal", X: 505, Y: 1662, W: 210, H: 228},
	{Name: "terrain-swamp-murky", X: 747, Y: 1662, W: 212, H: 228},
	{Name: "terrain-forest-deciduous", X: 1025, Y: 1662, W: 211, H: 228},
	{Name: "terrain-forest-conifer", X: 1268, Y: 1662, W: 210, H: 228},
	{Name: "terrain-forest-mixed", X: 1509, Y: 1662, W: 209, H: 228},
	{Name: "terrain-forest-edge", X: 1744, Y: 1662, W: 207, H: 228},
	{Name: "terrain-hills-rolling", X: 34, Y: 1918, W: 206, H: 228},
	{Name: "terrain-hills-contour", X: 270, Y: 1918, W: 206, H: 228},
	{Name: "terrain-hills-rocky", X: 505, Y: 1918, W: 210, H: 228},
	{Name: "terrain-mountain-range", X: 747, Y: 1918, W: 212, H: 228},
	{Name: "terrain-mountain-peak", X: 1025, Y: 1918, W: 211, H: 228},
	{Name: "terrain-mountain-snow", X: 1268, Y: 1918, W: 210, H: 228},
	{Name: "terrain-cliff-face", X: 1509, Y: 1918, W: 209, H: 228},
	{Name: "terrain-cave-entrance", X: 1744, Y: 1918, W: 207, H: 228},
}

var terrainToSpriteIndices = map[string][]int{
	"deep-water":    {6},
	"shallow-water": {7, 4, 5},
	"beach":         {4, 5},
	"plains":        {0, 1},
	"grassland":     {0, 1, 2, 3},
	"forest":        {12, 13, 14, 15},
	"dense-forest":  {12, 14},
	"hills":         {16, 17, 18},
	"mountain":      {19, 20, 22},
	"desert":        {3, 18},
	"marsh":         {10, 11},
	"tundra":        {21},
	"road":          {0, 1},
	"river":         {8, 9},
}

func spriteIndexForTerrain(terrainID string, seed uint64) int {
	indices, ok := terrainToSpriteIndices[terrainID]
	if !ok || len(indices) == 0 {
		return 0
	}
	return indices[int(seed%uint64(len(indices)))]
}

func GenerateWorldGrid() *WorldGridData {
	grid := make([][]int, WorldGridSize)
	for y := 0; y < WorldGridSize; y++ {
		grid[y] = make([]int, WorldGridSize)
		parentRow := y / GridRows
		childRow := y % GridRows
		for x := 0; x < WorldGridSize; x++ {
			parentCol := x / GridCols
			childCol := x % GridCols
			parentTerrain := worldTerrain(parentCol, parentRow)
			childIndex := childRow*GridCols + childCol
			childAddr := TileAddress(TileAddress(RootAddress, parentRow*GridCols+parentCol), childIndex)
			childTerrain := TerrainForAddress(childAddr, WorldSeed)
			_ = parentTerrain
			seed := SeedForAddress(childAddr, WorldSeed)
			grid[y][x] = spriteIndexForTerrain(childTerrain, seed)
		}
	}

	return &WorldGridData{
		Width:   WorldGridSize,
		Height:  WorldGridSize,
		Sprites: TerrainSprites,
		Grid:    grid,
	}
}
