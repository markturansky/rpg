INSERT OR IGNORE INTO schema_migrations (version)
VALUES ('20260704000001_baseline_seed_data');

-- Ancestries
INSERT OR IGNORE INTO ancestries (id, name, str_adj, dex_adj, con_adj, int_adj, wis_adj, cha_adj, movement_rate, infravision) VALUES
    ('human',    'Human',    0,  0,  0,  0,  0,  0,  120, 0),
    ('elf',      'Elf',      0,  1, -1,  0,  0,  0,  120, 60),
    ('dwarf',    'Dwarf',    0,  0,  1,  0,  0, -1,  90,  60),
    ('halfling', 'Halfling', -1, 1,  0,  0,  0,  0,  90,  60),
    ('half-elf', 'Half-Elf', 0,  0,  0,  0,  0,  0,  120, 60),
    ('gnome',    'Gnome',    0,  0,  0,  0,  0,  0,  90,  60),
    ('half-orc', 'Half-Orc', 1,  0,  1,  0,  0, -2,  120, 60);

-- Ancestry abilities
INSERT OR IGNORE INTO ancestry_abilities (ancestry_id, ability) VALUES
    ('human',    'no_level_limits'),
    ('human',    'dual_classing'),
    ('elf',      'secret_doors_2in6'),
    ('elf',      'sleep_charm_resist_90'),
    ('dwarf',    'save_bonus_magic_poison'),
    ('dwarf',    'detect_stonework'),
    ('halfling', 'ranged_attack_bonus_3'),
    ('halfling', 'save_bonus_magic'),
    ('half-elf', 'secret_doors'),
    ('half-elf', 'sleep_charm_resist_30'),
    ('gnome',    'save_bonus_magic'),
    ('gnome',    'giant_slayer'),
    ('half-orc', 'all_fighter_types');

-- Classes
INSERT OR IGNORE INTO classes (id, name, hit_die, prime, armor_allowed, shield_allowed, weapons_allowed, gold_dice, gold_die, gold_multiplier) VALUES
    ('fighter',    'Fighter',    10, 'str', 'any',     1, 'any',     5, 4, 10),
    ('cleric',     'Cleric',      8, 'wis', 'any',     1, 'blunt',   3, 6, 10),
    ('magic-user', 'Magic-User',  4, 'int', 'none',    0, 'limited', 2, 4, 10),
    ('thief',      'Thief',       6, 'dex', 'leather', 0, 'limited', 2, 6, 10),
    ('ranger',     'Ranger',     10, 'str', 'any',     1, 'any',     5, 4, 10),
    ('paladin',    'Paladin',    10, 'str', 'any',     1, 'any',     5, 4, 10);

-- Ancestry-Class allowances
INSERT OR IGNORE INTO ancestry_classes (ancestry_id, class_id, level_limit) VALUES
    ('human', 'fighter', NULL), ('human', 'cleric', NULL), ('human', 'magic-user', NULL),
    ('human', 'thief', NULL),   ('human', 'ranger', NULL), ('human', 'paladin', NULL),
    ('elf', 'fighter', 7),      ('elf', 'magic-user', 11), ('elf', 'thief', NULL),
    ('elf', 'ranger', 8),
    ('dwarf', 'fighter', 9),    ('dwarf', 'cleric', 8), ('dwarf', 'thief', NULL),
    ('halfling', 'fighter', 4), ('halfling', 'thief', NULL),
    ('half-elf', 'fighter', NULL), ('half-elf', 'cleric', NULL),
    ('half-elf', 'magic-user', NULL), ('half-elf', 'thief', NULL), ('half-elf', 'ranger', 8),
    ('gnome', 'fighter', 6),    ('gnome', 'cleric', 7), ('gnome', 'thief', NULL),
    ('half-orc', 'fighter', NULL), ('half-orc', 'cleric', 4), ('half-orc', 'thief', NULL);

-- Class minimum scores
INSERT OR IGNORE INTO class_min_scores (class_id, ability, minimum) VALUES
    ('fighter', 'str', 9), ('fighter', 'con', 7),
    ('cleric', 'wis', 9),
    ('magic-user', 'int', 9),
    ('thief', 'dex', 9),
    ('ranger', 'str', 13), ('ranger', 'int', 13), ('ranger', 'wis', 14), ('ranger', 'con', 14),
    ('paladin', 'str', 12), ('paladin', 'con', 9), ('paladin', 'int', 9),
    ('paladin', 'wis', 13), ('paladin', 'cha', 17);

-- Saving throws
INSERT OR IGNORE INTO saving_throws (class_id, min_level, max_level, aimed, breath, death, petrify, spells) VALUES
    ('fighter', 1, 2, 14, 15, 12, 13, 16),
    ('fighter', 3, 4, 13, 14, 11, 12, 15),
    ('fighter', 5, 6, 11, 11, 9, 10, 13),
    ('fighter', 7, 8, 10, 10, 8, 9, 12),
    ('fighter', 9, 10, 8, 8, 6, 7, 10),
    ('cleric', 1, 3, 11, 16, 10, 13, 15),
    ('cleric', 4, 6, 9, 14, 8, 11, 13),
    ('cleric', 7, 9, 7, 12, 6, 9, 11),
    ('thief', 1, 4, 14, 16, 13, 12, 15),
    ('thief', 5, 8, 12, 15, 12, 11, 13),
    ('thief', 9, 12, 10, 14, 11, 10, 11),
    ('magic-user', 1, 5, 11, 15, 14, 13, 12),
    ('magic-user', 6, 10, 9, 13, 13, 11, 10),
    ('ranger', 1, 2, 14, 15, 12, 13, 16),
    ('ranger', 3, 4, 13, 14, 11, 12, 15),
    ('ranger', 5, 6, 11, 11, 9, 10, 13),
    ('ranger', 7, 8, 10, 10, 8, 9, 12),
    ('ranger', 9, 10, 8, 8, 6, 7, 10),
    ('paladin', 1, 2, 12, 13, 10, 11, 14),
    ('paladin', 3, 4, 11, 12, 9, 10, 13),
    ('paladin', 5, 6, 9, 9, 7, 8, 11),
    ('paladin', 7, 8, 8, 8, 6, 7, 10),
    ('paladin', 9, 10, 6, 6, 4, 5, 8);

