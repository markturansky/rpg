extends SceneTree

const HA = preload("res://scripts/hex_address.gd")
const TD = preload("res://scripts/tier_data.gd")
const TR = preload("res://scripts/terrain_data.gd")

var _pass_count := 0
var _fail_count := 0
var _test_name := ""

func _init():
	print("=== HexAddress Unit Tests ===\n")

	test_root_address()
	test_world_address()
	test_parse_world_coord()
	test_is_world_address()
	test_child_address()
	test_parent_address()
	test_depth()
	test_tier_mapping()
	test_leaf_index()
	test_sub_indices()
	test_indices_roundtrip()
	test_from_indices()
	test_children_addresses()
	test_world_neighbor()
	test_hex_root()
	test_seed_determinism()
	test_seed_world_hex_uniqueness()
	test_terrain_determinism()
	test_terrain_varies_by_address()
	test_terrain_varies_by_seed()
	test_is_ancestor()
	test_total_hexes_below()
	test_total_world_hexes()
	test_col_row_index_roundtrip()
	test_parent_terrain_bias()

	print("\n=== Results: %d passed, %d failed ===" % [_pass_count, _fail_count])
	if _fail_count > 0:
		quit(1)
	else:
		quit(0)

func begin(name: String):
	_test_name = name

func assert_eq(actual: Variant, expected: Variant, msg: String = ""):
	if actual == expected:
		_pass_count += 1
	else:
		_fail_count += 1
		var label := msg if msg != "" else _test_name
		print("  FAIL [%s]: expected %s, got %s" % [label, str(expected), str(actual)])

func assert_true(value: bool, msg: String = ""):
	assert_eq(value, true, msg)

func assert_false(value: bool, msg: String = ""):
	assert_eq(value, false, msg)

func assert_ne(a: Variant, b: Variant, msg: String = ""):
	if a != b:
		_pass_count += 1
	else:
		_fail_count += 1
		var label := msg if msg != "" else _test_name
		print("  FAIL [%s]: expected values to differ, both were %s" % [label, str(a)])

func test_root_address():
	begin("root_address")
	assert_eq(HA.root(), "/")
	print("  root_address: ok")

func test_world_address():
	begin("world_address")
	assert_eq(HA.world_address(0, 0), "/0,0")
	assert_eq(HA.world_address(3, -2), "/3,-2")
	assert_eq(HA.world_address(-1, 5), "/-1,5")
	print("  world_address: ok")

func test_parse_world_coord():
	begin("parse_world_coord")
	var qr := HA.parse_world_coord("/0,0")
	assert_eq(qr.x, 0, "q=0")
	assert_eq(qr.y, 0, "r=0")
	qr = HA.parse_world_coord("/3,-2")
	assert_eq(qr.x, 3, "q=3")
	assert_eq(qr.y, -2, "r=-2")
	qr = HA.parse_world_coord("/0,0/3/2")
	assert_eq(qr.x, 0, "nested q=0")
	assert_eq(qr.y, 0, "nested r=0")
	print("  parse_world_coord: ok")

func test_is_world_address():
	begin("is_world_address")
	assert_true(HA.is_world_address("/0,0"), "/0,0 is world")
	assert_true(HA.is_world_address("/3,-2"), "/3,-2 is world")
	assert_true(HA.is_world_address("/0,0/3"), "nested world")
	assert_false(HA.is_world_address(""), "empty not world")
	print("  is_world_address: ok")

func test_child_address():
	begin("child_address")
	assert_eq(HA.child("/0,0", 3), "/0,0/3")
	assert_eq(HA.child("/0,0/3", 2), "/0,0/3/2")
	assert_eq(HA.child("/1,2/3/4", 5), "/1,2/3/4/5")
	print("  child_address: ok")

func test_parent_address():
	begin("parent_address")
	assert_eq(HA.parent("/"), "/")
	assert_eq(HA.parent("/0,0"), "/")
	assert_eq(HA.parent("/0,0/3"), "/0,0")
	assert_eq(HA.parent("/0,0/3/2"), "/0,0/3")
	assert_eq(HA.parent("/1,2/3/4/5"), "/1,2/3/4")
	print("  parent_address: ok")

func test_depth():
	begin("depth")
	assert_eq(HA.depth("/"), 0)
	assert_eq(HA.depth(""), 0)
	assert_eq(HA.depth("/0,0"), 1)
	assert_eq(HA.depth("/3,-2"), 1)
	assert_eq(HA.depth("/0,0/3"), 2)
	assert_eq(HA.depth("/0,0/3/2"), 3)
	assert_eq(HA.depth("/0,0/1/2/3/4/5"), 6)
	print("  depth: ok")

