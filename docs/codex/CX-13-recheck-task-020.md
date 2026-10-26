# CX-13 · Re-measure the TASK-020 fixes

Read `docs/codex/RULES.md` first and follow it. Claude fixed the CX-11 and CX-12
findings in commit `0fb0a41` (decisions in `docs/qa/2026-10-26-cx09-12-disposition.md`).
Use your own earlier probes again, unchanged where you can, so the numbers compare
directly. Write the report as you go.

Scratch: `godot/build/cx13/` (copy probes here; do not edit the CX-11 and CX-12 folders).
Report: `docs/qa/cx13/report.md`.

## 1 · Accessibility (from CX-11, `godot/build/cx11/`)

At 1280x720 and 1920x1080, in Korean and English:

- **Keyboard:**
  - Can the Note targets (`Markcart_subtotal`, `Markcheckout_confirmButton`, and the
    others) be reached with Tab or Shift+Tab and pressed with Enter or Space?
  - Does the My Notes editor now let Tab, Shift+Tab, and Escape move focus away?
    Re-run the stateful trap check.
  - Is focus visible on Start work, Sign in, Start test, Send report, Send deduction, and
    Clock out? Compare the pixel-difference counts with CX-11's 76.
- **Contrast:** re-measure the lock-screen clock and date and the desktop icon names
  (CX-11 measured 2.26–2.33:1 and 4.07–4.47:1). These now have a light outline; measure
  the glyph against its immediate surroundings, as before, and say how you account for
  the outline.
- **Other flags:** list anything that is still flagged or newly flagged compared with
  `docs/qa/cx11/findings.csv`.

## 2 · Performance (from CX-12, `godot/build/cx12/`)

- Export into `godot/build/cx13/` and record the exe and pck sizes, and the pck
  breakdown by folder. Confirm that no `build/` entries are packed.
- Idle on the desktop for 60 s: process CPU (one core = 100%) and memory, measured as in
  CX-12 (on the editor process, not its console wrapper). Also give the engine loop rate,
  which should now be at most about 60.
- Frame time on the same ten screens, briefly: confirm nothing exceeds 16.7 ms.

## 3 · Playtest package

The package is in `godot/build/playtest-0fb0a41/`. Unzip a copy into
`godot/build/cx13/package/`, check both SHA-256 values against `SHA256SUMS.txt`, check
that `BUILD.txt` names `0fb0a41`, and run the unzipped exe's self-check (`-- --self-check`
only; never start it in normal mode). Follow `docs/playtest/TASK-010-facilitator-checklist.md`
"Before the session" and note any step that does not work as written.

## Finish

A verdict line per part (fixed / partly fixed / not fixed / new issue), then the details.
Do not fix code. Do not edit any file outside `godot/build/cx13/` and `docs/qa/cx13/`.
