import { describe, it, expect } from 'vitest';
import { TileCache } from '../../src/generation/TileCache.js';

describe('TileCache', () => {
  it('stores and retrieves data', () => {
    const cache = new TileCache(10);
    cache.set('world', 5, 3, { terrain: 'forest' });
    expect(cache.get('world', 5, 3)).toEqual({ terrain: 'forest' });
  });

  it('returns null for missing entries', () => {
    const cache = new TileCache(10);
    expect(cache.get('world', 0, 0)).toBeNull();
  });

  it('evicts oldest entry when full', () => {
    const cache = new TileCache(3);
    cache.set('world', 0, 0, 'a');
    cache.set('world', 1, 0, 'b');
    cache.set('world', 2, 0, 'c');
    cache.set('world', 3, 0, 'd');

    expect(cache.get('world', 0, 0)).toBeNull();
    expect(cache.get('world', 3, 0)).toBe('d');
    expect(cache.size).toBe(3);
  });

  it('updates LRU order on get', () => {
    const cache = new TileCache(3);
    cache.set('world', 0, 0, 'a');
    cache.set('world', 1, 0, 'b');
    cache.set('world', 2, 0, 'c');

    cache.get('world', 0, 0);
    cache.set('world', 3, 0, 'd');

    expect(cache.get('world', 0, 0)).toBe('a');
    expect(cache.get('world', 1, 0)).toBeNull();
  });

  it('has() works correctly', () => {
    const cache = new TileCache(5);
    expect(cache.has('world', 0, 0)).toBe(false);
    cache.set('world', 0, 0, 'data');
    expect(cache.has('world', 0, 0)).toBe(true);
  });

  it('clear() empties the cache', () => {
    const cache = new TileCache(5);
    cache.set('world', 0, 0, 'a');
    cache.set('world', 1, 0, 'b');
    cache.clear();
    expect(cache.size).toBe(0);
    expect(cache.get('world', 0, 0)).toBeNull();
  });

  it('overwrites existing keys', () => {
    const cache = new TileCache(5);
    cache.set('world', 0, 0, 'old');
    cache.set('world', 0, 0, 'new');
    expect(cache.get('world', 0, 0)).toBe('new');
    expect(cache.size).toBe(1);
  });
});
