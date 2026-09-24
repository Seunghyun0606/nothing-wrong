# Nothing Wrong

QA investigation simulation game. The repository contains the complete T01 first
playable: a refresh-safe journey from Company login through Shoply testing, Evidence,
Bug Report, deterministic QA Review, progression, and resolved Dashboard return.

## Requirements

- Node.js 24 or another version supported by the locked Vite toolchain
- npm 11+

## Local Development

```bash
npm install
npm run dev
```

The development server prints its local URL. The bootstrap route is `/start`.

## First Playable

The implemented journey is:

```text
Start Work → Login → Dashboard → T01 Ticket → Shoply Test
→ Evidence Capture → Bug Report → QA Review → Resolved Dashboard
```

T01 introduces a Scenario-driven `WRONG_STYLE` Mutation on
`checkout.confirmButton`. Shoply remains a normal purchase flow when no Mutation is
active.

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

See [docs/development/TESTING.md](docs/development/TESTING.md) for the critical-flow
checklist, architecture acceptance evidence, and manual verification procedure.

## Module Boundaries

- `src/app`: application composition, providers, and the main router
- `src/game`: framework-independent game domain and engines
- `src/products`: normal Fake Product implementations
- `src/scenarios`: data-driven Ticket content
- `src/pages`: game-level route pages
- `src/components`: shared game, Fake Browser, QA tool, and common UI
- `src/persistence`: versioned storage adapters

Ticket content and defects belong to `src/scenarios`; normal Product components must
not branch on Ticket IDs. Review, progression, and Mutation logic remain testable
outside React, while browser storage access stays behind `src/persistence` adapters.
