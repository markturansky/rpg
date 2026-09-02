import json
import websocket

WS_URL = "ws://localhost:8081/ws"
passed = 0
failed = 0

def send_recv(ws, msg_type, payload=None):
    msg = {"type": msg_type}
    if payload:
        msg["payload"] = payload
    else:
        msg["payload"] = {}
    ws.send(json.dumps(msg))
    resp = json.loads(ws.recv())
    return resp

def check(name, condition):
    global passed, failed
    if condition:
        passed += 1
        print(f"  PASS: {name}")
    else:
        failed += 1
        print(f"  FAIL: {name}")

ws = websocket.create_connection(WS_URL)

print("\n=== Reference Data ===")
for msg_type, resp_type in [
    ("get_ancestries", "ancestries"),
    ("get_classes", "classes"),
    ("get_weapons", "weapons"),
    ("get_armor", "armor"),
    ("get_shields", "shields"),
    ("get_terrain", "terrain"),
    ("get_monsters", "monsters"),
    ("get_spells", "spells"),
    ("get_items", "items"),
]:
    resp = send_recv(ws, msg_type)
    data = json.loads(resp["payload"]) if isinstance(resp["payload"], str) else resp["payload"]
    check(f"{msg_type} returns data", resp["type"] == resp_type and len(data) > 0)

print("\n=== Character Creation ===")
resp = send_recv(ws, "create_character", {
    "name": "TestHero",
    "ancestry_id": "human",
    "class_id": "fighter",
    "str": 16, "dex": 12, "con": 14, "int_": 10, "wis": 10, "cha": 10,
    "world_seed": 42
})
char_data = json.loads(resp["payload"]) if isinstance(resp["payload"], str) else resp["payload"]
check("character created", resp["type"] == "character_created")
check("character has id", "id" in char_data and char_data["id"] > 0)
check("character has current_address", "current_address" in char_data)
check("current_address is /0", char_data["current_address"] == "/0")
check("no world_col field", "world_col" not in char_data)
check("no world_row field", "world_row" not in char_data)
check("no current_tier field", "current_tier" not in char_data)
char_id = char_data["id"]

print("\n=== Get Character ===")
resp = send_recv(ws, "get_character", {"character_id": char_id})
char = json.loads(resp["payload"]) if isinstance(resp["payload"], str) else resp["payload"]
check("get character returns data", resp["type"] == "character")
check("current_address is /0", char["current_address"] == "/0")

print("\n=== Move (direction 0-5) ===")
for direction in range(6):
    resp = send_recv(ws, "move", {"character_id": char_id, "direction": direction})
    move_data = json.loads(resp["payload"]) if isinstance(resp["payload"], str) else resp["payload"]
    if resp["type"] == "move_result":
        check(f"move direction {direction} success", move_data["success"] == True)
        check(f"move direction {direction} has new_address", "new_address" in move_data)
        check(f"move direction {direction} has tier_name", "tier_name" in move_data)
        check(f"move direction {direction} has depth", "depth" in move_data and move_data["depth"] == 1)
        check(f"move direction {direction} has terrain_id", "terrain_id" in move_data)
    elif "error" in resp["type"] and "impassable" in move_data.get("error", ""):
        check(f"move direction {direction} blocked by impassable terrain", True)
    else:
        check(f"move direction {direction} valid response", resp["type"] == "move_result" or "error" in resp["type"])

print("\n=== Invalid Move Direction ===")
resp = send_recv(ws, "move", {"character_id": char_id, "direction": 7})
check("invalid direction rejected", "error" in resp["type"])

resp = send_recv(ws, "move", {"character_id": char_id, "direction": -1})
check("negative direction rejected", "error" in resp["type"])

print("\n=== Zoom In ===")
resp = send_recv(ws, "get_character", {"character_id": char_id})
char = json.loads(resp["payload"]) if isinstance(resp["payload"], str) else resp["payload"]
current_addr = char["current_address"]
print(f"  Current address before zoom: {current_addr}")

