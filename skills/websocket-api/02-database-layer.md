# 02 — Database Layer

## db.go Pattern

The database wrapper lives at `server/internal/database/db.go`. It embeds the DDL and migrations into the binary at compile time.

```go
package database

import (
    "database/sql"
    "embed"
    "fmt"
    "io/fs"
    "log"
    "sort"
    "strings"

    _ "github.com/mattn/go-sqlite3"
)

//go:embed schema.sql
var schemaSQL []byte

//go:embed migrations/*.sql
var migrationsFS embed.FS

type DB struct {
    *sql.DB
}
```

### NewDB

Opens SQLite with these connection string parameters:

- `_busy_timeout=10000` — wait 10s for locked DB
- `_journal_mode=WAL` — concurrent readers
- `_foreign_keys=on` — enforce FK constraints

```go
func NewDB(dataSourceName string) (*DB, error) {
    connStr := dataSourceName + "?_busy_timeout=10000&_journal_mode=WAL&_foreign_keys=on"
    db, err := sql.Open("sqlite3", connStr)
    // ...
    db.SetMaxOpenConns(10)
    db.SetMaxIdleConns(5)
    // calls InitSchema() which runs schema.sql then migrations
}
```

### InitSchema

Runs `schema.sql` (all `CREATE TABLE IF NOT EXISTS`), then calls `runMigrations()`.

### runMigrations

1. Reads `migrations/` directory from embedded FS
2. Sorts filenames lexicographically (timestamps ensure correct order)
3. For each `.sql` file, checks `schema_migrations` table — skips if already applied
4. Executes the migration SQL
5. Records the version with `INSERT OR IGNORE INTO schema_migrations`

## schema.sql Conventions

- Every table uses `CREATE TABLE IF NOT EXISTS`
- Reference tables use `TEXT PRIMARY KEY` (natural keys)
- Game state tables use `INTEGER PRIMARY KEY AUTOINCREMENT`
- Child tables use `ON DELETE CASCADE` for character-owned data
- Use `CHECK` constraints for enums (e.g., `CHECK (type IN ('melee','ranged'))`)
- Use `UNIQUE` constraints where appropriate (e.g., `UNIQUE(character_id, tier, col, row)`)

### Current Tables (~30)

**Reference data (TEXT PK):** ancestries, ancestry_abilities, classes, ancestry_classes, class_min_scores, saving_throws, bthb_progression, xp_table, spell_slots, weapons, armor, shields, items, starting_equipment, terrain, monsters, spells, stronghold_structures, stronghold_upgrades

**Lookup tables (INTEGER PK):** encounter_tables, domain_events, quest_templates, ability_mods

**Game state (INTEGER AUTOINCREMENT):** characters, character_equipment, character_spells, character_quests, character_stronghold, stronghold_built_structures, explored_hexes, combat_log

**System:** schema_migrations

## Migration File Conventions

**Naming:** `YYYYMMDDHHMMSS_description.sql`

Example: `20260704000001_baseline_seed_data.sql`

**Rules:**
- Seed data uses `INSERT OR IGNORE` so migrations are idempotent
- Each migration self-registers in schema_migrations: `INSERT OR IGNORE INTO schema_migrations (version) VALUES ('filename_without_extension');`
- The migration runner also records applied migrations with `INSERT OR IGNORE`, so double-registration is harmless

### How to Add a New Migration

1. Create `server/internal/database/migrations/YYYYMMDDHHMMSS_description.sql`
2. Use `INSERT OR IGNORE` for seed data
3. Include the self-registration line at the top or bottom
4. The `//go:embed migrations/*.sql` directive picks it up automatically at compile time

### Adding a New Table

1. Add `CREATE TABLE IF NOT EXISTS` to `schema.sql`
2. If seeding data, create a new migration file (do NOT modify existing migrations)
3. Follow the key convention: TEXT PK for reference data, INTEGER AUTOINCREMENT for game state
