# CX-05 · Visual review at three sizes (rerun)

Read `docs/codex/RULES.md` first and follow it. The first run (2026-10-26) viewed every
screenshot but stopped at the usage limit before writing any finding, so nothing from it
is usable. Since then the title, lock screen, and desktop have pictures, the record views
show photos, and the Korean text changed (commit `adf74eb`).

**Write findings as you go.** After each screenshot set, append its rows to the report so
a stop part-way still leaves results.

## Folders

- Screenshots and scratch: `godot/build/qa-2026-10-26-visual/` (one Godot process at a time).
- Report: `docs/qa/2026-10-26-visual/report.md` and `findings.csv`.

## Steps

1. Record `git rev-parse HEAD` and `git status --short` at the top of the report.
2. Run the screenshot tour six times: 1280x720, 1440x900, and 1920x1080, each in `ko` and
   `en`. Command shape: `--path godot --resolution WxH --script res://tests/screenshot_tour.gd
   -- <scratch>/tour-WxH-<lang> <lang> WxH`.
3. Look at every image. List only problems:
   - text cut off, overlapping, or unreadable against its background (the title card over
     its picture, the lock-screen clock and date, desktop icon labels over the wallpaper);
   - windows or popups off screen;
   - Korean UI left in English (the Shoply storefront and ONE HORIZON portal stay English
     on purpose);
   - photo cells too small to show the defect (T14 thumbnail cut, T32 tablet crop, T38
     rotated preview);
   - layout that differs oddly between sizes or languages.
4. `findings.csv` columns: `screenshot,size,language,where,problem,priority` (P1 blocks or
   misleads play, P2 hurts readability, P3 polish). `report.md`: a verdict line, counts by
   priority, the findings table, and the screenshots with no problems listed only by
   count.

Do not fix anything. Do not edit any file outside the two folders.
