extends SceneTree

const HA = preload("res://scripts/hex_address.gd")
const TD = preload("res://scripts/tier_data.gd")
const TR = preload("res://scripts/terrain_data.gd")

var _pass_count := 0
var _fail_count := 0
var _test_name := ""
var _socket := WebSocketPeer.new()
var _server_pid: int = -1
var _server_port := 8091
var _db_path := ""

func _init():
	print("=== Client Integration Tests ===\n")

	if not _start_server():
		print("  FATAL: Could not start server")
		quit(1)
		return

	if not _wait_for_server():
		print("  FATAL: Server did not become ready")
		_kill_server()
		quit(1)
		return

	if not _connect_websocket():
		print("  FATAL: WebSocket connection failed")
		_kill_server()
		quit(1)
		return

	test_get_reference_data()
	var char_id := test_create_character()
	if char_id > 0:
		test_get_character(char_id)
		test_move_all_directions(char_id)
		test_invalid_move(char_id)
		test_zoom_in(char_id)
		test_zoom_in_again(char_id)
		test_move_at_depth(char_id)
		test_zoom_out(char_id)
		test_zoom_out_to_world(char_id)
		test_zoom_out_at_world_fails(char_id)
		test_zoom_to_max_depth(char_id)
		test_zoom_past_max_fails(char_id)
		test_game_state_address_tracking(char_id)

	test_hex_address_consistency()
	test_unknown_message_type()

	_socket.close()
	_kill_server()

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

func assert_has(dict: Dictionary, key: String, msg: String = ""):
	if dict.has(key):
		_pass_count += 1
	else:
		_fail_count += 1
		var label := msg if msg != "" else _test_name
		print("  FAIL [%s]: dictionary missing key '%s'" % [label, key])

func _start_server() -> bool:
	var project_dir := ProjectSettings.globalize_path("res://")
	var server_path := project_dir.path_join("build/rpg-server")
	if not FileAccess.file_exists(server_path):
		server_path = project_dir.path_join("../server/rpg-server")
		if not FileAccess.file_exists(server_path):
			print("  Server binary not found")
			return false

	_db_path = "/tmp/rpg_integration_test_%d.db" % Time.get_ticks_msec()

	var args := PackedStringArray([
		"-addr", ":%d" % _server_port,
		"-db", _db_path,
	])

	_server_pid = OS.create_process(server_path, args)
	return _server_pid > 0

func _wait_for_server() -> bool:
	for i in range(40):
		OS.delay_msec(250)
		var http := HTTPClient.new()
		var err := http.connect_to_host("127.0.0.1", _server_port)
		if err != OK:
			continue
		for _j in range(10):
			OS.delay_msec(100)
			http.poll()
			if http.get_status() == HTTPClient.STATUS_CONNECTED:
				break
		if http.get_status() != HTTPClient.STATUS_CONNECTED:
			continue
		err = http.request(HTTPClient.METHOD_GET, "/health", PackedStringArray())
		if err != OK:
			continue
		for _j in range(10):
			OS.delay_msec(100)
			http.poll()
			if http.get_status() == HTTPClient.STATUS_BODY or http.get_status() == HTTPClient.STATUS_CONNECTED:
				break
		if http.has_response() and http.get_response_code() == 200:
			print("  Server ready on port %d" % _server_port)
			return true
	return false

func _connect_websocket() -> bool:
	var url := "ws://127.0.0.1:%d/ws" % _server_port
	var err := _socket.connect_to_url(url)
	if err != OK:
		return false
	for i in range(50):
		OS.delay_msec(100)
		_socket.poll()
		if _socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
			print("  WebSocket connected\n")
			return true
	return false

func _kill_server():
	if _server_pid > 0 and OS.is_process_running(_server_pid):
		OS.kill(_server_pid)
		_server_pid = -1
	if _db_path != "" and FileAccess.file_exists(_db_path):
		DirAccess.remove_absolute(_db_path)

func _send(msg_type: String, payload: Dictionary = {}) -> Dictionary:
	var envelope := {"type": msg_type, "payload": payload}
	_socket.send_text(JSON.stringify(envelope))
	for i in range(100):
		OS.delay_msec(50)
		_socket.poll()
		if _socket.get_available_packet_count() > 0:
			var packet := _socket.get_packet()
			var text := packet.get_string_from_utf8()
			var json := JSON.new()
			if json.parse(text) == OK:
				var data: Dictionary = json.data
				var resp_type: String = data.get("type", "")
				var resp_payload = data.get("payload", {})
				if resp_payload is Dictionary:
					resp_payload["_type"] = resp_type
					return resp_payload
				elif resp_payload is Array:
					return {"_items": resp_payload, "_type": resp_type}
				else:
					return {"_type": resp_type}
	return {"_type": "timeout"}

