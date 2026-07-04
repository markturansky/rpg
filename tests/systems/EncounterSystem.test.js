import { describe, it, expect } from 'vitest';
import { checkEncounter, rollEncounter, rollEncounterDistance, rollNpcReaction } from '../../src/systems/EncounterSystem.js';

describe('checkEncounter', () => {
  it('returns a boolean', () => {
    expect(typeof checkEncounter('Plains')).toBe('boolean');
  });

  it('night encounters are more frequent', () => {
    let dayEncounters = 0;
    let nightEncounters = 0;
    for (let i = 0; i < 10000; i++) {
      if (checkEncounter('Plains', false)) dayEncounters++;
      if (checkEncounter('Plains', true)) nightEncounters++;
    }
    expect(nightEncounters).toBeGreaterThan(dayEncounters);
  });
});

describe('rollEncounter', () => {
  it('returns an encounter object for plains', () => {
    const enc = rollEncounter('Plains');
    expect(enc).toBeDefined();
    expect(enc).toHaveProperty('friendly');
  });

  it('returns encounter for various terrain types', () => {
    for (const terrain of ['Forest', 'Hills', 'Desert', 'Marsh', 'Tundra', 'Road', 'Beach']) {
      const enc = rollEncounter(terrain);
      expect(enc).toBeDefined();
    }
  });
});

describe('rollEncounterDistance', () => {
  it('returns distance between 20 and 120 yards', () => {
    for (let i = 0; i < 50; i++) {
      const dist = rollEncounterDistance();
      expect(dist).toBeGreaterThanOrEqual(20);
      expect(dist).toBeLessThanOrEqual(120);
    }
  });
});

describe('rollNpcReaction', () => {
  it('returns hostile, uncertain, or friendly', () => {
    const validResults = ['hostile', 'uncertain', 'friendly'];
    for (let i = 0; i < 100; i++) {
      expect(validResults).toContain(rollNpcReaction());
    }
  });

  it('high CHA modifier biases toward friendly', () => {
    let friendlyCount = 0;
    for (let i = 0; i < 1000; i++) {
      if (rollNpcReaction(5) === 'friendly') friendlyCount++;
    }
    expect(friendlyCount).toBeGreaterThan(500);
  });
});