-- BTHB progression
INSERT OR IGNORE INTO bthb_progression (class_id, level, bonus) VALUES
    ('fighter', 1, 1), ('fighter', 2, 2), ('fighter', 3, 3), ('fighter', 4, 4),
    ('fighter', 5, 5), ('fighter', 6, 6), ('fighter', 7, 7), ('fighter', 8, 8), ('fighter', 9, 9),
    ('cleric', 1, 0), ('cleric', 2, 0), ('cleric', 3, 1), ('cleric', 4, 2),
    ('cleric', 5, 2), ('cleric', 6, 3), ('cleric', 7, 4), ('cleric', 8, 4), ('cleric', 9, 5),
    ('thief', 1, 0), ('thief', 2, 0), ('thief', 3, 1), ('thief', 4, 1),
    ('thief', 5, 2), ('thief', 6, 2), ('thief', 7, 4), ('thief', 8, 4), ('thief', 9, 5),
    ('magic-user', 1, 0), ('magic-user', 2, 0), ('magic-user', 3, 1), ('magic-user', 4, 1),
    ('magic-user', 5, 2), ('magic-user', 6, 2), ('magic-user', 7, 3), ('magic-user', 8, 3), ('magic-user', 9, 4),
    ('ranger', 1, 1), ('ranger', 2, 2), ('ranger', 3, 3), ('ranger', 4, 4),
    ('ranger', 5, 5), ('ranger', 6, 6), ('ranger', 7, 7), ('ranger', 8, 8), ('ranger', 9, 9),
    ('paladin', 1, 1), ('paladin', 2, 2), ('paladin', 3, 3), ('paladin', 4, 4),
    ('paladin', 5, 5), ('paladin', 6, 6), ('paladin', 7, 7), ('paladin', 8, 8), ('paladin', 9, 9);

-- XP tables
INSERT OR IGNORE INTO xp_table (class_id, level, xp_required, title) VALUES
    ('fighter', 1, 0, 'Veteran'), ('fighter', 2, 2000, 'Warrior'), ('fighter', 3, 4000, 'Swordsman'),
    ('fighter', 4, 8000, 'Hero'), ('fighter', 5, 16000, 'Swashbuckler'), ('fighter', 6, 32000, 'Myrmidon'),
    ('fighter', 7, 64000, 'Champion'), ('fighter', 8, 125000, 'Superhero'), ('fighter', 9, 250000, 'Lord'),
    ('cleric', 1, 0, 'Acolyte'), ('cleric', 2, 1500, 'Adept'), ('cleric', 3, 3000, 'Priest'),
    ('cleric', 4, 6000, 'Curate'), ('cleric', 5, 12000, 'Prefect'), ('cleric', 6, 25000, 'Canon'),
    ('cleric', 7, 50000, 'Lama'), ('cleric', 8, 100000, 'Matriarch'), ('cleric', 9, 200000, 'Patriarch'),
    ('magic-user', 1, 0, 'Prestidigitator'), ('magic-user', 2, 2500, 'Evoker'), ('magic-user', 3, 5000, 'Conjurer'),
    ('magic-user', 4, 10000, 'Theurgist'), ('magic-user', 5, 20000, 'Thaumaturgist'), ('magic-user', 6, 40000, 'Magician'),
    ('magic-user', 7, 60000, 'Enchanter'), ('magic-user', 8, 90000, 'Warlock'), ('magic-user', 9, 135000, 'Sorcerer'),
    ('thief', 1, 0, 'Apprentice'), ('thief', 2, 1250, 'Footpad'), ('thief', 3, 2500, 'Robber'),
    ('thief', 4, 5000, 'Burglar'), ('thief', 5, 10000, 'Sharper'), ('thief', 6, 20000, 'Pilferer'),
    ('thief', 7, 40000, 'Master Pilferer'), ('thief', 8, 60000, 'Thief'), ('thief', 9, 90000, 'Master Thief'),
    ('ranger', 1, 0, 'Runner'), ('ranger', 2, 2000, 'Strider'), ('ranger', 3, 4000, 'Scout'),
    ('ranger', 4, 8000, 'Guide'), ('ranger', 5, 16000, 'Pathfinder'), ('ranger', 6, 32000, 'Warden'),
    ('ranger', 7, 64000, 'Guardian'), ('ranger', 8, 125000, 'Ranger Knight'), ('ranger', 9, 250000, 'Ranger Lord'),
    ('paladin', 1, 0, 'Gallant'), ('paladin', 2, 2000, 'Keeper'), ('paladin', 3, 4000, 'Protector'),
    ('paladin', 4, 8000, 'Defender'), ('paladin', 5, 16000, 'Warder'), ('paladin', 6, 32000, 'Guardian'),
    ('paladin', 7, 64000, 'Chevalier'), ('paladin', 8, 125000, 'Justiciar'), ('paladin', 9, 250000, 'Paladin');

-- Spell slots (Magic-User)
INSERT OR IGNORE INTO spell_slots (class_id, caster_level, spell_level, slots) VALUES
    ('magic-user', 1, 1, 1),
    ('magic-user', 2, 1, 2),
    ('magic-user', 3, 1, 2), ('magic-user', 3, 2, 1),
    ('magic-user', 4, 1, 3), ('magic-user', 4, 2, 2),
    ('magic-user', 5, 1, 3), ('magic-user', 5, 2, 2), ('magic-user', 5, 3, 1);

