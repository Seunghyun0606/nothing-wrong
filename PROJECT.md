# Nothing Wrong

## Vision

`Nothing Wrong`은 실제 QA 업무의 관찰, 가설 수립, 재현, 증명, 보고를 게임의 핵심 재미로 만드는 QA 조사 시뮬레이션이다. 플레이어는 가상의 서비스에서 단순히 숨은 버그를 찾는 것이 아니라, 요구사항과 정상 동작을 이해하고 책임 있는 판단을 내리는 QA 직원으로 성장한다.

## Target User

논리적 추론과 탐색을 즐기며 소프트웨어 테스트나 QA 업무에 호기심이 있는 데스크톱 게임 플레이어가 주 사용자다. QA 경험이 없어도 단계적인 Ticket과 도구 해금으로 핵심 사고방식을 배울 수 있어야 한다.

## Core Experience

플레이어는 업무 Ticket을 읽고 실제 서비스처럼 동작하는 Fake Product를 자유롭게 테스트한다. 이상 현상을 발견하면 조건을 재현하고 Evidence를 확보해 Bug Report 또는 `NO ISSUE FOUND` 판단을 제출하며, 구조적인 Review와 Career Progression을 거쳐 다음 Ticket으로 이동한다.

핵심 사고 흐름은 다음과 같다.

```text
Understand → Explore → Hypothesize → Reproduce → Prove → Report
```

## Product Principles

- Fake Product는 결함이 없는 상태에서도 믿을 수 있는 서비스처럼 정상 동작해야 한다.
- 정상 기능이 결함보다 훨씬 많아야 하며, 모든 Ticket에 Bug가 있다고 가정할 수 없어야 한다.
- 자유로운 탐색에는 벌점을 주지 않되, 최종 Report에는 정확성에 대한 책임이 따른다.
- Bug 발견 자체보다 재현 조건과 Evidence의 품질을 중요하게 평가한다.
- Scenario Content와 Game Engine을 분리하고, 특정 Ticket을 위한 Product 내부 분기를 만들지 않는다.
- Game Logic과 Review는 UI 프레임워크 밖에서도 검증 가능해야 한다.
- Career Progression은 숫자 난이도 증가보다 QA 업무의 성격과 판단 범위를 확장한다.
- Core Gameplay는 최종 Mystery Narrative와 독립적으로 완결되어야 한다.
- 플레이어는 각 Ticket에서 찾아낸 사실을 Story 단서로 이어가며 추리한다. 초반 Ticket은 바로 찾고 다음 단계로 자연스럽게 넘어가는 튜토리얼이어야 하며, 추리 실패에는 벌점을 주지 않는다.
- 실제 QA 용어를 사용하고 `Nothing Wrong`은 브랜드명에만 사용한다.

## Platform

게임 클라이언트는 `godot/`의 Godot 4 빌드 하나만 개발·배포한다(DEC-007, DEC-008). 저장소 루트의 React/Vite 웹 빌드는 동결된 참조본이며 더 이상 수정하지 않는다. 콘텐츠의 정본은 `godot/data`와 `godot/i18n`이다.

## Non-Goals

현재 MVP에서는 다음을 만들지 않는다.

- 최종 Mystery Narrative, Investigation Board, Scenario data 밖의 임의 Story Content
  (Ticket별 briefing·debrief·clue·deduction으로 이루어진 Story Chapter는 DEC-005에 따라 범위에 포함한다)
- Backend, Online Account, Multiplayer, Global Leaderboard
- LLM Runtime, Procedural Ticket Generation, 실제 웹사이트 Crawling
- 실제 Browser iframe 또는 외부 사이트 연동
- Tauri, Steam 통합, Windows/macOS 네이티브 패키징
- Payment, Achievement, Money/Equipment Economy
- 여러 Fake Product 또는 Shoply 외 추가 Product

## Success Definition

현재 단계의 성공은 T01 End-to-End Vertical Slice가 새 사용자 기준으로 시작부터 Review와 Dashboard 복귀까지 끊김 없이 동작하고, 새 Ticket과 Mutation을 Product Component 변경 없이 추가할 수 있는 구조가 자동 테스트로 증명되는 것이다.

그다음 T01~T04 Prototype에서 플레이어가 정상 동작과 결함을 구분하고 재현·Evidence·Report 과정을 재미있는 QA Gameplay로 받아들이는지 Human Playtest로 확인한다. 이 검증 전에는 후속 Ticket Content를 대량 생산하지 않는다.
