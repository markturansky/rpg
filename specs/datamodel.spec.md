# RPG Data Model Specification

## Overview

This document defines the normalized relational data model for the Tile World RPG.
The schema is designed for SQLite with Go services following the same patterns as
the `stonks` project: embedded schema + ordered migrations, `*sql.DB` service structs,
`RETURNING` clauses, and `?` parameter placeholders.

All game rules, lookup tables, and reference data live in the database as seed data
inserted via the baseline migration. The WebSocket API serves this data to the client.

---

## Entity Relationship Diagram

```
┌──────────────┐       ┌──────────────────┐       ┌──────────────┐
│  ancestries  │──┐    │ ancestry_classes  │    ┌──│   classes    │
├──────────────┤  │    ├──────────────────┤    │  ├──────────────┤
│ id TEXT PK   │  └───>│ ancestry_id TEXT  │FK  │  │ id TEXT PK   │
│ name         │       │ class_id TEXT     │FK──┘  │ name         │
│ str_adj      │       │ level_limit      │       │ hit_die      │
│ dex_adj      │       └──────────────────┘       │ prime        │
│ con_adj      │                                  │ armor_allowed│
│ int_adj      │       ┌──────────────────┐       │ shield       │
│ wis_adj      │       │ class_min_scores │       │ weapons      │
│ cha_adj      │       ├──────────────────┤       │ gold_dice    │
│ movement_rate│       │ class_id TEXT FK  │──────>│ gold_die     │
│ infravision  │       │ ability TEXT      │       │ gold_mult    │
│ created_at   │       │ minimum INTEGER   │       │ created_at   │
└──────────────┘       └──────────────────┘       └──────┬───────┘
       │                                                  │
       │  ┌──────────────────┐                            │
       │  │ancestry_abilities│        ┌───────────────────┘
       │  ├──────────────────┤        │
       └─>│ ancestry_id TEXT │FK      │
          │ ability TEXT     │        │
          └──────────────────┘        │
                                      │
┌──────────────────┐    ┌─────────────┴────────┐    ┌──────────────────┐
│  saving_throws   │    │   bthb_progression   │    │    xp_table      │
├──────────────────┤    ├──────────────────────┤    ├──────────────────┤
│ class_id TEXT FK  │    │ class_id TEXT FK      │    │ class_id TEXT FK  │
│ min_level INTEGER│    │ level INTEGER         │    │ level INTEGER     │
│ max_level INTEGER│    │ bonus INTEGER         │    │ xp_required INT   │
│ aimed INTEGER    │    └──────────────────────┘    │ title TEXT        │
│ breath INTEGER   │                                └──────────────────┘
│ death INTEGER    │
│ petrify INTEGER  │    ┌──────────────────┐
│ spells INTEGER   │    │   spell_slots    │
└──────────────────┘    ├──────────────────┤
                        │ class_id TEXT FK  │
                        │ caster_level INT │
                        │ spell_level INT  │
                        │ slots INTEGER    │
                        └──────────────────┘

┌──────────────┐    ┌──────────────┐    ┌────────────────┐
│   weapons    │    │    armor     │    │    shields     │
├──────────────┤    ├──────────────┤    ├────────────────┤
│ id TEXT PK   │    │ id TEXT PK   │    │ id TEXT PK     │
│ name         │    │ name         │    │ name           │
│ damage_sm_n  │    │ ac INTEGER   │    │ ac_bonus INT   │
│ damage_sm_d  │    │ weight INT   │    │ weight INTEGER │
│ damage_sm_b  │    │ cost INTEGER │    │ cost INTEGER   │
│ damage_lg_n  │    │ move_cap INT │    └────────────────┘
│ damage_lg_d  │    │ created_at   │
│ damage_lg_b  │    └──────────────┘
│ weight       │
│ cost         │         ┌──────────────────────┐
│ type TEXT    │         │ starting_equipment   │
│ thrown BOOL  │         ├──────────────────────┤
│ attacks_per  │         │ class_id TEXT FK      │
│ created_at   │         │ item_type TEXT        │  -- 'weapon','armor','shield','item'
└──────────────┘         │ item_id TEXT          │  -- FK to weapons/armor/shields/items
                         │ quantity INTEGER      │
                         └──────────────────────┘

┌──────────────┐    ┌────────────────────┐
│    items     │    │   ability_mods     │
├──────────────┤    ├────────────────────┤
│ id TEXT PK   │    │ ability TEXT        │  -- 'str','dex','con','int','wis','cha'
│ name         │    │ score_min INTEGER   │
│ effect TEXT  │    │ score_max INTEGER   │
│ cost INTEGER │    │ to_hit INTEGER      │  -- STR melee, DEX missile
│ weight       │    │ damage INTEGER      │  -- STR only
│ created_at   │    │ ac_mod INTEGER      │  -- DEX only
└──────────────┘    │ hp_mod INTEGER      │  -- CON only
                    │ hp_mod_fighter INT  │  -- CON fighter bonus
                    │ encumbrance INT    │  -- STR only
                    │ surprise INTEGER   │  -- DEX only
                    │ max_henchmen INT   │  -- CHA only
                    │ loyalty_pct INT    │  -- CHA only
                    │ reaction_pct INT   │  -- CHA only
                    └────────────────────┘

┌──────────────────┐    ┌──────────────────────┐
│    spells        │    │     monsters         │
├──────────────────┤    ├──────────────────────┤
│ id TEXT PK       │    │ id TEXT PK            │
│ name             │    │ name                  │
│ class_id TEXT FK │    │ hit_dice TEXT          │  -- e.g. "2+1", "1-1"
│ level INTEGER    │    │ hit_dice_count INT    │
│ effect TEXT      │    │ hit_dice_bonus INT    │
│ damage TEXT      │    │ xp INTEGER            │
│ duration TEXT    │    │ ac INTEGER             │
│ range TEXT       │    │ attacks TEXT           │
│ save_type TEXT   │    │ damage TEXT            │
│ casting_time INT │    │ special TEXT           │
│ created_at       │    │ morale INTEGER         │
└──────────────────┘    │ size TEXT              │  -- 'S','M','L'
                        │ created_at             │
                        └──────────────────────┘

┌──────────────────────┐    ┌────────────────────────┐
│  encounter_tables    │    │     terrain            │
├──────────────────────┤    ├────────────────────────┤
│ id INTEGER PK AI     │    │ id TEXT PK              │
│ terrain_id TEXT FK   │    │ name                    │
│ roll_value INTEGER   │    │ color TEXT               │
│ monster_id TEXT FK   │    │ move_cost REAL           │
│ count_dice INTEGER   │    │ lost_chance INTEGER      │  -- d6 threshold
│ count_die INTEGER    │    │ vision_range INTEGER     │
│ xp_override INTEGER │    │ encounter_freq TEXT      │  -- '1-in-6','1-in-8', etc.
│ notes TEXT           │    │ created_at               │
└──────────────────────┘    └────────────────────────┘

┌─────────────────────────┐
│         tiles           │       Lazily materialized tile world
├─────────────────────────┤
│ address TEXT PK          │  -- tile path e.g. "map2_05_07"
│ parent_address TEXT FK   │  -- FK to tiles(address), NULL for root
│ depth INTEGER            │  -- 0=root, 1=first cut, 2=second cut, ...
│ grid_col INTEGER         │  -- column within parent (0-9)
│ grid_row INTEGER         │  -- row within parent (0-9)
│ terrain_id TEXT FK       │  -- FK to terrain(id)
│ world_seed INTEGER       │
│ created_at               │
└─────────────────────────┘

┌────────────────────────────┐    ┌──────────────────────┐
│  stronghold_structures     │    │  stronghold_upgrades  │
├────────────────────────────┤    ├──────────────────────┤
│ id TEXT PK                  │    │ id TEXT PK            │
│ name                        │    │ name                  │
│ cost INTEGER                │    │ cost INTEGER          │
│ build_weeks INTEGER         │    │ prerequisite TEXT     │
│ garrison_capacity INTEGER   │    │ pop_required INTEGER  │
│ notes TEXT                  │    │ benefit TEXT          │
│ created_at                  │    │ created_at            │
└────────────────────────────┘    └──────────────────────┘

┌──────────────────────┐
│    domain_events     │
├──────────────────────┤
│ id INTEGER PK AI     │
│ roll_value INTEGER   │
│ name TEXT            │
│ effect TEXT          │
│ created_at           │
└──────────────────────┘

┌──────────────────────┐
│    quest_templates   │
├──────────────────────┤
│ id INTEGER PK AI     │
│ type TEXT            │  -- 'kill','fetch','escort','explore'
│ difficulty TEXT      │  -- 'easy','medium','hard'
│ description TEXT     │
│ gold_min INTEGER     │
│ gold_max INTEGER     │
│ xp_reward INTEGER    │
│ item_reward TEXT     │
│ created_at           │
└──────────────────────┘

======================== GAME STATE TABLES (per-session, mutable) ========================

┌─────────────────────────┐
│      characters         │       The player's saved character
├─────────────────────────┤
│ id INTEGER PK AI        │
│ name TEXT               │
│ ancestry_id TEXT FK     │
│ class_id TEXT FK        │
│ level INTEGER           │
│ xp INTEGER              │
│ hp INTEGER              │
│ max_hp INTEGER          │
│ ac INTEGER              │
│ gold INTEGER            │
│ str INTEGER             │
│ dex INTEGER             │
│ con INTEGER             │
│ int_ INTEGER            │  -- 'int' is reserved in most langs
│ wis INTEGER             │
│ cha INTEGER             │
│ exceptional_str INTEGER │  -- d100 for 18 STR fighters
│ movement_rate INTEGER   │
│ current_tile TEXT       │  -- tile address e.g. "map2_35_07"
│ game_day INTEGER        │
│ game_hour REAL          │
│ travel_hours_today REAL │
│ rations INTEGER         │
│ world_seed INTEGER      │
│ created_at              │
│ updated_at              │
└─────────────────────────┘

┌──────────────────────────┐
│  character_equipment     │
├──────────────────────────┤
│ id INTEGER PK AI         │
│ character_id INTEGER FK  │
│ item_type TEXT           │  -- 'weapon','armor','shield','item'
│ item_id TEXT             │
│ equipped BOOLEAN         │
│ quantity INTEGER          │
│ created_at               │
└──────────────────────────┘

┌──────────────────────────┐
│  character_spells        │
├──────────────────────────┤
│ id INTEGER PK AI         │
│ character_id INTEGER FK  │
│ spell_id TEXT FK         │
│ memorized BOOLEAN        │
│ created_at               │
└──────────────────────────┘

┌──────────────────────────┐
│  character_quests        │
├──────────────────────────┤
│ id INTEGER PK AI         │
│ character_id INTEGER FK  │
│ quest_template_id INT FK │
│ status TEXT              │  -- 'active','completed','failed'
│ target_terrain TEXT      │
│ target_count INTEGER     │
│ current_count INTEGER    │
│ reward_gold INTEGER      │
│ reward_xp INTEGER        │
│ created_at               │
│ updated_at               │
└──────────────────────────┘

┌──────────────────────────┐
│  character_stronghold    │
├──────────────────────────┤
│ id INTEGER PK AI         │
│ character_id INTEGER FK  │
│ tile_address TEXT        │  -- tile address where stronghold is built
│ population INTEGER       │
│ monthly_income INTEGER   │
│ garrison_count INTEGER   │
│ created_at               │
│ updated_at               │
└──────────────────────────┘

┌──────────────────────────────┐
│ stronghold_built_structures  │
├──────────────────────────────┤
│ id INTEGER PK AI             │
│ stronghold_id INTEGER FK     │
│ structure_id TEXT FK         │
│ completed BOOLEAN            │
│ weeks_remaining INTEGER      │
│ created_at                   │
└──────────────────────────────┘

┌────────────────────────────┐
│  explored_tiles            │
├────────────────────────────┤
│ id INTEGER PK AI           │
│ character_id INTEGER FK    │
│ address TEXT               │  -- tile address, UNIQUE with character_id
│ terrain_id TEXT FK         │
│ discovered_at DATETIME     │
└────────────────────────────┘

┌────────────────────────────┐
│  tile_items                │       Items placed/dropped in the world
├────────────────────────────┤
│ id INTEGER PK AI           │
│ tile_address TEXT          │  -- FK to tiles(address)
│ item_type TEXT             │  -- 'weapon','armor','shield','item'
│ item_id TEXT               │  -- polymorphic FK to reference table
│ quantity INTEGER           │
│ dropped_by INTEGER         │  -- nullable FK to characters(id), NULL if world-spawned
│ created_at DATETIME        │
└────────────────────────────┘

┌────────────────────────────┐
│  tile_npcs                 │       Persistent people/creatures in the world
├────────────────────────────┤
│ id INTEGER PK AI           │
│ tile_address TEXT          │  -- FK to tiles(address)
│ monster_id TEXT            │  -- nullable FK to monsters(id), template stats
│ name TEXT                  │  -- display name, e.g. "Old Gareth the Hermit"
│ disposition TEXT           │  -- 'friendly','neutral','hostile'
│ hp INTEGER                 │
│ max_hp INTEGER             │
│ dialogue TEXT              │  -- nullable, what they say on interaction
│ vendor BOOLEAN             │  -- whether they buy/sell
│ created_at DATETIME        │
└────────────────────────────┘

┌────────────────────────┐
│  combat_log            │
├────────────────────────┤
│ id INTEGER PK AI       │
│ character_id INT FK    │
│ monster_id TEXT FK     │
│ outcome TEXT           │  -- 'victory','fled','died'
│ xp_earned INTEGER      │
│ gold_earned INTEGER    │
│ game_day INTEGER       │
│ created_at             │
└────────────────────────┘

┌────────────────────┐
│ schema_migrations  │
├────────────────────┤
│ version TEXT PK    │
│ applied_at         │
└────────────────────┘
```