-- Spell slots (Cleric)
INSERT OR IGNORE INTO spell_slots (class_id, caster_level, spell_level, slots) VALUES
    ('cleric', 1, 1, 1),
    ('cleric', 2, 1, 2),
    ('cleric', 3, 1, 2), ('cleric', 3, 2, 1),
    ('cleric', 4, 1, 3), ('cleric', 4, 2, 2),
    ('cleric', 5, 1, 3), ('cleric', 5, 2, 2), ('cleric', 5, 3, 1);

-- Weapons
INSERT OR IGNORE INTO weapons (id, name, damage_sm_count, damage_sm_die, damage_sm_bonus, damage_lg_count, damage_lg_die, damage_lg_bonus, weight, cost, type, thrown, attacks_per_round) VALUES
    ('dagger',          'Dagger',          1, 4, 0, 1, 3,  0, 1,    2,    'melee',  1, 1.0),
    ('short-sword',     'Short Sword',     1, 6, 0, 1, 8,  0, 3,    8,    'melee',  0, 1.0),
    ('longsword',       'Longsword',       1, 8, 0, 1, 12, 0, 6,    15,   'melee',  0, 1.0),
    ('two-handed-sword','Two-Handed Sword',1, 10,0, 3, 6,  0, 15,   30,   'melee',  0, 1.0),
    ('battle-axe',      'Battle Axe',      1, 8, 0, 1, 8,  0, 7,    5,    'melee',  0, 1.0),
    ('mace',            'Mace',            1, 6, 1, 1, 6,  0, 5,    8,    'melee',  0, 1.0),
    ('morning-star',    'Morning Star',    2, 4, 0, 1, 6,  1, 12,   5,    'melee',  0, 1.0),
    ('staff',           'Staff',           1, 6, 0, 1, 6,  0, 4,    0,    'melee',  0, 1.0),
    ('short-bow',       'Short Bow',       1, 6, 0, 1, 6,  0, 2,    15,   'ranged', 0, 2.0),
    ('longbow',         'Longbow',         1, 6, 0, 1, 6,  0, 3,    60,   'ranged', 0, 2.0),
    ('light-crossbow',  'Light Crossbow',  1, 4, 1, 1, 4,  1, 5,    12,   'ranged', 0, 1.0),
    ('heavy-crossbow',  'Heavy Crossbow',  1, 6, 1, 1, 6,  1, 8,    20,   'ranged', 0, 0.5),
    ('sling',           'Sling',           1, 4, 1, 1, 6,  1, 0.5,  0.5,  'ranged', 0, 1.0);

-- Armor
INSERT OR IGNORE INTO armor (id, name, ac, weight, cost, move_cap) VALUES
    ('unarmored',       'Unarmored',        10, 0,   0,   120),
    ('leather',         'Leather',          12, 15,  5,   120),
    ('studded-leather', 'Studded Leather',  13, 20,  15,  120),
    ('scale-mail',      'Scale Mail',       14, 40,  45,  60),
    ('chain-mail',      'Chain Mail',       15, 30,  75,  90),
    ('banded-mail',     'Banded Mail',      16, 35,  200, 90),
    ('plate-mail',      'Plate Mail',       17, 45,  400, 60);

-- Shields
INSERT OR IGNORE INTO shields (id, name, ac_bonus, weight, cost) VALUES
    ('small-shield', 'Small Shield', 1, 5,  10),
    ('large-shield', 'Large Shield', 1, 10, 15);

-- Items
INSERT OR IGNORE INTO items (id, name, effect, cost, weight) VALUES
    ('healing-potion',  'Healing Potion',    '2d4+2 HP',                      50,    0.5),
    ('antidote',        'Antidote',          'Cure poison',                    25,    0.5),
    ('rations',         'Rations (1 day)',   'Prevent starvation',             1,     1),
    ('torch',           'Torch',             '40 ft light, 6 turns',           0.01,  1),
    ('lantern',         'Lantern',           '80 ft beam, 24 turns',           12,    2),
    ('oil-flask',       'Oil Flask',         'Fuel lantern or 2d6 fire',       1,     1),
    ('rope-50ft',       'Rope (50 ft)',      'Climbing, binding',              1,     5),
    ('10ft-pole',       '10 ft Pole',        'Trap detection',                 0.2,   8),
    ('holy-water',      'Holy Water',        '2d4 vs undead (thrown)',          25,    0.5),
    ('thieves-tools',   'Thieves'' Tools',   'Required for lock/trap skills',  30,    1),
    ('arrows-20',       'Arrows (20)',       'Bow ammunition',                 5,     1),
    ('bolts-20',        'Bolts (20)',        'Crossbow ammunition',            5,     1);

-- Starting equipment
INSERT OR IGNORE INTO starting_equipment (class_id, item_type, item_id, quantity) VALUES
    ('fighter', 'armor', 'chain-mail', 1),
    ('fighter', 'shield', 'small-shield', 1),
    ('fighter', 'weapon', 'longsword', 1),
    ('cleric', 'armor', 'chain-mail', 1),
    ('cleric', 'shield', 'small-shield', 1),
    ('cleric', 'weapon', 'mace', 1),
    ('magic-user', 'weapon', 'dagger', 1),
    ('magic-user', 'weapon', 'staff', 1),
    ('thief', 'armor', 'leather', 1),
    ('thief', 'weapon', 'short-sword', 1),
    ('thief', 'weapon', 'dagger', 1),
    ('thief', 'item', 'thieves-tools', 1),
    ('ranger', 'armor', 'chain-mail', 1),
    ('ranger', 'weapon', 'longsword', 1),
    ('ranger', 'weapon', 'longbow', 1),
    ('ranger', 'item', 'arrows-20', 1),
    ('paladin', 'armor', 'chain-mail', 1),
    ('paladin', 'shield', 'small-shield', 1),
    ('paladin', 'weapon', 'longsword', 1);

