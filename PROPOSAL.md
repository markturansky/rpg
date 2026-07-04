# Hex World RPG — OSRIC / AD&D 1st Edition Rules

## Overview

A single-file HTML RPG built on a procedurally generated hex world map. Mechanics are
drawn from OSRIC 3.0 (the faithful 1e AD&D restatement). The game uses five nested
zoom tiers — world, regional, local, town, and tactical — with continuous Google Maps-style
zoom transitions between them. Movement is grounded in travel time rather than arbitrary
pixel distances.

---

## 1. World Scale & Navigation

### Map Tiers

The game world operates at five nested scales, modeled after Google Maps-style continuous
zoom. Each tier is procedurally generated from its parent hex on demand, seeded by the
parent coordinates for deterministic results. Only nearby tiles are cached; distant ones
are freed to keep memory bounded.

| Tier | Scale | Grid Per Parent | What Appears | Real-World Analog |
|------|-------|-----------------|--------------|-----------------|
| **World** | 1 hex = 6 miles | 300×200 (root) | Continents, mountain ranges, region labels, town markers | Google Maps satellite — state/country level |
| **Regional** | 1 hex = 1 mile | ~6×6 per world hex | Roads between towns, hamlets, ruins, river fords, terrain patches | City/metro area (Image 3 — Charleston metro) |
| **Local** | 1 hex = 200 feet | ~26×26 per regional hex | Individual farms, crossroads, camps, clearings, bridge detail | Neighborhood (between Images 1 & 2) |
| **Town** | 1 hex = 20 feet | ~50×50 per local hex | Buildings, market stalls, NPCs, walls, gates | Street view (Image 1 — Shem Creek area) |
| **Tactical** | 1 square = 5 feet | 20×15 grid | Combat grid, obstacles, cover, positioning | Interior/encounter |

### Tier Transitions

The player zooms between tiers using scroll wheel or +/- keys. As zoom crosses a
threshold, the game generates the next tier's detail from the current hex:

```
World hex (6 mi) → zoom in → generates 6×6 Regional hexes (1 mi each)
Regional hex (1 mi) → zoom in → generates 26×26 Local hexes (200 ft each)
Local hex (200 ft) → zoom in → generates 50×50 Town hexes (20 ft each)
Town → encounter → generates 20×15 Tactical grid (5 ft squares)
```

Zooming out reverses the process. The player's position is preserved across tiers
by mapping pixel coordinates to the parent hex's sub-grid.

### Procedural Sub-Hex Generation

When the player zooms into a hex, its child grid is generated using:

1. **Parent terrain type** — determines the palette of child terrain types
   (e.g., a Forest world hex generates ~70% forest, 20% grassland, 10% stream at Regional)
2. **Neighbor blending** — edges blend with adjacent parent hexes for seamless transitions
3. **Seeded noise** — `fbm(childCol, childRow, parentSeed)` for natural variation
4. **Feature placement** — roads, ruins, camps, fords placed by seeded RNG
5. **Caching** — generated tiles stored in an LRU cache (max ~50 tiles) keyed by
   `tier:parentCol:parentRow`

### Content By Tier

**Regional (1 hex = 1 mile):**
- Road segments connecting towns (visible as hex paths)
- Hamlets (3–5 buildings, 1–2 NPCs, no walls)
- Ruins and dungeons (encounter locations)
- River crossings: fords, bridges, ferry landings
- Terrain detail: individual groves, clearings, ponds, rock outcrops
- Encounter checks: 1-in-8 per regional hex entered

**Local (1 hex = 200 feet):**
- Individual farmsteads, woodcutter camps, shepherd huts
- Crossroads with signposts
- Bandit camps, monster lairs (visible before triggering)
- Bridge and ford detail (walkable structure)
- Terrain micro-features: fallen trees, streams, boulders
- Encounter checks: 1-in-12 per local hex entered

**Town (1 hex = 20 feet):**
- Individual buildings with doors and interiors
- Market stalls, well, town square
- NPC positions and patrol routes
- Walls, gates, towers (for walled towns)
- Gardens, ponds, paths between buildings
- No encounter checks (safe zone)

### World Map Dimensions

The 300×200 hex grid at 6 miles per hex represents a landmass roughly **1,800 × 1,200
miles** — comparable to Western Europe. This gives meaningful travel times between towns
and makes wilderness exploration feel vast.

### Travel Time

Movement is based on the OSRIC outdoor movement rules. A character's base movement rate
determines how many 6-mile hexes they can cross per day (8 hours of travel).

**Base Daily Travel (hexes per day):**

| Movement Rate | Road | Plains/Grassland | Forest | Hills | Mountain | Desert | Marsh | Tundra |
|--------------|------|-----------------|--------|-------|----------|--------|-------|--------|
| 120 ft (unencumbered, no heavy armor) | 4 | 3 | 2 | 2 | 1 | 2 | 1.5 | 1.5 |
| 90 ft (chain/banded/scale mail) | 3 | 2 | 1.5 | 1.5 | 0.5 | 1.5 | 1 | 1 |
| 60 ft (plate mail / heavy load) | 2 | 1.5 | 1 | 1 | 0.5 | 1 | 0.5 | 0.5 |

**Mounted Travel:** Horse doubles road/plains rates. War horse allows combat while mounted.

### Real-Time to Game-Time Mapping

Movement at any tier translates to game time. The tier determines the time scale:

| Tier | Time Per Hex Crossed | Encounter Check |
|------|---------------------|-----------------|
| World | ~1.5–6 hours (terrain dependent) | 1-in-6 per hex |
| Regional | ~15–60 minutes | 1-in-8 per hex |
| Local | ~1–5 minutes | 1-in-12 per hex |
| Town | Seconds | None (safe zone) |
| Tactical | 1 round = 1 minute | N/A (in combat) |

As the player token crosses hex boundaries at any tier, the game tracks:

