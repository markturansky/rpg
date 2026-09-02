# 05 — Handler Layer

All game logic and message dispatch lives in `server/internal/ws/handlers.go`.

## Handler Struct

The Handler holds pointers to all 17 services:

```go
type Handler struct {
    ancestryService    *models.AncestryService
    classService       *models.ClassService
    weaponService      *models.WeaponService
    armorService       *models.ArmorService
    shieldService      *models.ShieldService
    terrainService     *models.TerrainService
    monsterService     *models.MonsterService
    spellService       *models.SpellService
    itemService        *models.ItemService
    abilityModService  *models.AbilityModService
    encounterService   *models.EncounterService
    characterService   *models.CharacterService
    questService       *models.QuestService
    strongholdService  *models.StrongholdService
    combatLogService   *models.CombatLogService
    exploredHexService *models.ExploredHexService
    hexService         *models.HexService
}
```

Constructor takes all 17 as positional arguments.

## Message Dispatch

`HandleMessage(env Envelope) []byte` — a switch on `env.Type`:

```go
func (h *Handler) HandleMessage(env Envelope) []byte {
    switch env.Type {
    case "get_ancestries":
        return h.handleGetAncestries()
    case "get_classes":
        return h.handleGetClasses()
    // ...
    default:
        resp, _ := NewErrorEnvelope("unknown", "unknown message type: "+env.Type)
        return resp
    }
}
```

## Current Message Types

### Reference Data (no payload needed)

These all follow the same pattern — call `service.GetAll()`, wrap in envelope:

| Type | Response Type | Service Call |
|---|---|---|
| `get_ancestries` | `ancestries` | `ancestryService.GetAll()` |
| `get_classes` | `classes` | `classService.GetAll()` |
| `get_weapons` | `weapons` | `weaponService.GetAll()` |
| `get_armor` | `armor` | `armorService.GetAll()` |
| `get_shields` | `shields` | `shieldService.GetAll()` |
| `get_terrain` | `terrain` | `terrainService.GetAll()` |
| `get_monsters` | `monsters` | `monsterService.GetAll()` |
| `get_spells` | `spells` | `spellService.GetAll()` |
| `get_items` | `items` | `itemService.GetAll()` |

Pattern for a reference data handler:

```go
func (h *Handler) handleGetThings() []byte {
    things, err := h.thingService.GetAll()
    if err != nil {
        resp, _ := NewErrorEnvelope("things", err.Error())
        return resp
    }
    resp, _ := NewEnvelope("things", things)
    return resp
}
```

### Parameterized Queries

These unmarshal the payload first:

| Type | Payload | Response Type |
|---|---|---|
| `get_ability_mod` | `{"ability": "str", "score": 18}` | `ability_mod` |
| `get_encounters` | `{"id": "plains"}` | `encounters` |
| `get_starting_equipment` | `{"id": "fighter"}` | `starting_equipment` |

Pattern:

```go
func (h *Handler) handleGetEncounters(payload json.RawMessage) []byte {
    var req QueryPayload
    if err := json.Unmarshal(payload, &req); err != nil {
        resp, _ := NewErrorEnvelope("encounters", "invalid payload")
        return resp
    }
    entries, err := h.encounterService.GetByTerrain(req.ID)
    if err != nil {
        resp, _ := NewErrorEnvelope("encounters", err.Error())
        return resp
    }
    resp, _ := NewEnvelope("encounters", entries)
    return resp
}
```

### Game Actions

#### create_character

**Request:**
```json
{
    "type": "create_character",
    "payload": {
        "name": "Thorin Ironforge",
        "ancestry_id": "dwarf",
        "class_id": "fighter",
        "str": 16, "dex": 12, "con": 14,
        "int_": 10, "wis": 11, "cha": 9,
        "world_seed": 42
    }
}
```

**Server-side logic:**
1. Validate required fields (name, ancestry_id, class_id)
2. Check class minimum scores via `classService.MeetsMinimumScores()`
3. Look up ancestry for stat adjustments and movement rate
4. Look up class for hit die and gold dice
5. Apply ancestry stat adjustments to base scores
6. Roll HP: `rollDice(1, cls.HitDie)` + CON modifier (minimum 1)
7. Roll gold: `rollDice(cls.GoldDice, cls.GoldDie) * cls.GoldMultiplier`
8. Create character with defaults: level=1, xp=0, ac=10, current_address="/0", day=1, hour=8.0, rations=7
9. Materialize starting hex via `hexService.GetOrCreate()`
10. Mark starting hex explored
11. Return created character with auto-generated id and timestamps

