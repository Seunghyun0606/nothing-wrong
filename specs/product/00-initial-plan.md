# Nothing Wrong — Codex Implementation Blueprint v0.1

## 0. Document Status

Status: `REFERENCE`

Historical status: `IMPLEMENTATION_READY`

Purpose:

이 문서는 **Nothing Wrong**의 첫 번째 playable prototype을 위해 작성된 최초 기획안을 보존한다.

Project OS 구조화 이후 정본은 다음 위치에서 관리한다.

- 장기 제품 방향: `PROJECT.md`
- 제품 범위와 상세 요구사항: `specs/product/`, `specs/feature/`, `specs/ux/`
- 기술 설계: `specs/architecture/`
- 확정 설계 선택: `.project-os/decisions/`
- 현재 순서와 상태: `.project-os/state/`
- 실행 작업 계약: `.project-os/tasks/`

이 문서는 canonical 문서의 배경과 원문 reference이며, 진행 상태나 Task 계약의 정본이 아니다.

현재 단계에서는 최종 Mystery / Narrative Story를 구현하지 않는다.

향후 Narrative가 추가될 수 있도록 Extension Point만 제공한다.

---

# 1. Naming Rules

## Product / Brand

공식 게임명:

```text
Nothing Wrong
```

표시명:

```text
NOTHING WRONG
```

Repository 권장명:

```text
nothing-wrong
```

package.json:

```json
{
  "name": "nothing-wrong"
}
```

브라우저 title:

```text
Nothing Wrong
```

localStorage prefix:

```text
nothingwrong.*
```

예:

```text
nothingwrong.profile
nothingwrong.gameState
nothingwrong.settings
```

---

## Domain Naming Rule

`Nothing Wrong`은 **제품/브랜드 이름에만 사용한다.**

다음 Core Domain Entity에는 제품명을 prefix하지 않는다.

Correct:

```text
Ticket
Scenario
BugReport
ExpectedBug
BugType
Mutation
Evidence
ReviewResult
GameState
```

Incorrect:

```text
NothingWrongTicket
NothingWrongScenario
NothingWrongBugReport
```

QA 업무에서 실제로 사용되는 `Bug`, `Bug Report`, `Known Issue`, `No Issue Found` 등의 용어는 게임 내부에서도 그대로 사용한다.

---

# 2. Product Goal

**Nothing Wrong**은 가상의 QA 직원이 되어 업무 Ticket을 받고, 실제 서비스처럼 구성된 Fake Product를 테스트하고, 이상 현상을 발견·재현·증명하여 Bug Report를 제출하는 QA Investigation Simulation Game이다.

Core Loop:

```text
Dashboard
→ Ticket
→ Requirement
→ Test
→ Detect
→ Reproduce
→ Evidence
→ Report
→ Review
→ Progression
→ Next Ticket
```

게임의 핵심은 단순 `Find the Bug`가 아니다.

```text
Understand
→ Explore
→ Hypothesize
→ Reproduce
→ Prove
→ Report
```

플레이어가 실제로 생각하고 테스트하도록 만드는 것이 핵심이다.

---

# 3. Core Design Principles

1. Fake Product는 실제 서비스처럼 정상 동작해야 한다.
2. 정상 기능이 버그보다 훨씬 많아야 한다.
3. Ticket에 항상 Bug가 있다고 가정할 수 없어야 한다.
4. 클릭 자체에는 Penalty를 주지 않는다.
5. Report 제출에는 책임이 따른다.
6. Bug 발견보다 Reproduction과 Evidence가 중요하다.
7. Career 상승은 단순 난이도 증가가 아니라 업무 성격 변화다.
8. Core Gameplay와 Mystery Narrative를 분리한다.
9. Scenario Content는 가능한 한 데이터 기반으로 만든다.
10. 특정 Ticket을 위한 hard-coded Product logic을 금지한다.

---

# 4. MVP Scope

## Platform

```text
Web Desktop
```

Tech:

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

향후:

```text
Tauri
Windows
macOS
Steam
```

Tauri는 MVP 범위에서 제외한다.

---

# 5. Fake Product

MVP에서는 하나만 구현한다.

```text
Shoply
```

Shoply는 Nothing Wrong이라는 게임과 별개의 가상 서비스 브랜드다.

필요 화면:

```text
/login
/home
/search
/product/:id
/cart
/checkout
/orders
/profile
```

---

# 6. Main Game Routes

