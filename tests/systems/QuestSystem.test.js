import { describe, it, expect } from 'vitest';
import { createQuest, updateQuestProgress, getQuestReward } from '../../src/systems/QuestSystem.js';

describe('createQuest', () => {
  it('creates a quest with required fields', () => {
    const quest = createQuest('kill', { targetId: 'goblin', goal: 5, rewardGold: 100, rewardXp: 200 });
    expect(quest.type).toBe('kill');
    expect(quest.status).toBe('active');
    expect(quest.progress).toBe(0);
    expect(quest.targetId).toBe('goblin');
    expect(quest.goal).toBe(5);
    expect(quest.id).toBeDefined();
  });

  it('generates unique IDs', () => {
    const q1 = createQuest('kill', { targetId: 'goblin', goal: 1 });
    const q2 = createQuest('kill', { targetId: 'goblin', goal: 1 });
    expect(q1.id).not.toBe(q2.id);
  });
});

describe('updateQuestProgress', () => {
  it('increments kill quest progress', () => {
    const quest = createQuest('kill', { targetId: 'goblin', goal: 3 });
    updateQuestProgress(quest, { type: 'kill', monsterId: 'goblin', count: 1 });
    expect(quest.progress).toBe(1);
  });

  it('ignores wrong monster type', () => {
    const quest = createQuest('kill', { targetId: 'goblin', goal: 3 });
    updateQuestProgress(quest, { type: 'kill', monsterId: 'orc', count: 1 });
    expect(quest.progress).toBe(0);
  });

  it('marks quest complete when goal reached', () => {
    const quest = createQuest('kill', { targetId: 'goblin', goal: 2 });
    updateQuestProgress(quest, { type: 'kill', monsterId: 'goblin', count: 1 });
    const completed = updateQuestProgress(quest, { type: 'kill', monsterId: 'goblin', count: 1 });
    expect(completed).toBe(true);
    expect(quest.status).toBe('complete');
  });

  it('does not update completed quests', () => {
    const quest = createQuest('kill', { targetId: 'goblin', goal: 1 });
    quest.status = 'complete';
    const result = updateQuestProgress(quest, { type: 'kill', monsterId: 'goblin', count: 1 });
    expect(result).toBe(false);
  });

  it('handles fetch quests', () => {
    const quest = createQuest('fetch', { targetId: 'gem', goal: 1 });
    const completed = updateQuestProgress(quest, { type: 'fetch', itemId: 'gem' });
    expect(completed).toBe(true);
  });

  it('handles explore quests', () => {
    const quest = createQuest('explore', { goal: 3 });
    updateQuestProgress(quest, { type: 'explore' });
    updateQuestProgress(quest, { type: 'explore' });
    const completed = updateQuestProgress(quest, { type: 'explore' });
    expect(completed).toBe(true);
  });
});

describe('getQuestReward', () => {
  it('returns reward values', () => {
    const quest = createQuest('kill', { rewardGold: 100, rewardXp: 500, rewardItems: ['healing-potion'] });
    const reward = getQuestReward(quest);
    expect(reward.gold).toBe(100);
    expect(reward.xp).toBe(500);
    expect(reward.items).toContain('healing-potion');
  });

  it('defaults to 0 for missing rewards', () => {
    const quest = createQuest('kill', {});
    const reward = getQuestReward(quest);
    expect(reward.gold).toBe(0);
    expect(reward.xp).toBe(0);
    expect(reward.items).toEqual([]);
  });
});
