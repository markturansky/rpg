import { roll } from '../utils/dice.js';

export function canBuildStronghold(character) {
  const nameLevel = { fighter: 9, cleric: 9, 'magic-user': 11, thief: 10 };
  return character.level >= (nameLevel[character.classId] || 9);
}

export function createStronghold(character) {
  return {
    ownerId: character.name,
    structures: [],
    population: 0,
    monthsElapsed: 0,
    followers: [],
    gold: 0,
  };
}

export function calculateMonthlyIncome(stronghold) {
  return Math.floor(stronghold.population / 2);
}

export function calculateMaintenanceCost(stronghold) {
  let cost = 0;
  for (const s of stronghold.structures) {
    cost += Math.floor(s.constructionCost * 0.01);
  }
  return cost;
}

export function rollDomainEvent() {
  const eventRoll = roll(1, 12);
  const EVENTS = [
    { roll: 1,  name: 'Monster incursion',       effect: 'lose_population', amount: 0.1 },
    { roll: 2,  name: 'Plague',                   effect: 'lose_population', amount: 0.2 },
    { roll: 3,  name: 'Bandit raids',             effect: 'lose_income',     amount: 1.0 },
    { roll: 4,  name: 'Poor harvest',             effect: 'lose_income',     amount: 0.5 },
    { roll: 5,  name: 'Trade caravan arrives',     effect: 'gain_income',     amount: 0.5 },
    { roll: 6,  name: 'Peaceful month',            effect: 'none',            amount: 0 },
    { roll: 7,  name: 'Peaceful month',            effect: 'none',            amount: 0 },
    { roll: 8,  name: 'Peaceful month',            effect: 'none',            amount: 0 },
    { roll: 9,  name: 'Festival',                  effect: 'gain_population', amount: 0.1 },
    { roll: 10, name: 'New settlers',              effect: 'gain_families',   amount: roll(1, 6) * 5 },
    { roll: 11, name: 'Merchant guild interest',   effect: 'permanent_bonus', amount: 0.1 },
    { roll: 12, name: 'Heroic reputation',         effect: 'gain_families',   amount: roll(2, 6) * 5 },
  ];
  return EVENTS[eventRoll - 1];
}
