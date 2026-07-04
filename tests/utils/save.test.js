import { describe, it, expect, beforeEach, vi } from 'vitest';
import { saveGame, loadGame, deleteSave, hasSave } from '../../src/utils/save.js';

const mockStorage = {};
const localStorageMock = {
  getItem: vi.fn((key) => mockStorage[key] || null),
  setItem: vi.fn((key, val) => { mockStorage[key] = val; }),
  removeItem: vi.fn((key) => { delete mockStorage[key]; }),
};

vi.stubGlobal('localStorage', localStorageMock);

beforeEach(() => {
  Object.keys(mockStorage).forEach(k => delete mockStorage[k]);
  vi.clearAllMocks();
});

describe('saveGame', () => {
  it('saves game state to localStorage', () => {
    const state = { character: { name: 'Test', level: 1 } };
    expect(saveGame(state)).toBe(true);
    expect(localStorageMock.setItem).toHaveBeenCalled();
  });
});

describe('loadGame', () => {
  it('returns null when no save exists', () => {
    expect(loadGame()).toBeNull();
  });

  it('round-trips save and load', () => {
    const state = { character: { name: 'Hero', hp: 10 } };
    saveGame(state);
    const loaded = loadGame();
    expect(loaded).toEqual(state);
  });
});

describe('deleteSave', () => {
  it('removes save from localStorage', () => {
    saveGame({ test: true });
    deleteSave();
    expect(loadGame()).toBeNull();
  });
});

describe('hasSave', () => {
  it('returns false when no save exists', () => {
    expect(hasSave()).toBe(false);
  });

  it('returns true after saving', () => {
    saveGame({ test: true });
    expect(hasSave()).toBe(true);
  });
});
