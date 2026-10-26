# CX-08 Part B: long-play memory

> **Written by Claude from Codex's data.** The Codex session hit its usage limit (reset
> 08:58) after the runs but before writing this report. The numbers below are copied from
> `godot/build/qa-cx08/memory-windowed-verified-full.json` and
> `memory-headless-verified-full.json`. Codex's probe is `memory_probe.gd` in the same
> folder. Conclusions marked "judgement" are Claude's.

Loop: open and close each app, switch tabs, open record views with photos, zoom a photo,
open directory pages (badge photos) and Shoply product pages (product photos), take a
note, open the Case File, and rebuild the Messenger log. Saves go to `user://tests/`.

## Windowed, 300 loops (complete)

| Loop | Nodes | Objects | Orphans | Static | Texture mem | Video mem | Notes | Save size |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 0 | 3,018 | 8,461 | 0 | 137.0 MB | 48.2 MB | 54.9 MB | 0 | 3 KB |
| 25 | 3,358 | 9,217 | 0 | 148.0 MB | 114.2 MB | 122.4 MB | 25 | 92 KB |
| 100 | 3,358 | 9,217 | 0 | 149.8 MB | 114.2 MB | 122.4 MB | 100 | 276 KB |
| 200 | 3,358 | 9,217 | 0 | 152.3 MB | 114.2 MB | 122.4 MB | 200 | 521 KB |
| 300 | 3,358 | 9,216 | 0 | 154.7 MB | 114.2 MB | 122.4 MB | 300 | 765 KB |
| after teardown | 17 | 1,642 | 0 | 90.3 MB | 105.9 MB | 112.3 MB | 300 | 765 KB |

## Headless (75 of 300 loops before the limit)

| Loop | Nodes | Objects | Orphans | Static | Notes |
| --- | --- | --- | --- | --- | --- |
| 0 | 3,018 | 8,488 | 0 | 156.1 MB | 0 |
| 25 | 3,358 | 9,267 | 0 | 218.3 MB | 25 |
| 50 | 3,358 | 9,266 | 0 | 220.8 MB | 50 |
| 75 | 3,358 | 9,266 | 0 | 221.5 MB | 75 |

## Reading

- Nodes, objects, and orphans are flat after the first 25 loops. Texture and video memory are flat after every screen and photo has been seen once.
- Static memory grows about 24 KB per loop with a window, while notes (with their screen snapshots) grow by one per loop and the save grows about 2.4 KB per loop. Judgement: this growth is the player's data, not a leak. Notes are capped only by play, and 300 notes is far beyond a normal playthrough.
- Tearing down the scene frees the nodes and most of the static memory. The RID/ObjectDB warnings at exit are therefore shutdown-only, as the 2026-10-26 headless run also suggested.
- The headless run stopped at 75 loops. It shows the same shape, with a higher static baseline because there is no GPU.

No fix is needed.

## Headless, 300 loops (CX-08b) and the history check

Codex finished the headless run on 2026-10-26 09:01 ([memory-headless.md](memory-headless.md)).
Nodes and objects were flat after warm-up, and orphans stayed at zero. Static memory
grew 20.5 MB over loops 25–300. A control run with the Note step turned off still grew
17 MB with no notes. Codex pointed to Browser history: every navigation was kept, 3,604
entries after 300 loops.

Claude capped history at 50 pages per tab (`DesktopSession.MAX_HISTORY`, tested by
`test_browser_history_is_capped`). Claude then re-ran the same probe, notes off, for 150
loops:

| Loop | History entries | Static (MB), capped | Static (MB), Codex control before cap |
| --- | ---: | ---: | ---: |
| 25 | 53 | 216.6 | 216.7 |
| 50 | 53 | 217.6 | 217.9 |
| 75 | 53 | 219.5 | 220.1 |
| 100 | 53 | 219.5 | 220.3 |
| 125 | 53 | 223.5 | 224.4 |
| 150 | 53 | 223.5 | 224.6 |
| teardown | 53 | 152.9 | 163.1 |

History is now bounded, but the static curve barely changed. History was not the cause.
The growth comes in steps (2–4 MB about every 50 loops, flat in between) while nodes and
objects stay flat. Judgement: this is the engine's allocator and caches growing, not a
leak in game objects. It amounts to about 17 MB over 300 loops that each open every
screen, which is far more than a playthrough does. The cap stays as hygiene. A deeper
look would need Godot's memory profiler. This is not a blocker.
