# CX-12 performance baseline

Status: COMPLETE for the assigned measurement brief, with limitations and diagnostics below. Date: 2026-10-26 (Asia/Seoul).

Role: Codex verification/measurement. Source: `docs/codex/CX-12-performance.md` and `docs/codex/RULES.md`. HEAD: `1c8f0d9bb9fde3946a7ad346cfc6f653cd3e1e09`. This does not approve M4 or replace TASK-010 human playtesting.

## Machine and run conditions

| Item | Recorded value |
| --- | --- |
| CPU | AMD Ryzen 5 7500F 6-Core Processor; 12 logical processors |
| GPU | NVIDIA GeForce RTX 4070 SUPER; OpenGL log reports NVIDIA 610.88 |
| RAM | 32 GiB installed; 31.60 GiB OS-visible |
| Windows | 25H2; build 26200.9711; registry ProductName: Windows 10 Pro |
| Display | 1920×1080; 120.083 Hz; 96 DPI |
| Engine | Godot 4.7.2.stable.official.ed1daf0bf; GL Compatibility |
| Test window | 1920×1080 client area and viewport; windowed; Korean; sound on |
| VSync | Default enabled (mode 1); no FPS cap or VSync override passed |

Inventory was recorded before export. WMI queries were denied, so registry/Win32 APIs were used; Godot confirmed the display and rendering GPU. The legacy Windows ProductName is retained verbatim; the build/version are the reliable comparison identifiers. CPU core count is inferred from the processor model; logical count comes from the OS. No power-plan, GPU-driver, or OS-cache setting was changed.

## Method and safety

- All probes/builds are under `godot/build/cx12/`; report deliverables are under `docs/qa/cx12/`. Product files, export preset, Project OS state, story content, and Git history are unchanged. Existing work is preserved. Godot import cache updates and runtime logs are allowed. Export also generated new import sidecars outside CX-12; those accidental files were audited and removed, as documented below.
- Player saves were never read, hashed, moved, written, or deleted. Exported runs always include `-- --self-check`; scripted SceneTree save paths are asserted as `user://tests/save.json`, `workspace.json`, and `settings.json`. Probe persistence is disabled before actions, and probe state is in memory. No probe save files were created, so no save cleanup was needed.
- Godot runs were sequential. Console-wrapper processes are not independent project runs. The final frame/idle probe launches the actual editor executable directly, and measures that PID rather than its console wrapper.
- Startup uses a host monotonic clock immediately before process creation until receipt of the success/title-frame line on stdout. Export self-checks are headless. Title timing uses the real scene and `RenderingServer.frame_post_draw`; it is not the self-check time.
- Each screen settles for 2.5 s, then samples approximately 10 s. Wall frame intervals use monotonic microseconds between `process_frame` signals; engine process/drawn frame counters were checked against the samples. Average FPS = frames / elapsed seconds. **1% low** = 1000 / mean of the slowest ceil(1% of frames) durations. Raw intervals are retained.
- `Performance.TIME_PROCESS` is read every sampled frame, converted to ms, and reported as its frame-weighted mean and maximum. Its observed refresh cadence is lower than the frame loop; repeated monitor values are not independent per-frame observations. Screenshot readback and file writing occur outside sample windows. The longer settle avoids stale readback/transition values.
- Engine loop FPS exceeds the physical refresh rate in this environment despite VSync mode 1. These are engine throughput figures, **not measured display presentation FPS**; no driver-level cause was established. They must not be compared directly to a 60/120 Hz presentation counter.
- Screen frame/idle data use the editor executable with a custom SceneTree, not an instrumented release. Release verification/startup use the exported EXE. Long chat uses the real 79-entry `# shoply-autumn-release` conversation within a synthetic fully unlocked 290-entry session; no invented chat text. QA Notes is T36; Case File includes the unlocked story. This fixture is not a player playthrough.
- Cold export startup means first run after the final export, exactly as briefed. It is not a cold OS filesystem-cache test. Later warm values are the median of five independent launches. Photo “first” means first visit in this fresh probe process; shared images/variants can already be cached from an earlier view. Tablet runs follow desktop runs; zoom reuses its thumbnail texture.

## Export size

