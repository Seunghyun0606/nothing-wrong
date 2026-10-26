# CX-09 Old-save compatibility report

**Task execution: complete. Compatibility verdict: FAIL for the first Godot build (`9131493`).** All 16 save/workspace pairs load in current HEAD without being set aside. Progress and workspace data survive, but the oldest build replays already delivered chat and loses legacy deduction exchanges from the rendered transcript. No product fixes were made.

- Date: 2026-10-26. Role: Codex verification. Explicit CX-09 assignment; no Project OS state transition.
- Current HEAD: `1c8f0d9bb9fde3946a7ad346cfc6f653cd3e1e09`.
- Engine: `4.7.2.stable.official.ed1daf0bf` (the console binary specified in RULES.md).
- Evidence: [machine-readable results and fixture hashes](results.json), [report written during execution](execution-log.md).

## Method and coverage

Archived each requested commit, including HEAD as a control, with `git archive`; extracted only `godot` below `godot/build/cx09/<version>/`. Every archived `project.godot` was renamed to `NW-CX09` before execution. Each writer printed `OS.get_user_data_dir()` and checked its final directory name before saving. All five runs reported `C:/Users/limse/AppData/Roaming/Godot/app_userdata/NW-CX09`. That directory was emptied between versions and is empty at completion.

Writers use each archived version's own `GameSession` and `WorkspaceSession`: start Tickets, submit reports accepted by that version's review logic, open discovery records, answer deductions/Case Files, set bilingual multiline notes, pin actual attachments, record interactions, and mark available chat delivered/read. Evidence snapshots and report actions are constructed from that version's requirements and reproduction conditions, following its domain tests; they are synthetic fixtures, not screenshot captures or observations from a human playtest. The writer never rewrites a saved JSON schema. All final writers exited 0 with zero fixture assertions.

Three checkpoints per version:

1. `t01`: T01 resolved; notes, evidence and a pinned specification; available chat delivered, before answering its deduction.
2. `mid-ch2`: later builds have T01–T06 resolved, DED-T06 wrong exactly once and still unsolved. The first build contains only T01–T05, and Chapter 2 contains no deduction: its checkpoint is T05 TESTING, with a wrong-then-correct T03 deduction retained from Chapter 1. This content limitation cannot produce the later Chapter 2 state.
3. `furthest`: all content resolved (5 Tickets / 4 deductions for `9131493`; 42 Tickets / 19 deductions for the other versions), including every available Case File answer, and all five available specifications pinned.

An extra `9131493-t01-wrong` checkpoint isolates a single unanswered legacy wrong deduction attempt. Total: 16 pairs. Every pair is retained at `godot/build/cx09/saves/<version>-<state>/{save.json,workspace.json}`, alongside metadata containing the old generated Messenger entries.

The current-project loader lives at `godot/build/cx09/loader.gd`. Its custom SceneTree makes autoload save paths use `user://tests/`; the probe asserts the game/workspace/settings paths, disables persistence, copies fixtures only to `user://tests/cx09/`, then explicitly calls both `load_state()` methods. It compares every old Ticket field and top-level game field semantically, all workspace collections, generated chat IDs and text, and the old delivered prefix. It opens the real main scene, desktop and each app (Messenger, Browser, QA Notes), renders each saved notes page and the Case File, and advances queued messages through the real `_deliver_next()` to detect actual replay. A Godot Logger captures errors throughout load, chat construction and UI operations. Temporary copied saves/backups are removed after every case.

## Final results

For every row: both loadability checks pass; neither file is set aside; Ticket state, raw story/deduction data, notes, evidence, interactions and references are preserved; desktop and all three apps open. There are **0 load/UI runtime errors**. Counts below concern the generated transcript, separately from saved-data preservation.

