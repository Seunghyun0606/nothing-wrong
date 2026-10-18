# First Playable UX

## Player Journey (DEC-006)

```text
NOTHING WRONG
→ Start work
→ Workstation lock screen · Sign in
→ Desktop · Messenger notification
→ Messenger briefing (links to shoply.local and the intranet spec)
→ QA Tracker · T01 · Start test
→ Browser · shoply.local Product/Cart/Checkout
→ Detect visual defect · Capture (saved to QA Notes)
→ QA Tracker · Create report
→ QA Review
→ Messenger debrief · reply to the deduction
→ Next briefing arrives
```

## Information Hierarchy

The desktop is the game UI; Shoply only exists inside the Browser window and keeps its
own visual identity. Four apps carry the work:

```text
Messenger   story chat, links, ticket cards, deductions as replies
QA Tracker  Ticket queue, Start test, Report, Review, Case File, profile
Browser     address bar, QA bar (viewport · account · Capture), Shoply, intranet docs
QA Notes    Ticket sheet with links, personal notes, Evidence, activity log
```

A sticky-note guide on the desktop points at the next action. Early briefings carry
clickable links; later ones give an address to type. QA Notes always lists it.

## First Ticket Guidance

- T01은 Core Loop tutorial이지만 정답을 직접 알려주지 않는다.
- Ticket과 requirements가 탐색 범위를 제시한다.
- Evidence capture와 Report builder는 단계적으로 다음 행동을 알려준다.
- Expected/Actual은 candidate 선택을 허용하고 reproduction steps는 Interaction History에서 제안한다.
- Review는 VALID/INVALID, Detection, Evidence, Severity, Total, XP, Reputation, Feedback을 명확히 보여준다.

## Viewport Behavior

Desktop, Tablet, Mobile 선택은 Fake Browser의 실제 content width와 layout을 변경해야 한다. label만 바뀌는 구현은 허용하지 않는다.

## Prototype Playtest Questions

- 이슈를 찾는 과정이 재미있는가?
- Shoply가 믿을 수 있는 서비스처럼 느껴지는가?
- 정상 동작과 결함을 구분할 수 있는가?
- 재현과 Evidence 확보가 만족스러운가?
- Report가 서류 작업이 아니라 Gameplay로 느껴지는가?
- 다음 Ticket을 열고 싶은가?

## Source Reference

- [Foundation and T01 brief](../feature/foundation-task.md), sections 7, 12–16
- [Initial plan](../product/00-initial-plan.md), sections 32–38, 58–59