| Artifact/component | Bytes | MiB |
| --- | --- | --- |
| EXE (includes embedded PCK) | 358,870,584 | 342.25 |
| Exact embedded PCK, also extracted to NothingWrong.pck | 249,665,580 | 238.10 |
| Non-PCK executable portion | 109,204,992 | 104.15 |
| PCK file payload | 249,305,205 | 237.76 |
| PCK header/directory/alignment | 360,375 | 0.34 |
| EXE PCK footer | 12 | 0.000011 |

The unchanged preset embeds the pack, so EXE and PCK sizes must not be added. The extracted standalone PCK is byte-for-byte the embedded region, not a second export. Parsed the Godot v4 PCK directory: 3140 entries; every entry passed its stored MD5 check. SHA-256 is in the scratch manifest.

| PCK folder attribution | Packed entries | Payload bytes | MiB |
| --- | --- | --- | --- |
| data | 7 | 343,646 | 0.328 |
| i18n | 1 | 180,321 | 0.172 |
| assets/photos | 22 | 12,769,920 | 12.178 |
| assets/people | 14 | 630,611 | 0.601 |
| assets/products | 6 | 1,125,967 | 1.074 |
| assets/art | 10 | 1,917,523 | 1.829 |
| scripts | 76 | 239,995 | 0.229 |
| scenes | 2 | 966 | 0.001 |
| build (pre-existing scratch artifacts) | 2999 | 231,992,416 | 221.245 |
| other engine/project resources | 3 | 103,840 | 0.099 |

Actual packed payload sizes are used, not original source JPEG sizes. `.import`/`.remap` descriptors map `.godot/imported` textures and exported script/scene resources back to their source folders. Descriptor bytes are included in their source folder. Directory/padding overhead is outside the folder totals. The CX-12 folder has `.gdignore` and contributes zero packed entries.

## Startup

| Run | Export self-check to pass line (ms) | Scripted editor title first draw (ms) |
| --- | --- | --- |
| Cold / first measured | 816.87 | 1609.11 |
| Warm 1 | 725.39 | 1512.84 |
| Warm 2 | 718.98 | 1531.76 |
| Warm 3 | 758.66 | 1548.48 |
| Warm 4 | 807.81 | 1525.73 |
| Warm 5 | 787.70 | 1554.46 |
| Warm median (five) | 758.66 | 1531.76 |

All six exported checks passed with exit 0. The editor headless self-check also passed (1355.89 ms). Counts: 42 tickets, 10 chapters, 25 records, 30 views, 8 people, 12 photo references. Title runs all reached the first drawn title frame and exited 0 without script errors. The title first measured run is not claimed to have cold caches.

## Frame time per screen

| Screen | Seconds / frames | Avg FPS | 1% low FPS | Avg frame ms | Worst frame ms | TIME_PROCESS avg / max ms | Frames >16.7 ms |
| --- | --- | --- | --- | --- | --- | --- | --- |
| title | 10.000 / 45,643 | 4564.3 | 2048.7 | 0.219 | 0.909 | 0.662 / 0.759 | 0 |
| lock | 10.000 / 47,845 | 4784.4 | 2155.3 | 0.209 | 1.309 | 0.629 / 0.669 | 0 |
| desktop | 10.000 / 39,281 | 3928.1 | 1900.4 | 0.255 | 0.934 | 0.696 / 0.920 | 0 |
| messenger-long-chat | 10.000 / 8,684 | 868.4 | 555.4 | 1.152 | 2.455 | 2.013 / 2.421 | 0 |
| browser-shoply | 10.000 / 23,034 | 2303.3 | 1394.5 | 0.434 | 1.089 | 0.810 / 1.065 | 0 |
| record-with-photos | 10.000 / 18,735 | 1873.5 | 1200.5 | 0.534 | 1.451 | 0.993 / 1.434 | 0 |
| photo-zoom | 10.000 / 21,700 | 2169.9 | 1285.4 | 0.461 | 1.036 | 0.897 / 1.084 | 0 |
| directory | 10.001 / 15,560 | 1555.9 | 689.1 | 0.643 | 5.218 | 1.526 / 3.054 | 0 |
| qa-notes | 10.000 / 12,360 | 1236.0 | 465.1 | 0.809 | 3.628 | 2.276 / 3.415 | 0 |
| case-file | 10.001 / 7,712 | 771.1 | 464.5 | 1.297 | 2.561 | 2.172 / 2.516 | 0 |

