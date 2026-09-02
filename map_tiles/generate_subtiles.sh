#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ -z "${1:-}" ]; then
    echo "Usage: $0 <input_file> [max_depth]"
    echo "  e.g. $0 map2.png 2"
    exit 1
fi

INPUT="$1"
MAX_DEPTH="${2:-999}"

if [ ! -f "$INPUT" ]; then
    echo "ERROR: $INPUT not found"
    exit 1
fi

EXT="${INPUT##*.}"
BASE="$(basename "$INPUT" ".$EXT")"
OUTPUT_DIR="${SCRIPT_DIR}/${BASE}"

echo "=========================================="
echo "PHASE 1: Planning (Python - breadth-first)"
echo "=========================================="
echo ""
python3 "${SCRIPT_DIR}/plan_tiles.py" "$INPUT" "$MAX_DEPTH"

echo ""
echo "=========================================="
echo "PHASE 2: Rendering tiles (breadth-first)"
echo "=========================================="
echo ""

RENDER_QUEUE="${OUTPUT_DIR}/_render_queue.txt"
if [ ! -f "$RENDER_QUEUE" ]; then
    echo "ERROR: render queue not found at ${RENDER_QUEUE}"
    exit 1
fi

DEPTH_QUEUE="$(mktemp)"
head -1 "$RENDER_QUEUE" > "$DEPTH_QUEUE"

CURRENT_DEPTH=0
LINE=2

while [ -s "$DEPTH_QUEUE" ]; do
    RENDERED=0
    NEXT_DEPTH_QUEUE="$(mktemp)"
    NEXT_DEPTH=-1

    echo "--- Rendering depth ${CURRENT_DEPTH} ---"

    while IFS='|' read -r src_file tile_dir depth tile_name; do
        local_ext="${src_file##*.}"
        dest_tile="${tile_dir}/${tile_name}.${local_ext}"

        src_real="$(realpath "$src_file" 2>/dev/null || echo "")"
        dest_real="$(realpath "$dest_tile" 2>/dev/null || echo "")"
        if [ "$src_real" != "$dest_real" ]; then
            cp "$src_file" "$dest_tile"
        fi

        tjson="${tile_dir}/tile.json"
        is_leaf="$(python3 -c "import json; print(json.load(open('${tjson}'))['is_leaf'])")"

        if [ "$is_leaf" = "True" ]; then
            RENDERED=$(( RENDERED + 1 ))
            continue
        fi

        dims="$(magick identify -format '%w %h' "$dest_tile")"
        width="${dims%% *}"
        height="${dims##* }"

        upscaled="${tile_dir}/${tile_name}_2x.${local_ext}"
        if [ ! -f "$upscaled" ]; then
            magick "$dest_tile" -filter Lanczos -resize 200% -quality 92 "$upscaled"
        fi

        tmpdir="$(mktemp -d)"
        magick "$upscaled" -crop 4x3@ +repage +adjoin "${tmpdir}/child_%02d.${local_ext}"

        for i in $(seq 0 11); do
            child_idx="$(printf "%02d" "$i")"
            child_name="${tile_name}_${child_idx}"
            child_dir="${tile_dir}/${child_name}"
            child_tile="${child_dir}/${child_name}.${local_ext}"

            mkdir -p "$child_dir"
            mv "${tmpdir}/child_${child_idx}.${local_ext}" "$child_tile"
        done

        rm -rf "$tmpdir"

        actual_child_dims="$(magick identify -format '%wx%h' "${tile_dir}/${tile_name}_00/${tile_name}_00.${local_ext}")"
        RENDERED=$(( RENDERED + 1 ))
        echo "  ${tile_name} (${width}x${height}) -> 12 children @ ${actual_child_dims}"

    done < "$DEPTH_QUEUE"

    echo "  Depth ${CURRENT_DEPTH}: ${RENDERED} tiles rendered"
    echo ""

    rm -f "$DEPTH_QUEUE"

    NEXT_DEPTH=$(( CURRENT_DEPTH + 1 ))
    DEPTH_QUEUE="$(mktemp)"
    awk -F'|' -v d="$NEXT_DEPTH" '$3 == d' "$RENDER_QUEUE" > "$DEPTH_QUEUE"

    if [ ! -s "$DEPTH_QUEUE" ]; then
        rm -f "$DEPTH_QUEUE"
        break
    fi

    CURRENT_DEPTH="$NEXT_DEPTH"
done

echo ""
echo "=========================================="
echo "PHASE 3: Updating tile.json with actual pixel dimensions"
echo "=========================================="

python3 -c "
import json, os, subprocess

output_dir = '${OUTPUT_DIR}'
ext = '${EXT}'
count = 0

for root, dirs, files in os.walk(output_dir):
    if 'tile.json' in files:
        tjson_path = os.path.join(root, 'tile.json')
        with open(tjson_path) as f:
            data = json.load(f)
        img_path = os.path.join(root, data['tile_file'])
        if os.path.exists(img_path):
            dims = subprocess.check_output(
                ['magick', 'identify', '-format', '%w %h', img_path],
                text=True
            ).strip()
            w, h = dims.split()
            data['pixel_width'] = int(w)
            data['pixel_height'] = int(h)
            with open(tjson_path, 'w') as f:
                json.dump(data, f, indent=2)
            count += 1

print(f'  Updated {count} tile.json files with actual dimensions')
"

echo ""
echo "=== Done ==="
echo "Output: ${OUTPUT_DIR}/"
