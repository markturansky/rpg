extends Control

signal back_requested

const SPRITES_IMAGE_PATH = "res://assets/sprites.png"
const SPRITES_JSON_PATH = "res://assets/sprites.json"
const GRID_COLUMNS = 10
const CELL_PADDING = 4
const SCROLL_SPEED = 40.0

var _sprite_data: Array = []
var _scroll_offset := 0.0
var _max_scroll := 0.0
var _tile_container: Control
var _spritesheet_texture: Texture2D

const CATEGORY_COLORS = {
	"topography": Color(0.18, 0.42, 0.12),
	"roads": Color(0.55, 0.45, 0.33),
	"buildings": Color(0.63, 0.25, 0.25),
}

func _ready():
	print("[SpriteAtlas] _ready called")
	_tile_container = $TileContainer
	$BackButton.pressed.connect(_return_to_map)
	_load_sprites()
	_build_grid()

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

func _load_sprites():
	print("[SpriteAtlas] loading spritesheet: %s" % SPRITES_IMAGE_PATH)
	var tex = load(SPRITES_IMAGE_PATH)
	if tex == null:
		print("[SpriteAtlas] FAILED to load spritesheet texture")
		return
	print("[SpriteAtlas] spritesheet loaded: %dx%d" % [tex.get_width(), tex.get_height()])
	_spritesheet_texture = tex

	print("[SpriteAtlas] loading sprite data: %s" % SPRITES_JSON_PATH)
	var data = _parse_json_file(SPRITES_JSON_PATH)
	if data == null:
		print("[SpriteAtlas] FAILED to load/parse sprites.json")
		return
	_sprite_data = data.get("sprites", [])
	print("[SpriteAtlas] loaded %d sprites" % _sprite_data.size())

func _build_grid():
	for child in _tile_container.get_children():
		child.queue_free()

	if _spritesheet_texture == null or _sprite_data.is_empty():
		return

	var win_size = get_viewport_rect().size
	var cell_size = floori((win_size.x - CELL_PADDING * (GRID_COLUMNS + 1)) / GRID_COLUMNS)

	var cur_x = CELL_PADDING
	var cur_y = 40
	var col_index = 0
	var current_category = ""
	var sprite_count = _sprite_data.size()

	var title_label = Label.new()
	title_label.text = "Sprite Atlas — %d sprites" % sprite_count
	title_label.position = Vector2(win_size.x / 2 - 120, 8)
	title_label.add_theme_color_override("font_color", Color(0.94, 0.75, 0.25))
	title_label.add_theme_font_size_override("font_size", 18)
	_tile_container.add_child(title_label)

	for i in range(sprite_count):
		var sprite_entry = _sprite_data[i]
		var category = sprite_entry.get("category", "")

		if category != current_category:
			if current_category != "":
				cur_x = CELL_PADDING
				cur_y += cell_size + CELL_PADDING
				col_index = 0

			current_category = category
			var cat_label = Label.new()
			cat_label.text = category.to_upper()
			cat_label.position = Vector2(CELL_PADDING, cur_y)
			var cat_color = CATEGORY_COLORS.get(category, Color.WHITE)
			cat_label.add_theme_color_override("font_color", cat_color)
			cat_label.add_theme_font_size_override("font_size", 16)
			_tile_container.add_child(cat_label)
			cur_y += 24

		if col_index >= GRID_COLUMNS:
			cur_x = CELL_PADDING
			cur_y += cell_size + CELL_PADDING
			col_index = 0

		var sx = int(sprite_entry.get("x", 0))
		var sy = int(sprite_entry.get("y", 0))
		var sw = int(sprite_entry.get("w", 1))
		var sh = int(sprite_entry.get("h", 1))

		var bg_rect = ColorRect.new()
		bg_rect.color = Color(0.1, 0.1, 0.18, 0.8)
		bg_rect.position = Vector2(cur_x, cur_y)
		bg_rect.size = Vector2(cell_size, cell_size)
		bg_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_tile_container.add_child(bg_rect)

		var atlas_tex = AtlasTexture.new()
		atlas_tex.atlas = _spritesheet_texture
		atlas_tex.region = Rect2(sx, sy, sw, sh)

		var scale_factor = minf(float(cell_size) / float(sw), float(cell_size) / float(sh))
		if scale_factor > 1.0:
			scale_factor = 1.0
		var display_w = sw * scale_factor
		var display_h = sh * scale_factor

		var tex_rect = TextureRect.new()
		tex_rect.texture = atlas_tex
		tex_rect.position = Vector2(cur_x + (cell_size - display_w) / 2, cur_y + (cell_size - display_h) / 2)
		tex_rect.size = Vector2(display_w, display_h)
		tex_rect.expand_mode = 1
		tex_rect.stretch_mode = 4
		tex_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_tile_container.add_child(tex_rect)

		var name_label = Label.new()
		name_label.text = sprite_entry.get("name", "")
		name_label.position = Vector2(cur_x, cur_y + cell_size - 14)
		name_label.size = Vector2(cell_size, 14)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.add_theme_color_override("font_color", Color(0.67, 0.67, 0.67))
		name_label.add_theme_font_size_override("font_size", 9)
		name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_tile_container.add_child(name_label)

		cur_x += cell_size + CELL_PADDING
		col_index += 1

	_max_scroll = maxf(0.0, cur_y + cell_size + CELL_PADDING - win_size.y)

func _input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_scroll_offset = clampf(_scroll_offset - SCROLL_SPEED, 0.0, _max_scroll)
			_tile_container.position.y = -_scroll_offset
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_scroll_offset = clampf(_scroll_offset + SCROLL_SPEED, 0.0, _max_scroll)
			_tile_container.position.y = -_scroll_offset
	elif event is InputEventKey and event.pressed:
		if event.keycode == KEY_UP:
			_scroll_offset = clampf(_scroll_offset - SCROLL_SPEED, 0.0, _max_scroll)
			_tile_container.position.y = -_scroll_offset
		elif event.keycode == KEY_DOWN:
			_scroll_offset = clampf(_scroll_offset + SCROLL_SPEED, 0.0, _max_scroll)
			_tile_container.position.y = -_scroll_offset
		elif event.keycode == KEY_ESCAPE:
			_return_to_map()

func _return_to_map():
	print("[SpriteAtlas] back_requested emitted")
	back_requested.emit()

func _notification(what):
	if what == NOTIFICATION_RESIZED:
		if _tile_container != null:
			_scroll_offset = 0.0
			_build_grid()
