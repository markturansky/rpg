export function roll(count, sides) {
  let total = 0;
  for (let i = 0; i < count; i++) {
    total += Math.floor(Math.random() * sides) + 1;
  }
  return total;
}

export function rollDetailed(count, sides) {
  const results = [];
  for (let i = 0; i < count; i++) {
    results.push(Math.floor(Math.random() * sides) + 1);
  }
  return { total: results.reduce((a, b) => a + b, 0), rolls: results };
}

export function rollPercentile() {
  return roll(1, 100);
}

export function parseDiceString(str) {
  const match = str.match(/^(\d+)d(\d+)([+-]\d+)?$/);
  if (!match) return null;
  const count = parseInt(match[1]);
  const sides = parseInt(match[2]);
  const modifier = match[3] ? parseInt(match[3]) : 0;
  return roll(count, sides) + modifier;
}
