import Phaser from 'phaser';
import { SCENE_KEYS } from '../constants.js';

export class HUDScene extends Phaser.Scene {
  constructor() {
    super(SCENE_KEYS.HUD);
  }

  create() {
    this.hpText = this.add.text(16, 16, 'HP: --/--', { fontSize: '16px', color: '#ffffff' });
    this.levelText = this.add.text(16, 40, 'Level: 1 Fighter', { fontSize: '14px', color: '#cccccc' });
    this.timeText = this.add.text(16, 680, 'Day 1 - Dawn', { fontSize: '14px', color: '#f0c040' });
    this.terrainText = this.add.text(16, 700, 'Plains', { fontSize: '14px', color: '#a8c256' });
  }

  updateHUD(gameState) {
    if (!gameState) return;
    if (gameState.character) {
      const c = gameState.character;
      this.hpText.setText(`HP: ${c.hp}/${c.maxHp}`);
      this.levelText.setText(`Level: ${c.level} ${c.className}`);
    }
  }
}
