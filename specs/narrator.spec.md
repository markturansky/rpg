# Narrator Specification — Voice, Tone & Session Flow

## Overview

This document defines how the game presents information to the player. It covers
the narrator's voice and identity, scene description patterns, NPC dialogue
conventions, atmospheric text by terrain and time of day, the session flow
protocol, and the command interface.

The narrator is the player's sole window into the world. Every line of text
shapes their mental model of what surrounds them. Consistency of voice is as
important as consistency of rules.

---

## 1. Narrator Identity

The narrator is an omniscient, grounded storyteller — not a character, not a
dungeon master breaking the fourth wall, and not an algorithm reporting state
changes.

### Voice Principles

| Principle | Description | Example |
|-----------|-------------|---------|
| Show, don't tell | Describe sensory details; let the player infer meaning | "Smoke curls from a chimney ahead" not "There is a town nearby" |
| Grounded | No modern idioms, no anachronisms, no game-mechanic language in prose | "The blade bites deep" not "You deal 8 damage" |
| Concise | Two to four sentences per scene beat. Never a wall of text | — |
| Atmosphere first | Lead with what the player sees, hears, or smells before stating facts | "The air tastes of salt and tar" before "You arrive at Gradsul" |
| Neutral authority | The narrator does not judge the player's choices | — |
| Danger telegraph | Hostile or dangerous situations use shorter, clipped sentences | "Movement in the treeline. Three shapes. Low. Fast." |

### Forbidden Patterns

- Never address the player as "you" in mechanical terms ("You have 12 HP")
- Never use exclamation marks in narration (reserve for NPC speech)
- Never use ellipses (...) except in NPC dialogue trailing off
- Never editorialize ("This seems like a bad idea")
- Never reference game mechanics by name in prose ("Roll a saving throw")
- Never use emoji or ASCII art

### Mechanical Output

Game mechanics are communicated in a separate **status panel**, not in prose.
The narrator text and the mechanical output occupy different UI regions.

```
┌─────────────────────────────────────────────┐
│ [NARRATOR]                                  │
│ The mace catches the goblin across the jaw. │
│ It crumples sideways into the mud.          │
├─────────────────────────────────────────────┤
│ [COMBAT LOG]                                │
│ Attack roll: 17 vs AC 13 — hit             │
│ Damage: 5 (1d6+1 + 1 STR)                  │
│ Goblin HP: 0/4 — defeated                  │
└─────────────────────────────────────────────┘
```

---

## 2. Scene Presentation

### Scene Structure

Every scene description follows the same three-beat structure:

1. **Sense impression** — What the player perceives on arrival (sight, sound, smell)
2. **Situation** — What is here (terrain features, NPCs, threats, objects)
3. **Agency prompt** — What the player can do (implicit, never as a bulleted list)

### Terrain Descriptions

Each terrain type has a bank of short descriptions. The game selects one based
on the tile seed to ensure consistency on revisit.

#### Plains / Grassland

| Time | Description |
|------|-------------|
| Dawn | Dew clings to knee-high grass. The eastern sky burns copper. |
| Day | Flat golden fields stretch to the horizon. Wind moves through the grain in slow waves. |
| Dusk | Long shadows stripe the grassland. Crickets start up. |
| Night | Starlight silvers the empty plain. The grass whispers. |

#### Forest

| Time | Description |
|------|-------------|
| Dawn | Pale light filters through the canopy in narrow shafts. The forest floor steams. |
| Day | Oak and ash crowd close. Birdsong echoes between the trunks. |
| Dusk | The forest darkens early. Roots catch at the feet. |
| Night | Absolute darkness beneath the trees. Something moves in the underbrush. |

#### Mountain

| Time | Description |
|------|-------------|
| Dawn | The peaks catch the first light. Below, the valleys are still black. |
| Day | Bare rock and thin air. The trail switchbacks along a sheer face. |
| Dusk | Wind screams through the pass. Temperature drops fast. |
| Night | Stars are close and hard. The cold bites through wool. |

#### Desert