-- Terrain
INSERT OR IGNORE INTO terrain (id, name, color, move_cost, lost_chance, vision_range, encounter_freq) VALUES
    ('shallow-water', 'Shallow Water', '#1a5276', 999.0, 0, 2, '0'),
    ('deep-water',   'Deep Water',   '#0e3d5c', 999.0, 0, 2, '0'),
    ('plains',       'Plains',       '#a8c256', 1.0,   1, 3, '1-in-6'),
    ('grassland',    'Grassland',    '#7daa4e', 1.0,   1, 2, '1-in-6'),
    ('forest',       'Forest',       '#2d6a1e', 1.5,   2, 1, '1-in-6'),
    ('dense-forest', 'Dense Forest', '#1a4712', 2.0,   3, 1, '1-in-6'),
    ('hills',        'Hills',        '#8b7d3c', 1.5,   2, 4, '1-in-6'),
    ('mountain',     'Mountain',     '#6b6b6b', 3.0,   3, 6, '1-in-8'),
    ('desert',       'Desert',       '#d4b94e', 1.5,   3, 3, '1-in-6'),
    ('marsh',        'Marsh',        '#4a6741', 2.0,   3, 2, '1-in-6'),
    ('tundra',       'Tundra',       '#b8c8d4', 2.0,   0, 2, '1-in-6'),
    ('beach',        'Beach',        '#e8d5a3', 1.0,   0, 2, '1-in-8'),
    ('road',         'Road',         '#8b7355', 0.75,  0, 3, '1-in-8'),
    ('river',        'River',        '#2980b9', 999.0, 0, 2, '0');

-- Monsters
INSERT OR IGNORE INTO monsters (id, name, hit_dice_count, hit_dice_bonus, xp, ac, morale, size, attacks, damage, special) VALUES
    ('bandit',          'Bandit',           1, 0,  100,  12, 50,  'M', '1 weapon',   '1d6',    NULL),
    ('wolf',            'Wolf',             2, 1,  150,  13, 55,  'M', '1 bite',     '1d4+1',  NULL),
    ('wild-horse',      'Wild Horse',       2, 0,  50,   13, 40,  'L', '1 hoof',     '1d6',    'Can be tamed'),
    ('goblin',          'Goblin',           1,-1,  75,   11, 45,  'S', '1 weapon',   '1d6',    NULL),
    ('ogre',            'Ogre',             4, 1,  500,  14, 60,  'L', '1 club',     '1d10',   NULL),
    ('giant-spider',    'Giant Spider',     2, 1,  175,  12, 50,  'M', '1 bite',     '1d6',    'Poison (save or 2d6)'),
    ('orc',             'Orc',              1, 0,  100,  11, 50,  'M', '1 weapon',   '1d8',    NULL),
    ('owlbear',         'Owlbear',          5, 2,  600,  14, 65,  'L', '3 (claw/claw/bite)', '1d6/1d6/2d6', 'Hug for 2d8'),
    ('skeleton',        'Skeleton',         1, 0,  100,  13, 100, 'M', '1 weapon',   '1d6',    'Undead, half damage from edged'),
    ('treant',          'Treant',           8, 0,  1200, 18, 70,  'L', '2 branches', '2d6/2d6','Animate trees'),
    ('mountain-lion',   'Mountain Lion',    3, 1,  250,  14, 55,  'M', '3 (claw/claw/bite)', '1d3/1d3/1d6', NULL),
    ('kobold',          'Kobold',           0, 1,  50,   11, 40,  'S', '1 weapon',   '1d4',    NULL),
    ('hill-giant',      'Hill Giant',       8, 2,  1200, 16, 70,  'L', '1 club',     '2d8',    'Throw boulders 2d6'),
    ('hobgoblin',       'Hobgoblin',        1, 1,  120,  14, 55,  'M', '1 weapon',   '1d8',    NULL),
    ('harpy',           'Harpy',            3, 0,  300,  13, 50,  'M', '2 talons + song', '1d4/1d4', 'Charm song (save negates)'),
    ('griffon',         'Griffon',          7, 0,  900,  17, 60,  'L', '3 (claw/claw/bite)', '1d4/1d4/2d8', 'Flying'),
    ('giant-scorpion',  'Giant Scorpion',   4, 0,  400,  17, 55,  'M', '3 (claw/claw/sting)', '1d4/1d4/1d4', 'Poison sting (save or die)'),
    ('nomad',           'Nomad',            1, 0,  100,  12, 50,  'M', '1 weapon',   '1d6',    NULL),
    ('sphinx',          'Sphinx',           6, 0,  800,  19, 70,  'L', '2 claws',    '2d4/2d4','Riddle (INT check or combat)'),
    ('giant-lizard',    'Giant Lizard',     3, 1,  250,  14, 50,  'M', '1 bite',     '1d8',    NULL),
    ('lizardfolk',      'Lizardfolk',       2, 1,  175,  14, 55,  'M', '1 weapon + tail', '1d6/1d4', NULL),
    ('young-black-dragon','Black Dragon (Young)',6,1,1000,18, 80, 'L', '3 (claw/claw/bite)', '1d4/1d4/3d6', 'Acid breath 6d4 (save half)'),
    ('giant-leech',     'Giant Leech',      2, 0,  125,  12, 100, 'M', '1 bite',     '1d4',    'Drain 1 HP/round after hit'),
    ('will-o-wisp',     'Will-o''-Wisp',    9, 0,  1500, 20, 100, 'S', '1 shock',    '2d6',    'Only hit by magic, lure'),
    ('zombie',          'Zombie',           2, 0,  150,  12, 100, 'M', '1 slam',     '1d8',    'Undead, always last initiative'),
    ('winter-wolf',     'Winter Wolf',      6, 0,  700,  14, 60,  'M', '1 bite',     '2d4',    'Cold breath 4d4 (save half)'),
    ('frost-giant',     'Frost Giant',     10, 1,  2000, 16, 75,  'L', '1 weapon',   '4d6',    'Throw boulders 2d10, cold immune'),
    ('ice-goblin',      'Ice Goblin',       1, 0,  100,  12, 45,  'S', '1 weapon',   '1d6',    'Cold resist'),
    ('yeti',            'Yeti',             4, 4,  550,  14, 65,  'L', '2 claws',    '1d6/1d6','Hug 2d8, cold immune'),
    ('sahuagin',        'Sahuagin',         2, 1,  175,  14, 55,  'M', '1 weapon + bite', '1d6/1d4', 'Underwater advantage'),
    ('giant-crab',      'Giant Crab',       3, 0,  250,  17, 50,  'M', '2 claws',    '1d6/1d6','Crush'),
    ('sea-hag',         'Sea Hag',          3, 0,  300,  13, 60,  'M', '2 claws',    '1d4/1d4','Evil eye (save or -2 to attacks)'),
    ('merfolk',         'Merfolk',          1, 1,  75,   13, 50,  'M', '1 weapon',   '1d6',    'Peaceful, traders');

