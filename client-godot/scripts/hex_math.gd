class_name HexMath

const SQRT3 := 1.7320508075688772

static func hex_size() -> float:
	return 80.0

static func pointy_hex_to_pixel(col: int, row: int, size: float = hex_size()) -> Vector2:
	var x := size * (SQRT3 * col + SQRT3 / 2.0 * row)
	var y := size * (3.0 / 2.0 * row)
	return Vector2(x, y)

static func pixel_to_pointy_hex(pixel: Vector2, size: float = hex_size()) -> Vector2i:
	var q := (SQRT3 / 3.0 * pixel.x - 1.0 / 3.0 * pixel.y) / size
	var r := (2.0 / 3.0 * pixel.y) / size
	return axial_round(q, r)

static func axial_round(q: float, r: float) -> Vector2i:
	var s := -q - r
	var rq := roundf(q)
	var rr := roundf(r)
	var rs := roundf(s)
	var q_diff := absf(rq - q)
	var r_diff := absf(rr - r)
	var s_diff := absf(rs - s)
	if q_diff > r_diff and q_diff > s_diff:
		rq = -rr - rs
	elif r_diff > s_diff:
		rr = -rq - rs
	return Vector2i(int(rq), int(rr))

static func pointy_hex_corners(center: Vector2, size: float = hex_size()) -> PackedVector2Array:
	var corners := PackedVector2Array()
	for i in range(6):
		var angle_deg := 60.0 * i - 30.0
		var angle_rad := deg_to_rad(angle_deg)
		corners.append(Vector2(center.x + size * cos(angle_rad), center.y + size * sin(angle_rad)))
	return corners