1. **Hexes traversed** — increments a counter per tier
2. **Elapsed game time** — accumulated from tier-appropriate time increments
3. **Encounter checks** — rolled on hex entry at tier-appropriate frequency
4. **Rations consumed** — 1 ration per day of accumulated travel time
5. **Rest requirements** — after 8 hours of accumulated travel, must camp

### Day/Night Cycle

Game time advances as the player moves. Visual indicators show time of day:

| Game Time | Visual | Encounter Modifier |
|-----------|--------|-------------------|
| Dawn (6am–8am) | Warm golden light | Normal |
| Day (8am–6pm) | Full brightness | Normal |
| Dusk (6pm–8pm) | Orange/purple tint | +1 to encounter roll |
| Night (8pm–6am) | Dark blue overlay, reduced visibility | +2 to encounter roll |

Camping at night is required. Traveling at night is possible but risky (higher encounter
rate, chance of getting lost).

### Navigation & Getting Lost

When traveling off-road through wilderness, there is a chance of getting lost:

| Terrain | Lost Chance (d6) |
|---------|-----------------|
| Road | Never |
| Plains/Grassland | 1 |
| Forest | 1–2 |
| Dense Forest | 1–3 |
| Hills | 1–2 |
| Mountain | 1–3 |
| Desert | 1–3 |
| Marsh | 1–3 |

When lost, the player drifts 1 hex in a random direction. A ranger reduces the lost
chance by 1 on all terrain.

### Rivers & Water Crossings

Rivers block movement. To cross, the player must:
- Find a bridge (roads crossing rivers have bridges)
- Find a ford (shallow river hexes, marked on map)
- Use a ferry at a town
- Swim (CON check, fail = 1d6 damage, lose 1 random item)

### Fog of War

The world map starts with fog of war. Only hexes within the player's vision range are
revealed. Revealed hexes remain visible on the minimap.

| Terrain Player Is In | Vision Range (hexes) |
|---------------------|---------------------|
| Plains/Road | 3 |
| Grassland/Beach | 2 |
| Forest/Dense Forest | 1 |
| Hills (elevated) | 4 |
| Mountain (elevated) | 6 |
| All terrain at night | 1 |

---

## 2. Character Creation

At game start, the player creates a character before entering the world.

### Ability Scores

Six abilities, each rolled as 3d6 (range 3–18). Fighters, Paladins, and Rangers with
STR 18 roll d100 for exceptional strength (18.01–18.00).

**Strength:**

| Score | To-Hit | Damage | Encumbrance Bonus |
|-------|--------|--------|------------------|
| 3 | -3 | -1 | 0 |
| 4–5 | -2 | -1 | 0 |
| 6–7 | -1 | 0 | 0 |
| 8–9 | 0 | 0 | 0 |
| 10–11 | 0 | 0 | 0 |
| 12–13 | 0 | 0 | +10 lbs |
| 14–15 | 0 | 0 | +20 lbs |
| 16 | 0 | +1 | +35 lbs |
| 17 | +1 | +1 | +50 lbs |
| 18 | +1 | +2 | +75 lbs |
| 18.01–50 | +1 | +3 | +100 lbs |
| 18.51–75 | +2 | +3 | +125 lbs |
| 18.76–90 | +2 | +4 | +150 lbs |
| 18.91–99 | +2 | +5 | +200 lbs |
| 18.00 | +3 | +6 | +300 lbs |

**Dexterity:**

| Score | Surprise | Missile To-Hit | AC Bonus (ascending) |
|-------|---------|---------------|---------------------|
| 3 | -3 | -3 | -4 |
| 4–5 | -2 | -2 | -3 to -2 |
| 6 | -1 | -1 | -1 |
| 7–14 | 0 | 0 | 0 |
| 15 | 0 | 0 | +1 |
| 16 | +1 | +1 | +2 |
| 17 | +2 | +2 | +3 |
| 18 | +3 | +3 | +4 |

**Constitution:**

| Score | HP Modifier (per die) | Notes |
|-------|----------------------|-------|
| 3 | -2 | |
| 4–6 | -1 | |
| 7–14 | 0 | |
| 15–16 | +1 | |
| 17 | +2 (+3 for fighters) | |
| 18 | +2 (+4 for fighters) | |

**Wisdom:** 13+ grants bonus Cleric spell slots. Mental saving throw bonuses at 15+.

**Intelligence:** Determines max additional languages (0–7). Affects Magic-User spell
learning chance.

**Charisma:**

| Score | Max Henchmen | Loyalty Mod | Reaction Mod |
|-------|-------------|-------------|-------------|
| 3 | 1 | -30% | -25% |
| 8 | 3 | -10% | -10% |
| 12 | 5 | 0% | 0% |
| 15 | 7 | +15% | +15% |
| 18 | 15 | +40% | +35% |

### Ancestries (Races)

| Ancestry | Adjustments | Move | Infravision | Key Abilities |
|----------|------------|------|-------------|--------------|
| **Human** | None | 120 ft | None | No level limits, dual-classing |
| **Elf** | +1 DEX, -1 CON | 120 ft | 60 ft | Secret doors 2-in-6, 90% sleep/charm resist |
| **Dwarf** | +1 CON, -1 CHA | 90 ft | 60 ft | Save bonus vs magic/poison, detect stonework |
| **Halfling** | +1 DEX, -1 STR | 90 ft | 60 ft | +3 ranged attacks, save bonus vs magic |
| **Half-Elf** | None | 120 ft | 60 ft | Secret doors, 30% sleep/charm resist |
| **Gnome** | None | 90 ft | 60 ft | Save bonus vs magic, giant-slayer |
| **Half-Orc** | +1 STR, +1 CON, -2 CHA | 120 ft | 60 ft | All fighter-type classes |

