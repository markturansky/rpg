---
name: asset-gen
description: "Use this skill when generating visual assets — PNG images, sprites, 3D models, animated sprite sheets, or removing backgrounds. Covers Gemini and Grok image generation, Tripo3D GLB models, rembg background removal, and animated sprite workflows. Triggers on: asset, sprite, image generation, texture, 3D model, GLB, background removal, rembg."
---

# Asset Generator
> Generate PNG images (Gemini or xAI Grok) and GLB 3D models (Tripo3D) from text prompts. These are paid APIs — every call costs real money. Confirm the spend with the user before the first paid generation.

**Tools location:** `/home/mturansk/projects/src/github.com/godot-skills/asset-gen/tools/`
**Related skills:** ../godot-engine/SKILL.md, ./rembg.md

## Quick Start

```bash
ASSET_TOOLS=/home/mturansk/projects/src/github.com/godot-skills/asset-gen/tools

# Generate an image (Grok default, 2¢)
python3 $ASSET_TOOLS/asset_gen.py image \
  --prompt "medieval stone tower, top-down view, solid dark-green background" \
  -o assets/img/tower.png

# Generate an image (Gemini, more precise, 7¢ at 1K)
python3 $ASSET_TOOLS/asset_gen.py image \
  --prompt "dwarf fighter in plate armor, neutral pose, solid medium-gray background" \
  --model gemini -o assets/img/dwarf.png

# Remove background
python3 $ASSET_TOOLS/rembg_matting.py assets/img/dwarf.png -o assets/img/dwarf_nobg.png --preview
```

## Models

| Model  | Flag             | Cost                                    | Best for                                                       |
|--------|------------------|-----------------------------------------|----------------------------------------------------------------|
| Gemini | `--model gemini` | 5¢ (512) · 7¢ (1K) · 10¢ (2K) · 15¢ (4K) | Precise prompt following — references, characters, exact layouts |
| Grok   | `--model grok`   | 2¢                                      | High quality but imprecise — textures, simple objects, backgrounds |

Grok produces great-looking output but often ignores specific instructions; use Gemini when the result must match what you described.

## Images

```bash
python3 $ASSET_TOOLS/asset_gen.py image \
  --prompt "the full prompt" -o output.png
```

Options: `--model` (default `grok`) · `--size` (default `1K`; Gemini also `512`/`4K`) · `--aspect-ratio` (default `1:1`; also `16:9`, `9:16`, `4:3`, `3:4`, `3:2`, `2:3`).

**Image-to-image:** pass `--image ref.png` and the model sees the reference — prompt only for what changes (angle, pose, recolor), don't re-describe appearance.

**Small sprites:** minimum generation is 1K, so 1024px downscaled to 64px looks muddy. Design display sizes ≥128px, or generate a kit (multiple objects in one 1K image) and slice:

```bash
python3 $ASSET_TOOLS/grid_slice.py input.png --grid 2x2 --names "a,b,c,d"
```

## Terrain Sprite Sheet

For the RPG tile rendering pipeline, terrain sprites are composited server-side from a sprite sheet. When generating terrain tiles:

1. Generate each terrain type as a 1K image with solid background
2. Remove background with rembg
3. Assemble into a sprite sheet (grid of terrain variants)
4. Each terrain type should have 4 variants for visual variety

The server's `TileRenderer` reads the sprite sheet and composites 10×10 grids for depths 3–5.

## Background Removal

See [rembg.md](rembg.md) for the full guide. Key rule: **never prompt for a "transparent background"** — the generator bakes a checkerboard. Prompt a solid color, then matte it out.

```bash
# Single image (always pass --preview)
python3 $ASSET_TOOLS/rembg_matting.py img/car.png -o img/car_nobg.png --preview

# Batch (video frames)
python3 $ASSET_TOOLS/rembg_matting.py --batch frames/ -o clean/
```

