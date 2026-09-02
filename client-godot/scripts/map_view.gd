extends Control

signal back_requested

const TILE_BASE_PATH = "res://assets/map_tiles/map2"
const COLS = 4
const ROWS = 3

var _cursor_pos := Vector2(640, 360)
var _tile_container: Control
var _manifest: Dictionary = {}
var _tile_lookup: Dictionary = {}
var _current_tiles: Array[Dictionary] = []
var _address_stack: Array[String] = []
var _current_name := "map2"
var _world_width := 1.0
var _world_height := 1.0
var _pixels_per_norm_x := 1.0
var _pixels_per_norm_y := 1.0
var _view_origin_norm_x := 0.0
var _view_origin_norm_y := 0.0

func _ready():
	print("[MapView] _ready called")
	_tile_container = $TileContainer
	_load_manifest()
	_show_children_of("map2")
	$Cursor.position = _cursor_pos
	_update_breadcrumb()
	_update_coord_label()

func _parse_json_file(path: String) -> Variant:
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	var json_text = file.get_as_text()
	file.close()
	var json = JSON.new()
	var err = json.parse(json_text)
	if err != OK:
		return null
	return json.data

func _load_manifest():
	var manifest_path := TILE_BASE_PATH + "/manifest.json"
	print("[MapView] loading manifest: %s" % manifest_path)
	var data = _parse_json_file(manifest_path)
	if data == null:
		print("[MapView] FAILED to load manifest")
		return
	_manifest = data
	var tiles_array = _manifest.get("tiles", [])
	print("[MapView] manifest loaded: %d tiles" % tiles_array.size())
	for tile_entry in tiles_array:
		_tile_lookup[tile_entry["name"]] = tile_entry

func _get_children_of(parent_name: String) -> Array[Dictionary]:
	var tile_path = TILE_BASE_PATH
	if parent_name != "map2":
		var tile_data = _tile_lookup.get(parent_name, {})
		var rel_path = tile_data.get("path", "")
		tile_path = TILE_BASE_PATH + "/" + rel_path
	var tile_json_path = tile_path + "/tile.json"
	var tile_meta = _parse_json_file(tile_json_path)
	if tile_meta == null:
		return []
	var child_names = tile_meta.get("children", [])
	if child_names.is_empty():
		return []
	var children: Array[Dictionary] = []
	for child_name in child_names:
		if _tile_lookup.has(child_name):
			children.append(_tile_lookup[child_name])
	return children

func _get_parent_name(tile_name: String) -> String:
	if tile_name == "map2":
		return ""
	var parts = tile_name.split("_")
	if parts.size() <= 2:
		return "map2"
	var parent_parts: Array[String] = []
	for i in range(parts.size() - 1):
		parent_parts.append(parts[i])
	return "_".join(PackedStringArray(parent_parts))

func _get_grid_index_from_name(tile_name: String) -> int:
	var parts = tile_name.split("_")
	if parts.size() < 2:
		return -1
	var last_part = parts[parts.size() - 1]
	if not last_part.is_valid_int():
		return -1
	return int(last_part)

func _build_child_name(parent_name: String, grid_idx: int) -> String:
	return parent_name + "_%02d" % grid_idx

func _get_neighbor_crossing_parents(tile_name: String, direction: Vector2i) -> String:
	if tile_name == "map2":
		return ""
	var grid_idx = _get_grid_index_from_name(tile_name)
	if grid_idx < 0:
		return ""
	var col = grid_idx % COLS
	var row = grid_idx / COLS
	var new_col = col + direction.x
	var new_row = row + direction.y

	if new_col >= 0 and new_col < COLS and new_row >= 0 and new_row < ROWS:
		var new_idx = new_row * COLS + new_col
		var parent = _get_parent_name(tile_name)
		return _build_child_name(parent, new_idx)

	var parent = _get_parent_name(tile_name)
	var parent_dir_x = 0
	var parent_dir_y = 0
	var wrapped_col = new_col
	var wrapped_row = new_row

	if new_col < 0:
		parent_dir_x = -1
		wrapped_col = COLS - 1
	elif new_col >= COLS:
		parent_dir_x = 1
		wrapped_col = 0

	if new_row < 0:
		parent_dir_y = -1
		wrapped_row = ROWS - 1
	elif new_row >= ROWS:
		parent_dir_y = 1
		wrapped_row = 0

	var adjacent_parent = _get_neighbor_crossing_parents(parent, Vector2i(parent_dir_x, parent_dir_y))
	if adjacent_parent == "":
		return ""

	var wrapped_idx = wrapped_row * COLS + wrapped_col
	return _build_child_name(adjacent_parent, wrapped_idx)

