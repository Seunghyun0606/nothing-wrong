# QA Core Loop

> **현재 상태 (DEC-009, DEC-010, DEC-015):** 업무는 Messenger로 도착하고, Browser의 📌 기록으로
> 결함을 QA 노트에 남긴 뒤 Messenger에서 보낸 사람에게 보고한다. 점수 화면, XP, Reputation은 없고
> 답장이 피드백이다. 보고 뒤에는 기록을 찾아 추리에 답해야 다음 Ticket이 온다. 아래 본문은 초기 설계 기록이다.

## Functional Loop

```text
Dashboard → Ticket → Requirement → Test → Detect → Reproduce
→ Evidence → Report/No Issue → Review → Progression → Next Ticket
```

## Ticket Lifecycle

```text
NEW → ACCEPTED → TESTING → REPORTED/NO_ISSUE → REVIEWED → RESOLVED
```

URL 이동만으로 상태를 전이하지 않는다. 저장된 Game State가 유효한 전이의 정본이며, 잘못된 URL 진입은 상태를 손상시키지 않아야 한다.

## Player Actions

- Ticket에서 request, scope, requirements, starting context를 확인한다.
- Fake Product를 자유롭게 탐색한다. 클릭이나 잘못된 가설 자체에는 벌점이 없다.
- Notes를 Ticket별로 로컬 저장한다. Notes는 Review 점수에 사용하지 않는다.
- Evidence를 Capture하면 ticket, current path, viewport, account, timestamp, snapshot을 저장한다.
- Interaction History는 Report의 reproduction step 후보를 제공한다.
- 플레이어는 Bug Report 또는 `NO ISSUE FOUND`를 제출한다.

## Report Contract

Bug Report에는 title, ordered reproduction steps, expected, actual, severity, evidence가 필요하다.

- Expected는 Ticket requirement 중 위반된 항목을 선택한다.
- Actual은 플레이어가 Capture한 Evidence의 observation(화면 요소 label과 값) 중 하나를 선택한다. 선택지는 플레이어가 실제로 관찰한 값에서만 만들어지며 ExpectedBug 문장을 노출하지 않는다.
- Severity는 화면에 표시되는 severity guide를 기준으로 직접 선택한다(기본값 없음).
- 플레이어는 Bug Report 대신 `NO ISSUE FOUND`를 제출할 수 있다. Evidence 첨부가 필요하다.

## Review Contract

Review는 Report와 숨겨진 ExpectedBug를 조건, Evidence, severity 기준으로 구조적으로 비교한다. 평가는 React와 독립적인 pure function이어야 한다.

점수 배분:

| Category | Points |
| --- | ---: |
| Detection | 40 |
| Reproduction | 25 |
| Evidence | 20 |
| Severity | 15 |

평가 결과는 valid 여부, matched bug, 영역별 점수, total, XP, reputation delta, feedback을 포함한다.

- Detection: 선택한 requirement가 ExpectedBug.requirementId와 같고, 선택한 observation이 validEvidenceTargets에 속하며 재현 조건을 만족한 Evidence에서 나왔을 때.
- Reproduction: 선택한 step에 ExpectedBug.reproductionActions가 모두 포함되고, 첨부 Evidence 중 하나가 재현 조건을 만족할 때. 필요 이상으로 많은 step은 -5점(유효성에는 영향 없음).
- Evidence: 첨부 Evidence 중 결함 target을 실패 상태에서 보여주는 것이 있을 때. 무관한 Evidence가 더 많으면 -5점.
- Feedback은 정답 문장을 알려주지 않고 무엇을 다시 확인할지 안내한다.

Reputation 기본 규칙:

- Valid Bug: +1~+5
- False Positive: -2
- Correct No Issue: +2
- Missed Bug: -2

## QA Tools

- Viewport Switcher는 Desktop, Tablet, Mobile의 실제 Fake Product 너비를 바꾼다.
- Account Switcher는 Basic, Gold 계정을 바꾸며, 데이터 reset 여부는 Scenario policy가 결정한다.
- Screenshot-style Evidence는 snapshot과 metadata를 보존하고 preview를 제공한다.
- Notes는 자동 저장하되 평가하지 않는다.

## Source Reference

- [Initial plan](../product/00-initial-plan.md), sections 2, 21–26, 32–41