resp = send_recv(ws, "zoom_in", {"character_id": char_id, "child_index": 0})
zoom_data = json.loads(resp["payload"]) if isinstance(resp["payload"], str) else resp["payload"]
check("zoom_in returns zoom_result", resp["type"] == "zoom_result")
check("zoom_in success", zoom_data["success"] == True)
check("zoom_in depth increased", zoom_data["depth"] == 2)
check("zoom_in tier is regional", zoom_data["tier_name"] == "regional")
check("zoom_in has siblings", "siblings" in zoom_data and len(zoom_data["siblings"]) == 6)
check("zoom_in has terrain_id", "terrain_id" in zoom_data)
new_addr_after_zoom = zoom_data["new_address"]
print(f"  Address after zoom in: {new_addr_after_zoom}")

resp = send_recv(ws, "get_character", {"character_id": char_id})
char = json.loads(resp["payload"]) if isinstance(resp["payload"], str) else resp["payload"]
check("character address updated after zoom_in", char["current_address"] == new_addr_after_zoom)

print("\n=== Zoom In Again (to local) ===")
resp = send_recv(ws, "zoom_in", {"character_id": char_id, "child_index": 3})
zoom_data = json.loads(resp["payload"]) if isinstance(resp["payload"], str) else resp["payload"]
check("zoom to local success", zoom_data["success"] == True)
check("zoom to local depth 3", zoom_data["depth"] == 3)
check("zoom to local tier", zoom_data["tier_name"] == "local")

print("\n=== Move at Local Tier ===")
resp = send_recv(ws, "move", {"character_id": char_id, "direction": 2})
move_data = json.loads(resp["payload"]) if isinstance(resp["payload"], str) else resp["payload"]
if resp["type"] == "move_result":
    check("move at local tier success", move_data["success"] == True)
    check("move at local tier depth 3", move_data["depth"] == 3)
else:
    check("move at local tier accepted", resp["type"] == "move_result")

print("\n=== Zoom Out ===")
resp = send_recv(ws, "zoom_out", {"character_id": char_id})
zoom_data = json.loads(resp["payload"]) if isinstance(resp["payload"], str) else resp["payload"]
check("zoom_out returns zoom_result", resp["type"] == "zoom_result")
check("zoom_out success", zoom_data["success"] == True)
check("zoom_out depth decreased", zoom_data["depth"] == 2)
check("zoom_out tier is regional", zoom_data["tier_name"] == "regional")

print("\n=== Zoom Out Again (to world) ===")
resp = send_recv(ws, "zoom_out", {"character_id": char_id})
zoom_data = json.loads(resp["payload"]) if isinstance(resp["payload"], str) else resp["payload"]
check("zoom to world success", zoom_data["success"] == True)
check("zoom to world depth 1", zoom_data["depth"] == 1)
check("zoom to world tier", zoom_data["tier_name"] == "world")

print("\n=== Zoom Out at World (should fail) ===")
resp = send_recv(ws, "zoom_out", {"character_id": char_id})
check("zoom_out at world fails", "error" in resp["type"])

print("\n=== Zoom In to Max Depth ===")
for depth_target in range(2, 7):
    resp = send_recv(ws, "zoom_in", {"character_id": char_id, "child_index": 1})
    zoom_data = json.loads(resp["payload"]) if isinstance(resp["payload"], str) else resp["payload"]
    check(f"zoom to depth {depth_target}", zoom_data["depth"] == depth_target)

print("\n=== Zoom In Past Max (should fail) ===")
resp = send_recv(ws, "zoom_in", {"character_id": char_id, "child_index": 0})
check("zoom beyond max depth fails", "error" in resp["type"])

print("\n=== Invalid Zoom Child Index ===")
resp = send_recv(ws, "zoom_out", {"character_id": char_id})
resp = send_recv(ws, "zoom_in", {"character_id": char_id, "child_index": 7})
check("invalid child_index rejected", "error" in resp["type"])

print("\n=== Unknown Message Type ===")
resp = send_recv(ws, "nonexistent_type")
check("unknown type returns error", "error" in resp["type"])

ws.close()

print(f"\n{'='*40}")
print(f"Results: {passed} passed, {failed} failed out of {passed+failed}")
if failed > 0:
    exit(1)
