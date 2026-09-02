class_name TileLoader

static func tile_url(address: String, host: String, port: int, size: int = 256) -> String:
	var base := "http://%s:%d/tiles/%s" % [host, port, address]
	if size != 256:
		base += "?size=%d" % size
	return base

static func to_server_address(address: String) -> String:
	return address

static func grid_position(col: int, row: int, viewport_size: Vector2) -> Vector2:
	var cell_size := viewport_size / 10.0
	return Vector2(col * cell_size.x, row * cell_size.y)

static func grid_cell_size(viewport_size: Vector2) -> Vector2:
	return viewport_size / 10.0

class TileCache:
	var _max_size: int
	var _entries: Dictionary = {}
	var _access_order: Array[String] = []

	func _init(max_size: int):
		_max_size = max_size

	func put(key: String, image: Image):
		if _entries.has(key):
			_access_order.erase(key)
		elif _entries.size() >= _max_size:
			var oldest := _access_order[0]
			_access_order.remove_at(0)
			_entries.erase(oldest)
		_entries[key] = image
		_access_order.append(key)

	func get_tile(key: String) -> Image:
		if not _entries.has(key):
			return null
		_access_order.erase(key)
		_access_order.append(key)
		return _entries[key]

	func has(key: String) -> bool:
		return _entries.has(key)

	func size() -> int:
		return _entries.size()

	func clear():
		_entries.clear()
		_access_order.clear()
