# CX-08b: headless memory, 300 loops

Result: completed 300 full headless loops; exit 0; no probe failures. Started 2026-10-26T09:01:26 (local system time); loop 300 at 324.601 s, timer-drain sample at 332.625 s, teardown at 332.753 s. Godot 4.7.2 stable, headless display / dummy renderer.

The existing `godot/build/qa-cx08/memory_probe.gd` ran byte-for-byte unchanged in a scratch project at `godot/build/qa-cx08b/project/`. The project configuration, scripts, scenes, assets, data, translations, and imported resources were copied; no product configuration or code was edited. This preserves the probe's hardcoded `res://build/qa-cx08/` output paths while containing every output in CX-08b scratch.

```powershell
& 'C:/Users/limse/AppData/Local/shard-storm-tools/godot/4.7.2-stable/Godot_v4.7.2-stable_win64_console.exe' --headless --path godot/build/qa-cx08b/project --log-file ../memory-headless-engine.log --script res://build/qa-cx08/memory_probe.gd -- full headless-cx08b 300
```

One engine instance ran, with its console launcher. All nine probe step groups completed exactly 300 times: app open/close, tabs, record photos, directory badges, Shoply products, photo zoom, evidence note, Case File, and Messenger. Sampling was every 25 loops, followed by the unchanged probe's eight-second timer drain and scene teardown.

| Loop | Nodes | Objects | Orphans | Static (MB) | Notes | Save size (bytes) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 0 | 3,018 | 8,488 | 0 | 156.110 | 0 | 3,666 |
| 25 | 3,358 | 9,267 | 0 | 218.270 | 25 | 92,327 |
| 50 | 3,358 | 9,267 | 0 | 220.850 | 50 | 153,474 |
| 75 | 3,358 | 9,267 | 0 | 221.467 | 75 | 214,688 |
| 100 | 3,358 | 9,267 | 0 | 226.016 | 100 | 276,147 |
| 125 | 3,358 | 9,267 | 0 | 226.631 | 125 | 337,461 |
| 150 | 3,358 | 9,267 | 0 | 227.246 | 150 | 398,646 |
| 175 | 3,358 | 9,267 | 0 | 227.860 | 175 | 459,845 |
| 200 | 3,358 | 9,267 | 0 | 236.338 | 200 | 521,042 |
| 225 | 3,358 | 9,267 | 0 | 236.955 | 225 | 582,236 |
| 250 | 3,358 | 9,267 | 0 | 237.569 | 250 | 643,440 |
| 275 | 3,358 | 9,267 | 0 | 238.183 | 275 | 704,638 |
| 300 | 3,358 | 9,267 | 0 | 238.797 | 300 | 765,839 |
| 301 (8 s drain; no extra loop) | 3,358 | 9,257 | 0 | 238.788 | 300 | 765,839 |
| 302 (after teardown; no extra loop) | 17 | 1,693 | 0 | 168.190 | 300 | 765,839 |

MB = 1,000,000 bytes. Notes means captured evidence (`ws.evidence.size()`), not free-text notes. Save size is the probe's sum of serialized game and workspace UTF-8 byte counts, not a player save read from disk. The combined snapshot file adds its outer JSON wrapper.

- Nodes: flat after warmup, 3,358–3,358 across loops 25–300; 17 after teardown.
- Objects: effectively flat after warmup, 9,267–9,267 across loops 25–300; 1,693 after teardown.
- Orphans: zero in every sample.
- Static growth and notes: **not explained by saved notes alone**. Loops 25–300 add 20.528 MB of static memory, 275 evidence notes, and 673,512 serialized bytes; the note-disabled control below still grows in static memory with zero notes. Retained browser history is a likely contributor, but the allocation source of the larger steps remains unproven.

| Sample | Text notes | Chat entries | Browser history entries | Interactions | Photo cache | Texture bytes | Video bytes |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 0 | 0 | 260 | 4 | 2 | 4 | 0 | 0 |
| 25 | 0 | 260 | 329 | 200 | 15 | 0 | 0 |
| 300 | 0 | 260 | 3904 | 200 | 15 | 0 | 0 |
| 301 | 0 | 260 | 3904 | 200 | 15 | 0 | 0 |
| 302 | 0 | 260 | 3904 | 200 | 15 | 0 | 0 |

Initial static warmup was 62.159 MB while the photo cache expanded from 4 to 15. Browser history subsequently grows by 13 entries per loop; interactions cap at 200. Chat and free-text notes stay flat. Texture/video monitors report zero in this headless renderer and therefore do not measure GPU residency. Static after teardown is 168.190 MB with all 300 evidence notes still retained in the autoload workspace.

Save isolation: the scripted SceneTree routes autoload reads to `user://tests/` before initialization; the six test save/temporary paths were absent before launch. The probe printed game, workspace, and settings paths under `user://tests/`, then set all three persistence flags false before exercising the UI. No test save files were created by this probe, so none required cleanup. Player save paths were never read, written, moved, or deleted.