BG color strategy: pick a color (1) distinct from the subject and (2) close to the expected in-game environment. Forest → `dark-green`; sky/water → `steel-blue`; dungeon → `dark-gray`; generic → `medium-gray`. Avoid pure chromakey (`#00FF00`).

## Animated Sprites

Recipe: **reference → pose → video → extract frames → loop-trim → rembg.**

1. **Reference** (Gemini 1K, neutral pose, solid BG) — anchors everything; review carefully
2. **Pose** per action: image-to-image from the reference, prompt only the action
3. **Video** from the pose frame:
   ```bash
   python3 $ASSET_TOOLS/asset_gen.py video --image pose.png --duration 2 -o walk.mp4
   ```
   `--duration` 1–15s, `--resolution` 720p; cost 5¢/s
4. **Extract:** `ffmpeg -i walk.mp4 -vsync 0 frames/%04d.png`
5. **Loop-trim** for looping cycles (walk/idle):
   ```bash
   python3 $ASSET_TOOLS/find_loop_frame.py frames/
   ```
   Returns the loop frame; delete frames past it. Skip for one-shots (attack/death).
6. **Batch matte:**
   ```bash
   python3 $ASSET_TOOLS/rembg_matting.py --batch frames/ -o clean/
   ```

Reuse one reference for all of a character's actions. Chaining (feed action A's last frame as action B's start) keeps positional continuity — keep chains ≤2 deep, they drift.

## 3D Models

```bash
# GLB from reference image (30¢ default / 60¢ --quality hd)
python3 $ASSET_TOOLS/asset_gen.py glb --image ref.png -o model.glb

# Rig a biped (+25¢, biped only)
python3 $ASSET_TOOLS/asset_gen.py rig --image ref.png -o rigged.glb

# Retarget animation (10¢ per clip)
python3 $ASSET_TOOLS/asset_gen.py retarget --rigged rigged.glb \
  --animation preset:biped:walk -o walk.glb
```

Source image for `glb`: 3/4 elevated angle, solid white/gray background, matte finish, single centered subject — do **not** rembg it (Tripo3D needs the solid bg).

### Tripo3D Resume

Jobs can sit at 99% with empty output for minutes. A timeout does **not** mean failure. The task id is saved in `<output>.tripo.json`. Do not resubmit — that double-charges. Resume instead:

```bash
python3 $ASSET_TOOLS/asset_gen.py resume -o model.glb
```

## Cost Quick Reference

| Asset                | Cost   |
|----------------------|--------|
| Texture/sprite (Grok) | 2¢    |
| Character/ref (Gemini 1K) | 7¢ |
| Background (Grok)    | 2¢    |
| Background (Gemini 2K) | 10¢  |
| Full 3D asset        | 37¢   |
| Rigged character walk/idle/attack | ~92¢ |

## Output Format

Each command prints JSON to stdout: `{"ok": true, "path": "...", "cost_cents": 7}`. Progress goes to stderr:

```bash
_log=$(mktemp)
result=$(python3 $ASSET_TOOLS/asset_gen.py image --prompt "..." -o p.png 2>"$_log") || tail -20 "$_log"
```

Generate independent images in parallel (multiple Bash calls in one message).

## API Keys

Set in environment:
- `GOOGLE_API_KEY` — Gemini image generation
- `XAI_API_KEY` — xAI Grok image/video generation
- `TRIPO3D_API_KEY` — image-to-3D conversion

## Python Dependencies

```bash
pip install -r /home/mturansk/projects/src/github.com/godot-skills/asset-gen/tools/requirements.txt
pip install google-genai
```

## Visual Pitfalls

- **Direction/orientation** is unreliable ("facing left" vs "right" often comes out identical). Generate one direction and flip at runtime.
- **Mixed sizes:** image frames are ~1024px, video frames ~720px. Downscale everything to the smallest source before matting.
- **Playback fps:** source videos are ~24fps — drive sprite playback off elapsed time at ~1/24s.
