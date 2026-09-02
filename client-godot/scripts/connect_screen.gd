extends Control

signal enter_world

var _ancestries: Array = []
var _classes: Array = []
var _awaiting_data := 0

func _ready():
	print("[ConnectScreen] _ready called")
	$ConnectPanel/ConnectButton.pressed.connect(_on_connect_pressed)
	$CharacterPanel.visible = false

	print("[ConnectScreen] connecting WsClient signals")
	WsClient.connected.connect(_on_connected)
	WsClient.disconnected.connect(_on_disconnected)
	WsClient.connection_error.connect(_on_connection_error)
	WsClient.message_received.connect(_on_message_received)

	print("[ConnectScreen] ServerProcess.is_server_ready() = %s" % ServerProcess.is_server_ready())
	if ServerProcess.is_server_ready():
		print("[ConnectScreen] server already ready, auto-connecting")
		_auto_connect()
	else:
		print("[ConnectScreen] server not ready, waiting for startup")
		$StatusLabel.text = "Starting server..."
		$ConnectPanel.visible = false
		ServerProcess.server_started.connect(_on_server_started)
		ServerProcess.server_failed.connect(_on_server_failed)

func _on_server_started():
	print("[ConnectScreen] >>> server_started signal received")
	_auto_connect()

func _on_server_failed(reason: String):
	print("[ConnectScreen] >>> server_failed: %s" % reason)
	$StatusLabel.text = "Server failed: %s\nConnect manually below." % reason
	$ConnectPanel.visible = true

func _auto_connect():
	var url := ServerProcess.get_server_url()
	print("[ConnectScreen] _auto_connect to: %s" % url)
	$StatusLabel.text = "Connecting to server..."
	$ConnectPanel.visible = false
	WsClient.connect_to_server(url)

func _on_connect_pressed():
	var url: String = $ConnectPanel/AddressInput.text.strip_edges()
	if url == "":
		url = "ws://localhost:8080/ws"
	print("[ConnectScreen] manual connect pressed: %s" % url)
	$StatusLabel.text = "Connecting to %s..." % url
	$ConnectPanel/ConnectButton.disabled = true
	WsClient.connect_to_server(url)

func _on_connected():
	print("[ConnectScreen] >>> connected signal received — loading game data")
	$StatusLabel.text = "Connected! Loading game data..."
	$ConnectPanel.visible = false
	_awaiting_data = 2
	print("[ConnectScreen] sending: get_ancestries, get_classes")
	WsClient.send_message("get_ancestries")
	WsClient.send_message("get_classes")

func _on_disconnected():
	print("[ConnectScreen] >>> disconnected signal received")
	$StatusLabel.text = "Disconnected from server"
	$ConnectPanel.visible = true
	$ConnectPanel/ConnectButton.disabled = false
	$CharacterPanel.visible = false

func _on_connection_error(message: String):
	print("[ConnectScreen] >>> connection_error: %s" % message)
	$StatusLabel.text = "Error: %s" % message
	$ConnectPanel.visible = true
	$ConnectPanel/ConnectButton.disabled = false

func _on_message_received(msg_type: String, payload: Dictionary):
	print("[ConnectScreen] >>> message received: type='%s' keys=%s" % [msg_type, payload.keys()])
	match msg_type:
		"ancestries":
			_ancestries = payload.get("_items", [])
			print("[ConnectScreen] received %d ancestries, awaiting=%d" % [_ancestries.size(), _awaiting_data - 1])
			_awaiting_data -= 1
			_check_data_loaded()
		"classes":
			_classes = payload.get("_items", [])
			print("[ConnectScreen] received %d classes, awaiting=%d" % [_classes.size(), _awaiting_data - 1])
			_awaiting_data -= 1
			_check_data_loaded()
		"character_created":
			print("[ConnectScreen] character created: %s" % payload)
			_on_character_created(payload)
		"character_created_error":
			print("[ConnectScreen] character creation error: %s" % payload)
			$StatusLabel.text = "Error: %s" % payload.get("error", "unknown")

func _check_data_loaded():
	print("[ConnectScreen] _check_data_loaded: awaiting=%d" % _awaiting_data)
	if _awaiting_data <= 0:
		print("[ConnectScreen] all data loaded — auto-creating character")
		_auto_create_character()

