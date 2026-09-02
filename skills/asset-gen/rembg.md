---
name: rembg
description: "Background removal for game assets using rembg. Covers matting solid backgrounds from characters, props, icons, UI elements, and animated sprite frames."
---

# Background Removal

Matte a solid background out of an asset that needs transparency.

Applies to: characters, props, icons, UI, animated sprite frames.
Does NOT apply to: textures, backgrounds, 3D model references (Tripo3D needs the solid bg).

**Never prompt for a "transparent background" — the generator draws a checkerboard. Prompt a solid color, then remove it.**

## BG Color Strategy

Pick a prompt bg color that is (1) **distinct from the subject** so the mask separates cleanly, and (2) **close to the expected in-game environment** so residual fringe blends.

| Environment | BG Color      |
|-------------|---------------|
| Forest      | `dark-green`  |
| Sky/water   | `steel-blue`  |
| Dungeon     | `dark-gray`   |
| Generic     | `medium-gray` |

Avoid pure chromakey (`#00FF00`) — it leaves unnatural fringing.

Prompt template:
```
{name}, {description}. Centered on a solid {bg_color} background.
```

## CLI

Tools location: `/home/mturansk/projects/src/github.com/godot-skills/asset-gen/tools/`

```bash
ASSET_TOOLS=/home/mturansk/projects/src/github.com/godot-skills/asset-gen/tools

# Single image — always pass --preview
python3 $ASSET_TOOLS/rembg_matting.py img/car.png -o img/car_nobg.png --preview

# Batch (video frames): BiRefNet loads once, bg sampled per-frame for color drift
python3 $ASSET_TOOLS/rembg_matting.py --batch frames/ -o clean/
```

Dependencies: `pip install rembg[gpu,cli]` (or `rembg[cpu,cli]`). The script auto-detects CUDA and falls back to CPU with a warning.

## Modes

`-m auto` (default) selects by mask coverage:

| Mode    | Auto when       | Behavior                                              |
|---------|-----------------|-------------------------------------------------------|
| `trust` | 5–70% mask fg   | Keep all mask-fg pixels, aggressively remove bg       |
| `adapt` | >70% mask fg    | Adaptive threshold — fg pixels can be removed if bg-colored |
| `color` | <5% mask fg     | Color matting only, no mask — rough fallback          |

Output reports `BG color`, `Mask: fg=… (%)`, and the selected `Regime`. If the bg color is wrong (corners aren't bg) or `Transparent: 0`, regenerate the image with the subject centered on a solid bg.

## QA Verification

Always pass `--preview` — it writes a `_qa.png` (the result composited on a contrasting color). The AI cannot judge transparency from a raw PNG; reading the `_qa` is the only reliable check. Delete it after inspection.

## Fixing Results

- **Background remnants** → `--bg-thresh 0.03` (lower = more aggressive; also reduces fringing)
- **Missing foreground** → `-m trust`, or in adapt `--fg-thresh 0.30` (higher = more protective)
- **Fringing** (colored halo) → `-m adapt --fg-thresh 0.10`; if it persists, the bg is too close to the subject — regenerate with a more distinct color

Tune `--bg-thresh`/`--fg-thresh` together. For batches, tune on one frame, then apply the flags to the whole set.
