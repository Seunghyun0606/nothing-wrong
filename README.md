# Nothing Wrong

QA investigation simulation game. This repository is currently building the T01 first playable through Project OS.

## Requirements

- Node.js 24 or another version supported by the locked Vite toolchain
- npm 11+

## Local Development

```bash
npm install
npm run dev
```

The development server prints its local URL. The bootstrap route is `/start`.

## Verification

```bash
npm run typecheck
npm test
npm run build
npm run test:e2e:list
npm run test:e2e
```

Install the Playwright Chromium runtime once before the full end-to-end run if it is not already available:

```bash
npx playwright install chromium
```

## Module Boundaries

- `src/app`: application composition, providers, and the main router
- `src/game`: framework-independent game domain and engines
- `src/products`: normal Fake Product implementations
- `src/scenarios`: data-driven Ticket content
- `src/pages`: game-level route pages
- `src/components`: shared game, Fake Browser, QA tool, and common UI
- `src/persistence`: versioned storage adapters

TASK-001 intentionally contains only the build, routing, testing, and module foundation. Gameplay domain, Shoply, and T01 behavior belong to later tasks.
