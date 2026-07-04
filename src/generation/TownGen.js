export function generateTown(col, row, seed) {
  const townSeed = hashCoords(col, row, seed);
  const name = generateTownName(townSeed);

  return {
    name,
    col,
    row,
    buildings: generateBuildings(townSeed),
    npcs: generateNPCs(townSeed, name),
  };
}

function generateBuildings(seed) {
  return [
    { type: 'inn',       name: 'The Weary Traveler', col: 20, row: 15 },
    { type: 'market',    name: 'Market Square',      col: 25, row: 25 },
    { type: 'smithy',    name: 'Iron Anvil',          col: 30, row: 20 },
    { type: 'chapel',    name: 'Temple of Light',     col: 15, row: 30 },
    { type: 'town-hall', name: 'Town Hall',           col: 25, row: 15 },
  ];
}

function generateNPCs(seed, townName) {
  return [
    { name: 'Innkeeper', role: 'innkeeper', dialog: `Welcome to ${townName}! Rest here for 5 gold.` },
    { name: 'Merchant',  role: 'merchant',  dialog: 'Care to see my wares?' },
    { name: 'Smith',     role: 'smith',     dialog: 'I can forge or repair your equipment.' },
    { name: 'Priest',    role: 'priest',    dialog: 'May the light guide you. I can heal your wounds.' },
    { name: 'Mayor',     role: 'mayor',     dialog: 'Check the bounty board for work.' },
  ];
}

function generateTownName(seed) {
  const prefixes = ['Oak', 'Iron', 'Stone', 'River', 'Wolf', 'Raven', 'Storm', 'Dawn', 'Frost', 'Shadow'];
  const suffixes = ['haven', 'ford', 'wick', 'dale', 'gate', 'hold', 'bury', 'bridge', 'moor', 'fell'];
  const pi = seed % prefixes.length;
  const si = Math.floor(seed / 10) % suffixes.length;
  return prefixes[pi] + suffixes[si];
}

function hashCoords(col, row, seed) {
  return ((col * 73856093) ^ (row * 19349663) ^ (seed * 83492791)) & 0x7fffffff;
}
