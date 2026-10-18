# T01-T04 Verification

This document records the reproducible verification procedure for the Nothing Wrong
prototype through T04. Run commands from the repository root.

## Automated gates

```bash
npm run typecheck
npm test -- --run
npm run build
npm run test:e2e:list
npm run test:e2e
```

Playwright uses local port 4173 by default. If another application occupies that
port, choose a free port for the test server. For example, in PowerShell:

```powershell
$env:NOTHING_WRONG_E2E_PORT = '4174'
npm run test:e2e
Remove-Item Env:NOTHING_WRONG_E2E_PORT
```

The server uses `--strictPort` so Vite reports an occupied port immediately instead
of silently starting on a different port from the one Playwright expects.

The Playwright test clears browser storage explicitly before starting and plays the
whole workstation journey in Chromium: lock screen, Messenger briefings with real
message pacing, QA Tracker, Browser (links and typed addresses), QA Notes, four
resolved Tickets, deductions, and the Chapter 1 finale. It reloads mid-way and at the
end, then checks that 400 XP, 111 Reputation, and the closed Case File remain.
(T01's deduction is answered wrong once on purpose, so it earns no first-try bonus;
T02–T04 each earn +1.) Expect about a minute because messages arrive in real time.

## Godot build (DEC-007, DEC-008)

The Godot 4.7 client in `godot/` is the only maintained and shipped build. Its content
lives in `godot/data` and `godot/i18n`. Run its headless suite (25 tests, including UI
flows that play Chapter 1 and T05 by pressing real buttons, and a check that every
ticket, story, and record string has a Korean translation):

```powershell
& "<godot>\Godot_v4.7.2-stable_win64_console.exe" --headless --path godot --script res://tests/run_tests.gd
```

See `godot/README.md` for running the game and rendering screenshots. Everything below
this section describes the frozen web build and is kept only for reference.

## Manual journey

1. Open `/start` with browser storage cleared and confirm the `NOTHING WRONG` title.
2. Select **Start work**, then **Sign in** on the lock screen. The desktop opens and a
   Messenger notification arrives after a short pause.
3. Open Messenger: the T01 briefing arrives message by message, ending with links to
   `shoply.local` and the intranet spec, and a ticket card.
4. Open T01 in QA Tracker and select **Start test**. The sticky note now says to open
   Shoply. Open the spec link and confirm the intranet page renders.
5. Open the product link. Switch Desktop/Tablet/Mobile in the Browser QA bar and confirm
   the Product width changes. Add the pack, open the bag, continue to Checkout.
6. Confirm the confirmation button is secondary and select **Capture**. Open QA Notes and
   confirm the Evidence card lists `Confirm order button: Secondary action style`.
7. In QA Tracker select **Create report**. Pick REQ-T01-02, that observation, and LOW.
   Confirm `VALID`, 100/100, XP +100, Reputation +2, and `Level up!`.
8. Select **The team replied · Open Messenger**. Read the debrief and clue, answer the
   deduction once wrong (no penalty, hint shown) and once right. The T02 briefing follows.
9. Reload: QA Tracker shows 100 XP and 102 Reputation, and the chat does not replay.
10. T02: at quantity two the line total is $60.00 while Subtotal and Total show $50.00.
    Report REQ-T02-01 with `Subtotal: $50.00` at MEDIUM. Reply to the deduction.
11. T03: type `shoply.local/orders/order-1042` into the Browser. **Cancel order** opens
    Payment details. Capture and report REQ-T03-01 at HIGH. The Account Switcher unlocks.
12. T04: type `shoply.local`. Apply SAVE20 as Basic (unavailable), switch to Gold
    ($6.00 off one item), then quantity three ($9.00 instead of $18.00). Capture and
    report REQ-T04-02 with `Discount: −$9.00` at MEDIUM.
13. Answer the final deduction: the epilogue and `Chapter 1 · Release Candidate 3
    complete.` appear. QA Tracker shows 400 XP and 111 Reputation; Case File shows
    `Case closed`. Reload to confirm persistence.
14. Type an unknown host such as `shoply.com` and confirm the "site can't be reached" page.
15. Optional: on a defective Ticket submit **NO ISSUE FOUND** and confirm it is INVALID
    with Reputation −2 while the Ticket stays in testing.
16. On `/start`, **New game** resets progress, Evidence, notes, and the chat.

Exploratory clicks have no penalty. Subjective playtest questions belong to M2 and are
not part of this M1 verification.

## Architecture acceptance

