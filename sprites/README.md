# Sprites

Three AI-generated 2D sprite sheets for Hex World RPG, created with Google Gemini. All sheets are 1984x2164 RGBA PNGs drawn in a consistent pixel-art style on a grid-paper background.

## Sprite Sheets

### overworld-tileset.png
World map tiles for the top-down overworld view. Contains terrain surfaces (water, grass, sand, desert), forests, hills, mountains, caves, roads (stone and dirt variants with intersections, curves, and junctions), bridges, and buildings (cottages, houses, shops, towers, windmill, castle walls, and gates).

**60 sprites** across these categories:
- `terrain` — water, plains, forest, hills, mountains, cave
- `roads` — surfaces, intersections, dirt, bridges
- `buildings` — village, fortification

### interior-tileset.png
Building interiors and structural elements. Covers flooring (stone, wood, dirt), walls and doorways (stone, brick, with windows and arches), furniture (tables, beds, fireplaces, bookshelves, armor stands), castle great hall elements, wizard tower interior, staircases (spiral, straight, ladder), barn/rural equipment, and architectural floorplans.

**52 sprites** across these categories:
- `flooring` — stone, wood, natural
- `walls` — stone, brick, doors, sections, exterior
- `furniture` — home, hall, tower, rural, decoration
- `stairs` — vertical

### terrain-tileset.png
Natural terrain tiles organized into four landscape zones. Lowland and plains (farmland, grassland), aquatic and wetland (ponds, rivers, swamps, coastline, ocean), forest and vegetation (deciduous, conifer, mixed canopy), and upland topography (hills, mountains, cliffs, caves).

**33 sprites** across these categories:
- `lowland` — farmland, grassland
- `aquatic` — freshwater, wetland, coastal, ocean, river
- `forest` — vegetation, trees
- `upland` — topography, hills, mountains, cave

## Usage

### Index Format

`sprites.json` contains all sprite regions. Each sheet entry has:

```json
{
  "file": "overworld-tileset.png",
  "image_width": 1984,
  "image_height": 2164,
  "sprites": [
    {
      "name": "water-deep",
      "category": "terrain",
      "subcategory": "water",
      "x": 33, "y": 68,
      "w": 156, "h": 148
    }
  ]
}
```

### Loading in Godot (GDScript)

```gdscript
# Load the spritesheet as a texture
var sheet_tex = load("res://sprites/overworld-tileset.png")

# Create an AtlasTexture for a specific sprite region
var atlas = AtlasTexture.new()
atlas.atlas = sheet_tex
atlas.region = Rect2(33, 68, 156, 148)  # x, y, w, h from sprites.json

# Use it on a TextureRect or Sprite2D
$Sprite2D.texture = atlas
```

### Loading in code (Python / other)

```python
from PIL import Image
import json

with open("sprites/sprites.json") as f:
    data = json.load(f)

for sheet in data["sheets"]:
    img = Image.open(f"sprites/{sheet['file']}")
    for sprite in sheet["sprites"]:
        region = img.crop((
            sprite["x"], sprite["y"],
            sprite["x"] + sprite["w"],
            sprite["y"] + sprite["h"]
        ))
        region.save(f"output/{sprite['name']}.png")
```

## Notes

- The grid-paper background is baked into the images (not transparent). Sprites will need alpha masking or background removal if transparency is required.
- Sprite boundaries are approximate since these are AI-generated images without pixel-perfect grid alignment.
- All coordinates in `sprites.json` are in pixels from the top-left corner of each sheet.
