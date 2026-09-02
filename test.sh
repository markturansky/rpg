#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
SERVER_DIR="$ROOT_DIR/server"
CLIENT_DIR="$ROOT_DIR/client-godot"
GODOT="/home/mturansk/Downloads/Godot_v4.6.3-stable_linux.x86_64"

RED='\033[0;31m'
GREEN='\033[0;32m'
BOLD='\033[1m'
RESET='\033[0m'

TOTAL_PASS=0
TOTAL_FAIL=0

cleanup_ports() {
    fuser -k 8080/tcp 8091/tcp 8092/tcp 2>/dev/null || true
    sleep 0.5
}

echo -e "${BOLD}=== Hex World RPG Test Suite ===${RESET}"
echo ""

if [ ! -f "$GODOT" ]; then
    echo -e "${RED}ERROR: Godot not found at $GODOT${RESET}"
    exit 1
fi

echo -e "${BOLD}[1/7] Building server...${RESET}"
cd "$SERVER_DIR"
go build -o rpg-server ./cmd/rpg-server
cp rpg-server "$CLIENT_DIR/build/rpg-server"
echo -e "${GREEN}  Build OK${RESET}"
echo ""

echo -e "${BOLD}[2/7] Exporting Godot client...${RESET}"
rm -f "$CLIENT_DIR/build/rpg.db" "$CLIENT_DIR/build/rpg.db-shm" "$CLIENT_DIR/build/rpg.db-wal"
"$GODOT" --headless --path "$CLIENT_DIR" --export-release "Linux" build/hex-world-rpg.x86_64 2>&1 | tail -1
echo -e "${GREEN}  Export OK${RESET}"
echo ""

echo -e "${BOLD}[3/7] Go tests${RESET}"
GO_OUTPUT=$(go test ./... -v 2>&1)
GO_PASS=$(echo "$GO_OUTPUT" | grep -c "^--- PASS" || true)
GO_FAIL=$(echo "$GO_OUTPUT" | grep -c "^--- FAIL" || true)
TOTAL_PASS=$((TOTAL_PASS + GO_PASS))
TOTAL_FAIL=$((TOTAL_FAIL + GO_FAIL))
if [ "$GO_FAIL" -eq 0 ]; then
    echo -e "${GREEN}  $GO_PASS passed, $GO_FAIL failed${RESET}"
else
    echo -e "${RED}  $GO_PASS passed, $GO_FAIL failed${RESET}"
    echo "$GO_OUTPUT"
fi
echo ""

cleanup_ports

echo -e "${BOLD}[4/7] GDScript unit tests (hex_address)${RESET}"
UNIT_OUTPUT=$("$GODOT" --headless --path "$CLIENT_DIR" --script tests/test_hex_address.gd 2>&1)
UNIT_LINE=$(echo "$UNIT_OUTPUT" | grep "^=== Results:" || true)
UNIT_PASS=$(echo "$UNIT_LINE" | grep -oP '\d+ passed' | grep -oP '\d+' || echo "0")
UNIT_FAIL=$(echo "$UNIT_LINE" | grep -oP '\d+ failed' | grep -oP '\d+' || echo "0")
TOTAL_PASS=$((TOTAL_PASS + UNIT_PASS))
TOTAL_FAIL=$((TOTAL_FAIL + UNIT_FAIL))
if [ "$UNIT_FAIL" -eq 0 ]; then
    echo -e "${GREEN}  $UNIT_PASS passed, $UNIT_FAIL failed${RESET}"
else
    echo -e "${RED}  $UNIT_PASS passed, $UNIT_FAIL failed${RESET}"
    echo "$UNIT_OUTPUT"
fi
echo ""

cleanup_ports

echo -e "${BOLD}[5/7] GDScript integration tests (client)${RESET}"
INT_OUTPUT=$("$GODOT" --headless --path "$CLIENT_DIR" --script tests/test_client_integration.gd 2>&1)
INT_LINE=$(echo "$INT_OUTPUT" | grep "^=== Results:" || true)
INT_PASS=$(echo "$INT_LINE" | grep -oP '\d+ passed' | grep -oP '\d+' || echo "0")
INT_FAIL=$(echo "$INT_LINE" | grep -oP '\d+ failed' | grep -oP '\d+' || echo "0")
TOTAL_PASS=$((TOTAL_PASS + INT_PASS))
TOTAL_FAIL=$((TOTAL_FAIL + INT_FAIL))
if [ "$INT_FAIL" -eq 0 ]; then
    echo -e "${GREEN}  $INT_PASS passed, $INT_FAIL failed${RESET}"
else
    echo -e "${RED}  $INT_PASS passed, $INT_FAIL failed${RESET}"
    echo "$INT_OUTPUT"
fi
echo ""

cleanup_ports

echo -e "${BOLD}[6/7] GDScript zoom terrain tests${RESET}"
ZOOM_OUTPUT=$("$GODOT" --headless --path "$CLIENT_DIR" --script tests/test_zoom_terrain.gd 2>&1)
ZOOM_LINE=$(echo "$ZOOM_OUTPUT" | grep "^=== Results:" || true)
ZOOM_PASS=$(echo "$ZOOM_LINE" | grep -oP '\d+ passed' | grep -oP '\d+' || echo "0")
ZOOM_FAIL=$(echo "$ZOOM_LINE" | grep -oP '\d+ failed' | grep -oP '\d+' || echo "0")
TOTAL_PASS=$((TOTAL_PASS + ZOOM_PASS))
TOTAL_FAIL=$((TOTAL_FAIL + ZOOM_FAIL))
if [ "$ZOOM_FAIL" -eq 0 ]; then
    echo -e "${GREEN}  $ZOOM_PASS passed, $ZOOM_FAIL failed${RESET}"
else
    echo -e "${RED}  $ZOOM_PASS passed, $ZOOM_FAIL failed${RESET}"
    echo "$ZOOM_OUTPUT"
fi
echo ""

cleanup_ports

echo -e "${BOLD}[7/7] GDScript tile rendering tests${RESET}"
TILE_OUTPUT=$("$GODOT" --headless --path "$CLIENT_DIR" --script tests/test_tile_rendering.gd 2>&1)
TILE_LINE=$(echo "$TILE_OUTPUT" | grep "^=== Results:" || true)
TILE_PASS=$(echo "$TILE_LINE" | grep -oP '\d+ passed' | grep -oP '\d+' || echo "0")
TILE_FAIL=$(echo "$TILE_LINE" | grep -oP '\d+ failed' | grep -oP '\d+' || echo "0")
TOTAL_PASS=$((TOTAL_PASS + TILE_PASS))
TOTAL_FAIL=$((TOTAL_FAIL + TILE_FAIL))
if [ "$TILE_FAIL" -eq 0 ]; then
    echo -e "${GREEN}  $TILE_PASS passed, $TILE_FAIL failed${RESET}"
else
    echo -e "${RED}  $TILE_PASS passed, $TILE_FAIL failed${RESET}"
    echo "$TILE_OUTPUT"
fi
echo ""

echo -e "${BOLD}==============================${RESET}"
if [ "$TOTAL_FAIL" -eq 0 ]; then
    echo -e "${GREEN}${BOLD}TOTAL: $TOTAL_PASS passed, $TOTAL_FAIL failed${RESET}"
    exit 0
else
    echo -e "${RED}${BOLD}TOTAL: $TOTAL_PASS passed, $TOTAL_FAIL failed${RESET}"
    exit 1
fi
