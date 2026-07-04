import { roll } from '../utils/dice.js';
import { CLASSES } from '../data/classes.js';
import { ANCESTRIES } from '../data/ancestries.js';

export function rollAbilityScores() {
  return {
    str: roll(3, 6),
    dex: roll(3, 6),
    con: roll(3, 6),
    int: roll(3, 6),
    wis: roll(3, 6),
    cha: roll(3, 6),
  };
}

export function rollExceptionalStrength() {
  return roll(1, 100);
}

export function createCharacter(name, ancestryId, classId, scores) {
  const ancestry = ANCESTRIES[ancestryId];
  const cls = CLASSES[classId];

  const adjusted = { ...scores };
  if (ancestry.adjustments) {
    for (const [stat, mod] of Object.entries(ancestry.adjustments)) {
      adjusted[stat] = Math.max(3, Math.min(18, adjusted[stat] + mod));
    }
  }

  const conMod = getConHpModifier(adjusted.con, classId);
  const maxHp = roll(1, cls.hitDie) + conMod;

  return {
    name,
    ancestryId,
    classId,
    className: cls.name,
    ancestryName: ancestry.name,
    level: 1,
    xp: 0,
    scores: adjusted,
    exceptionalStr: null,
    hp: Math.max(1, maxHp),
    maxHp: Math.max(1, maxHp),
    ac: 10,
    gold: roll(cls.startingGold.count, cls.startingGold.die) * cls.startingGold.multiplier,
    equipment: [],
    spellsMemorized: [],
    inventory: [],
  };
}

export function getConHpModifier(con, classId) {
  if (con <= 3) return -2;
  if (con <= 6) return -1;
  if (con <= 14) return 0;
  if (con <= 16) return 1;
  const isFighter = classId === 'fighter' || classId === 'ranger' || classId === 'paladin';
  if (con === 17) return isFighter ? 3 : 2;
  if (con >= 18) return isFighter ? 4 : 2;
  return 0;
}

export function getXpForNextLevel(classId, currentLevel) {
  const cls = CLASSES[classId];
  if (!cls || !cls.xpTable) return Infinity;
  return cls.xpTable[currentLevel + 1] || Infinity;
}

export function checkLevelUp(character) {
  const needed = getXpForNextLevel(character.classId, character.level);
  return character.xp >= needed;
}