Non-human ancestries have level limits per class (e.g., Dwarf Fighter max 7–9 by STR,
Elf Magic-User max 9–11 by INT). Humans are unlimited.

### Classes

| Class | HD | Min Scores | Prime | Armor | Weapons | Starting Gold |
|-------|-----|-----------|-------|-------|---------|-------------|
| **Fighter** | d10 | STR 9, CON 7 | STR | Any | Any | 5d4×10 |
| **Cleric** | d8 | WIS 9 | WIS | Any + shield | Blunt only | 3d6×10 |
| **Magic-User** | d4 | INT 9 | INT | None | Dagger, dart, staff | 2d4×10 |
| **Thief** | d6 | DEX 9 | DEX | Leather/studded | Limited | 2d6×10 |
| **Ranger** | d10 | STR 13, INT 13, WIS 14, CON 14 | STR | Any | Any | 5d4×10 |
| **Paladin** | d10 | STR 12, CON 9, INT 9, WIS 13, CHA 17 | STR | Any | Any | 5d4×10 |

**Key Class Features:**

- **Fighter**: +1 BTHB per level. Extra attacks at level 7 (3/2 rounds) and 13 (2/1).
  At level 2, 1 attack per level vs creatures with <1 HD. Optional weapon specialisation.
- **Cleric**: Divine spells (7 levels), Turn Undead (2d6 roll vs undead HD table),
  bonus spell slots from WIS 13+. Blunt weapons only. At level 9: temple + 3d6+2 followers.
- **Magic-User**: Arcane spells (9 levels), must learn from spellbook (INT-based chance).
  Vancian memorization — spells consumed on cast. At level 7: craft potions/scrolls.
  At level 11: tower.
- **Thief**: Backstab (+4 to hit, x2 damage at level 1, scaling to x5 at level 13).
  Skills: Climb, Hide, Move Quietly, Pick Locks, Pick Pockets, Find/Remove Traps.
  At level 10: guild + 6d4 NPC thieves.
- **Ranger**: +1 damage per level vs "giant-class" creatures. Tracking. Surprise
  opponents 50% of the time. Limited druid/magic-user spells at higher levels.
  Reduces party lost chance by 1 on all terrain.
- **Paladin**: Detect Evil at will. Lay on Hands (2 HP/level/day). Protection from
  Evil 10 ft radius. Turn Undead at level 3 (as cleric 2 levels lower). Divine spells
  at level 9.

### Starting Equipment

Class determines starting gear (OSRIC costs):

- **Fighter**: Chain mail (AC 15, 75 gp), longsword (1d8/1d12, 15 gp), shield (+1 AC, 10 gp)
- **Cleric**: Scale mail (AC 14, 45 gp), mace (1d6+1/1d6, 8 gp), holy symbol
- **Magic-User**: Staff (1d6/1d6, free), spellbook (Read Magic + 1 random), robes
- **Thief**: Leather armor (AC 12, 5 gp), short sword (1d6/1d8, 8 gp), thieves' tools (30 gp)
- **Ranger**: Studded leather (AC 13, 15 gp), longsword (1d8/1d12, 15 gp), longbow (1d6, 60 gp)
- **Paladin**: Chain mail (AC 15, 75 gp), longsword (1d8/1d12, 15 gp), shield (+1 AC, 10 gp)

---

## 3. Combat System

### Tactical Combat Grid

When an encounter triggers, the game switches to the **tactical combat tier**: a zoomed-in
grid where 1 square = 5 feet. The grid is generated from the surrounding terrain hex type.

**Grid size:** 20×15 squares (100 ft × 75 ft).

### Armor Class (Ascending)

Ascending AC is used throughout (descending + ascending = 20).

| Armor | AC (ascending) | Weight | Cost | Move Cap |
|-------|---------------|--------|------|----------|
| Unarmored | 10 | 0 | — | 120 ft |
| Leather | 12 | 15 lbs | 5 gp | 120 ft |
| Studded Leather | 13 | 20 lbs | 15 gp | 120 ft |
| Scale Mail | 14 | 40 lbs | 45 gp | 60 ft |
| Chain Mail | 15 | 30 lbs | 75 gp | 90 ft |
| Banded Mail | 16 | 35 lbs | 200 gp | 90 ft |
| Plate Mail | 17 | 45 lbs | 400 gp | 60 ft |
| Shield (small) | +1 | 5 lbs | 10 gp | — |
| Shield (large) | +1 | 10 lbs | 15 gp | — |
| DEX modifier | Added | — | — | — |

### Attack Resolution

d20 + BTHB (Base To-Hit Bonus) + ability modifier >= target ascending AC → hit.

**BTHB Progression:**

| Level | Fighter | Cleric | Thief | Magic-User |
|-------|---------|--------|-------|------------|
| 1 | +1 | +0 | +0 | +0 |
| 3 | +3 | +1 | +1 | +1 |
| 5 | +5 | +2 | +2 | +2 |
| 7 | +7 | +4 | +4 | +3 |
| 9 | +9 | +5 | +5 | +4 |

Fighters advance +1 per level. Others advance ~+1 per 2–3 levels.

### Initiative

Each side rolls 1d6. **Low roll acts first** (OSRIC rule). Ties = simultaneous resolution.
Spells and special actions must be declared before initiative is rolled.

### Combat Round Sequence

1. Both sides declare spells and special actions
2. Initiative: each side rolls 1d6 (low wins)
3. Winner's side acts (move, attack, cast)
4. Loser's side acts
5. Round complete (1 minute of game time)

### Combat Actions

On their turn, a character can:
- **Attack**: Roll d20 + BTHB + modifier vs AC. Damage = weapon die + STR mod (melee)
  or DEX mod (ranged).
- **Cast a spell**: Takes full round. Interrupted if damaged before completion.
  No DEX AC bonus while casting. Cannot move while casting.
