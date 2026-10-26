# CX-08 Part A: playtest kit dry run

Result: completed, with documentation discrepancies and clarifications below. This is an automated kit dry run, **not TASK-010, a human playtest, or human observations**. Neither TASK-010 nor M4 is marked complete. No product, kit, or Project OS files were edited.

Tested on 2026-10-26, Windows, Godot 4.7.2, 1440 x 900, English and Korean. Baseline: `e94fde81cae7a7c6fbb68180a2feaac3f03f5141` plus Claude's uncommitted changes, recorded in [baseline.json](baseline.json). Role: verification; assigned brief: CX-08. No Project OS task transition was performed.

## Execution and evidence

- Real workstation UI driven through button signals, address entry, note highlights and deduction forms, using `ui_test_base.gd` / `test_ui_flow.gd` helpers and conventions. [Probe](../../../godot/build/qa-cx08/kit_probe.gd), [runner](../../../godot/build/qa-cx08/kit_runner.gd), [log](../../../godot/build/qa-cx08/kit-run.log), [button labels, gates and assertions](../../../godot/build/qa-cx08/kit-evidence.json).
- 78 screenshots: 39 per language. [Screenshot index](screenshots.md). All were reviewed as contact sheets; the notification, clock-out and night captures were subsequently refreshed after their entrance animations and inspected at full size. Button inventories provide exact text where a screenshot contains scrolling content.
- Fresh title -> lock -> notification -> T01 accept -> hint DM -> product/bag/checkout -> returned report -> accepted report -> record search -> wrong and correct deduction were exercised in each language. Pacing was accelerated after the first notification. The after-T02 day transition and T05 were separately prepared from domain state, following existing test patterns; the later photo/directory views were inspected on an unlocked fixture. These are fixtures, not claims of uninterrupted human play.
- Existing full test suite: **72 passed, 0 failed**, exit 0, including the workstation full-story journey, account/device checks, Case File finales and ending. [tests.log](../../../godot/build/qa-cx08/tests.log).
- Release export into `godot/build/qa-cx08/NothingWrong.exe`: exit 0. Exported and editor `--self-check`: **Self-check passed**, exit 0, each counting 10 chapters, 8 people, 12 record photos, 25 records, 42 tickets and 30 views. [export log](../../../godot/build/qa-cx08/export.log), [export self-check](../../../godot/build/qa-cx08/self-check-export.log), [editor self-check](../../../godot/build/qa-cx08/self-check-editor.log).
- Runtime save paths were asserted to start with `user://tests/`; persistence was disabled before state changes. `SaveFile.path()` routes scripted SceneTrees and `--self-check` to that directory before autoloads read anything. No player's save, workspace, settings or unreadable backups were read, changed, moved or removed. The probe itself wrote no user saves.
- Environmental startup message: `Failed to read the root certificate store`. The tests also intentionally log two damaged-JSON parse errors, as documented. Exit-time RID/texture/ObjectDB diagnostics occurred; these do not invalidate the assertion results and are distinct from in-play memory measurement in Part B. Early probe-development failures were corrected in scratch and rerun; final kit run has zero failed assertions.

## Claim-by-claim comparison

Locations: **Guide** = `docs/playtest/TASK-010-participant-guide.md`; **Template** = `docs/playtest/TASK-010-session-template.md`. Screenshot keys below exist for both `kit-en/` and `kit-ko/`; see the index. Code references are relative to `godot/`.