```text
/start
/login
/dashboard
/tickets/:id
/test/:ticketId
/reports
/review/:ticketId
/career
/settings
```

---

# 7. MVP Tickets

총 8개.

```text
T01 Visual
T02 Data
T03 Behavior
T04 Conditional
T05 No Bug
T06 Cross Screen
T07 Multiple Bugs
T08 Mini Regression
```

---

# 8. QA Tools

MVP:

```text
Screenshot Evidence
Viewport Switcher
Account Switcher
Notes
```

향후:

```text
Locale Switcher
Clock Control
Network Mode
Session Inspector
Build Comparison
Regression Matrix
```

---

# 9. Progression

MVP Career:

```text
Junior QA
→ QA Engineer
```

핵심 수치:

```text
XP
Reputation
```

Money / Equipment Economy는 구현하지 않는다.

---

# 10. Out of Scope

현재 구현하지 않는다.

```text
Final Mystery Narrative
Investigation Board
Backend
Online Accounts
Global Leaderboard
Multiplayer
LLM Runtime
Procedural Ticket Generation
Real Website Crawling
Real Browser iframe
Tauri
Steam Integration
Payment
Achievements
Multiple Fake Products
```

---

# 11. Architecture

Game Engine과 Game Content를 명확히 분리한다.

```text
src/
├─ app/
├─ game/
├─ products/
├─ scenarios/
├─ pages/
├─ components/
└─ persistence/
```

권장 상세 구조:

```text
src/

app/
  router/
  providers/
  App.tsx

game/
  domain/
  engine/
  mutations/
  evidence/
  reporting/
  progression/

products/
  shoply/
    components/
    pages/
    data/
    rules/

scenarios/
  shoply/
    T01.json
    T02.json
    T03.json
    T04.json
    T05.json
    T06.json
    T07.json
    T08.json

pages/
  StartPage/
  CompanyLoginPage/
  DashboardPage/
  TicketPage/
  TestWorkspacePage/
  ReviewPage/
  ReportsPage/
  CareerPage/

components/
  game/
  fake-browser/
  qa-tools/
  common/

persistence/
  localStorage/
```

---

# 12. Runtime Architecture

```text
React App
   │
   ├── Company Game Shell
   │
   ├── Ticket Engine
   │
   ├── Test Workspace
   │      ├── Fake Browser
   │      ├── Shoply Runtime
   │      └── QA Toolbar
   │
   ├── Scenario Engine
   │
   ├── Mutation Engine
   │
   ├── Evidence Engine
   │
   ├── Report Engine
   │
   ├── Review Engine
   │
   └── Progression Engine
```

---

# 13. Core Domain Types

```ts
type TicketStatus =
  | "NEW"
  | "ACCEPTED"
  | "TESTING"
  | "REPORTED"
  | "REVIEWED"
  | "RESOLVED"
  | "NO_ISSUE";

type Priority =
  | "LOW"
  | "NORMAL"
  | "HIGH"
  | "CRITICAL";

type BugSeverity =
  | "LOW"
  | "MEDIUM"
  | "HIGH"
  | "CRITICAL";

type BugType =
  | "VISUAL"
  | "CONTENT"
  | "DATA"
  | "BEHAVIOR"
  | "STATE"
  | "CONDITIONAL"
  | "CROSS_SCREEN";

type QAAccount =
  | "GUEST"
  | "BASIC"
  | "GOLD";

type Viewport =
  | "DESKTOP"
  | "TABLET"
  | "MOBILE";
```

---

# 14. Ticket Contract

```ts
interface Ticket {
  id: string;

  projectId: string;

  title: string;

  sender: {
    id: string;
    name: string;
    role: string;
  };

  priority: Priority;

  request: string;

  scope: string[];

  requirements: Requirement[];

  attachments?: Attachment[];

  startingContext: TestContext;

  hints?: Hint[];

  status: TicketStatus;
}
```

---

# 15. Requirement

```ts
interface Requirement {
  id: string;
  description: string;
  reference?: string;
}
```

Example:

```json
{
  "id": "REQ-SHOP-001",
  "description": "Gold members receive a 20% discount when SAVE20 is applied."
}
```

---

# 16. Test Context

```ts
interface TestContext {
  account: QAAccount;
  viewport: Viewport;
  locale: string;
  currentPath: string;
}
```

---

# 17. Scenario Contract

Scenario가 게임의 기본 Content Unit이다.