func _collect_neighbors_at_depth(center_name: String) -> Array[String]:
	var neighbors: Array[String] = []
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			if dx == 0 and dy == 0:
				continue
			var neighbor = _get_neighbor_crossing_parents(center_name, Vector2i(dx, dy))
			if neighbor != "" and _tile_lookup.has(neighbor):
				neighbors.append(neighbor)
	return neighbors

func _show_children_of(parent_name: String):
	for child in _tile_container.get_children():
		child.queue_free()
	_current_tiles.clear()
	_current_name = parent_name

	var children = _get_children_of(parent_name)
	if children.is_empty():
		_show_leaf_tile(parent_name)
		return

	var parent_data = _tile_lookup.get(parent_name, {})
	var parent_bounds = parent_data.get("bounds", [0, 0, 1, 1])
	var pb_x0 = float(parent_bounds[0])
	var pb_y0 = float(parent_bounds[1])
	var pb_x1 = float(parent_bounds[2])
	var pb_y1 = float(parent_bounds[3])

	var first_child = children[0]
	var fc_bounds = first_child.get("bounds", [0, 0, 1, 1])
	var cell_norm_w = float(fc_bounds[2]) - float(fc_bounds[0])
	var cell_norm_h = float(fc_bounds[3]) - float(fc_bounds[1])

	var fc_path_str = first_child.get("path", "")
	var fc_img_path = TILE_BASE_PATH + "/" + fc_path_str + "/" + first_child["name"] + ".png"
	var fc_tex = _load_texture_from_file(fc_img_path)
	if fc_tex == null:
		return
	var tile_pixel_w = float(fc_tex.get_width())
	var tile_pixel_h = float(fc_tex.get_height())

	_pixels_per_norm_x = tile_pixel_w / cell_norm_w
	_pixels_per_norm_y = tile_pixel_h / cell_norm_h

	var tiles_to_render: Array[Dictionary] = []

	for child_data in children:
		tiles_to_render.append(child_data)

	if parent_name != "map2":
		var neighbor_parents = _collect_neighbors_at_depth(parent_name)
		for neighbor_parent in neighbor_parents:
			var neighbor_children = _get_children_of(neighbor_parent)
			for child_data in neighbor_children:
				tiles_to_render.append(child_data)

	var min_norm_x = pb_x0
	var min_norm_y = pb_y0
	var max_norm_x = pb_x1
	var max_norm_y = pb_y1

	for tile_data in tiles_to_render:
		var t_bounds = tile_data.get("bounds", [0, 0, 1, 1])
		var tx0 = float(t_bounds[0])
		var ty0 = float(t_bounds[1])
		var tx1 = float(t_bounds[2])
		var ty1 = float(t_bounds[3])
		if tx0 < min_norm_x:
			min_norm_x = tx0
		if ty0 < min_norm_y:
			min_norm_y = ty0
		if tx1 > max_norm_x:
			max_norm_x = tx1
		if ty1 > max_norm_y:
			max_norm_y = ty1

	_view_origin_norm_x = min_norm_x
	_view_origin_norm_y = min_norm_y
	_world_width = (max_norm_x - min_norm_x) * _pixels_per_norm_x
	_world_height = (max_norm_y - min_norm_y) * _pixels_per_norm_y

	for child_data in tiles_to_render:
		var c_bounds = child_data.get("bounds", [0, 0, 1, 1])
		var cx0 = float(c_bounds[0])
		var cy0 = float(c_bounds[1])
		var cx1 = float(c_bounds[2])
		var cy1 = float(c_bounds[3])

		var pos_x = (cx0 - min_norm_x) * _pixels_per_norm_x
		var pos_y = (cy0 - min_norm_y) * _pixels_per_norm_y
		var size_w = (cx1 - cx0) * _pixels_per_norm_x
		var size_h = (cy1 - cy0) * _pixels_per_norm_y

		var rel_path = child_data.get("path", "")
		var child_name = child_data.get("name", "")
		if child_name == "":
			continue
		var img_path = TILE_BASE_PATH + "/" + rel_path + "/" + child_name + ".png"
		var tex = _load_texture_from_file(img_path)
		if tex == null:
			continue

		var rect = TextureRect.new()
		rect.texture = tex
		rect.position = Vector2(pos_x, pos_y)
		rect.size = Vector2(size_w, size_h)
		rect.expand_mode = 1
		rect.stretch_mode = 4
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_tile_container.add_child(rect)
		_current_tiles.append(child_data)

	_fit_to_window()

