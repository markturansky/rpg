import Phaser from 'phaser';
import { SCENE_KEYS, GAME_WIDTH, GAME_HEIGHT } from '../constants.js';

export class TownScene extends Phaser.Scene {
  constructor() {
    super(SCENE_KEYS.TOWN);
  }

  create() {
    this.add.text(GAME_WIDTH / 2, GAME_HEIGHT / 2, 'Town\n(1 hex = 20 feet)', {
      fontSize: '20px',
      color: '#d4a574',
      align: 'center',
    }).setOrigin(0.5);
  }

  update(time, delta) {
  }
}
