import { describe, it, expect } from 'vitest';
import { getSpellSlots, getAvailableSpells, memorizeSpell, castSpell } from '../../src/systems/SpellSystem.js';

describe('getSpellSlots', () => {
  it('returns [1] for level 1 magic-user', () => {
    expect(getSpellSlots('magic-user', 1, 10)).toEqual([1]);
  });

  it('returns [2, 1] for level 3 magic-user', () => {
    expect(getSpellSlots('magic-user', 3, 10)).toEqual([2, 1]);
  });

  it('returns empty for fighter', () => {
    expect(getSpellSlots('fighter', 5, 10)).toEqual([]);
  });

  it('WIS 13 adds bonus 1st-level slot for cleric', () => {
    const base = getSpellSlots('cleric', 1, 10);
    const bonus = getSpellSlots('cleric', 1, 13);
    expect(bonus[0]).toBe(base[0] + 1);
  });

  it('WIS 15 adds bonus 2nd-level slot for cleric', () => {
    const slots = getSpellSlots('cleric', 3, 15);
    expect(slots[1]).toBeGreaterThan(1);
  });
});

describe('getAvailableSpells', () => {
  it('returns level 1 spells for level 1 magic-user', () => {
    const spells = getAvailableSpells('magic-user', 1);
    expect(spells.length).toBeGreaterThan(0);
    for (const s of spells) {
      expect(s.classId).toBe('magic-user');
      expect(s.spellLevel).toBe(1);
    }
  });

  it('returns spells up to level for higher level casters', () => {
    const spells = getAvailableSpells('magic-user', 3);
    const levels = [...new Set(spells.map(s => s.spellLevel))];
    expect(levels).toContain(1);
    expect(levels).toContain(2);
    expect(levels).toContain(3);
  });

  it('returns no spells for fighter', () => {
    expect(getAvailableSpells('fighter', 5)).toHaveLength(0);
  });
});

describe('memorizeSpell / castSpell', () => {
  it('memorizes and casts a spell', () => {
    const char = { spellsMemorized: [] };
    memorizeSpell(char, 'magic-missile');
    expect(char.spellsMemorized).toContain('magic-missile');

    const spell = castSpell(char, 'magic-missile');
    expect(spell).not.toBeNull();
    expect(spell.id).toBe('magic-missile');
    expect(char.spellsMemorized).not.toContain('magic-missile');
  });

  it('returns null when casting unmemorized spell', () => {
    const char = { spellsMemorized: [] };
    expect(castSpell(char, 'fireball')).toBeNull();
  });

  it('only consumes one instance of a memorized spell', () => {
    const char = { spellsMemorized: [] };
    memorizeSpell(char, 'magic-missile');
    memorizeSpell(char, 'magic-missile');
    castSpell(char, 'magic-missile');
    expect(char.spellsMemorized).toHaveLength(1);
    expect(char.spellsMemorized[0]).toBe('magic-missile');
  });
});
