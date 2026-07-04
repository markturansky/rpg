import { TERRAIN } from '../constants.js';
import { roll } from '../utils/dice.js';

const DAILY_HEXES = {
  120: { road: 4, plains: 3, forest: 2, hills: 2, mountain: 1, desert: 2, marsh: 1.5, tundra: 1.5 },
  90:  { road: 3, plains: 2, forest: 1.5, hills: 1.5, mountain: 0.5, desert: 1.5, marsh: 1, tundra: 1 },
  60:  { road: 2, plains: 1.5, forest: 1, hills: 1, mountain: 0.5, desert: 1, marsh: 0.5, tundra: 0.5 },
};

export function getMovementRate(character) {
  return character.movementRate || 120;
}

export function getHexesPerDay(movementRate, terrainName) {
  const rates = DAILY_HEXES[movementRate] || DAILY_HEXES[120];
  const key = terrainName.toLowerCase().replace(/\s+/g, '');
  return rates[key] || rates.plains;
}

export function getTimeToTraverseHex(movementRate, terrainName) {
  const hexesPerDay = getHexesPerDay(movementRate, terrainName);
  return 8 / hexesPerDay;
}

const LOST_CHANCE = {
  road: 0, plains: 1, grassland: 1, forest: 2, denseforest: 3,
  hills: 2, mountain: 3, desert: 3, marsh: 3,
};

export function checkLost(terrainName, isRanger = false) {
  const key = terrainName.toLowerCase().replace(/\s+/g, '');
  let threshold = LOST_CHANCE[key] || 0;
  if (isRanger) threshold = Math.max(0, threshold - 1);
  if (threshold <= 0) return false;
  return roll(1, 6) <= threshold;
}

const VISION_RANGE = {
  plains: 3, road: 3, grassland: 2, beach: 2,
  forest: 1, denseforest: 1,
  hills: 4, mountain: 6,
};

export function getVisionRange(terrainName, isNight = false) {
  if (isNight) return 1;
  const key = terrainName.toLowerCase().replace(/\s+/g, '');
  return VISION_RANGE[key] || 2;
}
