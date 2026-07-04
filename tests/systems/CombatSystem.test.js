import { describe, it, expect, vi } from 'vitest';
import { rollInitiative, getBTHB, resolveAttack, rollDamage, checkMorale, checkSurprise } from '../../src/systems/CombatSystem.js';

describe('rollInitiative', () => {
  it('returns value between 1 and 6', () => {
    for (let i = 0; i < 50; i++) {
      const result = rollInitiative();
      expect(result).toBeGreaterThanOrEqual(1);
      expect(result).toBeLessThanOrEqual(6);
    }
  });
});

describe('getBTHB', () => {
  it('returns +1 for level 1 fighter', () => {
    expect(getBTHB('fighter', 1)).toBe(1);
  });

  it('returns +5 for level 5 fighter', () => {
    expect(getBTHB('fighter', 5)).toBe(5);
  });

  it('returns 0 for level 1 magic-user', () => {
    expect(getBTHB('magic-user', 1)).toBe(0);
  });

  it('returns 0 for unknown class', () => {
    expect(getBTHB('unknown', 1)).toBe(0);
  });

  it('fighter BTHB increases every level', () => {
    for (let lvl = 1; lvl <= 9; lvl++) {
      expect(getBTHB('fighter', lvl)).toBe(lvl);
    }
  });
});

describe('resolveAttack', () => {
  it('returns hit result with expected properties', () => {
    const attacker = { classId: 'fighter', level: 1, scores: { str: 10 } };
    const defender = { ac: 10 };
    const result = resolveAttack(attacker, defender);

    expect(result).toHaveProperty('attackRoll');
    expect(result).toHaveProperty('total');
    expect(result).toHaveProperty('hit');
    expect(result).toHaveProperty('critical');
    expect(result).toHaveProperty('fumble');
    expect(typeof result.hit).toBe('boolean');
  });

  it('natural 20 is always critical', () => {
    vi.spyOn(Math, 'random').mockReturnValue(0.999);
    const result = resolveAttack(
      { classId: 'fighter', level: 1, scores: { str: 10 } },
      { ac: 30 }
    );
    expect(result.critical).toBe(true);
    expect(result.attackRoll).toBe(20);
    vi.restoreAllMocks();
  });

  it('natural 1 is always fumble', () => {
    vi.spyOn(Math, 'random').mockReturnValue(0);
    const result = resolveAttack(
      { classId: 'fighter', level: 1, scores: { str: 10 } },
      { ac: 1 }
    );
    expect(result.fumble).toBe(true);
    expect(result.attackRoll).toBe(1);
    vi.restoreAllMocks();
  });
});

describe('rollDamage', () => {
  it('returns at least 1', () => {
    vi.spyOn(Math, 'random').mockReturnValue(0);
    const dmg = rollDamage({ count: 1, die: 4 }, -5);
    expect(dmg).toBeGreaterThanOrEqual(1);
    vi.restoreAllMocks();
  });

  it('adds strength modifier', () => {
    vi.spyOn(Math, 'random').mockReturnValue(0.5);
    const base = rollDamage({ count: 1, die: 8 }, 0);
    vi.spyOn(Math, 'random').mockReturnValue(0.5);
    const withStr = rollDamage({ count: 1, die: 8 }, 3);
    expect(withStr).toBe(base + 3);
    vi.restoreAllMocks();
  });
});

describe('checkMorale', () => {
  it('returns a boolean', () => {
    expect(typeof checkMorale(1)).toBe('boolean');
  });

  it('higher HD monsters have better morale', () => {
    let lowHdPasses = 0;
    let highHdPasses = 0;
    for (let i = 0; i < 1000; i++) {
      if (checkMorale(1)) lowHdPasses++;
      if (checkMorale(10)) highHdPasses++;
    }
    expect(highHdPasses).toBeGreaterThan(lowHdPasses);
  });
});

describe('checkSurprise', () => {
  it('returns a boolean', () => {
    expect(typeof checkSurprise()).toBe('boolean');
  });
});
