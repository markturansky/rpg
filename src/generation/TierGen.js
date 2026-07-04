import { TERRAIN } from '../constants.js';

export function generateChildGrid(parentTerrain, parentCol, parentRow, childW, childH, seed) {
  const grid = [];
  const parentSeed = hashCoords(parentCol, parentRow, seed);

  for (let row = 0; row < childH; row++) {
    grid[row] = [];
    for (let col = 0; col < childW; col++) {
      grid[row][col] = generateChildTerrain(parentTerrain, col, row, parentSeed);
    }
  }

  return grid;
}

function generateChildTerrain(parentTerrain, col, row, seed) {
  const noise = seededNoise(col, row, seed);
  const palette = getTerrainPalette(parentTerrain);

  let cumulative = 0;
  for (const { terrain, weight } of palette) {
    cumulative += weight;
    if (noise < cumulative) return terrain;
  }

  return parentTerrain;
}

function getTerrainPalette(parentTerrain) {
  switch (parentTerrain) {
    case TERRAIN.FOREST:
      return [
        { terrain: TERRAIN.FOREST, weight: 0.70 },
        { terrain: TERRAIN.GRASSLAND, weight: 0.20 },
        { terrain: TERRAIN.RIVER, weight: 0.10 },
      ];
    case TERRAIN.PLAINS:
      return [
        { terrain: TERRAIN.PLAINS, weight: 0.60 },
        { terrain: TERRAIN.GRASSLAND, weight: 0.30 },
        { terrain: TERRAIN.FOREST, weight: 0.10 },
      ];
    case TERRAIN.HILLS:
      return [
        { terrain: TERRAIN.HILLS, weight: 0.60 },
        { terrain: TERRAIN.GRASSLAND, weight: 0.20 },
        { terrain: TERRAIN.FOREST, weight: 0.15 },
        { terrain: TERRAIN.MOUNTAIN, weight: 0.05 },
      ];
    case TERRAIN.MOUNTAIN:
      return [
        { terrain: TERRAIN.MOUNTAIN, weight: 0.50 },
        { terrain: TERRAIN.HILLS, weight: 0.30 },
        { terrain: TERRAIN.FOREST, weight: 0.10 },
        { terrain: TERRAIN.TUNDRA, weight: 0.10 },
      ];
    default:
      return [{ terrain: parentTerrain, weight: 1.0 }];
  }
}

function hashCoords(col, row, seed) {
  return ((col * 73856093) ^ (row * 19349663) ^ (seed * 83492791)) & 0x7fffffff;
}

function seededNoise(x, y, seed) {
  const n = Math.sin(x * 12.9898 + y * 78.233 + seed * 43758.5453) * 43758.5453;
  return n - Math.floor(n);
}
