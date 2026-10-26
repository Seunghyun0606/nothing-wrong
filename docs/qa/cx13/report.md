# CX-13 — TASK-020 fix recheck

Status: **COMPLETE for the assigned verification brief**. Date: 2026-10-26, Asia/Seoul.
Tested commit: `0fb0a410f9ecc70eeff9e1430f8c94cb31dff3e8`.
Role: Codex measurement/review. No fixes applied and no Project OS transition.

- **Part 1 — Accessibility: partly fixed.** Both P1 classes are fixed in the probes, all six primary focus cues are stronger, and the halo improves measured local contrast. Existing offscreen/covered focus, small text and other contrast flags remain; newly reachable Note targets expose additional clipped-focus flags.
- **Part 2 — Performance: partly fixed against the literal brief.** Export contamination and idle CPU saturation are fixed, and active engine work stays below 16.7 ms. The capped wall-clock intervals include small excursions above 16.7 ms, so “nothing exceeds” cannot be confirmed for that metric.
- **Part 3 — Playtest package: fixed for automated preflight.** Both hashes, outer and inner BUILD.txt, the unzipped EXE self-check, and the editor self-check pass. The normal launch/fresh-save/participant steps remain for the human session, as required by this brief's prohibition on a normal exported launch.

## Scope and evidence

Read PROJECT.md, Project OS manifest/current state, CX-13, RULES.md, prior CX-11/CX-12 reports and probes, the fix disposition, Build instructions, facilitator checklist and session template. The explicit CX-13 assignment determines the task; no task claim/submit/review/evaluate or state edit was performed.

Authored files are confined to `godot/build/cx13/` and `docs/qa/cx13/`. Player saves were never enumerated, read, hashed, moved or changed. Scripted SceneTree routing is checked in `SaveFile.path()` before autoload save loading; probes record/assert `user://tests/` paths and disable persistence before actions. No save fixture was created, so none needed cleanup. Exported processes always received `-- --self-check`. All Godot runs were sequential; console wrappers belong to the same run.

The repository hash audit covered 6,813 existing files, including prior QA scratch, while excluding `.git`, `node_modules`, `.godot` and the two CX-13 output folders. **One external change was observed:** `godot/build/cx-runs/cx13.log`, a launcher-maintained live Codex transcript (its header identifies Codex and its tail contains current tool invocations). It grew while the task ran. The agent did not write, truncate or restore it. Raw `scope_ok=false` is retained in `scope-audit.json`, alongside this attribution. No other outside-folder addition, removal or content change was found. Godot's permitted import cache/log writes are outside this repository-content comparison.

## 1. Accessibility

### Coverage and keyboard results

Reused the final CX-11 probe at English/Korean × 1280×720/1920×1080: 36 measured screens per combination, 144 total. All four runs exited 0 and reached the day-change screen. Output paths changed to CX-13; screen fixtures, key dispatch, bidirectional traversal and focus-pair measurement remain the original method. Added outline metadata and retained-outline frames at lock/desktop. The original screenshot-only tour was not rerun: its screens are covered by the instrumented probe and the explicit added screens.

All **100/100 original keyboard activations passed**, versus 92/100 in CX-11. Both `Markcart_subtotal` and `Markcheckout_confirmButton` were reached and pressed in every combination (English Enter, Korean Space). No direct-marker fallback was needed for either. The supplement tests **both Enter and Space in every matrix combination**, with 104/104 successful activations and one added evidence item per activation.

The supplement visits all 13 marker instances across product/cart/checkout: product price/stock; cart stock/remove action/quantity/line total/subtotal/shipping/total; checkout subtotal/shipping/total/confirm. There are 10 distinct target names because the summary targets repeat on checkout. Every supplementary reachability attempt succeeded via Tab. This is fixture-assisted verification, not a continuous keyboard-only player playthrough; other product pages/portal evidence targets were not individually enumerated.

**My Notes:** the original stateful sequence now records same-owner flags `[false, true, false]` in all four combinations. Tab leaves the editor without inserting a tab, Shift+Tab returns to it from the next control, and Escape releases focus. That middle `true` is the expected return, not a trap. The supplemental test starts each key independently inside My Notes: Tab, Shift+Tab and Escape all move focus away, with unchanged text, in all 12 checks. Tab goes to the taskbar NS control, Shift+Tab to AskHint, and Escape to no focus owner.