func test_tier_mapping():
	begin("tier_mapping")
	assert_eq(HA.tier("/0,0"), TD.Tier.WORLD)
	assert_eq(HA.tier("/0,0/3"), TD.Tier.REGIONAL)
	assert_eq(HA.tier("/0,0/3/2"), TD.Tier.LOCAL)
	assert_eq(HA.tier("/0,0/3/2/1"), TD.Tier.DISTRICT)
	assert_eq(HA.tier("/0,0/3/2/1/4"), TD.Tier.STREET)
	assert_eq(HA.tier("/0,0/3/2/1/4/0"), TD.Tier.TACTICAL)
	print("  tier_mapping: ok")

func test_leaf_index():
	begin("leaf_index")
	assert_eq(HA.leaf_index("/"), -1)
	assert_eq(HA.leaf_index("/0,0"), -1, "world addr has no leaf index")
	assert_eq(HA.leaf_index("/0,0/3"), 3)
	assert_eq(HA.leaf_index("/1,2/3/4/5"), 5)
	print("  leaf_index: ok")

func test_sub_indices():
	begin("sub_indices")
	var empty: Array[int] = HA.sub_indices("/0,0")
	assert_eq(empty.size(), 0, "world addr has no sub indices")
	var idx: Array[int] = HA.sub_indices("/0,0/3/2")
	assert_eq(idx.size(), 2)
	assert_eq(idx[0], 3)
	assert_eq(idx[1], 2)
	var five: Array[int] = HA.sub_indices("/0,0/1/2/3/4/5")
	assert_eq(five.size(), 5)
	print("  sub_indices: ok")

func test_indices_roundtrip():
	begin("indices_roundtrip")
	var idx: Array[int] = HA.indices("/0,0/3/2")
	assert_eq(idx.size(), 2, "world addr indices are sub-indices")
	assert_eq(idx[0], 3)
	assert_eq(idx[1], 2)
	print("  indices_roundtrip: ok")

func test_from_indices():
	begin("from_indices")
	var empty: Array[int] = []
	assert_eq(HA.from_indices(empty), "/")
	var single: Array[int] = [3]
	assert_eq(HA.from_indices(single), "/3")
	var multi: Array[int] = [1, 2, 3, 4, 5]
	assert_eq(HA.from_indices(multi), "/1/2/3/4/5")
	print("  from_indices: ok")

func test_children_addresses():
	begin("children_addresses")
	var children: Array[String] = HA.children_addresses("/0,0")
	assert_eq(children.size(), 6)
	assert_eq(children[0], "/0,0/0")
	assert_eq(children[5], "/0,0/5")

	var sub_children: Array[String] = HA.children_addresses("/0,0/2")
	assert_eq(sub_children.size(), 6)
	assert_eq(sub_children[0], "/0,0/2/0")
	assert_eq(sub_children[3], "/0,0/2/3")
	print("  children_addresses: ok")

func test_world_neighbor():
	begin("world_neighbor")
	var n0 := HA.world_neighbor(0, 0, 0)
	assert_eq(n0, Vector2i(1, 0), "dir 0")
	var n1 := HA.world_neighbor(0, 0, 1)
	assert_eq(n1, Vector2i(0, 1), "dir 1")
	var n2 := HA.world_neighbor(0, 0, 2)
	assert_eq(n2, Vector2i(-1, 1), "dir 2")
	var n3 := HA.world_neighbor(0, 0, 3)
	assert_eq(n3, Vector2i(-1, 0), "dir 3")
	var n4 := HA.world_neighbor(0, 0, 4)
	assert_eq(n4, Vector2i(0, -1), "dir 4")
	var n5 := HA.world_neighbor(0, 0, 5)
	assert_eq(n5, Vector2i(1, -1), "dir 5")
	print("  world_neighbor: ok")

func test_hex_root():
	begin("hex_root")
	assert_eq(HA.hex_root("/0,0"), "/0,0")
	assert_eq(HA.hex_root("/0,0/3/2"), "/0,0")
	assert_eq(HA.hex_root("/3,-2/1"), "/3,-2")
	print("  hex_root: ok")

func test_seed_determinism():
	begin("seed_determinism")
	var world_seed := 42
	var addr := "/0,0/3/2"

	var seed_a: int = HA.seed_for_address(addr, world_seed)
	var seed_b: int = HA.seed_for_address(addr, world_seed)
	assert_eq(seed_a, seed_b, "same address same seed must produce same result")

	var seed_c: int = HA.seed_for_address("/0,0/3/1", world_seed)
	assert_ne(seed_a, seed_c, "different addresses must produce different seeds")

	var seed_d: int = HA.seed_for_address(addr, 99)
	assert_ne(seed_a, seed_d, "different world seeds must produce different results")
	print("  seed_determinism: ok")

func test_seed_world_hex_uniqueness():
	begin("seed_world_hex_uniqueness")
	var seen: Dictionary = {}
	for q in range(-5, 6):
		for r in range(-5, 6):
			var addr := HA.world_address(q, r)
			var s := HA.seed_for_address(addr, 42)
			assert_false(seen.has(s), "no collision at %s" % addr)
			seen[s] = addr
	print("  seed_world_hex_uniqueness: ok")

