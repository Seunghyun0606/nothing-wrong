# System Design

## Runtime Boundaries

```text
React App
├─ Company Game Shell
├─ Ticket Engine
├─ Test Workspace
│  ├─ Fake Browser
│  ├─ Shoply Runtime
│  └─ QA Toolbar
├─ Scenario / Mutation Engine
├─ Evidence / Report / Review Engine
└─ Progression / Persistence
```

- `app/`은 router와 providers를 조립한다.
- `game/`은 React에 의존하지 않는 domain과 engine을 소유한다.
- `products/shoply/`는 정상 Product state, rules, components, pages를 소유한다.
- `scenarios/shoply/`는 Ticket별 content data를 소유한다.
- `components/`는 game shell, Fake Browser, QA tools, common UI를 소유한다.
- `persistence/`는 versioned localStorage adapter를 소유한다.

## Scenario-Driven Rendering

```text
Base State → Normal Business Rules → Mutation Resolver → Rendered State
```

Mutation이 없으면 resolver는 base value를 그대로 반환한다. Shoply는 Ticket ID를 알지 못하며, Ticket별 결함은 Scenario의 Mutation data와 TestContext를 통해서만 활성화한다.

Scenario JSON은 Runtime 진입 전에 Zod로 검증한다. 개발 환경에서는 잘못된 data를 명확히 표시하고 silent fallback하지 않는다.

## Router Isolation

Main Game Router와 Fake Browser 내부 Product Router는 논리적으로 분리한다. Fake Browser는 React로 구현하며 실제 iframe, 외부 Browser, 외부 Website 접근을 사용하지 않는다.

## Normal Shoply Rules

- Subtotal: product price × quantity의 합
- SAVE10: 10% discount
- SAVE20: Gold user only, 20% discount
- Shipping: subtotal $50 이상 무료, 미만 $5

Scenario나 Mutation을 제거한 Shoply는 항상 정상 규칙을 따른다.

## Review and State

- Review matching과 scoring은 pure function이다.
- Ticket state transition과 progression update는 engine에서 수행한다.
- URL은 state를 유도할 수 있지만 canonical Game State를 대신하지 않는다.
- localStorage save는 version을 포함하고 create/load/save/reset API 뒤에 격리한다.

## Narrative Extension

Scenario는 optional narrative metadata를 보존할 수 있지만 현재 Runtime은 해석하지 않는다. Core Gameplay는 향후 Mystery Story 없이도 실행되고 테스트되어야 한다.

## Architecture Acceptance

- React Component 변경 없이 새 Ticket을 추가할 수 있다.
- Shoply 수정 없이 Scenario Mutation을 바꿀 수 있다.
- Shoply는 zero Mutation으로 정상 동작한다.
- Mutation Engine은 다른 Fake Product가 재사용할 수 있다.
- Report evaluation은 React 없이 테스트할 수 있다.
- T04 조건을 자동 재현할 수 있다.
- Core Gameplay 재작성 없이 Narrative layer를 추가할 수 있다.

## Source Reference

- [Initial plan](../product/00-initial-plan.md), sections 11–12, 27–31, 44, 47–49, 57
