class_name HexAddress

const CHILDREN_PER_HEX := 6
const MAX_DEPTH := 6

const DEPTH_TO_TIER := {
	1: TierData.Tier.WORLD,
	2: TierData.Tier.REGIONAL,
	3: TierData.Tier.LOCAL,
	4: TierData.Tier.DISTRICT,
	5: TierData.Tier.STREET,
	6: TierData.Tier.TACTICAL,
}

const PRIME_A := 73856093
const PRIME_B := 19349663
const PRIME_C := 83492791
const PRIME_D := 4256249

const POINTY_HEX_NEIGHBOR_OFFSETS := [
	Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 1),
	Vector2i(-1, 0), Vector2i(0, -1), Vector2i(1, -1),
]

static func root() -> String:
	return "/"

static func world_address(q: int, r: int) -> String:
	return "/%d,%d" % [q, r]

static func parse_world_coord(address: String) -> Vector2i:
	var segments := _address_segments(address)
	if segments.is_empty():
		return Vector2i(0, 0)
	return _parse_qr(segments[0])

static func is_world_address(address: String) -> bool:
	var segments := _address_segments(address)
	if segments.is_empty():
		return false
	return segments[0].contains(",")

static func _parse_qr(segment: String) -> Vector2i:
	var parts := segment.split(",")
	if parts.size() != 2:
		return Vector2i(0, 0)
	return Vector2i(int(parts[0]), int(parts[1]))

static func _address_segments(address: String) -> Array[String]:
	var trimmed := address.trim_prefix("/")
	if trimmed == "":
		return []
	var result: Array[String] = []
	for s in trimmed.split("/"):
		result.append(s)
	return result

static func child(parent_address: String, child_index: int) -> String:
	return "%s/%d" % [parent_address, child_index]

static func parent(address: String) -> String:
	if address == "/" or address == "":
		return "/"
	var last_slash := address.rfind("/")
	if last_slash <= 0:
		return "/"
	return address.substr(0, last_slash)

static func depth(address: String) -> int:
	if address == "/" or address == "":
		return 0
	return _address_segments(address).size()

static func tier(address: String) -> TierData.Tier:
	var d := depth(address)
	if d < 1 or d > 6:
		return TierData.Tier.WORLD
	return DEPTH_TO_TIER[d]

static func leaf_index(address: String) -> int:
	if address == "/":
		return -1
	var last_slash := address.rfind("/")
	var last_segment := address.substr(last_slash + 1)
	if last_segment.contains(","):
		return -1
	return int(last_segment)

static func sub_indices(address: String) -> Array[int]:
	var segments := _address_segments(address)
	if segments.size() <= 1:
		return []
	var result: Array[int] = []
	for i in range(1, segments.size()):
		result.append(int(segments[i]))
	return result

static func indices(address: String) -> Array[int]:
	var segments := _address_segments(address)
	if segments.is_empty():
		return []
	if segments[0].contains(","):
		return sub_indices(address)
	var result: Array[int] = []
	for s in segments:
		result.append(int(s))
	return result

static func from_indices(idx_array: Array[int]) -> String:
	if idx_array.is_empty():
		return "/"
	var parts: Array[String] = []
	for i in idx_array:
		parts.append(str(i))
	return "/" + "/".join(parts)

static func hex_root(address: String) -> String:
	var segments := _address_segments(address)
	if segments.is_empty():
		return ""
	return "/" + segments[0]

static func world_neighbor(q: int, r: int, direction: int) -> Vector2i:
	if direction < 0 or direction >= 6:
		return Vector2i(q, r)
	var offset: Vector2i = POINTY_HEX_NEIGHBOR_OFFSETS[direction]
	return Vector2i(q + offset.x, r + offset.y)

