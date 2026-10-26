# CX-12 · Performance baseline

Read `docs/codex/RULES.md` first and follow it.

Scratch: `godot/build/cx12/`. Report: `docs/qa/cx12/report.md` (write as you go).

## Goal

A baseline to compare against slower machines in the playtest. Record the machine first:
CPU, GPU, RAM, Windows version, and display.

## Measure

1. **Export size:** export into `godot/build/cx12/` and record the exe and pck sizes.
   Break down the pck by folder (data, i18n, assets/photos, assets/people,
   assets/products, assets/art, scripts) from the export file list or a file listing.
2. **Startup:** never start the exported exe in normal mode, because it reads the
   player's real save folder. Time the exported exe with `-- --self-check` (it uses
   `user://tests/`) from launch to the "Self-check passed" line, cold (the first run
   after export) and warm (median of 5). Also time the editor binary with a scripted
   SceneTree to the first frame of the title screen, which saves under `user://tests/`.
3. **Frame time per screen:** with a window at 1920x1080, for about 10 s on each screen
   (title, lock, desktop, Messenger with a long chat, Browser on Shoply, a record view
   with photos, the photo zoom, the directory, QA Notes, Case File), record average FPS,
   the 1% low, and `Performance.TIME_PROCESS` average and max. Also time the first open
   of each photo view (decoding and cropping) separately from later opens.
4. **Idle:** CPU and memory over 60 s on the desktop doing nothing.

Report tables, then list anything slower than 16.7 ms per frame or a first open over
200 ms, with the likely cause. Judgements are marked as such. Do not fix code.
