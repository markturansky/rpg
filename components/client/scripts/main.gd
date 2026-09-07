extends Node2D

const GRASS_COLOR: Color = Color("3f8f45")
const GRASS_BLADE_COLOR: Color = Color("57aa50")
const SHADOW_COLOR: Color = Color(0.06, 0.12, 0.05, 0.35)
const TUNIC_COLOR: Color = Color("315a9d")
const CAPE_COLOR: Color = Color("b64242")
const SKIN_COLOR: Color = Color("e8bd8f")
const HAIR_COLOR: Color = Color("4b2b1a")

var player_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_center_player()

func _draw() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, viewport_size), GRASS_COLOR)
	_draw_grass(viewport_size)
	_draw_player()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		get_tree().quit()

func is_player_centered() -> bool:
	return player_position.is_equal_approx(get_viewport_rect().size * 0.5)

func _on_viewport_size_changed() -> void:
	_center_player()

func _center_player() -> void:
	player_position = get_viewport_rect().size * 0.5
	queue_redraw()

func _draw_grass(viewport_size: Vector2) -> void:
	var spacing: float = 48.0
	var rows: int = int(ceil(viewport_size.y / spacing)) + 1
	var columns: int = int(ceil(viewport_size.x / spacing)) + 1
	for row: int in rows:
		for column: int in columns:
			var offset_x: float = 12.0 if row % 2 == 0 else 36.0
			var blade_position := Vector2(column * spacing + offset_x, row * spacing + 20.0)
			draw_line(blade_position, blade_position + Vector2(-3.0, -9.0), GRASS_BLADE_COLOR, 2.0)
			draw_line(blade_position + Vector2(4.0, 0.0), blade_position + Vector2(7.0, -7.0), GRASS_BLADE_COLOR, 2.0)

func _draw_player() -> void:
	_draw_shadow(player_position + Vector2(0.0, 19.0), Vector2(19.0, 7.0), SHADOW_COLOR)
	draw_colored_polygon(PackedVector2Array([
		player_position + Vector2(-16.0, 16.0),
		player_position + Vector2(16.0, 16.0),
		player_position + Vector2(10.0, -14.0),
		player_position + Vector2(-10.0, -14.0),
	]), CAPE_COLOR)
	draw_rect(Rect2(player_position + Vector2(-10.0, -10.0), Vector2(20.0, 25.0)), TUNIC_COLOR)
	draw_circle(player_position + Vector2(0.0, -20.0), 11.0, SKIN_COLOR)
	draw_circle(player_position + Vector2(0.0, -25.0), 11.0, HAIR_COLOR)
	draw_circle(player_position + Vector2(0.0, -21.0), 9.5, SKIN_COLOR)
	draw_rect(Rect2(player_position + Vector2(-11.0, 14.0), Vector2(8.0, 8.0)), HAIR_COLOR)
	draw_rect(Rect2(player_position + Vector2(3.0, 14.0), Vector2(8.0, 8.0)), HAIR_COLOR)

func _draw_shadow(center: Vector2, radii: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for index: int in 24:
		var angle: float = TAU * float(index) / 24.0
		points.append(center + Vector2(cos(angle) * radii.x, sin(angle) * radii.y))
	draw_colored_polygon(points, color)