func test_get_reference_data():
	begin("reference_data")
	for pair in [
		["get_ancestries", "ancestries"],
		["get_classes", "classes"],
		["get_weapons", "weapons"],
		["get_armor", "armor"],
		["get_shields", "shields"],
		["get_terrain", "terrain"],
		["get_monsters", "monsters"],
		["get_spells", "spells"],
		["get_items", "items"],
	]:
		var resp := _send(pair[0])
		assert_eq(resp.get("_type"), pair[1], "%s type" % pair[0])
		var items = resp.get("_items", [])
		assert_true(items.size() > 0, "%s has data" % pair[0])
	print("  reference_data: ok")

func test_create_character() -> int:
	begin("create_character")
	var resp := _send("create_character", {
		"name": "TestHero",
		"ancestry_id": "human",
		"class_id": "fighter",
		"str": 16, "dex": 12, "con": 14, "int_": 10, "wis": 10, "cha": 10,
		"world_seed": 42,
	})
	assert_eq(resp.get("_type"), "character_created", "response type")
	assert_has(resp, "id", "has id")
	assert_has(resp, "current_address", "has current_address")
	assert_eq(resp.get("current_address"), "/-190,155", "starts at /-190,155")
	assert_false(resp.has("world_col"), "no legacy world_col")
	assert_false(resp.has("world_row"), "no legacy world_row")
	assert_true(int(resp.get("id", 0)) > 0, "id > 0")
	print("  create_character: ok")
	return int(resp.get("id", 0))

func test_get_character(char_id: int):
	begin("get_character")
	var resp := _send("get_character", {"character_id": char_id})
	assert_eq(resp.get("_type"), "character", "response type")
	assert_eq(resp.get("current_address"), "/-190,155", "address is /-190,155")
	assert_eq(int(resp.get("id", 0)), char_id, "id matches")
	print("  get_character: ok")

func test_move_all_directions(char_id: int):
	begin("move_all_directions")
	var move_count := 0
	for direction in range(6):
		var resp := _send("move", {"character_id": char_id, "direction": direction})
		var resp_type: String = resp.get("_type", "")
		if resp_type == "move_result":
			assert_true(resp.get("success", false), "move %d success" % direction)
			assert_has(resp, "new_address", "move %d has new_address" % direction)
			assert_has(resp, "tier_name", "move %d has tier_name" % direction)
			assert_eq(int(resp.get("depth", 0)), 1, "move %d depth is 1" % direction)
			move_count += 1
		elif resp_type.contains("error"):
			assert_true(true, "move %d rejected" % direction)
			move_count += 1
		else:
			assert_true(false, "move %d unexpected type: %s" % [direction, resp_type])
	assert_eq(move_count, 6, "all 6 moves processed")
	print("  move_all_directions: ok")

func test_invalid_move(char_id: int):
	begin("invalid_move")
	var resp := _send("move", {"character_id": char_id, "direction": 7})
	assert_true(resp.get("_type", "").contains("error"), "direction 7 rejected")
	resp = _send("move", {"character_id": char_id, "direction": -1})
	assert_true(resp.get("_type", "").contains("error"), "direction -1 rejected")
	print("  invalid_move: ok")

func test_zoom_in(char_id: int):
	begin("zoom_in")
	var resp := _send("zoom_in", {"character_id": char_id, "child_index": 0})
	assert_eq(resp.get("_type"), "zoom_result", "response type")
	assert_true(resp.get("success", false), "zoom_in success")
	assert_eq(int(resp.get("depth", 0)), 2, "depth is 2")
	assert_eq(resp.get("tier_name"), "regional", "tier is regional")
	assert_has(resp, "siblings", "has siblings")
	var siblings = resp.get("siblings", [])
	assert_eq(siblings.size(), 6, "6 siblings")
	print("  zoom_in: ok")

func test_zoom_in_again(char_id: int):
	begin("zoom_in_again")
	var resp := _send("zoom_in", {"character_id": char_id, "child_index": 3})
	assert_eq(resp.get("_type"), "zoom_result", "response type")
	assert_true(resp.get("success", false), "success")
	assert_eq(int(resp.get("depth", 0)), 3, "depth is 3")
	assert_eq(resp.get("tier_name"), "local", "tier is local")
	print("  zoom_in_again: ok")