---

## Table Relationships Summary

| Parent | Child | Relationship | Join |
|--------|-------|-------------|------|
| ancestries | ancestry_classes | 1:N | ancestry_id |
| classes | ancestry_classes | 1:N | class_id |
| ancestries | ancestry_abilities | 1:N | ancestry_id |
| classes | class_min_scores | 1:N | class_id |
| classes | saving_throws | 1:N | class_id |
| classes | bthb_progression | 1:N | class_id |
| classes | xp_table | 1:N | class_id |
| classes | spell_slots | 1:N | class_id |
| classes | starting_equipment | 1:N | class_id |
| classes | spells | 1:N | class_id |
| terrain | encounter_tables | 1:N | terrain_id |
| monsters | encounter_tables | 1:N | monster_id |
| ancestries | characters | 1:N | ancestry_id |
| classes | characters | 1:N | class_id |
| characters | character_equipment | 1:N | character_id |
| characters | character_spells | 1:N | character_id |
| characters | character_quests | 1:N | character_id |
| characters | character_stronghold | 1:1 | character_id |
| characters | explored_tiles | 1:N | character_id |
| tiles | tiles (self) | 1:N | parent_address |
| terrain | tiles | 1:N | terrain_id |
| characters | combat_log | 1:N | character_id |
| character_stronghold | stronghold_built_structures | 1:N | stronghold_id |
| tiles | tile_items | 1:N | tile_address |
| characters | tile_items | 1:N | dropped_by |
| tiles | tile_npcs | 1:N | tile_address |
| monsters | tile_npcs | 1:N | monster_id |

