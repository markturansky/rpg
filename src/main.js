import Phaser from 'phaser';
import { GAME_WIDTH, GAME_HEIGHT, SCENE_KEYS } from './constants.js';
import { BootScene } from './scenes/BootScene.js';
import { CharCreateScene } from './scenes/CharCreateScene.js';
import { WorldScene } from './scenes/WorldScene.js';
import { RegionalScene } from './scenes/RegionalScene.js';
import { LocalScene } from './scenes/LocalScene.js';
import { TownScene } from './scenes/TownScene.js';
import { CombatScene } from './scenes/CombatScene.js';
import { HUDScene } from './scenes/HUDScene.js';

const config = {
  type: Phaser.AUTO,
  width: GAME_WIDTH,
  height: GAME_HEIGHT,
  parent: document.body,
  backgroundColor: '#111111',
  scene: [
    BootScene,
    CharCreateScene,
    WorldScene,
    RegionalScene,
    LocalScene,
    TownScene,
    CombatScene,
    HUDScene,
  ],
  scale: {
    mode: Phaser.Scale.FIT,
    autoCenter: Phaser.Scale.CENTER_BOTH,
  },
  physics: {
    default: 'arcade',
    arcade: {
      debug: false,
    },
  },
};

const game = new Phaser.Game(config);
