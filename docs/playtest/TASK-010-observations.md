# TASK-010 playtest observations

## First Ticket onboarding feedback

- Source: direct project-owner feedback after starting T01.
- Observation: the first Ticket did not make the player's next action intuitive.
  The player requested a tutorial that explains what to do.
- Response: T01 now introduces the QA loop on the Ticket page, gives contextual
  guidance while exploring Shoply, explains the Report fields, and points to the
  next step after Review. The guidance does not identify the defect.
- Follow-up: replay T01 from a fresh browser save and record whether the next
  action is clear at each stage without outside help.

This is one human observation, not a completed six-question playtest session or
the final human decision on content production.

## Tutorial follow-up result — 2026-10-14 (Asia/Seoul)

- Status: implementation verified; human validation pending.
- Repository baseline: `2eb6904` plus the uncommitted tutorial and verification
  changes. This record does not describe a committed release.
- Scope: T01 Ticket introduction, contextual Workspace guidance, first Report
  instructions, and Review follow-up guidance.

### Findings and corrections

- An early product-page Evidence capture advanced the guide to Report before the
  player had explored checkout. Report guidance now follows a checkout-page capture;
  earlier captures retain the purchase-journey guidance. This is a tutorial milestone,
  not validation that the captured Evidence proves a defect.
- Navigating to Orders showed an instruction to use Add to bag, which was absent
  there. Off-journey guidance now explains how the Shoply logo returns to the product.
- INVALID Review guidance required stronger Evidence even when the problem was the
  Report's behavior selections. The guide now explains revising the Report and
  capturing new Evidence when needed.
- Regression coverage confirms early capture, detour and return, restored guidance
  after remount, and an INVALID → revised Report → VALID → Dashboard flow reusing
  the existing Evidence.

### Verification

| Check | Result |
| --- | --- |
| Full unit/component suite | PASS: 23 files, 93 tests |
| Typecheck | PASS |
| Production build | PASS |
| Chromium T01–T04 browser flow | PASS: one flow, fresh save, Reviews and reload persistence |
| Product Ticket-ID / ExpectedBug boundary search | PASS: no matches |
| Storage access outside persistence boundary | PASS: no matches |
| Forbidden domain-name boundary search | PASS: no matches |
| Project OS doctor | PASS |
| Diff whitespace check | PASS |

The first default-port browser run could not start its app: port 4173 was occupied
by another `node server.js`, whose `/start` returned 404. No browser assertions ran
in that attempt. The successful run used `NOTHING_WRONG_E2E_PORT=4174`. Playwright
now accepts a validated port override and Vite uses `--strictPort`; reproduction
instructions are in [the development testing guide](../development/TESTING.md).

### Handoff and remaining acceptance

Give the designated human tester the
[participant guide](TASK-010-participant-guide.md) and record the run using the
[session template](TASK-010-session-template.md). Replay with a fresh browser save
and note whether each T01 guide makes the next action clear without facilitator hints.
Then complete T02–T04 and collect the six responses.

This verification is agent-led and does not establish the tutorial's usability or
the gameplay's appeal. Independent review is not claimed by this self-check.
TASK-010 remains ready and M2 remains current. Six human observations, independent
review, and the human content-scaling decision still require their documented
handoff and evaluation; no completion transition has been made.

## Rejected playtest request and safe follow-up — 2026-10-14

- The human rejected the request to provide a designated tester and schedule or
  completed playtest observations. The planned playtest handoff above is deferred;
  no tester was assigned or contacted and no human responses were supplied.
- Safe alternative: a scoped React self-review of the existing tutorial changes.
  Tutorial steps derive from current route and persisted Evidence during rendering;
  the change adds no duplicated state, effects, storage schema, or dependencies.
  Conditional tutorial sections use boolean guards and have accessible names.
- The review found that the requirements instruction assumed the Ticket tab was
  visible even while Notes or Evidence was selected. The instructions now explicitly
  tell the player to open the Ticket tab. The guide also uses `aria-atomic="true"`
  with its polite live region so updated guidance is announced as a whole.
- This self-review does not satisfy the independent-review gate. No further scoped
  blocking issue was identified by this static check; it is not a usability approval
  or a screen-reader validation session.
- Follow-up verification: `npm run typecheck` and `git diff --check` passed. The
  previously recorded 93-test suite and Chromium flow were not rerun for this
  wording and accessibility-attribute change.
- Remaining blocker: TASK-010 still lacks the required independent review, six human
  observations, and explicit human content-scaling decision. The rejection does not
  authorize replacing the human criteria with agent testing, completing M2, or
  starting T05–T08. Canonical Project OS state remains unchanged.

## Owner-directed gameplay revision — 2026-10-18

- Source: project-owner review request. The owner asked to fix every prioritized
  review finding without making the game harder, keep the first Tickets as quick
  guided tutorials, and make following the story and deducing from each Ticket's
  findings the core of play. Recorded as DEC-005.
- Changes: the Report no longer offers ExpectedBug text. Expected is a Ticket
  requirement and Actual is an observation the player captured. Review now checks
  required reproduction actions and evidence quality (small noise deductions only).
  NO ISSUE FOUND, a severity guide, readable attachments, captured values in
  Evidence previews, scenario-driven guides (T01 full, T02 guided, T03 light, T04
  tool intro only), Chapter 1 story beats with no-penalty deductions, a Case File,
  New game reset, unreadable-save recovery, and an error boundary were added.
- Verification: typecheck, 26 Vitest files (111 tests), production build, the
  Chromium T01–T04 + story flow, the boundary searches, and `git diff --check` pass.
- Not established: whether the story and difficulty land with players. The six
  human playtest observations, independent review, and the human content-scaling
  decision are still outstanding. The Chapter 1 story text is a draft for owner
  review. Canonical Project OS state was not changed.

## Owner-directed workstation UI — 2026-10-18

- Source: project-owner direction (DEC-006). Play now starts on an in-game QA
  workstation: lock screen, desktop, Messenger briefings with links, QA Tracker,
  a Browser where the player follows links or types addresses, and QA Notes where
  Evidence and work records collect. The owner cited "No Results Found" as inspiration.
- Verification: typecheck, 26 Vitest files (106 tests), production build, and the
  Chromium T01–T04 workstation journey with real message pacing pass.
- Not established: whether the desktop framing reads as natural QA work to players.
  Human observations, independent review, and the content-scaling decision remain open.

## Owner-directed gameplay depth pass — 2026-10-18

- Source: project-owner direction after comparing with "No Results Found". Development
  continues in Godot only (DEC-008); the web build is frozen, not deleted.
- Changes: story clues are now found by the player through an intranet search
  (`search.nothingwrong.local`) instead of being told in the debrief; hints fold from T03;
  the Chapter 1 finale is answered on a Case File clue board; T05 adds a no-defect ticket
  with a red-herring complaint; the Shoply storefront has three products; synthesized
  sound effects and ambience; a Chapter 2 hook.
- Verification: 25 Godot headless tests pass, including a full UI run of Chapter 1 and
  T05; Korean screenshots reviewed for search, record, deduction, storefront, and board.
- Not established: whether search-based discovery is fun and not too hard for players.