The samples are steady screens, without scripted scrolling, dragging, typing, or screenshot work inside the sample window. Navigation/photo first opens are measured separately below. Engine loop rate and CPU process time are distinct metrics.

## Photo and image-bearing view openings

| View | First sync build ms | First draw ms | Later sync median ms | Later draw median ms |
| --- | --- | --- | --- | --- |
| shoply-product-photos | 50.52 | 55.60 | 48.52 | 51.52 |
| photo-thumbnails | 137.37 | 143.91 | 15.76 | 19.75 |
| photo-zoom-IMG001-Target | 5.78 | 10.57 | 5.75 | 10.15 |
| cms-albums | 115.48 | 122.82 | 20.30 | 26.98 |
| foundation-gallery | 87.54 | 91.75 | 15.84 | 19.41 |
| opportunity-program | 41.88 | 48.13 | 17.82 | 22.30 |
| archive-attachments | 101.61 | 105.77 | 14.58 | 17.71 |
| foundation-gallery (tablet) | 61.77 | 65.36 | 14.29 | 17.56 |
| directory-badge-photos | 60.25 | 71.84 | 60.55 | 70.18 |
| person-badge-photo | 63.91 | 72.30 | 66.45 | 73.44 |

Each row has one first visit and two later visits. Sync build measures the real navigation/click handler, including synchronous image load/readback, decoding/decompression, crop/rotation, texture creation, and UI rebuild as applicable. First draw adds completion of the next `frame_post_draw`. These are whole-view latency measurements, not an isolated JPEG-decoder microbenchmark. Directory/person/Shoply rows include badge/product images. The five record views cover all photo-bearing portal views; gallery tablet adds device-specific crops.

## Desktop idle (60 seconds)

| Metric | Result |
| --- | --- |
| Interval / samples | 60.000 s / 58 samples (~1 Hz plus endpoints) |
| Process CPU time | 60.016 CPU-seconds |
| Average CPU (one core = 100%) | 100.03% |
| Average CPU (all 12 logical CPUs = 100%) | 8.34% |
| Per-interval CPU range, one-core scale | 97.27%–103.04% |
| Working set | mean 274.20 MiB; min–max 274.19–274.27 MiB; start → end 274.19 → 274.20 MiB (Δ +0.01 MiB) |
| Private bytes | mean 302.78 MiB; min–max 302.74–302.93 MiB; start → end 302.74 → 302.78 MiB (Δ +0.04 MiB) |

Process CPU comes from Windows user+kernel time deltas; memory from GetProcessMemoryInfo. This is application-process usage, not system CPU or GPU utilization. Desktop has no app window open and no input; sound/office ambience remains enabled. The title/lock/desktop screens were already visited; it is not a fresh-process minimum-memory test. No changing messages arrived during the idle interval.

## Threshold findings and likely causes

Result: no sampled steady-screen wall frame or TIME_PROCESS maximum exceeded 16.7 ms in the final run. This does not establish performance on slower hardware.

Result: no first image-bearing view open exceeded 200 ms.

Navigation costs can still exceed a single 16.7 ms frame budget, even when under the separate 200 ms first-open threshold:

| First open >16.7 ms synchronous work | Sync ms / first draw ms |
| --- | --- |
| shoply-product-photos | 50.52 / 55.60 |
| photo-thumbnails | 137.37 / 143.91 |
| cms-albums | 115.48 / 122.82 |
| foundation-gallery | 87.54 / 91.75 |
| opportunity-program | 41.88 / 48.13 |
| archive-attachments | 101.61 / 105.77 |
| foundation-gallery (tablet) | 61.77 / 65.36 |
| directory-badge-photos | 60.25 / 71.84 |
| person-badge-photo | 63.91 / 72.30 |

Judgement: `record_view.gd::photo_texture()` synchronously calls texture `get_image()`, optionally decompresses/crops/rotates, creates an ImageTexture, and caches it by drawn variant. The lower later-open costs and increased cache counts are consistent with that path; shared source pictures can still be read/cropped for different variants. Full UI reconstruction also contributes. This is a likely cause, not a sampled call-stack attribution.

Result: existing build scratch contributes 221.25 MiB (93.1% of PCK payload). The unchanged all-resources export admits older QA screenshots/imported textures, other resources and test fixture JSON. `pck-files.csv` identifies the exact packed files. Judgement/suggestion: exclude scratch builds from future distribution; this is the dominant current package-size opportunity. No export settings or original older artifacts were changed.

