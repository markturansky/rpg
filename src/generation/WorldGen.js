import { TERRAIN, TIERS } from '../constants.js';

export function generateWorldMap(seed = 42) {
  const { gridW, gridH } = TIERS.WORLD;
  const terrain = [];

  for (let row = 0; row < gridH; row++) {
    terrain[row] = [];
    for (let col = 0; col < gridW; col++) {
      terrain[row][col] = generateWorldTerrain(col, row, seed);
    }
  }

  return { terrain, width: gridW, height: gridH, seed };
}

function generateWorldTerrain(col, row, seed) {
  const n = seededNoise(col, row, seed);

  if (n < 0.15) return TERRAIN.DEEP_WATER;
  if (n < 0.30) return TERRAIN.WATER;
  if (n < 0.35) return TERRAIN.BEACH;
  if (n < 0.50) return TERRAIN.PLAINS;
  if (n < 0.60) return TERRAIN.GRASSLAND;
  if (n < 0.72) return TERRAIN.FOREST;
  if (n < 0.78) return TERRAIN.DENSE_FOREST;
  if (n < 0.85) return TERRAIN.HILLS;
  if (n < 0.92) return TERRAIN.MOUNTAIN;
  if (n < 0.96) return TERRAIN.TUNDRA;
  return TERRAIN.DESERT;
}

function seededNoise(x, y, seed) {
  const n = Math.sin(x * 12.9898 + y * 78.233 + seed * 43758.5453) * 43758.5453;
  return n - Math.floor(n);
}

export function placeStartingTown(worldMap) {
  const { width, height, terrain } = worldMap;
  const centerCol = Math.floor(width / 2);
  const centerRow = Math.floor(height / 2);

  for (let r = 0; r < 20; r++) {
    for (let dc = -r; dc <= r; dc++) {
      for (let dr = -r; dr <= r; dr++) {
        const c = centerCol + dc;
        const rr = centerRow + dr;
        if (c >= 0 && c < width && rr >= 0 && rr < height) {
          const t = terrain[rr][c];
          if (t === TERRAIN.PLAINS || t === TERRAIN.GRASSLAND) {
            return { col: c, row: rr };
          }
        }
      }
    }
  }

  return { col: centerCol, row: centerRow };
}
