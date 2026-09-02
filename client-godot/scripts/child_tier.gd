extends Node2D

const GRID_COLS := 30
const GRID_ROWS := 20

var tier: TierData.Tier
var parent_col: int
var parent_row: int
var parent_terrain: TerrainData.TerrainType
var child_seed: int

const TERRAIN_BIAS := {
	TerrainData.TerrainType.PLAINS: { "elevation": 0.15, "moisture": 0.35 },
	TerrainData.TerrainType.GRASSLAND: { "elevation": 0.1, "moisture": 0.5 },
	TerrainData.TerrainType.FOREST: { "elevation": 0.2, "moisture": 0.65 },
	TerrainData.TerrainType.DENSE_FOREST: { "elevation": 0.25, "moisture": 0.8 },
	TerrainData.TerrainType.HILLS: { "elevation": 0.55, "moisture": 0.4 },
	TerrainData.TerrainType.MOUNTAIN: { "elevation": 0.75, "moisture": 0.3 },
	TerrainData.TerrainType.DESERT: { "elevation": 0.15, "moisture": 0.1 },
	TerrainData.TerrainType.MARSH: { "elevation": 0.05, "moisture": 0.85 },
	TerrainData.TerrainType.TUNDRA: { "elevation": 0.6, "moisture": 0.3 },
	TerrainData.TerrainType.BEACH: { "elevation": -0.05, "moisture": 0.4 },
	TerrainData.TerrainType.SHALLOW_WATER: { "elevation": -0.2, "moisture": 0.5 },
	TerrainData.TerrainType.DEEP_WATER: { "elevation": -0.5, "moisture": 0.5 },
	TerrainData.TerrainType.ROAD: { "elevation": 0.1, "moisture": 0.3 },
}

func _ready():
	print("[ChildTier] _ready called")
	var context := GameState.get_parent_context()
	print("[ChildTier] parent context: %s" % context)
	if context.is_empty():
		print("[ChildTier] ABORT — empty parent context")
		return

	parent_col = context["col"]
	parent_row = context["row"]
	parent_terrain = context["terrain"]
	tier = GameState.current_tier
	child_seed = GameState.WORLD_SEED + parent_col * 7919 + parent_row * 6271 + GameState.get_tier_depth() * 104729

	var grid := _generate_terrain()
	$HexMap.setup(GRID_COLS, GRID_ROWS, grid)
	$HexMap.hex_clicked.connect(_on_hex_clicked)
	$HexMap.hex_hovered.connect(_on_hex_hovered)

	$MapCamera.position = HexMath.pointy_hex_to_pixel(GRID_COLS / 2, GRID_ROWS / 2)
	$MapCamera.zoom = Vector2(1.0, 1.0)

	var tier_name: String = TierData.TIER_NAMES[tier]
	var scale_label: String = TierData.TIER_SCALE_LABEL[tier]
	var parent_terrain_name: String = TerrainData.TERRAIN_NAMES[parent_terrain]
	$HUD/TierLabel.text = "%s — %s  [from %s (%d,%d)]" % [tier_name, scale_label, parent_terrain_name, parent_col, parent_row]
	$HUD/TerrainLabel.text = ""
	$HUD/BackLabel.text = "ESC to go back"

	if not TierData.has_children(tier):
		$HUD/HintLabel.text = "Bottom tier — 4 ft per hex"
	else:
		$HUD/HintLabel.text = "Click a hex to go deeper"

func _generate_terrain() -> Array:
	var noise_elevation := FastNoiseLite.new()
	noise_elevation.seed = child_seed
	noise_elevation.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise_elevation.frequency = 0.08 + GameState.get_tier_depth() * 0.02
	noise_elevation.fractal_octaves = 4
	noise_elevation.fractal_lacunarity = 2.0
	noise_elevation.fractal_gain = 0.5

	var noise_moisture := FastNoiseLite.new()
	noise_moisture.seed = child_seed + 5000
	noise_moisture.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise_moisture.frequency = 0.1 + GameState.get_tier_depth() * 0.02
	noise_moisture.fractal_octaves = 3

	var bias: Dictionary = TERRAIN_BIAS.get(parent_terrain, { "elevation": 0.1, "moisture": 0.4 })
	var elev_bias: float = bias["elevation"]
	var moist_bias: float = bias["moisture"]

	var grid: Array = []
	for row in range(GRID_ROWS):
		var grid_row: Array = []
		for col in range(GRID_COLS):
			var raw_elev := noise_elevation.get_noise_2d(float(col), float(row))
			var raw_moist := (noise_moisture.get_noise_2d(float(col), float(row)) + 1.0) / 2.0
			var elevation := raw_elev * 0.4 + elev_bias * 0.6
			var moisture := raw_moist * 0.4 + moist_bias * 0.6
			grid_row.append(TerrainData.terrain_from_elevation(elevation, moisture))
		grid.append(grid_row)
	return grid

func _on_hex_clicked(col: int, row: int):
	var terrain: TerrainData.TerrainType = $HexMap.get_terrain_at(col, row)
	print("[ChildTier] hex clicked: (%d,%d) terrain=%d has_children=%s" % [col, row, terrain, TierData.has_children(tier)])
	if terrain == TerrainData.TerrainType.DEEP_WATER:
		return
	if TierData.has_children(tier):
		GameState.enter_hex(tier, col, row, terrain)

func _on_hex_hovered(col: int, row: int):
	var terrain: TerrainData.TerrainType = $HexMap.get_terrain_at(col, row)
	var terrain_name: String = TerrainData.TERRAIN_NAMES[terrain]
	$HUD/TerrainLabel.text = "%s  (%d, %d)" % [terrain_name, col, row]
	if not TierData.has_children(tier):
		$HUD/TerrainLabel.text += "  [bottom tier]"

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		print("[ChildTier] ESC pressed — exit_tier")
		GameState.exit_tier()