| Claim | Where in kit | What the build actually does / evidence | Match | Suggested wording |
| --- | --- | --- | --- | --- |
| Fresh title offers Start work; lock offers Sign in | Guide / Start | `01`, `02`; `title_screen.gd`, `lock_screen.gd`. Labels include the title arrow and translate in Korean; the access code is already filled. | Yes, English labels are abbreviated | Give both labels (table below); no code needs to be supplied. |
| Work arrives in Messenger through a notification | Guide / introduction, Playing; Template / first journey row | `03`-`05`: clock advances, a bottom-right notification offers Open; opening it starts Messenger delivery. `desktop_session.gd`, `desktop_screen.gd`. | Yes | Say: click Open / its Korean equivalent on the bottom-right notification, or open Messenger. |
| Desktop has Messenger, Browser, QA Notes | Guide / Start | Desktop icons and taskbar have precisely those three apps; `03`, `05`, `09`; `DesktopSession.APP_TITLES`. In Korean the names translate. | Functionally yes; missing Korean app names | Add the app-name pairs below. |
| Browser contains shop, intranet, directory | Guide / Start | T01 product `09`, record `16`, directory `later-directory`, person `later-person`; Browser new-tab link and `people.northstar.local`. | Yes | Retain; optionally identify the directory link on a new Browser tab. |
| QA Notes contains Tickets, notes and Case File | Guide / Start | `06`, `11`, `26`, `later-case-file-all-chapters`; `notes_app.gd`. Narrow layout uses a picker instead of a fixed sidebar. | Yes | Mention the top picker in narrow QA Notes. |
| Taskbar Arrange / Korean label puts apps side by side | Guide / Start | `10`: Browser left 75%, QA Notes right 25%, full height, Messenger steps aside; `arrange_for_testing`, existing arrangement test. | Yes | Retain; optionally say Browser left, QA Notes right. |
| Accept Ticket in QA Notes | Guide / Playing; Template / T01 row | `06`-`07`: the actionable button is Start test, which puts the Ticket in TESTING. No button labelled Accept. | Wording mismatch | Choose Start test / its Korean equivalent in QA Notes. |
| Press Note then click the mismatching part | Guide / Playing | `11`, `13`, `14`: browser Note mode creates target highlights; clicking one adds a note with screen context and console to QA Notes. `browser_app.gd`, `WorkspaceSession.add_evidence`. | Yes | Retain; say click a highlighted part. |
| Report the note to the sender in Messenger | Guide / Playing; Template / T01 row | `14`-`15`: choose a note AND the requirement it breaks, then Send report. Report composer is inside Messenger, with an entry link from QA Notes. | Correct but omits required choice | Select the note and broken requirement, then Send report. |
| Returned report costs 20 workday minutes; can retry | Guide / introduction; Template / watch-for table | `12`; every penalty-marked reply had `time - previous.time == 20`; Ticket remained TESTING and subsequent correct report resolved it. `messenger_log.gd:PENALTY`, `_stamp`. | Yes | Retain; 20 minutes is the penalty reply increment, in addition to ordinary message time. |
| Wrong answer costs 20 workday minutes; can retry | Same | `17`-`18`: wrong deduction reply has the same exact 20-minute increment; correct retry unlocks T02. | Yes | Retain; do not promise the total taskbar jump for all resulting messages is exactly 20. |
| Clicking around costs nothing | Guide / introduction | Free navigation does not create penalty entries; `_stamp` applies penalties only to invalid reports and incorrect deductions. Messages and scheduled work advance story time. | Yes as a penalty statement | Exploration has no penalty; story time also advances with messages and scheduled work. |
| Team asks player to find a record and answer | Guide / Playing; Template / T01 debrief | `15`-`18`: intranet search, record, deduction blanks, team reply. | Yes | Retain. |
| Report NO ISSUE FOUND after checking the relevant screen | Guide / Playing; Template / T05 | `23`-`25`: T05 reported after only the bag was rejected; after visiting the Ticket's product screen it resolved. Code checks recorded screen visits. | Yes, submission controls omitted | Open the Messenger report form, choose Nothing is wrong, confirm Send NO ISSUE FOUND. |
| End of day -> clock out -> next-morning sign in | Guide / Playing; Template / after T02 | `19`-`22`: after T02, T03 waits until Wednesday; Tuesday 18:00 clock-out card, night screen, Wednesday 10:00 lock, T03 notification at 10:20. Existing new-day UI test follows same flow. | Yes | Clock out / Korean label appears on the bottom-right end-of-day card; the next day may include a story time jump. |
| QA Notes has a Stuck? Ask ... for a hint link | Guide / Playing; Template / Journey, hint row | `07`-`08`: `AskHint` requests help from the Ticket sender in a DM; subsequent link becomes Open the conversation. Hint adds normal chat entries, no penalty. `notes_app.gd:248-260`. | Yes | Use the localized hint template below; scroll the Ticket page if needed. |
| T02 quantity, T03 cancel, T04 Gold + SAVE20 / Account Switcher | Template / Journey | Existing full-story UI test drives these cases, including Gold account context and cancellation routing. These are journey prompts rather than participant answers. | Yes | Account Switcher is a capability name; identify the Basic/Gold choices in Browser's QA bar if facilitator needs help. |
| T06/T07 device checks, Chapter 1/2 clue-board finales | Template / Journey | Full-story UI tests exercise device changes and board answers; `26`, `later-tablet`, `later-mobile`, `later-case-file-all-chapters` show the relevant surfaces. | Yes | Say Case File / localized label instead of introducing an unlabelled separate clue-board app. |
| Chapters 3-4 and ONE HORIZON, directory and private messages later | Template / Journey | Full-story UI test covers cross-screen stock, two defects, RC5, later record tickets and ending. Later fixture screenshots show record tables, all-chapter Case File and directory. | Yes | Retain as facilitator observation checklist. Do not require completion within a fixed session. |
| Photos at T14, T24, T32, T38 | Template / Watch for | `later-photo-thumbnails`, `later-cms-albums`, `later-foundation-gallery`, `later-archive-attachments`; corresponding scenario paths and photos in `horizon.json`. | Yes | Retain neutral observation wording. Photo recognition remains a human observation. |
| Final decision and ending | Template / Journey | Full-story test reaches the Case File decision and checks the ending card. | Yes | Retain; mark not reached if session stops earlier. |
| Quit/reopen resumes progress | Template / Journey | Save and whole-story JSON round-trip tests pass in the 72-test suite; save loaders restore game/workspace. Desktop layout/tabs are transient (`desktop_session.gd` header). This run did not simulate a participant quitting an ordinary save. | Qualified | Resumes progress and notes; window layout and Browser tabs need not match. Keep this as a real-session observation, not an assumed pass. |
| Choose New game to obtain fresh progress | Template / Setup 2 | `27`-`29`: only shown when `has_progress()` is true; requires Yes, start a new game. Resets GameSession and WorkspaceSession, leaves settings language/sound as-is. `title_screen.gd:_reset`. | Incomplete | If Continue work is shown, choose New game, then Yes, start a new game. If Start work is already shown, progress is fresh. Select session language and sound separately. |
| README says New game resets save/workspace/settings | Template / Setup 1 reference to README / Run | Runtime assertions retained language and sound after reset; `_reset()` does not reset Settings. | Mismatch in linked README | New game resets progress, evidence and notes; language and sound stay selected. |
| Manual deletion of three JSON files gives fresh save | Template / Setup 2 | Checked against `save_file.gd` ONLY; never tried on player data. `exists()`/`read()` recover a `*.json.tmp` when the primary is absent; deleting only the three primaries can reload stale temporary data. `.unreadable` is a backup, not the read fallback. | Incomplete for interrupted writes | Prefer the in-game confirmed reset. If documenting manual cleanup, specify primaries AND matching `.tmp` companions, with the game closed; leave tests and unreadable backups alone. This is a suggestion, not an action performed. |
| Build and run self-check via README | Template / Setup 1 | Export, exported self-check and editor self-check all exit 0 as documented; content counts above. Tests excluded from export by preset. | Yes | State explicitly to run BOTH self-checks and require the pass line AND exit 0, as README already does. |
| Six questions, coaching notes, consent, human decision | Guide / After playing; Template / six observations and decision | These are real-session procedures, not software claims. Template correctly leaves blanks and reserves decision for a human. | Appropriate; not executed | Retain. No participant responses, enjoyment judgments, or MVP decision were fabricated. |

