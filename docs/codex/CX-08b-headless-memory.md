# CX-08b · Headless memory, 300 loops (finish CX-08 part B)

Read `docs/codex/RULES.md` first and follow it. CX-08 part B finished the 300-loop
windowed run but stopped the headless run at 75 loops (usage limit). Claude wrote
`docs/qa/cx08/memory.md` from the data; do not edit that file.

1. Use the probe already in `godot/build/qa-cx08/memory_probe.gd` unchanged (copy it into
   `godot/build/qa-cx08b/` if you need a scratch copy). Run it headless for at least 300
   loops with the same loop and sampling every 25 loops as the windowed run.
2. Write `docs/qa/cx08/memory-headless.md` as soon as the run ends: the table (loop,
   nodes, objects, orphans, static memory, notes, save size), and one line each on
   whether nodes, objects, and orphans are flat and whether static growth matches the
   notes. Put the raw JSON in `godot/build/qa-cx08b/`.

Write only to `docs/qa/cx08/memory-headless.md` and `godot/build/qa-cx08b/`. One Godot
process at a time. Do not fix code.