func test_move_at_depth(char_id: int):
	begin("move_at_depth")
	var resp := _send("move", {"character_id": char_id, "direction": 2})
	var resp_type: String = resp.get("_type", "")
	if resp_type == "move_result":
		assert_true(resp.get("success", false), "move at depth 3 success")
		assert_eq(int(resp.get("depth", 0)), 3, "still depth 3")
	else:
		assert_true(resp_type.contains("error"), "move at depth 3 valid response")
	print("  move_at_depth: ok")

func test_zoom_out(char_id: int):
	begin("zoom_out")
	var resp := _send("zoom_out", {"character_id": char_id})
	assert_eq(resp.get("_type"), "zoom_result", "response type")
	assert_true(resp.get("success", false), "success")
	assert_eq(int(resp.get("depth", 0)), 2, "depth is 2")
	assert_eq(resp.get("tier_name"), "regional", "tier is regional")
	print("  zoom_out: ok")

func test_zoom_out_to_world(char_id: int):
	begin("zoom_out_to_world")
	var resp := _send("zoom_out", {"character_id": char_id})
	assert_eq(resp.get("_type"), "zoom_result", "response type")
	assert_true(resp.get("success", false), "success")
	assert_eq(int(resp.get("depth", 0)), 1, "depth is 1")
	assert_eq(resp.get("tier_name"), "world", "tier is world")
	print("  zoom_out_to_world: ok")

func test_zoom_out_at_world_fails(char_id: int):
	begin("zoom_out_at_world_fails")
	var resp := _send("zoom_out", {"character_id": char_id})
	assert_true(resp.get("_type", "").contains("error"), "zoom_out at world rejected")
	print("  zoom_out_at_world_fails: ok")

func test_zoom_to_max_depth(char_id: int):
	begin("zoom_to_max_depth")
	for target_depth in range(2, 7):
		var resp := _send("zoom_in", {"character_id": char_id, "child_index": 1})
		assert_eq(resp.get("_type"), "zoom_result", "depth %d type" % target_depth)
		assert_eq(int(resp.get("depth", 0)), target_depth, "depth is %d" % target_depth)
	print("  zoom_to_max_depth: ok")

func test_zoom_past_max_fails(char_id: int):
	begin("zoom_past_max_fails")
	var resp := _send("zoom_in", {"character_id": char_id, "child_index": 0})
	assert_true(resp.get("_type", "").contains("error"), "zoom past max rejected")
	print("  zoom_past_max_fails: ok")

func test_game_state_address_tracking(char_id: int):
	begin("game_state_address_tracking")
	for _i in range(5):
		_send("zoom_out", {"character_id": char_id})
	var resp := _send("get_character", {"character_id": char_id})
	var addr: String = resp.get("current_address", "")
	assert_eq(HA.depth(addr), 1, "back at world depth")
	var d := HA.depth(addr)
	var tier := HA.tier(addr)
	assert_eq(tier, TD.Tier.WORLD, "tier matches depth")
	assert_true(HA.depth(addr) >= 1, "address is valid")
	print("  game_state_address_tracking: ok")

func test_hex_address_consistency():
	begin("hex_address_consistency")
	var addr := "/0,0/3/2"
	var d := HA.depth(addr)
	assert_eq(d, 3, "depth of /0,0/3/2")
	var p := HA.parent(addr)
	assert_eq(p, "/0,0/3", "parent of /0,0/3/2")
	var c := HA.child(p, 2)
	assert_eq(c, addr, "child roundtrip")
	var world_addr := "/0,0"
	assert_eq(HA.depth(world_addr), 1, "world depth")
	assert_eq(HA.parent(world_addr), "/", "world parent is root")
	assert_true(HA.is_world_address(world_addr), "is_world_address")
	var qr := HA.parse_world_coord(world_addr)
	assert_eq(qr.x, 0, "world q=0")
	assert_eq(qr.y, 0, "world r=0")
	var t1 := HA.terrain_for_address(addr, 42)
	var t2 := HA.terrain_for_address(addr, 42)
	assert_eq(t1, t2, "terrain determinism")
	print("  hex_address_consistency: ok")

func test_unknown_message_type():
	begin("unknown_message_type")
	var resp := _send("nonexistent_type")
	assert_true(resp.get("_type", "").contains("error"), "unknown type returns error")
	print("  unknown_message_type: ok")
