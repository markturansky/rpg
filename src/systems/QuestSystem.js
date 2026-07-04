export function createQuest(type, params) {
  return {
    id: `quest_${Date.now()}_${Math.random().toString(36).slice(2, 6)}`,
    type,
    status: 'active',
    progress: 0,
    ...params,
  };
}

export function updateQuestProgress(quest, event) {
  if (quest.status !== 'active') return false;

  switch (quest.type) {
    case 'kill':
      if (event.type === 'kill' && event.monsterId === quest.targetId) {
        quest.progress += event.count || 1;
      }
      break;
    case 'fetch':
      if (event.type === 'fetch' && event.itemId === quest.targetId) {
        quest.progress = 1;
      }
      break;
    case 'explore':
      if (event.type === 'explore') {
        quest.progress += 1;
      }
      break;
  }

  if (quest.progress >= quest.goal) {
    quest.status = 'complete';
    return true;
  }
  return false;
}

export function getQuestReward(quest) {
  return {
    gold: quest.rewardGold || 0,
    xp: quest.rewardXp || 0,
    items: quest.rewardItems || [],
  };
}