```ts
interface Scenario {
  id: string;

  ticket: Ticket;

  seed: ScenarioSeed;

  expectedBugs: ExpectedBug[];

  mutations: Mutation[];

  scoring: ScoringConfig;

  progression?: ProgressionReward;

  narrative?: NarrativeHook;
}
```

Narrative는 현재 Runtime에서 사용하지 않는다.

```ts
interface NarrativeHook {
  tags?: string[];
  clueIds?: string[];
  entityIds?: string[];
  persistentChanges?: string[];
}
```

기본값:

```json
{
  "tags": [],
  "clueIds": [],
  "entityIds": [],
  "persistentChanges": []
}
```

---

# 18. Mutation Contract

```ts
interface Mutation {
  id: string;

  type: MutationType;

  target: string;

  conditions?: MutationCondition[];

  payload: Record<string, unknown>;
}
```

```ts
type MutationType =
  | "REPLACE_TEXT"
  | "HIDE_ELEMENT"
  | "WRONG_NUMBER"
  | "WRONG_STYLE"
  | "WRONG_ACTION"
  | "WRONG_STATE"
  | "WRONG_CALCULATION"
  | "CROSS_SCREEN_MISMATCH";
```

---

# 19. Mutation Condition

```ts
interface MutationCondition {
  field: string;

  operator:
    | "EQ"
    | "NEQ"
    | "GT"
    | "GTE"
    | "LT"
    | "LTE"
    | "IN";

  value: unknown;
}
```

Example:

```json
[
  {
    "field": "account",
    "operator": "EQ",
    "value": "GOLD"
  },
  {
    "field": "cart.quantity",
    "operator": "GTE",
    "value": 3
  }
]
```

---

# 20. Expected Bug

Canonical 정답 정의.

```ts
interface ExpectedBug {
  id: string;

  type: BugType;

  title: string;

  target: string;

  severity: BugSeverity;

  reproductionConditions: Condition[];

  expected: string;

  actual: string;

  validEvidenceTargets: string[];
}
```

플레이어에게 직접 노출하지 않는다.

---

# 21. Evidence

```ts
interface Evidence {
  id: string;

  ticketId: string;

  type: "SCREENSHOT";

  path: string;

  capturedAt: number;

  context: TestContext;

  snapshot: Record<string, unknown>;
}
```

MVP에서는 실제 PNG 저장이 필수는 아니다.

화면 snapshot + metadata + preview로 시작 가능하다.

---

# 22. Bug Report

```ts
interface BugReport {
  id: string;

  ticketId: string;

  title: string;

  reproductionSteps: ReportStep[];

  expected: string;

  actual: string;

  severity: BugSeverity;

  evidenceIds: string[];

  submittedAt: number;
}
```

---

# 23. Review Result

```ts
interface ReviewResult {
  valid: boolean;

  matchedBugId?: string;

  scores: {
    detection: number;
    reproduction: number;
    evidence: number;
    severity: number;
  };

  totalScore: number;

  xp: number;

  reputationDelta: number;

  feedback: string[];
}
```

Review logic은 React 외부의 pure function으로 구현한다.

---

# 24. Game State

```ts
interface GameState {
  profile: PlayerProfile;

  tickets: Record<string, PlayerTicketState>;

  currentTicketId?: string;

  unlockedTools: string[];

  reportHistory: BugReport[];

  reviewHistory: ReviewResult[];
}
```

---

# 25. Player Profile

```ts
interface PlayerProfile {
  name: string;

  level: number;

  career:
    | "JUNIOR_QA"
    | "QA_ENGINEER";

  xp: number;

  reputation: number;
}
```

초기:

```json
{
  "name": "J. PARK",
  "level": 1,
  "career": "JUNIOR_QA",
  "xp": 0,
  "reputation": 100
}
```

---

# 26. Ticket State Machine

```text
NEW
 ↓
ACCEPTED
 ↓
TESTING
 ↓
┌───────────────┐
│               │
REPORT        NO ISSUE
│               │
↓               ↓
REVIEW        REVIEW
│               │
└───────┬───────┘
        ↓
     RESOLVED
```

URL 이동과 State가 불일치해도 Game State가 깨지지 않아야 한다.

---

# 27. Fake Browser

실제 iframe이나 외부 Browser를 사용하지 않는다.

React 기반 Fake Browser다.

```text
FakeBrowser
├─ BrowserBar
├─ ViewportContainer
└─ ProductRouter
```

Example:

```tsx
<FakeBrowser>
  <ShoplyApp scenario={scenario} />
</FakeBrowser>
```

