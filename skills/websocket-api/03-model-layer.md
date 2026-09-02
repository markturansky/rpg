# 03 — Model Layer

All models live in `server/internal/models/`. Each file contains a struct, a service, and all SQL operations for that domain object.

## Pattern

Every model file follows the same structure:

```go
package models

import (
    "database/sql"
    "fmt"
    "time"
)

type Thing struct {
    ID        string    `json:"id"`
    Name      string    `json:"name"`
    CreatedAt time.Time `json:"created_at"`
}

type ThingService struct {
    db *sql.DB
}

func NewThingService(db *sql.DB) *ThingService {
    return &ThingService{db: db}
}

func (s *ThingService) GetAll() ([]Thing, error) {
    rows, err := s.db.Query(`SELECT id, name, created_at FROM things ORDER BY name`)
    if err != nil {
        return nil, fmt.Errorf("failed to query things: %w", err)
    }
    defer rows.Close()

    var things []Thing
    for rows.Next() {
        var t Thing
        if err := rows.Scan(&t.ID, &t.Name, &t.CreatedAt); err != nil {
            return nil, fmt.Errorf("failed to scan thing: %w", err)
        }
        things = append(things, t)
    }
    return things, nil
}

func (s *ThingService) GetByID(id string) (*Thing, error) {
    var t Thing
    err := s.db.QueryRow(`SELECT id, name, created_at FROM things WHERE id = ?`, id).
        Scan(&t.ID, &t.Name, &t.CreatedAt)
    if err != nil {
        return nil, fmt.Errorf("failed to get thing %s: %w", id, err)
    }
    return &t, nil
}
```

## Conventions

### Struct Tags
- All exported fields with `json:"snake_case"` tags
- Optional/nullable fields use pointer types: `*int`, `*string`
- Nullable JSON fields use `omitempty`: `json:"field,omitempty"`

### Constructor
- Always `NewXxxService(db *sql.DB) *XxxService`
- Every constructor takes raw `*sql.DB`, not the `database.DB` wrapper

### SQL
- Raw SQL with `?` placeholders (SQLite parameter style)
- Use `RETURNING` clause on INSERT to get auto-generated fields back:
  ```go
  err := s.db.QueryRow(`INSERT INTO things (...) VALUES (?, ?) RETURNING id, created_at`,
      val1, val2).Scan(&t.ID, &t.CreatedAt)
  ```
- Wrap errors with `fmt.Errorf("failed to <action>: %w", err)`
- Always `defer rows.Close()` after Query calls

### Read-Only vs CRUD

**Reference data services** (ancestry, class, weapon, armor, terrain, monster, spell, item, encounter, ability_mod): `GetAll()` and `GetByID()` only. Data comes from seed migrations.

**Game state services** (character, quest, stronghold, combat_log, explored_hex, hex): Full CRUD — `Create()`, `GetByID()`, `Update()`, `Delete()`.

**Pure function models** (hex_address): No DB dependency. Contains address utilities and deterministic terrain generation.

## Existing Models

### Simple Reference Models
These follow the basic GetAll/GetByID pattern:

| File | Struct | Service | Notes |
|---|---|---|---|
| weapon.go | Weapon | WeaponService | damage_sm/lg split, type melee/ranged |
| armor.go | Armor, Shield | ArmorService, ShieldService | Two structs, two services in one file |
| terrain.go | Terrain | TerrainService | move_cost, lost_chance, vision_range |
| monster.go | Monster | MonsterService | Nullable attacks/damage/special fields |
| spell.go | Spell | SpellService | GetAll, GetByClassAndLevel |
| item.go | Item | ItemService | Also has GetStartingEquipment(classID) |

### Complex Reference Models (with child data)

**ancestry.go** — `AncestryService.GetAll()` and `GetByID()` both call `populateAbilities()` and `populateAllowedClasses()` to load from join tables:
```go
type Ancestry struct {
    // ...base fields...
    Abilities      []string             `json:"abilities"`
    AllowedClasses []AncestryClassEntry `json:"allowed_classes"`
}
```