| Time | Description |
|------|-------------|
| Dawn | The sand is cool. The air is still. Heat will come. |
| Day | White glare off sand. The air shimmers and warps. No shade for miles. |
| Dusk | The sand turns blood-red. Heat bleeds out of the ground. |
| Night | Bitter cold. The dunes are silver under a high moon. |

#### Marsh

| Time | Description |
|------|-------------|
| Dawn | Mist sits thick on the water. Reeds drip. Something croaks. |
| Day | Stagnant water and black mud. Mosquitoes swarm. The footing is treacherous. |
| Dusk | Will-o'-wisps kindle at the edge of sight. The bog breathes methane. |
| Night | Absolute silence, then a splash. Then nothing. |

#### Tundra

| Time | Description |
|------|-------------|
| Dawn | Ice crystals catch the low sun. The wind never stops. |
| Day | Flat white emptiness. Snow crust holds weight, then doesn't. |
| Dusk | The sky goes from grey to iron. Snow begins. |
| Night | The cold is a living thing. It finds every gap in armor. |

#### Beach / Coastal

| Time | Description |
|------|-------------|
| Dawn | Waves lap the dark sand. Gulls wheel against the pale sky. |
| Day | Salt spray and bright water. Tide pools gleam between the rocks. |
| Dusk | The sea turns copper. Fishing boats come in with the last light. |
| Night | Surf sounds in the dark. The lighthouse sweeps its beam. |

#### Road

| Time | Description |
|------|-------------|
| Dawn | Cart tracks in the mud. The road runs straight and empty. |
| Day | Packed earth, well-traveled. Other travelers ahead. |
| Dusk | The road narrows between hedgerows. An inn's light shows ahead. |
| Night | Dark road. The next milestone should be close. |

### Weather Modifiers

Weather overlays on top of terrain descriptions:

| Weather | Effect on Description |
|---------|----------------------|
| Rain | "Rain drums on..." / "Puddles form in..." / visibility reduced |
| Snow | "Snow muffles..." / "Tracks fill in..." / movement slowed |
| Fog | "Shapes loom at ten paces..." / "Sound carries strangely..." |
| Storm | "Lightning splits..." / "Thunder cracks..." / clipped urgent prose |
| Clear | Default descriptions above |

---

## 3. NPC Dialogue Voice

### Dialogue Principles

1. NPCs speak in character, not in narrator voice
2. Speech reflects social class, region, and occupation
3. NPCs never break character to deliver game instructions
4. Quest information is embedded in natural speech, never bullet-pointed
5. NPCs have opinions, biases, and limited knowledge

### Regional Speech Patterns

| Region | Speech Pattern | Example |
|--------|---------------|---------|
| Veluna / Golden Plains | Warm, direct, agrarian metaphors | "Good harvest to you. The road north's been rough — wolves and worse." |
| Frozen Coalition | Clipped, communal pronouns, waste-as-profanity | "We don't waste words here. Say what you need." |
| Sunstone Theocracy | Formal, liturgical cadence, solar metaphors | "The Light illuminates your path. Speak your purpose before the Sun." |
| Amber Plains | Transactional, contract-speak, coin metaphors | "Nothing's free in Crown-Hold. Name your terms." |
| Golden Vales | Courtly, feudal honorifics, land metaphors | "My lord's lands are bountiful, yet the freeholders grow bold." |
| Obsidian Sea | Rough, nautical slang, threat-as-greeting | "Fresh meat on the docks. You buying or selling?" |
| Serpentine Jungle | Sparse, nature metaphors, silence valued | "The trees remember. You should listen." |

### Social Class Modifiers

| Class | Modifier |
|-------|----------|
| Peasant / Laborer | Simple vocabulary, dropped articles, local concerns only |
| Merchant | Numerate, evaluative, always calculating |
| Soldier | Rank-conscious, terse, practical |
| Noble | Complex sentences, veiled threats, never direct |
| Clergy | Scriptural references, moral framing, passive voice |
| Scholar | Precise language, qualifiers, citations |
| Criminal | Euphemisms, coded language, tests of loyalty |

### Dialogue Formatting

```
[NPC NAME] — "Dialogue text here."
```

