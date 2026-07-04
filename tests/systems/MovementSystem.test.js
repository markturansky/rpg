import { describe, it, expect, vi } from 'vitest';
import { getMovementRate, getHexesPerDay, getTimeToTraverseHex, checkLost, getVisionRange } from '../../src/systems/MovementSystem.js';

describe('getMovementRate', () => {
  it('returns character movementRate if set', () => {
    expect(getMovementRate({ movementRate: 90 })).toBe(90);
  });

  it('defaults to 120', () => {
    expect(getMovementRate({})).toBe(120);
  });
});

describe('getHexesPerDay', () => {
  it('returns 4 for unencumbered on road', () => {
    expect(getHexesPerDay(120, 'road')).toBe(4);
  });

  it('returns 1 for plate mail in mountain', () => {
    expect(getHexesPerDay(60, 'mountain')).toBe(0.5);
  });

  it('forest is slower than plains', () => {
    expect(getHexesPerDay(120, 'forest')).toBeLessThan(getHexesPerDay(120, 'plains'));
  });
});

describe('getTimeToTraverseHex', () => {
  it('returns hours to cross one hex', () => {
    const time = getTimeToTraverseHex(120, 'road');
    expect(time).toBe(2);
  });

  it('mountain takes longer than plains', () => {
    expect(getTimeToTraverseHex(120, 'mountain')).toBeGreaterThan(getTimeToTraverseHex(120, 'plains'));
  });
});

describe('checkLost', () => {
  it('never gets lost on road', () => {
    for (let i = 0; i < 100; i++) {
      expect(checkLost('Road')).toBe(false);
    }
  });

  it('returns a boolean for forest', () => {
    expect(typeof checkLost('Forest')).toBe('boolean');
  });

  it('ranger reduces lost chance', () => {
    let normalLost = 0;
    let rangerLost = 0;
    for (let i = 0; i < 10000; i++) {
      if (checkLost('Forest', false)) normalLost++;
      if (checkLost('Forest', true)) rangerLost++;
    }
    expect(rangerLost).toBeLessThan(normalLost);
  });
});

describe('getVisionRange', () => {
  it('returns 3 for plains', () => {
    expect(getVisionRange('Plains')).toBe(3);
  });

  it('returns 1 for forest', () => {
    expect(getVisionRange('Forest')).toBe(1);
  });

  it('returns 6 for mountain', () => {
    expect(getVisionRange('Mountain')).toBe(6);
  });

  it('returns 1 at night regardless of terrain', () => {
    expect(getVisionRange('Plains', true)).toBe(1);
    expect(getVisionRange('Mountain', true)).toBe(1);
  });
});
