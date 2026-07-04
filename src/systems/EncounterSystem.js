import { roll } from '../utils/dice.js';
import { ENCOUNTER_TABLES } from '../data/monsters.js';

export function checkEncounter(terrainName, isNight = false) {
  const encounterRoll = roll(1, 6);
  const threshold = isNight ? 2 : 1;
  return encounterRoll <= threshold;
}

export function rollEncounter(terrainName) {
  const key = terrainName.toLowerCase().replace(/\s+/g, '');
  const table = ENCOUNTER_TABLES[key] || ENCOUNTER_TABLES.plains;
  const tableRoll = roll(1, table.length);
  return table[tableRoll - 1];
}

export function rollEncounterDistance() {
  return roll(2, 6) * 10;
}

export function rollNpcReaction(chaMod = 0) {
  const reactionRoll = roll(2, 6) + chaMod;
  if (reactionRoll <= 5) return 'hostile';
  if (reactionRoll <= 8) return 'uncertain';
  return 'friendly';
}
