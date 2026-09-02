extends Node2D

const VIEW_SCENES := {
	"connect_screen": "res://scenes/connect_screen.tscn",
	"world_tier": "res://scenes/world_tier.tscn",
}

var _current_view_key := ""
var _previous_view_key := ""

func _ready():
	print("[Main] _ready called")
	_show_view("connect_screen")

func _show_view(view_key: String):
	print("[Main] _show_view requested: '%s' (current='%s')" % [view_key, _current_view_key])
	if view_key == _current_view_key:
		return
	if not VIEW_SCENES.has(view_key):
		print("[Main] _show_view FAILED — unknown view key '%s'" % view_key)
		return

	_previous_view_key = _current_view_key
	_current_view_key = view_key
	print("[Main] transitioning: '%s' -> '%s'" % [_previous_view_key, _current_view_key])

	for child in $CurrentView.get_children():
		child.queue_free()

	var scene_path: String = VIEW_SCENES[view_key]
	var scene := load(scene_path) as PackedScene
	if scene == null:
		print("[Main] _show_view FAILED — could not load scene '%s'" % scene_path)
		return
	var instance := scene.instantiate()
	$CurrentView.add_child(instance)

	_connect_view_signals(instance)
	_update_hud_visibility()
	print("[Main] _show_view complete: now showing '%s'" % view_key)

func _connect_view_signals(view: Node):
	if view.has_signal("enter_world"):
		view.enter_world.connect(_on_enter_world)
	if view.has_signal("hud_terrain_updated"):
		view.hud_terrain_updated.connect(_on_hud_terrain_updated)
	if view.has_signal("hud_tier_updated"):
		view.hud_tier_updated.connect(_on_hud_tier_updated)
	if view.has_signal("hud_status_updated"):
		view.hud_status_updated.connect(_on_hud_status_updated)
	if view.has_signal("hud_hint_updated"):
		view.hud_hint_updated.connect(_on_hud_hint_updated)
	if view.has_signal("hud_character_updated"):
		view.hud_character_updated.connect(_on_hud_character_updated)
	if view.has_signal("hud_time_updated"):
		view.hud_time_updated.connect(_on_hud_time_updated)

func _update_hud_visibility():
	var is_gameplay := _current_view_key == "world_tier"
	$HUD/TierLabel.visible = is_gameplay
	$HUD/TerrainLabel.visible = is_gameplay
	$HUD/HintLabel.visible = is_gameplay
	$HUD/CharacterLabel.visible = is_gameplay
	$HUD/TimeLabel.visible = is_gameplay
	$HUD/StatusLabel.visible = is_gameplay

func _on_enter_world():
	print("[Main] >>> enter_world signal received")
	_show_view("world_tier")

func _on_hud_terrain_updated(text: String):
	$HUD/TerrainLabel.text = text

func _on_hud_tier_updated(text: String):
	$HUD/TierLabel.text = text

func _on_hud_status_updated(text: String):
	$HUD/StatusLabel.text = text

func _on_hud_hint_updated(text: String):
	$HUD/HintLabel.text = text

func _on_hud_character_updated(text: String):
	$HUD/CharacterLabel.text = text

func _on_hud_time_updated(text: String):
	$HUD/TimeLabel.text = text
