import { roll } from '../utils/dice.js';
import { CLASSES } from '../data/classes.js';

export function rollInitiative() {
  return roll(1, 6);
}

export function getBTHB(classId, level) {
  const cls = CLASSES[classId];
  if (!cls || !cls.bthbProgression) return 0;
  const entries = cls.bthbProgression;
  let bthb = 0;
  for (const entry of entries) {
    if (level >= entry.level) bthb = entry.bonus;
  }
  return bthb;
}

export function resolveAttack(attacker, defender) {
  const bthb = getBTHB(attacker.classId, attacker.level);
  const strMod = getStrToHitMod(attacker.scores.str);
  const attackRoll = roll(1, 20);
  const total = attackRoll + bthb + strMod;
  const hit = total >= defender.ac;

  return {
    attackRoll,
    total,
    hit,
    critical: attackRoll === 20,
    fumble: attackRoll === 1,
  };
}

export function rollDamage(weaponDamage, strDamageMod) {
  const base = roll(weaponDamage.count, weaponDamage.die);
  return Math.max(1, base + (strDamageMod || 0));
}

export function checkMorale(monsterHD, conditionModifier = 0) {
  const baseMorale = 50 + (monsterHD * 5);
  const moraleRoll = roll(1, 100);
  return moraleRoll <= (baseMorale + conditionModifier);
}

export function checkSurprise() {
  return roll(1, 6) <= 2;
}

function getStrToHitMod(str) {
  if (str <= 3) return -3;
  if (str <= 5) return -2;
  if (str <= 7) return -1;
  if (str <= 16) return 0;
  if (str === 17) return 1;
  if (str >= 18) return 1;
  return 0;
}
