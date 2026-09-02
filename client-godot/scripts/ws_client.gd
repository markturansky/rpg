extends Node

signal connected
signal disconnected
signal connection_error(message: String)
signal message_received(msg_type: String, payload: Dictionary)

var _socket := WebSocketPeer.new()
var _connected := false
var _url := ""
var _pending_requests: Dictionary = {}

func connect_to_server(url: String = "ws://localhost:8080/ws"):
	_url = url
	print("[WsClient] connect_to_server: %s" % url)
	var err := _socket.connect_to_url(url)
	if err != OK:
		print("[WsClient] connect_to_url FAILED: err=%d" % err)
		connection_error.emit("Failed to initiate connection to %s" % url)
	else:
		print("[WsClient] connect_to_url initiated successfully")

func disconnect_from_server():
	print("[WsClient] disconnect_from_server called")
	_socket.close()
	_connected = false

func is_connected_to_server() -> bool:
	return _connected

func send_message(msg_type: String, payload: Dictionary = {}):
	if not _connected:
		print("[WsClient] send_message SKIPPED (not connected): type='%s'" % msg_type)
		return
	var envelope := {"type": msg_type, "payload": payload}
	var json_str := JSON.stringify(envelope)
	print("[WsClient] >>> SEND: %s" % json_str)
	_socket.send_text(json_str)

func send_and_await(msg_type: String, payload: Dictionary = {}, response_type: String = "") -> Dictionary:
	if response_type == "":
		response_type = msg_type.trim_prefix("get_")
		if response_type == msg_type:
			response_type = msg_type
	send_message(msg_type, payload)
	var result: Array = await message_received
	if result[0] == response_type or result[0] == msg_type + "_error":
		return result[1]
	return {}

func _process(_delta: float):
	_socket.poll()

	var state := _socket.get_ready_state()

	match state:
		WebSocketPeer.STATE_OPEN:
			if not _connected:
				_connected = true
				print("[WsClient] STATE_OPEN — connection established, emitting connected")
				connected.emit()
			var pkt_count := _socket.get_available_packet_count()
			if pkt_count > 0:
				print("[WsClient] %d packets available" % pkt_count)
			while _socket.get_available_packet_count() > 0:
				var packet := _socket.get_packet()
				var text := packet.get_string_from_utf8()
				print("[WsClient] <<< RECV: %s" % text.substr(0, 200))
				_handle_message(text)

		WebSocketPeer.STATE_CLOSING:
			pass

		WebSocketPeer.STATE_CLOSED:
			if _connected:
				_connected = false
				var code := _socket.get_close_code()
				var reason := _socket.get_close_reason()
				print("[WsClient] STATE_CLOSED — code=%d reason='%s'" % [code, reason])
				disconnected.emit()
				if code != 1000:
					connection_error.emit("Connection closed: %d %s" % [code, reason])

func _handle_message(text: String):
	var json := JSON.new()
	var err := json.parse(text)
	if err != OK:
		print("[WsClient] JSON parse error: %d" % err)
		return

	var data: Dictionary = json.data
	if not data.has("type"):
		print("[WsClient] message missing 'type' field")
		return

	var msg_type: String = data["type"]
	var payload: Dictionary = {}

	if data.has("payload"):
		if data["payload"] is Dictionary:
			payload = data["payload"]
		elif data["payload"] is Array:
			payload = {"_items": data["payload"]}

	print("[WsClient] dispatching: type='%s' payload_keys=%s" % [msg_type, payload.keys()])
	message_received.emit(msg_type, payload)
