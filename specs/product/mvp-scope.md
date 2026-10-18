# MVP Scope

## Product Stage

MVP는 Web Desktop에서 동작하는 단일 플레이어 QA Investigation Simulation이다. 첫 검증 단위는 T01 End-to-End Vertical Slice이며, 전체 MVP 범위는 Shoply와 T01~T08이다.

## Included Experience

- Company flow: Start, Login, Dashboard, Ticket Detail, Reports, Review, Career, Settings
- Test flow: Ticket 요구사항 확인, Fake Browser 탐색, Notes, Evidence Capture, Report 또는 `NO ISSUE FOUND`, Review
- Fake Product: Shoply 한 개
- Shoply surfaces: Login, Home, Search, Product, Cart, Checkout, Orders, Profile
- QA tools: Screenshot-style Evidence, Viewport Switcher, Account Switcher, Notes
- Progression: Junior QA에서 QA Engineer까지, XP와 Reputation
- Content: Visual, Data, Behavior, Conditional, No Bug, Cross Screen, Multiple Bugs, Mini Regression Ticket
- Persistence: versioned localStorage save

## Delivery Boundaries

- Web Desktop이 기준 플랫폼이다.
- Evidence는 MVP에서 실제 PNG 파일이 아니라 화면 snapshot, context metadata, preview로 구현할 수 있다.
- Report 평가는 LLM/NLP가 아닌 구조적 matching으로 수행한다.
- Account Switcher는 T04에서 해금한다.
- Reputation은 피드백 수치이며 Game Over 조건이 아니다.
- Narrative hook 필드는 확장 지점으로 보존한다. Ticket별 Story Chapter(briefing, debrief, clue, deduction, epilogue)는 DEC-005에 따라 Scenario data로 Runtime에서 사용한다.

## Deferred Capabilities

PROJECT.md의 Non-Goals를 따른다. Locale Switcher, Clock Control, Network Mode, Session Inspector, Build Comparison, Regression Matrix도 MVP 이후로 미룬다.

## Product Gates

1. T01 First Playable: 전체 QA Pipeline과 확장 가능한 Architecture를 검증한다.
2. T01~T04 Prototype: 핵심 결함 유형과 조건부 테스트를 구현한 뒤 Human Playtest를 실시한다.
3. T01~T08 MVP: No Bug, Cross Screen, Multiple Bugs, Regression까지 Content 폭을 완성한다.

## Source Reference

- [Initial plan](./00-initial-plan.md), sections 4–10, 42–44, 58–60
