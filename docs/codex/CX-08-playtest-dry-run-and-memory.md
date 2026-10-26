# CX-08 · Playtest kit dry run, and long-play memory (300 loops)

Read `docs/codex/RULES.md` first and follow it. Both parts run Godot: one process at a
time, part A first. Write each part's report as soon as it is done.

Scratch: `godot/build/qa-cx08/`. Reports: `docs/qa/cx08/`.

## Part A · Dry run of the playtest kit → `docs/qa/cx08/kit-dry-run.md`

This is **not** the human playtest (TASK-010) and must not be reported as one. It checks
that the kit a human will use matches the build.

1. Read `docs/playtest/TASK-010-participant-guide.md` and
   `TASK-010-session-template.md` as a participant and a facilitator would.
2. Check every concrete claim against the running game and the code: button and app
   names in both languages (the guide mixes English and Korean labels), where things are
   (taskbar, QA Notes, Messenger), the clock-out and next-morning flow, the hint link, the
   20-minute cost of a sent-back report or wrong answer, NO ISSUE FOUND, the fresh-save
   steps (do not delete the real saves; check the instructions against
   `scripts/domain/save_file.gd` instead), and the build and self-check steps.
   Drive the game the way `godot/tests/ui_test_base.gd` and `test_ui_flow.gd` do, with
   saves in `user://tests/`, and take screenshots of each step you check.
3. Report a table: claim, where in the kit, what the build actually does, match or
   mismatch, suggested wording. Then list anything a participant is likely to get stuck
   on that the kit does not mention (judgement, marked as such).

## Part B · Memory, 300 loops → `docs/qa/cx08/memory.md`

The 2026-10-26 run (`docs/qa/2026-10-26-verification/report.md`, probe in
`godot/build/qa-2026-10-26/memory_probe.gd`) did 100 headless loops: node and object counts
were flat, and static memory grew about 60 KB per loop alongside the notes and chat.

1. Reuse or adapt that probe (copy it into your scratch folder). Run at least 300 loops
   **with a window** (not `--headless`), and also 300 headless, sampling every 25 loops:
   `OBJECT_COUNT`, `OBJECT_NODE_COUNT`, `OBJECT_ORPHAN_NODE_COUNT`, `MEMORY_STATIC`,
   `RENDER_TEXTURE_MEM_USED`, `RENDER_VIDEO_MEM_USED`, plus the number of notes and chat
   entries.
2. Include the record views with photos, the photo zoom, the directory pages (badge
   photos), and the Shoply product pages (product photos) in the loop.
3. Report the tables, say whether each measure is flat, levels off, or grows, and whether
   the growth matches the saved data. If anything grows without matching data, find the
   step by turning steps off and name the likely code.

Do not fix code.
