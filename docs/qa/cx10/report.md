# CX-10 playtest build package report

Status: complete for CX-10 packaging; diagnostics recorded. Date: 2026-10-26 (Asia/Seoul).
Role: Codex verification and packaging; assigned brief: docs/codex/CX-10-playtest-build-package.md.

## Scope and baseline

- Read PROJECT.md, Project OS manifest/current state, CX-10, RULES.md, godot/README.md, participant guide, and session template.
- HEAD: `1c8f0d9bb9fde3946a7ad346cfc6f653cd3e1e09` (short `1c8f0d9`).
- Initial `git status --short`:

```text
?? docs/codex/CX-09-old-save-compatibility.md
?? docs/codex/CX-10-playtest-build-package.md
?? docs/codex/CX-11-readability-accessibility.md
?? docs/codex/CX-12-performance.md
?? docs/qa/cx09/
```

Git also warned that the global ignore file was inaccessible; status still exited 0.
No tracked modifications were reported. Existing untracked files are preserved.

## Safety and procedure

- Only write deliverables under godot/build/playtest-2026-10-26/, docs/qa/cx10/, and the new facilitator checklist. Godot may update its import cache and runtime logs.
- Do not read, write, move, hash, or delete player saves. No exported normal-mode launch.
- Inspected SaveFile.path(): `--self-check` and a custom SceneTree script select `user://tests/` before autoload save loading. Both self-checks disable persistence before screen exercise. The screenshot tour also disables persistence before changing language or exercising UI.
- No Godot process was running at baseline. Run all Godot operations sequentially.
- No Project OS transitions, Git history changes, product edits, or human playtest observations.

## Execution log

1. Baseline and save isolation reviewed. Export, checks, icon verification, packaging, and checklist pending.
2. Release export completed with exit 0; output currently contains NothingWrong.exe (242,567,408 bytes). Export log: `godot/build/playtest-2026-10-26/export.txt`. Godot reported that it could not save its global editor settings outside the authorized writable paths. This was an engine-side attempted write, denied by the environment; no permission change or external settings edit was made. Verify resulting artifact with both self-checks and icon extraction below.
3. Exported self-check: PASS, exit 0. Editor self-check: PASS, exit 0. Both printed `Self-check passed` with 42 tickets, 10 chapters, 25 records, 30 views, 8 people, and 12 photo references. Combined commands/output: `godot/build/playtest-2026-10-26/self-check.txt`.

Diagnostics retained: both checks log an OS root certificate store read error at startup and two ObjectDB instances leaked at exit. The startup message occurs before the self-check's error logger is installed; the required gate passed, but this is not a warning-free run. Export also warned about an existing CX-09 nested project being ignored. No product changes were made to suppress diagnostics.
4. Windows associated icon extracted through System.Drawing.Icon.ExtractAssociatedIcon without executing the EXE. `extracted-icon.ico` / `extracted-icon.png` are in the package root. Its 32x32 RGBA pixels exactly match the source icon.ico at that size (automated equality); visual inspection shows the white check on the blue tile. Evidence: `icon-verification.txt`.
5. Editor screenshot tour completed at 1280x720 in Korean, exit 0; all 32 PNGs were produced. Inspected g0-title.png: title, Korean Start work, language controls, and office background are visible. This is an editor image, not an exported normal-mode run. Log: `screenshot-tour.txt`. Startup certificate diagnostic and exit RID/texture/ObjectDB leaks remain in that log; no missing-button/marker output was found. Other tour images were not individually reviewed. No human session observations were generated.
6. Wrote the new facilitator checklist in workflow order, consistent with the unchanged participant guide and session template. ZIP creation and integrity verification next.
7. Created `NothingWrong-1c8f0d9.zip` containing exactly `NothingWrong/NothingWrong.exe` (the only file emitted beside/in the export). PCK is embedded by the unchanged preset. Stream-read the ZIP entry back and verified its SHA-256 against the exported file; ZIP CRC is checked during that read. Wrote and independently re-read both manifest entries, then re-hashed both files successfully. Evidence: `package-verification.json`; reproducible packaging helper: `package_and_verify.py` (refuses to overwrite the existing ZIP).
8. Final HEAD remains unchanged. `git diff --exit-code` returned 0. Final status adds only the permitted facilitator checklist and docs/qa/cx10/ to the original untracked items. No product files, participant guide, session template, Project OS state, or Git history changed.

## Task result

Outcome: CX-10 packaging COMPLETE, with environment/startup and known shutdown diagnostics retained. This result is not a human playtest result or an MVP approval.

| Acceptance item | Result | Evidence |
| --- | --- | --- |
| Record commit and initial status | PASS | Scope and baseline above; package git-status-before.txt |
| Release export to the specified folder | PASS; exit 0 | export.txt; NothingWrong/NothingWrong.exe |
| Exported self-check | PASS; exit 0 | self-check.txt, first run |
| Editor self-check | PASS; exit 0 | self-check.txt, second run |
| EXE icon extracted and game icon verified | PASS; exact 32x32 source pixel match and visual inspection | extracted-icon.ico/png; icon-verification.txt |
| Build size recorded | PASS | EXE: 242,567,408 bytes (231.33 MiB); ZIP: 162,986,741 bytes (155.44 MiB) |
| ZIP and EXE SHA-256 manifest | PASS; archive payload and both manifest entries verified | SHA256SUMS.txt; package-verification.json |
| Exported EXE launched only with self-check | PASS | Commands in self-check.txt; icon extraction uses Windows icon API |
| Title image uses editor screenshot tour | PASS; exit 0, 32 images | screenshots-ko-1280x720/g0-title.png; screenshot-tour.txt |
| New one-page facilitator checklist | PASS; 409 words, before/during/after order | docs/playtest/TASK-010-facilitator-checklist.md |
| Protected file scope | PASS for repository status/diff; player save files were not inspected | Final status and diff check |

## Deliverables

Package root: [godot/build/playtest-2026-10-26/](../../../godot/build/playtest-2026-10-26/).

- [Release ZIP](../../../godot/build/playtest-2026-10-26/NothingWrong-1c8f0d9.zip)
- [SHA256SUMS.txt](../../../godot/build/playtest-2026-10-26/SHA256SUMS.txt)
- [Combined self-check evidence](../../../godot/build/playtest-2026-10-26/self-check.txt)
- [Facilitator checklist](../../playtest/TASK-010-facilitator-checklist.md)

```text
55ac5fd84725ef680e937b0d415832ffc324b3002001ca5e9acfe38d98b5ec83  NothingWrong-1c8f0d9.zip
dc577ae7d2ff6ea158336238512bdafa0ab69b4514e33c30faee21547c6f8055  NothingWrong/NothingWrong.exe
```

## Limitations and human handoff

- Neither the full automated test suite nor a normal-mode exported gameplay session was part of this packaging run. Content/screen self-check success and an editor title image do not establish participant usability or complete gameplay correctness.
- Keep this report, self-check output, and diagnostics with the build. The certificate-store error and denied editor-settings write are environment observations; their behavior on a participant's machine was not tested. Shutdown leak output is retained under the existing CX-03 concern.
- Human sessions, all six human observations, and the product owner's decision remain outstanding. TASK-010 and M4 are not marked complete. Facilitators follow the checklist and existing session template on their session account; this agent did not reset or collect any player saves.

