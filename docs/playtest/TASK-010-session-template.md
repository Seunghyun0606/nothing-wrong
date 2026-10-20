# TASK-010 playtest session record (template — not a completed session)

Copy this template for each real session. Record observations without changing the
participant's wording to fit an expected answer. Do not enter a real name, account,
credential, or recording link without the participant's permission. Leave unknown
fields blank rather than inventing results.

## Session details

- Date and timezone:
- Tester ID (pseudonym):
- Facilitator:
- Tested commit:
- Build: exported `NothingWrong.exe` / editor run
- Screen size and OS:
- Language: 한국어 / English
- Fresh save confirmed: yes / no / unknown
- Recording or screenshots consented to: yes / no / not requested

## Setup

1. Build the game (see `godot/README.md`, **Build**) and run its `--self-check`.
2. Start from a fresh save: choose **New game** on the title screen, or delete
   `save.json`, `workspace.json`, and `settings.json` from
   `%APPDATA%\Godot\app_userdata\Nothing Wrong` (keep the `tests` folder).
3. Give the participant only the [participant guide](TASK-010-participant-guide.md),
   not `docs/development/TESTING.md`, the specs, or the story docs. They contain the answers.

## Journey and observations

For each step, note whether the participant got through without coaching. Write down
where they hesitated, any hint given (QA Notes' hint link or the facilitator), anything
unexpected, and any defect that reproduces. Sessions may stop at any chapter; mark steps
not reached as "not reached".

| Step | Completed without hint? | Observation / hint / defect |
| --- | --- | --- |
| Title, lock screen, desktop, first notification opened |  |  |
| T01: accepted, found the defect, noted it, reported it in Messenger |  |  |
| T01 debrief: found the record, answered the question |  |  |
| T02: quantity |  |  |
| First clock-out, night screen, next-morning sign-in (after T02) |  |  |
| T03–T04: cancel flow, Gold + SAVE20 (Account Switcher) |  |  |
| Chapter 1 finale on the clue board |  |  |
| T05 closed as NO ISSUE FOUND |  |  |
| Device checks (T06, T07) and the Chapter 2 finale |  |  |
| Chapters 3–4: Gold orders, cross-screen stock, two defects, RC5 regression |  |  |
| Chapter 5 onward: ONE HORIZON records, directory, private messages |  |  |
| Asked for a hint in a direct message (if used) |  |  |
| Final decision and ending |  |  |
| Quit and reopen mid-chapter: picked up where they were |  |  |

For a defect, record the Ticket, starting state, actions, expected result, actual result,
and whether it reproduced on a second attempt. Check before you record a participant's
uncertainty as a software defect.

## Six required human observations

1. 이슈를 찾는 과정이 재미있는가?
   - Participant response:
   - Concrete moment or example:
2. Shoply가 믿을 수 있는 서비스처럼 느껴지는가?
   - Participant response:
   - Concrete moment or example:
3. 정상 동작과 결함을 구분할 수 있는가?
   - Participant response:
   - Concrete moment or example:
4. 재현과 Evidence 확보가 만족스러운가?
   - Participant response:
   - Concrete moment or example:
5. Report가 서류 작업이 아니라 Gameplay로 느껴지는가?
   - Participant response:
   - Concrete moment or example:
6. 다음 Ticket을 열고 싶은가?
   - Participant response:
   - Concrete moment or example:

Optional: 추리 질문이 공정했는가? 하루가 넘어가는 흐름이 자연스러웠는가?

## Human decision after reviewing all sessions

The human product decision-maker fills in this section. An agent or the playtest
participant must not fill it in for them.

- Decision-maker:
- Decision date:
- Is this build an MVP candidate? yes / no / defer
- Reason tied to observations:
- Defects or UX work required first:

Do not mark TASK-010 or M4 complete while any required observation or the explicit human
decision is missing. Once the Human Gate is actually satisfied, record the evidence
through the Project OS handoff and evaluation process.
