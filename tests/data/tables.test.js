import { describe, it, expect } from 'vitest';
import { CLASSES } from '../../src/data/classes.js';
import { ANCESTRIES } from '../../src/data/ancestries.js';
import { WEAPONS } from '../../src/data/weapons.js';
import { ARMOR, SHIELDS } from '../../src/data/armor.js';
import { SPELLS } from '../../src/data/spells.js';
import { MONSTERS, ENCOUNTER_TABLES } from '../../src/data/monsters.js';
import { ITEMS } from '../../src/data/items.js';

describe('CLASSES', () => {
  it('has all 6 classes', () => {
    expect(Object.keys(CLASSES)).toHaveLength(6);
    expect(CLASSES).toHaveProperty('fighter');
    expect(CLASSES).toHaveProperty('cleric');
    expect(CLASSES).toHaveProperty('magic-user');
    expect(CLASSES).toHaveProperty('thief');
    expect(CLASSES).toHaveProperty('ranger');
    expect(CLASSES).toHaveProperty('paladin');
  });

  it('each class has required fields', () => {
    for (const [id, cls] of Object.entries(CLASSES)) {
      expect(cls.name).toBeDefined();
      expect(cls.hitDie).toBeGreaterThan(0);
      expect(cls.bthbProgression).toBeDefined();
      expect(cls.savingThrows).toBeDefined();
      expect(cls.xpTable).toBeDefined();
      expect(cls.startingGold).toBeDefined();
    }
  });
});

describe('ANCESTRIES', () => {
  it('has all 7 ancestries', () => {
    expect(Object.keys(ANCESTRIES)).toHaveLength(7);
  });

  it('each ancestry has required fields', () => {
    for (const [id, anc] of Object.entries(ANCESTRIES)) {
      expect(anc.name).toBeDefined();
      expect(anc.movementRate).toBeGreaterThan(0);
      expect(anc.allowedClasses).toBeDefined();
      expect(anc.allowedClasses.length).toBeGreaterThan(0);
    }
  });
});

describe('WEAPONS', () => {
  it('has at least 10 weapons', () => {
    expect(Object.keys(WEAPONS).length).toBeGreaterThanOrEqual(10);
  });

  it('each weapon has damage values', () => {
    for (const [id, w] of Object.entries(WEAPONS)) {
      expect(w.damageSM).toBeDefined();
      expect(w.damageSM.die).toBeGreaterThan(0);
      expect(w.damageL).toBeDefined();
      expect(w.damageL.die).toBeGreaterThan(0);
    }
  });
});

describe('ARMOR', () => {
  it('has ascending AC values', () => {
    expect(ARMOR.unarmored.ac).toBe(10);
    expect(ARMOR['plate-mail'].ac).toBe(17);
  });

  it('shields provide +1 AC', () => {
    for (const shield of Object.values(SHIELDS)) {
      expect(shield.acBonus).toBe(1);
    }
  });
});

describe('SPELLS', () => {
  it('has magic-user and cleric spells', () => {
    const muSpells = SPELLS.filter(s => s.classId === 'magic-user');
    const clericSpells = SPELLS.filter(s => s.classId === 'cleric');
    expect(muSpells.length).toBeGreaterThan(0);
    expect(clericSpells.length).toBeGreaterThan(0);
  });

  it('each spell has required fields', () => {
    for (const spell of SPELLS) {
      expect(spell.id).toBeDefined();
      expect(spell.name).toBeDefined();
      expect(spell.spellLevel).toBeGreaterThan(0);
      expect(spell.classId).toBeDefined();
    }
  });

  it('spell IDs are unique', () => {
    const ids = SPELLS.map(s => s.id);
    expect(new Set(ids).size).toBe(ids.length);
  });
});

describe('MONSTERS', () => {
  it('has at least 20 monsters', () => {
    expect(Object.keys(MONSTERS).length).toBeGreaterThanOrEqual(20);
  });

  it('each monster has required stats', () => {
    for (const [id, m] of Object.entries(MONSTERS)) {
      expect(m.name).toBeDefined();
      expect(m.hd).toBeGreaterThan(0);
      expect(m.ac).toBeGreaterThan(0);
      expect(m.attacks).toBeDefined();
      expect(m.xp).toBeGreaterThan(0);
    }
  });
});

describe('ENCOUNTER_TABLES', () => {
  it('has tables for all major terrain types', () => {
    const requiredTerrains = ['plains', 'forest', 'hills', 'mountain', 'desert', 'marsh', 'tundra', 'road', 'beach'];
    for (const terrain of requiredTerrains) {
      expect(ENCOUNTER_TABLES).toHaveProperty(terrain);
      expect(ENCOUNTER_TABLES[terrain].length).toBeGreaterThan(0);
    }
  });
});

describe('ITEMS', () => {
  it('has consumable items', () => {
    expect(ITEMS).toHaveProperty('healing-potion');
    expect(ITEMS).toHaveProperty('rations');
    expect(ITEMS).toHaveProperty('arrows');
  });

  it('each item has cost and weight', () => {
    for (const [id, item] of Object.entries(ITEMS)) {
      expect(item.cost).toBeDefined();
      expect(item.weight).toBeDefined();
    }
  });
});