Main Game Router와 Shoply 내부 Router를 논리적으로 분리한다.

---

# 28. Shoply Baseline Domain

```ts
interface ShoplyUser {
  id: string;
  name: string;
  tier: "BASIC" | "GOLD";
}

interface ShoplyProduct {
  id: string;
  name: string;
  price: number;
  stock: number;
}

interface CartItem {
  productId: string;
  quantity: number;
}

interface ShoplyState {
  currentUserId: string;
  cart: CartItem[];
  coupon?: string;
  orders: Order[];
}
```

---

# 29. Normal Business Rules

Bug를 구현하기 전에 정상 Rule부터 만든다.

Subtotal:

```text
Σ product.price × quantity
```

SAVE10:

```text
10% discount
```

SAVE20:

```text
Gold user only
20% discount
```

Shipping:

```text
Subtotal >= $50
→ Free

Subtotal < $50
→ $5
```

Mutation이 없는 Shoply는 항상 이 정상 Rule을 따른다.

---

# 30. Critical Architecture Rule

금지:

```ts
if (ticketId === "T04") {
  total = wrongTotal;
}
```

Product 내부에서 Ticket ID 기반 분기 금지.

반드시:

```text
Scenario
→ Mutation
→ Runtime
```

으로 처리한다.

---

# 31. Mutation Runtime

```text
Base State
    ↓
Business Rules
    ↓
Mutation Resolver
    ↓
Rendered State
```

대표 API:

```ts
resolveMutation(
  target,
  baseValue,
  context,
  mutations
)
```

Mutation이 없으면 baseValue 그대로 반환해야 한다.

---

# 32. Test Workspace

```text
┌──────────────────────────────────────────────┐
│ QA TOOLBAR                                   │
├──────────────────────────────────────────────┤
│                                              │
│                FAKE BROWSER                  │
│                                              │
├──────────────────────────────────────────────┤
│ TICKET | NOTES | EVIDENCE                    │
│                                              │
│                    CAPTURE   CREATE REPORT   │
└──────────────────────────────────────────────┘
```

Fake Product가 가장 많은 화면 영역을 차지한다.

---

# 33. QA Toolbar

초기:

```text
Ticket
Notes
Evidence
Capture
Report
Viewport
```

T04 이후:

```text
Account Switcher
```

---

# 34. Notes

```ts
interface TicketNote {
  ticketId: string;
  content: string;
}
```

Local Save.

평가하지 않는다.

---

# 35. Viewport

```text
Desktop
Tablet
Mobile
```

실제 Fake Product viewport width가 변경되어야 한다.

단순한 UI label 변경 구현은 금지한다.

---

# 36. Account Switcher

T04에서 Unlock.

```text
Basic
Gold
```

Account 변경 시 데이터 reset 여부는 Scenario policy가 결정한다.

---

# 37. Interaction History

```ts
interface PlayerAction {
  timestamp: number;
  type: string;
  target?: string;
  payload?: Record<string, unknown>;
}
```

Example:

```text
OPEN_PRODUCT
ADD_TO_CART
CHANGE_QUANTITY
APPLY_COUPON
OPEN_CHECKOUT
```

Report reproduction step 후보 생성에 사용한다.

---

# 38. Report Builder

MVP에서는 typing 부담을 최소화한다.

필수:

```text
Title
Reproduction
Expected
Actual
Severity
Evidence
```

초기 Ticket:

```text
Expected / Actual candidate selection
```

후반 Ticket:

```text
partial free text
```

Reproduction은 Interaction History에서 Step 후보를 제공하고 플레이어가 선택/정렬하게 한다.

---

# 39. Review Matching

MVP에서는 LLM/NLP Evaluation을 사용하지 않는다.

```text
BugReport
↓
ExpectedBug
↓
Conditions
Evidence
Severity
```

구조적 matching을 사용한다.

---

# 40. Score

```text
Detection       40
Reproduction    25
Evidence        20
Severity        15
```

총 100점.

---

# 41. Reputation

Valid Bug:

```text
+1 ~ +5
```

False Positive:

```text
-2
```

Correct No Issue:

```text
+2
```

Missed Bug:

```text
-2
```

Reputation으로 Game Over를 만들지 않는다.

---

# 42. Ticket Specifications

## T01 — Visual

Purpose:

```text
Core loop tutorial
```

Issue:

```text
Checkout primary CTA has incorrect style.
```

Expected:

```text
Primary button
```

Actual:

```text
Secondary button
```

---

