import { TIME_OF_DAY } from '../constants.js';

export function createTimeState() {
  return {
    dayElapsed: 0,
    totalDays: 1,
    hour: 8,
    rationsConsumed: 0,
    lastRestDay: 0,
    travelHoursToday: 0,
  };
}

export function advanceTime(timeState, hours) {
  timeState.hour += hours;
  timeState.travelHoursToday += hours;

  while (timeState.hour >= 24) {
    timeState.hour -= 24;
    timeState.totalDays += 1;
    timeState.travelHoursToday = 0;
  }

  timeState.dayElapsed = timeState.hour / 24;
}

export function getTimeOfDay(hour) {
  for (const [key, period] of Object.entries(TIME_OF_DAY)) {
    if (period.start < period.end) {
      if (hour >= period.start && hour < period.end) return period;
    } else {
      if (hour >= period.start || hour < period.end) return period;
    }
  }
  return TIME_OF_DAY.DAY;
}

export function isNight(hour) {
  return hour >= 20 || hour < 6;
}

export function needsRest(timeState) {
  return timeState.travelHoursToday >= 8;
}

export function consumeRation(inventory) {
  const rationIdx = inventory.findIndex(i => i.id === 'rations');
  if (rationIdx === -1) return false;
  const rations = inventory[rationIdx];
  if (rations.quantity > 1) {
    rations.quantity -= 1;
  } else {
    inventory.splice(rationIdx, 1);
  }
  return true;
}