func _show_leaf_tile(parent_name: String):
	var tile_data = _tile_lookup.get(parent_name, {})
	var rel_path = tile_data.get("path", ".")
	var img_path = TILE_BASE_PATH + "/" + rel_path + "/" + parent_name + ".png"
	if rel_path == ".":
		img_path = TILE_BASE_PATH + "/" + parent_name + ".png"
	var tex = _load_texture_from_file(img_path)
	if tex == null:
		return
	_world_width = float(tex.get_width())
	_world_height = float(tex.get_height())
	var rect = TextureRect.new()
	rect.texture = tex
	rect.position = Vector2.ZERO
	rect.size = Vector2(_world_width, _world_height)
	rect.expand_mode = 1
	rect.stretch_mode = 4
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tile_container.add_child(rect)
	_current_tiles.append(tile_data)
	_fit_to_window()

func _load_texture_from_file(path: String) -> Texture2D:
	if not FileAccess.file_exists(path):
		return null
	var img = Image.new()
	var err = img.load(path)
	if err != OK:
		return null
	return ImageTexture.create_from_image(img)

func _navigate_direction(direction: Vector2i):
	if _current_name == "map2":
		return
	var neighbor = _get_neighbor_crossing_parents(_current_name, direction)
	if neighbor == "" or not _tile_lookup.has(neighbor):
		return
	var neighbor_children = _get_children_of(neighbor)
	if neighbor_children.is_empty() and _get_children_of(_current_name).is_empty():
		_address_stack.clear()
		var parts = neighbor.split("_")
		for i in range(2, parts.size()):
			var ancestor_parts: Array[String] = []
			for j in range(i):
				ancestor_parts.append(parts[j])
			_address_stack.append("_".join(PackedStringArray(ancestor_parts)))
		_show_children_of(neighbor)
		_update_breadcrumb()
		_update_coord_label()
		return
	if neighbor_children.is_empty():
		return
	_address_stack.clear()
	var parts = neighbor.split("_")
	for i in range(2, parts.size()):
		var ancestor_parts: Array[String] = []
		for j in range(i):
			ancestor_parts.append(parts[j])
		_address_stack.append("_".join(PackedStringArray(ancestor_parts)))
	_show_children_of(neighbor)
	_update_breadcrumb()
	_update_coord_label()

func _zoom_into_tile(tile_idx: int):
	if tile_idx < 0 or tile_idx >= _current_tiles.size():
		return
	var tile_data = _current_tiles[tile_idx]
	var tile_name = tile_data.get("name", "")
	if tile_name == "":
		return
	var children = _get_children_of(tile_name)
	if children.is_empty():
		return
	_address_stack.append(_current_name)
	_show_children_of(tile_name)
	_update_breadcrumb()

