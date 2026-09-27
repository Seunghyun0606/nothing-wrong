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

The Playwright test clears browser storage explicitly before starting and verifies the
complete Chromium journey through four resolved Tickets. It reloads after each
Ticket, then checks that the final 400 XP and 108 Reputation remain visible.

## Manual journey

1. Open `/start` with browser storage cleared and confirm the `NOTHING WRONG` title.
2. Select **Start Work**, enter the Company workspace, and open T01 from Dashboard.
3. Start the test and confirm Shoply renders inside the Fake Browser while the main URL
   remains `/test/T01`.
4. Switch Desktop, Tablet, and Mobile and confirm the Product width and layout change.
5. Add the Everyday Carry Pack, open Cart, change quantity, and continue to Checkout.
6. Confirm the checkout action is visibly secondary for T01 and capture Evidence on
   the Checkout page.
7. Create a Report, select the primary expected behavior and secondary actual behavior,
   attach the captured Evidence, and submit it.
8. Confirm Review displays `VALID`, the 40/25/20/15 category scores, total 100, XP +100,
   Reputation +2, and feedback.
9. Return to Dashboard and confirm T01 is Resolved, XP is 100, and Reputation is 102.
10. Reload the browser and confirm the same Dashboard state remains.
11. Open the newly unlocked T02 and start its Shoply test session.
12. Add the Everyday Carry Pack, open Cart, and change its quantity to two.
13. Confirm the line item remains $60.00 while the mutated Subtotal displays $50.00.
14. Capture Cart Evidence and create a Report with the documented $60.00 expected and
    $50.00 actual behavior at MEDIUM severity.
15. Confirm the T02 Review displays `VALID`, 100/100, XP +100, and Reputation +2.
16. Return to Dashboard and confirm T01 and T02 are Resolved, XP is 200, Reputation
    is 104, and T03 is the one open Ticket.
17. Reload and open the newly unlocked T03.
18. Select **Cancel order** on Order details and confirm that Payment details opens
    instead of the cancellation flow.
19. Capture payment-page Evidence, report the expected cancellation flow and actual
    payment flow at HIGH severity, then confirm Review displays `VALID` and 100/100.
20. Return to Dashboard and confirm T01–T03 are Resolved, XP is 300, Reputation
    is 106, and T04 is the one open Ticket. Reload to confirm persistence.
21. Open T04, add one Everyday Carry Pack, and apply SAVE20 while Basic. Confirm
    the coupon is unavailable.
22. Switch to Gold and confirm one item receives the normal $6.00 discount.
23. Change quantity to three and confirm the discount is $9.00 rather than the
    required $18.00. Switch to Basic and back to Gold to verify the T04 policy
    preserves the cart and coupon.
24. Capture Cart Evidence with Gold + SAVE20 + quantity three, report expected
    20% and actual 10% at MEDIUM severity, and confirm Review is `VALID` 100/100.
25. Return to Dashboard and confirm all four Tickets are Resolved, XP is 400,
    Reputation is 108, and no Ticket is open. Reload to confirm persistence.

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
| Narrative can be layered without rewriting the core loop | `ScenarioSchema` preserves optional narrative metadata; the T01 runtime does not require or interpret it. |

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