static func seed_for_address(address: String, world_seed: int) -> int:
	var segments := _address_segments(address)
	if segments.is_empty():
		return world_seed

	var hash_val := world_seed

	if segments[0].contains(","):
		var qr := _parse_qr(segments[0])
		var qu := absi(qr.x)
		if qr.x < 0:
			qu = qu | (1 << 31)
		var ru := absi(qr.y)
		if qr.y < 0:
			ru = ru | (1 << 31)
		hash_val = _hash_combine(hash_val, qu, 1)
		hash_val = _hash_combine(hash_val, ru, 2)

		for i in range(1, segments.size()):
			hash_val = _hash_combine(hash_val, int(segments[i]), i + 2)
	else:
		for i in range(segments.size()):
			hash_val = _hash_combine(hash_val, int(segments[i]), i)

	if hash_val < 0:
		hash_val = -hash_val
	return hash_val

static func terrain_for_address(address: String, world_seed: int) -> TerrainData.TerrainType:
	var d := depth(address)
	if d == 0:
		return TerrainData.TerrainType.PLAINS

	if d == 1:
		var qr := parse_world_coord(address)
		return _world_terrain(qr.x, qr.y)

	var parent_addr := parent(address)
	var parent_terrain := terrain_for_address(parent_addr, world_seed)
	var s := seed_for_address(address, world_seed)
	var elevation := _seed_to_float(s, 0)
	var moisture := _seed_to_float(s, 1)
	var bias := _terrain_bias(parent_terrain)
	elevation = lerpf(elevation, bias[0], 0.7)
	moisture = lerpf(moisture, bias[1], 0.7)
	var candidate := TerrainData.terrain_from_elevation(elevation, moisture)
	var allowed := _allowed_child_terrains(parent_terrain)
	if candidate in allowed:
		return candidate
	return allowed[0]

static func children_addresses(address: String) -> Array[String]:
	var result: Array[String] = []
	for i in range(CHILDREN_PER_HEX):
		result.append(child(address, i))
	return result

static func is_ancestor(ancestor: String, descendant: String) -> bool:
	if ancestor == "/":
		return descendant != "/"
	return descendant.begins_with(ancestor + "/")

static func total_hexes_below(tiers_remaining: int) -> int:
	if tiers_remaining <= 0:
		return 1
	var total := 1
	var layer := 1
	for i in range(tiers_remaining):
		layer *= CHILDREN_PER_HEX
		total += layer
	return total

static func world_hex_count(world_hex_cols: int, world_hex_rows: int) -> int:
	return world_hex_cols * world_hex_rows

static func total_world_hexes(world_hex_cols: int, world_hex_rows: int) -> int:
	var per_world_hex := total_hexes_below(MAX_DEPTH - 1)
	return world_hex_cols * world_hex_rows * per_world_hex

static func col_row_to_index(col: int, row: int, cols: int) -> int:
	return row * cols + col

static func index_to_col_row(index: int, cols: int) -> Vector2i:
	return Vector2i(index % cols, index / cols)

static func _hash_combine(current: int, child_idx: int, depth_val: int) -> int:
	return (current ^ (child_idx * PRIME_A + depth_val * PRIME_B)) * PRIME_C + PRIME_D

static func _seed_to_float(s: int, channel: int) -> float:
	var mixed := ((s + channel * PRIME_A) * PRIME_C) & 0x7FFFFFFF
	return float(mixed % 10000) / 10000.0 * 2.0 - 1.0

static func _terrain_bias(terrain: TerrainData.TerrainType) -> Array:
	match terrain:
		TerrainData.TerrainType.DEEP_WATER: return [-0.5, 0.5]
		TerrainData.TerrainType.SHALLOW_WATER: return [-0.2, 0.5]
		TerrainData.TerrainType.BEACH: return [-0.05, 0.4]
		TerrainData.TerrainType.PLAINS: return [0.1, 0.3]
		TerrainData.TerrainType.GRASSLAND: return [0.15, 0.5]
		TerrainData.TerrainType.FOREST: return [0.2, 0.65]
		TerrainData.TerrainType.DENSE_FOREST: return [0.35, 0.75]
		TerrainData.TerrainType.HILLS: return [0.55, 0.4]
		TerrainData.TerrainType.MOUNTAIN: return [0.75, 0.3]
		TerrainData.TerrainType.DESERT: return [0.2, 0.1]
		TerrainData.TerrainType.MARSH: return [0.05, 0.85]
		TerrainData.TerrainType.TUNDRA: return [0.3, 0.15]
		TerrainData.TerrainType.ROAD: return [0.1, 0.3]
		_: return [0.1, 0.5]