### Primary action focus

Counts use the original >3/255 channel-difference criterion inside the action rectangle, with window/toast occlusion masks. Each row is the same at both resolutions; pairs show an actual dark border. These counts demonstrate a stronger cue, not a formal focus-conformance certification.


| Action | CX-11 | CX-13 English | CX-13 Korean |
| --- | --- | --- | --- |
| Start work | 76 | 1604 | 1604 |
| Sign in | 76 | 2072 | 2072 |
| Start test | 76 | 806 | 878 |
| Send report | 76 | 920 | 878 |
| Send deduction | 76 | 1154 | 1388 |
| Clock out | 76 | 812 | 764 |


### Contrast with the outline accounted for

Preserved the original paired-frame sRGB luminance method and its thresholds (3:1 clock/date, 4.5:1 14 px regular icon captions). The wallpaper-only comparison reproduces the prior failures, so the difference is not a changed crop or a rectangle average.

An additional GPU frame hides glyph fill **while retaining the actual outline**, and metadata records outline sizes 10/6/4 and white alpha 0.8 for clock/date/captions. Removing both fill and outline would measure an invisible backing. Even retaining the outline leaves wallpaper in the hollow center of thick 96 px glyphs, so fill-footprint contrast alone is not the contrast at the visible text boundary.

`measure_outline.py` identifies fill pixels by the same >3/255, coverage >0.08 and RGB-residual <0.035 rules, then takes the 8-connected inner glyph boundary. For every boundary pixel it inspects the 3×3 neighborhood in the retained-outline frame, selects the strongest **measured outline opacity** over the captured wallpaper, and compares the declared dark glyph color with that actual composited pixel. This is a local outline-backing measurement, not a global bright-background selection. Every tested boundary pixel has a neighboring outline at ≥0.72 opacity (90% of the intended 0.8); the observed minimum selected opacity is about 0.797. Minimum, p05 and median, wallpaper-only and hollow-footprint alternatives are preserved in `outline-measurements.json`.

All requested lock/desktop samples pass with the outline counted. The table shows **minimum glyph/adjacent-outline ratios**:


| Matrix | Clock | Date | Messenger | Browser | QA Notes |
| --- | --- | --- | --- | --- | --- |
| en-1280x720 | 12.41:1 | 11.85:1 | 13.06:1 | 12.84:1 | 12.69:1 |
| en-1920x1080 | 11.83:1 | 13.21:1 | 13.07:1 | 12.95:1 | 12.83:1 |
| ko-1280x720 | 12.09:1 | 11.83:1 | 13.07:1 | 12.84:1 | 12.69:1 |
| ko-1920x1080 | 11.84:1 | 13.21:1 | 13.07:1 | 12.95:1 | 12.83:1 |


Wallpaper-only minima still span **2.26–3.33:1** for the clock, **2.29–5.42:1** for the date and **4.07–4.47:1** for QA Notes. The measured visible outline changes those immediate surroundings; the wallpaper itself was not made higher contrast. This is the stated measurement method, not a full WCAG audit.

The automatic foreground-only scanner initially retained 23 outline-related flags: three thick-clock hollow-footprint cases and 20 later-screen repetitions of the icon caption. `paired-findings.csv` and `paired-summary.json` preserve that raw output. `outline-disposition.csv` records their removal from the residual list. The later captions are the unchanged same control instances; applying the measured desktop-outline result to those later occurrences is a **judgement**, not a separately captured retained-outline frame for each later screen.

### Still/newly flagged compared with CX-11


| Finding class | CX-11 occurrences | CX-13 occurrences | Disposition |
| --- | --- | --- | --- |
| Unreachable evidence markers | 8 | 0 | fixed |
| My Notes traversal-trap rows | 48 | 0 | fixed |
| Weak primary focus | 24 | 0 | fixed |
| Text contrast | 133 | 104 | clock/date/caption flags cleared; other colors remain |
| Text below 12 px | 24 | 24 | unchanged |
| Focus outside clipped viewport | 298 | 448 | still present; longer traversal exposes more positions |
| Covered focused action | 4 | 4 | unchanged |
| Clipped marker focus sample | 0 | 2 | newly reachable checkout marker at 720p |


