# Rules for Codex sessions on Nothing Wrong

Codex sessions verify, measure, review, and make art. Claude sessions implement, change
content, and move Project OS state. These rules keep the two from overwriting each
other. Every Codex brief in this folder includes them.

## Do not change

- Product code and content: `godot/scripts/`, `godot/scenes/`, `godot/data/`,
  `godot/i18n/`, `godot/tests/`, `godot/project.godot`, `godot/export_presets.cfg`.
- Project OS state: anything under `.project-os/`. Do not claim, submit, review, or
  evaluate tasks. Do not mark TASK-010 or M4 done.
- The story canon: `docs/NOTHING_WRONG_ALL_IN_ONE.md`, `docs/story/`.
- Git history: no commits, branches, pushes, or resets. Leave other people's changes alone.

Findings and suggestions go in your report; Claude applies them.

## Write only here

- The output folder your brief names (under `docs/qa/` or `docs/art/`).
- Scratch builds, probe scripts, logs, and screenshots: `godot/build/<your folder>/`
  (ignored by git). Remove anything else you create by accident.

## Saves

Never read, write, move, or delete the player's saves in
`%APPDATA%\Godot\app_userdata\Nothing Wrong` (`save.json`, `workspace.json`,
`settings.json`, and their `.unreadable` copies). Tests and probes use `user://tests/`.
A probe that writes saves must point at `user://tests/` and remove its files afterwards.

## Canon guardrails

Reports, suggestions, and art must keep these:

- Nothing confirms that Daniel Park was murdered. The words "murder", "살인", "살해",
  "killed", and "CRITICAL CLUE" never appear in game text or art.
- Photos prove acquaintance only. DB-01 is a benefits code. Trafficking appears only as
  signals in records. Northstar is under Horizon Community Trust's INFLUENCE, not owned.
- No real people, real companies, or real brand marks.

## Honesty

- Do not stand in for the human playtest (TASK-010) or write its observations.
- Report what you ran and what you saw. Mark anything you inferred without running it
  as a judgement, not a result.

## Tools

- Godot 4.7.2 console binary:
  `C:/Users/limse/AppData/Local/shard-storm-tools/godot/4.7.2-stable/Godot_v4.7.2-stable_win64_console.exe`
- Tests: `--headless --path godot -s tests/run_tests.gd`. Two "Parse JSON failed" lines
  are expected (tests that read damaged saves on purpose). RID/ObjectDB leak lines at exit
  are known and are what CX-03 measures.
- Screenshot tour: `--path godot --resolution WxH --script res://tests/screenshot_tour.gd -- <out-dir> <ko|en> <WxH>`.
- Export and self-check: see `godot/README.md`, **Build**. Export into your own folder,
  not `godot/build/windows/`.
- Only one Godot process should use the project at a time. Run them one after another.
