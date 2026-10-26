# CX-13 TASK-020 fix recheck

Status: IN PROGRESS. Date: 2026-10-26 (Asia/Seoul). Role: Codex verification.

Tested HEAD: `0fb0a410f9ecc70eeff9e1430f8c94cb31dff3e8`. Assigned brief: `docs/codex/CX-13-recheck-task-020.md`; rules: `docs/codex/RULES.md`. Project bootstrap, prior reports/probes, disposition, build and facilitator instructions read. No canonical state transition.

Safety: authored files confined to `godot/build/cx13/` and `docs/qa/cx13/`; Godot import cache and logs are permitted. Player saves are never inspected or changed. Scripted main loops route autoloads to `user://tests/` before loading; persistence is disabled before probe actions. Exported EXEs run only with `-- --self-check`. Godot processes run sequentially. This is automated verification, not a human playtest.

## Execution journal

- Captured repository hash baseline, including earlier scratch, without inspecting app_userdata. No Godot process running. Copied CX-11/CX-12 probes, changing only CX-13 paths initially. `.gdignore` protects new scratch from importer/export scanning.

- Package copied and unzipped into `godot/build/cx13/package/`, preserving `NothingWrong/`. Both SHA-256 values match `SHA256SUMS.txt`; BUILD.txt names the full current commit. Blank human-session template copied with known preflight metadata; human observations and consent fields remain blank. Exported/editor checks await completion of the sequential accessibility runs.

- Run `probe-en-1280x720`: exit 0, 142 PNGs, 36 metadata frames; logs in `godot/build/cx13/`.

- Run `probe-en-1920x1080`: exit 0, 142 PNGs, 36 metadata frames; logs in `godot/build/cx13/`.

- Preliminary English 720p: 25/25 activations passed, including cart subtotal and checkout confirm markers; completion reached the day screen with all persistence flags false. Halo evidence is captured by keeping the actual outline while hiding only glyph fill; both original wallpaper-only and halo-retained backgrounds are preserved.

- Run `probe-ko-1280x720`: exit 0, 142 PNGs, 36 metadata frames; logs in `godot/build/cx13/`.

- Run `probe-ko-1920x1080`: exit 0, 142 PNGs, 36 metadata frames; logs in `godot/build/cx13/`.

- `trap-en-1280x720`: original stateful trap check, exit 0; raw same-owner flags: [False, True, False]. See supplemental independent-key check for escape semantics.

- `trap-en-1920x1080`: original stateful trap check, exit 0; raw same-owner flags: [False, True, False]. See supplemental independent-key check for escape semantics.

- `trap-ko-1280x720`: original stateful trap check, exit 0; raw same-owner flags: [False, True, False]. See supplemental independent-key check for escape semantics.

- `trap-ko-1920x1080`: original stateful trap check, exit 0; raw same-owner flags: [False, True, False]. See supplemental independent-key check for escape semantics.

- `supplement-en-1280x720`: exit 0, completed=True, 26 marker/key checks; independent editor exits: [('Tab', False, True), ('Shift+Tab', False, True), ('Escape', False, True)].

- `supplement-en-1920x1080`: exit 0, completed=True, 26 marker/key checks; independent editor exits: [('Tab', False, True), ('Shift+Tab', False, True), ('Escape', False, True)].

- `supplement-ko-1280x720`: exit 0, completed=True, 26 marker/key checks; independent editor exits: [('Tab', False, True), ('Shift+Tab', False, True), ('Escape', False, True)].

- `supplement-ko-1920x1080`: exit 0, completed=True, 26 marker/key checks; independent editor exits: [('Tab', False, True), ('Shift+Tab', False, True), ('Escape', False, True)].
- CX-13 release export completed with exit 0; original preset unchanged.
8. Parsed and extracted the exact embedded PCK: 126431184 bytes EXE; 17226180 bytes PCK; 141 packed entries. No build/ entries are packed; folder breakdown and largest-file evidence saved for the final report.
- `selfcheck-export` passed with exit 0; raw output retained.
- `selfcheck-editor` passed with exit 0; raw output retained.
- Unzipped package self-check passed using the facilitator PowerShell pipeline: success line and $LASTEXITCODE=0. No normal exported launch performed.
Desktop idle interval started; sampling process CPU time, working set, and private bytes once per second for 60 seconds.
Desktop idle interval finished; raw process samples saved in `godot/build/cx13/idle.json`.

- Accessibility matrix complete: 100/100 original activations and 104/104 supplementary marker activations passed; each supplementary activation added evidence. All 12 independently started Tab/Shift+Tab/Escape checks exit My Notes without editing it. Primary focus counts now 764?2072 changed pixels versus 76. Adjacent outline minima exceed 11.8:1 for clock/date and 12.6:1 for icon names. Remaining clipping, covered focus, small text and non-outline contrast findings are retained; outline-only scanner artefacts are separately dispositioned.
7. All ten 10-second screen samples and photo-view first/later opens completed. Probe exit 0. Raw data, metadata, logs, and PNG evidence are in the scratch folder.
