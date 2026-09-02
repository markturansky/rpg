extends SceneTree

var _pass_count := 0
var _fail_count := 0
var _test_name := ""
var _socket := WebSocketPeer.new()
var _server_pid: int = -1
var _server_port := 8092
var _db_path := ""

func _init():
	print("=== Zoom + Terrain FK Integration Tests ===\n")

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

	test_terrain_ids_valid()
	var char_id := test_create_character()
	if char_id > 0:
		test_zoom_all_children_at_depth_1(char_id)
		test_zoom_full_depth_chain(char_id)
		test_move_at_every_depth(char_id)
		test_zoom_out_full_chain(char_id)
		test_multiple_world_hexes(char_id)

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

func assert_ne(a: Variant, b: Variant, msg: String = ""):
	if a != b:
		_pass_count += 1
	else:
		_fail_count += 1
		var label := msg if msg != "" else _test_name
		print("  FAIL [%s]: expected values to differ, both were %s" % [label, str(a)])

func _start_server() -> bool:
	var project_dir := ProjectSettings.globalize_path("res://")
	var server_path := project_dir.path_join("build/rpg-server")
	if not FileAccess.file_exists(server_path):
		server_path = project_dir.path_join("../server/rpg-server")
		if not FileAccess.file_exists(server_path):
			print("  Server binary not found")
			return false

	_db_path = "/tmp/rpg_zoom_test_%d.db" % Time.get_ticks_msec()
	print("  Server binary: %s" % server_path)
	print("  DB path: %s" % _db_path)

	var args := PackedStringArray(["-addr", ":%d" % _server_port, "-db", _db_path])
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
			print("  Server ready on port %d\n" % _server_port)
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

func test_terrain_ids_valid():
	begin("terrain_ids_valid")
	var resp := _send("get_terrain")
	assert_eq(resp.get("_type"), "terrain", "get_terrain response type")
	var items = resp.get("_items", [])
	assert_true(items.size() >= 10, "at least 10 terrain types")
	var terrain_ids: Array[String] = []
	for t in items:
		terrain_ids.append(t.get("id", ""))
	print("  DB terrain IDs: %s" % str(terrain_ids))
	assert_true("shallow-water" in terrain_ids, "has 'shallow-water'")
	assert_true("deep-water" in terrain_ids, "has 'deep-water'")
	assert_true("dense-forest" in terrain_ids, "has 'dense-forest'")
	assert_true("forest" in terrain_ids, "has 'forest'")
	assert_true("plains" in terrain_ids, "has 'plains'")
	assert_true("grassland" in terrain_ids, "has 'grassland'")
	assert_true("mountain" in terrain_ids, "has 'mountain'")
	assert_true("desert" in terrain_ids, "has 'desert'")
	assert_true("hills" in terrain_ids, "has 'hills'")
	assert_true("beach" in terrain_ids, "has 'beach'")
	assert_true("marsh" in terrain_ids, "has 'marsh'")
	assert_true("tundra" in terrain_ids, "has 'tundra'")
	print("  terrain_ids_valid: ok")

func test_create_character() -> int:
	begin("create_character")
	var resp := _send("create_character", {
		"name": "ZoomTester",
		"ancestry_id": "human",
		"class_id": "fighter",
		"str": 16, "dex": 12, "con": 14, "int_": 10, "wis": 10, "cha": 10,
		"world_seed": 42,
	})
	assert_eq(resp.get("_type"), "character_created", "character created")
	var char_id := int(resp.get("id", 0))
	assert_true(char_id > 0, "valid id")
	print("  create_character: ok (id=%d, addr=%s)" % [char_id, resp.get("current_address", "?")])
	return char_id

func test_zoom_all_children_at_depth_1(char_id: int):
	begin("zoom_all_children_at_depth_1")
	for child_idx in range(6):
		_send("get_character", {"character_id": char_id})
		var char_resp := _send("get_character", {"character_id": char_id})
		var current_addr: String = char_resp.get("current_address", "")
		var current_depth := current_addr.count("/")

		if current_depth > 1:
			for _i in range(current_depth - 1):
				_send("zoom_out", {"character_id": char_id})

		_send("move", {"character_id": char_id, "direction": 0})

		var resp := _send("zoom_in", {"character_id": char_id, "child_index": child_idx})
		var resp_type: String = resp.get("_type", "")

		if resp_type == "zoom_result":
			assert_true(resp.get("success", false), "zoom child %d success" % child_idx)
			assert_eq(int(resp.get("depth", 0)), 2, "zoom child %d depth 2" % child_idx)
			var terrain_id: String = resp.get("terrain_id", "")
			assert_ne(terrain_id, "", "zoom child %d has terrain_id" % child_idx)
			print("    child %d: addr=%s terrain=%s siblings=%d" % [
				child_idx, resp.get("new_address", "?"), terrain_id,
				resp.get("siblings", []).size()])
		else:
			var err_msg: String = resp.get("error", "unknown")
			print("    child %d FAILED: %s" % [child_idx, err_msg])
			assert_true(false, "zoom child %d failed: %s" % [child_idx, err_msg])

		_send("zoom_out", {"character_id": char_id})

	print("  zoom_all_children_at_depth_1: ok")

