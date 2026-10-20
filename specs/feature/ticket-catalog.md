# MVP Ticket Catalog

각 Ticket은 Scenario data(`godot/data/scenarios.json`)로 정의하며 Product Component에 Ticket ID 조건을 추가하지 않는다. ExpectedBug는 플레이어에게 직접 노출하지 않는다.

출시 대상 Ticket 세트는 10개 장(Chapter 1–9, Final)에 걸친 T01–T42다. 장별 스토리 매핑은 [CANON-MAP](../../docs/story/CANON-MAP.md)에 있다.

## Mechanics

초기 계획의 T05–T08 학습 목표(No Bug, Cross Screen, Multiple Bugs, Mini Regression)는 스토리 Ticket에 흡수되었다(DEC-016).

| Mechanic | Learning Goal | Tickets | Canonical Case |
| --- | --- | --- | --- |
| Visual | Core loop tutorial | T01 | Checkout confirm CTA가 Primary여야 하나 Secondary style로 표시됨 |
| Data | 수치 검증 | T02, T06, T08 | $30 × 2의 subtotal이 $60 대신 $50으로 표시됨 |
| Behavior | action/result 검증 | T03, T07 | Cancel Order가 return/cancel flow 대신 payment flow를 엶 |
| Conditional | 조건 조합과 계정 전환 | T04, T08, T09 | Gold + SAVE20 + quantity ≥ 3에서 20% 대신 10% 할인 |
| Device | 기기별 일관성 | T06, T07, T11, T12 | Mobile cart만 배송비가 붙음, Tablet에서 Cancel order가 사라짐 |
| No Bug | 제보를 맹신하지 않는 판단 | T05, T20, T21, T30, T31, T41, T42 | RC4: $45 주문 배송비 불만은 규칙대로이며 정답은 `NO ISSUE FOUND` |
| Cross Screen | 화면 간 일관성 | T10 | Product page stock과 Cart stock이 다름 (rollback snapshot) |
| Multiple Bugs | 복수 결함 보고 | T11 | Whole-dollar price format과 Mobile cart의 Remove 누락, 둘 다 보고해야 해결 |
| Mini Regression | 범위와 Coverage 선택 | T12 | RC5에서 지난주 수정 전체를 재확인, Mobile에서만 cancel 결함이 돌아옴 |
| Records | 시스템 간 데이터 대조 | T13–T19, T22–T29, T32–T40 | ONE HORIZON 마이그레이션 레코드의 매핑·동기화 결함 |
| Decision | 증거 범위와 판단 | T42 · Final | 검사 예산 안에서 출시 보류·보고 경로를 고르고 결말이 갈림 |

## Unlock Order

```text
T01 → T02 → T03 → Account Switcher → T04 → … → T42 → Final
```

Ticket은 스토리 순서대로 Messenger에 도착한다(DEC-015). 진행은 새 Ticket과 도구로 표현하며 Level, XP, Reputation, Career 승급은 없다(DEC-010).

## Scenario Verification Rules

- 모든 Scenario에는 canonical reproduction test가 필요하다: `test_full_story`가 실제 버튼으로 T01–T42와 Final을 플레이한다.
- 모든 Mutation은 조건이 모두 맞을 때만 active이고 하나라도 어긋나면 inactive여야 한다: `test_every_mutation_is_active_only_under_its_conditions`가 전 Mutation을 조건별로 검사한다.
- Conditional Scenario는 positive와 negative 조건을 모두 테스트한다.
- T04 positive: Gold, SAVE20, quantity 3에서 Mutation active.
- T04 negative: Basic이거나 quantity 1이면 정상 20%/eligibility rule을 따른다.
- Shoply 코드에는 Ticket, Scenario, Bug, Mutation ID가 나오지 않는다: `test_shoply_never_branches_on_a_ticket`.

## Source Reference

- [Initial plan](../product/00-initial-plan.md), sections 42–43, 46, 59

## Story Chapter 1 · Release Candidate 3 (DEC-005)

| Ticket | Guide level | Clue | Deduction |
| --- | --- | --- | --- |
| T01 | Full tutorial | 02:14 · release-bot | 체크아웃은 실제로 바뀌었다 (자동 merge) |
| T02 | Guided | 은퇴한 "TWO FOR $50" 프로모션 코드 | 두 결함은 같은 overnight merge에서 왔다 |
| T03 | Field guide | exp/retention-push 실험 브랜치 | release-bot이 archived branch를 RC3에 merge했다 |
| T04 | Field note (도구 소개만) | 넓어진 merge rule | 넓어진 merge rule이 archive를 끌어왔다 → Chapter epilogue |

다음 Ticket은 기록을 찾고 추리에 답한 뒤에 도착한다. 추리 오답은 벌점이 없고 다시 답할 수 있다.
