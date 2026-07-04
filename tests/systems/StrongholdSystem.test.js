import { describe, it, expect } from 'vitest';
import { canBuildStronghold, createStronghold, calculateMonthlyIncome, calculateMaintenanceCost, rollDomainEvent } from '../../src/systems/StrongholdSystem.js';

describe('canBuildStronghold', () => {
  it('returns false for low-level fighter', () => {
    expect(canBuildStronghold({ classId: 'fighter', level: 5 })).toBe(false);
  });

  it('returns true for level 9 fighter', () => {
    expect(canBuildStronghold({ classId: 'fighter', level: 9 })).toBe(true);
  });

  it('requires level 11 for magic-user', () => {
    expect(canBuildStronghold({ classId: 'magic-user', level: 10 })).toBe(false);
    expect(canBuildStronghold({ classId: 'magic-user', level: 11 })).toBe(true);
  });

  it('requires level 10 for thief', () => {
    expect(canBuildStronghold({ classId: 'thief', level: 9 })).toBe(false);
    expect(canBuildStronghold({ classId: 'thief', level: 10 })).toBe(true);
  });
});

describe('createStronghold', () => {
  it('creates a stronghold with initial values', () => {
    const sh = createStronghold({ name: 'Lord Bob' });
    expect(sh.ownerId).toBe('Lord Bob');
    expect(sh.population).toBe(0);
    expect(sh.structures).toEqual([]);
    expect(sh.followers).toEqual([]);
  });
});

describe('calculateMonthlyIncome', () => {
  it('returns half of population as income', () => {
    expect(calculateMonthlyIncome({ population: 1000 })).toBe(500);
    expect(calculateMonthlyIncome({ population: 0 })).toBe(0);
  });
});

describe('calculateMaintenanceCost', () => {
  it('returns 1% of total construction cost', () => {
    const sh = { structures: [{ constructionCost: 10000 }, { constructionCost: 5000 }] };
    expect(calculateMaintenanceCost(sh)).toBe(150);
  });

  it('returns 0 for no structures', () => {
    expect(calculateMaintenanceCost({ structures: [] })).toBe(0);
  });
});

describe('rollDomainEvent', () => {
  it('returns an event object with expected properties', () => {
    const event = rollDomainEvent();
    expect(event).toHaveProperty('name');
    expect(event).toHaveProperty('effect');
    expect(event).toHaveProperty('amount');
  });
});
