import Phaser from 'phaser';
import { SCENE_KEYS, GAME_WIDTH, GAME_HEIGHT } from '../constants.js';

export class CharCreateScene extends Phaser.Scene {
  constructor() {
    super(SCENE_KEYS.CHAR_CREATE);
  }

  create() {
    this.add.text(GAME_WIDTH / 2, GAME_HEIGHT / 2, 'Character Creation\n(Coming Soon)\n\nPress ENTER to start', {
      fontSize: '24px',
      color: '#ffffff',
      align: 'center',
    }).setOrigin(0.5);

    this.input.keyboard.on('keydown-ENTER', () => {
      this.scene.start(SCENE_KEYS.WORLD);
      this.scene.launch(SCENE_KEYS.HUD);
    });
  }
}
