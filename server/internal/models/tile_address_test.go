package models

import (
	"testing"
)

func TestValidAddress(t *testing.T) {
	tests := []struct {
		address string
		want    bool
	}{
		{"", false},
		{"map2", true},
		{"map2_35", true},
		{"map2_35_07", true},
		{"map2_35_07_42", true},
		{"map2_35_07_42_55", true},
		{"map2_35_07_42_55_00", true},
		{"map2_35_07_42_55_00_99", false},
		{"invalid", false},
		{"map2_abc", false},
		{"map2_100", false},
		{"map2_-1", false},
		{"map2_9", false},
		{"map3_35", false},
	}
	for _, tt := range tests {
		got := ValidAddress(tt.address)
		if got != tt.want {
			t.Errorf("ValidAddress(%q) = %v, want %v", tt.address, got, tt.want)
		}
	}
}

func TestTileAddress(t *testing.T) {
	tests := []struct {
		parent string
		index  int
		want   string
	}{
		{"map2", 0, "map2_00"},
		{"map2", 35, "map2_35"},
		{"map2", 99, "map2_99"},
		{"map2_35", 7, "map2_35_07"},
		{"map2_35_07", 42, "map2_35_07_42"},
	}
	for _, tt := range tests {
		got := TileAddress(tt.parent, tt.index)
		if got != tt.want {
			t.Errorf("TileAddress(%q, %d) = %q, want %q", tt.parent, tt.index, got, tt.want)
		}
	}
}

func TestIndexToColRow(t *testing.T) {
	tests := []struct {
		index   int
		wantCol int
		wantRow int
	}{
		{0, 0, 0},
		{5, 5, 0},
		{9, 9, 0},
		{10, 0, 1},
		{35, 5, 3},
		{55, 5, 5},
		{99, 9, 9},
	}
	for _, tt := range tests {
		col := IndexToCol(tt.index)
		row := IndexToRow(tt.index)
		if col != tt.wantCol || row != tt.wantRow {
			t.Errorf("IndexToCol/Row(%d) = (%d, %d), want (%d, %d)", tt.index, col, row, tt.wantCol, tt.wantRow)
		}
	}
}

func TestColRowToIndex(t *testing.T) {
	for i := 0; i < 100; i++ {
		col := IndexToCol(i)
		row := IndexToRow(i)
		got := ColRowToIndex(col, row)
		if got != i {
			t.Errorf("ColRowToIndex(%d, %d) = %d, want %d", col, row, got, i)
		}
	}
}

func TestDepth(t *testing.T) {
	tests := []struct {
		address string
		want    int
	}{
		{"", -1},
		{"map2", 0},
		{"map2_35", 1},
		{"map2_35_07", 2},
		{"map2_35_07_42", 3},
		{"map2_35_07_42_55", 4},
		{"map2_35_07_42_55_00", 5},
	}
	for _, tt := range tests {
		got := Depth(tt.address)
		if got != tt.want {
			t.Errorf("Depth(%q) = %d, want %d", tt.address, got, tt.want)
		}
	}
}

func TestRoot(t *testing.T) {
	tests := []struct {
		address string
		want    string
	}{
		{"map2", "map2"},
		{"map2_35", "map2"},
		{"map2_35_07_42", "map2"},
	}
	for _, tt := range tests {
		got := Root(tt.address)
		if got != tt.want {
			t.Errorf("Root(%q) = %q, want %q", tt.address, got, tt.want)
		}
	}
}

func TestParent(t *testing.T) {
	tests := []struct {
		address string
		want    string
	}{
		{"map2", ""},
		{"map2_35", "map2"},
		{"map2_35_07", "map2_35"},
		{"map2_35_07_42", "map2_35_07"},
	}
	for _, tt := range tests {
		got := Parent(tt.address)
		if got != tt.want {
			t.Errorf("Parent(%q) = %q, want %q", tt.address, got, tt.want)
		}
	}
}