| Version | State | Load outcome | Old → current chat entries | Lost or replayed | Runtime errors |
|---|---|---|---|---|---|
| 9131493 | furthest | Loaded; no set-aside | 62 → 64 | 12 old entries absent; 4 existing entry texts updated | 0 |
| 9131493 | mid-ch2 | Loaded; no set-aside | 58 → 54 | 12 old entries absent; 4 existing entry texts updated | 0 |
| 9131493 | t01 | Loaded; no set-aside | 7 → 9 | 2 already delivered entries replayed; 1 existing entry texts updated | 0 |
| 9131493 | t01-wrong | Loaded; no set-aside | 12 → 12 | 2 old entries absent; 2 existing entry texts updated | 0 |
| ef3a593 | furthest | Loaded; no set-aside | 373 → 375 | 6 existing entry texts updated | 0 |
| ef3a593 | mid-ch2 | Loaded; no set-aside | 80 → 80 | None | 0 |
| ef3a593 | t01 | Loaded; no set-aside | 9 → 9 | None | 0 |
| adf74eb | furthest | Loaded; no set-aside | 373 → 375 | 3 existing entry texts updated | 0 |
| adf74eb | mid-ch2 | Loaded; no set-aside | 80 → 80 | None | 0 |
| adf74eb | t01 | Loaded; no set-aside | 9 → 9 | None | 0 |
| e94fde8 | furthest | Loaded; no set-aside | 373 → 375 | 3 existing entry texts updated | 0 |
| e94fde8 | mid-ch2 | Loaded; no set-aside | 80 → 80 | None | 0 |
| e94fde8 | t01 | Loaded; no set-aside | 9 → 9 | None | 0 |
| HEAD | furthest | Loaded; no set-aside | 375 → 375 | None | 0 |
| HEAD | mid-ch2 | Loaded; no set-aside | 80 → 80 | None | 0 |
| HEAD | t01 | Loaded; no set-aside | 9 → 9 | None | 0 |

All 12 checkpoints from `ef3a593`, `adf74eb`, `e94fde8` and HEAD pass the 24 operational assertions per case (no chat-ID loss/replay). The four earliest-build checkpoints fail chat assertions. The later old builds' furthest checkpoints regenerate some existing text using current content; they do not preserve a byte-identical historical transcript. HEAD controls have no transcript differences.

## Findings and responsible fields/checks

### CX09-01 — earliest-build delivered-count fallback repeats messages

**Observed:** `9131493-t01` has `story.deliveredCount = 7`, `story.readCount = 7`, no `deliveredId`, and seven old chat entries. Current Messenger generates nine entries. Its delivered position falls back to 7; `_deliver_next()` actually delivers these two IDs again:

- `SCENARIO-T01:debrief:0`
- `SCENARIO-T01:debrief:1`

Both IDs occur within the already delivered old transcript. Current chat adds a briefing entry and a report entry ahead of the old debrief, so the old positional marker no longer identifies the same point.

**Responsible path:** `DesktopSession.messenger_log()` (`godot/scripts/autoload/desktop_session.gd:501`) calls `_position_after()` (`:532`); without a saved ID, it returns `min(fallback, entries.size())`. `GameState.is_loadable` accepts the numeric counts, and `GameState.reconcile` does not migrate an old count using its old catalog. This is a delivery compatibility defect, not a set-aside failure.

### CX09-02 — legacy deduction and Case File exchanges vanish from chat

**Observed:** the isolated wrong T01 checkpoint loads its string option-ID attempt unchanged, yet its two old entries (`SCENARIO-T01:reply:0`, `SCENARIO-T01:response:0`) are absent. The mid-Chapter-2 and furthest checkpoints each lose 12 old chat IDs: T01 and T03 each have two answer/reply pairs, T02 one pair, and T04 one Case File board answer/reply pair. Solved flags and original attempts remain in the loaded save; this is transcript loss, not loss of the raw progress fields.