## Exact localized labels

| English | Korean |
| --- | --- |
| Start work  → | 업무 시작  → |
| Continue work  → | 업무 계속하기  → |
| Sign in | 로그인 |
| Messenger | 메신저 |
| Browser | 브라우저 |
| QA Notes | QA 노트 |
| Arrange | 화면 정렬 |
| Start test | 테스트 시작 |
| 📌 Note | 📌 메모 |
| Nothing is wrong | 이상 없음 |
| Send NO ISSUE FOUND | NO ISSUE FOUND 보내기 |
| Send report | 보고 보내기 |
| Clock out | 퇴근하기 |
| Case File | 사건 파일 |
| New game | 새 게임 |
| Yes, start a new game | 네, 새 게임을 시작합니다 |
| Stuck? Ask %s for a hint | 막혔나요? %s에게 힌트 묻기 |
| Open the conversation | 대화 열기 |

The literal English text `NO ISSUE FOUND` remains in the Korean confirmation label. Shoply and ONE HORIZON record content intentionally remain English within Korean game chrome; both were seen in the captures.

## Potential participant sticking points (judgment, not human observations)

1. **Accept vs Start test:** the guide's verb does not identify the actual button. This is the most direct label correction.
2. **Reporting choices:** a participant may have a note but miss the second requirement selection. The guide can name both choices without giving an answer.
3. **NO ISSUE FOUND controls:** the first control says Nothing is wrong / its localized equivalent, not NO ISSUE FOUND. Name the two-stage path.
4. **Scroll/picker:** in the 25%-width QA Notes window, the file list becomes a picker and the hint can be below the fold. Explain the location without coaching the investigation.
5. **In-world sites stay English:** a Korean participant may mistake untranslated Shoply/record columns for a language-setting failure. A short sentence would set expectations.
6. **Photo recognition:** directory pictures are dated badge photos with explanatory captions/tooltips. Do not turn the template's neutral watch-for item into a promise that photos prove more than acquaintance.
7. **Time accounting:** a 20-minute penalty is followed by ordinary chat timestamps; a participant watching only the clock can see a larger total jump.
8. **Fresh-state facilitation:** a fresh title has no New game button, while a progressed title requires confirmation. Settings persist. The current one-line setup may cause unnecessary troubleshooting.
9. **Resume expectations:** save progress persists, but layout and tabs do not. A reopened desktop can look different even when progress is intact.

## Reproduction commands

Run one Godot process at a time from repository root. Binary is the path in `docs/codex/RULES.md`.

```powershell
& $godot --path godot --resolution 1440x900 --script res://build/qa-cx08/kit_runner.gd
& $godot --headless --path godot -s tests/run_tests.gd
& $godot --headless --path godot --export-release 'Windows Desktop' build/qa-cx08/NothingWrong.exe
& godot/build/qa-cx08/NothingWrong.exe --headless --quit-after 3000 -- --self-check | Out-String
& $godot --headless --path godot --quit-after 3000 -- --self-check
```

Part A report saved before starting Part B. Product/kit corrections are recommendations for Claude; no fixes were applied.
