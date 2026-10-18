# MVP Ticket Catalog

각 Ticket은 Scenario data로 정의하며 Product Component에 Ticket ID 조건을 추가하지 않는다. ExpectedBug는 플레이어에게 직접 노출하지 않는다.

| Ticket | Learning Goal | Canonical Case |
| --- | --- | --- |
| T01 Visual | Core loop tutorial | Checkout confirm CTA가 Primary여야 하나 Secondary style로 표시됨 |
| T02 Data | 수치 검증 | $30 × 2의 subtotal이 $60 대신 $50으로 표시됨 |
| T03 Behavior | action/result 검증 | Cancel Order가 return/cancel flow 대신 payment flow를 엶 |
| T04 Conditional | 조건 조합과 계정 전환 | Gold + SAVE20 + quantity ≥ 3에서 20% 대신 10% 할인 |
| T05 No Bug | 제보를 맹신하지 않는 판단 | RC4 검증: $45 주문 배송비 불만은 규칙대로이며 정답은 `NO ISSUE FOUND` (구현됨, 소유자 지시) |
| T06 Cross Screen | 화면 간 일관성 | Product stock 5와 Cart stock 2가 불일치 |
| T07 Multiple Bugs | 복수 결함 보고 | Currency formatting과 Mobile layout 결함 |
| T08 Mini Regression | 범위와 Coverage 선택 | Cart, Checkout, Coupon, Profile 변경 영역 회귀 테스트 |

## Unlock Order

```text
T01 → T02 → T03 → Account Switcher → T04
→ T05/T06 → T07 → T08 → QA Engineer
```

## Scenario Verification Rules

- 모든 Scenario에는 canonical reproduction test가 필요하다.
- 모든 Mutation에는 active와 inactive 동작을 검증하는 자동 테스트가 필요하다.
- Conditional Scenario는 positive와 negative 조건을 모두 테스트한다.
- T04 positive: Gold, SAVE20, quantity 3에서 Mutation active.
- T04 negative: Basic이거나 quantity 1이면 정상 20%/eligibility rule을 따른다.

## Content Production Gate

T01~T04 구현 후 Human Playtest를 완료하기 전에는 T05~T08 Content를 대량 제작하지 않는다.

## Source Reference

- [Initial plan](../product/00-initial-plan.md), sections 42–43, 46, 59

## Story Chapter 1 · Release Candidate 3 (DEC-005)

| Ticket | Guide level | Clue | Deduction |
| --- | --- | --- | --- |
| T01 | Full tutorial | 02:14 · release-bot | 체크아웃은 실제로 바뀌었다 (자동 merge) |
| T02 | Guided | 은퇴한 "TWO FOR $50" 프로모션 코드 | 두 결함은 같은 overnight merge에서 왔다 |
| T03 | Field guide | exp/retention-push 실험 브랜치 | release-bot이 archived branch를 RC3에 merge했다 |
| T04 | Field note (도구 소개만) | 넓어진 merge rule | 넓어진 merge rule이 archive를 끌어왔다 → Chapter epilogue |

Story는 Ticket 해금을 막지 않는다. 추리 오답은 벌점이 없고 첫 시도 정답은 Reputation +1이다.