static func _allowed_child_terrains(parent_type: TerrainData.TerrainType) -> Array:
	match parent_type:
		TerrainData.TerrainType.DEEP_WATER:
			return [TerrainData.TerrainType.DEEP_WATER, TerrainData.TerrainType.SHALLOW_WATER]
		TerrainData.TerrainType.SHALLOW_WATER:
			return [TerrainData.TerrainType.SHALLOW_WATER, TerrainData.TerrainType.DEEP_WATER, TerrainData.TerrainType.BEACH]
		TerrainData.TerrainType.BEACH:
			return [TerrainData.TerrainType.BEACH, TerrainData.TerrainType.SHALLOW_WATER, TerrainData.TerrainType.PLAINS, TerrainData.TerrainType.GRASSLAND, TerrainData.TerrainType.MARSH]
		TerrainData.TerrainType.PLAINS:
			return [TerrainData.TerrainType.PLAINS, TerrainData.TerrainType.GRASSLAND, TerrainData.TerrainType.FOREST, TerrainData.TerrainType.HILLS, TerrainData.TerrainType.DESERT, TerrainData.TerrainType.ROAD]
		TerrainData.TerrainType.GRASSLAND:
			return [TerrainData.TerrainType.GRASSLAND, TerrainData.TerrainType.PLAINS, TerrainData.TerrainType.FOREST, TerrainData.TerrainType.MARSH, TerrainData.TerrainType.ROAD]
		TerrainData.TerrainType.FOREST:
			return [TerrainData.TerrainType.FOREST, TerrainData.TerrainType.DENSE_FOREST, TerrainData.TerrainType.GRASSLAND, TerrainData.TerrainType.HILLS, TerrainData.TerrainType.ROAD]
		TerrainData.TerrainType.DENSE_FOREST:
			return [TerrainData.TerrainType.DENSE_FOREST, TerrainData.TerrainType.FOREST, TerrainData.TerrainType.MARSH, TerrainData.TerrainType.HILLS]
		TerrainData.TerrainType.HILLS:
			return [TerrainData.TerrainType.HILLS, TerrainData.TerrainType.MOUNTAIN, TerrainData.TerrainType.GRASSLAND, TerrainData.TerrainType.FOREST, TerrainData.TerrainType.PLAINS]
		TerrainData.TerrainType.MOUNTAIN:
			return [TerrainData.TerrainType.MOUNTAIN, TerrainData.TerrainType.HILLS, TerrainData.TerrainType.TUNDRA]
		TerrainData.TerrainType.DESERT:
			return [TerrainData.TerrainType.DESERT, TerrainData.TerrainType.PLAINS, TerrainData.TerrainType.HILLS]
		TerrainData.TerrainType.MARSH:
			return [TerrainData.TerrainType.MARSH, TerrainData.TerrainType.GRASSLAND, TerrainData.TerrainType.SHALLOW_WATER, TerrainData.TerrainType.FOREST]
		TerrainData.TerrainType.TUNDRA:
			return [TerrainData.TerrainType.TUNDRA, TerrainData.TerrainType.HILLS, TerrainData.TerrainType.MOUNTAIN, TerrainData.TerrainType.PLAINS]
		_:
			return [parent_type]

static func _world_terrain(q: int, r: int) -> TerrainData.TerrainType:
	var fq := float(q)
	var fr := float(r)
	var x := fq + fr * 0.5
	var y := fr * 0.866025

	var elevation := _continent_elevation(x, y, fq, fr)
	var moisture := _continent_moisture(x, y, fq, fr, elevation)

	elevation = clampf(elevation, -1.0, 1.0)
	moisture = clampf(moisture, -1.0, 1.0)
	return TerrainData.terrain_from_elevation(elevation, moisture)