## T02 — Data

```text
$30 × 2
```

Expected:

```text
$60
```

Actual:

```text
$50
```

---

## T03 — Behavior

```text
Cancel Order
```

Expected:

```text
Return / cancel flow
```

Actual:

```text
Payment flow opens
```

---

## T04 — Conditional

Unlock:

```text
Account Switcher
```

Trigger:

```text
Gold
+
SAVE20
+
Quantity >= 3
```

Expected:

```text
20% discount
```

Actual:

```text
10% discount
```

이 Ticket이 핵심 Vertical Slice 검증 Ticket이다.

---

## T05 — No Bug

고객 제보가 있지만 실제 시스템은 정상.

Correct:

```text
NO ISSUE FOUND
```

Ticket에 반드시 Bug가 있는 것은 아니라는 것을 학습시킨다.

---

## T06 — Cross Screen

Product:

```text
Stock 5
```

Cart:

```text
Stock 2
```

두 화면을 비교해야 한다.

---

## T07 — Multiple Bugs

```text
Currency Formatting
+
Mobile Layout
```

한 Ticket에 여러 Bug가 있을 수 있다.

---

## T08 — Mini Regression

Changed:

```text
Cart
Checkout
Coupon
Profile
```

플레이어가 테스트 Coverage를 선택한다.

---

# 43. Unlock

```text
T01
↓
T02
↓
T03
↓
Account Switcher
↓
T04
↓
T05 / T06
↓
T07
↓
T08
↓
QA Engineer
```

---

# 44. Persistence

MVP:

```text
localStorage
```

Keys:

```text
nothingwrong.profile
nothingwrong.gameState
nothingwrong.settings
```

```ts
interface SaveFile {
  version: 1;
  state: GameState;
}
```

Save Version은 필수다.

---

# 45. Testing

## Unit

```text
Business rules
Mutation resolver
Mutation conditions
Review scoring
Progression
Save serialization
Scenario validation
```

## Component

```text
TicketPanel
FakeBrowser
QA Toolbar
AccountSwitcher
ReportBuilder
ReviewResult
```

## E2E

Playwright:

```text
Start
→ Login
→ Dashboard
→ T01
→ Test
→ Capture
→ Report
→ Review
→ Dashboard
```

---

# 46. Scenario Tests

Conditional Bug는 반드시 Positive와 Negative를 모두 테스트한다.

T04:

Positive:

```text
GOLD
SAVE20
Quantity 3
→ mutation active
```

Negative:

```text
BASIC
SAVE20
Quantity 3
→ normal
```

또는:

```text
GOLD
SAVE20
Quantity 1
→ normal
```

---

# 47. Scenario Validation

Scenario JSON은 Runtime 전에 validation한다.

Zod 사용 권장.

Validation 오류는 development에서 명확히 표시한다.

Silent fallback 금지.

---

# 48. Development Scenario Tool

개발 편의를 위해:

```text
/scenario-dev
```

같은 development-only route를 둘 수 있다.

표시:

```text
Scenario
Current State
Account
Viewport
Active Mutation
Current Path
```

Production build에서는 노출하지 않는다.

---

# 49. Narrative Extension Point

현재 Narrative는 구현하지 않는다.

하지만 Scenario에는 다음 optional field를 유지한다.

```ts
narrative?: {
  eventId?: string;
  clueIds?: string[];
  entityIds?: string[];
  persistentChanges?: string[];
};
```

현재 Game Runtime은 이 값을 무시한다.

향후 Mystery Story가 확정되면:

```text
Ticket
→ Normal QA Gameplay
→ Optional Clue
→ Persistent World Change
```

구조로 확장한다.

---

# 50. In-Game Terminology

다음 표현은 향후 Story에서도 활용할 수 있으므로 일반 QA 상태값으로 유지한다.

```text
KNOWN ISSUE
NO ISSUE FOUND
RESOLVED
INVALID REPORT
UNDER REVIEW
NO ACTION REQUIRED
```

이 중 `Known Issue`는 게임명이 아니다.

게임 안에서 사용하는 일반 Status / Classification이다.

---

# 51. Documentation Structure

Repository에는 최소 다음 문서를 둔다.

```text
README.md

docs/
  product/
    GAME_DESIGN.md
    PLAYER_STORYBOARD.md
    MVP_SCOPE.md

  architecture/
    ARCHITECTURE.md
    DOMAIN_MODEL.md
    SCENARIO_SCHEMA.md
    GAME_STATE.md

  content/
    TICKET_DESIGN.md
    BUG_TAXONOMY.md
    SHOPLY.md

  development/
    DEVELOPMENT.md
    TESTING.md
    CODEX_TASKS.md

  narrative/
    README.md

  decisions/
```

