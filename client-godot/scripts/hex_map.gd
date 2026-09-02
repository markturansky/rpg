extends Node2D

signal hex_clicked(col: int, row: int)
signal hex_hovered(col: int, row: int)

var grid_cols: int = 10
var grid_rows: int = 10
var terrain_grid: Array = []
var hovered_hex := Vector2i(-1, -1)
var selected_hex := Vector2i(-1, -1)
var _hex_size: float = HexMath.hex_size()

func setup(cols: int, rows: int, grid: Array, hex_size: float = HexMath.hex_size()):
	print("[HexMap] setup: %d cols x %d rows, hex_size=%.1f, grid_rows=%d" % [cols, rows, hex_size, grid.size()])
	grid_cols = cols
	grid_rows = rows
	terrain_grid = grid
	_hex_size = hex_size
	queue_redraw()

func _draw():
	for row in range(grid_rows):
		if row >= terrain_grid.size():
			break
		for col in range(grid_cols):
			if col >= terrain_grid[row].size():
				break
			var center := HexMath.pointy_hex_to_pixel(col, row, _hex_size)
			var corners := HexMath.pointy_hex_corners(center, _hex_size)
			var terrain_type: TerrainData.TerrainType = terrain_grid[row][col]
			var color: Color = TerrainData.TERRAIN_COLORS[terrain_type]

			if selected_hex == Vector2i(col, row):
				color = color.lightened(0.4)
			elif hovered_hex == Vector2i(col, row):
				color = color.lightened(0.25)

			draw_colored_polygon(corners, color)
			draw_polyline(corners + PackedVector2Array([corners[0]]), Color(0, 0, 0, 0.25), 1.0)

	if selected_hex.x >= 0 and selected_hex.x < grid_cols and selected_hex.y >= 0 and selected_hex.y < grid_rows:
		var center := HexMath.pointy_hex_to_pixel(selected_hex.x, selected_hex.y, _hex_size)
		var corners := HexMath.pointy_hex_corners(center, _hex_size)
		draw_polyline(corners + PackedVector2Array([corners[0]]), Color(1, 1, 1, 0.8), 2.0)

func _input(event: InputEvent):
	if event is InputEventMouseMotion:
		var mouse_pos := get_local_mouse_position()
		var new_hover := HexMath.pixel_to_pointy_hex(mouse_pos, _hex_size)
		if new_hover != hovered_hex:
			hovered_hex = new_hover
			queue_redraw()
			if _is_valid_hex(new_hover):
				hex_hovered.emit(new_hover.x, new_hover.y)

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos := get_local_mouse_position()
		var clicked := HexMath.pixel_to_pointy_hex(mouse_pos, _hex_size)
		if _is_valid_hex(clicked):
			selected_hex = clicked
			queue_redraw()
			hex_clicked.emit(clicked.x, clicked.y)

func _is_valid_hex(coord: Vector2i) -> bool:
	return coord.x >= 0 and coord.x < grid_cols and coord.y >= 0 and coord.y < grid_rows

func get_terrain_at(col: int, row: int) -> TerrainData.TerrainType:
	if row >= 0 and row < terrain_grid.size() and col >= 0 and col < terrain_grid[row].size():
		return terrain_grid[row][col]
	return TerrainData.TerrainType.PLAINS
