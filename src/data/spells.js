export const SPELLS = [
  { id: 'magic-missile',  classId: 'magic-user', spellLevel: 1, name: 'Magic Missile',  description: 'Auto-hit, 1d4+1 damage. +1 missile at levels 3 and 5.',          castingTime: 1,  range: 60,  duration: 'instant' },
  { id: 'sleep',           classId: 'magic-user', spellLevel: 1, name: 'Sleep',           description: '2d8 HD of creatures fall asleep (no save for ≤4 HD).',            castingTime: 1,  range: 60,  duration: '5 rounds/level' },
  { id: 'shield',          classId: 'magic-user', spellLevel: 1, name: 'Shield',          description: '+4 AC for the encounter.',                                        castingTime: 1,  range: 0,   duration: 'encounter' },
  { id: 'web',             classId: 'magic-user', spellLevel: 2, name: 'Web',             description: 'Immobilize enemies for 1d4 rounds (save negates).',               castingTime: 2,  range: 30,  duration: '1d4 rounds' },
  { id: 'mirror-image',    classId: 'magic-user', spellLevel: 2, name: 'Mirror Image',    description: '1d4 illusory duplicates absorb attacks.',                          castingTime: 2,  range: 0,   duration: 'encounter' },
  { id: 'invisibility',    classId: 'magic-user', spellLevel: 2, name: 'Invisibility',    description: 'Invisible until attacking. Guaranteed surprise round.',             castingTime: 2,  range: 0,   duration: 'until attack' },
  { id: 'fireball',        classId: 'magic-user', spellLevel: 3, name: 'Fireball',        description: '6d6 damage in area (save for half).',                              castingTime: 3,  range: 100, duration: 'instant' },
  { id: 'lightning-bolt',  classId: 'magic-user', spellLevel: 3, name: 'Lightning Bolt',  description: '6d6 damage in line (save for half).',                              castingTime: 3,  range: 60,  duration: 'instant' },
  { id: 'haste',           classId: 'magic-user', spellLevel: 3, name: 'Haste',           description: 'Double attacks for 3 rounds.',                                     castingTime: 3,  range: 60,  duration: '3 rounds' },

  { id: 'cure-light-wounds', classId: 'cleric',  spellLevel: 1, name: 'Cure Light Wounds', description: 'Touch, 1d8 HP, 5 segments casting time.',                         castingTime: 5,  range: 0,   duration: 'instant' },
  { id: 'bless',             classId: 'cleric',  spellLevel: 1, name: 'Bless',             description: '+1 attack and saves for the encounter.',                           castingTime: 1,  range: 60,  duration: 'encounter' },
  { id: 'command',           classId: 'cleric',  spellLevel: 1, name: 'Command',           description: 'One-word command for 1 round (save for INT 13+ or 6+ HD).',        castingTime: 1,  range: 30,  duration: '1 round' },
  { id: 'detect-evil',       classId: 'cleric',  spellLevel: 1, name: 'Detect Evil',       description: '120 ft path, concentration, 1 turn + 5 rounds/level.',             castingTime: 1,  range: 120, duration: '1 turn' },
  { id: 'light',             classId: 'cleric',  spellLevel: 1, name: 'Light',             description: '20 ft radius, 6 turns + 1/level.',                                 castingTime: 4,  range: 60,  duration: '6 turns' },
  { id: 'protection-evil',   classId: 'cleric',  spellLevel: 1, name: 'Protection from Evil', description: 'Touch, 3 rounds/level, -2 to evil attacks/+2 saves.',          castingTime: 4,  range: 0,   duration: '3 rounds/level' },

  { id: 'hold-person',       classId: 'cleric',  spellLevel: 2, name: 'Hold Person',       description: 'Paralyze 1 humanoid for 1d4 rounds (save negates).',               castingTime: 5,  range: 60,  duration: '1d4 rounds' },
  { id: 'silence',           classId: 'cleric',  spellLevel: 2, name: 'Silence',           description: 'No spellcasting in area for 1d6 rounds.',                          castingTime: 5,  range: 120, duration: '1d6 rounds' },
  { id: 'spiritual-weapon',  classId: 'cleric',  spellLevel: 2, name: 'Spiritual Weapon',  description: '1d6+1 damage, attacks on its own.',                                castingTime: 5,  range: 30,  duration: '1 round/level' },

  { id: 'cure-serious-wounds', classId: 'cleric', spellLevel: 3, name: 'Cure Serious Wounds', description: 'Heal 2d8+3 HP.',                                               castingTime: 7,  range: 0,   duration: 'instant' },
  { id: 'dispel-magic',       classId: 'cleric', spellLevel: 3, name: 'Dispel Magic',       description: 'Remove one magical effect.',                                      castingTime: 6,  range: 60,  duration: 'instant' },
  { id: 'prayer',             classId: 'cleric', spellLevel: 3, name: 'Prayer',             description: '+1 to all rolls for the party, -1 for enemies.',                   castingTime: 6,  range: 60,  duration: 'encounter' },
];