func _auto_create_character():
	print("[ConnectScreen] _auto_create_character: ancestries=%d classes=%d" % [_ancestries.size(), _classes.size()])
	if _ancestries.is_empty() or _classes.is_empty():
		print("[ConnectScreen] ABORT — no ancestries or classes")
		$StatusLabel.text = "No ancestries or classes available"
		return

	var ancestry_id: String = _ancestries[0].get("id", "")
	var class_id: String = _classes[0].get("id", "")
	print("[ConnectScreen] auto-creating: ancestry='%s' class='%s'" % [ancestry_id, class_id])

	var payload := {
		"name": "Adventurer",
		"ancestry_id": ancestry_id,
		"class_id": class_id,
		"str": 14,
		"dex": 14,
		"con": 14,
		"int_": 14,
		"wis": 14,
		"cha": 14,
		"world_seed": GameState.WORLD_SEED,
	}

	$StatusLabel.text = "Creating character..."
	WsClient.send_message("create_character", payload)

func _show_character_panel():
	$CharacterPanel.visible = true

	var ancestry_select: OptionButton = $CharacterPanel/AncestrySelect
	ancestry_select.clear()
	for a in _ancestries:
		ancestry_select.add_item(a.get("name", "?"))

	var class_select: OptionButton = $CharacterPanel/ClassSelect
	class_select.clear()
	for c in _classes:
		class_select.add_item(c.get("name", "?"))

	$CharacterPanel/ButtonRow/RollButton.pressed.connect(_on_roll_pressed)
	$CharacterPanel/ButtonRow/CreateButton.pressed.connect(_on_create_pressed)
	_on_roll_pressed()

func _on_roll_pressed():
	$CharacterPanel/StrRow/StrValue.text = str(_roll_3d6())
	$CharacterPanel/DexRow/DexValue.text = str(_roll_3d6())
	$CharacterPanel/ConRow/ConValue.text = str(_roll_3d6())
	$CharacterPanel/IntRow/IntValue.text = str(_roll_3d6())
	$CharacterPanel/WisRow/WisValue.text = str(_roll_3d6())
	$CharacterPanel/ChaRow/ChaValue.text = str(_roll_3d6())

func _on_create_pressed():
	var char_name: String = $CharacterPanel/NameInput.text.strip_edges()
	if char_name == "":
		$StatusLabel.text = "Enter a character name"
		return

	var ancestry_idx: int = $CharacterPanel/AncestrySelect.selected
	var class_idx: int = $CharacterPanel/ClassSelect.selected
	if ancestry_idx < 0 or class_idx < 0:
		$StatusLabel.text = "Select ancestry and class"
		return

	var ancestry_id: String = _ancestries[ancestry_idx].get("id", "")
	var class_id: String = _classes[class_idx].get("id", "")

	var payload := {
		"name": char_name,
		"ancestry_id": ancestry_id,
		"class_id": class_id,
		"str": int($CharacterPanel/StrRow/StrValue.text),
		"dex": int($CharacterPanel/DexRow/DexValue.text),
		"con": int($CharacterPanel/ConRow/ConValue.text),
		"int_": int($CharacterPanel/IntRow/IntValue.text),
		"wis": int($CharacterPanel/WisRow/WisValue.text),
		"cha": int($CharacterPanel/ChaRow/ChaValue.text),
		"world_seed": GameState.WORLD_SEED,
	}

	$StatusLabel.text = "Creating character..."
	WsClient.send_message("create_character", payload)

func _on_character_created(data: Dictionary):
	print("[ConnectScreen] _on_character_created: id=%s name='%s' address='%s'" % [data.get("id", "?"), data.get("name", "?"), data.get("current_address", "?")])
	GameState.character = data
	GameState.character_id = int(data.get("id", 0))
	print("[ConnectScreen] GameState.character_id = %d" % GameState.character_id)
	$StatusLabel.text = "Character created! Entering world..."
	print("[ConnectScreen] waiting 0.5s before emitting enter_world")
	await get_tree().create_timer(0.5).timeout
	print("[ConnectScreen] >>> EMITTING enter_world signal")
	enter_world.emit()

func _roll_3d6() -> int:
	return randi_range(1, 6) + randi_range(1, 6) + randi_range(1, 6)