Startup diagnostics include the existing root-certificate-store error and a log-path warning/error: the relative `../` log argument caused Godot to attempt the invalid `user://..` directory before opening the scratch log. These did not prevent sampling or completion. Any shutdown RID/ObjectDB diagnostics are preserved in the logs; they are not represented by the in-run orphan monitor and this measurement alone does not establish their cause.

Scope verification: SHA-256 checked 481 pre-existing product, test, old CX-08 scratch, and CX-08 report files; 0 changed. The source and executed probe hashes match (`2272ccd0087dc85424bdf775f9b6355e5f66b5160e1c407b4efcc0151a383229`). No Project OS transition, code fix, or human-playtest claim was made.

Evidence:

- [Raw samples and step counts](../../../godot/build/qa-cx08b/memory-headless-cx08b-full.json)
- [Loop 300 serialized snapshot](../../../godot/build/qa-cx08b/saved-data-headless-cx08b-full-300.json) and [timer-drained snapshot](../../../godot/build/qa-cx08b/saved-data-headless-cx08b-full-301.json)
- [Console output](../../../godot/build/qa-cx08b/memory-headless.log), [engine log](../../../godot/build/qa-cx08b/memory-headless-engine.log), and [exit code](../../../godot/build/qa-cx08b/memory-headless-exit.txt)
- [Probe hashes](../../../godot/build/qa-cx08b/probe-hashes.json) and [protected-file check](../../../godot/build/qa-cx08b/protected-hashes-check.json)

## Diagnostic: note step disabled

A second, sequential run used the same unchanged probe with user arguments `without-note headless-cx08b-control 300`. Started 2026-10-26T09:07:08; loop 300 at 274.336 s; exit 0; no probe failures. The other eight step groups each completed 300 times. The engine log argument was absolute for this run, avoiding the first run's relative-log-path warning.

| Loop | Nodes | Objects | Orphans | Static (MB) | Notes | History entries | Save bytes |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 0 | 3,018 | 8,488 | 0 | 156.111 | 0 | 4 | 3,666 |
| 25 | 3,358 | 9,256 | 0 | 216.719 | 0 | 304 | 29,959 |
| 50 | 3,358 | 9,256 | 0 | 217.908 | 0 | 604 | 30,072 |
| 75 | 3,358 | 9,256 | 0 | 220.078 | 0 | 904 | 30,065 |
| 100 | 3,358 | 9,256 | 0 | 220.283 | 0 | 1,204 | 30,158 |
| 125 | 3,358 | 9,256 | 0 | 224.421 | 0 | 1,504 | 30,424 |
| 150 | 3,358 | 9,256 | 0 | 224.626 | 0 | 1,804 | 30,471 |
| 175 | 3,358 | 9,256 | 0 | 224.830 | 0 | 2,104 | 30,469 |
| 200 | 3,358 | 9,256 | 0 | 225.035 | 0 | 2,404 | 30,465 |
| 225 | 3,358 | 9,256 | 0 | 225.239 | 0 | 2,704 | 30,462 |
| 250 | 3,358 | 9,256 | 0 | 233.308 | 0 | 3,004 | 30,468 |
| 275 | 3,358 | 9,256 | 0 | 233.512 | 0 | 3,304 | 30,480 |
| 300 | 3,358 | 9,256 | 0 | 233.717 | 0 | 3,604 | 30,470 |
| 301 | 3,358 | 9,256 | 0 | 233.719 | 0 | 3,604 | 30,470 |
| 302 | 17 | 1,693 | 0 | 163.121 | 0 | 3,604 | 30,470 |

From loops 25–300, static still grows 16.997 MB (61.809 KB/loop), while saved size changes by only 511 bytes and evidence stays at zero. Browser history grows from 304 to 3,604 entries (12 per loop). As above, 301 is the timer-drain sample and 302 is teardown, not additional loops.

Judgement: accumulated notes explain the main run's serialized-data growth, but do not explain all headless static growth. The likely application retention path to investigate is `DesktopSession.navigate()` (`godot/scripts/autoload/desktop_session.gd:304`), which slices the current history and appends every navigation; `visited()` also collects that retained history. Browser history lives in the autoload and is omitted from the probe's saved-data JSON, so increasing live data need not increase its save-size metric. This control also removes one navigation per loop with the note step, and does not isolate history from engine caches or allocator capacity. Therefore it localizes growth beyond note creation but does not prove a leak or assign the static jumps to a specific allocation. A bounded-history control would be needed for causal attribution; the required probe was kept unchanged. No code fix was made.

- [Control raw JSON](../../../godot/build/qa-cx08b/memory-headless-cx08b-control-without-note.json)
- [Control console log](../../../godot/build/qa-cx08b/control.log), [engine log](../../../godot/build/qa-cx08b/control-engine.log), and [exit code](../../../godot/build/qa-cx08b/control-exit.txt)

Final scope/isolation check after both runs: all 481 protected hashes still match; the six `user://tests/` save/temporary files remain absent. Both engine logs contain no shutdown RID/ObjectDB leak diagnostics.

The 137 staged configuration, source, scene, asset, and content files also match their originals byte-for-byte; see [staging fidelity check](../../../godot/build/qa-cx08b/staged-fidelity.json). Git status before and after matches (the report is inside an already untracked QA directory).