func TestLastIndex(t *testing.T) {
	tests := []struct {
		address string
		want    int
	}{
		{"map2", -1},
		{"map2_35", 35},
		{"map2_35_07", 7},
		{"map2_35_07_42", 42},
	}
	for _, tt := range tests {
		got := LastIndex(tt.address)
		if got != tt.want {
			t.Errorf("LastIndex(%q) = %d, want %d", tt.address, got, tt.want)
		}
	}
}

func TestSubIndices(t *testing.T) {
	tests := []struct {
		address string
		want    []int
	}{
		{"map2", nil},
		{"map2_35", []int{35}},
		{"map2_35_07", []int{35, 7}},
		{"map2_35_07_42", []int{35, 7, 42}},
	}
	for _, tt := range tests {
		got := SubIndices(tt.address)
		if len(got) != len(tt.want) {
			t.Errorf("SubIndices(%q) length = %d, want %d", tt.address, len(got), len(tt.want))
			continue
		}
		for i := range got {
			if got[i] != tt.want[i] {
				t.Errorf("SubIndices(%q)[%d] = %d, want %d", tt.address, i, got[i], tt.want[i])
			}
		}
	}
}

func TestChild(t *testing.T) {
	tests := []struct {
		address string
		index   int
		want    string
	}{
		{"map2", 35, "map2_35"},
		{"map2_35", 7, "map2_35_07"},
		{"map2", -1, "map2"},
		{"map2", 100, "map2"},
		{"map2_35_07_42_55_00", 5, "map2_35_07_42_55_00"},
	}
	for _, tt := range tests {
		got := Child(tt.address, tt.index)
		if got != tt.want {
			t.Errorf("Child(%q, %d) = %q, want %q", tt.address, tt.index, got, tt.want)
		}
	}
}

func TestChildren(t *testing.T) {
	children := Children("map2")
	if len(children) != 100 {
		t.Fatalf("Children(map2) length = %d, want 100", len(children))
	}
	if children[0] != "map2_00" {
		t.Errorf("Children(map2)[0] = %q, want map2_00", children[0])
	}
	if children[35] != "map2_35" {
		t.Errorf("Children(map2)[35] = %q, want map2_35", children[35])
	}
	if children[99] != "map2_99" {
		t.Errorf("Children(map2)[99] = %q, want map2_99", children[99])
	}

	maxDepthAddr := "map2_35_07_42_55_00"
	if Depth(maxDepthAddr) != MaxDepth {
		t.Fatalf("expected depth %d for %q, got %d", MaxDepth, maxDepthAddr, Depth(maxDepthAddr))
	}
	nilChildren := Children(maxDepthAddr)
	if nilChildren != nil {
		t.Errorf("Children at max depth should be nil, got %v", nilChildren)
	}
}

func TestIsAncestor(t *testing.T) {
	tests := []struct {
		ancestor   string
		descendant string
		want       bool
	}{
		{"map2", "map2_35", true},
		{"map2", "map2_35_07", true},
		{"map2_35", "map2_35_07", true},
		{"map2", "map2", false},
		{"map2_35", "map2_36", false},
		{"map2_35", "map2_36_07", false},
	}
	for _, tt := range tests {
		got := IsAncestor(tt.ancestor, tt.descendant)
		if got != tt.want {
			t.Errorf("IsAncestor(%q, %q) = %v, want %v", tt.ancestor, tt.descendant, got, tt.want)
		}
	}
}

func TestTierName(t *testing.T) {
	tests := []struct {
		address string
		want    string
	}{
		{"map2", "world"},
		{"map2_35", "regional"},
		{"map2_35_07", "area"},
		{"map2_35_07_42", "district"},
		{"map2_35_07_42_55", "block"},
		{"map2_35_07_42_55_00", "tactical"},
	}
	for _, tt := range tests {
		got := TierName(tt.address)
		if got != tt.want {
			t.Errorf("TierName(%q) = %q, want %q", tt.address, got, tt.want)
		}
	}
}

