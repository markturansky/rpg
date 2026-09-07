#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd -W)"
SERVER_DIR="$ROOT_DIR/components/server"
CLIENT_DIR="$ROOT_DIR/components/client"

if [ -n "${GODOT:-}" ]; then
    GODOT_BIN="$GODOT"
elif command -v godot >/dev/null 2>&1; then
    GODOT_BIN="$(command -v godot)"
elif [ -x "${LOCALAPPDATA:-}/Godot/4.7.2/Godot_v4.7.2-stable_win64_console.exe" ]; then
    GODOT_BIN="${LOCALAPPDATA}/Godot/4.7.2/Godot_v4.7.2-stable_win64_console.exe"
else
    echo "Godot executable not found. Set GODOT to its executable path."
    exit 1
fi

echo "=== Hex World RPG Test Suite ==="
echo "[1/3] Go tests"
(
    cd "$SERVER_DIR"
    go test ./...
)

echo "[2/3] Godot import"
"$GODOT_BIN" --headless --editor --path "$CLIENT_DIR" --quit

echo "[3/3] Godot bootstrap test"
"$GODOT_BIN" --headless --path "$CLIENT_DIR" --script res://tests/test_bootstrap.gd

echo "All tests passed."