- **Move**: Up to movement rate on the tactical grid (e.g., 120 ft = 24 squares).
- **Charge**: Double move in a straight line, +2 to hit, but defenders with set
  weapons deal double damage.
- **Flee**: Opponents get a free attack at +4 to hit.
- **Use item**: Potion, scroll, etc. Takes full round.
- **Backstab (Thief)**: Must be behind or flanking unaware target. +4 to hit,
  x2 damage (scaling with level).

### Damage

Weapons have two damage values: vs Small-Medium / vs Large creatures.

| Weapon | Damage vs S-M | Damage vs L | Weight | Cost | Type |
|--------|--------------|-------------|--------|------|------|
| Dagger | 1d4 | 1d3 | 1 lb | 2 gp | Melee/Thrown |
| Short Sword | 1d6 | 1d8 | 3 lbs | 8 gp | Melee |
| Longsword | 1d8 | 1d12 | 6 lbs | 15 gp | Melee |
| Two-Handed Sword | 1d10 | 3d6 | 15 lbs | 30 gp | Melee |
| Battle Axe | 1d8 | 1d8 | 7 lbs | 5 gp | Melee |
| Mace | 1d6+1 | 1d6 | 5 lbs | 8 gp | Melee |
| Morning Star | 2d4 | 1d6+1 | 12 lbs | 5 gp | Melee |
| Staff | 1d6 | 1d6 | 4 lbs | Free | Melee |
| Short Bow | 1d6 | 1d6 | 2 lbs | 15 gp | Ranged (2/round) |
| Longbow | 1d6 | 1d6 | 3 lbs | 60 gp | Ranged (2/round) |
| Light Crossbow | 1d4+1 | 1d4+1 | 5 lbs | 12 gp | Ranged (1/round) |
| Heavy Crossbow | 1d6+1 | 1d6+1 | 8 lbs | 20 gp | Ranged (1/2 round) |
| Sling | 1d4+1 | 1d6+1 | 0.5 lb | 5 sp | Ranged (1/round) |

Missile range: -2 penalty per range increment beyond the first, max 5 increments.

### Death & Healing

- **0 HP**: Unconscious, bleeding at -1 HP per round
- **-10 HP**: Dead
- **Natural healing**: 1 HP per full day of rest
- **Inn rest**: Full HP restored (5 gp/night)
- **Cure Light Wounds** (Cleric 1): 1d8 HP, touch, 5 segments casting time
- **Healing Potion**: 2d4+2 HP
- **Resurrection**: Chapel (1,000 gp), requires system shock roll (CON-based %)

### Surprise

Each side rolls 1d6 on encounter. 1–2 = surprised for that many segments. Surprised
side cannot act. Rangers surprise opponents 50% of the time (3-in-6). Halflings are
lightfooted and reduce their surprise chance by 1.

### Morale

Monsters check morale (d100 <= base 50% + 5%/HD) when:
- First blood is drawn
- An ally is killed
- Half their forces are lost
- Their leader falls

Failed morale = monsters flee or surrender.

---

## 4. Saving Throws

Five categories per OSRIC:

| Category | Situations |
|----------|-----------|
| **Aimed Magic** | Rods, staves, wands |
| **Breath Weapon** | Dragon breath, area attacks |
| **Death/Paralysis/Poison** | Instant-death effects, venom, paralysis |
| **Petrification/Polymorph** | Gaze attacks, shape-changing |
| **Spells** | All other magical effects |

Roll d20 >= target number = success. Natural 1 always fails.

**Fighter Saving Throws:**

| Level | Aimed | Breath | Death | Petrify | Spells |
|-------|-------|--------|-------|---------|--------|
| 1–2 | 14 | 15 | 12 | 13 | 16 |
| 3–4 | 13 | 14 | 11 | 12 | 15 |
| 5–6 | 11 | 11 | 9 | 10 | 13 |
| 7–8 | 10 | 10 | 8 | 9 | 12 |
| 9–10 | 8 | 8 | 6 | 7 | 10 |

**Cleric Saving Throws:**

| Level | Aimed | Breath | Death | Petrify | Spells |
|-------|-------|--------|-------|---------|--------|
| 1–3 | 11 | 16 | 10 | 13 | 15 |
| 4–6 | 9 | 14 | 8 | 11 | 13 |
| 7–9 | 7 | 12 | 6 | 9 | 11 |

**Thief Saving Throws:**

| Level | Aimed | Breath | Death | Petrify | Spells |
|-------|-------|--------|-------|---------|--------|
| 1–4 | 14 | 16 | 13 | 12 | 15 |
| 5–8 | 12 | 15 | 12 | 11 | 13 |
| 9–12 | 10 | 14 | 11 | 10 | 11 |

**Magic-User Saving Throws:**

| Level | Aimed | Breath | Death | Petrify | Spells |
|-------|-------|--------|-------|---------|--------|
| 1–5 | 11 | 15 | 14 | 13 | 12 |
| 6–10 | 9 | 13 | 13 | 11 | 10 |

Modifiers: WIS bonus applies to mental saves. DEX bonus applies to breath/area saves.
Racial save bonuses (Dwarf, Gnome, Halfling "Stalwart") based on CON.

---

## 5. Random Encounters

### Wilderness Encounter Checks

Encounters are checked **per hex entered** (not by real-time). Roll 1d6 on each hex
crossing. On a 1, an encounter occurs. At night, encounters trigger on 1–2.

Encounter tables are keyed to terrain type:

**Plains / Grassland (1d8)**

| Roll | Encounter | HD | XP |
|------|-----------|----|----|
| 1 | 2d4 Bandits | 1 | 100 ea |
| 2 | 1d6 Wolves | 2+1 | 150 ea |
| 3 | Merchant caravan (friendly) | — | Trade opportunity |
| 4 | 1d4 Wild Horses | 2 | Can be tamed |
| 5 | Wandering Cleric (friendly) | 3 | Offers healing |
| 6 | 2d6 Goblins | 1-1 | 75 ea |
| 7 | 1 Ogre | 4+1 | 500 |
| 8 | Traveling Bard (friendly) | 2 | Shares rumors |

