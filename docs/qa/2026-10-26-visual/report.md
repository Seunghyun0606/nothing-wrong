# CX-05 visual review — 2026-10-26

HEAD: `adf74ebaef5634692aaecde453aa768d5acd0843`

Initial `git status --short`:
```text
?? docs/codex/CX-05-visual-review.md
```
Git also warned that the global ignore file was inaccessible.

**Verdict: PASS for the reviewed CX-05 screenshot coverage — no reportable visual problems found.**

| Priority | Findings |
|---|---:|
| P1 — blocks or misleads play | 0 |
| P2 — hurts readability | 0 |
| P3 — polish | 0 |

## Findings

| Screenshot | Size | Language | Where | Problem | Priority |
|---|---|---|---|---|---|

No finding rows. `findings.csv` contains the required header and no data rows.

## Coverage

Screenshots with no reportable problems, listed by count only:

| Size | Language | Required tour images inspected | Focused images inspected |
|---|---|---:|---:|
| 1280x720 | ko | 29 | 5 |
| 1280x720 | en | 29 | 5 |
| 1440x900 | ko | 29 | 0 |
| 1440x900 | en | 29 | 0 |
| 1920x1080 | ko | 29 | 0 |
| 1920x1080 | en | 29 | 0 |
| Total | | 174 | 10 |

All 184 captured screenshots were visually inspected. Contact sheets were used for complete set review, with native-size inspection for suspected issues and focused follow-up. Contact sheets are derivatives and are excluded from screenshot counts.

Scope: Godot 4.7.2, OpenGL compatibility renderer, NVIDIA GeForce RTX 4070 SUPER. This is a visual review of captured states, not the TASK-010 human playtest or a claim about every possible interaction. Storefront/ONE HORIZON English and product-derived names/logs were not classified as localization omissions. Normal scrollable content and intentional scenario defects were distinguished from broken game layout.

## Reproduction and artifacts

Ran `res://tests/screenshot_tour.gd` unchanged, sequentially for each size/language above, using this command pattern (out-dir and log-file resolve inside the designated scratch folder):

```text
Godot_v4.7.2-stable_win64_console.exe --path godot --resolution WxH --log-file <absolute-scratch>/tour-WxH-lang.log --script res://tests/screenshot_tour.gd -- res://build/qa-2026-10-26-visual/tour-WxH-lang lang WxH
```

Screenshots, contact sheets, per-run logs, the focused probe, and automated verification are in [the scratch folder](../../../godot/build/qa-2026-10-26-visual/). The focused probe extends the original tour and captures only the suspect states after waiting/scrolling. Its screenshots are separate from the six required tours. [verification.json](../../../godot/build/qa-2026-10-26-visual/verification.json) records automated count, PNG integrity, actual dimensions, matching screenshot names, completion-log, and CSV-schema checks. Those checks passed; all eight Godot invocations exited 0 without missing-button/marker or script-parse/runtime errors.

Safety: inspected the tour and SaveFile.path implementation before running. Scripted main loops route persistence to user://tests/; the tour disables Settings, GameSession, and WorkspaceSession persistence and resets the session. No probe writes saves. Player saves were never opened, read, written, moved, or deleted. Only one Godot process ran at a time; none remained at final verification. Authored files are confined to the two authorized folders. No product edits, Project OS transitions, or Git-history changes were made.

Final Git check: HEAD unchanged; no tracked diff. Status contains the original untracked CX-05 brief plus the new report folder. Scratch output is ignored by Git.

## Execution and review log

The entries below were appended immediately after each screenshot set was inspected. Pending candidates in earlier entries are resolved by the focused checks and final disposition below.

### Set 1 — 1280x720 / ko

Ran the prescribed tour: exit 0; 29 PNGs, each 1280x720. Visually inspected all 29 using contact sheets and native-size checks. No confirmed persistent finding yet. Low-resolution photo detail and partially visible notification cards require follow-up before classifying: the app provides photo enlargement, and notification cards animate from behind the taskbar. Portal/storefront English is intentional and excluded. No-problem count remains provisional until these checks finish.

