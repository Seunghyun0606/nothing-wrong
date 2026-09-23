# Nothing Wrong — Codex Task 001

> 문서 상태: `REFERENCE`
>
> 이 문서는 최초의 통합 구현 지시를 보존한다. 실행 순서와 상태의 정본은
> `.project-os/state/backlog.yaml`, 실제 작업 계약의 정본은
> `.project-os/tasks/ready/TASK-001.yaml`부터 `TASK-006.yaml`까지다.
> 각 canonical Task contract가 이 문서의 해당 절을 reference로 사용한다.

## Foundation & T01 Vertical Slice

### Objective

Nothing Wrong의 첫 번째 End-to-End playable flow를 구현한다.

완료 상태:

```text
NOTHING WRONG
→ Start Work
→ Login
→ Dashboard
→ T01 Ticket
→ Shoply Test
→ Evidence Capture
→ Bug Report
→ QA Review
→ Dashboard
```

전체 MVP를 구현하지 않는다.

---

# 1. Naming

Product:

```text
Nothing Wrong
```

Repository:

```text
nothing-wrong
```

Package:

```text
nothing-wrong
```

Storage:

```text
nothingwrong.*
```

`Nothing Wrong`은 브랜드명이다.

다음 Domain Type 이름을 변경하지 않는다.

```text
Ticket
Scenario
BugReport
ExpectedBug
Mutation
Evidence
ReviewResult
```

다음과 같은 naming은 금지한다.

```text
NothingWrongTicket
NothingWrongBugReport
NothingWrongScenario
```

---

# 2. Required Reading

작업 시작 전에 반드시 확인:

```text
docs/product/GAME_DESIGN.md
docs/product/PLAYER_STORYBOARD.md

docs/architecture/ARCHITECTURE.md
docs/architecture/DOMAIN_MODEL.md
docs/architecture/SCENARIO_SCHEMA.md
```

파일이 없다면 Implementation Blueprint를 기준으로 먼저 문서를 분리 생성한다.

---

# 3. Phase 1 — Project Foundation

구성:

```text
React
TypeScript
Vite
React Router
Zod
Vitest
React Testing Library
Playwright
```

불필요한 dependency는 추가하지 않는다.

---

# 4. Directory Structure

```text
src/
  app/
  game/
  products/
  scenarios/
  pages/
  components/
  persistence/
```

Domain / Game Logic을 React component 내부에 묻지 않는다.

---

# 5. Core Domain

먼저 정의:

```text
Ticket
Scenario
Requirement
Mutation
ExpectedBug
Evidence
BugReport
ReviewResult
GameState
PlayerProfile
```

Runtime validation용 Zod schema도 함께 구현한다.

---

# 6. Persistence

localStorage.

필수 API:

```text
createInitialGameState()
loadGameState()
saveGameState()
resetGameState()
```

Prefix:

```text
nothingwrong.*
```

Save version 포함.

---

# 7. Company Shell

구현:

```text
/start
/login
/dashboard
/tickets/:ticketId
```

Start 화면:

```text
NOTHING WRONG

[ START WORK ]
```

Dashboard:

```text
Player
Career
XP
Reputation
Ticket List
Ticket Status
```

---

# 8. Shoply Baseline

이번 Task에서 필요한 Shoply:

```text
Product
Cart
Checkout
```

먼저 **정상 Product**를 완성한다.

아직 Bug를 hard-code하지 않는다.

Checkout에는 정상 Primary CTA가 있어야 한다.

---

# 9. Fake Browser

React 기반으로 구현.

필수:

```text
Browser Bar
Fake URL
Viewport Container
Shoply Router
```

실제 iframe 사용 금지.

외부 웹사이트 접근 금지.

---

# 10. T01 Scenario

첫 Scenario:

```text
T01 — Visual Verification
```

Project:

```text
Shoply
```

Ticket 목적:

```text
Checkout CTA styling verification
```

Expected:

```text
Primary CTA
```

Mutation:

```text
WRONG_STYLE
```

Target:

```text
checkout.confirmButton
```

Actual:

```text
Secondary CTA
```

Scenario를 비활성화하면 Shoply는 정상적으로 표시되어야 한다.

---

# 11. Mutation Engine

첫 Mutation은:

```text
WRONG_STYLE
```

Product component 안에서 다음 방식은 금지한다.

```ts
if (ticketId === "T01")
```

반드시:

```text
Scenario
→ Mutation Resolver
→ Render
```

