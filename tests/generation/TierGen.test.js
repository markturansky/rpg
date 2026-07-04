import { describe, it, expect } from 'vitest';
import { generateChildGrid } from '../../src/generation/TierGen.js';
import { TERRAIN } from '../../src/constants.js';

describe('generateChildGrid', () => {
  it('generates a grid of the correct dimensions', () => {
    const grid = generateChildGrid(TERRAIN.FOREST, 5, 3, 6, 6, 42);
    expect(grid).toHaveLength(6);
    expect(grid[0]).toHaveLength(6);
  });

  it('is deterministic with same inputs', () => {
    const grid1 = generateChildGrid(TERRAIN.PLAINS, 10, 10, 6, 6, 42);
    const grid2 = generateChildGrid(TERRAIN.PLAINS, 10, 10, 6, 6, 42);
    for (let r = 0; r < 6; r++) {
      for (let c = 0; c < 6; c++) {
        expect(grid1[r][c]).toEqual(grid2[r][c]);
      }
    }
  });

  it('different parent coords produce different grids', () => {
    const grid1 = generateChildGrid(TERRAIN.FOREST, 0, 0, 6, 6, 42);
    const grid2 = generateChildGrid(TERRAIN.FOREST, 5, 5, 6, 6, 42);
    let differences = 0;
    for (let r = 0; r < 6; r++) {
      for (let c = 0; c < 6; c++) {
        if (grid1[r][c].id !== grid2[r][c].id) differences++;
      }
    }
    expect(differences).toBeGreaterThan(0);
  });

  it('every cell has valid terrain data', () => {
    const grid = generateChildGrid(TERRAIN.HILLS, 2, 3, 26, 26, 42);
    for (let r = 0; r < 26; r++) {
      for (let c = 0; c < 26; c++) {
        const cell = grid[r][c];
        expect(cell).toHaveProperty('id');
        expect(cell).toHaveProperty('name');
        expect(cell).toHaveProperty('color');
      }
    }
  });
});
