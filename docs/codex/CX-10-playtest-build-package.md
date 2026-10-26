# CX-10 · Playtest build package

Read `docs/codex/RULES.md` first and follow it.

Output: the package in `godot/build/playtest-2026-10-26/` (ignored by git), and a
facilitator checklist at `docs/playtest/TASK-010-facilitator-checklist.md` (new file).
Report: `docs/qa/cx10/report.md`.

## Steps

1. Record `git rev-parse HEAD` and `git status --short`.
2. Export the release build into `godot/build/playtest-2026-10-26/NothingWrong/`
   (`NothingWrong.exe` and anything the export writes beside it).
3. Run the exported self-check and the editor self-check (commands in
   `godot/README.md`, **Build**). Keep their output in the package folder as
   `self-check.txt`. Both must print "Self-check passed" and exit 0.
4. Check that the exe shows the game icon (extract it) and note the build's file size.
5. Zip the `NothingWrong` folder to `NothingWrong-<short commit>.zip` and write
   `SHA256SUMS.txt` for the zip and the exe.
6. Do not start the exported exe in normal mode: it would read the player's real save
   folder. Launch it only with `-- --self-check`, which uses `user://tests/`. For a
   title-screen picture, use the screenshot tour from the editor binary.
7. Write the facilitator checklist: one page, in the order a facilitator works.
   - Before the session: unzip, verify the checksum, run the self-check, start from a
     fresh save as the session template says, and pick the language.
   - During: where the participant guide and session template are.
   - After: collect the session record, keep `save.json` and `workspace.json` only with
     consent, and record the build commit.
   Keep it consistent with `TASK-010-participant-guide.md` and
   `TASK-010-session-template.md`, and do not edit those two files.

Do not edit any other file.
