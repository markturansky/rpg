import { describe, it, expect } from 'vitest';
import { axialToPixel, pixelToAxial, axialRound, axialDistance, axialNeighbors, hexCorners } from '../../src/utils/hex.js';

describe('axialToPixel', () => {
  it('converts origin hex to pixel origin', () => {
    const { x, y } = axialToPixel(0, 0, 32);
    expect(x).toBe(0);
    expect(y).toBe(0);
  });

  it('produces consistent pixel coordinates', () => {
    const p1 = axialToPixel(1, 0, 32);
    const p2 = axialToPixel(0, 1, 32);
    expect(p1.x).not.toBe(p2.x);
  });
});

describe('pixelToAxial', () => {
  it('round-trips through axialToPixel', () => {
    for (const [col, row] of [[0, 0], [1, 0], [0, 1], [3, 4], [-1, 2]]) {
      const { x, y } = axialToPixel(col, row, 32);
      const result = pixelToAxial(x, y, 32);
      expect(result.col).toBe(col);
      expect(result.row).toBe(row);
    }
  });
});

describe('axialRound', () => {
  it('rounds fractional coords to nearest hex', () => {
    const result = axialRound(0.1, -0.1);
    expect(result.col).toBe(0);
    expect(result.row).toBe(0);
  });

  it('handles exact integers', () => {
    const result = axialRound(3, 4);
    expect(result.col).toBe(3);
    expect(result.row).toBe(4);
  });
});

describe('axialDistance', () => {
  it('returns 0 for same hex', () => {
    expect(axialDistance({ col: 0, row: 0 }, { col: 0, row: 0 })).toBe(0);
  });

  it('returns 1 for adjacent hexes', () => {
    expect(axialDistance({ col: 0, row: 0 }, { col: 1, row: 0 })).toBe(1);
    expect(axialDistance({ col: 0, row: 0 }, { col: 0, row: 1 })).toBe(1);
  });

  it('returns correct distance for non-adjacent hexes', () => {
    expect(axialDistance({ col: 0, row: 0 }, { col: 3, row: 0 })).toBe(3);
    expect(axialDistance({ col: 0, row: 0 }, { col: 2, row: 2 })).toBe(4);
  });
});

describe('axialNeighbors', () => {
  it('returns exactly 6 neighbors', () => {
    const neighbors = axialNeighbors(0, 0);
    expect(neighbors).toHaveLength(6);
  });

  it('all neighbors are distance 1 from center', () => {
    const center = { col: 5, row: 3 };
    const neighbors = axialNeighbors(center.col, center.row);
    for (const n of neighbors) {
      expect(axialDistance(center, n)).toBe(1);
    }
  });
});

describe('hexCorners', () => {
  it('returns exactly 6 corners', () => {
    const corners = hexCorners(0, 0, 32);
    expect(corners).toHaveLength(6);
  });

  it('all corners are at the correct distance from center', () => {
    const cx = 100, cy = 100, size = 32;
    const corners = hexCorners(cx, cy, size);
    for (const corner of corners) {
      const dist = Math.sqrt((corner.x - cx) ** 2 + (corner.y - cy) ** 2);
      expect(dist).toBeCloseTo(size, 5);
    }
  });
});
