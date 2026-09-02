CREATE TABLE IF NOT EXISTS schema_migrations (
    version TEXT PRIMARY KEY,
    applied_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS ancestries (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    str_adj INTEGER DEFAULT 0,
    dex_adj INTEGER DEFAULT 0,
    con_adj INTEGER DEFAULT 0,
    int_adj INTEGER DEFAULT 0,
    wis_adj INTEGER DEFAULT 0,
    cha_adj INTEGER DEFAULT 0,
    movement_rate INTEGER NOT NULL DEFAULT 120,
    infravision INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS ancestry_abilities (
    ancestry_id TEXT NOT NULL REFERENCES ancestries(id),
    ability TEXT NOT NULL,
    PRIMARY KEY (ancestry_id, ability)
);

CREATE TABLE IF NOT EXISTS classes (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    hit_die INTEGER NOT NULL,
    prime TEXT NOT NULL,
    armor_allowed TEXT NOT NULL DEFAULT 'any',
    shield_allowed BOOLEAN NOT NULL DEFAULT 1,
    weapons_allowed TEXT NOT NULL DEFAULT 'any',
    gold_dice INTEGER NOT NULL,
    gold_die INTEGER NOT NULL,
    gold_multiplier INTEGER NOT NULL DEFAULT 10,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS ancestry_classes (
    ancestry_id TEXT NOT NULL REFERENCES ancestries(id),
    class_id TEXT NOT NULL REFERENCES classes(id),
    level_limit INTEGER,
    PRIMARY KEY (ancestry_id, class_id)
);

CREATE TABLE IF NOT EXISTS class_min_scores (
    class_id TEXT NOT NULL REFERENCES classes(id),
    ability TEXT NOT NULL CHECK (ability IN ('str','dex','con','int','wis','cha')),
    minimum INTEGER NOT NULL,
    PRIMARY KEY (class_id, ability)
);

CREATE TABLE IF NOT EXISTS saving_throws (
    class_id TEXT NOT NULL REFERENCES classes(id),
    min_level INTEGER NOT NULL,
    max_level INTEGER NOT NULL,
    aimed INTEGER NOT NULL,
    breath INTEGER NOT NULL,
    death INTEGER NOT NULL,
    petrify INTEGER NOT NULL,
    spells INTEGER NOT NULL,
    PRIMARY KEY (class_id, min_level)
);

CREATE TABLE IF NOT EXISTS bthb_progression (
    class_id TEXT NOT NULL REFERENCES classes(id),
    level INTEGER NOT NULL,
    bonus INTEGER NOT NULL,
    PRIMARY KEY (class_id, level)
);

CREATE TABLE IF NOT EXISTS xp_table (
    class_id TEXT NOT NULL REFERENCES classes(id),
    level INTEGER NOT NULL,
    xp_required INTEGER NOT NULL,
    title TEXT NOT NULL,
    PRIMARY KEY (class_id, level)
);

CREATE TABLE IF NOT EXISTS spell_slots (
    class_id TEXT NOT NULL REFERENCES classes(id),
    caster_level INTEGER NOT NULL,
    spell_level INTEGER NOT NULL,
    slots INTEGER NOT NULL,
    PRIMARY KEY (class_id, caster_level, spell_level)
);

CREATE TABLE IF NOT EXISTS weapons (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    damage_sm_count INTEGER NOT NULL DEFAULT 1,
    damage_sm_die INTEGER NOT NULL,
    damage_sm_bonus INTEGER DEFAULT 0,
    damage_lg_count INTEGER NOT NULL DEFAULT 1,
    damage_lg_die INTEGER NOT NULL,
    damage_lg_bonus INTEGER DEFAULT 0,
    weight REAL NOT NULL,
    cost REAL NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('melee','ranged')),
    thrown BOOLEAN DEFAULT 0,
    attacks_per_round REAL DEFAULT 1.0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS armor (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    ac INTEGER NOT NULL,
    weight INTEGER NOT NULL,
    cost INTEGER NOT NULL,
    move_cap INTEGER NOT NULL DEFAULT 120,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS shields (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    ac_bonus INTEGER NOT NULL DEFAULT 1,
    weight INTEGER NOT NULL,
    cost INTEGER NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS items (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    effect TEXT,
    cost REAL NOT NULL,
    weight REAL NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS starting_equipment (
    class_id TEXT NOT NULL REFERENCES classes(id),
    item_type TEXT NOT NULL CHECK (item_type IN ('weapon','armor','shield','item')),
    item_id TEXT NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    PRIMARY KEY (class_id, item_type, item_id)
);

CREATE TABLE IF NOT EXISTS terrain (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    color TEXT NOT NULL,
    move_cost REAL NOT NULL,
    lost_chance INTEGER DEFAULT 0,
    vision_range INTEGER DEFAULT 2,
    encounter_freq TEXT DEFAULT '1-in-6',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS monsters (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    hit_dice_count INTEGER NOT NULL DEFAULT 1,
    hit_dice_bonus INTEGER DEFAULT 0,
    xp INTEGER NOT NULL DEFAULT 0,
    ac INTEGER NOT NULL DEFAULT 10,
    morale INTEGER DEFAULT 50,
    size TEXT DEFAULT 'M' CHECK (size IN ('S','M','L')),
    attacks TEXT,
    damage TEXT,
    special TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS encounter_tables (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    terrain_id TEXT NOT NULL REFERENCES terrain(id),
    roll_value INTEGER NOT NULL,
    monster_id TEXT REFERENCES monsters(id),
    count_dice INTEGER DEFAULT 1,
    count_die INTEGER DEFAULT 1,
    xp_override INTEGER,
    notes TEXT,
    UNIQUE(terrain_id, roll_value)
);

CREATE TABLE IF NOT EXISTS ability_mods (
    ability TEXT NOT NULL,
    score_min INTEGER NOT NULL,
    score_max INTEGER NOT NULL,
    to_hit INTEGER DEFAULT 0,
    damage INTEGER DEFAULT 0,
    ac_mod INTEGER DEFAULT 0,
    hp_mod INTEGER DEFAULT 0,
    hp_mod_fighter INTEGER DEFAULT 0,
    encumbrance INTEGER DEFAULT 0,
    surprise INTEGER DEFAULT 0,
    max_henchmen INTEGER DEFAULT 0,
    loyalty_pct INTEGER DEFAULT 0,
    reaction_pct INTEGER DEFAULT 0,
    PRIMARY KEY (ability, score_min)
);

CREATE TABLE IF NOT EXISTS spells (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    class_id TEXT NOT NULL REFERENCES classes(id),
    level INTEGER NOT NULL,
    effect TEXT,
    damage TEXT,
    duration TEXT,
    range TEXT,
    save_type TEXT,
    casting_time INTEGER DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS stronghold_structures (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    cost INTEGER NOT NULL,
    build_weeks INTEGER NOT NULL,
    garrison_capacity INTEGER DEFAULT 0,
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS stronghold_upgrades (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    cost INTEGER NOT NULL,
    prerequisite TEXT,
    pop_required INTEGER DEFAULT 0,
    benefit TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS domain_events (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    roll_value INTEGER NOT NULL UNIQUE,
    name TEXT NOT NULL,
    effect TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

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

CREATE TABLE IF NOT EXISTS quest_templates (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    type TEXT NOT NULL CHECK (type IN ('kill','fetch','escort','explore')),
    difficulty TEXT NOT NULL CHECK (difficulty IN ('easy','medium','hard')),
    description TEXT,
    gold_min INTEGER NOT NULL,
    gold_max INTEGER NOT NULL,
    xp_reward INTEGER NOT NULL,
    item_reward TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS characters (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    ancestry_id TEXT NOT NULL REFERENCES ancestries(id),
    class_id TEXT NOT NULL REFERENCES classes(id),
    level INTEGER NOT NULL DEFAULT 1,
    xp INTEGER NOT NULL DEFAULT 0,
    hp INTEGER NOT NULL,
    max_hp INTEGER NOT NULL,
    ac INTEGER NOT NULL DEFAULT 10,
    gold INTEGER NOT NULL DEFAULT 0,
    str INTEGER NOT NULL,
    dex INTEGER NOT NULL,
    con INTEGER NOT NULL,
    int_ INTEGER NOT NULL,
    wis INTEGER NOT NULL,
    cha INTEGER NOT NULL,
    exceptional_str INTEGER,
    movement_rate INTEGER NOT NULL DEFAULT 120,
    current_tile TEXT NOT NULL DEFAULT 'map2',
    game_day INTEGER DEFAULT 1,
    game_hour REAL DEFAULT 8.0,
    travel_hours_today REAL DEFAULT 0.0,
    rations INTEGER DEFAULT 7,
    world_seed INTEGER DEFAULT 42,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS character_equipment (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    character_id INTEGER NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
    item_type TEXT NOT NULL CHECK (item_type IN ('weapon','armor','shield','item')),
    item_id TEXT NOT NULL,
    equipped BOOLEAN DEFAULT 0,
    quantity INTEGER DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS character_spells (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    character_id INTEGER NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
    spell_id TEXT NOT NULL REFERENCES spells(id),
    memorized BOOLEAN DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS character_quests (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    character_id INTEGER NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
    quest_template_id INTEGER NOT NULL REFERENCES quest_templates(id),
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active','completed','failed')),
    target_terrain TEXT,
    target_count INTEGER DEFAULT 0,
    current_count INTEGER DEFAULT 0,
    reward_gold INTEGER DEFAULT 0,
    reward_xp INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS character_stronghold (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    character_id INTEGER NOT NULL UNIQUE REFERENCES characters(id) ON DELETE CASCADE,
    tile_address TEXT NOT NULL,
    population INTEGER DEFAULT 0,
    monthly_income INTEGER DEFAULT 0,
    garrison_count INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS stronghold_built_structures (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    stronghold_id INTEGER NOT NULL REFERENCES character_stronghold(id) ON DELETE CASCADE,
    structure_id TEXT NOT NULL REFERENCES stronghold_structures(id),
    completed BOOLEAN DEFAULT 0,
    weeks_remaining INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS explored_tiles (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    character_id INTEGER NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
    address TEXT NOT NULL,
    terrain_id TEXT REFERENCES terrain(id),
    discovered_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(character_id, address)
);

CREATE TABLE IF NOT EXISTS tile_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tile_address TEXT NOT NULL,
    item_type TEXT NOT NULL CHECK (item_type IN ('weapon','armor','shield','item')),
    item_id TEXT NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    dropped_by INTEGER REFERENCES characters(id),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS tile_npcs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tile_address TEXT NOT NULL,
    monster_id TEXT REFERENCES monsters(id),
    name TEXT NOT NULL,
    disposition TEXT NOT NULL DEFAULT 'neutral' CHECK (disposition IN ('friendly','neutral','hostile')),
    hp INTEGER NOT NULL,
    max_hp INTEGER NOT NULL,
    dialogue TEXT,
    vendor BOOLEAN DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS combat_log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    character_id INTEGER NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
    monster_id TEXT REFERENCES monsters(id),
    outcome TEXT NOT NULL CHECK (outcome IN ('victory','fled','died')),
    xp_earned INTEGER DEFAULT 0,
    gold_earned INTEGER DEFAULT 0,
    game_day INTEGER,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