| Assertion | Prototype evidence |
| --- | --- |
| A new Ticket does not require a React page change | T02, T03, and T04 content are catalogued under `src/scenarios`; Dashboard, Ticket, Workspace, Report, and Review pages read the catalog generically. |
| A Scenario Mutation can change without editing Shoply | `src/scenarios/shoply/t01.test.ts` changes only the payload and observes a different resolved value. |
| Shoply is normal with zero Mutations | `src/products/shoply/ShoplyFlow.test.tsx` covers the primary CTA, normal totals, and completed order cancellation outside the Test Workspace; T02 and T03 Scenario tests verify zero-Mutation values. |
| The Mutation Engine is reusable by another Product | `src/game/mutations/resolveMutation.ts` depends only on generic domain types, target strings, TestContext, and Product state. |
| Report evaluation is testable without React | `src/game/reporting/reviewBugReport.test.ts` imports the pure review function directly. |
| T04-style conditions can be reproduced automatically | `src/game/mutations/resolveMutation.test.ts` covers Gold + SAVE20 + quantity 3 and negative account/quantity cases. |
| Story and tutorial are Scenario data | `ScenarioSchema.story` and `ScenarioSchema.guide` drive the Briefing, Debrief, Case File, deductions, and guide banners; pages read them generically (see DEC-005). `src/game/guide/resolveGuideStep.test.ts` and `src/game/story/answerDeduction.test.ts` cover the logic without React. |

## Static architecture checks

```bash
rg -n -i "ticketId|T0[1-8]|ExpectedBug" src/products/shoply
rg -n "localStorage" src --glob "!src/persistence/**" --glob "!**/*.test.*"
rg -n "NothingWrong(Ticket|BugReport|Scenario|Mutation|Evidence|ReviewResult|GameState)" src
git diff --check
projectctl doctor
```

The first three searches should produce no matches. Product tests may mention Ticket IDs only
outside the `src/products/shoply` production tree; all browser storage access belongs in
the persistence boundary.

## Verification record

Verified on 2026-09-24 from a fresh browser save:

- Typecheck, production build, and all 18 Vitest files (68 tests) passed.
- Playwright discovered one Chromium critical flow, which passed from `/start` through
  Review, resolved Dashboard return, and reload.
- Rendered captures were inspected at Desktop, Tablet (768 px), and Mobile (390 px).
  Tablet and Mobile reflow through the Product container queries rather than changing
  only the viewport label.
- The Checkout capture showed the T01 confirmation action with the secondary style.
- Review displayed `VALID`, 100/100, category scores 40/25/20/15, XP +100, and
  Reputation +2.
- The post-reload Dashboard displayed T01 as Resolved, 100 XP, and Reputation 102.
- All architecture searches above returned no matches, `git diff --check` passed, and
  `projectctl doctor` reported a consistent Project OS state.

The connected computer-use environment did not expose a browser surface during this
run. The manual visual check therefore used full-page captures from the installed
Playwright Chromium runtime; the permanent critical-flow test independently exercised
the same interactions and assertions.

## TASK-007 verification record

Verified on 2026-09-24:

- Typecheck and production build passed.
- All 20 Vitest files and 76 unit/component tests passed.
- The Chromium critical flow passed through T01, T02, both Reviews, Dashboard returns,
  and final reload persistence.
- T02 active, wrong-quantity, wrong-path, and zero-Mutation cases passed.
- T02 Evidence and deterministic Review were verified at quantity two.
- `projectctl doctor` and `git diff --check` passed.

## TASK-008 verification record

Verified on 2026-09-27:

- Typecheck and production build passed.
- All 21 Vitest files and 83 unit/component tests passed.
- The Chromium critical flow passed through T01, T02, and T03 Reviews, Dashboard
  returns, and final reload persistence with 300 XP and 106 Reputation.
- The T03 action Mutation changed the Cancel Order destination only in its active
  context. Inactive and zero-Mutation cases retained the cancellation destination.
- Without Mutations, confirming cancellation updated the order to `CANCELLED` and
  removed the Cancel Order action.
- Payment-page Evidence produced a deterministic valid T03 Review at HIGH severity.
- `projectctl doctor` and `git diff --check` passed.

## TASK-009 verification record

Verified on 2026-09-28:

- Typecheck and production build passed.
- All 23 Vitest files and 91 unit/component tests passed.
- The Chromium critical flow passed through T01–T04 with final reload persistence
  of four resolved Tickets, 400 XP, and 108 Reputation.
- Account switching unlocks after T03. T04 preserves Product state on account
  changes; a reset policy clears it in focused component coverage.
- Basic + SAVE20 is ineligible, Gold + SAVE20 + quantity one receives the normal
  20% discount, and Gold + SAVE20 + quantity three displays the 10% defect.
- Conditional Evidence and pure Review tests cover positive and negative cases.
- `projectctl doctor` and `git diff --check` passed.