---

## Normalization Notes

### What Normalization Solves

1. **No duplicate rule data** — Ability score modifiers, saving throws, BTHB progression,
   spell slots, and XP thresholds are each stored once in their own tables. A rule change
   requires updating one row, not hunting through JS constants scattered across files.

2. **Referential integrity** — Foreign keys enforce that a character's `class_id` actually
   exists in `classes`, that encounter tables reference real monsters, that starting
   equipment references real items. No dangling references.

3. **Query-driven game logic** — Instead of `if (con <= 3) return -2; if (con <= 6) return -1; ...`
   in JS, the API returns `SELECT hp_mod FROM ability_mods WHERE ability='con' AND ? BETWEEN score_min AND score_max`.

4. **Encounter tables become data** — Adding a new terrain type with encounters is an INSERT,
   not a code change. Modding the game becomes editing rows.

5. **Character state is relational** — Equipment, spells, quests, and stronghold data are
   properly normalized instead of nested JSON blobs. Queries like "find all characters who
   have a longsword equipped" become trivial.

6. **Fog of war is a table** — `explored_tiles` tracks what the player has seen, queryable
   by depth/position. No more managing a giant boolean array in gameState.

7. **Combat history** — `combat_log` enables stats like "total XP from combat", "monsters
   killed by type", win/loss ratios. Impossible with the current ephemeral state.

