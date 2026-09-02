extends Control

signal hud_terrain_updated(text: String)
signal hud_tier_updated(text: String)
signal hud_status_updated(text: String)
signal hud_hint_updated(text: String)
signal hud_character_updated(text: String)
signal hud_time_updated(text: String)

const VIEWPORT_TILES := 10
const SERVER_HOST := "127.0.0.1"
const SERVER_PORT := 8080
const TILE_SHEET := "terrain-tileset.png"
const MOVE_COOLDOWN := 0.12

var _map_width := 0
var _map_height := 0
var _sprites: Array = []
var _grid: Array = []
var _sheet_texture: Texture2D = null
var _player_x := 50
var _player_y := 50
var _tile_rects: Array = []
var _move_timer := 0.0
var _map_loaded := false

func _ready():
	print("[WorldTier] _ready: loading map data")
	hud_status_updated.emit("Loading world...")
	_load_sheet()
	_request_map()

func _load_sheet():
	var path := "res://assets/%s" % TILE_SHEET
	if ResourceLoader.exists(path):
		_sheet_texture = load(path) as Texture2D
		print("[WorldTier] sheet loaded: %s %dx%d" % [path, _sheet_texture.get_width(), _sheet_texture.get_height()])
	else:
		print("[WorldTier] WARNING: sheet not found at %s" % path)

func _request_map():
	var url := "http://%s:%d/map" % [SERVER_HOST, SERVER_PORT]
	var http := HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_map_loaded.bind(http))
	var err := http.request(url)
	if err != OK:
		print("[WorldTier] map request FAILED: err=%d" % err)
		http.queue_free()
		hud_status_updated.emit("Failed to load map")

func _on_map_loaded(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray, http: HTTPRequest):
	http.queue_free()

	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		print("[WorldTier] map load FAILED: result=%d code=%d" % [result, response_code])
		hud_status_updated.emit("Map load failed")
		return

	var json := JSON.new()
	var parse_err := json.parse(body.get_string_from_utf8())
	if parse_err != OK:
		print("[WorldTier] JSON parse FAILED")
		hud_status_updated.emit("Map parse failed")
		return

	var data: Dictionary = json.data
	_map_width = int(data.get("width", 0))
	_map_height = int(data.get("height", 0))
	_sprites = data.get("sprites", [])
	_grid = data.get("grid", [])
	_map_loaded = true

	_build_sprite_rects()

	print("[WorldTier] map loaded: %dx%d, %d sprites" % [_map_width, _map_height, _sprites.size()])
	hud_status_updated.emit("")
	hud_hint_updated.emit("WASD / Arrow keys to move")
	_render_viewport()
	_update_hud()

func _build_sprite_rects():
	_tile_rects.clear()
	for sprite in _sprites:
		var r := Rect2(
			float(sprite.get("x", 0)),
			float(sprite.get("y", 0)),
			float(sprite.get("w", 64)),
			float(sprite.get("h", 64))
		)
		_tile_rects.append(r)

func _render_viewport():
	if not _map_loaded or _sheet_texture == null:
		return

	_clear_tile_grid()

	var viewport_size := get_viewport_rect().size
	var cell_w := viewport_size.x / VIEWPORT_TILES
	var cell_h := viewport_size.y / VIEWPORT_TILES

	var half := VIEWPORT_TILES / 2
	var start_x := _player_x - half
	var start_y := _player_y - half

	for vy in range(VIEWPORT_TILES):
		for vx in range(VIEWPORT_TILES):
			var world_x := start_x + vx
			var world_y := start_y + vy

			var sprite_idx := _grid_at(world_x, world_y)
			if sprite_idx < 0 or sprite_idx >= _tile_rects.size():
				var fallback := ColorRect.new()
				fallback.position = Vector2(vx * cell_w, vy * cell_h)
				fallback.size = Vector2(cell_w, cell_h)
				fallback.color = Color(0.05, 0.08, 0.15)
				fallback.mouse_filter = Control.MOUSE_FILTER_IGNORE
				$TileGrid.add_child(fallback)
				continue

			var src_rect: Rect2 = _tile_rects[sprite_idx]
			var atlas_tex := AtlasTexture.new()
			atlas_tex.atlas = _sheet_texture
			atlas_tex.region = src_rect

			var tex_rect := TextureRect.new()
			tex_rect.texture = atlas_tex
			tex_rect.position = Vector2(vx * cell_w, vy * cell_h)
			tex_rect.size = Vector2(cell_w, cell_h)
			tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tex_rect.stretch_mode = TextureRect.STRETCH_SCALE
			tex_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
			$TileGrid.add_child(tex_rect)

			if world_x == _player_x and world_y == _player_y:
				var marker := ColorRect.new()
				var marker_size := Vector2(cell_w * 0.3, cell_h * 0.3)
				marker.position = Vector2(vx * cell_w + (cell_w - marker_size.x) / 2.0, vy * cell_h + (cell_h - marker_size.y) / 2.0)
				marker.size = marker_size
				marker.color = Color(1.0, 0.85, 0.2, 0.9)
				marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
				$TileGrid.add_child(marker)

func _grid_at(x: int, y: int) -> int:
	if x < 0 or x >= _map_width or y < 0 or y >= _map_height:
		return 6
	return int(_grid[y][x])

func _clear_tile_grid():
	for child in $TileGrid.get_children():
		$TileGrid.remove_child(child)
		child.free()

func _process(delta: float):
	if _move_timer > 0:
		_move_timer -= delta

func _input(event: InputEvent):
	if not _map_loaded:
		return

	if event is InputEventKey and event.pressed:
		if _move_timer > 0:
			return
		var moved := false
		match event.keycode:
			KEY_W, KEY_UP:
				if _player_y > 0:
					_player_y -= 1
					moved = true
			KEY_S, KEY_DOWN:
				if _player_y < _map_height - 1:
					_player_y += 1
					moved = true
			KEY_A, KEY_LEFT:
				if _player_x > 0:
					_player_x -= 1
					moved = true
			KEY_D, KEY_RIGHT:
				if _player_x < _map_width - 1:
					_player_x += 1
					moved = true

		if moved:
			_move_timer = MOVE_COOLDOWN
			_render_viewport()
			_update_hud()

func _update_hud():
	if not _map_loaded:
		return

	var sprite_idx := _grid_at(_player_x, _player_y)
	var terrain_name := "unknown"
	if sprite_idx >= 0 and sprite_idx < _sprites.size():
		terrain_name = _sprites[sprite_idx].get("name", "unknown")
	terrain_name = terrain_name.replace("terrain-", "").replace("-", " ")

	hud_terrain_updated.emit("%s  (%d, %d)" % [terrain_name.capitalize(), _player_x, _player_y])
	hud_tier_updated.emit("Overworld")

	if GameState.has_character():
		_update_character_hud()

func _update_character_hud():
	var day := GameState.get_game_day()
	var hour := GameState.get_game_hour()
	var hour_int := int(hour)
	var minute := int((hour - float(hour_int)) * 60.0)
	hud_character_updated.emit("%s  Lv%d  HP %d/%d  Gold %d" % [
		GameState.get_character_name(),
		GameState.get_character_level(),
		GameState.get_character_hp(),
		GameState.get_character_max_hp(),
		GameState.get_character_gold(),
	])
	hud_time_updated.emit("Day %d  %02d:%02d" % [day, hour_int, minute])
