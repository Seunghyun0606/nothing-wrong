# Canon map: Godot build ↔ master synopsis

The master synopsis is `docs/NOTHING_WRONG_ALL_IN_ONE.md` (handoff-1.0). Chapters 1–4 of
the Godot build are a prologue added before it; from Chapter 5 the build follows its acts
and Tickets (DEC-013). `godot/tests/test_canon.gd` checks the reveal order and the facts the
canon leaves open, using `godot/data/canon.json`.

## Chapters

| Chapter | Canon | Tickets | Status |
|---|---|---|---|
| 1 · Release Candidate 3 | Prologue (T01 = NW-001, T02 = NW-002) | T01–T04 | Built |
| 2 · Write Access | Prologue | T05–T07 | Built |
| 3 · Holdout | Prologue | T08–T09 | Built |
| 4 · Rollback | Prologue; its epilogue hands Northstar to ONE HORIZON | T10–T12 | Built |
| 5 · October 17 | ACT 2 | T13–T16 = NW-006–009 | Built |
| 6 · Source Data | ACT 3 | T17–T21 = NW-010–014 | Built |
| 7 · Zero Incident | ACT 4 (Case Notes open) | NW-015–019 | Next |
| 8 · The Foundation | ACT 5 | NW-020–026 | Planned |
| 9 · Daniel's Last Case | ACT 6 | NW-027–030 (+028B) | Planned |
| Final | NW-FINAL (SHIP / HOLD, endings) | — | Planned |

NW-003–005 (Tier sync, photo crop, payroll deductions) are not built; NW-005's net pay
($4,340) appears as the salary in NW-009's data.

## Reveal order (canon principle 5)

| Reveal | First chapter | Gate terms (canon.json) |
|---|---|---|
| October 17 | 5 | October 17 / 17 October |
| Horizon Ridge | 6 | Horizon Ridge, Wellness Center |
| Daniel's death | 7 | Death Benefit, died, fatality, 사망 |
| The Foundation | 8 | Foundation, Community Alignment, COMMUNITY_PARTNER_OVERRIDE, 재단 |
| Who controls it, Northstar included | 9 | Community Trust, Services Holdings |

Never stated as fact anywhere: murder (살인/살해), and no "CRITICAL CLUE" style alerts.

## People

| Build name | Role | Canon |
|---|---|---|
| Mina Seo | Northstar QA Lead | Canon P-MINA (was "Maya Kim" in the prologue) |
| Grace Yoon | Horizon Program Manager | Canon P-GRACE |
| Alex Han | Integration Developer | Canon P-ALEX, introduced at the end of Chapter 5 |
| Daniel Park (E-18419) | Former employee | Canon P-DANIEL; his Triply ID T-55291 appears in Chapter 5 |
| Marcus Reyes | Shoply Release Manager | Prologue only (was "Daniel Reyes") |
| Leo Ortiz | Shoply Engineer | Prologue only (was "Sam Ortiz") |
| Elena Brooks | Shoply VP Growth | Prologue only (was "Elena Park") |
| Priya Nair | Shoply Support Lead | Prologue only |

The player works for Northstar Quality Services (`northstar.local`), as in the canon.

## How the build follows the canon's rules

- Clues arrive through QA screens: the ONE HORIZON QA portal (`qa.onehorizon.local`)
  shows read-only UAT snapshots as record tables or Source/Target compares
  (`data/horizon.json`, drawn by `scripts/ui/horizon/record_view.gd`).
- No "clue found" alerts: chapters marked `quiet` keep clues out of the chat and the Case
  File; the Case File opens for the story in Chapter 7 (canon: after NW-018).
- Reports can claim BUG, DATA_INTEGRITY, or DOC_GAP (`ticket.outcomes`); NW-009 is
  DATA_INTEGRITY, and Horizon closes it as KNOWN ISSUE / LEGACY EXCEPTION.
- The Chapter 5 conclusion is the canon's reasonable wrong hypothesis (one shared
  migration batch); Alex disproves it in Chapter 6 (NW-011), and the Chapter 6 conclusion
  stays at what the records prove ("the conflict was already in the source"), not why.
- NW-010 and NW-011 are NO_BUG Tickets: the right report is NO ISSUE FOUND.
- NW-014's photo is shown as metadata and alt text until the photo assets exist (D-19):
  a sun-in-a-ring emblem stands in for the Foundation symbol, which is not named before
  Chapter 8.

## Open decisions carried from the canon

D-01 (year: 2021 used as proposed), D-13/D-14 (trafficking and death evidence levels),
D-18 (final choice and endings), D-19 (photo assets for NW-004/014/022/028).