Residual `findings.csv`: **582 occurrence rows (562 P2, 20 P3; no P1)**. These are repeated screen/locale/direction observations, not distinct defect counts. `findings-comparison.csv` provides the screen/text/category comparison; dynamic Godot instance IDs are not treated as stable identities.

- **Remaining contrast:** Shoply uppercase 12 px labels at 3.8998:1 (intentionally retained in the disposition), record-source text at 4.3195:1, and warning/status/waiting copy at 4.4569:1, against the same 4.5:1 threshold. No new non-outline contrast text class was found.
- **Remaining small text:** twenty 7 px `MS` avatar-initial observations (P3; name adjacent) and four 11 px count-badge observations (P2).
- **Remaining focus visibility:** scroll-container content, My Notes and some Messenger links/authors can still receive focus outside the clipped viewport. The editor can be exited now, but focusing it does not always scroll it into view. The Messenger product link still accepts activation while fully covered by Browser in all four original runs.
- **Newly exposed marker clipping:** at 720p, the original checkout fixture has `Markcheckout_confirmButton` at `[570,704,345,54]` but clipped rect `[0,0,0,0]`, in both languages. It accepts the key and records evidence without a visible target/cue. The focus analyzer now respects ancestor clipping; it does not mislabel pixels behind the taskbar as visible. The supplemental maximized product page similarly focuses `Markproduct_stock` at `[650,679,585,26]` wholly outside the parent clip in both languages and both key variants (four rows in `supplemental-findings.csv`). These are additional affected controls in the pre-existing clipping class, not proof that the fix introduced a layout regression. Checkout is visible at 1080p; maximized supplemental checkout is also reachable at 720p.

Suggested owner follow-up: make keyboard focus scroll the underlying evidence target/editor into view and expose the focused app window. No code change was made here.

## 2. Performance

Same machine/method as CX-12: Ryzen 5 7500F (12 logical CPUs), RTX 4070 SUPER/NVIDIA 610.88, 31.60 GiB OS-visible RAM, Windows 25H2 build 26200.9711; 1920×1080 window and viewport, Korean, sound on, GL Compatibility, VSync mode 1, 120.083 Hz physical display. Registry/Win32 inventory was refreshed; WMI was not queried in CX-13. Godot 4.7.2.stable.official.ed1daf0bf. No FPS override was passed.

The copied CX-12 performance probe retains its ten screens, synthetic unlocked session, 2.5 s settle, 10 s samples and 60 s desktop idle. Added only idle frame-counter metadata; screen/CPU sampling is unchanged. The runner launches the actual editor executable directly and samples **its PID**, not the console wrapper, with GetProcessTimes/GetProcessMemoryInfo. Screen snapshots and file I/O occur outside sample windows. `performance-run.json` records the exact command. The inherited stdout markers still say `CX12`; paths and data belong to CX-13.

### Export and PCK


| Artifact | CX-11/12 baseline bytes | CX-13 bytes | CX-13 MiB |
| --- | --- | --- | --- |
| EXE with embedded PCK | 358870584 | 126431184 | 120.57 |
| Exact extracted embedded PCK | 249665580 | 17226180 | 16.43 |
| PCK payload | 249305205 | 17213768 | 16.42 |
| PCK directory/padding | 360375 | 12412 | 0.0118 |

EXE and PCK sizes must not be added: the PCK is embedded. The unchanged export preset was used, with an explicit CX-13 destination. Parsed all 141 directory entries, verified all stored MD5s, and extracted the exact embedded region. **Zero `build/` entries by packed path or remapped source**. CX-12 had 2,999 such entries / 231,992,416 bytes. Source attribution follows the original `.import`/`.remap` mapping, including descriptor bytes; directory/padding is separate.

| PCK source folder | Entries | Payload bytes | MiB |
| --- | --- | --- | --- |
| assets/art | 10 | 1917523 | 1.829 |
| assets/people | 14 | 630611 | 0.601 |
| assets/photos | 22 | 12769920 | 12.178 |
| assets/products | 6 | 1125967 | 1.074 |
| data | 7 | 343646 | 0.328 |
| i18n | 1 | 180321 | 0.172 |
| other engine/project resources | 3 | 4201 | 0.004 |
| scenes | 2 | 966 | 0.001 |
| scripts | 76 | 240613 | 0.229 |
| build | 0 | 0 | 0.000 |