-- Encounter tables: Plains/Grassland
INSERT OR IGNORE INTO encounter_tables (terrain_id, roll_value, monster_id, count_dice, count_die, xp_override, notes) VALUES
    ('plains', 1, 'bandit',      2, 4, NULL, NULL),
    ('plains', 2, 'wolf',        1, 6, NULL, NULL),
    ('plains', 3, NULL,          0, 0, 0,    'Merchant caravan - trade opportunity'),
    ('plains', 4, 'wild-horse',  1, 4, 0,    'Can be tamed'),
    ('plains', 5, NULL,          0, 0, 0,    'Wandering Cleric - offers healing'),
    ('plains', 6, 'goblin',      2, 6, NULL, NULL),
    ('plains', 7, 'ogre',        1, 1, NULL, NULL),
    ('plains', 8, NULL,          0, 0, 0,    'Traveling Bard - shares rumors'),
    ('grassland', 1, 'bandit',   2, 4, NULL, NULL),
    ('grassland', 2, 'wolf',     1, 6, NULL, NULL),
    ('grassland', 3, NULL,       0, 0, 0,    'Merchant caravan - trade opportunity'),
    ('grassland', 4, 'wild-horse',1,4, 0,    'Can be tamed'),
    ('grassland', 5, NULL,       0, 0, 0,    'Wandering Cleric - offers healing'),
    ('grassland', 6, 'goblin',   2, 6, NULL, NULL),
    ('grassland', 7, 'ogre',     1, 1, NULL, NULL),
    ('grassland', 8, NULL,       0, 0, 0,    'Traveling Bard - shares rumors');

-- Encounter tables: Forest/Dense Forest
INSERT OR IGNORE INTO encounter_tables (terrain_id, roll_value, monster_id, count_dice, count_die, xp_override, notes) VALUES
    ('forest', 1, 'giant-spider', 1, 6, NULL, NULL),
    ('forest', 2, 'orc',          2, 4, NULL, NULL),
    ('forest', 3, 'owlbear',      1, 1, NULL, NULL),
    ('forest', 4, 'wolf',         1, 4, NULL, NULL),
    ('forest', 5, NULL,           0, 0, 0,    'Wood Elf patrol - trade/info'),
    ('forest', 6, 'skeleton',     1, 6, NULL, NULL),
    ('forest', 7, 'treant',       1, 1, 0,    'Neutral - may help or hinder'),
    ('forest', 8, NULL,           0, 0, 0,    'Hermit - offers quest'),
    ('dense-forest', 1, 'giant-spider', 1, 6, NULL, NULL),
    ('dense-forest', 2, 'orc',         2, 4, NULL, NULL),
    ('dense-forest', 3, 'owlbear',     1, 1, NULL, NULL),
    ('dense-forest', 4, 'wolf',        1, 4, NULL, NULL),
    ('dense-forest', 5, NULL,          0, 0, 0,    'Wood Elf patrol - trade/info'),
    ('dense-forest', 6, 'skeleton',    1, 6, NULL, NULL),
    ('dense-forest', 7, 'treant',      1, 1, 0,    'Neutral - may help or hinder'),
    ('dense-forest', 8, NULL,          0, 0, 0,    'Hermit - offers quest');

-- Encounter tables: Hills/Mountain
INSERT OR IGNORE INTO encounter_tables (terrain_id, roll_value, monster_id, count_dice, count_die, xp_override, notes) VALUES
    ('hills', 1, 'mountain-lion', 1, 4, NULL, NULL),
    ('hills', 2, 'kobold',        2, 4, NULL, NULL),
    ('hills', 3, 'hill-giant',    1, 1, NULL, NULL),
    ('hills', 4, 'hobgoblin',     1, 6, NULL, NULL),
    ('hills', 5, NULL,            0, 0, 0,    'Dwarven miners - trade'),
    ('hills', 6, 'harpy',         1, 4, NULL, NULL),
    ('hills', 7, 'griffon',       1, 1, NULL, NULL),
    ('hills', 8, NULL,            0, 0, 0,    'Rockslide - DEX save or 2d6 damage'),
    ('mountain', 1, 'mountain-lion', 1, 4, NULL, NULL),
    ('mountain', 2, 'kobold',       2, 4, NULL, NULL),
    ('mountain', 3, 'hill-giant',   1, 1, NULL, NULL),
    ('mountain', 4, 'hobgoblin',    1, 6, NULL, NULL),
    ('mountain', 5, NULL,           0, 0, 0,    'Dwarven miners - trade'),
    ('mountain', 6, 'harpy',        1, 4, NULL, NULL),
    ('mountain', 7, 'griffon',      1, 1, NULL, NULL),
    ('mountain', 8, NULL,           0, 0, 0,    'Rockslide - DEX save or 2d6 damage');

