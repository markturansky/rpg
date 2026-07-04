export const GAME_WIDTH = 1280;
export const GAME_HEIGHT = 720;

export const TIERS = {
  WORLD:    { name: 'world',    scale: '6 miles',   gridW: 300, gridH: 200, childPerParent: null,    timePerHex: 3,     encounterChance: 1/6  },
  REGIONAL: { name: 'regional', scale: '1 mile',    gridW: 6,   gridH: 6,   childPerParent: '6x6',   timePerHex: 0.5,   encounterChance: 1/8  },
  LOCAL:    { name: 'local',    scale: '200 feet',  gridW: 26,  gridH: 26,  childPerParent: '26x26', timePerHex: 0.05,  encounterChance: 1/12 },
  TOWN:    { name: 'town',     scale: '20 feet',   gridW: 50,  gridH: 50,  childPerParent: '50x50', timePerHex: 0,     encounterChance: 0    },
  TACTICAL: { name: 'tactical', scale: '5 feet',    gridW: 20,  gridH: 15,  childPerParent: '20x15', timePerHex: 0,     encounterChance: 0    },
};

export const TERRAIN = {
  WATER:        { id: 0, name: 'Water',        color: '#1a5276', moveCost: Infinity },
  DEEP_WATER:   { id: 1, name: 'Deep Water',   color: '#0e3d5c', moveCost: Infinity },
  PLAINS:       { id: 2, name: 'Plains',       color: '#a8c256', moveCost: 1.0 },
  GRASSLAND:    { id: 3, name: 'Grassland',    color: '#7daa4e', moveCost: 1.0 },
  FOREST:       { id: 4, name: 'Forest',       color: '#2d6a1e', moveCost: 1.5 },
  DENSE_FOREST: { id: 5, name: 'Dense Forest', color: '#1a4712', moveCost: 2.0 },
  HILLS:        { id: 6, name: 'Hills',        color: '#8b7d3c', moveCost: 1.5 },
  MOUNTAIN:     { id: 7, name: 'Mountain',     color: '#6b6b6b', moveCost: 3.0 },
  DESERT:       { id: 8, name: 'Desert',       color: '#d4b94e', moveCost: 1.5 },
  MARSH:        { id: 9, name: 'Marsh',        color: '#4a6741', moveCost: 2.0 },
  TUNDRA:       { id: 10, name: 'Tundra',      color: '#b8c8d4', moveCost: 2.0 },
  BEACH:        { id: 11, name: 'Beach',       color: '#e8d5a3', moveCost: 1.0 },
  ROAD:         { id: 12, name: 'Road',        color: '#8b7355', moveCost: 0.75 },
  RIVER:        { id: 13, name: 'River',       color: '#2980b9', moveCost: Infinity },
};

export const HEX_SIZE = 32;

export const TILE_CACHE_MAX = 50;

export const TIME_OF_DAY = {
  DAWN:  { start: 6,  end: 8,  label: 'Dawn',  encounterMod: 0 },
  DAY:   { start: 8,  end: 18, label: 'Day',   encounterMod: 0 },
  DUSK:  { start: 18, end: 20, label: 'Dusk',  encounterMod: 1 },
  NIGHT: { start: 20, end: 6,  label: 'Night', encounterMod: 2 },
};

export const SCENE_KEYS = {
  BOOT:        'BootScene',
  CHAR_CREATE: 'CharCreateScene',
  WORLD:       'WorldScene',
  REGIONAL:    'RegionalScene',
  LOCAL:       'LocalScene',
  TOWN:        'TownScene',
  COMBAT:      'CombatScene',
  HUD:         'HUDScene',
};
