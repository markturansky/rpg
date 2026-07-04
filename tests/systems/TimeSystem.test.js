import { describe, it, expect } from 'vitest';
import { createTimeState, advanceTime, getTimeOfDay, isNight, needsRest, consumeRation } from '../../src/systems/TimeSystem.js';

describe('createTimeState', () => {
  it('returns initial state at 8am day 1', () => {
    const state = createTimeState();
    expect(state.hour).toBe(8);
    expect(state.totalDays).toBe(1);
    expect(state.travelHoursToday).toBe(0);
  });
});

describe('advanceTime', () => {
  it('advances hours correctly', () => {
    const state = createTimeState();
    advanceTime(state, 3);
    expect(state.hour).toBe(11);
    expect(state.travelHoursToday).toBe(3);
  });

  it('wraps past midnight correctly', () => {
    const state = createTimeState();
    advanceTime(state, 20);
    expect(state.hour).toBe(4);
    expect(state.totalDays).toBe(2);
    expect(state.travelHoursToday).toBe(0);
  });

  it('handles multiple day wraps', () => {
    const state = createTimeState();
    advanceTime(state, 48);
    expect(state.totalDays).toBe(3);
  });
});

describe('getTimeOfDay', () => {
  it('returns Dawn for 7am', () => {
    expect(getTimeOfDay(7).label).toBe('Dawn');
  });

  it('returns Day for noon', () => {
    expect(getTimeOfDay(12).label).toBe('Day');
  });

  it('returns Dusk for 7pm', () => {
    expect(getTimeOfDay(19).label).toBe('Dusk');
  });

  it('returns Night for 11pm', () => {
    expect(getTimeOfDay(23).label).toBe('Night');
  });

  it('returns Night for 3am', () => {
    expect(getTimeOfDay(3).label).toBe('Night');
  });
});

describe('isNight', () => {
  it('returns false during daytime', () => {
    expect(isNight(12)).toBe(false);
    expect(isNight(8)).toBe(false);
  });

  it('returns true at night', () => {
    expect(isNight(22)).toBe(true);
    expect(isNight(3)).toBe(true);
  });
});

describe('needsRest', () => {
  it('returns false when travel hours are low', () => {
    expect(needsRest({ travelHoursToday: 4 })).toBe(false);
  });

  it('returns true after 8 hours of travel', () => {
    expect(needsRest({ travelHoursToday: 8 })).toBe(true);
  });
});

describe('consumeRation', () => {
  it('consumes one ration', () => {
    const inv = [{ id: 'rations', quantity: 5 }];
    expect(consumeRation(inv)).toBe(true);
    expect(inv[0].quantity).toBe(4);
  });

  it('removes rations entry when last one consumed', () => {
    const inv = [{ id: 'rations', quantity: 1 }];
    consumeRation(inv);
    expect(inv).toHaveLength(0);
  });

  it('returns false when no rations', () => {
    expect(consumeRation([])).toBe(false);
  });
});