-- Encounter tables: Desert
INSERT OR IGNORE INTO encounter_tables (terrain_id, roll_value, monster_id, count_dice, count_die, xp_override, notes) VALUES
    ('desert', 1, 'giant-scorpion', 1, 4, NULL, NULL),
    ('desert', 2, 'nomad',          2, 6, NULL, NULL),
    ('desert', 3, 'sphinx',         1, 1, NULL, NULL),
    ('desert', 4, NULL,             0, 0, 0,    'Sandstorm - CON save or lose 1d4 HP'),
    ('desert', 5, NULL,             0, 0, 0,    'Oasis - rest and recover'),
    ('desert', 6, 'giant-lizard',   1, 4, NULL, NULL);

-- Encounter tables: Marsh
INSERT OR IGNORE INTO encounter_tables (terrain_id, roll_value, monster_id, count_dice, count_die, xp_override, notes) VALUES
    ('marsh', 1, 'lizardfolk',       2, 4, NULL, NULL),
    ('marsh', 2, 'young-black-dragon',1,1, NULL, NULL),
    ('marsh', 3, 'giant-leech',      1, 6, NULL, NULL),
    ('marsh', 4, 'will-o-wisp',      1, 1, NULL, NULL),
    ('marsh', 5, NULL,               0, 0, 0,    'Swamp Witch - sells potions'),
    ('marsh', 6, 'zombie',           1, 8, NULL, NULL);

-- Encounter tables: Tundra
INSERT OR IGNORE INTO encounter_tables (terrain_id, roll_value, monster_id, count_dice, count_die, xp_override, notes) VALUES
    ('tundra', 1, 'winter-wolf', 1, 4, NULL, NULL),
    ('tundra', 2, 'frost-giant', 1, 1, NULL, NULL),
    ('tundra', 3, 'ice-goblin',  2, 4, NULL, NULL),
    ('tundra', 4, NULL,          0, 0, 0,    'Blizzard - CON save or lose 1d6 HP'),
    ('tundra', 5, NULL,          0, 0, 0,    'Frozen traveler - find 1d6x10 GP'),
    ('tundra', 6, 'yeti',        1, 1, NULL, NULL);

-- Encounter tables: Road
INSERT OR IGNORE INTO encounter_tables (terrain_id, roll_value, monster_id, count_dice, count_die, xp_override, notes) VALUES
    ('road', 1, NULL,    0, 0, 0,    'Merchant - shop opportunity'),
    ('road', 2, 'bandit',2, 4, NULL, NULL),
    ('road', 3, NULL,    0, 0, 0,    'Patrol guards - information'),
    ('road', 4, NULL,    0, 0, 0,    'Pilgrim - offers quest'),
    ('road', 5, NULL,    0, 0, 0,    'Broken wagon - variable loot'),
    ('road', 6, NULL,    0, 0, 0,    'Nothing');

-- Encounter tables: Beach
INSERT OR IGNORE INTO encounter_tables (terrain_id, roll_value, monster_id, count_dice, count_die, xp_override, notes) VALUES
    ('beach', 1, 'sahuagin',    1, 6, NULL, NULL),
    ('beach', 2, 'giant-crab',  1, 1, NULL, NULL),
    ('beach', 3, NULL,          0, 0, 0,    'Shipwreck debris - find 2d6x10 GP'),
    ('beach', 4, 'sea-hag',     1, 1, NULL, NULL),
    ('beach', 5, NULL,          0, 0, 0,    'Fisherman - shares rumors'),
    ('beach', 6, 'merfolk',     1, 4, 0,    'Peaceful traders');

-- Ability modifiers: Strength
INSERT OR IGNORE INTO ability_mods (ability, score_min, score_max, to_hit, damage, ac_mod, hp_mod, hp_mod_fighter, encumbrance, surprise, max_henchmen, loyalty_pct, reaction_pct) VALUES
    ('str', 3,  3,  -3, -1, 0, 0, 0, 0,   0, 0, 0, 0),
    ('str', 4,  5,  -2, -1, 0, 0, 0, 0,   0, 0, 0, 0),
    ('str', 6,  7,  -1,  0, 0, 0, 0, 0,   0, 0, 0, 0),
    ('str', 8,  9,   0,  0, 0, 0, 0, 0,   0, 0, 0, 0),
    ('str', 10, 11,  0,  0, 0, 0, 0, 0,   0, 0, 0, 0),
    ('str', 12, 13,  0,  0, 0, 0, 0, 10,  0, 0, 0, 0),
    ('str', 14, 15,  0,  0, 0, 0, 0, 20,  0, 0, 0, 0),
    ('str', 16, 16,  0,  1, 0, 0, 0, 35,  0, 0, 0, 0),
    ('str', 17, 17,  1,  1, 0, 0, 0, 50,  0, 0, 0, 0),
    ('str', 18, 18,  1,  2, 0, 0, 0, 75,  0, 0, 0, 0);

-- Ability modifiers: Dexterity
INSERT OR IGNORE INTO ability_mods (ability, score_min, score_max, to_hit, damage, ac_mod, hp_mod, hp_mod_fighter, encumbrance, surprise, max_henchmen, loyalty_pct, reaction_pct) VALUES
    ('dex', 3,  3,  -3, 0, -4, 0, 0, 0, -3, 0, 0, 0),
    ('dex', 4,  5,  -2, 0, -2, 0, 0, 0, -2, 0, 0, 0),
    ('dex', 6,  6,  -1, 0, -1, 0, 0, 0, -1, 0, 0, 0),
    ('dex', 7,  14,  0, 0,  0, 0, 0, 0,  0, 0, 0, 0),
    ('dex', 15, 15,  0, 0,  1, 0, 0, 0,  0, 0, 0, 0),
    ('dex', 16, 16,  1, 0,  2, 0, 0, 0,  1, 0, 0, 0),
    ('dex', 17, 17,  2, 0,  3, 0, 0, 0,  2, 0, 0, 0),
    ('dex', 18, 18,  3, 0,  4, 0, 0, 0,  3, 0, 0, 0);

