# Domain Model

## Naming

`Nothing Wrong`은 제품과 브랜드에만 사용한다. Domain type은 `Ticket`, `Scenario`, `BugReport`, `ExpectedBug`, `Mutation`, `Evidence`, `ReviewResult`, `GameState`처럼 QA와 Game 개념 자체의 이름을 사용한다.

## Content Aggregate

`Scenario`가 기본 Content Unit이다.

```text
Scenario
├─ Ticket
│  ├─ sender, priority, request, scope
│  ├─ requirements, attachments, hints
│  └─ starting TestContext
├─ ScenarioSeed
├─ ExpectedBug[]
├─ Mutation[]
├─ ScoringConfig
├─ ProgressionReward?
└─ NarrativeHook?
```

## Runtime Context

`TestContext`는 account, viewport, locale, currentPath를 포함한다. `MutationCondition`은 context 또는 product state의 field를 `EQ`, `NEQ`, `GT`, `GTE`, `LT`, `LTE`, `IN`으로 비교한다.

Mutation은 id, type, target, optional conditions, payload를 가진다. MVP Mutation type은 text/visibility/number/style/action/state/calculation/cross-screen mismatch를 지원할 수 있어야 한다.

## Evidence and Reporting

- `Evidence`: id, ticketId, screenshot type, capturedAt, TestContext, snapshot, preview/path reference
- `BugReport`: id, ticketId, title, ordered reproductionSteps, expected, actual, severity, evidenceIds, submittedAt
- `ExpectedBug`: id, type, title, target, severity, reproductionConditions, expected, actual, validEvidenceTargets
- `ReviewResult`: valid, matchedBugId, category scores, totalScore, xp, reputationDelta, feedback

## Player State

`GameState`는 PlayerProfile, Ticket별 state, current ticket, unlocked tools, report history, review history를 보존한다.

초기 Profile은 `J. PARK`, level 1, `JUNIOR_QA`, XP 0, Reputation 100이다. Career는 MVP에서 `JUNIOR_QA`와 `QA_ENGINEER`를 사용한다.

## Persistence Envelope

```text
SaveFile
├─ version: 1
└─ state: GameState
```

Storage prefix는 `nothingwrong.*`이며 profile, gameState, settings key를 사용할 수 있다.

## Validation

Domain contract와 Scenario data에는 같은 의미의 TypeScript type과 Zod runtime schema를 둔다. validation 실패는 개발 환경에서 원인과 위치를 드러내며 유효하지 않은 Scenario를 정상값으로 조용히 대체하지 않는다.

## Source Reference

- [Initial plan](../product/00-initial-plan.md), sections 13–25, 37, 44, 47, 49