**Forest / Dense Forest (1d8)**

| Roll | Encounter | HD | XP |
|------|-----------|----|----|
| 1 | 1d6 Giant Spiders | 2+1 | 175 ea |
| 2 | 2d4 Orcs | 1 | 100 ea |
| 3 | 1 Owlbear | 5+2 | 600 |
| 4 | 1d4 Wolves | 2+1 | 150 ea |
| 5 | Wood Elf patrol (friendly) | 1+1 | Trade/info |
| 6 | 1d6 Skeletons | 1 | 100 ea |
| 7 | 1 Treant (neutral) | 8 | Speaks if CHA check |
| 8 | Hermit (friendly) | 2 | Quest hook |

**Hills / Mountain (1d8)**

| Roll | Encounter | HD | XP |
|------|-----------|----|----|
| 1 | 1d4 Mountain Lions | 3+1 | 250 ea |
| 2 | 2d4 Kobolds | 1/2 | 50 ea |
| 3 | 1 Hill Giant | 8+2 | 1200 |
| 4 | 1d6 Hobgoblins | 1+1 | 120 ea |
| 5 | Dwarven miners (friendly) | 1 | Trade ore |
| 6 | 1d4 Harpies | 3 | 300 ea |
| 7 | 1 Griffon | 7 | 900 |
| 8 | Rockslide (DEX save or 2d6 damage) | — | — |

**Desert (1d6)**

| Roll | Encounter | HD | XP |
|------|-----------|----|----|
| 1 | 1d4 Giant Scorpions | 4 | 400 ea |
| 2 | 2d6 Nomads | 1 | 100 ea |
| 3 | 1 Sphinx (riddle) | 6 | Solve for 800 XP |
| 4 | Sandstorm (CON save or fatigue) | — | — |
| 5 | Oasis (rest point, possible mirage) | — | — |
| 6 | 1d4 Giant Lizards | 3+1 | 250 ea |

**Marsh (1d6)**

| Roll | Encounter | HD | XP |
|------|-----------|----|----|
| 1 | 2d4 Lizardfolk | 2+1 | 175 ea |
| 2 | 1 Black Dragon (young) | 6+1 | 1000 |
| 3 | 1d6 Giant Leeches | 2 | 125 ea |
| 4 | Will-o'-Wisp | 9 | 1500 (hard to hit) |
| 5 | Swamp Witch (neutral) | 5 | Sells potions |
| 6 | 1d8 Zombies | 2 | 150 ea |

**Tundra (1d6)**

| Roll | Encounter | HD | XP |
|------|-----------|----|----|
| 1 | 1d4 Winter Wolves | 6 | 700 ea |
| 2 | 1 Frost Giant | 10+1 | 2000 |
| 3 | 2d4 Ice Goblins | 1 | 100 ea |
| 4 | Blizzard (CON save, lose movement) | — | — |
| 5 | Frozen traveler (lootable) | — | 1d6×10 GP |
| 6 | 1 Yeti | 4+4 | 550 |

**Road (1d6)**

| Roll | Encounter | HD | XP |
|------|-----------|----|----|
| 1 | Merchant (trade) | — | Shop |
| 2 | 2d4 Bandits | 1 | 100 ea |
| 3 | Patrol guards (friendly) | 2 | Info |
| 4 | Pilgrim (quest) | 1 | Quest hook |
| 5 | Broken wagon (loot/trap) | — | Variable |
| 6 | Nothing | — | — |

**Beach (1d6)**

| Roll | Encounter | HD | XP |
|------|-----------|----|----|
| 1 | 1d6 Sahuagin | 2+1 | 175 ea |
| 2 | Giant Crab | 3 | 250 |
| 3 | Shipwreck debris (loot) | — | 2d6×10 GP |
| 4 | Sea Hag | 3 | 300 |
| 5 | Fisherman (friendly) | 1 | Rumors |
| 6 | 1d4 Merfolk (neutral) | 1+1 | Trade |

### Encounter Flow

```
1. Player enters new hex → encounter check (1d6, encounter on 1; night: 1–2)
2. Encounter triggered → determine distance (2d6 × 10 yards)
3. Surprise: each side rolls 1d6, surprised on 1–2 (lose that many segments)
4. If friendly/neutral: NPC reaction roll (2d6 + CHA mod)
   - 2–5: Hostile    6–8: Uncertain    9–12: Friendly
5. If hostile: switch to tactical combat grid
6. Combat rounds until one side is defeated, flees, or surrenders
7. Loot: gold + possible item drops
8. Award XP (HD × 100, adjusted for special abilities)
```

---

## 6. Experience & Leveling

### XP Sources

| Source | XP |
|--------|-----|
| Monster defeated | HD × 100 (adjusted by special abilities) |
| Gold acquired | 1 XP per 1 GP (OSRIC/1e rule) |
| Quest completion | Variable (100–1000) |

### Level Thresholds (OSRIC)

| Level | Fighter | Cleric | Thief | Magic-User | Title |
|-------|---------|--------|-------|------------|-------|
| 1 | 0 | 0 | 0 | 0 | Veteran / Acolyte / Apprentice / Prestidigitator |
| 2 | 2,000 | 1,500 | 1,250 | 2,500 | Warrior / Adept / Footpad / Evoker |
| 3 | 4,000 | 3,000 | 2,500 | 5,000 | Swordsman / Priest / Robber / Conjurer |
| 4 | 8,000 | 6,000 | 5,000 | 10,000 | Hero / Curate / Burglar / Theurgist |
| 5 | 16,000 | 12,000 | 10,000 | 20,000 | Swashbuckler / Prefect / Sharper / Thaumaturgist |
| 6 | 32,000 | 25,000 | 20,000 | 40,000 | Myrmidon / Canon / Pilferer / Magician |
| 7 | 64,000 | 50,000 | 40,000 | 60,000 | Champion / Lama / Master Pilferer / Enchanter |
| 8 | 125,000 | 100,000 | 60,000 | 90,000 | Superhero / Matriarch / Thief / Warlock |
| 9 | 250,000 | 200,000 | 90,000 | 135,000 | Lord / Patriarch / Master Thief / Sorcerer |