### What the WebSocket API Enables

- **Thin client** — The client only renders. All game rules, dice rolls, and state mutations
  happen server-side. The client sends `{"type": "move", "payload": {...}}` and gets back
  the result including terrain, time elapsed, encounter data.

- **No cheating** — Players can't modify game state. The server is the source of truth.

- **Multiplayer-ready** — Multiple clients can connect to the same server via WebSocket hub.

- **Modding via data** — Change monster stats, add new spells, rebalance encounter tables
  by editing the database. No code changes needed.

- **Save/load becomes trivial** — Character state is already persisted in SQLite. "Save game"
  is just the current DB state.

### Tile Address System

The game uses the same address system as the tile pyramid (see `tile_rendering.spec.md`).
A tile's address is its name in the tile hierarchy (e.g., `map2_35_07`). This unifies
the visual rendering layer and the game data layer — there is no separate coordinate
space.

- **Address format** — Tile addresses encode the full path through the hierarchy:
  `map2` (root), `map2_35` (depth 1, grid index 35), `map2_35_07` (depth 2, grid
  index 7 within parent `map2_35`). The suffix after each `_` is the 2-digit grid
  index (00-99) within the parent's 10×10 grid.

- **Grid position from address** — Given a grid index:
  `col = index % 10` (0-9), `row = index / 10` (0-9).

