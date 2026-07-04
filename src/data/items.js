export const ITEMS = {
  'healing-potion':  { id: 'healing-potion',  name: 'Healing Potion',   cost: 50,   weight: 0.5, stackable: true,  effect: 'heal',     value: '2d4+2' },
  antidote:          { id: 'antidote',         name: 'Antidote',         cost: 25,   weight: 0.5, stackable: true,  effect: 'cure_poison' },
  rations:           { id: 'rations',          name: 'Rations (1 day)',  cost: 1,    weight: 1,   stackable: true,  effect: 'food' },
  torch:             { id: 'torch',            name: 'Torch',            cost: 0.01, weight: 1,   stackable: true,  effect: 'light',    lightRadius: 40, duration: 6 },
  'bullseye-lantern': { id: 'bullseye-lantern', name: 'Bullseye Lantern', cost: 12, weight: 2,   stackable: false, effect: 'light',    lightRadius: 80, duration: 24 },
  'oil-flask':       { id: 'oil-flask',        name: 'Oil Flask',        cost: 1,    weight: 1,   stackable: true,  effect: 'fuel_or_fire', fireDamage: '2d6' },
  rope:              { id: 'rope',             name: 'Rope (50 ft)',     cost: 1,    weight: 5,   stackable: false, effect: 'utility' },
  'ten-foot-pole':   { id: 'ten-foot-pole',    name: '10 ft Pole',       cost: 0.2,  weight: 8,   stackable: false, effect: 'utility' },
  'holy-water':      { id: 'holy-water',       name: 'Holy Water',       cost: 25,   weight: 0.5, stackable: true,  effect: 'damage_undead', damage: '2d4' },
  'thieves-tools':   { id: 'thieves-tools',    name: "Thieves' Tools",   cost: 30,   weight: 1,   stackable: false, effect: 'skill_tool' },
  arrows:            { id: 'arrows',           name: 'Arrows (20)',      cost: 5,    weight: 1,   stackable: true,  effect: 'ammunition', ammoType: 'bow' },
  bolts:             { id: 'bolts',            name: 'Bolts (20)',       cost: 5,    weight: 1,   stackable: true,  effect: 'ammunition', ammoType: 'crossbow' },
};
