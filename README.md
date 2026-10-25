# Nothing Wrong

QA investigation game for Windows. The player is a new QA engineer: work arrives in
Messenger, the player tests a fake shop and later a client's migrated records in the
Browser, notes what breaks a requirement in QA Notes, reports it, and pieces together
what happened behind the work. The game ships Tickets T01–T42 in ten chapters and a final
release decision with three endings.

**The product is the Godot 4.7 client in [`godot/`](godot/README.md)** (DEC-008). Run,
build, test, and content instructions are in [godot/README.md](godot/README.md) and
[docs/development/TESTING.md](docs/development/TESTING.md). Project state and decisions
live in [PROJECT.md](PROJECT.md) and `.project-os/`; the story canon is
[docs/NOTHING_WRONG_ALL_IN_ONE.md](docs/NOTHING_WRONG_ALL_IN_ONE.md) and
[docs/story/CANON-MAP.md](docs/story/CANON-MAP.md).

## Frozen web prototype (reference only)

Everything below describes the first React/Vite prototype (T01–T04) in `src/`. It is kept
as a reference, is not updated, and is not the game. Do not develop it further.

### Requirements

- Node.js 24 or another version supported by the locked Vite toolchain
- npm 11+

### Local Development

```bash
npm install
npm run dev
```

The development server prints its local URL. The bootstrap route is `/start`.

### Current Prototype

The implemented journey is:

```text
Start Work → Login → Dashboard → T01 Ticket → Shoply Test
→ Evidence Capture → Bug Report → QA Review → Resolved Dashboard
→ T02 Ticket → Cart subtotal test → Evidence → Review → Resolved Dashboard
→ T03 Ticket → Cancel Order test → Evidence → Review → Resolved Dashboard
→ T04 Ticket → Gold coupon test → Evidence → Review → Resolved Dashboard
```

T01 introduces a Scenario-driven `WRONG_STYLE` Mutation on
`checkout.confirmButton`. T02 unlocks after T01 and introduces a conditional
`WRONG_CALCULATION` Mutation on `cart.subtotal` for two $30 items. Shoply remains a
normal purchase flow when no Mutation is active. T03 unlocks after T02 and uses a
`WRONG_ACTION` Mutation to send Cancel Order to payment instead of cancellation.
Without that Mutation, cancellation updates the order status normally. Older saves
are reconciled with new catalog Tickets without losing progress. After T03, the
Account Switcher unlocks for T04, which applies a conditional discount Mutation for
Gold + SAVE20 + quantity three or more.

### Verification

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

The web prototype's own critical-flow checklist is kept in the history of
[docs/development/TESTING.md](docs/development/TESTING.md), which now covers the Godot build.

### Module Boundaries

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
