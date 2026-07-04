import { TILE_CACHE_MAX } from '../constants.js';

export class TileCache {
  constructor(maxSize = TILE_CACHE_MAX) {
    this.maxSize = maxSize;
    this.cache = new Map();
  }

  makeKey(tier, col, row) {
    return `${tier}:${col}:${row}`;
  }

  get(tier, col, row) {
    const key = this.makeKey(tier, col, row);
    const entry = this.cache.get(key);
    if (!entry) return null;

    this.cache.delete(key);
    this.cache.set(key, entry);
    return entry;
  }

  set(tier, col, row, data) {
    const key = this.makeKey(tier, col, row);

    if (this.cache.has(key)) {
      this.cache.delete(key);
    } else if (this.cache.size >= this.maxSize) {
      const oldest = this.cache.keys().next().value;
      this.cache.delete(oldest);
    }

    this.cache.set(key, data);
  }

  has(tier, col, row) {
    return this.cache.has(this.makeKey(tier, col, row));
  }

  clear() {
    this.cache.clear();
  }

  get size() {
    return this.cache.size;
  }
}
