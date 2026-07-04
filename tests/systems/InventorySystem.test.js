import { describe, it, expect } from 'vitest';
import { addItem, removeItem, getTotalWeight, getEncumbrancePenalty, getBaseCarryCapacity } from '../../src/systems/InventorySystem.js';

describe('addItem', () => {
  it('adds a new item to empty inventory', () => {
    const inv = [];
    addItem(inv, { id: 'sword', name: 'Sword', weight: 6 });
    expect(inv).toHaveLength(1);
    expect(inv[0].id).toBe('sword');
  });

  it('stacks stackable items', () => {
    const inv = [];
    addItem(inv, { id: 'arrows', name: 'Arrows', weight: 1, stackable: true, quantity: 20 });
    addItem(inv, { id: 'arrows', name: 'Arrows', weight: 1, stackable: true, quantity: 20 });
    expect(inv).toHaveLength(1);
    expect(inv[0].quantity).toBe(40);
  });

  it('does not stack non-stackable items', () => {
    const inv = [];
    addItem(inv, { id: 'sword', name: 'Sword', weight: 6 });
    addItem(inv, { id: 'sword', name: 'Sword', weight: 6 });
    expect(inv).toHaveLength(2);
  });
});

describe('removeItem', () => {
  it('removes an item from inventory', () => {
    const inv = [{ id: 'sword', name: 'Sword', weight: 6, quantity: 1 }];
    expect(removeItem(inv, 'sword')).toBe(true);
    expect(inv).toHaveLength(0);
  });

  it('decrements stackable items', () => {
    const inv = [{ id: 'arrows', name: 'Arrows', stackable: true, quantity: 20 }];
    removeItem(inv, 'arrows', 5);
    expect(inv[0].quantity).toBe(15);
  });

  it('returns false for missing items', () => {
    expect(removeItem([], 'nonexistent')).toBe(false);
  });

  it('removes stackable item entirely when quantity reaches 0', () => {
    const inv = [{ id: 'arrows', name: 'Arrows', stackable: true, quantity: 1 }];
    removeItem(inv, 'arrows', 1);
    expect(inv).toHaveLength(0);
  });
});

describe('getTotalWeight', () => {
  it('returns 0 for empty inventory', () => {
    expect(getTotalWeight([])).toBe(0);
  });

  it('sums weights correctly', () => {
    const inv = [
      { id: 'sword', weight: 6, quantity: 1 },
      { id: 'arrows', weight: 1, quantity: 20 },
    ];
    expect(getTotalWeight(inv)).toBe(26);
  });
});

describe('getEncumbrancePenalty', () => {
  it('returns 1.0 when under allowance', () => {
    expect(getEncumbrancePenalty(50, 100)).toBe(1.0);
  });

  it('returns 0.75 for slight overload', () => {
    expect(getEncumbrancePenalty(110, 100)).toBe(0.75);
  });

  it('returns 0.5 for moderate overload', () => {
    expect(getEncumbrancePenalty(150, 100)).toBe(0.5);
  });

  it('returns 0.25 for heavy overload', () => {
    expect(getEncumbrancePenalty(200, 100)).toBe(0.25);
  });

  it('returns 0 when immobilized', () => {
    expect(getEncumbrancePenalty(250, 100)).toBe(0);
  });
});

describe('getBaseCarryCapacity', () => {
  it('returns low capacity for low STR', () => {
    expect(getBaseCarryCapacity(3)).toBe(35);
  });

  it('returns medium capacity for average STR', () => {
    expect(getBaseCarryCapacity(10)).toBe(70);
  });

  it('returns high capacity for high STR', () => {
    expect(getBaseCarryCapacity(18)).toBe(150);
  });

  it('increases monotonically with STR', () => {
    let prev = 0;
    for (let str = 3; str <= 18; str++) {
      const cap = getBaseCarryCapacity(str);
      expect(cap).toBeGreaterThanOrEqual(prev);
      prev = cap;
    }
  });
});
