# World Builder Data Model and Persistence API

## Scope

The first product is a world builder. It persists tile placements made by the
Godot client on an unbounded integer world-coordinate grid. This contract does
not define RPG characters, combat, procedural terrain, tile rendering, or
spritesheet extraction.

## SQLite schema

The Go service owns a SQLite database and applies its embedded schema at
startup. Foreign keys are enabled and WAL mode is used.

### `tile_definitions`

Reference catalog entries for the editor palette.

| Column | Type | Constraints |
|---|---|---|
| `id` | TEXT | primary key |
| `category` | TEXT | not null |
| `name` | TEXT | not null |

The service seeds a small, deterministic placeholder catalog. These IDs are
editor placeholders only; they do not claim to identify tileset3 assets.

### `world_tiles`

A placed definition at one world coordinate.

| Column | Type | Constraints |
|---|---|---|
| `world_name` | TEXT | not null, non-empty |
| `x` | INTEGER | not null |
| `y` | INTEGER | not null |
| `tile_definition_id` | TEXT | not null, references `tile_definitions(id)` |
| `updated_at` | TEXT | not null |

`(world_name, x, y)` is the primary key. Coordinates are signed integer
16x16-grid cells; a placement represents one grid cell, not pixel coordinates.

## HTTP JSON API

All endpoints use `application/json; charset=utf-8`. JSON field order is
stable through typed response structs; catalog and placement lists are sorted
by `category, id` and `y, x` respectively.

### `GET /health`

Returns `200`:

```json
{"status":"ok"}
```

### `GET /api/tile-definitions`

Returns the full placeholder catalog, optionally filtered by exact `category`
query parameter. Unknown categories return an empty list.

```json
{"tile_definitions":[{"id":"terrain.grass","category":"terrain","name":"Grass"}]}
```

### `GET /api/worlds/{world_name}/tiles`

Returns all placements in the named world, sorted by `y` then `x`. A world with
no placements returns `200` and an empty list.

```json
{"world_name":"starter","tiles":[{"x":-2,"y":5,"tile_definition_id":"terrain.grass"}]}
```

### `PUT /api/worlds/{world_name}/tiles/{x}/{y}`

Upserts the placement at integer coordinates. Request body:

```json
{"tile_definition_id":"terrain.grass"}
```

Returns `200` and the persisted placement. Repeating the request at the same
world/coordinate replaces the definition, leaving exactly one row. Unknown
definition IDs and malformed paths/bodies return `400`.

### `DELETE /api/worlds/{world_name}/tiles/{x}/{y}`

Deletes the placement. Returns `204` whether or not a placement existed, so a
client can safely retry an erase.

## Persistence requirements

A successful placement mutation is committed before its response is returned.
Reopening the same SQLite database must retain catalog and placement data.
