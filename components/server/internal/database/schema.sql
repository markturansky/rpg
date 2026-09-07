PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS schema_migrations (
    version TEXT PRIMARY KEY,
    applied_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS tile_definitions (
    id TEXT PRIMARY KEY,
    category TEXT NOT NULL,
    name TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS world_tiles (
    world_name TEXT NOT NULL CHECK (length(world_name) > 0),
    x INTEGER NOT NULL,
    y INTEGER NOT NULL,
    tile_definition_id TEXT NOT NULL REFERENCES tile_definitions(id),
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (world_name, x, y)
);

CREATE INDEX IF NOT EXISTS world_tiles_by_world_position
    ON world_tiles (world_name, y, x);
