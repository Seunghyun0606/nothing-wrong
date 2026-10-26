# CX-09 · Old-save compatibility

Read `docs/codex/RULES.md` first and follow it. Do not create git branches, worktrees, or
commits; read old versions with `git archive`.

Scratch: `godot/build/cx09/`. Report: `docs/qa/cx09/report.md` (write it as each version
finishes).

## Goal

Saves written by earlier builds must still load in the current build (HEAD) with their
progress, notes, and chat intact, and not be set aside as unreadable. The load checks
were tightened twice on 2026-10-26 (`GameState.is_loadable`,
`WorkspaceSession._is_loadable`).

## Versions

`9131493` (first Godot build), `ef3a593`, `adf74eb`, `e94fde8`, and HEAD.

## Safety: old builds must not touch the player's saves

Builds before TASK-012 write `user://save.json` directly, so an old build could overwrite
the player's saves. For every archived copy, **before running anything**:

- Extract with `git archive <commit> godot | tar -x -C godot/build/cx09/<commit>`.
- In the copy's `project.godot`, set `config/name="NW-CX09"`. Godot's user folder is then
  `%APPDATA%\Godot\app_userdata\NW-CX09`, which is empty and is the only user folder you
  may write to apart from the current project's `tests` folder. Check that the setting
  took effect (print `OS.get_user_data_dir()`) before writing any save.
- Empty `NW-CX09` between versions.

## Steps per old version

1. In the copy, write a small probe (in the copy, not in `godot/`) that uses that
   version's own sessions to reach realistic states, using its tests as a guide, and
   saves them: (a) T01 resolved with notes and chat delivered; (b) mid-Chapter 2 with a
   deduction answered wrong once; (c) as far as that version's content goes (for
   example, a late Ticket with a Case File answer and a pinned spec). Keep each pair of
   `save.json` and `workspace.json` in `godot/build/cx09/saves/<commit>-<state>/`.
2. In the current project, write a loader probe in `godot/build/cx09/` that copies each
   pair into `user://tests/`, then calls `GameSession.load_state()` and
   `WorkspaceSession.load_state()` and checks:
   - not recovered or set aside;
   - ticket statuses and notes match the old save;
   - `MessengerLog.build` runs without errors and nothing already delivered is delivered
     again;
   - the desktop opens, and each app opens once without logged errors.
   Remove the copies from `user://tests/` afterwards.
3. Record a table: version, state, loaded or set aside, what was lost or replayed, and
   errors. For anything set aside or broken, name the field and the check responsible.

Do not fix code.
