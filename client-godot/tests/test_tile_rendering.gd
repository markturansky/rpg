extends SceneTree

const TerrainDataClass = preload("res://scripts/terrain_data.gd")
const TileLoaderClass = preload("res://scripts/tile_loader.gd")

var _pass_count := 0
var _fail_count := 0
var _test_name := ""

func _init():
	print("=== Tile Rendering Tests ===")
	print("")

	test_tile_url_construction()
	test_terrain_color_fallback()
	test_tile_grid_positioning()
	test_tile_cache_max_size()
	test_tile_address_to_server_address()
	test_grid_cell_no_gaps()
	test_grid_cell_no_overlaps()

	print("")
	print("=== Results: %d passed, %d failed ===" % [_pass_count, _fail_count])

	if _fail_count > 0:
		quit(1)
	else:
		quit(0)

func assert_eq(actual, expected, msg: String = ""):
	if actual == expected:
		_pass_count += 1
	else:
		_fail_count += 1
		var label := msg if msg != "" else _test_name
		print("  FAIL [%s]: expected %s, got %s" % [label, str(expected), str(actual)])

func assert_true(value: bool, msg: String = ""):
	if value:
		_pass_count += 1
	else:
		_fail_count += 1
		var label := msg if msg != "" else _test_name
		print("  FAIL [%s]: expected true, got false" % label)

func assert_ne(a, b, msg: String = ""):
	if a != b:
		_pass_count += 1
	else:
		_fail_count += 1
		var label := msg if msg != "" else _test_name
		print("  FAIL [%s]: expected not equal, both are %s" % [label, str(a)])

func test_tile_url_construction():
	_test_name = "tile_url_construction"
	print("  %s" % _test_name)

	assert_eq(TileLoaderClass.tile_url("map2", "localhost", 8080), "http://localhost:8080/tiles/map2")
	assert_eq(TileLoaderClass.tile_url("map2_35", "localhost", 8080), "http://localhost:8080/tiles/map2_35")
	assert_eq(TileLoaderClass.tile_url("map2_35_07", "localhost", 8080), "http://localhost:8080/tiles/map2_35_07")
	assert_eq(TileLoaderClass.tile_url("map2_35_07_42_55_00", "localhost", 8080), "http://localhost:8080/tiles/map2_35_07_42_55_00")

	var url_with_size := TileLoaderClass.tile_url("map2_35", "localhost", 8080, 512)
	assert_true(url_with_size.contains("size=512"), "URL should include size parameter")

func test_terrain_color_fallback():
	_test_name = "terrain_color_fallback"
	print("  %s" % _test_name)

	var terrain_ids := [
		TerrainDataClass.TerrainType.DEEP_WATER,
		TerrainDataClass.TerrainType.SHALLOW_WATER,
		TerrainDataClass.TerrainType.BEACH,
		TerrainDataClass.TerrainType.PLAINS,
		TerrainDataClass.TerrainType.GRASSLAND,
		TerrainDataClass.TerrainType.FOREST,
		TerrainDataClass.TerrainType.DENSE_FOREST,
		TerrainDataClass.TerrainType.HILLS,
		TerrainDataClass.TerrainType.MOUNTAIN,
		TerrainDataClass.TerrainType.DESERT,
		TerrainDataClass.TerrainType.MARSH,
		TerrainDataClass.TerrainType.TUNDRA,
		TerrainDataClass.TerrainType.ROAD,
	]

	for terrain_id in terrain_ids:
		assert_true(
			TerrainDataClass.TERRAIN_COLORS.has(terrain_id),
			"terrain %d should have fallback color" % terrain_id
		)

	for terrain_id in terrain_ids:
		var color: Color = TerrainDataClass.TERRAIN_COLORS[terrain_id]
		assert_true(color.a > 0.0, "terrain %d color should not be fully transparent" % terrain_id)

