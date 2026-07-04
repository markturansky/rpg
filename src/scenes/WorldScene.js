import Phaser from 'phaser';
import { SCENE_KEYS, GAME_WIDTH, GAME_HEIGHT } from '../constants.js';

export class WorldScene extends Phaser.Scene {
  constructor() {
    super(SCENE_KEYS.WORLD);
  }

  create() {
    this.add.text(GAME_WIDTH / 2, GAME_HEIGHT / 2, 'World Map\n(1 hex = 6 miles)', {
      fontSize: '20px',
      color: '#a8c256',
      align: 'center',
    }).setOrigin(0.5);
  }

  update(time, delta) {
  }
}