### Desktop idle


| Metric | CX-13 |
| --- | --- |
| Interval / samples | 60.015 s / 58 (~1 Hz plus endpoints) |
| CPU time | 4.96875 CPU-seconds |
| CPU, one core = 100% | 8.279% (CX-12: 100.03%; about 91.7% lower) |
| CPU, all 12 logical CPUs = 100% | 0.690% |
| Working set | mean 274.82; range 274.65–274.94 MiB; 274.65 → 274.94 MiB (Δ +0.293) |
| Private bytes | mean 313.00; range 312.96–313.14 MiB; 312.96 → 313.00 MiB (Δ +0.047) |
| Idle engine loop | 3601 process frames / 60.014275 s = 60.0024/s; Engine.max_fps=60 |

CX-12 memory means were 274.20 MiB working set and 302.78 MiB private bytes; CX-13 private bytes are about 10.22 MiB higher in this single run. The interval is stable, but 60 seconds does not establish long-term leak behavior. Idle loop rate fell from the uncapped thousands-per-second regime to about 60.0. These are engine loops, not independently measured physical display presentations.


### Same ten screen samples


| Screen | Frames / seconds | Loop Hz | Wall avg / p99 / max ms | TIME_PROCESS avg / max ms | Wall intervals >16.7 ms |
| --- | --- | --- | --- | --- | --- |
| title | 601 / 10.016 | 60.002 | 16.666 / 16.793 / 17.080 | 0.814 / 1.037 | 35 |
| lock | 601 / 10.016 | 60.002 | 16.666 / 16.901 / 17.058 | 0.792 / 1.069 | 32 |
| desktop | 601 / 10.016 | 60.002 | 16.666 / 16.739 / 17.342 | 0.922 / 1.146 | 28 |
| messenger-long-chat | 601 / 10.016 | 60.002 | 16.666 / 16.719 / 17.154 | 2.253 / 2.847 | 24 |
| browser-shoply | 601 / 10.016 | 60.002 | 16.666 / 16.724 / 17.229 | 1.232 / 1.391 | 23 |
| record-with-photos | 601 / 10.016 | 60.002 | 16.666 / 16.866 / 17.151 | 1.381 / 1.643 | 22 |
| photo-zoom | 601 / 10.016 | 60.002 | 16.666 / 16.715 / 17.383 | 1.270 / 1.448 | 21 |
| directory | 601 / 10.016 | 60.002 | 16.666 / 16.714 / 17.113 | 1.352 / 1.627 | 17 |
| qa-notes | 601 / 10.016 | 60.002 | 16.666 / 16.708 / 16.834 | 1.507 / 1.933 | 19 |
| case-file | 601 / 10.016 | 60.003 | 16.666 / 16.740 / 17.105 | 2.452 / 3.103 | 27 |

All active-work monitor maxima are below 16.7 ms (highest **3.103 ms**, Case File). `TIME_PROCESS` refreshes less often than process_frame; repeated readings are not independent frame observations. The same raw wall-interval method now includes the limiter's wait: averages are about 16.666 ms, with **248/6,010 intervals above 16.7 ms**, worst **17.383 ms**. Thus the brief's literal zero-exceedance wall-time assertion fails. Small capped-loop excursions are consistent with scheduling/frame-pacing variation; no driver cause or product regression was established. Neither metric is silently substituted for the other.

The inherited probe also repeats photo-opening tests. Those are not the steady-frame criterion; for context, first thumbnail view drawing was 183.832 ms here versus 143.91 ms in CX-12. This brief did not request a new opening-latency verdict, and no threshold/regression conclusion is inferred from that single run. Raw opens are retained.

## 3. Playtest package / “Before the session”

Copied the package-root ZIP, SHA256SUMS.txt, BUILD.txt and original self-check.txt to `godot/build/cx13/package/`, then extracted the ZIP there with the `NothingWrong/` directory intact. The ZIP contains `NothingWrong/BUILD.txt` and `NothingWrong/NothingWrong.exe`. Both outer and inner BUILD.txt name the full tested commit.


