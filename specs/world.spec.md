# World Specification — The Realm of Aereth

## Overview

This document defines the world depicted in `map_tiles/map2.png`. The map covers a
single continent and its surrounding seas, rendered as a tile pyramid rooted
at `map2` with **100 depth-1 tiles** (10 columns x 10 rows). Each depth-1 tile
covers roughly **20 x 20 miles**. The landmass spans roughly **200 x 200 miles**
with significant ocean margins.

The world is caught in an intricate web of environmental extremes, transitioning
from the merciless glaciation of the Northern Ice Peaks down to the volcanic
volatility of the Cinder Archipelago and the sweltering canopies of the Serpentine
Jungle in the south. Between these continental bookends lie shifting political
entities, theological empires, and ancient duchies, each fighting for resources,
magical supremacy, and security.

Reference images: `map_tiles/map2/map2_2x_square.png` (full, 4740×4740).
Tile images are rendered dynamically by the server (see `specs/tile_rendering.spec.md`).

---

## Coordinate System

The world uses the tile pyramid addressing system established in
`game.spec.md`. The root tile `map2` subdivides into 100 depth-1 tiles
arranged in a 10×10 grid.

| Property | Value |
|----------|-------|
| Root tile | `map2` (depth 0) |
| Depth-1 tiles | 100 (10 cols × 10 rows) |
| Map width | ~200 miles |
| Map height | ~200 miles |
| Default spawn | `map2_35` (central plains, near Veluna) |
| World seed | 42 |

Coordinates in this document use **tile grid (col, row)** notation where
(0,0) is the top-left depth-1 tile. Tile `map2_XX` maps to
`col = XX % 10`, `row = XX / 10`.

### Tile Grid

The map is divided into 100 tiles (10 columns x 10 rows):

```
tile_00  tile_01  tile_02  tile_03  tile_04  tile_05  tile_06  tile_07  tile_08  tile_09   (row 0)
tile_10  tile_11  tile_12  tile_13  tile_14  tile_15  tile_16  tile_17  tile_18  tile_19   (row 1)
tile_20  tile_21  tile_22  tile_23  tile_24  tile_25  tile_26  tile_27  tile_28  tile_29   (row 2)
tile_30  tile_31  tile_32  tile_33  tile_34  tile_35  tile_36  tile_37  tile_38  tile_39   (row 3)
tile_40  tile_41  tile_42  tile_43  tile_44  tile_45  tile_46  tile_47  tile_48  tile_49   (row 4)
tile_50  tile_51  tile_52  tile_53  tile_54  tile_55  tile_56  tile_57  tile_58  tile_59   (row 5)
tile_60  tile_61  tile_62  tile_63  tile_64  tile_65  tile_66  tile_67  tile_68  tile_69   (row 6)
tile_70  tile_71  tile_72  tile_73  tile_74  tile_75  tile_76  tile_77  tile_78  tile_79   (row 7)
tile_80  tile_81  tile_82  tile_83  tile_84  tile_85  tile_86  tile_87  tile_88  tile_89   (row 8)
tile_90  tile_91  tile_92  tile_93  tile_94  tile_95  tile_96  tile_97  tile_98  tile_99   (row 9)
```

### Legacy Tile References

The kingdom and geographic feature entries below reference tiles using the
previous 4×3 grid naming (tile_00 through tile_11). These map to approximate
regions in the new 10×10 grid:

| Old Tile | Old Grid (4×3) | New Grid Region (10×10) |
|----------|---------------|------------------------|
| tile_00 | col=0, row=0 (NW) | cols 0-2, rows 0-2 |
| tile_01 | col=1, row=0 (N-center-left) | cols 2-4, rows 0-2 |
| tile_02 | col=2, row=0 (N-center-right) | cols 5-7, rows 0-2 |
| tile_03 | col=3, row=0 (NE) | cols 7-9, rows 0-2 |
| tile_04 | col=0, row=1 (W) | cols 0-2, rows 3-6 |
| tile_05 | col=1, row=1 (center-west) | cols 2-4, rows 3-6 |
| tile_06 | col=2, row=1 (center-east) | cols 5-7, rows 3-6 |
| tile_07 | col=3, row=1 (E) | cols 7-9, rows 3-6 |
| tile_08 | col=0, row=2 (SW) | cols 0-2, rows 7-9 |
| tile_09 | col=1, row=2 (S-center-left) | cols 2-4, rows 7-9 |
| tile_10 | col=2, row=2 (S-center-right) | cols 5-7, rows 7-9 |
| tile_11 | col=3, row=2 (SE) | cols 7-9, rows 7-9 |

The `Map region` col/row ranges in each entry below use the old 38×30
coordinate system and will be re-derived from the source map when the
10×10 grid is implemented.

### Map Legend

| Symbol | Meaning |
|--------|---------|
| Town icon (building) | Towns |
| Fort icon | Forts |
| Community icon | Communities |
| Scorched fest icon | Scorched/volcanic features |
| Dashed line | Trails |
| Fort line | Fortifications |
| Crossing icon | River crossings |
| Volcanic island icon | Volcanic island chain |

---

## 1. Kingdoms, Realms, and Territories

### The Theocracy of Sunstone (The Great Kingdom)

| Property | Value |
|----------|-------|
| Tile(s) | tile_07, tile_06, tile_11 |
| Map region | Eastern landmass, cols 22-37, rows 6-26 |
| Terrain | Mixed grassland, forest, hills, river valleys |
| Capital | Hinwanit (Solis-Prime) |
| Population | ~5,200,000 across a highly urbanized, regimented hierarchy |
| Power standing | Hegemon / Magically advanced global superpower |
| Disposition | Expansionist, theocratic, fanatical |
| Notable features | Unmatched treasury; extreme magical technology; fanatical expansionism |

The dominant power on the continent, known formally as the Theocracy of Sunstone.
Its western border runs along the Verdant Heart forest and the central waterways.
The Great Kingdom claims sovereignty over the North Province, South Province, and
the coastline facing the Azure Depths Ocean.

The Theocracy rose two centuries ago following the Sun-Shatter Schism, a bloody
religious war that overthrew the corrupt secular kings of the east. Guided by
holy prophecies, the empire believes it has an absolute divine mandate to bring
the entire continent under the light of the Sun. They utilize high-capacity
Solar-shards to store sunlight, powering everything from street lamps to
destructive military weaponry.

**Religion:** The Solar Ascendancy — fanatical worship of the absolute Sun God,
who they believe demands the ultimate conversion or destruction of all heretical
nations. Citizens are categorized at birth based on spiritual aptitude.
Compliance is absolute; dissent is viewed as spiritual corruption punishable by
public purification.

**Internal rift:** A boiling political tension exists between the fanatical Solar
Archon and the Grand Admiral of Khazar. The Sultanate values profit and free
trade, growing increasingly hostile toward the Inquisition's continuous
interference in their naval shipping and merchant networks.

**Military:**
- **Dawn Legion** (~80,000) — Highly fanatical legionnaires
- **Grand Fleet of Khazar** (~120 warships)
- **Solar Invokers** — Battle-mages channeling blinding light through focusing
  crystals to incinerate entire enemy phalanxes
- **Prismatic Sentinels** — Giant automated stone constructs powered by internal
  solar reactors
- Mobile mirror arrays concentrate sunlight to melt stone fortress gates from
  miles away. Solar-charged energy crystals synthesize nutrients, eliminating
  the need for conventional food supply trains in clear weather.

**Economy:**
- Currency: The Sol (rectangular gold bar inlaid with luminescent sun crystal)
- Exports: Solar-shard technology, refined luxury silks, exotic spices,
  high-purity arcane components
- Imports: Raw blood-gems, high-grade iron ore, foreign labor
- Naval monopoly: Through Khazar, the empire controls and taxes all maritime
  luxury trade through the strategic Opal Straits

**Quest hooks:**
- **The Eclipse Coup** — Arcane scholars have calculated that a total solar
  eclipse is approaching, which will temporarily drain the empire's Prism Towers
  and automated defenses. A network of secular rebels wants to assassinate the
  Solar Archon during the hours of total darkness.
- **The Slave Uprising** — Thousands of captured jungle hunters are staging a
  mass breakout from labor camps outside Solis-Prime. If they sabotage the
  primary Prism Tower during escape, the capital's magical infrastructure will
  collapse.

**Visible settlements:** Hinwanit, Floves, Aley, Revnle, Port of Sailing

### Hold of the Sea Princes (Obsidian Sea & Volcanic Front)

| Property | Value |
|----------|-------|
| Tile(s) | tile_08, tile_09, tile_10 |
| Map region | Southwestern coast and volcanic islands, cols 6-24, rows 20-30 |
| Terrain | Beach, grassland, coastal hills, volcanic basalt |
| Capital | Gradsul (pop. 160,000) |
| Population | ~1,100,000 across pirate captains, blacksmiths, outlaws, and marine merchants |
| Power standing | Strategic Neutral / Tactical Kingmaker |
| Disposition | Maritime, mercantile, lawless |
| Notable features | Controls southwestern sea lanes; naval power; absolute monopoly on combat metallurgy |

A confederation of pirate lords turned merchant princes, politically fragmented
and lawless but completely secure due to their global monopoly on combat
metallurgy. They control the warm southwestern coastline, the sea lanes between
the continent and the Silver Reef Isles, and the volcanic forges of the Cinder
Archipelago.

