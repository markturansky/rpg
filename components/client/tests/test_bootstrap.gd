extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var scene: PackedScene = load("res://scenes/main.tscn")
	assert(scene != null)
	var main: Node2D = scene.instantiate()
	root.add_child(main)
	await process_frame
	assert(main.is_player_centered())
	print("bootstrap: player centered and scene initialized")
	quit()
