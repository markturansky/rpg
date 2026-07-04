import Phaser from 'phaser';
import { SCENE_KEYS, GAME_WIDTH, GAME_HEIGHT } from '../constants.js';

export class LocalScene extends Phaser.Scene {
  constructor() {
    super(SCENE_KEYS.LOCAL);
  }

  create() {
    this.add.text(GAME_WIDTH / 2, GAME_HEIGHT / 2, 'Local Map\n(1 hex = 200 feet)', {
      fontSize: '20px',
      color: '#2d6a1e',
      align: 'center',
    }).setOrigin(0.5);
  }

  update(time, delta) {
  }
}