Run diagnostics (not visual findings): engine certificate-store error; known exit RID/texture/ObjectDB leaks. The res:// log argument emitted a directory warning despite producing a log; subsequent runs use an absolute log path.
### Set 2 — 1280x720 / en

Ran the prescribed tour: exit 0; 29 PNGs, each 1280x720. Visually inspected all 29. No additional confirmed persistent finding. English report options and deduction controls wrap and remain within their windows. Photo detail and notification-animation candidates remain pending the focused check. No finding rows added for an unverified candidate.
### Set 3 — 1440x900 / ko

Ran the prescribed tour: exit 0; 29 PNGs, each 1440x900. Visually inspected all 29. No additional confirmed persistent finding. T14 Source/Target now both appear in the initial viewport and the target's right-edge face cut is distinguishable; T32's tablet crop and T38's sideways preview are distinguishable. Photo enlargement and notification settling will be checked separately before finalizing their classification.
### Set 4 — 1440x900 / en

Ran the prescribed tour: exit 0; 29 PNGs, each 1440x900. Visually inspected all 29. No additional confirmed persistent finding. English requirement text uses more lines in the narrow side panel but remains readable and scrollable. The title card, lock text, desktop labels, report form, and deduction form fit. Candidate follow-up remains as recorded above.
### Set 5 — 1920x1080 / ko

Ran the prescribed tour: exit 0; 29 PNGs, each 1920x1080. Visually inspected all 29. No additional confirmed persistent finding. Windows keep their normal pixel dimensions with more desktop space; arranged Browser/Notes expand to the screen. The T14 enlarged target fits vertically at this size. No overlap or unintended locale difference identified in the inspected set.
### Set 6 — 1920x1080 / en

Ran the prescribed tour: exit 0; 29 PNGs, each 1920x1080. Visually inspected all 29. No additional confirmed persistent finding. All six required sets (174 tour images) have now been inspected. Focused verification below resolves the two remaining candidates before the final verdict.
### Focused check — 1280x720 / ko

Ran scratch-only focused_review.gd, extending the unchanged screenshot tour: exit 0; 5 additional PNGs, all inspected at native size. After waiting 0.6 seconds, notification cards are fully above the taskbar; the earlier partial cards were entrance-animation captures, not persistent off-screen popups. Scrolling the T14 table exposes both Source and Target; the missing right-edge face is visible even in the 72-pixel-high cells. Closing the console and scrolling the enlargement shows the crop clearly at 640 pixels wide. The T38 enlargement opens and scrolls with the sideways image preserved. Its table preview already shows the rotation, so the small preview does not conceal that defect. No product finding rows warranted by this follow-up.
### Focused check — 1280x720 / en

Ran the same scratch-only follow-up: exit 0; 5 additional PNGs, all inspected at native size. The settled English cards also fit above the taskbar. T14 table comparison and photo enlargement, and T38 enlargement/scrolling, reproduce the Korean result. No visual finding rows added.

## Final disposition

The notification candidate is resolved: after its 0.35-second entrance animation, cards sit fully above the taskbar in both languages. The tour captures after four frames, so some original screenshots show partially entered cards. This was not reported as a persistent layout defect.

The photo-size candidate is resolved for the requested defects: the T14 right-edge face cut is distinguishable after scrolling the table and clear in enlargement; the T32 tablet crop is distinguishable from the desktop version; the T38 sideways preview is distinguishable and its enlargement scrolls. Small pins/badge lettering need enlargement, but the requested crop/rotation defects remain observable. This classification is reviewer judgement based on the captured screens, not a human usability result.

Run diagnostics are retained in the logs: certificate-store access error and exit RID/texture/ObjectDB leaks. These are not visual findings; leak measurement belongs to CX-03. The first log-path directory warning did not prevent its 29 PNGs or log from being written; subsequent launches used absolute log paths.

Task result: CX-05 review complete; 6/6 required sets, 174/174 required screenshots inspected, 10 focused screenshots inspected, 0 findings, no fixes applied. No Project OS state transition was performed.