On level-up:
- Roll new hit die + CON modifier, add to max HP (fighters get full CON bonus)
- Fighters: +1 BTHB, extra attacks at 7 and 13
- Magic-Users: learn 1 new spell, new spell level access
- Clerics: gain access to next spell tier, bonus slots from WIS
- Thieves: improve all skill percentages

---

## 7. Inventory & Equipment

### Encumbrance (OSRIC)

Base carrying capacity determined by STR. Movement penalty when overloaded:

| Excess Over Allowance | Movement Penalty |
|-----------------------|-----------------|
| 0 | Full speed |
| 1–40 lbs | 3/4 speed |
| 41–80 lbs | 1/2 speed |
| 81–120 lbs | 1/4 speed |
| 121+ lbs | Cannot move |

Armor imposes movement caps: Plate 60 ft, Chain/Banded/Scale 90 ft, Leather/Studded 120 ft.
Encumbrance penalties stack with terrain speed multipliers and armor movement caps
(use the lowest).

### Consumables

| Item | Effect | Cost | Weight |
|------|--------|------|--------|
| Healing Potion | 2d4+2 HP | 50 gp | 0.5 lb |
| Antidote | Cure poison | 25 gp | 0.5 lb |
| Rations (1 day) | Prevent starvation | 1 gp | 1 lb |
| Torch | 40 ft light, 6 turns | 1 cp | 1 lb |
| Lantern (bullseye) | 80 ft beam, 24 turns | 12 gp | 2 lbs |
| Oil flask (1 pint) | Fuel lantern or 2d6 fire | 1 gp | 1 lb |
| Rope (50 ft) | Climbing, binding | 1 gp | 5 lbs |
| 10 ft pole | Trap detection | 2 sp | 8 lbs |
| Holy water | 2d4 vs undead (thrown) | 25 gp | 0.5 lb |
| Thieves' tools | Required for lock/trap skills | 30 gp | 1 lb |
| Arrows (20) | Bow ammunition | 5 gp | 1 lb |
| Bolts (20) | Crossbow ammunition | 5 gp | 1 lb |

### Rations & Starvation

The player must consume 1 ration per day. Going without food:
- Day 1–2: No effect
- Day 3: -1 to all rolls
- Day 4: -2 to all rolls, half movement
- Day 5+: 1d4 damage per day, -4 to all rolls

Rations can be purchased at town Markets. Hunting (ranger skill or WIS check in
forest/plains) can supplement food supply.

---

## 8. Town Interactions

### Inn
- Rest: restore full HP (5 gp/night)
- Hear rumors: random quest hooks
- Save game: persist character state to localStorage
- Memorize spells: Magic-Users and Clerics prepare daily spell loadout

### Market
- Buy/sell equipment and consumables
- Prices fluctuate by town (seeded by town name hash)
- Sell loot from encounters at 50% value

### Smithy
- Buy weapons and armor
- Upgrade weapons (+1 enchantment for 500 gp, requires level 3+)

### Chapel
- Cleric healing (free Cure Light Wounds once per visit)
- Remove curse (100 gp)
- Resurrection (1,000 gp, system shock roll required)

### Town Hall
- View active quests
- Bounty board: kill X monsters in Y terrain for gold reward
- Town reputation tracker

### Town NPCs
- NPCs are procedurally generated with names, roles, and dialog
- NPC reaction based on CHA modifier (2d6 + CHA mod)
- Active NPCs wander near their buildings; idle NPCs show available quests

---

## 9. Spells (Magic-User & Cleric)

### Vancian Spellcasting

Spells must be memorized from a spellbook (Magic-User) or prayed for (Cleric) during
rest at an Inn. Memorized spells are consumed when cast. Re-memorization requires
another rest.

Casting in combat takes a full round. Any damage to the caster before the spell
completes causes the spell to be lost. No DEX AC bonus while casting. Cannot move
while casting.

### Magic-User Spells (memorize per day)

**Slots per level:**

| Caster Level | 1st | 2nd | 3rd |
|-------------|-----|-----|-----|
| 1 | 1 | — | — |
| 2 | 2 | — | — |
| 3 | 2 | 1 | — |
| 4 | 3 | 2 | — |
| 5 | 3 | 2 | 1 |

**1st Level:**
- **Magic Missile**: Auto-hit, 1d4+1 damage. +1 missile at levels 3 and 5.
- **Sleep**: 2d8 HD of creatures fall asleep (no save for ≤4 HD).
- **Shield**: +4 AC for the encounter.

**2nd Level:**
- **Web**: Immobilize enemies for 1d4 rounds (save negates).
- **Mirror Image**: 1d4 illusory duplicates absorb attacks.
- **Invisibility**: Invisible until attacking. Guaranteed surprise round.

**3rd Level:**
- **Fireball**: 6d6 damage in area (save for half).
- **Lightning Bolt**: 6d6 damage in line (save for half).
- **Haste**: Double attacks for 3 rounds.

### Cleric Spells

**Slots per level (+ WIS bonus slots):**

| Caster Level | 1st | 2nd | 3rd |
|-------------|-----|-----|-----|
| 1 | 1 | — | — |
| 2 | 2 | — | — |
| 3 | 2 | 1 | — |
| 4 | 3 | 2 | — |
| 5 | 3 | 2 | 1 |

