extends Node

const SERVER_PORT := 8080
const HEALTH_CHECK_INTERVAL := 0.5
const MAX_HEALTH_CHECKS := 20

var _server_pid: int = -1
var _server_ready := false
var _health_check_timer: Timer
var _health_checks_remaining: int = 0
var _http_request: HTTPRequest

signal server_started
signal server_failed(reason: String)

func _ready():
	print("[ServerProcess] _ready called")
	_start_server()

func _notification(what: int):
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE:
		_kill_server()

func _exit_tree():
	_kill_server()

func is_server_ready() -> bool:
	return _server_ready

func get_server_url() -> String:
	return "ws://127.0.0.1:%d/ws" % SERVER_PORT

func _start_server():
	print("[ServerProcess] _start_server: probing http://127.0.0.1:%d/health" % SERVER_PORT)
	_http_request = HTTPRequest.new()
	add_child(_http_request)
	_http_request.request_completed.connect(_on_probe_response)
	_http_request.request("http://127.0.0.1:%d/health" % SERVER_PORT)

func _on_probe_response(result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray):
	_http_request.request_completed.disconnect(_on_probe_response)
	if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
		print("[ServerProcess] external server already running on port %d, adopting" % SERVER_PORT)
		_server_ready = true
		server_started.emit()
		return
	_launch_server()

func _launch_server():
	print("[ServerProcess] _launch_server called")
	_kill_stale_server()

	var server_path := _find_server_binary()
	print("[ServerProcess] server binary: '%s'" % server_path)
	if server_path == "":
		print("[ServerProcess] FAILED — no server binary found")
		server_failed.emit("Could not find rpg-server binary")
		return

	var db_path := _get_database_path()
	var args := PackedStringArray([
		"-addr", ":%d" % SERVER_PORT,
		"-db", db_path,
	])

	print("[ServerProcess] starting: %s %s" % [server_path, " ".join(args)])
	_server_pid = OS.create_process(server_path, args)
	if _server_pid <= 0:
		server_failed.emit("Failed to start server process")
		return
	print("[ServerProcess] pid=%d" % _server_pid)

	_http_request.request_completed.connect(_on_health_response)
	_start_health_polling()

func _find_server_binary() -> String:
	var exe_dir := OS.get_executable_path().get_base_dir()
	print("[ServerProcess] exe_dir: %s" % exe_dir)

	var candidates := [
		exe_dir.path_join("rpg-server"),
		exe_dir.path_join("../rpg-server"),
		ProjectSettings.globalize_path("res://").path_join("build/rpg-server"),
		ProjectSettings.globalize_path("res://").path_join("rpg-server"),
	]

	for path in candidates:
		var exists := FileAccess.file_exists(path)
		print("[ServerProcess] candidate '%s' exists=%s" % [path, exists])
		if exists:
			return path

	return ""

func _get_database_path() -> String:
	var dir := OS.get_executable_path().get_base_dir()
	DirAccess.make_dir_recursive_absolute(dir)
	return dir.path_join("rpg.db")

func _start_health_polling():
	_health_checks_remaining = MAX_HEALTH_CHECKS

	_health_check_timer = Timer.new()
	_health_check_timer.wait_time = HEALTH_CHECK_INTERVAL
	_health_check_timer.timeout.connect(_poll_health)
	add_child(_health_check_timer)
	_health_check_timer.start()

func _poll_health():
	_health_checks_remaining -= 1
	print("[ServerProcess] _poll_health: remaining=%d" % _health_checks_remaining)
	if _health_checks_remaining <= 0:
		_health_check_timer.stop()
		print("[ServerProcess] health check timeout")
		server_failed.emit("Server did not become healthy in time")
		return

	if not OS.is_process_running(_server_pid):
		_health_check_timer.stop()
		print("[ServerProcess] server process exited unexpectedly")
		server_failed.emit("Server process exited unexpectedly")
		return

	_http_request.request("http://127.0.0.1:%d/health" % SERVER_PORT)

func _on_health_response(result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray):
	print("[ServerProcess] health response: result=%d code=%d" % [result, response_code])
	if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
		_health_check_timer.stop()
		_server_ready = true
		print("[ServerProcess] server is healthy, emitting server_started")
		server_started.emit()

func _kill_stale_server():
	var output: Array = []
	OS.execute("fuser", PackedStringArray(["%d/tcp" % SERVER_PORT]), output, true, true)
	if output.size() > 0:
		var pids_str: String = output[0].strip_edges()
		if pids_str != "":
			print("[ServerProcess] killing stale process on port %d: %s" % [SERVER_PORT, pids_str])
			for pid_part in pids_str.split(" "):
				var pid := int(pid_part.strip_edges())
				if pid > 0:
					OS.kill(pid)
			OS.delay_msec(500)

func _kill_server():
	if _server_pid > 0 and OS.is_process_running(_server_pid):
		OS.kill(_server_pid)
		_server_pid = -1