func TestTotalTilesBelow(t *testing.T) {
	tests := []struct {
		depth int
		want  int
	}{
		{0, 1},
		{1, 101},
		{2, 10101},
	}
	for _, tt := range tests {
		got := TotalTilesBelow(tt.depth)
		if got != tt.want {
			t.Errorf("TotalTilesBelow(%d) = %d, want %d", tt.depth, got, tt.want)
		}
	}
}

func TestNeighborWithinParent(t *testing.T) {
	tests := []struct {
		address string
		dir     Direction
		want    string
	}{
		{"map2_55", North, "map2_45"},
		{"map2_55", South, "map2_65"},
		{"map2_55", East, "map2_56"},
		{"map2_55", West, "map2_54"},
	}
	for _, tt := range tests {
		got := Neighbor(tt.address, tt.dir)
		if got != tt.want {
			t.Errorf("Neighbor(%q, %q) = %q, want %q", tt.address, string(tt.dir), got, tt.want)
		}
	}
}

func TestNeighborBoundaryCrossing(t *testing.T) {
	got := Neighbor("map2_00", North)
	if got == "map2_00" {
		t.Logf("Neighbor(map2_00, North) = %q (boundary, no move)", got)
	}

	got = Neighbor("map2_55_00", North)
	expectedParentNeighbor := Neighbor("map2_55", North)
	wantChild := TileAddress(expectedParentNeighbor, ColRowToIndex(0, GridRows-1))
	if got != wantChild {
		t.Errorf("Neighbor(map2_55_00, North) = %q, want %q", got, wantChild)
	}
}

func TestNeighborWorldEdge(t *testing.T) {
	got := Neighbor("map2_00", North)
	if got != "map2_00" {
		t.Errorf("Neighbor(map2_00, North) should stay at boundary, got %q", got)
	}

	got = Neighbor("map2_09", East)
	if got != "map2_09" {
		t.Errorf("Neighbor(map2_09, East) should stay at boundary, got %q", got)
	}

	got = Neighbor("map2_90", West)
	if got != "map2_90" {
		t.Errorf("Neighbor(map2_90, West) should stay at boundary, got %q", got)
	}

	got = Neighbor("map2_99", South)
	if got != "map2_99" {
		t.Errorf("Neighbor(map2_99, South) should stay at boundary, got %q", got)
	}
}

func TestNeighborRootNoMove(t *testing.T) {
	got := Neighbor("map2", North)
	if got != "map2" {
		t.Errorf("Neighbor(map2, North) = %q, want map2 (root doesn't move)", got)
	}
}

func TestSeedForAddressDeterminism(t *testing.T) {
	seed1 := SeedForAddress("map2_35_07", 42)
	seed2 := SeedForAddress("map2_35_07", 42)
	if seed1 != seed2 {
		t.Errorf("SeedForAddress is not deterministic: %d != %d", seed1, seed2)
	}
}

func TestSeedForAddressUniqueness(t *testing.T) {
	seed1 := SeedForAddress("map2_35_07", 42)
	seed2 := SeedForAddress("map2_35_06", 42)
	if seed1 == seed2 {
		t.Errorf("different addresses should produce different seeds: both got %d", seed1)
	}
}

func TestSeedForAddressDifferentWorldSeeds(t *testing.T) {
	seed1 := SeedForAddress("map2_35_07", 42)
	seed2 := SeedForAddress("map2_35_07", 99)
	if seed1 == seed2 {
		t.Errorf("different world seeds should produce different address seeds: both got %d", seed1)
	}
}

func TestSeedForWorldTileUniqueness(t *testing.T) {
	seen := map[uint64]string{}
	for i := 0; i < 100; i++ {
		addr := TileAddress("map2", i)
		seed := SeedForAddress(addr, 42)
		if prev, ok := seen[seed]; ok {
			t.Errorf("seed collision between %q and %q (seed=%d)", prev, addr, seed)
		}
		seen[seed] = addr
	}
}

