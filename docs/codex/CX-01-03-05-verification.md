# CX-01, CX-05, CX-03 · Re-verification, visual review, and long-play memory

Read `docs/codex/RULES.md` first and follow it. These three use Godot, so run them in one
session, one Godot process at a time, in this order: CX-01, CX-05, CX-03.

Baseline: the working tree as you find it (Claude's fixes for your 2026-10-25 review,
not yet committed, on top of `ef3a593`). Record `git rev-parse HEAD` and `git status
--short` at the start of your report so the baseline is clear.

Scratch folder: `godot/build/qa-2026-10-26/` (probe scripts, logs, screenshots, export).
Report folder: `docs/qa/2026-10-26-verification/` (`report.md` and `result.yaml`, in the
same shape as `docs/qa/2026-10-25-project-review.yaml`).

## CX-01 · Re-verify the 2026-10-25 findings

Your review: `docs/qa/2026-10-25-project-review.md`. Claude's answer:
`docs/qa/2026-10-25-review-disposition.md`, decisions DEC-017, tasks TASK-016 and
TASK-017 under `.project-os/` (read only).

1. Run the full test suite, the export into your scratch folder, and both self-checks
   (exported and editor). Record the counts.
2. For each of F01–F08, reproduce your original probe against the new build and say
   whether it is fixed, partly fixed, or not fixed. Then try to break the fix:
   - F02: a NO ISSUE FOUND on every no-bug Ticket (T05, T20, T21, T30, T31, T41, T42)
     after visiting only an unrelated screen must be rejected; after opening the Ticket's
     own screen, or starting the Ticket while already on it, it must be accepted. Look for
     a legitimate path that is now wrongly rejected.
   - F04: render every Korean deduction sentence with every option combination (use
     `deduction_form.gd`'s `filled_text`) and list any that read wrongly.
   - F07: try other wrongly shaped saves (game and notes) in `user://tests/`. None may
     crash, and none may silently lose a well-formed field.
3. F03 photos (DEC-017): check T14, T24, T32 (desktop and tablet), T36, and T38 on screen.
   Confirm that a Note on a photo records the same target as the Ticket's
   `validEvidenceTargets` where the photo is the evidence, and that a missing image falls
   back to text without an error (test with a copy of the view data in your scratch
   folder, not by deleting assets).
4. F09 is deferred to the human playtest; do not judge it as fixed or not.

Also report anything new you find, with priority as before (P0–P2).

## CX-05 · Visual review at three sizes

Run the screenshot tour at 1280x720, 1440x900, and 1920x1080, in Korean and in English
(six runs). The tour now also captures the photo views (`p-*.png`). Look at every image
and list problems: text cut off or overlapping, windows off screen, unreadable contrast,
untranslated Korean UI (the Shoply storefront and ONE HORIZON portal stay English on
purpose), photo cells that are too small to see the defect, and layout that differs
oddly between sizes. One row per problem: screenshot file, what is wrong, where, priority.
Do not list things that are fine.

## CX-03 · Long-play memory

The suite and tools print RID/ObjectDB leak warnings at exit. Find out whether memory grows
during long play or only leaks at shutdown.

1. Write a probe in your scratch folder that starts the real desktop scene (see
   `godot/tests/ui_test_base.gd` and `test_ui_flow.gd` for how the tests drive it) with
   saves in `user://tests/`, and repeats a realistic loop many times: open and close each
   app, switch browser tabs, open record views with photos, zoom a photo, note something,
   open the Case File, and rebuild the Messenger log. Sample at intervals:
   `Performance.get_monitor` for `OBJECT_COUNT`, `OBJECT_NODE_COUNT`,
   `OBJECT_ORPHAN_NODE_COUNT`, `MEMORY_STATIC`, and `RENDER_TEXTURE_MEM_USED` (headless
   and, if possible, with a window).
2. Run it for at least 300 loop iterations. Report the numbers over time as a table and
   say whether each grows steadily, levels off, or stays flat.
3. If something grows, find which loop step causes it (bisect by disabling steps) and name
   the likely code location. If nothing grows, say the exit warnings are shutdown-only and
   show the evidence.

Do not fix code. Put suggested fixes in the report.

## Finish

`report.md` starts with a verdict line per task, then the details. `result.yaml` lists
the verification results and findings. Do not edit any other file outside your two
folders.