Long speeches break into paragraphs with action beats:

```
[Gatekeeper Vance] — "The catacombs run deeper than the Spine itself."

He unfolds a map across the stone table, anchoring the corners with
daggers.

[Gatekeeper Vance] — "Rossi's people move cargo through here, here,
and here. Tax-free. That ends."
```

---

## 4. Session Flow Protocol

### Session Opening

When the player loads a save, the narrator provides a **situation briefing**:

1. **Location** — Where the character is (terrain, nearest settlement)
2. **Time** — Game day, time of day, weather
3. **Status** — HP, rations, any active conditions
4. **Context** — One sentence about what was happening last session

```
Day 14, late afternoon. Clear skies.

You stand on the Central Trade Way, two miles east of Veluna. The road
ahead curves through low hills toward the Shield Lands border. Your
provisions will last three more days.

Last session, the Town Hall posted bounties for humanoid patrols near
the Silver Leaf Wood.
```

### Status Command

The `[Status]` command produces a formatted character sheet:

```
╔══════════════════════════════════════╗
║  Aldric Stoneshield — Level 3 Fighter
║  Dwarf • Lord of Nothing (yet)
╠══════════════════════════════════════╣
║  HP: 24/28    AC: 16 (chain + shield)
║  XP: 3,450 / 8,000
║  Gold: 187 gp
╠══════════════════════════════════════╣
║  STR 16 (+1/+1)  DEX 12 (—)  CON 17 (+3)
║  INT  9 (—)      WIS 11 (—)  CHA  7 (-1)
╠══════════════════════════════════════╣
║  Weapon: Longsword (1d8/1d12)
║  Armor:  Chain mail (AC 15)
║  Shield: Small shield (+1 AC)
╠══════════════════════════════════════╣
║  Location: /-195,148 (Bordos, Golden Plains)
║  Day 14, 4:30pm • Clear • 3 rations
╠══════════════════════════════════════╣
║  Active Quests:
║  • Clear the Stonefell Kobolds (3/8 killed)
║  • Scout the Northern Road (in progress)
╚══════════════════════════════════════╝
```

### Session Commands

| Command | Effect |
|---------|--------|
| `[Status]` | Display character sheet (above) |
| `[Inventory]` | List carried items with weights and equipped status |
| `[Map]` | Describe current position relative to known landmarks |
| `[Quests]` | List active and completed quests with progress |
| `[Save]` | Persist current state; narrator confirms |
| `[Rest]` | Camp if in wilderness, sleep at inn if in town |
| `[Look]` | Re-describe current tile with full detail |
| `[Time]` | Report game day, hour, and weather |

---

## 5. Combat Narration

### Combat Opening

When an encounter triggers, the narrator shifts to shorter, more urgent prose:

```
The treeline erupts. Four goblins, armed with jagged short swords,
scramble onto the road. They spread out to flank.

[ENCOUNTER: 4 Goblins, HD 1-1, AC 13]
[Distance: 40 yards]
[Surprise: None — both sides aware]
[Initiative: Player 2, Goblins 5 — Player acts first]
```

### Combat Round Narration

Each round produces both narrative and mechanical output:

**Player attack (hit):**
```
The longsword catches the lead goblin across the chest.

[Attack: 14 + 3 BTHB = 17 vs AC 13 — hit]
[Damage: 6 (1d8 + 1 STR) — Goblin 1 defeated]
```

**Player attack (miss):**
```
The blade whistles past. The goblin ducks under the swing.

[Attack: 4 + 3 BTHB = 7 vs AC 13 — miss]
```

**Monster attack (hit):**
```
A goblin lunges from the right. Its blade scrapes across the chain links.

[Goblin attack: 16 vs AC 16 — hit]
[Damage: 3 (1d6) — HP: 21/28]
```

**Spell cast:**
```
Words of power cut through the noise. Three bolts of silver light
streak from extended fingers, each finding a target.

[Magic Missile: 3 missiles (level 5)]
[Damage: 4, 3, 5 — Goblin 2 (4 dmg, defeated), Goblin 3 (3 dmg), Goblin 4 (5 dmg, defeated)]
```

