export function addItem(inventory, item) {
  const existing = inventory.find(i => i.id === item.id && i.stackable);
  if (existing) {
    existing.quantity = (existing.quantity || 1) + (item.quantity || 1);
  } else {
    inventory.push({ ...item, quantity: item.quantity || 1 });
  }
}

export function removeItem(inventory, itemId, quantity = 1) {
  const idx = inventory.findIndex(i => i.id === itemId);
  if (idx === -1) return false;
  const item = inventory[idx];
  if (item.stackable && item.quantity > quantity) {
    item.quantity -= quantity;
  } else {
    inventory.splice(idx, 1);
  }
  return true;
}

export function getTotalWeight(inventory) {
  return inventory.reduce((sum, item) => sum + (item.weight || 0) * (item.quantity || 1), 0);
}

export function getEncumbrancePenalty(totalWeight, strAllowance) {
  const excess = totalWeight - strAllowance;
  if (excess <= 0) return 1.0;
  if (excess <= 40) return 0.75;
  if (excess <= 80) return 0.5;
  if (excess <= 120) return 0.25;
  return 0;
}

export function getBaseCarryCapacity(str) {
  if (str <= 5) return 35;
  if (str <= 7) return 45;
  if (str <= 9) return 55;
  if (str <= 11) return 70;
  if (str <= 13) return 85;
  if (str <= 15) return 100;
  if (str === 16) return 110;
  if (str === 17) return 130;
  return 150;
}
