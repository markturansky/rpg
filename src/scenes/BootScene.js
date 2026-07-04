import Phaser from 'phaser';
import { SCENE_KEYS } from '../constants.js';

export class BootScene extends Phaser.Scene {
  constructor() {
    super(SCENE_KEYS.BOOT);
  }

  preload() {
  }

  create() {
    this.scene.start(SCENE_KEYS.CHAR_CREATE);
  }
}