static func _landmass(x: float, y: float, cx: float, cy: float, rx: float, ry: float, angle_offset: float) -> float:
	var dx := (x - cx) / rx
	var dy := (y - cy) / ry
	var d := sqrt(dx * dx + dy * dy)
	var base := 1.0 - d
	var a := atan2(dy, dx)
	base += sin(a * 3.0 + angle_offset) * 0.08
	base += sin(a * 5.0 + angle_offset * 1.7) * 0.04
	base += sin(a * 7.0 + angle_offset * 2.3) * 0.025
	base += sin(a * 11.0 + angle_offset * 3.1) * 0.015
	return base

static func _bay(x: float, y: float, cx: float, cy: float, sx: float, sy: float) -> float:
	return maxf(0.0, 1.0 - ((x - cx) * (x - cx) / sx + (y - cy) * (y - cy) / sy))

static func _ridge(x: float, y: float, x1: float, y1: float, x2: float, y2: float, width: float, strength: float) -> float:
	var dx := x2 - x1
	var dy := y2 - y1
	var len_sq := dx * dx + dy * dy
	if len_sq < 0.001:
		return 0.0
	var t := clampf(((x - x1) * dx + (y - y1) * dy) / len_sq, 0.0, 1.0)
	var px := x1 + t * dx
	var py := y1 + t * dy
	var dist := sqrt((x - px) * (x - px) + (y - py) * (y - py))
	return maxf(0.0, strength * (1.0 - dist / width))

static func _continent_elevation(x: float, y: float, fq: float, fr: float) -> float:
	var main_body := _landmass(x, y, -50.0, -25.0, 425.0, 300.0, 0.5)
	var east_wing := _landmass(x, y, 250.0, 25.0, 275.0, 225.0, 1.3)
	var north_lobe := _landmass(x, y, 50.0, -225.0, 200.0, 150.0, 2.7)
	var south_reach := _landmass(x, y, 0.0, 200.0, 250.0, 125.0, 3.1)
	var great_kingdom := _landmass(x, y, 350.0, 75.0, 175.0, 150.0, 0.9)
	var tilvanot := _landmass(x, y, 150.0, 250.0, 90.0, 75.0, 4.2)
	var northwest_horn := _landmass(x, y, -300.0, -150.0, 125.0, 100.0, 1.8)

	var combined := maxf(main_body, maxf(east_wing, maxf(north_lobe, maxf(south_reach, maxf(great_kingdom, maxf(tilvanot, northwest_horn))))))

	var azure_sea := _bay(x, y, 50.0, 150.0, 22500.0, 10000.0)
	combined -= azure_sea * 0.7

	var grendep_bay := _bay(x, y, 225.0, -150.0, 10000.0, 6250.0)
	combined -= grendep_bay * 0.6

	var woolly_bay := _bay(x, y, -75.0, 75.0, 6250.0, 5000.0)
	combined -= woolly_bay * 0.5

	var nyr_dyv := _bay(x, y, 25.0, -25.0, 4500.0, 2000.0)
	combined -= nyr_dyv * 0.55

	var densac_gulf := _bay(x, y, 100.0, 240.0, 7500.0, 2500.0)
	combined -= densac_gulf * 0.5

	var aerdi_sea := _bay(x, y, 375.0, 150.0, 5000.0, 8750.0)
	combined -= aerdi_sea * 0.55

	var icy_channel := _bay(x, y, 100.0, -275.0, 15000.0, 2000.0)
	combined -= icy_channel * 0.4

	var crystalmist := _ridge(x, y, -200.0, 100.0, -125.0, -125.0, 60.0, 0.5)
	var barrier_peaks := _ridge(x, y, -125.0, -125.0, -75.0, -200.0, 50.0, 0.45)
	var corusk := _ridge(x, y, 150.0, -200.0, 300.0, -150.0, 50.0, 0.4)
	var griff := _ridge(x, y, 125.0, -150.0, 175.0, -75.0, 40.0, 0.35)
	var lortmil := _ridge(x, y, -100.0, 0.0, -50.0, 75.0, 40.0, 0.35)
	var yatil := _ridge(x, y, -175.0, -150.0, -100.0, -100.0, 45.0, 0.4)
	var abbor_alz := _ridge(x, y, 75.0, 25.0, 150.0, 75.0, 35.0, 0.3)
	var iron_hills := _ridge(x, y, 200.0, 50.0, 275.0, 25.0, 40.0, 0.3)
	var hellfurnaces := _ridge(x, y, -225.0, 125.0, -175.0, 175.0, 50.0, 0.45)
	var sulhaut := _ridge(x, y, -250.0, 150.0, -150.0, 150.0, 40.0, 0.35)

	var ridge_total := maxf(crystalmist, maxf(barrier_peaks, maxf(corusk, maxf(griff, maxf(lortmil, maxf(yatil, maxf(abbor_alz, maxf(iron_hills, maxf(hellfurnaces, sulhaut)))))))))

	var elevation := combined * 0.45 + ridge_total * 0.75

	elevation += sin(fq * 0.16 + fr * 0.22) * 0.12
	elevation += sin(fq * 0.1 + fr * 0.14 + 1.5) * 0.09
	elevation += sin(fq * 0.06 + fr * 0.04 + 3.2) * 0.06
	elevation += sin(fq * 0.26 + fr * 0.08 + 2.1) * 0.05
	elevation += sin(fq * 0.034 + fr * 0.046 + 4.7) * 0.04

	if y < -200.0 and combined > 0.0:
		elevation += (absf(y) - 200.0) * 0.001

	return elevation