The Volcanic Front was populated over generations by outlaws, political refugees,
escaped slaves, and radical alchemists who fled the tyrannical laws of the
northern and eastern empires. Bound together by the Basalt Accord, they maintain
independence by weaponizing their boiling, treacherous waters and ensuring no
single nation can match the quality of their combat steel.

Status is measured purely by the strength of one's arm and the quality of one's
forge craft. There are no hereditary laws, religious taxes, or imperial codes.

**Major settlements:**
- **Gradsul** (pop. 160,000) — A dark-sand harbor permanently blanketed by
  light volcanic ash. A den of taverns, shipyards, and gambling halls; the
  premier recruitment hub for privateers, mercenaries, and smugglers.
- **Lavabury** (pop. 240,000) — A lawless, multi-tiered city built on cooled
  basalt shelves inside the caldera of an active volcanic island. Massive
  open-air smithies use channels of raw flowing magma to smelt unique combat
  metals. Governed by the Basalt Council.
- **Citesi** (pop. 95,000) — A rough port built into a network of jagged sea
  caves, the primary launching pad for raids against Sunstone treasure galleons.
- **Monmurg**, **Penensraft** — Secondary ports along the coastal run.

**Religion:** Largely secular; many revere the Forge-Father, a minor deity of
smithing and physical endurance.

**The Obsidian Counter-Measure:** High-temperature, magma-infused obsidian
weapons are the only objects capable of shattering the hard-light solar shields
deployed by the Dawn Legion, making the Volcanic Front highly dangerous to the
eastern superpower.

**Military:**
- **Privateer Fleet** (~90 heavily armed warships, ironclads, and raiders)
- **Lavabury Magma-Forgers** — Heavy shock infantry in heat-proof obsidian
  full-plate armor wielding massive volcanic warhammers
- **Kraken-Sea Boarders** — Reckless marine skirmishers with alchemical grapple
  guns and explosive black powder charges
- Ironclads equipped with heavy cannons firing volcanic ash canisters that blind
  enemy crews and set rigging on fire

**Economy:**
- Currency: The Doubloon (melted down, resized, and restamped foreign coinage)
- Exports: Magma-infused steel, combat obsidian, refined brimstone, black powder
- Imports: Fresh drinking water, luxury alcohol, grains, construction timber
- Monopoly: Exclusive geographic and technological monopoly on heat-forged
  metals forces continental superpowers to trade vital agricultural goods
  despite active piracy against those same nations

**Quest hooks:**
- **The Gatekeeper's Vendetta** — Grand Gatekeeper Vance of Crown-Hold has hired
  elite bounty hunters to capture or assassinate his rogue pirate daughter,
  Captain Valeria Vance, currently docked at Gradsul.
- **The Xanatos Awakening** — Severe tectonic activity has caused a massive
  section of the sunken Ruins of Xanatos to rise above sea level. Every nation
  is rushing naval forces to claim the ancient cataclysmic weapons hidden within.

### Kingdom of Verna

| Property | Value |
|----------|-------|
| Tile(s) | tile_05 |
| Map region | Central territory, cols 12-20, rows 10-16 |
| Terrain | Plains, grassland, light forest |
| Capital | Unnamed (central settlement) |
| Disposition | Neutral, agrarian |
| Notable features | Borders Lake Aegean to the north; breadbasket of the continent |

A fertile central kingdom fed by the rivers flowing from Lake Aegean. Verna
maintains neutrality between the Great Kingdom to the east and the western
realms. Its plains produce most of the continent's grain. Verna is part of the
Golden Vales agricultural bloc (see section 9).

### Sultanate of Khazar

| Property | Value |
|----------|-------|
| Tile(s) | tile_07 |
| Map region | Eastern coast, cols 28-37, rows 16-24 |
| Terrain | Dense forest, hills, coastal |
| Capital | Khazar (pop. 310,000) |
| Disposition | Mercantile, semi-autonomous |
| Notable features | Maritime vassal of Sunstone; dynamic bazaars; massive merchant fleet |

A semi-autonomous exotic coastal metropolis on the southeastern tip, known for
its dynamic bazaars, minarets, and massive merchant fleet. Khazar is technically
a vassal of the Theocracy of Sunstone but operates with increasing independence,
growing hostile toward the Solar Inquisition's interference in their shipping
and merchant networks.

**Visible settlements:** Grillo Quallor, Khazar

### Sultanate of Zeif

| Property | Value |
|----------|-------|
| Tile(s) | tile_00, tile_04 |
| Map region | Far western edge, cols 0-5, rows 8-16 |
| Terrain | Plains, scrubland, coastal cliffs |
| Capital | Sontero Idon |
| Disposition | Isolationist, wealthy |
| Notable features | Controls the western tip of the continent; borders Sea of Dust |

The westernmost civilized realm. Zeif sits on the far side of the Skyhammer
Peaks, separated from the central kingdoms by mountains. Its people trade
across the Sea of Dust with unknown western lands.

**Visible settlements:** Sontero Idon

### Caliphate of Ekbir

| Property | Value |
|----------|-------|
| Tile(s) | tile_00 |
| Map region | Upper-western coast, cols 2-6, rows 6-10 |
| Terrain | Hills, scrubland, coastal |
| Capital | Elois |
| Disposition | Theocratic, militant |
| Notable features | Controls the northwestern coastal region; religious authority |

A theocratic state on the northwestern coast. Ekbir claims divine mandate
over the western realms and maintains a powerful army of zealots. Tusmit sits
at its southern border as a buffer state.

**Visible settlements:** Elois

### Grand Duchy of Loren

| Property | Value |
|----------|-------|
| Tile(s) | tile_06 |
| Map region | Central-eastern territory, cols 18-26, rows 8-14 |
| Terrain | Forest, hills, river valleys |
| Capital | Lorenstadt (pop. 850,000) |
| Disposition | Noble, feudal |
| Notable features | Dense forests; strong knightly tradition; borders Verdant Heart |

A large forested duchy east of Verna and the heart of the Golden Vales
Confederation (see section 9). Lorenstadt is a glorious metropolis of white
limestone, towering spires, and masterfully engineered aqueducts divided into
strict social districts. Loren's knights are renowned across the continent.
The Verdant Heart forest covers much of its territory.

**Visible settlements:** Credosshat, Electus, Crupert, Lorenstadt

### Theocracy of the Pale

| Property | Value |
|----------|-------|
| Tile(s) | tile_02 |
| Map region | Northeastern mountains, cols 26-34, rows 4-8 |
| Terrain | Mountain, tundra, alpine meadow |
| Capital | Unnamed (mountain temple) |
| Disposition | Theocratic, isolationist |
| Notable features | Mountain fortress-monasteries; harsh climate; borders Silver Leaf Wood |

A religious state nestled in the northeastern mountain ranges. The Pale's
priest-rulers govern from fortified monasteries. Few outsiders are welcome.

### Prelacy of Almor