**Responsible field/check:** old `story.deductions.<id>.attempts` contains option-ID strings, with Case File details additionally in `boardAttempts`. `GameState.PROGRESS_FIELDS` (`godot/scripts/domain/game_state.gd:19`) requires only an Array plus a solved bool, so `is_loadable` (`:81`) accepts these saves. `reconcile` (`:92`) does not translate old attempts. `MessengerLog` (`godot/scripts/domain/messenger_log.gd:131`) explicitly skips every attempt whose type is not Dictionary; its current renderer expects `filled`, `right`, `total`, `correct`. The old `boardAttempts` exchanges are not reconstructed either.

Full missing-ID arrays are retained per case in [results.json](results.json). No sampled historical game or workspace file failed `GameState.is_loadable` or `WorkspaceSession._is_loadable`; there is no rejected field or set-aside condition to report.

### CX09-03 — historical wording is regenerated from current content

**Observed:** common entry IDs have different `text` values at the furthest checkpoint: 6 for `ef3a593`, 3 for `adf74eb`, 3 for `e94fde8`. Early/mid checkpoints for those versions are unchanged. The earliest-build counts are listed in the table. No additional IDs disappear or replay in the three later versions.

**Responsible path:** saves retain progress/markers rather than immutable rendered messages; `MessengerLog.build` uses current `godot/data/scenarios.json`. **Judgement:** these are content revisions rather than load-validation rejection. A requirement to preserve the exact historical chat wording is therefore also unmet. The full changed-ID arrays are in the machine-readable results.

## Environment and probe notes

- Each final Godot process logged `Failed to read the root certificate store` at startup, before the custom logger was installed. This is recorded as an environment/startup error, not counted as a load or app runtime error. Logs therefore are not completely error-free. It occurred in archive imports, writers and current loaders, including HEAD controls.
- Some runs reported known ObjectDB exit leak warnings (RULES.md assigns their measurement to CX-03). No leak-size claim is made here.
- The first editor import attempted to save global editor settings and was denied by the sandbox. Subsequent imports use a copied self-contained Godot editor under `godot/build/cx09/tools/`, with editor settings/data inside that scratch folder; runtime writers use the specified installed console binary. Engine log paths are explicitly redirected into scratch.
- Initial writer/probe issues were corrected before the final results: T03 uses `validEvidenceTargets`, JSON numeric counts are compared semantically, and UI layout coroutines are allowed to finish before teardown. The execution journal labels the initial probe rows as superseded. Final result JSON and logs correspond to the corrected probes.
- This is automated session/load/UI verification with synthetic evidence. It does not replace TASK-010, a manual visual/readability review, or exhaustive coverage of every possible save state.

## Reproduction and artifacts

From repository root, the retained scripts run one Godot process at a time:

```powershell
python godot/build/cx09/run_version.py 9131493
python godot/build/cx09/load_version.py 9131493
```

Replace the version with `ef3a593`, `adf74eb`, `e94fde8`, or `HEAD`. The archives, renamed configs and probes are already retained in scratch. `run_version.py` clears only the checked `NW-CX09` folder. Each `<version>-writer.log` records isolation and generated fixtures; `<version>-<state>-load.log` and `*-result.json` record current loading/UI results. Initial import/writer setup requires the retained scratch tools.

## Completion record

- Completed all requested versions and available checkpoints; recorded the first-build content limitation explicitly.
- Verified fixture completeness, accepted report transitions, preserved fields, wrong-once mid-Chapter-2 data, furthest-content completion and fixture SHA-256 hashes with `godot/build/cx09/verify_artifacts.py`.
- Verified `user://tests/cx09/` no longer exists and `app_userdata/NW-CX09` is empty. Player saves, workspace, settings and unreadable copies outside `Nothing Wrong/tests` were never read, written, moved or deleted.
- Repository tracked-file diff is empty; no product/content/Project OS files changed, and no branches, worktrees or commits were created. Deliverables are restricted to the two authorized output folders, plus the permitted engine cache/log/test side effects.
- Follow-up for implementation owner: migrate legacy deduction/board data and delivery markers, or explicitly revise the compatibility contract. No fixes applied and no Project OS completion claimed.