**class.go** — `ClassService` loads four child tables via `populateClassDetails()`:
```go
type Class struct {
    // ...base fields...
    MinScores       map[string]int   `json:"min_scores"`
    SavingThrows    []SavingThrowRow `json:"saving_throws"`
    BTHBProgression []BTHBRow        `json:"bthb_progression"`
    XPTable         []XPRow          `json:"xp_table"`
    SpellSlots      []SpellSlotRow   `json:"spell_slots,omitempty"`
}
```
Also has `MeetsMinimumScores(classID, scores)` for character creation validation.

### Game State Models

**character.go** — Full CRUD. Character uses `current_address TEXT` (hex address path like `/0/3/2`) instead of world_col/world_row/current_tier:
- `Create(c *Character) (*Character, error)` — uses `RETURNING id, created_at, updated_at`
- `GetByID(id int) (*Character, error)`
- `Update(c *Character) error` — checks `RowsAffected()` for not-found
- `Delete(id int) error`

**ability_mod.go** — `GetModsForScore(ability, score)` uses `BETWEEN score_min AND score_max`

**encounter.go** — `GetByTerrain(terrainID)`, `GetByTerrainAndRoll(terrainID, roll)`

**quest.go** — `AcceptQuest()` uses `RETURNING`, `UpdateQuestProgress()`

**stronghold.go** — Multiple structs: StrongholdStructure, StrongholdUpgrade, CharacterStronghold (uses `hex_address TEXT`), DomainEvent

**combat_log.go** — `Create()` with `RETURNING`, `GetByCharacter()`

**explored_hex.go** — `MarkExplored(characterID, address, terrainID)` uses `INSERT OR IGNORE` (idempotent), `GetAllExplored()`, `GetExploredByTier()`, `IsExplored()`

**hex.go** — `HexService` for hex materialization (eager at world level, lazy for sub-hexes):
- `GetOrCreate(address, worldSeed)` — returns existing hex or creates it (recursively creates parents)
- `GetByAddress(address)` — returns hex or error if not materialized
- `GetChildren(address)` — returns only already-materialized children
- `MaterializeChildren(address, worldSeed)` — creates all 6 children, returns them
- `MaterializeWorld(minQ, minR, maxQ, maxR, worldSeed)` — bulk-creates all root-level hexes in a bounding rectangle (transactional)
- `GetWorldHexes(minQ, minR, maxQ, maxR)` — returns all materialized depth-1 hexes in a coordinate range

**hex_address.go** — Pure functions with NO database dependency:
- World coordinates: `WorldAddress(q, r)`, `ParseWorldCoord(address)`, `IsWorldAddress(address)`, `WorldNeighbor(q, r, direction)`
- Address utilities: `Root()`, `Depth()`, `Parent()`, `Child()`, `Children()`, `Indices()`, `SubIndices()`, `FromIndices()`, `IsAncestor()`, `TierName()`, `TierScale()`
- Terrain generation: `SeedForAddress(address, worldSeed)`, `TerrainForAddress(address, worldSeed)`
- Constants: `MaxDepth=6`, `ChildrenPerHex=6`, `TierNames`, `TierScales`, `TerrainBiases`, `PointyHexNeighborOffsets`
- `TotalHexesBelow(depth)` — e.g., `TotalHexesBelow(5) == 9331`

## How to Add a New Model

1. Create `server/internal/models/thing.go`
2. Define the struct with `json` tags
3. Define `ThingService` with `db *sql.DB`
4. Write `NewThingService(db *sql.DB) *ThingService`
5. Implement query methods following the patterns above
6. If the model has child data loaded eagerly, use a private `populate*()` method
7. Wire the service in `main.go` and pass to `ws.NewHandler()`
