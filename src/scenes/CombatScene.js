import Phaser from 'phaser';
import { SCENE_KEYS, GAME_WIDTH, GAME_HEIGHT } from '../constants.js';

export class CombatScene extends Phaser.Scene {
  constructor() {
    super(SCENE_KEYS.COMBAT);
  }

  create() {
    this.add.text(GAME_WIDTH / 2, GAME_HEIGHT / 2, 'Tactical Combat\n(1 square = 5 feet)', {
      fontSize: '20px',
      color: '#c0392b',
      align: 'center',
    }).setOrigin(0.5);
  }

  update(time, delta) {
  }
}