| Artifact | SHA-256 | Result |
| --- | --- | --- |
| NothingWrong-0fb0a41.zip | `244ECBB0FD73EDCEF7329AD176F5CD6B352004D5D46C33AD644B6F928A919B39` | matches SHA256SUMS.txt |
| NothingWrong/NothingWrong.exe | `92C58F7B281BE22FD1E7F7BF496655355660AE0D9D1DF4E32CD1E5EABF0708EA` | matches SHA256SUMS.txt |


From that package root, executed the facilitator PowerShell pipeline, adding only `--log-file ..\package-selfcheck-engine.log` to keep logs in scratch:

```powershell
.\NothingWrong\NothingWrong.exe --headless --quit-after 3000 --log-file ..\package-selfcheck-engine.log -- --self-check | Out-String
```

It printed **Self-check passed** and `$LASTEXITCODE` was **0**. Fresh source-editor and newly exported CX-13 checks also passed with exit 0. All report 42 tickets, 10 chapters, 25 records, 30 views, 8 people and 12 photo references. Original package self-check.txt contains matching exported/editor pass results; fresh output is retained separately.


| Before-session step | Result |
| --- | --- |
| Unzip, preserve folder, compare ZIP and EXE hashes | passed; both hashes verified against package SHA256SUMS |
| Run exported check, require success line and exit 0 | passed using unzipped EXE and the PowerShell waiting pipeline |
| Complete both README Build checks and retain output | passed: new export + editor; package EXE checked separately |
| Copy session template and record known metadata | copied to session-preflight-template.md; preflight date/timezone, full commit and exported-build provenance filled; OS/screens/languages documented here; unknown human fields left unfilled |
| Ask participant permission before recordings/screenshots | not performed: no participant/human recording; captures are synthetic probe UI |
| Normal EXE launch, Start work/New game, fresh save and language selection | not executed: explicitly forbidden for CX-13; remains a facilitator step on a resettable human-session account |

No executed automated checklist step failed as written. The normal-launch/fresh-save confirmation is intentionally untested, not silently marked passed. This report is not a participant session, does not provide its observations, and does not close TASK-010 or M4.

## Artifacts and validation

- [Execution journal](execution-journal.md): report written incrementally during runs, preserved before this final consolidation.
- [Residual findings](findings.csv), [comparison to CX-11](findings-comparison.csv), [outline disposition](outline-disposition.csv), [supplemental clipped markers](supplemental-findings.csv).
- Scratch: `godot/build/cx13/`. Original probe frame pairs/metadata/focus pairs: `probe-*/`; stateful sequence: `trap-*/`; independent keys/all product-cart-checkout markers: `supplement-*/`.
- `runs.jsonl`, `supplement-runs.jsonl`, `keyboard-summary.json`, `supplement-summary.json`, `focus-summary.json`, `outline-measurements.json`, `measurements.jsonl`, and raw scanner summaries retain the detailed evidence. `measure_outline.py` defines the local boundary calculation; `analyze.py` is the copied paired scanner with documented outline/clipping adaptations. Raw and dispositioned findings are distinct.
- `pack-size.json`, `pck-files.csv`, `pck-integrity.json`, `NothingWrong.exe`, `NothingWrong.pck`; `machine.json`, `probe-metadata.json`, `idle.json`, `idle-loop.json`, `frames.json`, `photo-opens.json`; export/self-check/performance logs and result JSONs.
- `repository-before.json`, `repository-after.json`, `scope-audit.json`, and git snapshots preserve the scope audit. No Git history operation was performed; the pre-existing untracked CX-13 brief is preserved.
- All expected completion records, 144 metadata frames, 100 original activations, 104 marker evidence additions, 12 independent exits, 10 performance samples and PCK integrity results were asserted. No SCRIPT ERROR appears in the run logs. Non-headless probes still log the known certificate-store read error and exit RID/ObjectDB/texture leaks; those are distinguished from self-check success and are not new CX-13 findings.

Structured task result: **verification complete; accessibility and literal frame-pacing limitations reported; no implementation changes; package automated preflight passed; human session and canonical project state unchanged.**