-- Ability modifiers: Constitution
INSERT OR IGNORE INTO ability_mods (ability, score_min, score_max, to_hit, damage, ac_mod, hp_mod, hp_mod_fighter, encumbrance, surprise, max_henchmen, loyalty_pct, reaction_pct) VALUES
    ('con', 3,  3,   0, 0, 0, -2, -2, 0, 0, 0, 0, 0),
    ('con', 4,  6,   0, 0, 0, -1, -1, 0, 0, 0, 0, 0),
    ('con', 7,  14,  0, 0, 0,  0,  0, 0, 0, 0, 0, 0),
    ('con', 15, 16,  0, 0, 0,  1,  1, 0, 0, 0, 0, 0),
    ('con', 17, 17,  0, 0, 0,  2,  3, 0, 0, 0, 0, 0),
    ('con', 18, 18,  0, 0, 0,  2,  4, 0, 0, 0, 0, 0);

-- Ability modifiers: Charisma
INSERT OR IGNORE INTO ability_mods (ability, score_min, score_max, to_hit, damage, ac_mod, hp_mod, hp_mod_fighter, encumbrance, surprise, max_henchmen, loyalty_pct, reaction_pct) VALUES
    ('cha', 3,  3,   0, 0, 0, 0, 0, 0, 0, 1,  -30, -25),
    ('cha', 4,  5,   0, 0, 0, 0, 0, 0, 0, 1,  -25, -20),
    ('cha', 6,  7,   0, 0, 0, 0, 0, 0, 0, 2,  -15, -10),
    ('cha', 8,  8,   0, 0, 0, 0, 0, 0, 0, 3,  -10, -10),
    ('cha', 9,  11,  0, 0, 0, 0, 0, 0, 0, 4,   0,   0),
    ('cha', 12, 12,  0, 0, 0, 0, 0, 0, 0, 5,   0,   0),
    ('cha', 13, 14,  0, 0, 0, 0, 0, 0, 0, 5,   5,   5),
    ('cha', 15, 15,  0, 0, 0, 0, 0, 0, 0, 7,  15,  15),
    ('cha', 16, 16,  0, 0, 0, 0, 0, 0, 0, 8,  20,  20),
    ('cha', 17, 17,  0, 0, 0, 0, 0, 0, 0, 10, 30,  25),
    ('cha', 18, 18,  0, 0, 0, 0, 0, 0, 0, 15, 40,  35);