구조로 구현한다.

---

# 12. Test Workspace

구성:

```text
QA Toolbar
Fake Browser
Ticket Panel
Notes
Evidence Tray
Capture
Create Report
```

Game UI와 Shoply UI를 명확하게 시각적으로 구분한다.

Shoply가 화면의 중심이어야 한다.

---

# 13. Evidence

`Capture Evidence` 제공.

저장:

```text
ticketId
currentPath
viewport
account
timestamp
snapshot
```

이번 단계에서는 실제 PNG 생성은 필수가 아니다.

Evidence Preview는 제공한다.

---

# 14. Report

필수:

```text
Title
Expected
Actual
Severity
Evidence
```

T01에서는 Reproduction Step 자동 구성을 허용한다.

---

# 15. Review

ExpectedBug와 Report를 비교한다.

표시:

```text
VALID / INVALID

Detection
Evidence
Severity

Total Score

XP
Reputation

Feedback
```

Review logic은 pure function으로 작성한다.

React 의존 금지.

---

# 16. Progress Update

Valid Report 이후:

```text
T01 = RESOLVED
XP increases
Reputation updates
```

Dashboard로 복귀.

Browser refresh 후에도 상태가 유지되어야 한다.

---

# 17. Automated Tests

Unit:

```text
Scenario validation
Mutation active
Mutation inactive
Review score
XP update
Persistence serialization
```

E2E:

```text
Fresh save
→ Start Work
→ Login
→ Dashboard
→ Open T01
→ Start Test
→ Reach Checkout
→ Capture Evidence
→ Submit Report
→ Receive Review
→ Dashboard
```

---

# 18. Architecture Assertions

다음 조건 필수.

### A

Shoply 내부에:

```text
ticketId === T01
```

같은 코드가 없어야 한다.

### B

Mutation을 제거하면 정상 Checkout으로 돌아가야 한다.

### C

Scenario JSON의 mutation payload를 변경하면 React component 수정 없이 출력이 달라져야 한다.

### D

Review logic은 React 없이 Unit Test가 가능해야 한다.

### E

Core Domain에는 `NothingWrong` prefix를 사용하지 않는다.

---

# 19. Do Not Implement

이번 Task에서 구현 금지:

```text
T02+
Mystery Story
Narrative Clues
Investigation Board
Daily Issue
QA Engineer Promotion
Backend
Tauri
Steam
Audio
Leaderboard
Procedural Generation
```

Narrative extension field만 보존한다.

---

# 20. Documentation

이번 Task에서 최소 다음 문서 생성 또는 업데이트:

```text
README.md

docs/product/GAME_DESIGN.md

docs/architecture/
  ARCHITECTURE.md
  DOMAIN_MODEL.md
  SCENARIO_SCHEMA.md

docs/development/
  DEVELOPMENT.md
  TESTING.md

docs/narrative/
  README.md
```

Narrative README에는 현재 Story가 intentionally deferred 상태임을 명시한다.

---

# 21. Required Completion Report

작업 종료 시 반드시 다음 형식으로 보고한다.

## Implementation Summary

구현 내용.

## Architecture

주요 Module과 책임.

## File Tree

핵심 파일만 표시.

## Tests

실행한 명령과 PASS/FAIL.

## Manual Verification

T01 실제 Flow 검증 결과.

## Deviations

Blueprint와 다른 구현과 이유.

## Known Issues

남아 있는 문제.

## Next Recommended Task

Task 002 제안.

---

# 22. Definition of Done

* [ ] Product name is `Nothing Wrong`
* [ ] Start screen displays `NOTHING WRONG`
* [ ] Fresh user can start
* [ ] Login flow works
* [ ] Dashboard works
* [ ] T01 can be opened
* [ ] Normal Shoply exists
* [ ] Fake Browser works
* [ ] T01 mutation is Scenario-driven
* [ ] Evidence can be captured
* [ ] Bug Report can be submitted
* [ ] Review can evaluate the report
* [ ] XP updates
* [ ] Reputation updates
* [ ] Ticket becomes resolved
* [ ] Dashboard reflects updated state
* [ ] Refresh preserves progress
* [ ] Unit tests pass
* [ ] Playwright critical flow passes
* [ ] No Ticket-specific hack exists inside Shoply
* [ ] No `NothingWrong*` domain type names exist

모든 조건이 충족된 후에만 Task 001을 DONE으로 처리한다.
