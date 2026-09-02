extends Node

const WORLD_SEED := 42

var character: Dictionary = {}
var character_id: int = 0

signal character_updated(data: Dictionary)
signal move_result_received(result: Dictionary)
signal zoom_result_received(result: Dictionary)

func has_character() -> bool:
	return character_id > 0

func get_character_name() -> String:
	return character.get("name", "")

func get_character_hp() -> int:
	return int(character.get("hp", 0))

func get_character_max_hp() -> int:
	return int(character.get("max_hp", 0))

func get_character_level() -> int:
	return int(character.get("level", 1))

func get_character_gold() -> int:
	return int(character.get("gold", 0))

func get_character_class() -> String:
	return character.get("class_id", "")

func get_current_address() -> String:
	var addr = character.get("current_address", "")
	if addr == "":
		addr = character.get("current_tile", "")
	if addr == "" or addr == "map2" or addr.begins_with("map2_"):
		return "/0,0"
	return addr

func get_current_depth() -> int:
	return HexAddress.depth(get_current_address())

func get_current_tier_name() -> String:
	var tier := HexAddress.tier(get_current_address())
	return TierData.TIER_NAMES[tier]

func get_current_scale_label() -> String:
	var tier := HexAddress.tier(get_current_address())
	return TierData.TIER_SCALE_LABEL[tier]

func get_game_day() -> int:
	return int(character.get("game_day", 1))

func get_game_hour() -> float:
	return float(character.get("game_hour", 8.0))

func can_zoom_in() -> bool:
	return get_current_depth() < HexAddress.MAX_DEPTH

func can_zoom_out() -> bool:
	return get_current_depth() > 1

func update_from_move_result(result: Dictionary):
	var old_addr := get_current_address()
	character["current_address"] = result.get("new_address", get_current_address())
	character["game_day"] = result.get("game_day", get_game_day())
	character["game_hour"] = result.get("game_hour", get_game_hour())
	print("[GameState] move result: '%s' -> '%s'" % [old_addr, get_current_address()])
	character_updated.emit(character)
	move_result_received.emit(result)

func update_from_zoom_result(result: Dictionary):
	var old_addr := get_current_address()
	character["current_address"] = result.get("new_address", get_current_address())
	print("[GameState] zoom result: '%s' -> '%s'" % [old_addr, get_current_address()])
	character_updated.emit(character)
	zoom_result_received.emit(result)

func request_move(direction: int):
	print("[GameState] request_move: direction=%d has_character=%s" % [direction, has_character()])
	if not has_character():
		return
	WsClient.send_message("move", {
		"character_id": character_id,
		"direction": direction,
	})

func request_zoom_in(child_index: int):
	print("[GameState] request_zoom_in: child=%d can_zoom=%s addr='%s'" % [child_index, can_zoom_in(), get_current_address()])
	if not has_character() or not can_zoom_in():
		return
	WsClient.send_message("zoom_in", {
		"character_id": character_id,
		"child_index": child_index,
	})

func request_zoom_out():
	print("[GameState] request_zoom_out: can_zoom=%s addr='%s'" % [can_zoom_out(), get_current_address()])
	if not has_character() or not can_zoom_out():
		return
	WsClient.send_message("zoom_out", {
		"character_id": character_id,
	})
