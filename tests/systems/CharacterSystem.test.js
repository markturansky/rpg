import { describe, it, expect, vi } from 'vitest';
import { rollAbilityScores, createCharacter, getConHpModifier, getXpForNextLevel, checkLevelUp } from '../../src/systems/CharacterSystem.js';

describe('rollAbilityScores', () => {
  it('returns all six ability scores', () => {
    const scores = rollAbilityScores();
    expect(scores).toHaveProperty('str');
    expect(scores).toHaveProperty('dex');
    expect(scores).toHaveProperty('con');
    expect(scores).toHaveProperty('int');
    expect(scores).toHaveProperty('wis');
    expect(scores).toHaveProperty('cha');
  });

  it('each score is between 3 and 18', () => {
    for (let i = 0; i < 50; i++) {
      const scores = rollAbilityScores();
      for (const val of Object.values(scores)) {
        expect(val).toBeGreaterThanOrEqual(3);
        expect(val).toBeLessThanOrEqual(18);
      }
    }
  });
});

describe('createCharacter', () => {
  it('creates a valid fighter', () => {
    vi.spyOn(Math, 'random').mockReturnValue(0.5);
    const scores = { str: 14, dex: 12, con: 14, int: 10, wis: 10, cha: 10 };
    const char = createCharacter('TestHero', 'human', 'fighter', scores);

    expect(char.name).toBe('TestHero');
    expect(char.classId).toBe('fighter');
    expect(char.className).toBe('Fighter');
    expect(char.ancestryId).toBe('human');
    expect(char.level).toBe(1);
    expect(char.xp).toBe(0);
    expect(char.hp).toBeGreaterThanOrEqual(1);
    expect(char.maxHp).toBeGreaterThanOrEqual(1);
    expect(char.gold).toBeGreaterThan(0);
    expect(char.scores).toEqual(scores);
    vi.restoreAllMocks();
  });

  it('applies ancestry adjustments for elf', () => {
    vi.spyOn(Math, 'random').mockReturnValue(0.5);
    const scores = { str: 10, dex: 10, con: 10, int: 10, wis: 10, cha: 10 };
    const char = createCharacter('ElfHero', 'elf', 'fighter', scores);

    expect(char.scores.dex).toBe(11);
    expect(char.scores.con).toBe(9);
    vi.restoreAllMocks();
  });

  it('clamps adjusted scores to 3-18 range', () => {
    vi.spyOn(Math, 'random').mockReturnValue(0.5);
    const scores = { str: 3, dex: 10, con: 10, int: 10, wis: 10, cha: 10 };
    const char = createCharacter('WeakHalfling', 'halfling', 'fighter', scores);

    expect(char.scores.str).toBe(3);
    expect(char.scores.dex).toBe(11);
    vi.restoreAllMocks();
  });

  it('HP is at least 1', () => {
    vi.spyOn(Math, 'random').mockReturnValue(0);
    const scores = { str: 10, dex: 10, con: 3, int: 10, wis: 10, cha: 10 };
    const char = createCharacter('Frail', 'human', 'magic-user', scores);

    expect(char.hp).toBeGreaterThanOrEqual(1);
    vi.restoreAllMocks();
  });
});

describe('getConHpModifier', () => {
  it('returns -2 for CON 3', () => {
    expect(getConHpModifier(3, 'fighter')).toBe(-2);
  });

  it('returns 0 for CON 10', () => {
    expect(getConHpModifier(10, 'fighter')).toBe(0);
  });

  it('returns fighter bonus for CON 17', () => {
    expect(getConHpModifier(17, 'fighter')).toBe(3);
    expect(getConHpModifier(17, 'thief')).toBe(2);
  });

  it('returns fighter bonus for CON 18', () => {
    expect(getConHpModifier(18, 'fighter')).toBe(4);
    expect(getConHpModifier(18, 'magic-user')).toBe(2);
  });
});

describe('getXpForNextLevel', () => {
  it('returns correct XP for fighter level 2', () => {
    expect(getXpForNextLevel('fighter', 1)).toBe(2000);
  });

  it('returns Infinity for unknown class', () => {
    expect(getXpForNextLevel('unknown', 1)).toBe(Infinity);
  });
});

describe('checkLevelUp', () => {
  it('returns false when XP is insufficient', () => {
    expect(checkLevelUp({ classId: 'fighter', level: 1, xp: 1000 })).toBe(false);
  });

  it('returns true when XP meets threshold', () => {
    expect(checkLevelUp({ classId: 'fighter', level: 1, xp: 2000 })).toBe(true);
  });

  it('returns true when XP exceeds threshold', () => {
    expect(checkLevelUp({ classId: 'fighter', level: 1, xp: 5000 })).toBe(true);
  });
});
