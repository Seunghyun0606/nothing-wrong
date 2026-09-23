# First Playable UX

## Player Journey

```text
NOTHING WRONG
→ Start Work
→ Company Login
→ Dashboard
→ T01 Ticket
→ Start Test
→ Shoply Product/Cart/Checkout
→ Detect visual defect
→ Capture Evidence
→ Build Bug Report
→ Receive QA Review
→ Return to updated Dashboard
```

## Information Hierarchy

Test Workspace에서 Shoply가 가장 넓은 영역을 차지한다. Game UI와 Shoply UI는 시각적으로 구분하되, 플레이 중인 Fake Product가 중심이어야 한다.

```text
QA Toolbar
Fake Browser / Shoply
Ticket · Notes · Evidence
Capture · Create Report
```

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