- **100 children per tile** — Each tile has 100 children arranged in a 10-column × 10-row
  grid. Children are indexed 00-99 left-to-right, top-to-bottom:
  ```
  00  01  02  03  04  05  06  07  08  09    (row 0)
  10  11  12  13  14  15  16  17  18  19    (row 1)
  20  21  22  23  24  25  26  27  28  29    (row 2)
  ...                                        ...
  90  91  92  93  94  95  96  97  98  99    (row 9)
  ```

- **4-directional movement (NSEW)** — Movement uses cardinal compass directions.
  Moving north from `map2_35_17` (col=7, row=1) goes to `map2_35_07` (col=7, row=0).
  Moving east wraps into the neighboring parent tile's children. See neighbor
  computation below.

- **Depth determines tier** — Depth 0 is the full continent (~200 mi). Depth 1 divides
  it into 100 regional tiles (~20 mi each). Each subsequent depth subdivides by 10×10.
  Depth 5 leaves are ~10'×10' tactical combat squares.

- **Deterministic terrain** — `TerrainForTile(address, worldSeed)` computes terrain
  using the address and world seed. Parent terrain biases children (70% lerp).

- **Eager root materialization** — The 100 depth-1 tiles are bulk-inserted at world
  creation time via `MaterializeWorld(rootAddress, worldSeed)`.

- **Lazy sub-tile materialization** — Depth 2+ tiles are only INSERT-ed when a
  character enters them. Terrain can always be recomputed from the pure function.

### Neighbor Computation (NSEW)

Within a parent tile's 10×10 grid, neighbors are trivial:

```
North: same col, row - 1
South: same col, row + 1
East:  col + 1, same row
West:  col - 1, same row
```

When movement crosses a parent boundary (e.g., moving north from row 0), the
neighbor is in an adjacent parent tile:

```
Moving north from (col=2, row=0) in parent P:
  1. Find P's northern neighbor (P_north) — the parent tile in the same
     row-0 position above P in the grandparent's grid
  2. The destination is (col=2, row=2) in P_north — bottom row, same column
```

This requires walking up the tile tree to find the common ancestor, then back
down into the adjacent subtree. The algorithm is:

```
func Neighbor(address string, direction Direction) string:
  1. Parse grid_index from last segment of address
  2. Compute (col, row) from grid_index
  3. Apply direction offset: N=(0,-1), S=(0,+1), E=(+1,0), W=(-1,0)
  4. If new (col, row) is within 0-9, 0-9 → same parent, new index
  5. If out of bounds → recurse: find Neighbor(parent, direction),
     then select the child on the opposite edge
     (e.g., moved north out of parent → enter southern row of neighbor)
```

Edge of the world: moving off the root tile's boundary returns an error
(impassable — edge of the known world).

### Tile Contents

- **`tile_items`** — Persistent items placed in the world. A character can drop equipment
  into a tile (`dropped_by` tracks who left it, NULL for world-spawned loot). Uses the
  same polymorphic `item_type`/`item_id` discriminator as `character_equipment`. Multiple
  items can exist at the same address. Items persist until picked up or despawned.