---

# 52. Narrative README

현재:

```text
Narrative design is intentionally deferred.

Core gameplay must remain independent from
the final mystery storyline.

Reserved extension points:

- narrative tags
- clues
- entities
- persistent world changes
```

이외 Story를 임의로 작성하지 않는다.

---

# 53. ADR

```text
docs/decisions/
```

초기:

```text
ADR-001-scenario-driven-architecture.md
ADR-002-fake-browser.md
ADR-003-local-persistence.md
ADR-004-pure-review-evaluation.md
```

---

# 54. Recommended Implementation Order

## Milestone 0

Foundation.

```text
React/Vite/TS
Router
Testing
Domain
Zod
Documentation
```

## Milestone 1

Company Shell.

```text
Start
Login
Dashboard
Ticket Detail
```

## Milestone 2

Normal Shoply.

```text
Product
Cart
Checkout
Orders
Profile
```

No Bug yet.

## Milestone 3

Test Workspace.

```text
Fake Browser
Ticket
Notes
Viewport
Evidence
```

## Milestone 4

Scenario Runtime.

## Milestone 5

Mutation Engine.

## Milestone 6

Report / Review.

## Milestone 7

Progression / Persistence.

## Milestone 8

T01~T08 Content.

## Milestone 9

UX Polish.

---

# 55. Implementation Rules for Codex

1. Do not implement future features without request.
2. Do not introduce backend.
3. Do not access external websites.
4. Do not put Ticket-specific conditions inside Shoply components.
5. Prefer Scenario-driven content.
6. Game logic must be testable without React.
7. Normal Product behavior must exist independently of Mutation.
8. Every Mutation requires automated tests.
9. Every Scenario requires a reproduction test.
10. Conditional Scenario requires positive + negative tests.
11. Do not create Mystery Story yet.
12. Preserve Narrative extension fields.
13. Treat `Nothing Wrong` as brand name only.
14. Do not prefix domain types with `NothingWrong`.
15. Keep commits small and logically separated.

---

# 56. Commit Strategy

```text
chore: initialize nothing-wrong project

docs: add game and architecture specifications

feat: add core game domain

feat: add company shell

feat: add shoply baseline product

feat: add qa test workspace

feat: add scenario runtime

feat: add mutation engine

feat: add evidence and reporting

feat: add review scoring

feat: add progression persistence

content: add tutorial scenarios

test: add scenario regression suite
```

---

# 57. Architecture Acceptance

다음 질문에 모두 YES여야 한다.

```text
Can a new Ticket be added without changing React components?

Can a Scenario mutation be changed without editing Shoply?

Can Shoply run with zero mutations?

Can another Fake Product reuse the Mutation Engine?

Can Report Evaluation execute as a pure function?

Can T04 be reproduced automatically?

Can Narrative later be added without rewriting Core Gameplay?
```

하나라도 NO라면 Architecture를 재검토한다.

---

# 58. First Playable Target

첫 구현 목표:

```text
T01 End-to-End Vertical Slice
```

Flow:

```text
NOTHING WRONG
↓
Start Work
↓
Company Login
↓
Dashboard
↓
T01
↓
Shoply
↓
Visual Bug
↓
Evidence
↓
Bug Report
↓
Review
↓
Dashboard
```

T01 하나만 구현하더라도 Architecture는 T08까지 확장 가능한 상태여야 한다.

---

# 59. Prototype Gate

T01~T04가 구현되면 Human Playtest를 우선한다.

확인:

```text
Is searching for the issue enjoyable?

Does Shoply feel like a believable product?

Can players distinguish normal behavior from defects?

Is reproduction satisfying?

Does reporting feel like gameplay rather than paperwork?

Does the player want to open the next ticket?
```

이 결과를 확인하기 전에는 콘텐츠를 대량 생산하지 않는다.

---

# 60. Current Priority

현재 최우선은:

```text
Architecture
+
T01 End-to-End Vertical Slice
```

이다.

전체 MVP를 한 번에 구현하지 않는다.

첫 Pipeline:

```text
Scenario
→ Mutation
→ Detection
→ Evidence
→ Report
→ Review
→ Progression
```

이 안정적으로 동작한 뒤 다음 Ticket으로 확장한다.