**Response type:** `character_created`

#### get_character

**Request:** `{"type": "get_character", "payload": {"character_id": 1}}`
**Response type:** `character`

#### move

**Request:**
```json
{
    "type": "move",
    "payload": {
        "character_id": 1,
        "direction": 3
    }
}
```

Valid directions: `0-5` (child hex indices within the same parent)

**Server-side logic:**
1. Validate direction (0-5)
2. Load character
3. Compute new address by replacing last index with direction
4. Validate new address is a valid sibling (same parent)
5. Compute terrain via `models.TerrainForAddress(newAddress, worldSeed)`
6. Look up terrain in DB for move_cost
7. Block impassable terrain (move_cost >= 999)
8. Calculate travel time: `terrain.MoveCost * (120.0 / movementRate)`
9. Advance game clock (hours, day rollover)
10. Check lost chance: `rand.Intn(6)+1 <= terrain.LostChance` — if lost, position doesn't change
11. Save character state (current_address updated)
12. Materialize hex via `hexService.GetOrCreate()`
13. Mark hex explored via `exploredHexService.MarkExplored()`

**Response payload:**
```json
{
    "success": true,
    "new_address": "/3",
    "terrain_id": "grassland",
    "terrain_name": "Grassland",
    "tier_name": "world",
    "depth": 1,
    "game_day": 1,
    "game_hour": 9.0,
    "got_lost": false,
    "needs_rest": false
}
```

**Response type:** `move_result`

#### zoom_in

**Request:**
```json
{
    "type": "zoom_in",
    "payload": {
        "character_id": 1,
        "child_index": 3
    }
}
```

**Server-side logic:**
1. Load character, check depth < MaxDepth (6)
2. Validate child_index (0-5)
3. Set new address = `Child(currentAddress, childIndex)`
4. Update character's current_address
5. Materialize hex and all 6 siblings
6. Mark new hex explored
7. Return zoom_result with siblings list

**Response type:** `zoom_result`

#### zoom_out

**Request:**
```json
{
    "type": "zoom_out",
    "payload": {
        "character_id": 1
    }
}
```

**Server-side logic:**
1. Load character, check depth > 1 (can't zoom out of world tier)
2. Set new address = `Parent(currentAddress)`
3. Update character's current_address
4. If parent has a parent, materialize siblings
5. Return zoom_result

**Response type:** `zoom_result`

## Helper Functions

### rollDice(count, die) → total

Rolls `count` dice of size `die` using `rand.Intn(die)+1`.

### Hex Address Utilities (in models/hex_address.go)

- `models.WorldAddress(q, r)` — builds world-level address like `/3,-2`
- `models.ParseWorldCoord(address)` — extracts q,r from world address
- `models.WorldNeighbor(q, r, direction)` — returns neighbor q,r using pointy-hex offsets
- `models.SubIndices(address)` — returns sub-hex child indices (everything after the world root)
- `models.Root(address)` — returns the world-level root segment
- `models.FromIndices(indices)` — builds path from sub-hex index slice
- `models.Depth(address)`, `models.Parent(address)`, `models.Child(address, index)` — address utilities
- `models.Children(address)` — returns all 6 child addresses
- `models.TierName(address)` — returns tier name for depth (world/regional/local/district/street/tactical)
- `models.TerrainForAddress(address, worldSeed)` — deterministic terrain from address path
- `models.SeedForAddress(address, worldSeed)` — hash combine with primes for avalanche mixing

## Adding a New Handler

1. Add payload struct to `message.go` (if needed)
2. Add `case "action_name":` to the switch in `HandleMessage`
3. Write the handler method: `func (h *Handler) handleActionName(payload json.RawMessage) []byte`
4. Follow the error pattern: always return `NewErrorEnvelope()` on failure
5. Follow the success pattern: always return `NewEnvelope("response_type", data)`
6. If the handler needs a new service, add the field to Handler struct and update `NewHandler()` constructor