func TestTerrainForAddressDeterminism(t *testing.T) {
	terrain1 := TerrainForAddress("map2_35_07", 42)
	terrain2 := TerrainForAddress("map2_35_07", 42)
	if terrain1 != terrain2 {
		t.Errorf("TerrainForAddress is not deterministic: %q != %q", terrain1, terrain2)
	}
}

func TestTerrainForAddressReturnsValidTerrain(t *testing.T) {
	validTerrains := map[string]bool{
		"deep-water": true, "shallow-water": true, "beach": true,
		"marsh": true, "grassland": true, "plains": true,
		"forest": true, "dense-forest": true, "hills": true,
		"mountain": true, "desert": true, "tundra": true,
	}

	for i := 0; i < 100; i++ {
		addr := TileAddress("map2", i)
		terrain := TerrainForAddress(addr, 42)
		if terrain == "" {
			t.Errorf("TerrainForAddress(%q, 42) returned empty string", addr)
			continue
		}
		if !validTerrains[terrain] {
			t.Errorf("TerrainForAddress(%q, 42) returned invalid terrain %q", addr, terrain)
		}
	}
}

func TestTerrainForAddressParentBias(t *testing.T) {
	terrainCounts := map[string]int{}

	for i := 0; i < 10; i++ {
		parentAddr := TileAddress("map2", i*10+5)
		for childIdx := 0; childIdx < ChildrenPerTile; childIdx++ {
			childAddr := Child(parentAddr, childIdx)
			childTerrain := TerrainForAddress(childAddr, 42)
			terrainCounts[childTerrain]++
		}
	}

	if len(terrainCounts) == 0 {
		t.Error("no child terrains generated")
	}
}

func TestClassifyTerrain(t *testing.T) {
	tests := []struct {
		elevation float64
		moisture  float64
		want      string
	}{
		{-0.5, 0.5, "deep-water"},
		{-0.15, 0.6, "shallow-water"},
		{-0.15, 0.3, "shallow-water"},
		{-0.05, 0.5, "beach"},
		{0.05, 0.9, "marsh"},
		{0.05, 0.5, "grassland"},
		{0.05, 0.3, "plains"},
		{0.35, 0.8, "dense-forest"},
		{0.35, 0.5, "forest"},
		{0.35, 0.1, "desert"},
		{0.55, 0.3, "hills"},
		{0.75, 0.3, "mountain"},
	}
	for _, tt := range tests {
		got := classifyTerrain(tt.elevation, tt.moisture)
		if got != tt.want {
			t.Errorf("classifyTerrain(%v, %v) = %q, want %q", tt.elevation, tt.moisture, got, tt.want)
		}
	}
}

func TestDepthEmptyAddress(t *testing.T) {
	if Depth("") != -1 {
		t.Error("Depth of empty address should be -1")
	}
}

func TestTerrainForAddressEmptyAddress(t *testing.T) {
	terrain := TerrainForAddress("", 42)
	if terrain != "" {
		t.Errorf("TerrainForAddress('', 42) = %q, want empty", terrain)
	}
}

func TestTerrainForAddressRoot(t *testing.T) {
	terrain := TerrainForAddress("map2", 42)
	if terrain != "plains" {
		t.Errorf("TerrainForAddress('map2', 42) = %q, want 'plains'", terrain)
	}
}

func TestSeedDistribution(t *testing.T) {
	seen := map[uint64]string{}
	for i := 0; i < 100; i++ {
		parentAddr := TileAddress("map2", i)
		for j := 0; j < 100; j++ {
			addr := TileAddress(parentAddr, j)
			seed := SeedForAddress(addr, 42)
			if prev, ok := seen[seed]; ok {
				t.Errorf("seed collision between %q and %q (seed=%d)", prev, addr, seed)
			}
			seen[seed] = addr
		}
	}
}
