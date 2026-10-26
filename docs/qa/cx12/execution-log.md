# CX-12 performance baseline

Status: in progress. Date: 2026-10-26 (Asia/Seoul).
Role: Codex measurement; assigned brief: `docs/codex/CX-12-performance.md`.

## Scope and safety

Read PROJECT.md, manifest/current state, CX-12, RULES.md, Build instructions, and save-routing/UI implementations. No Project OS transition or product modification. HEAD: `1c8f0d9bb9fde3946a7ad346cfc6f653cd3e1e09`. Existing untracked work is preserved. Only CX-12 output folders are written by probes; Godot may update its import cache/logs. No player save is inspected, hashed, moved, changed, or deleted. Exported executable will only run with `-- --self-check`; scripted SceneTree uses `user://tests/`. Persistence is disabled before probe actions. Godot processes run sequentially. This is automated measurement, not human playtest observation.

## Machine (recorded before export)

```json
{
  "timestamp": "2026-10-26T14:17:57.441054+09:00",
  "cpu": {
    "ProcessorNameString": "AMD Ryzen 5 7500F 6-Core Processor             "
  },
  "logical_processors": 12,
  "ram_bytes": 33933996032,
  "windows": {
    "ProductName": "Windows 10 Pro",
    "DisplayVersion": "25H2",
    "CurrentBuild": "26200",
    "UBR": 9711
  },
  "windows_api": [
    10,
    0,
    26200,
    2,
    ""
  ],
  "display": {
    "width": 1920,
    "height": 1080,
    "flags": 0,
    "refresh_hz": 120
  },
  "wmi": "Get-CimInstance denied; registry and Win32 APIs used instead.",
  "gpu": [
    {
      "DriverDesc": "NVIDIA GeForce RTX 4070 SUPER"
    }
  ]
}
```

Windows registry retains the legacy ProductName “Windows 10 Pro”; build 26200 / 25H2 is reported explicitly to avoid relying on that label. WMI queries were denied, so registry and Win32 APIs supply the inventory. Exact physical panel model is pending the Godot display query.

## Execution log

1. Machine and repository hash baseline captured. No pre-existing Godot process found.
2. Release export completed, exit 0. Original export preset is unchanged (PCK embedded). Export log: `godot/build/cx12/export.log`.
- Export self-check cold (first launch after export): 834.50 ms to pass line, exit 0.
- Export self-check warm 1: 721.45 ms to pass line, exit 0.
- Export self-check warm 2: 706.99 ms to pass line, exit 0.
- Export self-check warm 3: 705.90 ms to pass line, exit 0.
- Export self-check warm 4: 719.35 ms to pass line, exit 0.
- Export self-check warm 5: 704.26 ms to pass line, exit 0.
3. Editor self-check also passed, exit 0. Export startup warm median: 706.99 ms. Cold means first post-export launch, not an OS cache flush.
2. Release export completed, exit 0. Original export preset is unchanged (PCK embedded). Export log: `godot/build/cx12/export.log`.
- Export self-check cold (first launch after export): 816.87 ms to pass line, exit 0.
- Export self-check warm 1: 725.39 ms to pass line, exit 0.
- Export self-check warm 2: 718.98 ms to pass line, exit 0.
- Export self-check warm 3: 758.66 ms to pass line, exit 0.
- Export self-check warm 4: 807.81 ms to pass line, exit 0.
- Export self-check warm 5: 787.70 ms to pass line, exit 0.
3. Editor self-check also passed, exit 0. Export startup warm median: 758.66 ms. Cold means first post-export launch, not an OS cache flush.
4. Scripted editor-binary title startup: first 1650.13 ms; following-five median 1542.07 ms to first frame_post_draw. Six successful launches. Probe paths verified under user://tests/.
4. Scripted editor-binary title startup: first 1597.17 ms; following-five median 1583.16 ms to first frame_post_draw. Six successful launches. Probe paths verified under user://tests/.
8. Parsed and extracted the exact embedded PCK: 358870584 bytes EXE; 249665580 bytes PCK; 3140 packed entries. No cx12 scratch entry is packed. Existing other build/ artifacts ARE packed; folder breakdown and largest-file evidence saved for the final report.
5. Desktop idle interval started; sampling process CPU time, working set, and private bytes once per second for 60 seconds.
6. Desktop idle interval finished; raw process samples saved in `godot/build/cx12/idle.json`.
7. All ten 10-second screen samples and photo-view first/later opens completed. Probe exit 0. Raw data, metadata, logs, and PNG evidence are in the scratch folder.
9. Validation correction: archived exploratory full run. Its idle samples measured the console wrapper (6.5 MiB / zero CPU), so they are invalid. TIME_PROCESS retained screenshot/transition spikes after a one-second settle, so those values are also excluded. Final run uses the real editor executable directly and 2.5 seconds of settling. An earlier title-only preload compile diagnostic was corrected by loading the UI script after autoload initialization; its preliminary numbers are superseded. Initial export was repeated after adding only cx12/.gdignore so the benchmark cannot package itself. Latest export/startup JSON and final tables are authoritative.
4. Scripted editor-binary title startup: first 1609.11 ms; following-five median 1531.76 ms to first frame_post_draw. Six successful launches. Probe paths verified under user://tests/.
5. Desktop idle interval started; sampling process CPU time, working set, and private bytes once per second for 60 seconds.
6. Desktop idle interval finished; raw process samples saved in `godot/build/cx12/idle.json`.
7. All ten 10-second screen samples and photo-view first/later opens completed. Probe exit 0. Raw data, metadata, logs, and PNG evidence are in the scratch folder.
10. Scope correction: export automatically created 714 new .import/.uid sidecars beside older QA scratch files. Creation times are within this export and original resources predate the run. Backed up exact generated bytes inside cx12, removed only those new sidecars, and preserved every original resource. Detailed creation-time/size/hash audit: generated-sidecar-cleanup.json. One pre-existing cx-runs/cx12.log was updated by the surrounding runner, predates our baseline, and was left untouched.