| Property | Value |
|----------|-------|
| Tile(s) | tile_06 |
| Map region | Central-east, cols 22-28, rows 14-18 |
| Terrain | Rolling hills, light forest |
| Capital | Unnamed (prelate's seat) |
| Disposition | Religious, diplomatic |
| Notable features | Buffer state between Loren and the Great Kingdom |

A small ecclesiastical state governed by a prelate. Almor serves as a
diplomatic buffer between the Grand Duchy of Loren and the Great Kingdom.

### Principality of Ulek

| Property | Value |
|----------|-------|
| Tile(s) | tile_05 |
| Map region | Central-south, cols 12-16, rows 20-24 |
| Terrain | Hills, light forest, rocky crags |
| Capital | Unnamed (prince's hall) |
| Disposition | Demi-human friendly, defensive |
| Notable features | Near Stonefell Rocks; significant dwarf and gnome population |

A principality with a large non-human population. Dwarves mine the Stonefell
Rocks, gnomes tend the hill farms, and elves patrol the forest borders.

### County of Ulek

| Property | Value |
|----------|-------|
| Tile(s) | tile_05 |
| Map region | Central-south, cols 10-14, rows 18-22 |
| Terrain | Hills, grassland |
| Capital | Unnamed (count's keep) |
| Disposition | Allied with Principality of Ulek |
| Notable features | Agricultural hinterland of the Ulek realms |

The rural counterpart to the Principality. The County provides food and raw
materials to the mountain settlements.

### Duchy of Urnst

| Property | Value |
|----------|-------|
| Tile(s) | tile_06 |
| Map region | Central waterways, cols 18-22, rows 12-16 |
| Terrain | River valleys, grassland, light forest |
| Capital | Unnamed (ducal palace) |
| Disposition | Mercantile, river trade |
| Notable features | Controls central river commerce; wealthy merchant class; borders Nyr Dyv |

A prosperous duchy built on river trade. The central waterways (including
Nyr Dyv) pass through Urnst territory, making it a natural trade hub.

### County of Urnst

| Property | Value |
|----------|-------|
| Tile(s) | tile_06 |
| Map region | Central waterways, cols 18-24, rows 8-12 |
| Terrain | River banks, grassland, forest edge |
| Capital | Unnamed (county seat) |
| Disposition | Allied with Duchy of Urnst |
| Notable features | Northern extension of Urnst trade network; borders Grand Duchy of Loren |

The county controls the northern portion of the central waterway network,
bordering the Grand Duchy of Loren to the east.

### Duchy of Liek

| Property | Value |
|----------|-------|
| Tile(s) | tile_05 |
| Map region | South of Stonefell Rocks, cols 10-14, rows 18-22 |
| Terrain | Rocky hills, scrubland |
| Capital | Unnamed (duke's fortress) |
| Disposition | Martial, border defense |
| Notable features | Guards the southern passes through Stonefell Rocks |

A frontier duchy defending the southern approaches through the Stonefell
Rocks. Liek's soldiers are hardened by constant skirmishes with monsters
from the Desolation of the Fire Dragon.

### Kingdom of Bentand

| Property | Value |
|----------|-------|
| Tile(s) | tile_09 |
| Map region | Southwestern peninsula, cols 6-10, rows 22-26 |
| Terrain | Coastal, grassland, mountain foothills |
| Capital | Unnamed (peninsular city) |
| Disposition | Maritime, independent |
| Notable features | Southwestern peninsula; fishing and shipbuilding |

An independent maritime kingdom on the southwestern peninsula. Bentand's
fleet rivals the Sea Princes', though the two maintain an uneasy peace.

### Bandit Kingdoms

| Property | Value |
|----------|-------|
| Tile(s) | tile_02 |
| Map region | North-central forested lowlands, cols 14-20, rows 6-10 |
| Terrain | Dense forest, marsh, broken terrain |
| Capital | None (shifting power centers) |
| Disposition | Chaotic, hostile |
| Notable features | Lawless territory; borders Silver Leaf Wood |

A loose collection of petty warlords and bandit chiefs who control the
forested lowlands south of the Silver Leaf Wood.

### Horned Society

| Property | Value |
|----------|-------|
| Tile(s) | tile_01 |
| Map region | North-central, cols 14-20, rows 6-10 |
| Terrain | Dark forest, hills |
| Capital | Unnamed (hidden stronghold) |
| Disposition | Evil, secretive |
| Notable features | Demon-worshipping cult; feared by neighbors; borders Moonwood/Silver Leaf Wood |

A sinister realm ruled by a cabal of hierarchs devoted to dark powers. The
Horned Society's borders are heavily patrolled by humanoid soldiers.

### Shield Lands

| Property | Value |
|----------|-------|
| Tile(s) | tile_05 |
| Map region | North of Lake Aegean, cols 14-18, rows 8-12 |
| Terrain | Plains, fortified settlements |
| Capital | Unnamed (shield fortress) |
| Disposition | Lawful, militaristic |
| Notable features | Bulwark against the Bandit Kingdoms and Horned Society |

A confederation of fortified settlements dedicated to holding the line
against the chaotic north.

### Perren Land

| Property | Value |
|----------|-------|
| Tile(s) | tile_00 |
| Map region | West of Skyhammer Peaks, cols 8-10, rows 6-10 |
| Terrain | Alpine meadow, mountain foothills |
| Capital | Oremond |
| Disposition | Neutral, pastoral |
| Notable features | Mountain herders; fiercely independent clans |

A highland realm of independent clans. Perren folk are renowned archers and
trackers.

**Visible settlements:** Oremond, Reveret

### North Province

| Property | Value |
|----------|-------|
| Tile(s) | tile_07 |
| Map region | Eastern peninsula, cols 28-37, rows 4-12 |
| Terrain | Coastal, forest, hills, river valleys |
| Capital | Unnamed (provincial seat) |
| Disposition | Semi-autonomous vassal of the Great Kingdom |
| Notable features | Controls the Vanguard Bay coastline; many settlements |

The northeastern arm of the Great Kingdom. The North Province is technically
a vassal state but operates with near-complete autonomy.

**Visible settlements:** Stelts, Shackin, Deon, Vaugen, Callex, Nobrigris, Fourte, Voorth, Barre

### South Province

| Property | Value |
|----------|-------|
| Tile(s) | tile_06, tile_07 |
| Map region | Southeastern coast, cols 26-34, rows 18-24 |
| Terrain | Coastal, grassland, river valleys |
| Capital | Nollass |
| Disposition | Vassal of the Great Kingdom |
| Notable features | Controls southeastern coast; borders Sea of Gearnat |

The southeastern arm of the Great Kingdom, governing the coast between the
Sea of Gearnat and the Azure Depths Ocean.

**Visible settlements:** Nollass

### The Frozen Coalition (Ice Clans & Northern Territories)

| Property | Value |
|----------|-------|
| Tile(s) | tile_01, tile_02, tile_03 |
| Map region | Far frozen north, cols 10-36, rows 0-6 |
| Terrain | Tundra, frozen wasteland, mountain, volcanic rift |
| Capital | Borealis |
| Population | ~1,200,000 across settled zones, fortresses, and nomadic clusters |
| Power standing | Weak / Exploited — resource-rich but vulnerable to food insecurity and factionalism |
| Disposition | Isolationist, communal, hostile to outsiders |
| Notable features | Northern Ice Peaks; geothermal industry; Dark Iron ore monopoly |

The Frozen Coalition encompasses the entire boreal front of the continent. To a
northern citizen, the individual is nothing; the community is everything. Waste
is considered a capital crime, and laziness is viewed as social betrayal. A
stern, communal stoicism born of survival defines every aspect of their culture.

The Coalition was forged during the Long Frost century, a historical anomaly where
a polar shift plunged the entire upper hemisphere into an endless winter, wiping
out all independent human kingdoms. Borealis was founded not as an empire of
conquest, but as a multi-generational, magically sealed shelter. This historical
trauma breeds an absolute isolationist philosophy — northerners view southerners
as soft, deceptive parasites who exploit the desperate for profit.

**Major settlements:**
- **Borealis** (pop. 350,000) — Capital. A high-walled citadel carved from
  glacio-marble and reinforced by ancient frost-runes. Streets are covered by
  massive semi-translucent ice domes that trap geothermal heat. Architecture is
  sharp, clinical, and pristine, prioritizing insulation above ornament.
- **Ashtown** (pop. 180,000) — Industrial core. A sprawling, smoke-choked
  subterranean and surface settlement built into northern volcanic rifts. Coated
  in black soot and sulfurous ash. Miners, engineers, and foundry workers endure
  grueling shifts to keep the furnace vents clear.
- **North-Watch** (pop. 45,000 garrison) — Military outpost. A brutalist
  stone-and-iron fortress built across the lowest pass of the Ice Peaks.
  Self-sustaining with underground barracks, armories, and cavernous stables.
- **Nots** — Seasonal nomadic camp of the outer Ice Clans.

**Religion:** Rime-Shamanism, an animistic faith worshipping elemental spirits of
winter, frost, and stone. They believe polar blizzards are the literal breath of
ancestral gods who must be appeased with offerings of dark ore and blood.

**Societal rift:** An intense socio-cultural divide splits the pristine
glacio-masons of Borealis from the soot-caked working class of Ashtown. The
miners resent the capital's aristocratic shamans, who live in clean domed palaces
while bartering away raw metal ore to southern traders for luxuries that never
reach the workers.

**Military:**
- **Rime-Guard** (~22,000) — Professional heavy infantry and mountain scouts
- **Taiga Strider Rangers** — Guerrilla hunters on snowshoes with domestic
  frost-wolves, composite bows, frost-tipped arrows
- **Ashtown Geothermal Sappers** — Combat engineers with pneumatic drills and
  pressurized boiling steam cannons
- Defensive-oriented; runic avalanche triggers and artificially frozen river
  blockades can stall armies ten times their size
- Supply lines are purely internal via subterranean thermal-heated ice caverns

**Economy:**
- Currency: The Shard (stamped iron slugs backed by state ore reserves)
- Exports: Unrefined Dark Iron ore, frost-resistant Taiga pine, rime-wolf pelts,
  glacier-melt distillation oil
- Imports: Grain, flour, dried fruits, woven textiles, volcanic heat stones
- Systemic flaw: Southern agricultural cartels intentionally freeze grain
  shipments during autumn harvest, causing artificial famines that force the
  Coalition to trade away Dark Iron stockpiles at a fraction of their worth

**Quest hooks:**
- **The Ashtown Industrial Strike** — Overseer Boros is covertly stockpiling
  weapons and organizing a total labor shutdown. If Ashtown cuts the geothermal
  heat pipes routed to Borealis, the capital will freeze solid within 48 hours.
- **The Whispering Spire Malfunction** — The naturally occurring hollow ice
  pillar near North-Watch, which acts as an acoustic early-warning system against
  blizzards, has begun humming in reverse, luring wild rime-beasts toward the
  fortress walls.

### The Pomarj

| Property | Value |
|----------|-------|
| Tile(s) | tile_05 |
| Map region | Southeastern peninsula below Ulek, cols 16-22, rows 20-24 |
| Terrain | Hills, scrubland, coastal |
| Capital | None (humanoid tribal territory) |
| Disposition | Hostile, humanoid-dominated |
| Notable features | Orc and goblin territory; raiding base against Ulek and Urnst |

A wild peninsula south of the Principality of Ulek, dominated by orc and
goblin tribes. The Pomarj's humanoid warbands raid northward into Ulek and
along the Sea of Gearnat coast. Adventurers are hired to clear raiding parties.
The Pomarj borders the Tropical Serpentine Jungle wild lands to the south
(see section 9).

### Heimoneland

| Property | Value |
|----------|-------|
| Tile(s) | tile_11 |
| Map region | Far southeastern coast, cols 30-36, rows 26-30 |
| Terrain | Coastal, tropical |
| Capital | Sorget |
| Disposition | Distant, isolationist |
| Notable features | Remote southeastern territory; little contact with central realms |

A distant realm on the far southeastern coast, separated from the main
continent by the Sea of Medegia. Little is known of Heimoneland in the
central kingdoms.

**Visible settlements:** Sorget

---

## 2. Cities, Ports, and Towns

### Major Cities

#### Hinwanit

| Property | Value |
|----------|-------|
| Tile | tile_07 |
| Map position | col 28, row 16 |
| World address | `/-181,156` |
| Region | Interior of The Great Kingdom |
| Population | ~12,000 |
| Terrain | Grassland / plains |
| Features | Imperial capital, grand cathedral, military garrison, arcane academy |
| Disposition | Lawful-evil |

The sprawling capital of the Great Kingdom. Hinwanit is the largest city
on the continent — a maze of stone towers, fortified walls, and crowded
districts. The Overking rules from the Iron Throne in the Imperial Palace.

**Key locations:**
- **Imperial Palace** — Seat of the Overking, heavily guarded
- **Grand Cathedral of Law** — Largest temple on the continent, cleric services
- **Arcane Academy** — Magic-user training, spell scrolls for sale
- **Iron Market** — Weapons, armor, military supplies at premium prices
- **The Gilded Cage Inn** — Luxurious, 10 gp/night, political intrigue
- **Garrison Quarter** — Barracks for 2,000 soldiers, training grounds
- **Foreign Quarter** — Diplomats, spies, restricted access

#### Port of Odyssey

| Property | Value |
|----------|-------|
| Tile | tile_04 |
| Map position | col 5, row 14 |
| World address | `/-204,154` |
| Region | Western coast, Plains of the Paynims border |
| Population | ~8,000 |
| Terrain | Beach / coastal |
| Features | Major harbor, shipyards, merchant quarter, thieves' guild |
| Disposition | Cosmopolitan, lawful-neutral |

The largest port on the western coast. Odyssey is a melting pot of cultures —
Zeif merchants, Ekbir pilgrims, and Bentand sailors all trade here. The harbor
can berth 40 ships. A powerful merchants' guild controls city politics.

**Key locations:**
- **The Grand Harbor** — 40-berth deep-water port with lighthouse
- **Merchants' Quarter** — Warehouses, trading houses, money changers
- **The Salted Mast Inn** — Premier inn, 5 gp/night, rumors and quest hooks
- **Temple of the Sea** — Cleric healing, blessings for voyages
- **Thieves' Quarter** — Black market, fencing, thieves' guild entrance
- **Shipwright Row** — Ship repairs and custom builds

#### Gradsul

| Property | Value |
|----------|-------|
| Tile | tile_09 |
| Map position | col 12, row 24 |
| World address | `/-197,164` |
| Region | Hold of the Sea Princes, southwestern coast |
| Population | ~6,000 |
| Terrain | Beach / coastal |
| Features | Pirate haven turned trade port, arena, harbor |
| Disposition | Chaotic-neutral |

The capital of the Sea Princes. Gradsul's harbor is a forest of masts —
merchant galleons, war galleys, and the occasional pirate vessel.

**Key locations:**
- **Prince's Palace** — Seat of the Sea Princes' council
- **The Corsair's Rest** — Rowdy tavern, 3 gp/night, fights common
- **Arena of Waves** — Gladiatorial combat, betting, prize fights
- **Black Market** — Contraband, stolen goods, rare items at markup
- **Harbor Master's Tower** — Controls port access, collects tariffs
- **Chandler's Row** — Ship supplies, rope, canvas, provisions

### Coastal Towns

#### Monmurg

| Property | Value |
|----------|-------|
| Tile | tile_09 |
| Map position | col 9, row 22 |
| World address | `/-200,162` |
| Region | Hold of the Sea Princes, southwestern coast |
| Population | ~3,000 |
| Terrain | Beach / coastal |
| Features | Secondary port, fishing fleet, smuggler coves |
| Disposition | Chaotic-neutral |

A rough port town northwest of Gradsul. Monmurg's economy runs on fishing and
smuggling in roughly equal measure.

**Key locations:**
- **Fisher's Wharf** — Fishing boats, fresh catch market
- **The Barnacle Inn** — Cheap lodging, 2 gp/night, rough clientele
- **Smuggler's Cove** — Hidden inlet for contraband transfer
- **Shrine of the Tide** — Small chapel, basic cleric healing

#### Rotik

| Property | Value |
|----------|-------|
| Tile | tile_03 |
| Map position | col 30, row 8 |
| World address | `/-179,148` |
| Region | Northeastern coast, below Vanguard Bay |
| Population | ~2,500 |
| Terrain | Coastal hills / forest |
| Features | Frontier port, fur trade, northern defense post |
| Disposition | Lawful-neutral |

A hardy frontier port on the northeastern coast. Rotik serves as the last
civilized outpost before the frozen north. Its people trade in furs, amber,
and whale oil. The town maintains a strong militia against Ice Clan raids.

**Key locations:**
- **Northern Wharf** — Small harbor, fur trading post
- **The Hearthstone Inn** — Warm refuge, 4 gp/night, northern rumors
- **Palisade Fort** — Wooden fort, militia headquarters
- **Fur Market** — Exotic pelts, whale oil, amber

#### Penensraft

| Property | Value |
|----------|-------|
| Tile | tile_09 |
| Map position | col 12, row 22 |
| World address | `/-197,162` |
| Region | Hold of the Sea Princes, inland coast |
| Population | ~1,500 |
| Terrain | Grassland / coastal |
| Features | River port, ferry crossing, trade waystation |
| Disposition | Neutral |

A small river port and trade waystation between Monmurg and Gradsul. Penensraft
controls a key ferry crossing.

**Key locations:**
- **Ferry Landing** — River crossing, 1 sp per passenger
- **Waystation Inn** — Simple lodging, 2 gp/night
- **River Market** — Freshwater fish, small goods

#### Maritime Point

| Property | Value |
|----------|-------|
| Tile | tile_03 |
| Map position | col 32, row 4 |
| World address | `/-177,144` |
| Region | Boreal Reach, far northeastern coast |
| Population | ~500 |
| Terrain | Tundra / coastal |
| Features | Remote northern port, whaling station |
| Disposition | Neutral |

A remote whaling station on the frozen northeastern coast. Maritime Point is
the northernmost permanent settlement on the continent.

**Key locations:**
- **Whaling Dock** — Whale processing, oil rendering
- **The Frostbite Tavern** — Only inn, 2 gp/night, whale stew

### Inland Towns

#### Veluna

| Property | Value |
|----------|-------|
| Tile | tile_05 |
| Map position | col 12, row 12 |
| World address | `/-197,152` |
| Region | Central-west, between Skyhammer Peaks and central plains |
| Population | ~4,000 |
| Terrain | Grassland / light forest |
| Features | Religious center, crossroads town, market hub |
| Disposition | Lawful-good |

A prosperous crossroads town at the heart of the western realms. Veluna
sits at the junction of major trade routes — north to Perren Land, east
to Verna, south to the Ulek realms.

**Key locations:**
- **Cathedral of the True Light** — Major temple, free Cure Light Wounds daily
- **Crossroads Market** — Central trading hub, fair prices
- **The Pilgrim's Rest Inn** — Clean and safe, 4 gp/night
- **Town Hall** — Quest board, bounties, regional news
- **Smithy of the Anvil** — Quality weapons and armor, +1 enchantments available

#### Tusmit

| Property | Value |
|----------|-------|
| Tile | tile_00 |
| Map position | col 5, row 9 |
| World address | `/-204,149` |
| Region | Below Caliphate of Ekbir, western interior |
| Population | ~2,000 |
| Terrain | Hills / scrubland |
| Features | Border town, caravanserai, spice trade |
| Disposition | Neutral |

A dusty border town where Ekbir's religious strictures give way to secular
commerce. Tusmit is the last supply stop before crossing the Skyhammer Peaks
westward or ascending into Ekbir's territory.

**Key locations:**
- **The Caravanserai** — Fortified inn for traders, 3 gp/night, stabling
- **Spice Bazaar** — Exotic goods from Ekbir and Zeif
- **Border Garrison** — Ekbir soldiers check travelers
- **Wayfinder's Chapel** — Small temple, basic healing

#### Citesi

| Property | Value |
|----------|-------|
| Tile | tile_09 |
| Map position | col 12, row 20 |
| World address | `/-197,160` |
| Region | South-central, north of Gradsul |
| Population | ~2,500 |
| Terrain | Hills / grassland |
| Features | Mining town, ore trade, dwarf quarter |
| Disposition | Lawful-neutral |

A mining town perched on the northern edge of the Stonefell Rocks.

**Key locations:**
- **Dwarf Quarter** — Dwarven smiths, ore dealers, stone halls
- **The Iron Ingot Inn** — Sturdy stone building, 3 gp/night, dwarven ale
- **Ore Exchange** — Raw metal and gem trading
- **Deep Shaft Mine** — Active mine, occasional monster incursions

#### Glintshore

| Property | Value |
|----------|-------|
| Tile | tile_05 |
| Map position | col 10, row 16 |
| World address | `/-199,156` |
| Region | Western edge of Stonefell Rocks, south of Veluna |
| Population | ~2,000 |
| Terrain | Hills / rocky |
| Features | Gem cutting, mineral trade, gateway to Stonefell Rocks |
| Disposition | Neutral-good |

A settlement on the western approach to the Stonefell Rocks, known for its
gem-cutters and mineral traders. Glintshore sits where the plains meet the
rocky crags, serving as a staging point for prospectors and miners.

**Key locations:**
- **Gem Cutters' Row** — Expert lapidaries, gem appraisal
- **The Shining Stone Inn** — Comfortable, 3 gp/night
- **Prospector's Guild** — Maps, guides, mining claims
- **Stonefell Gate** — Trail head into the Stonefell Rocks

#### Anata Krata

| Property | Value |
|----------|-------|
| Tile | tile_04 |
| Map position | col 6, row 12 |
| World address | `/-203,152` |
| Region | Plains of the Paynims, east of Port of Odyssey |
| Population | ~1,200 |
| Terrain | Plains / scrubland |
| Features | Caravan stop, horse trading, Paynim frontier |
| Disposition | Neutral |

A frontier settlement on the Plains of the Paynims, serving as a caravan
stop between Port of Odyssey and the Skyhammer Peaks passes. Paynim horsemen
trade here with western merchants.

**Key locations:**
- **Horse Corral** — Paynim horse trading, mounts for sale
- **The Dusty Trail Inn** — Basic, 2 gp/night, caravan gossip
- **Paynim Market** — Hides, furs, exotic goods from the western plains

#### Ioz

| Property | Value |
|----------|-------|
| Tile | tile_01 |
| Map position | col 14, row 6 |
| World address | `/-195,146` |
| Region | North-central, between Ash Waste and Horned Society |
| Population | ~800 |
| Terrain | Plains / forest edge |
| Features | Frontier outpost, buffer settlement, ranger station |
| Disposition | Neutral |

A small frontier outpost at the edge of civilized lands, wedged between
the Ash Waste to the north and the Horned Society's dark forests. Rangers
and scouts use Ioz as a base for monitoring threats from the north.

**Key locations:**
- **Ranger Station** — Northern scouts, bounties on humanoids
- **The Last Light Inn** — Spartan, 2 gp/night, rumors of the north

#### Blacamer

| Property | Value |
|----------|-------|
| Tile | tile_01 |
| Map position | col 12, row 2 |
| World address | `/-197,142` |
| Region | Northern frontier, edge of Frozen Tundra |
| Population | ~600 |
| Terrain | Tundra / forest edge |
| Features | Fur trading post, Ice Clan contact point |
| Disposition | Neutral |

The northernmost town on the western half of the continent. Blacamer sits
where the forests give way to tundra, serving as a fur trading post and
occasional point of contact with the Ice Clans.

**Key locations:**
- **Fur Trading Post** — Northern pelts, rare furs, Ice Clan trade
- **The Frozen Hearth Inn** — Basic shelter, 2 gp/night

#### Bordos

| Property | Value |
|----------|-------|
| Tile | tile_01 |
| Map position | col 14, row 8 |
| World address | `/-195,148` |
| Region | Between Golden Plains and Horned Society |
| Population | ~1,000 |
| Terrain | Grassland / forest edge |
| Features | Agricultural village, border watch |
| Disposition | Neutral-good |

A farming village on the border between the Golden Plains and the dark
forests of the Horned Society. Bordos' militia keeps watch against
humanoid raids.

**Key locations:**
- **Village Green** — Weekly market, local produce
- **Border Watch Tower** — Militia post, early warning system
- **The Plowman's Rest Inn** — Simple, 2 gp/night

#### Mottomics

| Property | Value |
|----------|-------|
| Tile | tile_09 |
| Map position | col 10, row 22 |
| World address | `/-199,162` |
| Region | South of Bentand, near Monmurg |
| Population | ~1,000 |
| Terrain | Coastal hills |
| Features | Fishing village, boat building |
| Disposition | Neutral |

A small fishing and boat-building village between Bentand and Monmurg.

**Key locations:**
- **Boatyard** — Small craft construction and repair
- **The Anchor Inn** — Fisherman's lodge, 2 gp/night

#### Dort

| Property | Value |
|----------|-------|
| Tile | tile_03 |
| Map position | col 34, row 6 |
| World address | `/-175,146` |
| Region | Boreal Reach, northeastern coast |
| Population | ~400 |
| Terrain | Tundra / coastal |
| Features | Remote fishing hamlet, seal hunting |
| Disposition | Neutral |

A tiny hamlet on the frozen northeastern coast, surviving on seal hunting
and fishing.

#### Nollass

| Property | Value |
|----------|-------|
| Tile | tile_06 |
| Map position | col 24, row 22 |
| World address | `/-185,162` |
| Region | South Province, southeastern coast |
| Population | ~3,000 |
| Terrain | Coastal / grassland |
| Features | Provincial capital, garrison, trade port |
| Disposition | Lawful-neutral |

Capital of the South Province, serving as the Great Kingdom's southeastern
administrative center.

**Key locations:**
- **Provincial Hall** — South Province government
- **Garrison Fort** — Great Kingdom soldiers
- **Harbor** — Trade with Sea of Gearnat ports
- **The Provincial Inn** — Official lodging, 4 gp/night

### North Province Settlements

The North Province contains numerous smaller settlements visible on the map:

| Settlement | Tile | Map Position | Notes |
|-----------|------|-------------|-------|
| Stelts | tile_07 | col 30, row 6 | Northern garrison town |
| Shackin | tile_07 | col 32, row 6 | Coastal settlement |
| Deon | tile_07 | col 34, row 8 | Coastal port |
| Vaugen | tile_07 | col 30, row 10 | Interior town |
| Callex | tile_07 | col 30, row 10 | River crossing |
| Nobrigris | tile_07 | col 34, row 10 | Coastal town |
| Fourte | tile_07 | col 34, row 10 | Eastern settlement |
| Voorth | tile_07 | col 32, row 12 | Interior town |
| Barre | tile_07 | col 34, row 12 | Eastern garrison |

---

## 3. Oceans, Seas, and Waterways

### Sea of Dust

| Property | Value |
|----------|-------|
| Tile(s) | tile_04, tile_08 |
| Map region | Far southwestern expanse |
| Type | Ocean |
| Navigation | Dangerous — dust storms, hidden reefs |
| Notable | Trade route to unknown western lands; Silver Reef Isles lie within |

A vast body of water west of the continent. Named for the fine volcanic dust
that blows across its surface from the Desolation.

### Iceland Sea

| Property | Value |
|----------|-------|
| Tile(s) | tile_02, tile_03 |
| Map region | Top-center |
| Type | Frozen sea |
| Navigation | Impassable in winter, dangerous in summer (icebergs) |
| Notable | Ice Clan territory; whale hunting grounds |

The frozen sea at the northern edge of the known world.

### Azure Depths Ocean

| Property | Value |
|----------|-------|
| Tile(s) | tile_03, tile_07, tile_11 |
| Map region | Eastern expanse |
| Type | Deep ocean |
| Navigation | Open water, relatively safe along the coast |
| Notable | Trade route to Spindrift Isles and Sea Barons |

The vast eastern ocean.

### Vanguard Bay

| Property | Value |
|----------|-------|
| Tile(s) | tile_03, tile_06, tile_07 |
| Map region | Northeastern bay AND central-eastern gulf |
| Type | Bay / gulf (two distinct bodies of water share this name) |
| Navigation | Sheltered, safe harbor |
| Notable | Major anchorage for the Great Kingdom's fleet |

Two bodies of water share the Vanguard Bay name — the large northeastern
bay (tile_03) and the central-eastern gulf between the Great Kingdom and
the South Province (tile_06).

### Sea of Gearnat

| Property | Value |
|----------|-------|
| Tile(s) | tile_06, tile_10 |
| Map region | Central-south sea |
| Type | Inland sea |
| Navigation | Moderate — seasonal storms |
| Notable | Separates northern landmass from southern territories |

The central sea separating the main continent from the southern territories.

### Nyr Dyv

| Property | Value |
|----------|-------|
| Tile(s) | tile_05, tile_06 |
| Map region | Central lake |
| Type | Large inland lake |
| Navigation | Safe, freshwater |
| Notable | "Lake of Unknown Depths" — rumored bottomless; lake monsters |

The largest freshwater lake on the continent. Central to the trade networks
of Urnst, Verna, and Loren.

### Lake Aegean

| Property | Value |
|----------|-------|
| Tile(s) | tile_05 |
| Map region | Northern-central |
| Type | Large lake |
| Navigation | Safe, fed by mountain streams |
| Notable | Feeds major river systems; Shield Lands on its northern shore |

A large clear-water lake fed by streams from the Skyhammer Peaks.

### Sea of Medegia

| Property | Value |
|----------|-------|
| Tile(s) | tile_11 |
| Map region | Far southeastern waters |
| Type | Coastal sea |
| Navigation | Moderate |
| Notable | Separates the mainland from Heimoneland; Spindrift Isles nearby |

The southeastern coastal sea, separating the Great Kingdom's coast from
Heimoneland and the Spindrift Isles.

### Deepwater Bay

| Property | Value |
|----------|-------|
| Tile(s) | tile_08, tile_09 |
| Map region | Southwestern coast, south of Gradsul |
| Type | Bay |
| Navigation | Safe, deep water |
| Notable | Southern anchorage for the Sea Princes' fleet |

A deep natural harbor south of Gradsul, used as a secondary anchorage
by the Sea Princes.

### Spindrift Isles

| Property | Value |
|----------|-------|
| Tile(s) | tile_11 |
| Map region | Eastern ocean |
| Type | Island chain |
| Navigation | Tricky — reefs and currents |
| Notable | Elven naval power; restricted access to outsiders |

An archipelago in the eastern ocean, governed by a secretive elven
maritime society.

### Sea Barons

| Property | Value |
|----------|-------|
| Tile(s) | tile_07 |
| Map region | Eastern ocean, off North Province coast |
| Type | Island chain / maritime territory |
| Navigation | Patrolled by Sea Baron warships |
| Notable | Naval mercenaries; control eastern sea lanes |

A confederation of island-based naval lords.

### Silver Reef Isles

| Property | Value |
|----------|-------|
| Tile(s) | tile_04 |
| Map region | Western ocean |
| Type | Island chain |
| Navigation | Dangerous — coral reefs just below the surface |
| Notable | Shipwrecks; pirate hideouts |

A chain of low coral islands west of the continent.

### The Cinder Archipelago

| Property | Value |
|----------|-------|
| Tile(s) | tile_10 |
| Map region | South-central sea, south of Sea of Gearnat |
| Type | Volcanic island chain |
| Navigation | Extremely dangerous — volcanic activity, lava flows |
| Notable | Active volcanoes; fire creatures; connects to Desolation of the Fire Dragon |

A chain of volcanic islands in the south-central sea. The Cinder Archipelago
is the oceanic extension of the Desolation of the Fire Dragon's volcanic
activity. Active eruptions make navigation treacherous, and fire-breathing
creatures nest on the larger islands. Legends speak of a dragon's lair on
the central island.

---

## 4. Geographical Features

### Mountains

#### The Skyhammer Peaks

| Property | Value |
|----------|-------|
| Tile(s) | tile_00, tile_04, tile_05 |
| Map region | Western mountain spine, cols 4-10, rows 2-20 |
| Terrain | Mountain, alpine, snowcap |
| Tile count | ~60 tiles |
| Notable | Continental divide; highest peaks; dwarven deep mines |

The massive mountain range dominating the western continent. The Skyhammer
Peaks run north-south for nearly the full height of the map, dividing the
western coastal realms (Zeif, Ekbir, Bentand) from the central plains.

**Named peaks:**
- **Riven Peak** — Prominent peak in the northern Skyhammer Peaks (tile_00)
- **Beller Peak** — Major peak south of Riven Peak (tile_00)

**Encounters:** Mountain lions, griffons, hill giants, dwarven patrols, rockslides

#### Stonefell Rocks

| Property | Value |
|----------|-------|
| Tile(s) | tile_05 |
| Map region | Center-west crags, cols 10-18, rows 16-20 |
| Terrain | Hills, rocky crags |
| Tile count | ~25 tiles |
| Notable | Dwarf and gnome settlements; mineral wealth; monster lairs |

A rugged chain of crags and broken hills cutting through the center-west.

**Encounters:** Kobolds, hobgoblins, harpies, dwarven miners (friendly), cave bears

### Forests

#### Silver Leaf Wood

| Property | Value |
|----------|-------|
| Tile(s) | tile_02 |
| Map region | North-central, cols 16-24, rows 4-8 |
| Terrain | Dense forest |
| Tile count | ~30 tiles |
| Notable | Ancient forest; Bandit Kingdoms and Theocracy of the Pale border it |

A vast ancient forest in the north-central region. Its silver-barked trees
give it its name. The Bandit Kingdoms hide within its western reaches, and
the Theocracy of the Pale claims its eastern edge.

**Encounters:** Orcs, giant spiders, owlbears, bandits, wood elf patrols (friendly), treants

#### Verdant Heart

| Property | Value |
|----------|-------|
| Tile(s) | tile_06 |
| Map region | Center-east, cols 20-26, rows 6-12 |
| Terrain | Forest, dense forest |
| Tile count | ~25 tiles |
| Notable | Forms the border between Loren and the Great Kingdom |

A dense forest in the center-east. The Verdant Heart forms a natural border
between the Grand Duchy of Loren and surrounding territories.

**Encounters:** Wolves, giant spiders, wood elf patrols, hermits, owlbears

### Plains & Deserts

#### The Golden Plains

| Property | Value |
|----------|-------|
| Tile(s) | tile_01, tile_05 |
| Map region | Central-western plains, cols 8-16, rows 8-14 |
| Terrain | Plains, grassland |
| Tile count | ~35 tiles |
| Notable | Major trade route corridor; breadbasket; horse herds |

The sweeping central-western plains between the Skyhammer Peaks and the
central waterways. Named for the golden wheat and grass that covers them.

**Encounters:** Bandits, wolves, merchant caravans (friendly), wild horses, wandering clerics

#### Plains of the Paynims

| Property | Value |
|----------|-------|
| Tile(s) | tile_04 |
| Map region | Far western plains, cols 0-6, rows 10-16 |
| Terrain | Plains, scrubland |
| Tile count | ~15 tiles |
| Notable | Nomadic horsemen; western frontier; sparse settlements |

Dry plains west of the Skyhammer Peaks. The Paynims are nomadic horsemen
who control this territory.

**Encounters:** Nomad horsemen, giant scorpions, desert lizards, oasis camps

#### The Ash Waste

| Property | Value |
|----------|-------|
| Tile(s) | tile_01 |
| Map region | North-central wasteland, cols 8-14, rows 2-6 |
| Terrain | Barren waste, ash-covered plains |
| Tile count | ~15 tiles |
| Notable | Desolate wasteland; source unknown; ash storms reduce visibility |

A bleak expanse of ash-covered ground north of the Golden Plains. The Ash
Waste is virtually lifeless — no vegetation grows in the fine gray ash that
covers everything. The source of the ash is debated: some say an ancient
volcanic eruption, others blame dark magic from the Horned Society.

**Encounters:** Ash storms (visibility hazard), undead, occasional Horned Society patrols

#### Desolation of the Fire Dragon

| Property | Value |
|----------|-------|
| Tile(s) | tile_09, tile_10 |
| Map region | Southern scorched desert, cols 12-24, rows 24-30 |
| Terrain | Desert, volcanic waste |
| Tile count | ~40 tiles |
| Notable | Volcanic activity; fire-breathing monsters; ancient ruins; extreme heat |

A vast scorched wasteland in the southern reaches. Volcanic vents spew
sulfurous gas, lava flows cut across the terrain, and fire storms sweep
the desert unpredictably.

**Encounters:** Giant scorpions, fire lizards, fire elementals, sandstorms, volcanic eruptions

### Swamps & Wetlands

#### Weaver'sfen

| Property | Value |
|----------|-------|
| Tile(s) | tile_10, tile_11 |
| Map region | Southeastern swamp, cols 26-34, rows 20-26 |
| Terrain | Marsh |
| Tile count | ~30 tiles |
| Notable | Vast swampland; will-o'-wisps; black dragon territory; witch covens |

A massive swamp in the southeastern lowlands.

**Encounters:** Lizardfolk, giant leeches, zombies, will-o'-wisps, black dragon (young), swamp witch

#### Sumalen Land

| Property | Value |
|----------|-------|
| Tile(s) | tile_01 |
| Map region | North-central, cols 12-16, rows 4-6 |
| Terrain | Marsh, boggy lowland |
| Tile count | ~8 tiles |
| Notable | Boggy lowlands between the Ash Waste and the forests |

A boggy transition zone between the Ash Waste and the northern forests.
Travelers crossing Sumalen Land risk becoming mired in its treacherous bogs.

**Encounters:** Giant leeches, will-o'-wisps, bog hazards

### Tundra & Frozen Wastes

#### Frozen Tundra

| Property | Value |
|----------|-------|
| Tile(s) | tile_01, tile_02 |
| Map region | Northern expanse, cols 10-22, rows 0-4 |
| Terrain | Tundra, frozen wasteland |
| Tile count | ~20 tiles |
| Notable | Ice Clan territory; yeti lairs; frost giants |

The frozen northern expanse. Permafrost covers the ground year-round.

**Encounters:** Winter wolves, frost giants, ice goblins, yetis, blizzards, Ice Clan raiders

#### Boreal Reach

| Property | Value |
|----------|-------|
| Tile(s) | tile_03 |
| Map region | Far northeastern frozen coast, cols 28-36, rows 0-6 |
| Terrain | Tundra, ice, coastal |
| Tile count | ~15 tiles |
| Notable | Frozen northeastern peninsula; Maritime Point and Dort settlements |

The frozen northeastern peninsula jutting into the Iceland Sea and Azure
Depths Ocean. Boreal Reach is mostly uninhabited except for the remote
settlements of Maritime Point and Dort.

**Encounters:** Frost giants, winter wolves, blizzards, extreme cold exposure

#### Bovers of the Barrens

| Property | Value |
|----------|-------|
| Tile(s) | tile_02 |
| Map region | North-central highlands, cols 18-24, rows 2-4 |
| Terrain | Barren highland, wind-scoured rock |
| Tile count | ~10 tiles |
| Notable | Desolate highlands between Frozen Tundra and Silver Leaf Wood |

A wind-scoured highland between the Frozen Tundra and the Silver Leaf Wood.
Virtually uninhabited — even the Ice Clans avoid this bleak terrain.

**Encounters:** Griffons, extreme cold, rockslides

### Jungles

#### Amedio Jungle (Tropical Serpentine Jungle)

| Property | Value |
|----------|-------|
| Tile(s) | tile_10 |
| Map region | Southern border, cols 20-28, rows 28-30 |
| Terrain | Dense forest (jungle) |
| Tile count | ~15 tiles |
| Population | ~950,000 scattered across nomadic tribal hunting grounds and hidden tree-cities |
| Power standing | Weak / Target of colonial exploitation |
| Notable | Tribal civilization; blood-gem deposits; lethal asymmetric defense |

The Tropical Serpentine Jungle is far more than unexplored wilderness. Its
indigenous tribes are the direct descendants of an incredibly advanced
prehistoric empire that intentionally shattered its own industrial cities
millennia ago after a catastrophic arcane experiment nearly destroyed the
ecosystem. They chose to return to a primal state to safeguard the planet.
They view the northern foundries and eastern prism towers as a systematic
disease devouring the living world.

Society is entirely symbiotic, tribal, and animistic. There is no concept of
land ownership, currency, or written law. Organization follows matrilineal
clans led by shamans and hunt-masters with deep understanding of botany,
toxicology, and beast taming.

**Major settlements:**
- **The Ruby Citadel** (pop. 110,000) — A breathtaking city built into the
  upper boughs of colossal crimson-leafed trees in the inner jungle. Structures
  of red sandstone and woven living vines suspended hundreds of feet above the
  jungle floor. Illuminated by raw glowing blood-gem veins that pulse in sync
  with the forest.
- **Serpent's Watch** (pop. 35,000) — A crude, heavily fortified settlement on
  the jungle's outer delta, populated by foreign mercenaries, outcasts, and
  bold traders who act as a buffer between the tribes and the civilized world.

**Religion:** Primal animism centering on worship of the Great World Serpent, a
colossal spirit believed to reside in the planet's core.

**Predatory dynamic:** The jungle is a continuous hunting ground for Sunstone
slaving expeditions. Solar mages capture thousands of native hunters annually
to serve as labor or live fuel for their prism towers, sparking unyielding
generational hatred.

**Military:**
- **Serpent Fangs** (~30,000 jungle skirmishers) — Coordinated guerrilla warbands
- **Viper Blowgunners** — Invisible hunters with neurotoxins that liquefy
  internal organs within minutes
- **Blood-Gem Changers** — Elite shamans who temporarily mutate their bodies
  into massive, scale-armored beast-hybrids using primal stones
- They carry no supply lines, living completely off the jungle. They use the
  ecosystem as a weapon — toxic spore clouds, quicksand bogs, apex predator
  nesting territories

**Economy:**
- Strict barter system; uncut blood-gems used only when forced to deal with
  foreign smugglers
- Exports: Rare medicinal panaceas, lethal venom concentrates, unique alchemical
  spores, uncut blood-gems
- Imports: Smuggled steel blades and blocks of cured rock salt

**Quest hooks:**
- **The Defiler's Fortress** — A wealthy logging syndicate backed by Loren
  knights has built a fortified lumber mill within the outer canopy, clear-cutting
  ancient sentient trees. Matriarch Na'Zala tasks adventurers with infiltrating
  the fort and unleashing a captured apex monster inside their barracks.
- **The Rotting Heart** — The primary blood-gem vein beneath the Ruby Citadel has
  begun rotting, turning pitch black and driving local wild beasts into an
  uncontrollable murderous frenzy that threatens to tear the tree-city down.

**Encounters:** Giant snakes, jungle cats, poisonous insects, tribal warriors,
carnivorous plants, Viper Blowgunners, blood-gem beasts

### Named Waterways

#### Bine Nol Erel

| Property | Value |
|----------|-------|
| Tile(s) | tile_01 |
| Map region | North-central, cols 12-16, rows 8-10 |
| Type | River / waterway |
| Notable | River flowing through the northern plains toward the Golden Plains |

A river system flowing south from the northern wastelands through the
transition zone between the Horned Society and the Golden Plains.

#### Dusting of Sand

| Property | Value |
|----------|-------|
| Tile(s) | tile_02 |
| Map region | North-central, cols 20-24, rows 4-6 |
| Type | Sandy wasteland / dry riverbed |
| Notable | Arid strip between Ice Clans territory and Silver Leaf Wood |

---

## 5. Ruins, Dungeons, and Points of Interest

### Ruins of Xanadu

| Property | Value |
|----------|-------|
| Tile(s) | tile_10 (sea ruins), tile_10 (coastal ruins) |
| Map position | col 22, row 24 (sea) and col 18, row 28 (coast) |
| Region | South-central, spanning sea and coast |
| Type | Ancient ruins — split across land and submerged |
| Danger level | High (level 5+) |

The shattered remains of an ancient civilization, split across the
south-central landscape. The ruins appear in two locations on the map:
submerged ruins in the Sea of Gearnat and a coastal ruin site to the south.
This suggests Xanadu was once a massive city that was partially submerged
by rising seas or catastrophic flooding.

**Dungeon levels:**
- **Surface ruins** — Crumbling walls, overgrown plazas, wild animals
- **Upper catacombs** — Skeletons, zombies, trapped corridors
- **Lower catacombs** — Ghouls, wights, ancient guardians
- **Flooded vaults** — Submerged chambers, water-breathing required, legendary treasure
- **Sunken city** — Underwater ruins in the sea, accessible only by magic or diving

**Encounters:** Skeletons, zombies, ghouls, wights, giant spiders, treasure hunters (neutral), sahuagin (underwater)

### Grillo Quallor

| Property | Value |
|----------|-------|
| Tile | tile_07 |
| Map position | col 32, row 16 |
| Region | Sultanate of Khazar, forested interior |
| Type | Fortified settlement or temple complex |
| Danger level | Medium |

A fortified site within the Sultanate of Khazar. Its exact nature is unclear
from the map — possibly a temple complex, fortress, or hidden city within
the dense forest.

### Remadon

| Property | Value |
|----------|-------|
| Tile | tile_03 |
| Map position | col 30, row 4 |
| Region | Boreal Reach, northeastern coast |
| Type | Ruined settlement or fort |

A remote location in the frozen Boreal Reach, possibly a ruined fort or
abandoned settlement.

---

## 6. Trade Routes

### Major Overland Routes

| Route | From | To | Terrain | Danger |
|-------|------|----|---------|--------|
| Western Coast Road | Port of Odyssey | Gradsul | Beach, grassland | Low |
| Central Trade Way | Veluna | Hinwanit | Plains, grassland | Low-Medium |
| Northern Pass | Veluna | Perren Land | Mountain foothills | Medium |
| Spire Crossing | Tusmit | Port of Odyssey | Mountain pass | Medium-High |
| Southern Road | Citesi | Kiranuri | Hills, scrubland | Medium |
| Urnst River Road | Veluna | Duchy of Urnst | River valley | Low |
| Shield Road | Veluna | Shield Lands | Plains | Low-Medium |
| Great Kingdom Highway | Hinwanit | North Province | Forest, grassland | Low |
| Coastal Northeast | Rotik | Dort | Coastal tundra | High |
| Paynim Trail | Port of Odyssey | Anata Krata | Plains, scrubland | Medium |
| Sea Princes Road | Monmurg | Gradsul | Coastal | Low |

### Major Sea Routes

| Route | From | To | Danger |
|-------|------|----|--------|
| Western Passage | Port of Odyssey | Silver Reef Isles | High (reefs) |
| Southern Coast | Port of Odyssey | Gradsul | Low |
| Sea Prince Circuit | Gradsul | Monmurg | Low |
| Eastern Shipping Lane | Rotik | Spindrift Isles | Medium |
| Vanguard Bay Run | North Province ports | Sea Barons | Low-Medium |
| Gearnat Crossing | Ulek ports | Eastern ports | Medium |
| Cinder Passage | Sea of Gearnat | Amedio coast | High (volcanic) |

---

## 7. World Factions

### Major Power Blocs

| Faction | Alignment | Territory | Population | Standing | Strength |
|---------|-----------|-----------|------------|----------|----------|
| Theocracy of Sunstone (Great Kingdom) | Lawful-Evil | Eastern half | 5.2M | Hegemon | 80K legion + 120 warships + magical tech |
| Golden Vales Confederation | Lawful-Neutral | Central-east | 4.5M | Hegemon | 55K infantry + 15K heavy cavalry |
| Amber Plains Hegemony | True Neutral | Central transit | 1.8M | Kingmaker | 15K elite + geographic chokepoints |
| Frozen Coalition | Chaotic-Neutral | Far north | 1.2M | Weak | 22K Rime-Guard + Dark Iron monopoly |
| Obsidian Sea (Sea Princes) | Chaotic-Neutral | Southwestern coast/islands | 1.1M | Kingmaker | 90 warships + obsidian metallurgy |
| Serpentine Jungle Tribes | True Neutral | Southern jungle | 950K | Weak | 30K guerrilla + asymmetric warfare |
| Western Alliance (Zeif, Ekbir, Veluna) | Lawful-Neutral | Western regions | — | Moderate | Trade wealth + moderate military |
| Shield Lands Coalition | Lawful-Good | North-central | — | Defensive | Dedicated military, adventurer haven |
| Bandit Kingdoms / Horned Society | Chaotic-Evil | North-central forests | — | Disruptive | Guerrilla warfare, dark magic |
| The Pomarj | Chaotic-Evil | Southeastern peninsula | — | Raider | Humanoid warbands |
| Sea Barons | Neutral | Eastern islands | — | Naval | Naval mercenaries |

### Continental Currency Table

| Region | Currency | Standard | Notes |
|--------|----------|----------|-------|
| Frozen Coalition | The Shard | Iron slugs backed by ore reserves | |
| Amber Plains | The Aureus | High-purity gold coin | Continental gold standard |
| Golden Vales | The Florin | Silver coin with lily emblem | |
| Theocracy of Sunstone | The Sol | Rectangular gold bar with sun crystal | |
| Obsidian Sea | The Doubloon | Melted/restamped foreign coinage | |
| Serpentine Jungle | Barter | Uncut blood-gems for foreign trade | |

### Tensions and Conflicts

1. **Sunstone vs. Everyone** — The Solar Archon claims divine mandate over the
   entire continent. The Dawn Legion and Solar Invokers make this threat credible.
   Neighboring realms resist, creating constant border friction.

2. **Shield Lands vs. Bandit Kingdoms** — Ongoing low-intensity warfare. The Shield
   Lands hold the line but cannot push into the forests.

3. **Horned Society raids** — Periodic incursions southward into Shield Lands and
   Verna. Dark creatures and humanoid warbands.

4. **Sea Princes vs. Bentand** — Maritime rivalry. Occasional naval skirmishes over
   fishing rights and sea lanes.

5. **Frozen Coalition exploitation** — Southern agricultural cartels create
   artificial famines to force Dark Iron sales at a fraction of their worth.
   Ashtown's labor unrest threatens civil war within the Coalition.

6. **Desolation expansion** — The volcanic wasteland slowly creeps northward,
   threatening southern settlements. The Cinder Archipelago extends this threat
   to sea lanes.

7. **Pomarj raids** — Humanoid warbands from the Pomarj raid northward into Ulek
   and along the Sea of Gearnat coast.

8. **Sunstone slaving expeditions** — The Theocracy captures thousands of jungle
   hunters annually from the Serpentine Jungle to fuel their prism towers,
   sparking generational hatred and jungle guerrilla warfare.

9. **Obsidian counter-measure** — The Sea Princes' obsidian weapons can shatter
   Sunstone's solar shields, creating a fragile deterrence balance between
   the two powers.

10. **Xanatos rising** — Tectonic activity is raising ancient ruins from the sea.
    Every major power is mobilizing to claim the cataclysmic weapons hidden within.

11. **Golden Vales grain leverage** — The Confederation controls the continent's
    most fertile valleys and can starve rival nations through total grain embargoes,
    using food as an absolute political weapon.

---

## 8. Starting Area

New characters spawn at world address `/-190,155`, corresponding to the central
plains near **Veluna**. This provides:

- Immediate access to a lawful-good town with full services (inn, market, smithy, temple)
- Central location with trade routes radiating in all directions
- Moderate-difficulty wilderness in all directions
- Escalating danger: safe Golden Plains nearby, dangerous Silver Leaf Wood to the north, deadly Desolation to the south
- Multiple quest hooks: Shield Lands need adventurers, Bandit Kingdoms need clearing,
  Ruins of Xanadu beckon treasure hunters, Desolation hides ancient secrets, Pomarj
  humanoids threaten the Ulek realms

---

## 9. Macro-Regional Power Blocs

The continent is organized into six macro-regions, each with distinct economic
systems, military doctrines, and internal tensions.

### The Amber Plains Hegemony

| Property | Value |
|----------|-------|
| Tile(s) | tile_04, tile_05 |
| Map region | Central transit corridor, cols 6-18, rows 10-20 |
| Population | ~1,800,000 |
| Power standing | Strategic Neutral / Kingmaker |
| Capital | Crown-Hold (pop. 410,000) |

Limited in overall manpower but completely dominant over continental transit,
taxes, and geographic bottlenecks. The Hegemony's entire identity is anchored
in the Salt-Sea Massacre, a historic conflict where an invading imperial force
was lured into the narrow, trap-laden passes of the Draconic Spine and completely
destroyed without a single hand-to-hand engagement.

**Major settlements:**
- **Crown-Hold** (pop. 410,000) — A colossal fortress city carved into a natural
  sandstone canyon. Travelers and merchant caravans must pass through three
  independent curtain walls, each fifty feet high with automated defense turrets.
  Golden stone architecture glows brilliantly under the savanna sun.
- **Glintstore** (pop. 290,000) — A sprawling oasis city on arid southern
  foothills. A chaotic labyrinth of open-air markets, mud-brick apartments, and
  hidden underworld networks that never sleeps.
- **Volcano's Edge** (pop. 75,000) — A heavily fortified military town around
  the geothermal sluices of the Dragon-Eye Caldera.

**Culture:** Fiercely individualistic, opportunistic, and transactional. Status is
measured purely by wealth and the validity of one's legal contracts. No hereditary
aristocracy; a meritocratic council of wealthy merchants and military officers
governs.

**Religion:** Largely secular. The Keepers of the Coin, a minor cult, views
successful commerce as spiritual virtue and economic poverty as moral failing.

**Societal friction:** The high military caste of Crown-Hold frequently clashes
with the shadowy merchant syndicates of Glintstore. The military demands total
obedience and transparency; the syndicates utilize bribery and covert tunnels
to run a massive parallel black-market economy.

**Military:**
- **Golden Gatekeepers** (~15,000) — Elite, heavily compensated professional infantry
- **Spine Drake-Riders** — High-altitude scouts on domesticated mountain drakes,
  dropping alchemical fire and boulders from above
- **Glintstore Arbalesters** — Infantry with mechanical winch-crossbows capable of
  punching through knightly plate at two hundred paces
- Crown-Hold houses massive subterranean hydroponic chambers and deep artesian
  wells, allowing the city to withstand a decade-long siege

**Economy:**
- Currency: The Aureus (high-purity gold coin; continental gold standard)
- Exports: Refined copper ingots, heat-resistant desert glassware, unearthed
  artifacts, official trade passes
- Imports: Heavy steel plates, luxury foods, raw magical crystals, textiles
- The Spine Toll: Every merchant caravan crossing the continent pays a mandatory
  12% value tax at Crown-Hold, funding high military wages and ensuring they can
  buy out any mercenary company before a rival nation hires them

**Quest hooks:**
- **The Syndicate Siphon** — Sylvia Rossi's syndicate has mapped ancient
  catacombs beneath the Draconic Spine, allowing smuggling rings to move
  contraband tax-free. Gatekeeper Vance will pay any price to destroy this route.
- **The Drake Plague** — A mysterious respiratory rot is spreading through the
  Spine Drake nesting grounds. If the drakes die, the Hegemony loses aerial
  dominance, leaving mountain passes vulnerable to a Sunstone crusade.

### The Golden Vales Confederation

| Property | Value |
|----------|-------|
| Tile(s) | tile_05, tile_06 |
| Map region | Central-eastern fertile valleys, cols 12-28, rows 8-20 |
| Population | ~4,500,000 |
| Power standing | Hegemon / Conventional superpower |
| Capital | Lorenstadt (pop. 850,000) |

The absolute dominant agricultural engine and traditional military force on the
continent. Encompasses the Grand Duchy of Loren, Kingdom of Verna, Duchy and
County of Urnst, and allied territories.

The Confederation was established two centuries ago through the Charter of the
Silver Lily, which united warring duchies under a single High Duke to repel
early southern warlords. Their legacy is one of absolute martial dominance on
open battlefields. However, generations of unchallenged peace have bred
political rot, with rival barons constantly plotting to assassinate the aging
High Duke and seize the throne.

**Additional settlements:**
- **Vitalia** (pop. 520,000) — A hyper-dense river port city on the wide delta
  leading into the Sea of Gearnat. Handles nearly all of the continent's food
  distribution through wooden docks, grain silos, and bustling warehouses.
- **Prelacia** (pop. 140,000) — An independent sanctuary city of archives,
  universities, and grand libraries. Gothic architecture houses mages, scholars,
  and historians who swear vows of political neutrality.

**Culture:** Highly feudal, chivalric, and stratified. Honor, lineage, and land
ownership are the sole metrics of nobility. The upper class values grand feasts,
artistic patronage, and martial prowess in tournaments.

**Religion:** Worship of the Earth Mother, a gentle agricultural deity whose
priesthood ensures soil fertility.

**Class warfare:** Beneath the chivalric exterior lies bitter social conflict.
The autonomous farmlands of the Freeholds are systematically exploited by the
high lords of Lorenstadt, who demand crushing food tithes while providing less
and less protection against southern privateers and eastern raiders.

**Military:**
- **Iron Vanguard** (~55,000) — Professional heavy infantry
- **Shock Heavy Cavalry** (~15,000) — Elite mounted force
- **Knights of the Silver Lily** — Unstoppable heavy shock cavalry in masterwork
  full-plate armor with enchanted lances
- **Pegasus Lancers** — High-mobility aerial knights stationed around Prelacia
  to guard its sacred vaults
- Massive trebuchets, heavy ballistas, and disciplined logistical baggage trains
  allow legions to march across the central plains without running out of supplies

**Economy:**
- Currency: The Florin (high-quality silver coin stamped with a lily emblem)
- Exports: Wheat, barley, livestock, fine vintage wines, masterwork full-plate
  steel armor
- Imports: Dark Iron ore, high-grade raw obsidian, exotic spices, medicinal oils
- Geopolitical leverage: Agricultural blackmail — controlling the continent's
  most fertile river valleys gives them the power to starve rival nations through
  total grain embargoes

**Quest hooks:**
- **The Freehold Grain Strike** — Starving farmers in the Vitalia basin have
  begun hoarding grain in hidden underground silos, preparing an armed rebellion
  against Lorenstadt's tax collectors. Sunstone spies are actively supplying
  them with gold and weapons to fuel the unrest.
- **The Forbidden Scroll** — High Archivist Morwenna has uncovered an ancient
  scroll proving the ruling High Duke's lineage is entirely illegitimate — a
  secret that could break the Confederation into a bloody civil war if leaked.