static func _continent_moisture(x: float, y: float, fq: float, fr: float, elevation: float) -> float:
	var moisture := 0.42

	var near_coast := maxf(0.0, 1.0 - absf(elevation) / 0.12) * 0.18
	moisture += near_coast

	if x > 250.0:
		moisture += 0.12
	if x < -250.0:
		moisture += 0.08

	moisture += sin(fq * 0.14 + fr * 0.1 + 3.1) * 0.15
	moisture += sin(fq * 0.08 + fr * 0.18 + 0.7) * 0.1
	moisture += sin(fq * 0.22 + fr * 0.06 + 5.3) * 0.07
	moisture += sin(fq * 0.04 + fr * 0.12 + 2.0) * 0.05

	moisture -= maxf(0.0, elevation - 0.35) * 0.45

	if y < -175.0 and elevation > -0.1:
		moisture -= (absf(y) - 175.0) * 0.0016

	var sea_of_dust_dist := sqrt((x + 200.0) * (x + 200.0) / 10000.0 + (y - 150.0) * (y - 150.0) / 5000.0)
	if sea_of_dust_dist < 1.0:
		moisture -= (1.0 - sea_of_dust_dist) * 0.5

	var dry_steppes_dist := sqrt((x + 275.0) * (x + 275.0) / 7500.0 + (y - 50.0) * (y - 50.0) / 5000.0)
	if dry_steppes_dist < 1.0:
		moisture -= (1.0 - dry_steppes_dist) * 0.35

	var vesve_dist := sqrt((x + 50.0) * (x + 50.0) / 7500.0 + (y + 100.0) * (y + 100.0) / 5000.0)
	if vesve_dist < 1.0:
		moisture += (1.0 - vesve_dist) * 0.2

	var grandwood_dist := sqrt((x - 275.0) * (x - 275.0) / 6250.0 + (y - 50.0) * (y - 50.0) / 5000.0)
	if grandwood_dist < 1.0:
		moisture += (1.0 - grandwood_dist) * 0.2

	var cold_marsh_dist := sqrt((x + 25.0) * (x + 25.0) / 5000.0 + (y + 225.0) * (y + 225.0) / 2500.0)
	if cold_marsh_dist < 1.0:
		moisture += (1.0 - cold_marsh_dist) * 0.35

	var vast_swamp_dist := sqrt((x - 250.0) * (x - 250.0) / 3750.0 + (y - 125.0) * (y - 125.0) / 2500.0)
	if vast_swamp_dist < 1.0:
		moisture += (1.0 - vast_swamp_dist) * 0.3

	return moisture