func test_zoom_full_depth_chain(char_id: int):
	begin("zoom_full_depth_chain")

	var char_resp := _send("get_character", {"character_id": char_id})
	var addr: String = char_resp.get("current_address", "")
	var d := addr.count("/")
	for _i in range(d - 1):
		_send("zoom_out", {"character_id": char_id})

	print("    starting from world tier")
	for target_depth in range(2, 7):
		var child_idx := target_depth % 6
		var resp := _send("zoom_in", {"character_id": char_id, "child_index": child_idx})
		var resp_type: String = resp.get("_type", "")

		if resp_type == "zoom_result":
			assert_eq(int(resp.get("depth", 0)), target_depth, "depth %d" % target_depth)
			var terrain_id: String = resp.get("terrain_id", "")
			print("    depth %d: addr=%s terrain=%s tier=%s" % [
				target_depth, resp.get("new_address", "?"), terrain_id, resp.get("tier_name", "?")])
		else:
			var err_msg: String = resp.get("error", "unknown")
			print("    depth %d FAILED: %s" % [target_depth, err_msg])
			assert_true(false, "zoom to depth %d failed: %s" % [target_depth, err_msg])

	var resp := _send("zoom_in", {"character_id": char_id, "child_index": 0})
	assert_true(resp.get("_type", "").contains("error"), "zoom past max rejected")

	print("  zoom_full_depth_chain: ok")

func test_move_at_every_depth(char_id: int):
	begin("move_at_every_depth")

	var char_resp := _send("get_character", {"character_id": char_id})
	var current_addr: String = char_resp.get("current_address", "")
	var current_depth := current_addr.count("/")
	for _i in range(current_depth - 1):
		_send("zoom_out", {"character_id": char_id})

	for target_depth in range(1, 7):
		if target_depth > 1:
			_send("zoom_in", {"character_id": char_id, "child_index": 0})

		var resp := _send("move", {"character_id": char_id, "direction": 1})
		var resp_type: String = resp.get("_type", "")
		if resp_type == "move_result":
			assert_true(resp.get("success", false), "move at depth %d success" % target_depth)
			print("    move at depth %d: addr=%s terrain=%s" % [
				target_depth, resp.get("new_address", "?"), resp.get("terrain_id", "?")])
		elif resp_type.contains("error"):
			var err_msg: String = resp.get("error", "")
			if err_msg.contains("impassable"):
				assert_true(true, "move at depth %d blocked" % target_depth)
				print("    move at depth %d: blocked (impassable)" % target_depth)
			else:
				print("    move at depth %d ERROR: %s" % [target_depth, err_msg])
				assert_true(false, "move at depth %d error: %s" % [target_depth, err_msg])

	print("  move_at_every_depth: ok")

func test_zoom_out_full_chain(char_id: int):
	begin("zoom_out_full_chain")

	var char_resp := _send("get_character", {"character_id": char_id})
	var current_addr: String = char_resp.get("current_address", "")
	var current_depth := current_addr.count("/")

	for target_depth in range(current_depth - 1, 0, -1):
		var resp := _send("zoom_out", {"character_id": char_id})
		var resp_type: String = resp.get("_type", "")
		if resp_type == "zoom_result":
			assert_eq(int(resp.get("depth", 0)), target_depth, "zoom out to depth %d" % target_depth)
			print("    zoom out to depth %d: addr=%s tier=%s" % [
				target_depth, resp.get("new_address", "?"), resp.get("tier_name", "?")])
		else:
			var err_msg: String = resp.get("error", "unknown")
			print("    zoom out to depth %d FAILED: %s" % [target_depth, err_msg])
			assert_true(false, "zoom out to depth %d failed" % target_depth)

	print("  zoom_out_full_chain: ok")

func test_multiple_world_hexes(char_id: int):
	begin("multiple_world_hexes")

	var char_resp := _send("get_character", {"character_id": char_id})
	var addr: String = char_resp.get("current_address", "")
	var d := addr.count("/")
	for _i in range(d - 1):
		_send("zoom_out", {"character_id": char_id})

	for direction in range(6):
		_send("move", {"character_id": char_id, "direction": direction})

		var resp := _send("zoom_in", {"character_id": char_id, "child_index": 0})
		var resp_type: String = resp.get("_type", "")
		if resp_type == "zoom_result":
			assert_true(resp.get("success", false), "zoom after move dir %d" % direction)
			var terrain_id: String = resp.get("terrain_id", "")
			var new_addr: String = resp.get("new_address", "?")
			print("    dir %d: zoom ok addr=%s terrain=%s" % [direction, new_addr, terrain_id])
		elif resp_type.contains("error"):
			var err_msg: String = resp.get("error", "")
			print("    dir %d: zoom FAILED: %s" % [direction, err_msg])
			assert_true(false, "zoom after move dir %d: %s" % [direction, err_msg])

		_send("zoom_out", {"character_id": char_id})

	print("  multiple_world_hexes: ok")
