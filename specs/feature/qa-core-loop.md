# QA Core Loop

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

Bug Report에는 title, ordered reproduction steps, expected, actual, severity, evidence가 필요하다. 초기 Ticket은 candidate 선택으로 typing 부담을 줄이고, 후반 Ticket은 partial free text를 허용한다.

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