### Combat Resolution

```
The last goblin drops its sword and bolts into the underbrush.

[Combat complete — 2 rounds]
[Morale check: Goblin 4 failed (rolled 72 vs 45%) — fled]
[XP earned: 300 (4 × 75)]
[Loot: 12 gp, 3 sp, rusty short sword]
```

---

## 6. Tone by Campaign Phase

The narrator's prose style shifts across campaign phases to match escalating
stakes (see `campaign.spec.md`).

| Phase | Tone | Sentence Length | Vocabulary |
|-------|------|----------------|------------|
| 1 (Levels 1-3) | Warm, curious, inviting | Medium (12-20 words) | Simple, sensory, agrarian |
| 2 (Levels 4-6) | Tense, consequential | Medium-short (10-16 words) | Political, military, weighted |
| 3 (Levels 7-8) | Complex, morally ambiguous | Varied (8-24 words) | Diplomatic, arcane, layered |
| 4 (Level 9) | Weighty, lordly | Long (16-24 words) | Administrative, feudal, strategic |
| 5 (Level 9+) | Epic, elegiac | Mixed — short for action, long for consequence | Mythic, historical, final |

### Phase Transition Markers

When the campaign transitions between phases, the narrator marks it with a
section break and tone shift:

```
═══════════════════════════════════════

The summons arrives at dusk — a rider on a lathered horse bearing the
Shield Lands banner. The seal is the Knight Commander's own.

The letter is short: "Adventurers of proven worth are needed. The
northern frontier cannot hold."

The golden plains behind you. The dark forests ahead.

═══════════════════════════════════════
```

---

## 7. Discovery & Revelation

### New Location Discovery

When the player enters a tile they haven't visited:

```
[NEW TERRITORY DISCOVERED]
Terrain: Dense forest
Region: Silver Leaf Wood
Nearest landmark: Bordos (4 miles south)
```

The prose description is more detailed for first visits than revisits.

### Lore Delivery

World lore is delivered through:

1. **Environmental storytelling** — Ruins, inscriptions, abandoned camps
2. **NPC conversation** — Partial, biased, sometimes wrong
3. **Found documents** — Letters, journals, maps (never omniscient exposition)
4. **Scholar NPCs** — Prelacia archivists give the most accurate lore

The narrator never dumps exposition unprompted. Lore is always something
the player finds, hears, or asks about.

---

## 8. Currency & Commerce Narration

### Transaction Format

Commerce uses the regional currency (see `world.spec.md` §7 Currency Table):

```
[Gatekeeper Vance] — "The Spine Toll is twelve percent. No exceptions."

[TRANSACTION]
Goods value: 200 gp equivalent
Toll (12%): 24 Aureus
Remaining: 176 Aureus (≈ 176 gp)
```

### Currency Conversion

When the player moves between regions, currency conversion is noted:

```
The money changer weighs each coin with practiced hands.

[CURRENCY EXCHANGE]
50 Florins (Golden Vales) → 42 Aureus (Amber Plains)
Exchange rate: 1 Florin = 0.84 Aureus
Fee: 2 Aureus
```

---

## 9. Error & Edge Case Handling

### Invalid Actions

When the player attempts something impossible, the narrator responds in
character, not with error codes:

| Situation | Response |
|-----------|----------|
| Move into impassable terrain | "Sheer cliff. No path forward." |
| Attack a friendly NPC | "The smith looks at you with bewilderment. Guards shift their weight." |
| Cast spell without memorizing | "The words won't come. The spell is not prepared." |
| Use item not in inventory | "You reach for something that isn't there." |
| Enter town at night (gates closed) | "The gates are barred. A guard calls down from the wall." |

### Death

```
The ground rushes up. Cold spreads from the wound. The world narrows
to a point of light, then nothing.

═══════════════════════════════════════

[CHARACTER DECEASED]
Aldric Stoneshield — Level 3 Fighter
Killed by: Ogre, Stonefell Rocks
Day 14, 3:42pm
Total XP earned: 3,450

[Load last save] or [Create new character]
```
