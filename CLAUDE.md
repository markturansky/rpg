# Hex World RPG - Project Conventions

## Commands
- `npm run dev` — Start dev server
- `npm run build` — Production build
- `npm run preview` — Preview production build

## Architecture
- **Framework:** Phaser 4 + Vite (ES modules)
- **Import pattern:** `import Phaser from 'phaser'` (default import)
- **File size target:** 300-500 lines per file max. If a file exceeds 500 lines, split it.
- **No comments in code** unless explicitly requested.

## Directory Structure
- `src/scenes/` — Phaser scenes (one per zoom tier + Boot, CharCreate, HUD)
- `src/systems/` — Stateless game logic functions (combat, movement, spells, etc.)
- `src/data/` — Pure data tables (classes, ancestries, weapons, armor, spells, monsters, items)
- `src/generation/` — Procedural generation (world, tier sub-hex, towns, tile cache)
- `src/utils/` — Utilities (dice rolling, hex math, save/load)
- `skills/` — Phaser 4 AI reference docs (read-only, not shipped)

## Conventions
- Systems export pure functions, not classes. They receive gameState as a parameter.
- Data files export const objects/arrays — no logic.
- Scenes extend `Phaser.Scene` with ES6 class syntax.
- Scene keys are defined in `src/constants.js` as `SCENE_KEYS`.
- Use semantic naming throughout.
- Game rules follow OSRIC 3.0 / AD&D 1e as specified in PROPOSAL.md.

## Game Design Reference
- See PROPOSAL.md for complete game design specification.
- See skills/ directory for Phaser 4 API reference (SKILL.md files).