WIS 13 = +1 first-level slot. WIS 14 = +2 first-level. WIS 15 = +1 second-level.
WIS 16 = +2 second-level. WIS 17 = +1 third-level. WIS 18 = +1 fourth-level.

**1st Level:**
- **Cure Light Wounds**: Touch, 1d8 HP, 5 segments casting time.
- **Bless**: +1 attack and saves for the encounter.
- **Command**: One-word command for 1 round (save for INT 13+ or 6+ HD).
- **Detect Evil**: 120 ft path, concentration, 1 turn + 5 rounds/level.
- **Light**: 20 ft radius, 6 turns + 1/level.
- **Protection from Evil**: Touch, 3 rounds/level, -2 to evil attacks/+2 saves.

**2nd Level:**
- **Hold Person**: Paralyze 1 humanoid for 1d4 rounds (save negates).
- **Silence**: No spellcasting in area for 1d6 rounds.
- **Spiritual Weapon**: 1d6+1 damage, attacks on its own.

**3rd Level:**
- **Cure Serious Wounds**: Heal 2d8+3 HP.
- **Dispel Magic**: Remove one magical effect.
- **Prayer**: +1 to all rolls for the party, -1 for enemies.

---

## 10. Quest System

### Quest Types

1. **Kill quests**: Defeat N creatures of type X (posted at Town Hall)
2. **Fetch quests**: Retrieve item from specific terrain hex
3. **Escort quests**: NPC follows player to another town (road encounters)
4. **Exploration**: Visit N new terrain types for cartographer reward

### Quest Rewards

| Difficulty | Gold | XP | Possible Item |
|-----------|------|----|---------------|
| Easy | 50–100 | 200 | Healing potion |
| Medium | 100–300 | 500 | +1 weapon |
| Hard | 300–1000 | 1000 | Rare armor/spell scroll |

---

## 11. Strongholds & Domain Management

At "name level" (level 9+), characters unlock the ability to build strongholds, attract
followers, administer wilderness hexes, and generate income from population. The player
must first clear surrounding hexes (2-hex radius = ~12 hexes, 72 square miles) of all
hostile encounters.

### Name Level by Class

| Class | Name Level | Title | Stronghold Type | Followers |
|-------|-----------|-------|-----------------|-----------|
| **Fighter** | 9 (Lord) | Baron/Baroness | Castle & keep | Captain + 4d20 mercenaries |
| **Cleric** | 9 (Patriarch) | High Priest | Fortified temple | 3d6+2 acolytes/guards |
| **Magic-User** | 11 (Wizard) | Tower Master | Wizard's tower | 1d4 apprentices |
| **Thief** | 10 (Master Thief) | Guildmaster | Hidden guild hall | 6d4 NPC thieves |

### Stronghold Construction