func _zoom_out():
	if _address_stack.is_empty():
		return
	var parent_name = _address_stack.pop_back()
	_show_children_of(parent_name)
	_update_breadcrumb()

func _update_breadcrumb():
	var parts = _current_name.split("_")
	var trail = parts[0]
	for i in range(1, parts.size()):
		trail = trail + " > " + parts[i]
	var viewing_depth = parts.size()
	var is_leaf = false
	var center_children = _get_children_of(_current_name)
	if not center_children.is_empty():
		is_leaf = center_children[0].get("is_leaf", false)
	elif _current_tiles.size() > 0:
		is_leaf = _current_tiles[0].get("is_leaf", false)
	var leaf_str = "  (max depth)" if is_leaf else ""
	var nav_hint = "  [Arrows=pan]" if _current_name != "map2" else ""
	$BreadcrumbLabel.text = "Depth %d  |  %s%s%s" % [viewing_depth, trail, leaf_str, nav_hint]

func _fit_to_window():
	var win_size = get_viewport_rect().size
	var sx = win_size.x / _world_width
	var sy = win_size.y / _world_height
	var s = sx if sx < sy else sy
	_tile_container.scale = Vector2(s, s)
	var drawn = Vector2(_world_width, _world_height) * s
	_tile_container.position = (win_size - drawn) * 0.5

func _notification(what):
	if what == NOTIFICATION_RESIZED:
		if _tile_container != null:
			_fit_to_window()

func _input(event: InputEvent):
	if event is InputEventMouseMotion:
		_cursor_pos = event.position
		$Cursor.position = _cursor_pos
		_update_coord_label()
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var tile_idx = _get_tile_under_cursor()
			if tile_idx >= 0:
				_zoom_into_tile(tile_idx)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_zoom_out()
	elif event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			if _address_stack.is_empty():
				back_requested.emit()
			else:
				_zoom_out()
		elif event.keycode == KEY_LEFT:
			_navigate_direction(Vector2i(-1, 0))
		elif event.keycode == KEY_RIGHT:
			_navigate_direction(Vector2i(1, 0))
		elif event.keycode == KEY_UP:
			_navigate_direction(Vector2i(0, -1))
		elif event.keycode == KEY_DOWN:
			_navigate_direction(Vector2i(0, 1))

func _get_tile_under_cursor() -> int:
	if _tile_container == null or _current_tiles.is_empty():
		return -1
	var local_pos = (_cursor_pos - _tile_container.position) / _tile_container.scale
	var px = local_pos.x
	var py = local_pos.y
	if px < 0 or py < 0 or px >= _world_width or py >= _world_height:
		return -1
	for i in range(_current_tiles.size()):
		var child_node = _tile_container.get_child(i)
		if child_node == null:
			continue
		var cpos = child_node.position
		var csz = child_node.size
		if px >= cpos.x and px < cpos.x + csz.x and py >= cpos.y and py < cpos.y + csz.y:
			return i
	return -1

func _update_coord_label():
	if _tile_container == null:
		return
	var local_pos = (_cursor_pos - _tile_container.position) / _tile_container.scale
	var px = local_pos.x
	var py = local_pos.y
	if px >= 0 and py >= 0 and px < _world_width and py < _world_height:
		var tile_idx = _get_tile_under_cursor()
		var tile_name = ""
		if tile_idx >= 0 and tile_idx < _current_tiles.size():
			tile_name = _current_tiles[tile_idx].get("name", "")
		var is_leaf = false
		if tile_idx >= 0 and tile_idx < _current_tiles.size():
			is_leaf = _current_tiles[tile_idx].get("is_leaf", false)
		var action = "(leaf)" if is_leaf else "Click=zoom"
		$CoordLabel.text = "%s  |  %s  Right-click=back" % [tile_name, action]
	else:
		$CoordLabel.text = "Right-click to zoom out"