func test_tile_grid_positioning():
	_test_name = "tile_grid_positioning"
	print("  %s" % _test_name)

	var viewport_size := Vector2(1024.0, 1024.0)
	var cell_size := viewport_size / 10.0

	assert_eq(cell_size, Vector2(102.4, 102.4), "cell size for 1024 viewport")

	var pos_00 := TileLoaderClass.grid_position(0, 0, viewport_size)
	assert_eq(pos_00, Vector2(0.0, 0.0), "cell 0,0 position")

	var pos_99 := TileLoaderClass.grid_position(9, 9, viewport_size)
	var expected_99 := Vector2(9.0 * cell_size.x, 9.0 * cell_size.y)
	assert_eq(pos_99, expected_99, "cell 9,9 position")

	var pos_55 := TileLoaderClass.grid_position(5, 5, viewport_size)
	var expected_55 := Vector2(5.0 * cell_size.x, 5.0 * cell_size.y)
	assert_eq(pos_55, expected_55, "cell 5,5 position")

	var size := TileLoaderClass.grid_cell_size(viewport_size)
	assert_eq(size, cell_size, "grid_cell_size should return viewport/10")

func test_tile_cache_max_size():
	_test_name = "tile_cache_max_size"
	print("  %s" % _test_name)

	var cache := TileLoaderClass.TileCache.new(5)
	assert_eq(cache.size(), 0, "empty cache size")

	for i in range(5):
		cache.put("tile_%d" % i, Image.create(1, 1, false, Image.FORMAT_RGBA8))
	assert_eq(cache.size(), 5, "cache at capacity")

	cache.put("tile_5", Image.create(1, 1, false, Image.FORMAT_RGBA8))
	assert_eq(cache.size(), 5, "cache should not exceed max")
	assert_true(cache.has("tile_5"), "newest entry should be in cache")

func test_tile_address_to_server_address():
	_test_name = "tile_address_to_server_address"
	print("  %s" % _test_name)

	assert_eq(TileLoaderClass.to_server_address("map2"), "map2")
	assert_eq(TileLoaderClass.to_server_address("map2_35"), "map2_35")
	assert_eq(TileLoaderClass.to_server_address("map2_35_07_42"), "map2_35_07_42")

func test_grid_cell_no_gaps():
	_test_name = "grid_cell_no_gaps"
	print("  %s" % _test_name)

	var viewport := Vector2(1000.0, 1000.0)
	var cs := TileLoaderClass.grid_cell_size(viewport)

	for row in range(9):
		var bottom_of_row := TileLoaderClass.grid_position(0, row, viewport).y + cs.y
		var top_of_next := TileLoaderClass.grid_position(0, row + 1, viewport).y
		assert_eq(bottom_of_row, top_of_next, "row %d bottom should touch row %d top" % [row, row + 1])

	for col in range(9):
		var right_of_col := TileLoaderClass.grid_position(col, 0, viewport).x + cs.x
		var left_of_next := TileLoaderClass.grid_position(col + 1, 0, viewport).x
		assert_eq(right_of_col, left_of_next, "col %d right should touch col %d left" % [col, col + 1])

func test_grid_cell_no_overlaps():
	_test_name = "grid_cell_no_overlaps"
	print("  %s" % _test_name)

	var viewport := Vector2(800.0, 800.0)
	var cs := TileLoaderClass.grid_cell_size(viewport)

	for row in range(10):
		for col in range(10):
			var pos := TileLoaderClass.grid_position(col, row, viewport)
			assert_true(pos.x >= 0.0, "cell %d,%d x >= 0" % [col, row])
			assert_true(pos.y >= 0.0, "cell %d,%d y >= 0" % [col, row])
			assert_true(pos.x + cs.x <= viewport.x + 0.01, "cell %d,%d right within viewport" % [col, row])
			assert_true(pos.y + cs.y <= viewport.y + 0.01, "cell %d,%d bottom within viewport" % [col, row])
