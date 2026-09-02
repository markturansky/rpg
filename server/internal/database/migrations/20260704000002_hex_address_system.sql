CREATE TABLE IF NOT EXISTS tiles (
    address TEXT PRIMARY KEY,
    parent_address TEXT REFERENCES tiles(address),
    depth INTEGER NOT NULL,
    grid_col INTEGER NOT NULL DEFAULT 0,
    grid_row INTEGER NOT NULL DEFAULT 0,
    terrain_id TEXT NOT NULL REFERENCES terrain(id),
    world_seed INTEGER NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT OR IGNORE INTO schema_migrations (version) VALUES ('20260704000002_hex_address_system');
