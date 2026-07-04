import { describe, it, expect } from 'vitest';
import { generateTown } from '../../src/generation/TownGen.js';

describe('generateTown', () => {
  it('generates a town with name, buildings, and npcs', () => {
    const town = generateTown(10, 20, 42);
    expect(town).toHaveProperty('name');
    expect(town.name.length).toBeGreaterThan(0);
    expect(town).toHaveProperty('buildings');
    expect(town.buildings.length).toBeGreaterThan(0);
    expect(town).toHaveProperty('npcs');
    expect(town.npcs.length).toBeGreaterThan(0);
  });

  it('has required building types', () => {
    const town = generateTown(5, 5, 42);
    const types = town.buildings.map(b => b.type);
    expect(types).toContain('inn');
    expect(types).toContain('market');
    expect(types).toContain('smithy');
    expect(types).toContain('chapel');
    expect(types).toContain('town-hall');
  });

  it('is deterministic with same inputs', () => {
    const t1 = generateTown(10, 10, 42);
    const t2 = generateTown(10, 10, 42);
    expect(t1.name).toBe(t2.name);
  });

  it('different coords produce different names', () => {
    const t1 = generateTown(0, 0, 42);
    const t2 = generateTown(50, 50, 42);
    expect(t1.name).not.toBe(t2.name);
  });
});