func test_terrain_determinism():
	begin("terrain_determinism")
	var world_seed := 42
	var addr := "/0,0/2/1"

	var terrain_a = HA.terrain_for_address(addr, world_seed)
	var terrain_b = HA.terrain_for_address(addr, world_seed)
	assert_eq(terrain_a, terrain_b, "same address must always return same terrain")
	print("  terrain_determinism: ok")

func test_terrain_varies_by_address():
	begin("terrain_varies_by_address")
	var world_seed := 42
	var terrains: Dictionary = {}
	for qi in range(-50, 51):
		for ri in range(-40, 41):
			var q := qi * 5
			var r := ri * 5
			var addr := HA.world_address(q, r)
			terrains[addr] = HA.terrain_for_address(addr, world_seed)
	var unique_count := 0
	var seen: Dictionary = {}
	for addr in terrains:
		var t: int = terrains[addr]
		if not seen.has(t):
			seen[t] = true
			unique_count += 1
	assert_true(unique_count >= 5, "at least 5 different terrain types among world hexes")
	print("  terrain_varies_by_address: ok")

func test_terrain_varies_by_seed():
	begin("terrain_varies_by_seed")
	var addr := "/3,2/1"
	var terrains: Dictionary = {}
	for seed_val in range(100):
		var t = HA.terrain_for_address(addr, seed_val)
		terrains[seed_val] = t
	var unique_count := 0
	var seen: Dictionary = {}
	for seed_val in terrains:
		var t: int = terrains[seed_val]
		if not seen.has(t):
			seen[t] = true
			unique_count += 1
	assert_true(unique_count >= 2, "at least 2 different terrain types across 100 seeds")
	print("  terrain_varies_by_seed: ok")

func test_is_ancestor():
	begin("is_ancestor")
	assert_true(HA.is_ancestor("/", "/0,0"))
	assert_true(HA.is_ancestor("/", "/0,0/3/2"))
	assert_true(HA.is_ancestor("/0,0", "/0,0/3"))
	assert_true(HA.is_ancestor("/0,0/3", "/0,0/3/2"))
	assert_false(HA.is_ancestor("/", "/"))
	assert_false(HA.is_ancestor("/0,0", "/1,0"))
	assert_false(HA.is_ancestor("/0,0", "/0,0"))
	assert_false(HA.is_ancestor("/0,0/3", "/0,0/4"))
	print("  is_ancestor: ok")

func test_total_hexes_below():
	begin("total_hexes_below")
	assert_eq(HA.total_hexes_below(0), 1)
	assert_eq(HA.total_hexes_below(1), 7)
	assert_eq(HA.total_hexes_below(2), 43)
	assert_eq(HA.total_hexes_below(3), 259)
	assert_eq(HA.total_hexes_below(4), 1555)
	assert_eq(HA.total_hexes_below(5), 9331)
	print("  total_hexes_below: ok")

func test_total_world_hexes():
	begin("total_world_hexes")
	var per_hex: int = HA.total_hexes_below(5)
	assert_eq(per_hex, 9331)

	var total_10x10: int = HA.total_world_hexes(10, 10)
	assert_eq(total_10x10, 100 * 9331)

	var total_6x6: int = HA.total_world_hexes(6, 6)
	assert_eq(total_6x6, 36 * 9331)
	print("  total_world_hexes: ok")

func test_col_row_index_roundtrip():
	begin("col_row_index_roundtrip")
	var cols := 10
	for row in range(5):
		for col in range(cols):
			var idx: int = HA.col_row_to_index(col, row, cols)
			var result: Vector2i = HA.index_to_col_row(idx, cols)
			assert_eq(result, Vector2i(col, row), "roundtrip col=%d row=%d" % [col, row])
	print("  col_row_index_roundtrip: ok")

func test_parent_terrain_bias():
	begin("parent_terrain_bias")
	var world_seed := 42
	var forest_addr := ""
	for qi in range(-50, 51):
		for ri in range(-40, 41):
			var q := qi * 5
			var r := ri * 5
			var addr := HA.world_address(q, r)
			var t = HA.terrain_for_address(addr, world_seed)
			if t == TR.TerrainType.FOREST:
				forest_addr = addr
				break
		if forest_addr != "":
			break

	if forest_addr == "":
		print("  parent_terrain_bias: skipped (no forest hex found)")
		return

	var forest_child_count := 0
	var green_count := 0
	for i in range(6):
		var child_addr: String = HA.child(forest_addr, i)
		var t = HA.terrain_for_address(child_addr, world_seed)
		if t == TR.TerrainType.FOREST or t == TR.TerrainType.DENSE_FOREST:
			forest_child_count += 1
		if t == TR.TerrainType.FOREST or t == TR.TerrainType.DENSE_FOREST or t == TR.TerrainType.GRASSLAND:
			green_count += 1

	assert_true(green_count >= 2, "forest parent should bias children toward green terrain")
	print("  parent_terrain_bias: ok (forest children: %d forest-like, %d green-like)" % [forest_child_count, green_count])