Judgement: the uncapped observed engine throughput can explain ongoing idle CPU use; the VSync request did not produce a refresh-rate-sized engine loop here. A separate controlled capped run would be needed to establish causation. Do not treat the idle numbers as a power or GPU-utilization measurement.

## Diagnostics, validation, and limitations

- Export exited 0. It logged an existing nested CX-09 project being ignored and denied attempts to save global editor settings outside the permitted workspace. Those settings were not modified. The process was not granted broader permissions.
- Startup/probe logs retain `Failed to read the root certificate store.` The content self-check passed; this startup/environment diagnostic occurs before the self-check error collector. This is not a warning-free execution claim.
- Exploratory runs were excluded after identifying stale monitor screenshot costs and idle CPU measured on the console wrapper. Their raw results are retained under `godot/build/cx12/exploratory/`. A preliminary title-only dependency compile diagnostic was corrected in the scratch probe. The first export/startup sequence was superseded after excluding the CX-12 scratch folder. Final tables use only the latest validated JSON files.
- One short-lived pair of other Godot process names from a different tool installation was observed during the exploratory run; it had exited before final measurements. It was not stopped or altered. The final run started without another Godot process. Background system/user workloads and display presentation were not controlled or measured.
- Scope restoration: Godot export created 712 `.import` and 2 `.gd.uid` files alongside pre-existing QA scratch resources, outside the allowed CX-12 folder. Their creation times are all within the first export (05:18:02–05:18:21 UTC), and the source resources predate this run. Their exact bytes were backed up under CX-12, then only those new generated sidecars were removed. Original resources were preserved. Evidence: `generated-file-audit.json`, `generated-sidecar-cleanup.json`. No further editor export/import was run after cleanup. A pre-existing `godot/build/cx-runs/cx12.log` changed during this session; it was not a file opened for writing by these probes and was left untouched. Its writer was not independently established.
- Final source hash comparison covered 492 existing repository files (excluding Git internals, node_modules, Godot cache/build outputs and CX-12 report output): no added, removed, or changed files in that set. `git diff --exit-code` passed. Existing untracked work is preserved. Player-save files are deliberately outside this validation and were never inspected.
- No code fixes, Project OS task claims/transitions, commits, branches, or human-playtest judgements were made. Reproduction uses the scratch scripts; `run_baseline.py initial` captures a new baseline, `export-startup` exports and measures, `title-startup` measures the title, `frames-idle` measures screens/idle. `pack_inventory.py` inventories/extracts the embedded PCK; `finalize_report.py` recomputes this report. Run one Godot operation at a time.

## Evidence

- [Progress/execution log](execution-log.md)
- [Screen summary CSV](screen-summary.csv), [JSON](screen-summary.json), [idle summary](idle-summary.json), [photo openings](photo-opens.json)
- [Scratch folder](../../../godot/build/cx12/): exported EXE/PCK, SHA256SUMS.txt, artifact-verification.json, full PCK listing and sizes, machine/probe metadata, raw per-frame/idle samples, startup commands/logs, screenshots, source-scope checks and reproducible probes.
- Each of the ten final screenshots is 1920×1080 (PNG headers checked) and was captured after its sample. Visually inspected the final Messenger, photo zoom and Case File screenshots: the intended long chat, enlarged photo and populated Case File are rendered. The screenshots are evidence of the rendered fixtures, not human-playtest observations.

## Structured task result

| Acceptance item | Result |
| --- | --- |
| Machine recorded before export | PASS; installed RAM/display details subsequently confirmed |
| EXE/PCK sizes and requested folder breakdown | PASS; exact embedded pack directory, all payload MD5 checks passed |
| Cold + five warm exported self-check timings | PASS; all exit 0 |
| Editor scripted title first-frame timing | PASS; six clean scripted launches |
| Ten screens at 1920×1080, ~10 s each | PASS; FPS, 1% low, TIME_PROCESS avg/max retained |
| First/later photo opens | PASS; five record views, tablet crops, zoom, plus directory/product photos |
| 60 s idle CPU/memory | PASS; actual engine PID, CPU-time deltas, working set/private bytes |
| Threshold list and labelled likely causes | PASS; above |
| Protected files and player saves | PASS; repository guard unchanged; player saves never inspected |
| Product fixes / Project OS changes | None; measurement only |
