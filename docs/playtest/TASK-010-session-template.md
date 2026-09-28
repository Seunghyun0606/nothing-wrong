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
- Browser and device:
- App URL or local setup:
- Fresh browser save confirmed: yes / no / unknown
- Recording or screenshots consented to: yes / no / not requested

Run locally with `npm install` (if needed) and `npm run dev`; use the URL printed by
Vite and start at `/start`. A local URL is usable only from the host machine unless
separate network access has been arranged. Clear this app's browser storage before
each participant's run. Give the participant only the
[participant guide](TASK-010-participant-guide.md), not the spoiler-containing
`docs/development/TESTING.md` checklist.

## Journey and observations

For each Ticket, note whether the participant reached Evidence, Report, Review, and
the next Dashboard state without coaching. Capture the exact point of hesitation,
hint given, unexpected behavior, and reproducible defect, if any.

| Step | Completed without hint? | Observation / hint / defect |
| --- | --- | --- |
| Start, login, Dashboard, T01 |  |  |
| T01 Evidence → Report → Review |  |  |
| T02 Evidence → Report → Review |  |  |
| T03 Evidence → Report → Review |  |  |
| Account Switcher and T04 Evidence → Report → Review |  |  |
| Final Dashboard and reload |  |  |

For a defect, include Ticket, starting state, actions, expected result, actual result,
and whether it reproduced on a second attempt. Do not label a participant's
uncertainty as a software defect without checking it.

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

## Human decision after reviewing all sessions

This section must be completed by the human product decision-maker, not by Codex or
the playtest participant on their behalf.

- Decision-maker:
- Decision date:
- Begin broad T05–T08 content production? yes / no / defer
- Reason tied to observations:
- Follow-up defects or UX work required before scaling:

Do not mark TASK-010 or M2 complete while any required observation or the explicit
human decision is missing. Record the completed evidence through the Project OS
handoff and evaluation process once the Human Gate is actually satisfied.