- **`tile_npcs`** — Persistent people and creatures placed in tiles. Each row is a live
  instance with its own HP, disposition, and optional dialogue. The `monster_id` FK
  links to the `monsters` template for base stats, but `name`, `hp`, and `disposition`
  can diverge from the template (e.g., a wounded wolf, a friendly hermit). NPCs with
  `vendor = true` can buy/sell items. NPCs without a `monster_id` are pure social
  characters (merchants, quest-givers, townsfolk).

### Tile Address Examples

```
map2                    depth 0   root (~200 mi continent)
map2_35                 depth 1   grid index 35 → col=5, row=3 (~20 mi region)
map2_35_07              depth 2   grid index 7 → col=7, row=0 within map2_35 (~2 mi area)
map2_35_07_42           depth 3   grid index 42 → col=2, row=4 within map2_35_07 (~1,000' district)
map2_35_07_42_55        depth 4   grid index 55 → col=5, row=5 within map2_35_07_42 (~100' block)
map2_35_07_42_55_00     depth 5   grid index 0 → col=0, row=0 within map2_35_07_42_55 (~10' tactical)
```

Each depth level has `100^depth` total tiles (power of 10):

| Depth | Total Tiles | Scale |
|-------|-------------|-------|
| 0 | 1 | ~200 mi (full continent) |
| 1 | 100 | ~20 mi (regional) |
| 2 | 10,000 | ~2 mi (area) |
| 3 | 1,000,000 | ~1,000' (district) |
| 4 | 100,000,000 | ~100' (block) |
| 5 | 10,000,000,000 | ~10' (tactical) |

---

## Migration Strategy

Following the stonks pattern:

1. `schema.sql` — Base DDL with `CREATE TABLE IF NOT EXISTS` for all tables.
2. `migrations/YYYYMMDDHHMMSS_description.sql` — Additive-only changes.
3. `schema_migrations` table tracks applied versions.
4. All SQL embedded via `//go:embed` — no runtime file dependencies.
5. Seed data (classes, ancestries, weapons, armor, spells, monsters, terrain, encounter
   tables, ability modifiers, stronghold structures) inserted in the baseline migration
   via `INSERT OR IGNORE`.

### Baseline Migration Contents

The baseline migration (`20260704000001_baseline_v1_schema.sql`) will contain:

- All DDL from `schema.sql`
- Seed data for all 7 ancestries
- Seed data for all 6 classes (with min scores, BTHB, saves, XP tables, spell slots)
- All 13 weapons, 7 armor types, 2 shields
- All 12 consumable items
- All 21 spells (9 magic-user, 12 cleric)
- All 27 monsters
- All encounter tables (8 terrain types × 6-8 entries each)
- All ability modifier ranges (6 abilities × ~10 ranges each)
- All 13 terrain types
- All stronghold structures and upgrades
- All domain events
- Quest templates

---

## WebSocket Message Mapping

| Message Type | Table(s) | Direction |
|-------------|----------|-----------|
| get_ancestries | ancestries, ancestry_classes, ancestry_abilities | request → ancestries |
| get_classes | classes, class_min_scores, saving_throws, bthb_progression, xp_table, spell_slots | request → classes |
| get_weapons | weapons | request → weapons |
| get_armor | armor | request → armor |
| get_shields | shields | request → shields |
| get_terrain | terrain | request → terrain |
| get_monsters | monsters | request → monsters |
| get_spells | spells | request → spells |
| get_items | items | request → items |
| get_encounters | encounter_tables, monsters | request → encounters |
| get_ability_mod | ability_mods | request → ability_mod |
| create_character | characters, tiles, explored_tiles | request → character_created |
| get_character | characters | request → character |
| move | characters, tiles, terrain, explored_tiles | request → move_result |
| zoom_in | characters, tiles, explored_tiles | request → zoom_result |
| zoom_out | characters, tiles | request → zoom_result |
| get_starting_equipment | starting_equipment | request → starting_equipment |
| drop_item | tile_items, character_equipment | request → drop_result |
| pick_up_item | tile_items, character_equipment | request → pick_up_result |
| get_tile_contents | tile_items, tile_npcs | request → tile_contents |
| talk_to_npc | tile_npcs | request → npc_dialogue |
