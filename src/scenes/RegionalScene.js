import Phaser from 'phaser';
import { SCENE_KEYS, GAME_WIDTH, GAME_HEIGHT } from '../constants.js';

export class RegionalScene extends Phaser.Scene {
  constructor() {
    super(SCENE_KEYS.REGIONAL);
  }

  create() {
    this.add.text(GAME_WIDTH / 2, GAME_HEIGHT / 2, 'Regional Map\n(1 hex = 1 mile)', {
      fontSize: '20px',
      color: '#7daa4e',
      align: 'center',
    }).setOrigin(0.5);
  }

  update(time, delta) {
  }
}
