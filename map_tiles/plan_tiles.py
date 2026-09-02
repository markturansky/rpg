#!/usr/bin/env python3
import json
import os
import shutil
import subprocess
import sys
from collections import deque
from fractions import Fraction

COLS = 4
ROWS = 3

def compute_child_pixel_dims(parent_w, parent_h, child_index):
    up_w = parent_w * 2
    up_h = parent_h * 2
    base_w = up_w // COLS
    base_h = up_h // ROWS
    extra_w = up_w % COLS
    extra_h = up_h % ROWS
    col = child_index % COLS
    row = child_index // COLS
    cw = base_w + (1 if col < extra_w else 0)
    ch = base_h + (1 if row < extra_h else 0)
    return cw, ch

def main():
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <input_file> [max_depth]")
        sys.exit(1)

    input_file = sys.argv[1]
    max_depth = int(sys.argv[2]) if len(sys.argv) > 2 else 999
    min_dimension = 64

    if not os.path.exists(input_file):
        print(f"ERROR: {input_file} not found")
        sys.exit(1)

    script_dir = os.path.dirname(os.path.abspath(__file__))
    ext = input_file.rsplit('.', 1)[-1]
    base = os.path.basename(input_file).rsplit('.', 1)[0]
    output_dir = os.path.join(script_dir, base)

    dims_out = subprocess.check_output(
        ['magick', 'identify', '-format', '%w %h', input_file],
        text=True
    ).strip()
    root_w, root_h = map(int, dims_out.split())

    print(f"Input:     {input_file}")
    print(f"Output:    {output_dir}/")
    print(f"Max depth: {max_depth}")
    print(f"Min cell:  {min_dimension}px")
    print(f"Root:      {root_w}x{root_h}")
    print()
    print("==========================================")
    print("PHASE 1: Planning tile tree (breadth-first)")
    print("==========================================")
    print()

    queue = deque()
    queue.append({
        'input': input_file,
        'dir': output_dir,
        'depth': 0,
        'index': 0,
        'bx0': Fraction(0), 'by0': Fraction(0),
        'bx1': Fraction(1), 'by1': Fraction(1),
        'width': root_w,
        'height': root_h,
        'name': base,
        'ext': ext,
    })

    all_tiles = []
    depth_counts = {}
    total_parents = 0
    total_leaves = 0

    while queue:
        next_queue = deque()
        current_depth = queue[0]['depth']
        depth_count = 0

        while queue and queue[0]['depth'] == current_depth:
            tile = queue.popleft()
            depth_count += 1

            up_w = tile['width'] * 2
            up_h = tile['height'] * 2
            cell_w = up_w // COLS
            cell_h = up_h // ROWS

            is_leaf = False
            if tile['depth'] >= max_depth:
                is_leaf = True
            elif cell_w < min_dimension or cell_h < min_dimension:
                is_leaf = True

            os.makedirs(tile['dir'], exist_ok=True)

            children_list = []
            if not is_leaf:
                for i in range(COLS * ROWS):
                    children_list.append(f"{tile['name']}_{i:02d}")

            tile_json = {
                "name": tile['name'],
                "depth": tile['depth'],
                "grid_index": tile['index'],
                "grid_col": tile['index'] % COLS,
                "grid_row": tile['index'] // COLS,
                "bounds": [
                    float(tile['bx0']),
                    float(tile['by0']),
                    float(tile['bx1']),
                    float(tile['by1'])
                ],
                "pixel_width": tile['width'],
                "pixel_height": tile['height'],
                "tile_file": f"{tile['name']}.{tile['ext']}",
                "upscaled_file": f"{tile['name']}_2x.{tile['ext']}" if not is_leaf else None,
                "is_leaf": is_leaf,
                "children": children_list,
            }

            tile_json_path = os.path.join(tile['dir'], 'tile.json')
            with open(tile_json_path, 'w') as f:
                json.dump(tile_json, f, indent=2)

            rel_path = os.path.relpath(tile['dir'], output_dir)
            if rel_path == '.':
                rel_path = '.'

            manifest_entry = {
                "name": tile['name'],
                "depth": tile['depth'],
                "bounds": [
                    float(tile['bx0']),
                    float(tile['by0']),
                    float(tile['bx1']),
                    float(tile['by1']),
                ],
                "is_leaf": is_leaf,
                "path": rel_path,
            }
            all_tiles.append(manifest_entry)

            if is_leaf:
                total_leaves += 1
            else:
                total_parents += 1
                bw = tile['bx1'] - tile['bx0']
                bh = tile['by1'] - tile['by0']

                for i in range(COLS * ROWS):
                    col = i % COLS
                    row = i // COLS

                    cx0 = tile['bx0'] + bw * col / COLS
                    cy0 = tile['by0'] + bh * row / ROWS
                    cx1 = tile['bx0'] + bw * (col + 1) / COLS
                    cy1 = tile['by0'] + bh * (row + 1) / ROWS

                    cw, ch = compute_child_pixel_dims(tile['width'], tile['height'], i)

                    child_name = f"{tile['name']}_{i:02d}"
                    child_dir = os.path.join(tile['dir'], child_name)

                    next_queue.append({
                        'input': os.path.join(child_dir, f"{child_name}.{tile['ext']}"),
                        'dir': child_dir,
                        'depth': tile['depth'] + 1,
                        'index': i,
                        'bx0': cx0, 'by0': cy0,
                        'bx1': cx1, 'by1': cy1,
                        'width': cw,
                        'height': ch,
                        'name': child_name,
                        'ext': tile['ext'],
                    })

        depth_counts[current_depth] = depth_count
        print(f"  Depth {current_depth}: {depth_count} tiles planned")

        queue = next_queue

    print()
    print(f"Plan complete: {len(all_tiles)} tiles ({total_parents} parents, {total_leaves} leaves)")

    manifest = {
        "root": base,
        "source": os.path.basename(input_file),
        "grid": {"cols": COLS, "rows": ROWS},
        "max_depth": max_depth,
        "min_cell_dimension": min_dimension,
        "tiles": all_tiles,
    }

    manifest_path = os.path.join(output_dir, 'manifest.json')
    with open(manifest_path, 'w') as f:
        json.dump(manifest, f, indent=2)

    print(f"Manifest written: {manifest_path}")

    print()
    print("==========================================")
    print("PHASE 1b: Creating placeholder tiles")
    print("==========================================")

    placeholder_path = os.path.join(output_dir, '_placeholder.png')
    subprocess.run([
        'magick', '-size', '75x236', 'xc:#444444',
        '-fill', '#888888', '-gravity', 'center',
        '-pointsize', '12', '-annotate', '0', 'loading',
        placeholder_path
    ], check=True)
    print(f"  Created placeholder: {placeholder_path}")

    placeholder_count = 0
    for entry in all_tiles:
        tile_dir = os.path.join(output_dir, entry['path'])
        tile_file = os.path.join(tile_dir, f"{entry['name']}.{ext}")
        if not os.path.exists(tile_file):
            shutil.copy2(placeholder_path, tile_file)
            placeholder_count += 1

    print(f"  Placed {placeholder_count} placeholder images")

    render_queue_path = os.path.join(output_dir, '_render_queue.txt')
    with open(render_queue_path, 'w') as f:
        f.write(f"{os.path.abspath(input_file)}|{output_dir}|0|{base}\n")

        for entry in all_tiles:
            if not entry['is_leaf']:
                tile_name = entry['name']
                if entry['path'] == '.':
                    tile_dir = output_dir
                else:
                    tile_dir = os.path.join(output_dir, entry['path'])
                for i in range(COLS * ROWS):
                    child_name = f"{tile_name}_{i:02d}"
                    child_dir = os.path.join(tile_dir, child_name)
                    child_file = os.path.join(child_dir, f"{child_name}.{ext}")
                    f.write(f"{child_file}|{child_dir}|{entry['depth'] + 1}|{child_name}\n")

    print(f"  Render queue written: {render_queue_path}")
    print()
    print("Phase 1 complete. Run render_tiles.sh to render actual images.")

if __name__ == '__main__':
    main()