-- Ability modifiers: Intelligence (minimal - languages)
INSERT OR IGNORE INTO ability_mods (ability, score_min, score_max, to_hit, damage, ac_mod, hp_mod, hp_mod_fighter, encumbrance, surprise, max_henchmen, loyalty_pct, reaction_pct) VALUES
    ('int', 3,  7,   0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    ('int', 8,  11,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    ('int', 12, 14,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    ('int', 15, 16,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    ('int', 17, 18,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

-- Ability modifiers: Wisdom (cleric spell bonus tracked via spell_slots)
INSERT OR IGNORE INTO ability_mods (ability, score_min, score_max, to_hit, damage, ac_mod, hp_mod, hp_mod_fighter, encumbrance, surprise, max_henchmen, loyalty_pct, reaction_pct) VALUES
    ('wis', 3,  7,   0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    ('wis', 8,  14,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    ('wis', 15, 16,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    ('wis', 17, 18,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

-- Spells: Magic-User
INSERT OR IGNORE INTO spells (id, name, class_id, level, effect, damage, duration, range, save_type, casting_time) VALUES
    ('magic-missile',  'Magic Missile',  'magic-user', 1, 'Auto-hit, +1 missile at levels 3 and 5', '1d4+1 per missile', 'Instant', '150 ft', NULL, 1),
    ('sleep',          'Sleep',          'magic-user', 1, '2d8 HD of creatures fall asleep', NULL, '5 rounds/level', '30 ft', NULL, 1),
    ('shield',         'Shield',         'magic-user', 1, '+4 AC for the encounter', NULL, '1 encounter', 'Self', NULL, 1),
    ('web',            'Web',            'magic-user', 2, 'Immobilize enemies', NULL, '1d4 rounds', '30 ft', 'petrify', 2),
    ('mirror-image',   'Mirror Image',   'magic-user', 2, '1d4 illusory duplicates absorb attacks', NULL, '3 rounds/level', 'Self', NULL, 2),
    ('invisibility',   'Invisibility',   'magic-user', 2, 'Invisible until attacking, guaranteed surprise round', NULL, 'Until attack', 'Touch', NULL, 2),
    ('fireball',       'Fireball',       'magic-user', 3, 'Area damage, save for half', '6d6', 'Instant', '150 ft', 'breath', 3),
    ('lightning-bolt', 'Lightning Bolt', 'magic-user', 3, 'Line damage, save for half', '6d6', 'Instant', '150 ft', 'breath', 3),
    ('haste',          'Haste',          'magic-user', 3, 'Double attacks for 3 rounds', NULL, '3 rounds', '60 ft', NULL, 3);

-- Spells: Cleric
INSERT OR IGNORE INTO spells (id, name, class_id, level, effect, damage, duration, range, save_type, casting_time) VALUES
    ('cure-light-wounds',       'Cure Light Wounds',       'cleric', 1, 'Heal HP', '1d8', 'Instant', 'Touch', NULL, 5),
    ('bless',                   'Bless',                   'cleric', 1, '+1 attack and saves for the encounter', NULL, '1 encounter', '60 ft', NULL, 5),
    ('command',                 'Command',                 'cleric', 1, 'One-word command for 1 round', NULL, '1 round', '30 ft', 'spells', 1),
    ('detect-evil',             'Detect Evil',             'cleric', 1, 'Detect evil in 120 ft path', NULL, '1 turn + 5 rounds/level', '120 ft', NULL, 1),
    ('light',                   'Light',                   'cleric', 1, '20 ft radius illumination', NULL, '6 turns + 1/level', '60 ft', NULL, 4),
    ('protection-from-evil',    'Protection from Evil',    'cleric', 1, '-2 to evil attacks, +2 saves', NULL, '3 rounds/level', 'Touch', NULL, 4),
    ('hold-person',             'Hold Person',             'cleric', 2, 'Paralyze 1 humanoid', NULL, '1d4 rounds', '60 ft', 'spells', 5),
    ('silence',                 'Silence',                 'cleric', 2, 'No spellcasting in area', NULL, '1d6 rounds', '120 ft', NULL, 5),
    ('spiritual-weapon',        'Spiritual Weapon',        'cleric', 2, 'Conjured weapon attacks on its own', '1d6+1', '1 round/level', '30 ft', NULL, 5),
    ('cure-serious-wounds',     'Cure Serious Wounds',     'cleric', 3, 'Heal HP', '2d8+3', 'Instant', 'Touch', NULL, 7),
    ('dispel-magic',            'Dispel Magic',            'cleric', 3, 'Remove one magical effect', NULL, 'Instant', '60 ft', NULL, 6),
    ('prayer',                  'Prayer',                  'cleric', 3, '+1 all rolls for party, -1 for enemies', NULL, '1 round/level', '60 ft', NULL, 6);

-- Stronghold structures
INSERT OR IGNORE INTO stronghold_structures (id, name, cost, build_weeks, garrison_capacity, notes) VALUES
    ('wooden-palisade', 'Wooden Palisade',       500,    1,  0,  'Basic defense, per hex side'),
    ('stone-wall',      'Stone Wall (10 ft)',    5000,   2,  0,  'Standard fortification'),
    ('round-tower',     'Tower (round, 30 ft)',  15000,  6,  10, 'Garrison 10 soldiers'),
    ('small-keep',      'Keep (small)',          25000,  12, 20, 'Lord residence, garrison 20'),
    ('large-keep',      'Keep (large)',          75000,  24, 50, 'Great hall, garrison 50'),
    ('castle',          'Castle (full)',         150000, 52, 100,'Multiple towers, curtain walls'),
    ('moat',            'Moat',                  5000,   4,  0,  '+2 to defense rolls, per hex side'),
    ('gatehouse',       'Gatehouse',             10000,  6,  0,  'Portcullis, murder holes'),
    ('drawbridge',      'Drawbridge',            2500,   2,  0,  'Requires moat'),
    ('dungeon-level',   'Dungeon Level',         10000,  8,  0,  'Prison, storage, or treasury'),
    ('chapel',          'Chapel',                8000,   4,  0,  'Cleric required'),
    ('wizard-lab',      'Wizard''s Laboratory',  20000,  8,  0,  'Magic-User required');

-- Stronghold upgrades
INSERT OR IGNORE INTO stronghold_upgrades (id, name, cost, prerequisite, pop_required, benefit) VALUES
    ('market',           'Market',              10000, NULL,               500, '+25% income'),
    ('inn',              'Inn',                 5000,  NULL,               200, 'Attracts more settlers'),
    ('stone-walls',      'Stone Walls Upgrade', 20000, 'wooden-palisade', 0,   '+4 defense'),
    ('watchtower-net',   'Watchtower Network',  8000,  'round-tower',     0,   'Early warning of attacks'),
    ('smithy',           'Smithy',              6000,  NULL,               300, 'Equip garrison locally'),
    ('granary',          'Granary',             4000,  NULL,               0,   'Resist famine events'),
    ('library',          'Library',             15000, 'round-tower',      0,   '+1 spell learned per level'),
    ('temple-upgrade',   'Temple Upgrade',      12000, 'chapel',           0,   'Cleric gains bonus spells');

-- Domain events
INSERT OR IGNORE INTO domain_events (roll_value, name, effect) VALUES
    (1,  'Monster Incursion',       'Must clear or lose 10% population'),
    (2,  'Plague',                  '-20% population, 500 gp to treat'),
    (3,  'Bandit Raids',           'Lose 1 month income unless garrison fights'),
    (4,  'Poor Harvest',           '-50% income this month'),
    (5,  'Trade Caravan Arrives',  '+50% income this month'),
    (6,  'Peaceful Month',         'Normal income'),
    (7,  'Peaceful Month',         'Normal income'),
    (8,  'Peaceful Month',         'Normal income'),
    (9,  'Festival',               '+10% population growth, costs 200 gp'),
    (10, 'New Settlers',           '+1d6x5 families arrive'),
    (11, 'Merchant Guild Interest','Permanent +10% income'),
    (12, 'Heroic Reputation',      '+2d6x5 families, attract 1d4 followers');

-- Quest templates
INSERT OR IGNORE INTO quest_templates (type, difficulty, description, gold_min, gold_max, xp_reward, item_reward) VALUES
    ('kill',    'easy',   'Clear nearby goblin camp',                  50,  100,  200,  'healing-potion'),
    ('kill',    'medium', 'Slay the ogre terrorizing merchants',       100, 300,  500,  NULL),
    ('kill',    'hard',   'Defeat the dragon in the marshlands',       300, 1000, 1000, NULL),
    ('fetch',   'easy',   'Retrieve herbs from the forest',            50,  100,  200,  'antidote'),
    ('fetch',   'medium', 'Recover the stolen relic from the hills',   100, 300,  500,  NULL),
    ('fetch',   'hard',   'Find the ancient artifact in the dungeon',  300, 1000, 1000, NULL),
    ('escort',  'easy',   'Escort the merchant to the next town',      50,  100,  200,  NULL),
    ('escort',  'medium', 'Guide the pilgrim through bandit territory',100, 300,  500,  NULL),
    ('escort',  'hard',   'Protect the diplomat across hostile lands',  300, 1000, 1000, NULL),
    ('explore', 'easy',   'Map 3 new terrain hexes for the guild',     50,  100,  200,  NULL),
    ('explore', 'medium', 'Chart 5 hexes including a mountain pass',   100, 300,  500,  NULL),
    ('explore', 'hard',   'Survey 8 hexes across dangerous territory', 300, 1000, 1000, NULL);
