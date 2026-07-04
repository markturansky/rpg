import { SPELLS } from '../data/spells.js';

const MAGE_SLOTS = {
  1: [1], 2: [2], 3: [2, 1], 4: [3, 2], 5: [3, 2, 1],
};

const CLERIC_SLOTS = {
  1: [1], 2: [2], 3: [2, 1], 4: [3, 2], 5: [3, 2, 1],
};

export function getSpellSlots(classId, level, wisScore) {
  let slots;
  if (classId === 'magic-user') {
    slots = [...(MAGE_SLOTS[level] || [])];
  } else if (classId === 'cleric') {
    slots = [...(CLERIC_SLOTS[level] || [])];
    if (wisScore >= 13 && slots.length >= 1) slots[0] += 1;
    if (wisScore >= 14 && slots.length >= 1) slots[0] += 1;
    if (wisScore >= 15 && slots.length >= 2) slots[1] += 1;
    if (wisScore >= 16 && slots.length >= 2) slots[1] += 1;
    if (wisScore >= 17 && slots.length >= 3) slots[2] += 1;
  } else {
    slots = [];
  }
  return slots;
}

export function getAvailableSpells(classId, level) {
  return SPELLS.filter(s => s.classId === classId && s.spellLevel <= level);
}

export function memorizeSpell(character, spellId) {
  character.spellsMemorized.push(spellId);
}

export function castSpell(character, spellId) {
  const idx = character.spellsMemorized.indexOf(spellId);
  if (idx === -1) return null;
  character.spellsMemorized.splice(idx, 1);
  return SPELLS.find(s => s.id === spellId);
}
