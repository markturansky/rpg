import { describe, it, expect } from 'vitest';
import { generateWorldMap, placeStartingTown } from '../../src/generation/WorldGen.js';

describe('generateWorldMap', () => {
  it('generates a 300x200 terrain grid', () => {
    const map = generateWorldMap(42);
    expect(map.height).toBe(200);
    expect(map.width).toBe(300);
    expect(map.terrain).toHaveLength(200);
    expect(map.terrain[0]).toHaveLength(300);
  });

  it('is deterministic with same seed', () => {
    const map1 = generateWorldMap(42);
    const map2 = generateWorldMap(42);
    for (let r = 0; r < 10; r++) {
      for (let c = 0; c < 10; c++) {
        expect(map1.terrain[r][c]).toEqual(map2.terrain[r][c]);
      }
    }
  });

  it('produces different maps with different seeds', () => {
    const map1 = generateWorldMap(1);
    const map2 = generateWorldMap(999);
    let differences = 0;
    for (let r = 0; r < 10; r++) {
      for (let c = 0; c < 10; c++) {
        if (map1.terrain[r][c].id !== map2.terrain[r][c].id) differences++;
      }
    }
    expect(differences).toBeGreaterThan(0);
  });

  it('every cell has valid terrain data', () => {
    const map = generateWorldMap(42);
    for (let r = 0; r < map.height; r++) {
      for (let c = 0; c < map.width; c++) {
        const cell = map.terrain[r][c];
        expect(cell).toHaveProperty('id');
        expect(cell).toHaveProperty('name');
        expect(cell).toHaveProperty('color');
      }
    }
  });
});

describe('placeStartingTown', () => {
  it('returns a valid position', () => {
    const map = generateWorldMap(42);
    const pos = placeStartingTown(map);
    expect(pos).toHaveProperty('col');
    expect(pos).toHaveProperty('row');
    expect(pos.col).toBeGreaterThanOrEqual(0);
    expect(pos.col).toBeLessThan(map.width);
    expect(pos.row).toBeGreaterThanOrEqual(0);
    expect(pos.row).toBeLessThan(map.height);
  });
});