| Structure | Cost (gp) | Build Time | Notes |
|-----------|----------|------------|-------|
| Wooden Palisade (per hex side) | 500 | 1 week | Basic defense |
| Stone Wall (10' section) | 5,000 | 2 weeks | Standard fortification |
| Tower (round, 30' high) | 15,000 | 6 weeks | Garrison 10 soldiers |
| Keep (small) | 25,000 | 12 weeks | Lord's residence, garrison 20 |
| Keep (large) | 75,000 | 24 weeks | Great hall, garrison 50 |
| Castle (full) | 150,000 | 52 weeks | Multiple towers, curtain walls |
| Moat (per hex side) | 5,000 | 4 weeks | +2 to defense rolls |
| Gatehouse | 10,000 | 6 weeks | Portcullis, murder holes |
| Drawbridge | 2,500 | 2 weeks | Requires moat |
| Dungeon Level (per floor) | 10,000 | 8 weeks | Prison, storage, or treasury |
| Chapel (within stronghold) | 8,000 | 4 weeks | Cleric required |
| Wizard's Laboratory | 20,000 | 8 weeks | Magic-User required |

### Domain Income

Population grows over time and generates tax revenue at 1 gp per 2 peasants per month
(adjusted by CHA modifier and realm events).

| Time After Construction | Population | Monthly Income |
|------------------------|-----------|---------------|
| 1 month | ~200 | 100 gp |
| 3 months | ~500 | 250 gp |
| 6 months | ~800 | 400 gp |
| 1 year | ~1,500 | 750 gp |
| 2 years | ~2,500 | 1,250 gp |
| Max (per hex) | ~5,000 | 2,500 gp |

### Stronghold Maintenance

| Expense | Monthly Cost |
|---------|-------------|
| Garrison (per soldier) | 3 gp |
| Garrison (per cavalry) | 10 gp |
| Garrison (per sergeant/lieutenant) | 25 gp |
| Stronghold upkeep | 1% of construction cost |
| Apprentice stipend (Magic-User) | 50 gp each |
| Temple offerings (Cleric) | 10% of income |
| Guild bribes (Thief) | 5% of income |

### Domain Events (Monthly Roll, 1d12)

| Roll | Event | Effect |
|------|-------|--------|
| 1 | Monster incursion | Must clear or lose 10% population |
| 2 | Plague | -20% population, 500 gp to treat |
| 3 | Bandit raids | Lose 1 month income unless garrison fights |
| 4 | Poor harvest | -50% income this month |
| 5 | Trade caravan arrives | +50% income this month |
| 6–8 | Peaceful month | Normal income |
| 9 | Festival | +10% population growth, costs 200 gp |
| 10 | New settlers | +1d6 × 5 families arrive |
| 11 | Merchant guild interest | Permanent +10% income (one-time) |
| 12 | Heroic reputation | +2d6 × 5 families, attract 1d4 additional followers |

### Stronghold Upgrades

| Upgrade | Cost | Prerequisite | Benefit |
|---------|------|-------------|---------|
| Market | 10,000 gp | 500+ population | +25% income |
| Inn | 5,000 gp | 200+ population | Attracts more settlers |
| Walls (stone upgrade) | 20,000 gp | Wooden palisade | +4 defense |
| Watchtower network | 8,000 gp | 3+ towers | Early warning of attacks |
| Smithy | 6,000 gp | 300+ population | Equip garrison locally |
| Granary | 4,000 gp | Any stronghold | Resist famine events |
| Library | 15,000 gp | Wizard's tower | +1 spell learned per level |
| Shrine → Temple upgrade | 12,000 gp | Chapel | Cleric gains bonus spells |

### Mass Combat (Simplified)

1. Each side totals **Battle Strength**: sum of all HD on each side
2. Roll 1d6 + (Battle Strength difference / 10) for each side
3. Higher roll wins the engagement
4. Losing side takes casualties: (winner's roll - loser's roll) × 10% of forces
5. Leader's level adds +1 per 3 levels to their side's roll
6. Fortification bonus: +2 for palisade, +4 for stone walls, +6 for full castle
7. Moat: additional +2 when defending

---

## 12. Controls & UI

### Key Bindings

| Key | World Map | Town | Combat | Dialog |
|-----|-----------|------|--------|--------|
| **WASD / Arrows** | Move player | Move player | — | — |
| **E** | Enter town | Talk to NPC | — | — |
| **I** | Inventory | Inventory | Inventory | — |
| **C** | Character sheet | Character sheet | Character sheet | — |
| **M** | Toggle map overlay | — | — | — |
| **Escape** | — | Exit town | — | Close dialog |
| **Enter** | — | — | — | Send message |
| **1–9** | — | — | Select action | — |
| **Scroll** | Zoom in/out | Zoom in/out | — | Scroll history |
| **+/-** | Zoom in/out | Zoom in/out | — | — |

### HUD Elements

- **Top-left**: Level, class, HP/maxHP, XP bar
- **Top-right**: Minimap (world view with fog of war, player dot, town markers)
- **Bottom-left**: Terrain name, movement speed, time of day, rations remaining
- **Bottom-right**: Active quest indicator
- **Center**: Dialog panel, combat overlay, inventory panel (when active)

---

## 13. Implementation Phases

### Phase 1: Character Sheet & Stats
- Character creation overlay (roll stats, pick class/ancestry)
- Persistent HUD showing HP, level, class, gold
- localStorage save/load for character state
- Estimated scope: ~300 lines of JS

### Phase 2: Multi-Tier Zoom System
- Tier transition logic (zoom thresholds, state management)
- Regional tier: procedural generation from world hex (6×6 child grid)
- Local tier: procedural generation from regional hex (26×26 child grid)
- Town tier: refactored to 20-ft hexes (50×50 child grid)
- LRU tile cache for generated sub-grids
- Hex-crossing detection per tier with tier-appropriate time/encounter scaling
- Day/night cycle visual effects
- Fog of war on world map
- Ration consumption and starvation
- Getting lost mechanic (off-road travel)
- Estimated scope: ~800 lines of JS

### Phase 3: Inventory & Economy
- Inventory panel (toggle with `I` key)
- Equipment slots (weapon, armor, shield)
- Town shop interactions (buy/sell at Market, Smithy)
- Encumbrance affecting movement speed and armor caps
- Estimated scope: ~300 lines of JS

### Phase 4: Combat & Encounters
- Hex-crossing encounter trigger system
- Tactical combat grid (20×15, 5 ft squares)
- Turn-based combat (declare → initiative → resolve)
- d20 + BTHB attack resolution, dual damage values
- Surprise, morale, fleeing
- Encounter tables per terrain type
- Monster stats and AI (attack nearest, morale checks)
- Estimated scope: ~600 lines of JS

### Phase 5: Spells & Abilities
- Vancian spell memorization (prepare at Inn)
- Spell effects in combat (casting time, interruption)
- Thief backstab and skill checks
- Cleric turn undead
- Ranger tracking and reduced lost chance
- Estimated scope: ~400 lines of JS

### Phase 6: Quests & Progression
- Quest board in Town Hall
- Quest tracking HUD
- XP awards and level-up system
- NPC reaction rolls tied to CHA
- Estimated scope: ~250 lines of JS

### Phase 7: Strongholds & Domains
- Stronghold construction overlay (select structures, pay gold, wait for build time)
- Hex clearing requirement (2-hex radius)
- Follower recruitment (automatic on stronghold completion)
- Domain income system (monthly tick based on population)
- Domain events (monthly random roll)
- Stronghold upgrades and maintenance costs
- Simplified mass combat for garrison defense
- Player's stronghold rendered on world map as a new town hex
- Estimated scope: ~500 lines of JS

### Phase 8: Polish
- Sound effects (dice rolls, combat hits, spell effects)
- Death screen with option to reload
- Character portrait on HUD
- Minimap fog of war rendering
- Session save/load improvements
- Estimated scope: ~200 lines of JS

---

## Technical Notes

- All game state stored in a single `gameState` object, serialized to `localStorage`
- Dice rolling: `function roll(n, d) { ... }` utility returning sum and individual results
- Combat runs as a state machine within the existing `gameLoop`, pausing world movement
- No external dependencies — everything stays in the single HTML file
- Monster/item/spell data defined as const lookup tables at the top of the script
- Encounter overlay reuses the existing dialog panel layout pattern
- Hex-crossing detection: track player position relative to hex grid, fire events on boundary crossing
- Multi-tier rendering: each tier has its own offscreen canvas, generated on demand
- Tile cache: LRU cache keyed by `tier:col:row`, max ~50 entries, evicts on memory pressure
- Tier transitions: zoom thresholds trigger generation of child grid from parent hex
- Parent-child coordinate mapping: `childCol = floor((playerX - parentHexLeft) / childHexW)`
- Tactical combat grid rendered on a separate canvas layer, overlaid on the hex map
- Game time tracked as a float (days elapsed), converted to hours for display
