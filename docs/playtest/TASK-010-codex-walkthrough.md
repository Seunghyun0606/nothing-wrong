# TASK-010 Codex walkthrough — functional evidence, not human playtest

This is an agent-led QA walkthrough of commit `6c3faa8` in a fresh local Chromium
browser save. It is **not** a human participant session, does not answer the six
subjective playtest questions, and does not authorize broad content production.

## Reproduced behavior

- The existing T01–T04 Playwright browser flow passed.
- A separate Codex-driven Chromium run completed each Ticket through Evidence,
  Report, `VALID` Review, and Dashboard return. Reload preserved the final 400 XP.
- T02 showed the normal $30 subtotal at quantity one and the Scenario's $50
  subtotal at quantity two.
- T03's Cancel order opened Payment details under the active Mutation.
- T04 Gold + SAVE20 showed a normal $12 discount at quantity two and the defect's
  $9 discount at quantity three. Moving 2 → 3 → 2 → 3 toggled these amounts
  consistently.
- The Fake Browser's Mobile control visibly reflowed Shoply to a 390 px layout.
- No page or browser-console errors were observed in this run.

Visual captures were inspected locally for Start, Workspace, Mobile Shoply, T02
cart, T03 payment, T04 cart, Reports, and final Dashboard. Captures live under
ignored `test-results/task010-agent/` and are not a durable project artifact.

## Non-blocking UX observation

The Report builder preselects every recorded interaction as a reproduction step.
In the exploratory path, this included viewport changes unrelated to T01 and
repeated quantity toggles for T04. The Report can therefore become long even
when the core reproduction is short. This is a usability hypothesis for human
playtesting, not a verified player preference or a functional failure.

## Automated gates

- `npm test`: 23 files, 91 tests passed.
- `npm run typecheck`: passed.
- `npm run build`: passed, 170 modules transformed.
- `npm run test:e2e`: one Chromium T01–T04 flow passed.
- `projectctl doctor`: passed.
- Product Ticket-ID and non-persistence `localStorage` boundary searches: no matches.

TASK-010 remains unclaimed because `projectctl next --role developer` returns no
eligible task for its configured Human Gate. No human observations or final
content-scaling recommendation have been recorded.
