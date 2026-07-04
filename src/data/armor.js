export const ARMOR = {
  unarmored:        { name: 'Unarmored',        ac: 10, weight: 0,  cost: 0,   moveCap: 120 },
  leather:          { name: 'Leather',          ac: 12, weight: 15, cost: 5,   moveCap: 120 },
  'studded-leather': { name: 'Studded Leather', ac: 13, weight: 20, cost: 15,  moveCap: 120 },
  'scale-mail':     { name: 'Scale Mail',       ac: 14, weight: 40, cost: 45,  moveCap: 60 },
  'chain-mail':     { name: 'Chain Mail',       ac: 15, weight: 30, cost: 75,  moveCap: 90 },
  'banded-mail':    { name: 'Banded Mail',      ac: 16, weight: 35, cost: 200, moveCap: 90 },
  'plate-mail':     { name: 'Plate Mail',       ac: 17, weight: 45, cost: 400, moveCap: 60 },
};

export const SHIELDS = {
  'small-shield':   { name: 'Small Shield',     acBonus: 1, weight: 5,  cost: 10 },
  'large-shield':   { name: 'Large Shield',     acBonus: 1, weight: 10, cost: 15 },
};
