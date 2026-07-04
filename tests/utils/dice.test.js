import { describe, it, expect, vi } from 'vitest';
import { roll, rollDetailed, rollPercentile, parseDiceString } from '../../src/utils/dice.js';

describe('roll', () => {
  it('returns a number within valid range for 1d6', () => {
    for (let i = 0; i < 100; i++) {
      const result = roll(1, 6);
      expect(result).toBeGreaterThanOrEqual(1);
      expect(result).toBeLessThanOrEqual(6);
    }
  });

  it('returns a number within valid range for 3d6', () => {
    for (let i = 0; i < 100; i++) {
      const result = roll(3, 6);
      expect(result).toBeGreaterThanOrEqual(3);
      expect(result).toBeLessThanOrEqual(18);
    }
  });

  it('returns exact value when Math.random is mocked', () => {
    vi.spyOn(Math, 'random').mockReturnValue(0);
    expect(roll(1, 6)).toBe(1);
    vi.spyOn(Math, 'random').mockReturnValue(0.999);
    expect(roll(1, 6)).toBe(6);
    vi.restoreAllMocks();
  });

  it('handles 1d1', () => {
    expect(roll(1, 1)).toBe(1);
  });

  it('handles 0 dice', () => {
    expect(roll(0, 6)).toBe(0);
  });
});

describe('rollDetailed', () => {
  it('returns total and individual rolls', () => {
    const result = rollDetailed(3, 6);
    expect(result).toHaveProperty('total');
    expect(result).toHaveProperty('rolls');
    expect(result.rolls).toHaveLength(3);
    expect(result.total).toBe(result.rolls.reduce((a, b) => a + b, 0));
  });

  it('each individual roll is within range', () => {
    const result = rollDetailed(5, 8);
    for (const r of result.rolls) {
      expect(r).toBeGreaterThanOrEqual(1);
      expect(r).toBeLessThanOrEqual(8);
    }
  });
});

describe('rollPercentile', () => {
  it('returns value between 1 and 100', () => {
    for (let i = 0; i < 100; i++) {
      const result = rollPercentile();
      expect(result).toBeGreaterThanOrEqual(1);
      expect(result).toBeLessThanOrEqual(100);
    }
  });
});

describe('parseDiceString', () => {
  it('parses "2d6" correctly', () => {
    vi.spyOn(Math, 'random').mockReturnValue(0.5);
    const result = parseDiceString('2d6');
    expect(result).toBeGreaterThanOrEqual(2);
    expect(result).toBeLessThanOrEqual(12);
    vi.restoreAllMocks();
  });

  it('parses "1d8+2" correctly', () => {
    vi.spyOn(Math, 'random').mockReturnValue(0);
    expect(parseDiceString('1d8+2')).toBe(3);
    vi.restoreAllMocks();
  });

  it('parses "2d4-1" correctly', () => {
    vi.spyOn(Math, 'random').mockReturnValue(0);
    expect(parseDiceString('2d4-1')).toBe(1);
    vi.restoreAllMocks();
  });

  it('returns null for invalid strings', () => {
    expect(parseDiceString('abc')).toBeNull();
    expect(parseDiceString('')).toBeNull();
    expect(parseDiceString('d6')).toBeNull();
  });
});
