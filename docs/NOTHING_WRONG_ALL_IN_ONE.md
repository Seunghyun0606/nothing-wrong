# NOTHING WRONG — AI HANDOFF (All-in-One)
버전: handoff-1.0 / 2026-10-18
이 문서는 00~08의 Markdown 문서를 전달 편의상 순서대로 결합한 파일이다. 각 섹션의 내부 문서 우선순위는 00_START_HERE를 따른다.

---

<!-- BEGIN 00_START_HERE.md -->

# NOTHING WRONG — AI Collaboration Handoff

- 문서 버전: `handoff-1.0` (2026-10-18)
- 프로젝트: **Nothing Wrong**
- 장르: Corporate Mystery / Integration QA Investigation Thriller
- 형식: Web desktop 우선, 선택지·QA 업무·이미지/데이터 비교 기반
- 캠페인 목표: 약 5–7시간, 메인 Ticket 30개 + 선택적 28B + Final Release
- 문서 목적: **기획 AI / 개발 AI / QA AI가 동일한 사실과 제약을 공유**하도록 하는 인수인계

> 본 문서 묶음은 사용자가 합의한 `Main Campaign Scenario v0.5`와 `Playable Campaign Content Specification v0.1`, 이어진 시놉시스 논의를 바탕으로 작성한 **제작용 통합본**이다. 코딩이나 Git 커밋/배포를 수행한 결과물이 아니다.

## 파일 안내

| 파일 | 목적 | 주 소비자 |
|---|---|---|
| `01_MASTER_SYNOPSIS.md` | 전체 스토리, 감정선, 6막, 결말, 추리의 인과 | 전원 |
| `02_NARRATIVE_CANON.md` | 인물·조직·사건·날짜·공식 사실과 미확정 가설 | 기획 / 개발 / QA |
| `03_PLAYABLE_TICKETS.md` | NW-001~030 + 선택 028B + FINAL 콘텐츠 매트릭스 | 기획 / 개발 / QA |
| `04_SCENARIO_ENGINE_CONTRACT.md` | 데이터 스키마, 예시 JSON, 증거·리뷰·진행 조건 | 개발 / QA |
| `05_QA_TEST_PLAN.md` | 콘텐츠 QA, 개연성 검증, E2E, 수용 기준 | QA / 개발 |
| `06_AGENT_PROMPTS.md` | 각 AI에게 복사해서 전달할 프롬프트 | 사용자 / 전원 |
| `07_IMAGE_ASSET_BIBLE.md` | 반복 등장하는 인물/사진·메타데이터 및 시각 단서 | 기획 / 아트 / QA |
| `08_OPEN_DECISIONS.md` | 기존 설계상 보완해야 할 가정·모순·결정 보류 항목 | 기획 / QA |
| `NOTHING_WRONG_ALL_IN_ONE.md` | 위 자료를 순서대로 병합한 단일 전달용 문서 | 단일 AI 세션 |

## 필수 원칙 — 어떤 역할도 변경 금지

1. **QA가 주 게임**이다. `Ticket → 요구사항 파악 → 재현 → Source/Target/Trace 비교 → Evidence → Report 또는 No Issue → Review`를 유지한다.
2. 플레이어는 Horizon의 내부감사 담당자도 경찰도 아니다. **Northstar 소속 외주 통합 QA**이며, 업무에 할당된 **SIT/UAT/QA 뷰와 비식별 이관 데이터**로만 검증한다.
3. 중요한 미스터리 정보는 **QA 검증에 필요한 화면/첨부/로그**로 자연스럽게 등장한다. 독립적인 ‘해킹/비밀 탐색’으로 정답을 찾게 만들지 않는다.
4. **버그가 아닌 정상적 비즈니스 룰**이 실제 범죄적 의도를 실행한다는 역설이 제목의 핵심이다. `WORKING AS DESIGNED`는 진실의 정당성을 뜻하지 않는다.
5. `October 17 → Horizon Ridge → Daniel Park → Foundation → Network → Northstar` 순으로 인지가 확장된다. 전말을 초반에 노출하지 않는다.
6. 사진은 얼굴·상징·공간·시간의 **관계 암시**로 사용한다. 사진 한 장만으로 범죄/공모/살인을 ‘확정’하면 안 된다.
7. 당시 **사망과 시설 사고는 공공기관이 인지하고 조사했다**. 숨겨진 것은 사망 자체가 아니라 고용 관계, 재단의 연결, 조직적 조작과 범죄 네트워크다.
8. 내부/외부 감사는 무능하거나 전원 공범이 아니다. 조사 범위, 분리된 ID, 불충분한 증거, 승인된 예외 처리와 일부 의도적 개입이 합쳐져 큰 그림을 놓쳤다.
9. Daniel의 **사망은 확정**, **고의 살해는 미확정**. 약품 및 강제 노동 관련 부분도 초기에는 정황 증거이며 범죄명을 자동 확정하지 않는다.
10. 스토리 필수 단서는 막힘 없이 재방문/대체 경로로 확보 가능. 선택적 사진 기억에 메인 진행을 종속시키지 않는다.

## 권장 작업 방식

- **기획 AI**: `01 → 02 → 03 → 07 → 08` 순서로 읽고 새로운 Ticket/대사/자산을 작성. 모든 추가 내용은 Canon과 Clue 의존 관계를 검증.
- **개발 AI**: `01 → 03 → 04 → 05` 순서로 읽고 **NW-001 1개 End-to-End**부터 개발. 이후 001~005, 006~010 순으로 수직 슬라이스 개발.
- **QA AI**: `01 → 02 → 03 → 04 → 05 → 08` 순서로 읽고 자동 테스트 + 서사 수동 평가를 구분.
- 변경이 필요한 경우 `08_OPEN_DECISIONS.md`에서 의사결정 기록 → Narrative Canon 갱신 → Ticket/Schema/QA 케이스 동기화 순서로 수정.

## 우선순위 / 충돌 해결

`02_NARRATIVE_CANON.md`(사실관계) → `01_MASTER_SYNOPSIS.md`(서사 의도) → `03_PLAYABLE_TICKETS.md`(콘텐츠) → `04_SCENARIO_ENGINE_CONTRACT.md`(구현 표준) → 개별 생성물.

아래는 **계획 단계의 가정**으로, 승인 전 법적/서사적 확정 사실처럼 표현하지 말 것:

- 사건 연도 `2021-10-17`은 **가안**. 2022~2024 Migration이 그 이후여야 한다는 연대기 정합성을 위한 제안이다.
- Foundation의 정확한 법률상 소유·지배구조, 소재 국가와 적용 법률은 **미정**이다. 문서의 `Community Trust → Foundation`은 지배력 관계를 묘사하는 픽션상의 작업 가정이다.
- 30개 Ticket/5–7시간은 **목표 분량**이지 검증된 플레이타임이 아니다.

## 완료 보고 형식

각 역할 AI는 답변에 `변경 파일 / 작업 내용 / 관련 Ticket·Clue ID / 테스트 증거 / 기존 Canon과 차이 / 남은 이슈 / 다음 우선순위`를 반드시 포함한다.


<!-- END 00_START_HERE.md -->

---

<!-- BEGIN 01_MASTER_SYNOPSIS.md -->

# NOTHING WRONG — 메인 캠페인 시놉시스

- 문서 버전: 1.0
- 기준: `Main Campaign Scenario v0.5` + `Playable Content v0.1`
- 장르: 오피스 QA 시뮬레이션 → 기업범죄 미스터리 → 제도적 스릴러
- 주제문: **시스템이 의도한 대로 정확하게 작동한다면, 그 의도 자체가 잘못되었을 때도 '정상'인가?**

## 로그라인

거대 기업집단 Horizon Group의 전사 시스템 통합 프로젝트에 파견된 외주 QA 직원. 평범한 웹 기능과 데이터 이관을 검증하던 그는 여러 서비스에서 반복되는 **10월 17일**의 불일치를 발견한다. 서로 다른 직원·거래·출장·보험 기록이 하나의 인물 **Daniel Park**로 수렴하고, 오래된 시설 사고의 흔적 뒤에서 `Horizon Foundation`이라는 폐쇄적 조직과 그룹의 부패한 운영구조가 드러난다. 그러나 가장 큰 반전은 그것을 실행한 프로그램들이 고장 난 것이 아니라 **요구사항대로 작동해 왔다**는 사실이다.

## 배경 — ONE HORIZON

플레이어는 외부 QA 업체 `Northstar Quality Services` 소속이다. 고객사 `Horizon Group`은 계열사 HR/쇼핑/결제/출장/구매/의료·복지/물류 데이터의 기준 ID와 통합 인터페이스를 묶는 `ONE HORIZON — Digital Integration Program`을 추진한다.

플레이어가 접하는 제품:
- **Shoply**: 임직원 구매·전자상거래
- **PeopleCore**: 인사·직원 상태
- **PayFlow**: 급여/비용 정산의 제한적 QA 뷰
- **Triply**: 출장/예약/경비
- **Horizon ID**: 직원 계정 및 글로벌 인물 매핑
- **Corporate CMS / Foundation Portal**: 행사/홍보 이미지
- **Procura**: 구매·벤더 마스터
- **CareBridge / Insurance**: 의료 비용·복리후생 정산의 제한적 데이터
- **RouteOne**: 물류 및 수령인
- **Compliance / Archive / Organization Master**: 사고 통계, 이전 문서, 조직/관계 매핑

업무 환경은 운영 DB 자유 조회가 아니라 QA/UAT 스냅샷과 Ticket에 승인된 최소 레코드·메타데이터만 노출한다. 민감 데이터는 원칙적으로 마스킹되어야 한다. **우연히 노출된 식별·의료 정보는 별도 데이터보호 결함**이기도 하다.

## 시작 — 평범한 일, 평범한 버그 (ACT 1 / NW-001~005)

직속 QA Lead **Mina Seo**는 재현 조건, Expected/Actual, Evidence, Severity를 차근차근 가르친다. 플레이어는 결제 버튼 색, 장바구니 합계, 직원 복지 등급 동기화, 행사 사진 썸네일 잘림, 급여 공제 항목 누락 같은 기능을 테스트한다.

기획상 첫 사진에는 프로그램 관리자 **Grace Yoon**, Foundation 이사 **Samuel Kwon**, 직원 **Daniel Park**가 함께 찍혀 있지만 이름표가 표시되지 않는다. 당시 QA 목적은 잘린 썸네일을 재현하는 것뿐이다. `Community Tier`, `Community Contribution` 같은 용어도 단순한 사내 제도처럼 보인다. **단서를 발견했다는 별도 알림은 뜨지 않는다.**

## 이상한 하루 — October 17 (ACT 2 / NW-006~009)

플레이어는 우수한 데이터 검증 성과로 Legacy Migration 티켓을 더 맡는다. 쇼핑 주문 기록의 특정 날짜가 누락되고, Triply에는 `HRDG-01`행 **38명 출발·돌아오는 예약 0건**, PeopleCore에는 같은 날 **교육휴가 38명**, 다음 날 **퇴사 12명**이 나타난다. 계속 등장하는 직원 ID는 `E-18419`, Daniel Park다.

퇴사일이 10월 16일인 Daniel에게 그 후 여러 달 급여성 거래가 존재한다. 플레이어는 상식적인 통합 QA 결함으로 Report하지만 고객사 승인 예외(`KNOWN ISSUE / LEGACY EXCEPTION`)로 처리된다. 당시 플레이어의 가장 합리적인 가설은 **공통 Migration Batch 오류**다.

## 원본이 이미 달랐다 (ACT 3 / NW-010~014)

`Global Identity Matching` 업무에서 PeopleCore·Triply·CareBridge·PayFlow의 서로 다른 레거시 ID가 `P-004217 — Daniel Park`로 통합된다. 시스템 통합 이전에는 각 부서와 감사 담당자가 **각자 다른 ID로 자신들의 기록만** 다뤄야 했다.

Integration Developer **Alex Han**은 각 시스템의 마이그레이션 실행 시점이 달랐음을 보여준다. 이것들은 동일한 Batch에서 파손될 수 없다. 제한된 Audit Metadata를 보면 사건 직후 여러 부서가 각각 `DATA_CORRECTION`을 수행했다. 한 사람이 모든 기록을 삭제한 정황이 아니라 **서로 다른 정상적인 행정 절차가 같은 사건의 관계를 끊은 듯한 패턴**이다.

출장의 `HRDG-01`은 실제로 `Horizon Ridge — Leadership & Wellness Center`이며, 행사 사진에는 Foundation의 기호와 Grace가 보인다. 플레이어는 아직 범죄보다 **원천 데이터 정합성 문제**를 먼저 의심한다.

## Zero Incident — 죽은 직원의 기록 (ACT 4 / NW-015~019)

의료비/혜택 지급 검증에서 Daniel의 글로벌 인물 ID와 `DB-01`이 다시 나타난다. 긴급 구매 기록은 Horizon Ridge에 집중된다. 그러나 월별 사고 Dashboard는 `Major Incidents: 0`; 상세 참조에는 `INC-1017 / DUPLICATE / Original Unavailable`이 남아 있다. 이후 보험 코드 매핑 QA에서 `DB-01 = Death Benefit`임이 드러난다.

플레이어는 HR `Voluntary Resignation`, 출장 `No Return`, 의료 `Emergency Record`, 보험 `Death Benefit`을 비교하여 **Daniel이 과거 사고에서 사망했다**는 사실을 알아낸다. 이 시점에 `Case Notes / Evidence Board`가 열린다.

플레이어가 제출한 Cross-System Data Integrity Report에는 **Grace Yoon**이 직접 `Historical Exception / No Action Required`를 적용한다. 보험 첨부의 공식 요약 문서에는 당시 Horizon Ridge에서 사망 1명·부상 여러 명이 발생했고 사고로 분류되었다는 정보가 있다. **공권력과 응급기관은 실제 개입했다.** 미스터리는 '죽음을 숨겼다'가 아니라 **사고 당시 Daniel의 고용/업무상 지위가 왜 사후적으로 바뀌었는가, 왜 사고 기록의 관련성이 제거되었는가**다.

## The Foundation — 정상 규칙이 만든 비정상 (ACT 5 / NW-020~026)

Procura의 글로벌 벤더 매칭을 검증하면 서로 다른 업체처럼 보였던 `Bright Future Consulting`, `BF Consulting`, `New Path Logistics`, `Horizon Living` 등이 등록대리인·주소군·연락처 등에서 반복적으로 겹친다. 이 거래를 과거에 **Daniel이 REJECT**했다는 승인 이력이 있다.

특정 업체의 예외적인 할인/우선 배정은 프로그램 결함이 아니라 `COMMUNITY_PARTNER_OVERRIDE`라는 **승인된 룰**이었다. CMS/재단 웹페이지 사진을 통해 Samuel·Grace·경영진의 오래된 관계가 재해석된다. 사진은 교류의 정황을 제공할 뿐 공모를 증명하지 않는다.

이어 인사 승진 테스트에서 성과와 근속을 충족한 직원이 탈락한다. 플레이어가 Bug로 보고하면 뒤늦게 `Community Alignment >= 70`이라는 정식 시스템 룰이 제시된다. 점수는 Foundation 행사·기부·리트릿 등과 연결되고 승진·주거·전근·복지에 영향을 준다. **불일치는 구현 오류가 아니라 공개 요구사항과 실제 승인 룰 사이의 간극**이었다.

다른 Ticket은 정상 의료 사용량에 반영되지 않는 관리 의료재고의 시설 간 이동, `Horizon Opportunity Program` 참가자의 장기간 미로그인·관리자 통제 연락처·귀환 정보 누락·이름/사진 불일치 등을 보여준다. 플레이어는 **약품 유출과 노동착취/인신매매를 의심할 정황**을 얻지만 이를 자동으로 기정사실화하지 않는다.

## Daniel's Last Case — 마지막 검증 (ACT 6 / NW-027~030)

Document Archive Migration의 접근권한 이슈를 재현하면서 Daniel이 사망 전 `Irregular Vendor and Foundation Transactions`라는 내부통제 Case를 작성했고 **사망 다음 날 그 Case가 종료**되었음을 확인한다. 사진 미리보기 회전 버그로 본 첨부 사진에는 사건 직전 Daniel·Grace·Samuel·Foundation 보안책임자가 같은 장소에 있다. 타임존 보정 QA를 거친 뒤에도 일부 출입·의료·차량 기록 간 동선 불일치가 남는다.

플레이어는 Daniel이 **사고사인지, 의도적으로 표적이 되었는지 확정할 수 없다**. Mina는 과거 유사한 Legacy 문제를 건드린 QA가 프로젝트에서 배제된 전례 때문에 플레이어를 보호하려 했다고 밝힌다. Alex는 문제의 규칙들이 문서대로 구현되었다고 말한다. 개인이 직무를 수행하는 행위들이 한데 모여 부조리한 제도가 된다.

최종 `Organization Master Consolidation`에서 일부 계열사의 최상위 지배력 경로는 `Horizon Holdings → Horizon Community Trust → Horizon Foundation`으로 수렴한다. **재단은 단순한 CSR 기관이 아니라 기업 의사결정을 지배하는 폐쇄적 네트워크의 중심**이었다.

같은 매핑 안에서 플레이어의 고용주 `Northstar Quality Services` 역시 Horizon 영향권으로 연결된다. 따라서 다양한 계열 시스템의 QA 계약, 고객사의 Defect Workflow 개입, 예외 처리 권한과 조직 내부의 침묵 압력이 새로운 의미를 갖게 된다.

## 결말 — Everything is working as intended

ONE HORIZON 최종 Release 검증 화면에는 `Identity / Payroll / Travel / Procurement / Medical / Organization: PASS`, `Blocking Defects: 0`, `SYSTEM STATUS: NORMAL`이 떠 있다. 일반적 기능 버그는 해결되었다. 그러나 Foundation 특혜, 인사/주거 통제, 일부 계정 접근 제한처럼 사람을 억압하는 정책은 **정상적인 Business Rule**로 계속 남는다.

최종 연출:

> VALIDATION COMPLETE  
> EVERYTHING IS WORKING AS INTENDED.  
> **NOTHING WRONG**

이후 내부 에스컬레이션·증거 보존·외부 제보·릴리스 승인 등 엔딩 분기를 넣을 여지는 있지만 **아직 확정되지 않았다**.

## 플레이어가 계속 조사하는 진짜 동기

- 1막: 티켓을 닫기 위해 재현한다.
- 2막: 티켓이 서로 충돌하므로 공통 Root Cause를 찾는다.
- 3막: 개발자에게 잘못된 원인 분류를 지적받아 Source/Target 책임을 가른다.
- 4막: 자신의 Cross-System Defect가 조직에 의해 예외 처리되지만, **명백한 데이터 정합성 리스크에 대한 처리 근거**가 불충분하다. 인물의 사망이 드러나면서 개인적·직업적 책임감을 느낀다.
- 5막: 관련 Ticket을 계속 받는 것은 Integration Regression 전문성을 인정받았기 때문이며, 다른 회사 시스템을 임의로 열지 않는다.
- 6막: 마감 Release QA에서 관계/권한/조직 데이터를 검증한다. 개인정보나 의료 원장을 무단 수집하지 않고 공식 품질·보안·준법 채널로 이관할 수 있는 증거의 범위와 한계를 고민한다.

## 앞선 감사/공권력이 전체 사건을 파악하지 못한 이유

- HR·Triply·보험·구매가 **서로 다른 Legacy ID**로 데이터를 관리했고 Cross-System 연결은 제한적이었다.
- 외부 재무감사는 중요성·표본·통제 범위가, 내부감사는 부서별 과제와 예외 승인 프로세스가 달랐다. 일부 경고/케이스가 있었으나 **증거가 부족하거나 범위상 종결**되었고, 일부 관리자도 의도적으로 억제했다.
- 경찰·소방·안전 조사기관은 실제 사고와 Daniel의 사망을 조사했다. 당시 조사에서 **재단 거래/고용상태 소급수정/다른 계열 프로그램의 연계**까지 드러나지 않았다. 해당 연결이 나중에 발견된다고 해서 곧바로 경찰의 과거 결론이 고의 은폐로 판명되는 것은 아니다.
- QA가 각 기록을 모두 볼 수 있었던 것은 **부여된 테스트 범위의 Source/Target 비교와 새 Global Identity Matching** 때문이다. 유출된 비마스킹 자료는 그 자체로 감사/보안 이슈로 다뤄야 한다.

## 화면과 장르 감정선

`SaaS 업무의 안도감 → 반복되는 날짜와 ID의 불편함 → 기록의 불일치 → 사람의 죽음 → 고의적 비즈니스 룰 → 통합된 권력 구조 → NORMAL이라는 말의 섬뜩함`

시스템·사진·대화와 제한된 보고서만으로 전달한다. 초자연·AI 모의세계·점프스케어는 사용하지 않는다.


<!-- END 01_MASTER_SYNOPSIS.md -->

---

<!-- BEGIN 02_NARRATIVE_CANON.md -->

# NOTHING WRONG — Narrative Canon / Continuity Bible

## 1. Canon Levels

- **FIXED**: 사용자와 기존 기획에서 합의된 줄거리 사실. 임의 변경 금지.
- **PROPOSED**: 개발·테스트 편의를 위해 본 문서에서 구체화한 설정. 기획 확인 후 FIXED 승격.
- **UNKNOWN**: 작품 세계에서 아직 밝혀지지 않거나 의도적으로 결론을 열어 둔 사안. AI가 사실로 확정 금지.

## 2. 인물

| Entity ID | 이름 / 직책 | 플레이어가 처음 아는 정보 | 후반 사실 또는 역할 | 상태 |
|---|---|---|---|---|
| `P-PLAYER` | 플레이어 / Northstar Integration QA | 외주 QA 실무자 | 사실의 연결을 보는 사람, 무제한 접근 불가 | FIXED |
| `P-MINA` | Mina Seo / QA Lead | 엄격하지만 유능한 선임 | 이전 QA 철수 사례를 알고 과잉 탐색을 말림. 전말은 모름 | FIXED |
| `P-ALEX` | Alex Han / Integration Developer | Source를 신뢰하는 개발자 | 숨은 Community Rule이 Requirement로 승인됐다는 사실을 앎. 범죄 확정 인지 아님 | FIXED |
| `P-GRACE` | Grace Yoon / Horizon Program Manager | 고객사 담당 PM | Historical Exception 승인/종결에 관여. 고의 범죄 인지 범위는 미정 | FIXED / UNKNOWN |
| `P-DANIEL` | Daniel Park / Internal Control Analyst | 이전 회사 직원 `E-18419` | Foundation 관련 거래 조사 중 Horizon Ridge 사고에서 사망 | FIXED |
| `P-SAMUEL` | Samuel Kwon / Horizon Foundation 이사 | 사진 속 참석자, 재단 간부 | 폐쇄적 조직의 핵심 인물; 구체적 범죄 직접 지휘 여부는 미정 | FIXED / UNKNOWN |
| `P-SECURITY` | Foundation 보안책임자 | 사건 당일 사진·동선의 단서 | 사건 당일 동선의 관계자, 이름/유죄 미정 | PROPOSED |

**Daniel 키**: Legacy PeopleCore `E-18419`, Triply `T-55291`, CareBridge `P-88114`, PayFlow/Insurance 참조 `B-44210`, Global Person `P-004217`. `P-DANIEL`은 콘텐츠 저작용 ID이며 `P-004217`은 게임 내 Global Person ID다. 이 둘을 혼동하지 말 것.

## 3. 조직·장소·사건

| 내부 ID | 표현 | 설명 / 비고 |
|---|---|---|
| `O-HORIZON` | Horizon Group | 계열사 통합 프로젝트 고객 |
| `O-HOLDINGS` | Horizon Holdings | 공식 상위 지주사 |
| `O-COMMUNITY-TRUST` | Horizon Community Trust | 재단 관계자의 지배권 연결 구조(법적 형태 미정) |
| `O-FOUNDATION` | Horizon Foundation | 대외 CSR/복지 조직; 실제 폐쇄적 권력 네트워크의 중심 |
| `O-NORTHSTAR` | Northstar Quality Services | 표면상 독립 외주 QA, 실제 Horizon 영향권 |
| `O-BF-CONSULTING` | Bright Future Consulting / BF Consulting | 벤더 유사성 대상. 완전 동일 법인 여부는 검증 대상 |
| `O-NEW-PATH` | New Path Logistics | 커뮤니티 파트너 네트워크 |
| `O-HORIZON-LIVING` | Horizon Living | 커뮤니티 파트너 네트워크 |
| `LOC-RIDGE` | Horizon Ridge (`HRDG-01`) | 리더십·웰니스 연수 시설, 10월 17일 사고 발생 |
| `LOC-WELL-ANNEX` | Foundation Wellness Annex (`HF-WELL-03`) | 관리 의료재고 목적지 |
| `EV-OCT17` | Horizon Ridge Incident | 10월 17일, 사망 1명·부상 여러 명, 당국 조사 실시 |
| `EV-AWARD-2021` | Leadership Awards 2021 | 인물 관계 복선 사진 |
| `PRJ-ONE-HORIZON` | ONE HORIZON | Global Entity/Identity/Vendor Consolidation |

### 지배 관계 유의

최종 Narrative Reveal은 **재단 핵심 세력이 Trust/이사회 등으로 Horizon 그룹의 실질 지배력을 행사한다**는 것. 공개 사이트에 재단 단독 소유지분 100%가 반드시 등장할 필요는 없고 실제 법제도와 충돌하는 복잡한 소유 설명도 피한다. 게임은 **가상 법체계** 혹은 법률 자문을 통해 구조를 최종 확정해야 한다.

## 4. 시간축 / 사건 연도 가안

> 기존 원문에서 `October 17`은 날짜만 확정. 아래 `2021`은 Migration이 2022–2024에 걸쳤다는 이전 설정과 맞추기 위한 **PROPOSED YEAR**이다. 날짜를 바꾸면 모든 Ticket/사진·사건 메타데이터를 함께 바꿀 것.

| 시간 | 사건 | 증거 및 정확도 |
|---|---|---|
| 2019 | Foundation Gala, Samuel·Grace·Daniel 동일 행사 사진 | 장소 동석만 증명 |
| 2021 (사고 이전) | Leadership Awards 사진 | 시점은 촬영/게시 구분해야 함 |
| 2021-10-12 | Daniel의 `Irregular Vendor and Foundation Transactions` 케이스 생성 | Archive metadata |
| **2021-10-16** | PeopleCore상 Daniel 퇴사 효력일 | 실제 사전 퇴사 여부 불분명, 소급 변경 의혹 |
| **2021-10-17** | Horizon Ridge 행사, 대략 38명 이동, 공식 사고와 Daniel 사망 | 사망 사실 FIXED / 구체 시각 가안 |
| 2021-10-17 22:48 | Daniel 배지 Building B 출입 | Timeline QA 샘플 |
| 2021-10-17 23:06 | 긴급사고 발생 | Timeline QA 샘플 |
| 2021-10-17 23:11 | 의료 이벤트 생성 | Timeline QA 샘플 |
| 2021-10-17 23:18 | Foundation 차량 출차 | Timeline QA 샘플 |
| 2021-10-18 00:14 | 병원이송 | Timeline QA 샘플; 실제 사망 시간으로 단정 금지 |
| 2021-10-18 | Daniel 내부통제 케이스 종료; 사후 정정 시작 | 종료자/지시자 미정 |
| 2021-10-18~24 | HR·출장·재무·의료 기록의 개별 Correction | 일부만 의도적 조작 가능 |
| 2022 / 2023 / 2024 | PeopleCore / PayFlow / Triply 각각 다른 환경/시점의 Migration | 같은 단일 Batch 가설 배제용 |
| 현재 캠페인 | ONE HORIZON 최종 통합 QA | 세부 시작일 미정 |

**중요**: 과거 Migration(2022~2024)과 현 프로젝트의 통합 시험(2026 가정)은 **서로 다른 계층**이다. 2022/23/24에는 제품별 레거시 이전, 현재에는 Cross-system Global Identity 통합을 진행한다. 한 번의 Migration을 네 번 다른 날짜로 표현하지 말 것.

## 5. '무엇이 사실인가' 구분

| 주제 | 플레이어가 확인하는 자료 | 확인 가능한 사실 | 아직 단정 불가 |
|---|---|---|---|
| October 17 | Travel·HR·PO·보험/안전 요약 | 시설 사고와 Daniel 사망이 공식 기록됨 | 사건 전 과정/고의 방화 |
| Daniel | Global ID, HR termination, 보험 코드 | 데이터상 퇴사일과 사망사건이 서로 충돌 | 사고사가 아닌 타살 확정 |
| Vendor | 공통 주소군/계좌군, Daniel REJECT 기록 | 업체 관계가 의심되고 거래 검토가 있었다 | 모든 업체가 동일 법인/범죄단체 |
| Foundation | 관리자 룰/행사 사진/Ownership | 재단 네트워크가 인사와 구매 결정에 깊이 개입 | 모든 회원이 조직적 범죄 공모 |
| Medical | 재고 원장, 외부 Transfer | 일부 재고가 정상 환자 사용으로 설명되지 않음 | 실제 불법 마약 유통의 전체 경로 |
| Labor | HR/SSO/출장/사진 불일치 | 일부 참가자 계정 접근·이동 정보가 비정상 | 강제 노동/인신매매의 모든 피해·가해 사실 |
| Grace | 예외 승인, 사진, 사건 당일 접점 | 기록 종결 권한/재단 인적 교류 | 살해 명령 또는 전말 인지 |
| Mina | 이전 QA 철수 경고, Review | 억제적 행동과 보호 동기가 공존 | 범죄 공범 여부 확정 |

## 6. 감사·수사·권한 개연성

- **외부 감사**: 모든 시스템을 포괄적으로 전수 조사하는 기관이 아님. 회계감사 중요성과 과업 범위가 다르며, 인명 관련 사건 조사와 직접 동일시하지 않는다.
- **내부 감사/컴플라이언스**: 일부 지적 이력·종결 사유가 존재해야 한다. '한 번도 발견 못 했다'라고 쓰지 않는다. 특정 이슈는 충분한 근거 부족, 범위 제한, 예외 승인 등으로 닫혔다.
- **수사기관**: 당시 시설 안전사고와 사망을 확인/조사했다. 모든 고용/벤더/종교 네트워크 관련 관계를 확인하지 못했을 수 있다. 새로운 증거는 재조사 가능성을 만들지만 반드시 최초 수사가 부실했다는 뜻은 아니다.
- **외주 QA 권한**: 기본 읽기전용 + 제한된 테스트 계정/스냅샷 + 필요한 메타데이터. 운영 ERP 전수 조회, 실제 의료 원장 열람, 인사정보 무차별 검색은 **금지**. 모든 민감 정보가 QA 데이터로 드러나는 장면은 테스트셋 구성, 마스킹 누락, 승인된 현안 조사 등 반드시 정당한 경로를 설명한다.
- **행위의 동기**: Ticket 해결을 위한 Source/Target 검증, 고객에게 승인받은 예외 사유 확인, 릴리스 데이터 품질·개인정보 리스크 보고 등으로 제한. QA가 사설 수사를 자처하거나 위법한 유출을 수행하지 않는다.

## 7. 절대적 서사 가드레일

1. 사진의 **동석 = 공모**가 아니다. 이미지의 EXIF 시간/위치는 파일 변경·시간대 오류 가능성을 검증해야 한다.
2. `No Bug`는 QA 관점의 기술적 판단일 뿐, 회사 정책의 적법성·정당성의 보증이 아니다.
3. `Known Issue`나 `Accepted Risk`는 QA 결과와 구분해, 누가 언제 어떤 범위에서 수락했는지 Audit Trail이 있어야 한다.
4. `DB-01`은 **복리후생/보험 정산 코드**로 사용한다. 응급 처치 코드가 아니다. CareBridge에서 노출 시 인터페이스의 `Benefit Settlement` 구획에 나타나야 한다.
5. 사망 1명/부상 여러 명이 공식 사실이라면, `Major Incidents: 0`은 별도의 통계 범위/분류/중복 제거 규칙 탓에 잘못됐거나 제외되어야 한다. **전체 공적 사고 기록이 0**이라고 표현하지 않는다.
6. `퇴사 후 급여 4개월`에는 미지급 임금/유족 보상/정산/수정 지연이라는 합법적 설명도 가능하다. 분석 없이 바로 범죄라고 규정하지 않는다.
7. 국제이주·인신매매 정황에서는 피해자를 범죄 도구나 충격 소재로만 소비하지 않도록 신원과 자율성 문제를 구체적으로 다루며, 불필요한 폭력/성적 착취 묘사는 하지 않는다.
8. 약물의 제조·밀매·통제 실행에 대한 실용적 지침은 스토리 콘텐츠로 만들지 않는다. 플레이어는 **비용/수량/승인/계정 로그의 모순**을 다룬다.

## 8. 진실의 역설

- **진짜 소프트웨어 버그**: 이미지 Crop, 숫자 표시 누락, Mapping/Timezone/Permission 구현 오류.
- **데이터 무결성 문제**: 상이한 출처의 정정 이력, 사망과 퇴사의 불일치, 사고 참조 누락.
- **정상적으로 구현된 제도적 문제**: Community Alignment와 승진, Community Partner Override, 관리자 통제 계정, 재단을 향한 우대 정책.

엔딩의 메시지 `Everything is working as intended`는 마지막 범주의 시스템적 모순을 강조한다.


<!-- END 02_NARRATIVE_CANON.md -->

---

<!-- BEGIN 03_PLAYABLE_TICKETS.md -->

# NOTHING WRONG — 플레이 가능 캠페인 Ticket 명세

## 0. 공통 콘텐츠 규칙

각 Ticket은 `업무 의뢰 → 정상 동작 확인 → 재현 → 증거 → QA 결론 → Review`로 완결되어야 한다. 각 카드에는 정상 UI/데이터가 버그보다 더 많아야 하며, **스토리 단서와 QA 정답은 별개 필드**로 유지한다.

**Ticket Outcome**: `BUG`(기술 버그), `NO_BUG`(정상), `DOC_GAP`(요구사항 누락), `DATA_INTEGRITY`(상태·마스터 충돌), `INCONCLUSIVE`(확증 부족). `WORKING_AS_DESIGNED`는 `NO_BUG`의 리뷰 사유지 기업 정책의 면죄부가 아니다.

**Evidence**: 정답 핵심 속성/조건을 담은 상태 캡처. 단순 해당 화면 스크린샷 1장만으로 항상 만점이 되지 않는다.

**공통 완료 조건**: (a) 관련 시나리오 실행, (b) 올바른 분류 선택, (c) 해당 Outcome에 필요한 증거/No Issue 판단, (d) 리뷰 반환, (e) NarrativeClue 발견 상태 갱신. 틀린 답변도 다시 시도할 수 있게 하고 메인 서사 진행은 막지 않는다.

## ACT 1 — ROUTINE (NW-001~005)

| ID / 시스템 | QA 의뢰와 실제 조작 | 정답 / 재현 조건 | 증거 / 자연스럽게 보이는 Clue | 완료 후 경험 |
|---|---|---|---|---|
| **NW-001 / Shoply** | Checkout CTA Regression. 기본 계정으로 상품→카트→Checkout 열기 | `BUG`, 데스크톱에서 Primary 버튼이 Secondary 스타일. 정상 결제 동작은 유지 | Checkout 화면 캡처; Narrative 없음 | Report/Evidence/Severity 학습 |
| **NW-002 / Shoply** | Cart 수량 1→2→3 변화, 단가 $30과 Subtotal 비교 | `BUG`, Qty=2에서 $50, 기대 $60. 다른 수량은 정상 | Qty=2와 가격/합계 동시 표시; `C001` 테스트 회사 `Horizon Community Services` | 숫자 검증 |
| **NW-003 / PeopleCore→Horizon ID→Shoply** | 프로필 Tier 소스와 쇼핑 계정 동기화 비교 | `BUG`, Source `STANDARD`, Target `PREMIUM` | 두 상태 나란히 캡처; `C002 Community Tier` | 간단한 Source/Target 사고 도입 |
| **NW-004 / CMS→Portal** | `IMG001` 행사 사진 원본/이관 썸네일 비교 | `BUG`, 오른쪽 인물 얼굴이 Crop | 원본/변환 비교, 넓은 사진 안의 Grace·Samuel·Daniel(현재 미표기) | 이미지 QA / 인물 관계 복선 |
| **NW-005 / PeopleCore/PayFlow View** | 급여 요약 합계 검증, Details 펼치기 | `BUG`는 계산이 아니라 **공제 항목 미표시**. 5200−410−190−260=4340 맞음 | Summary와 Detail 비교; `C003 Community Contribution` | 조건/원인 분류, Act 1 Performance Review |

## ACT 2 — OCTOBER 17 (NW-006~009)

**새 기능**: Source/Target Compare, 이관 기록/필터. 사용자에게 '공통 Migration'을 자연스럽게 의심하게 만들되 확답을 주지 않는다.

| ID / 시스템 | QA 의뢰와 조작 | 정답 / 재현 조건 | 증거 / Story Clue | 서사 역할 |
|---|---|---|---|---|
| **NW-006 / Shoply Legacy→Next** | 15개 역사 주문 Source/Target 비교, 날짜 필터 | `BUG`: 10월 17일 원본 `COMPLETED` 일부가 Target `CANCELLED/ABSENT` | 17일 전후 정상 행 + 비정상 행, `C004` Oct 17 | 날짜 패턴 첫 등장 |
| **NW-007 / Triply** | Outbound/Return 매핑 검증, Legacy↔Next 비교 | `BUG`: 소스에 남은 일부 return segment가 Target에서 누락. **Target 38 outbound / linked return 0**; Source에도 일부 참가자의 귀환 정보는 원래 없음 | Source 정상 segment 및 Target 빈 연결; `C005 HRDG-01 / 38 people` | 동일 날짜/인원 수 반복. 0은 Target 표시값임 |
| **NW-008 / PeopleCore** | Training Leave History Source/Target 정합성 | `BUG`: 과거 유효 레코드 일부가 Target History에서 누락 | Before/After 상태 및 `C006 E-18419 Daniel`, 38 leave / 12 resign records | Daniel 첫 등장 |
| **NW-009 / PeopleCore→PayFlow** | 퇴사 이벤트가 이후 지급/정산에 반영되는지 검증 | `DATA_INTEGRITY`: Daniel 10/16 퇴사·그 후 거래의 성격/상태 불일치. **퇴사 뒤 지급만으로 오류 확정 불가**, 지급 유형을 비교해야 함 | 양쪽 기록과 transaction type. `C007 Daniel 반복` | 제출 후 고객사 `KNOWN ISSUE` 처리(기술 결과와 업무상 처분 분리) |

**ACT 2 체크포인트**: 플레이어에게 임의 추적 대상 검색을 제공하지 않고, `원본 스냅샷 문제인가?`라는 QA 가설을 제안할 수 있다.

## ACT 3 — SOURCE DATA (NW-010~014)

**새 기능**: Global Entity View, Trace, 수정자/시각/사유 Code를 담은 **허용된 Audit Metadata(원문 기록 열람 아님)**.

| ID / 시스템 | QA 의뢰와 조작 | 정답 / 재현 조건 | 증거 / Story Clue | 서사 역할 |
|---|---|---|---|---|
| **NW-010 / Horizon ID** | Person matching 후보 4개의 키 값 비교 및 Merge 여부 선택 | `NO_BUG`: E-18419/T-55291/P-88114/B-44210는 동일 인물 P-004217 | 이름·해시·부분 이메일·원본 Ref가 같은 조건 | 다른 시스템의 Daniel이 동일 인물임을 확정 |
| **NW-011 / Integration Tool** | 이전 3개 Migration의 Root Cause 분류. 배치 시각 비교 | `NO_BUG` on global orchestrator; `SOURCE_DATA` 이슈로 전달. Migrated 2022/23/24 | Migration history; Alex의 기술적 반박 | 공통 Batch 가설 반증 |
| **NW-012 / QA Audit Metadata** | Source Snapshot의 `modifiedAt`/correction marker 불일치 확인 | `BUG`는 수정 Timestamp Export 매핑; 원본 Correction은 실제 기록. 내용 자체의 범죄성은 미확정 | HR/TRV/FIN/MED 수정 계정·Oct18/19/21/24; `C009 DATA_CORRECTION` | 분산된 사후 정정 패턴 |
| **NW-013 / Triply** | Legacy `HRDG-01` 코드 Target 명칭 매핑 검증 | `BUG`: 일부 행에서 지명 blank | `Horizon Ridge – Leadership & Wellness Center`; `C010` | 장소에 이름 부여 |
| **NW-014 / CMS** | `IMG002` 행사 사진의 이관 Album Category 비교 | `BUG`: Expected `Leadership Program`, Target `Community Event` | 이미지 배경 배지/심벌·장소·날짜(메타데이터는 검증 필요) | Act1 사진과 상징 연결 가능 |

**ACT 3 체크포인트**: 첫 명확한 가설 변경은 **'이관이 오류를 만들었다' → '원본에 이미 충돌이 있었다'**이다. 범죄 확정이 아니다.

## ACT 4 — ZERO INCIDENT (NW-015~019)

**새 기능**: Historical Reference와 Case Notes. 시나리오 NW-018 완료 뒤 처음으로 의미 연결 화면을 활성화한다.

| ID / 시스템 | QA 의뢰와 조작 | 정답 / 재현 조건 | 증거 / Story Clue | 서사 역할 |
|---|---|---|---|---|
| **NW-015 / CareBridge Benefits→PayFlow** | 긴급 복리후생 정산금액과 이체액 비교 | `BUG`: Settlement summary 표현/매핑 불일치. `DB-01`은 별도 **benefits claim type**이며 아직 해설 숨김 | Claim line `P-004217`, date 17~18 Oct, code `DB-01` | Daniel 관련 혜택 코드 복선 |
| **NW-016 / Procura** | Emergency PO의 Destination mapping 검증 | `BUG`: 특정 PO의 장소 값 blank | 구매종류·시각·Ridge 목적지 | 사고 규모 의문 발생 |
| **NW-017 / Compliance Dashboard** | 월간 Incident 0 vs Orphan Reference 검증 | `DATA_INTEGRITY`: Dashboard 필터 계산 자체는 현재 정의에 맞지만 `INC-1017` 원본 참조 누락/분류 충돌 | `INC-1017/DUPLICATE`와 공식 통계의 **범위 차이** | '사고가 있었나?' 가설 진입 |
| **NW-018 / Insurance Mapping** | Legacy Benefit Code Description 쌍 중 스왑 찾기 | `BUG`: Code description swapped; `DB-01=Death Benefit` 원본 기준 확인 | 참조표 + NW-015의 코드 재해석 | Daniel 사망 Reveal / Case Notes Open |
| **NW-019 / Cross-System Defect** | Daniel의 HR·Travel·Benefit·Official Incident 요약 연결 후 Quality Issue 작성 | `DATA_INTEGRITY`, 위험도 HIGH/CRITICAL 제안 가능. 코드상 퇴사 자체는 승인 정정일 수 있어 **독립적으로 불법/오류 확정하지 않음** | HR exit Oct16 + 10/17 incident + benefit + approved correction metadata | Grace가 업무적으로 예외 종결, 플레이어에게 리뷰와 예외 승인권의 차이 인식 |

**ACT 4 공식 사건 문서**: `Horizon Ridge Facility Incident / Accidental / One fatality / Multiple injuries`. 이것은 수사기관의 존재를 없애는 반전이 아니라 **사건에 대한 기존 공적 인지**를 보여주는 자료다.

## ACT 5 — THE FOUNDATION (NW-020~026)

**새 기능**: Entity Relationship/Reference Catalog, 이미지 메타데이터 비교, 현재 사업 룰 조회(권한 내). `NO_BUG`의 비중을 높인다.

| ID / 시스템 | QA 의뢰와 조작 | 정답 / 재현 조건 | 증거 / Story Clue | 서사 역할 |
|---|---|---|---|---|
| **NW-020 / Procura** | 유사 벤더 Auto-Merge false positive 검사 | `NO_BUG`: 여러 alias/affiliate 기록의 매칭 근거가 허용 임계값에 맞음. **동일 법인이라고 단정 안 함** | 등록주소군·대리인·연락처, Daniel의 과거 `REJECTED` | Daniel의 업무와 재단 관련 벤더 연결 |
| **NW-021 / Procura Rules** | Preferred Vendor 5% vs 특정 Vendor 18% 할인 확인 | `NO_BUG / WORKING_AS_DESIGNED`: `COMMUNITY_PARTNER_OVERRIDE` 승인 룰 | 기본 룰과 예외 룰 비교 | 기술적 정상과 제도적 특혜 구분 |
| **NW-022 / Foundation Portal** | Tablet Gallery 깨짐 재현, 사진 확대/메타데이터 비교 | `BUG`: 반응형 이미지 레이아웃. `IMG003~005`는 서사 복선 | Samuel·Grace·Daniel 동석, 배지, 행사 시점 | 인물 관계 재해석(공모 확정 아님) |
| **NW-023 / PeopleCore** | 승진 조건 A 등급/근속 4년인데 탈락한 사례 테스트 | `DOC_GAP`: 실제 백엔드 추가 룰 `CommunityAlignment≥70` 존재. **무조건 INVALID가 아니라 문서 누락 이슈는 유효** | 공개 Requirement vs 승인 Ruleset | 'Working as Designed'의 첫 충격 |
| **NW-024 / CareBridge Inventory** | 입고 1200, 환자 사용 380, 폐기 24, 표기 잔량 121 검증 | `BUG`: 675 단위 **Transfer**가 잔액 계산/화면에서 누락. 원장 기준 `1200-380-24-675=121`은 맞음 | Hidden transfer `HF-WELL-03`, SKU-MD204 | 투약 기록 밖의 이동과 재고 UI 결함 구분 |
| **NW-025 / RouteOne** | `SKU-MD204` shipment의 recipient region 확인 | `BUG`: 우편/지역 코드 mapping | Destination `HF-WELL-03 → Foundation Wellness Annex`, restricted medical category | 약품의 최종 사용/불법성은 미확정 |
| **NW-026 / PeopleCore+Triply+ID+PayFlow** | 해외 배치 직원 위치·급여 법인·계정 동기화 테스트 | `BUG`는 Country/Payroll Entity Mapping. `ACTIVE / no login / no return / admin-controlled contact`는 별도 모니터링 정황 | `IMG006` 집단 사진 vs 프로필 인물, Opportunity Program | 신원 자율성 및 착취 정황 |

**ACT 5 체크포인트**: QA가 '이상한 데이터를 찾았다'에서 '유효한 정책이 사람을 해치는가?'라는 질문으로 이동한다. 의료·인신 관련 이슈는 무죄추정과 증거 수준을 유지한다.

## ACT 6 — DANIEL'S LAST CASE (NW-027~030)

**새 기능**: Archive Meta, Timeline Compare, Org Hierarchy. NPC 독백보다 플레이어가 자료로 관계를 직접 연결하게 한다.

| ID / 시스템 | QA 의뢰와 조작 | 정답 / 재현 조건 | 증거 / Story Clue | 서사 역할 |
|---|---|---|---|---|
| **NW-027 / Document Archive** | 테스트 권한으로 볼 수 있는 이전 케이스의 `Viewer` attachment preview 접근 검증 | `BUG`: 승인 대상의 문서/미리보기가 권한 Rule과 다르게 거부됨. **기밀 케이스 전체 원문 열람 불가** | Daniel의 Case 메타: created 10/12, closed 10/18 | 사망 후 케이스 종료 |
| **NW-028 / Document Image** | 사내 자료 이미지 Orientation/Thumbnail 오류 재현 | `BUG`: EXIF orientation 누락, 이미지 회전 | `IMG007` Daniel·Grace·Samuel·보안담당자, 사고 이전 metadata | 사고 전 인물 접점 |
| **NW-028B (옵션) / Access Timeline** | 여러 로그의 UTC↔현지시각 표시를 보정 | `BUG`: 일부 표기 Timezone offset. 보정 이후에도 위치 불일치 | 출입·의료·차량·이송 Timeline | 살인은 **가설 선택 가능, 정답 확정 불가** |
| **NW-029 / Organization Master** | 공개 Org Tree와 Source control hierarchy 값 비교 | `NO_BUG / DOC_GAP`: 상위 신탁 지배관계는 Source에 존재하지만 UI가 표시 범위를 제한 | Holdings→Community Trust→Foundation 지배력 연결 | Foundation 권력망 Reveal |
| **NW-030 / Organization Master** | Northstar vendor/customer record parent chain 유효성 확인 | `NO_BUG`: Northstar가 Horizon 영향권임을 매핑 데이터가 보여줌 | Northstar→Services Holdings→Trust→Foundation | 플레이어 회사와 네트워크 연결 |

## NW-FINAL — ONE HORIZON Release Validation

- **표면 업무**: Identity / Payroll / Travel / Procurement / Medical / Org 영역에 제한된 Coverage Budget을 배치하고 릴리스 위험을 평가.
- **플레이 선택**: 체크할 영역, `SHIP / HOLD`, 리스크 별도 코멘트, Evidence 보존/정식 이관 여부(엔딩 정책은 미확정).
- **기술 결과**: 주요 컴포넌트의 Regression은 PASS일 수 있지만, `DATA_INTEGRITY`, `DOC_GAP`, `POLICY/ETHICS_RISK`는 개별 기록으로 남는다. **0 blocking defect가 0 risk를 뜻하지 않음**.
- **최종 표시**: `VALIDATION COMPLETE / SYSTEM STATUS: NORMAL / Everything is working as intended.`

## 필수 서사 게이트

| 게이트 | 최소 획득 정보 | 실패/힌트 처리 |
|---|---|---|
| G1 날짜 패턴 | NW-006/007/008 중 2건 + 날짜 | 진행 차단 금지, Recent Tickets 참조 표시 |
| G2 Identity | NW-009 반복 인물 + NW-010 Global ID | ID Compare 튜토리얼 허용 |
| G3 Source Error | NW-011 Migration 별도 시점 + NW-012 수정 이력 | 잘못된 가설 선택 후 비교 재시도 |
| G4 Incident | Ridge 장소 + Emergency 기록 + Compliance 참조 | 공식 사고 설명 자료는 NW-019 Review 시 필수 제공 |
| G5 Daniel Death | Benefit `DB-01` + 보험 Codebook + HR 기록 | NW-018 이후 연결 안내(스포일러 제한) |
| G6 Foundation Network | Vendor cluster + special rule + Relationship evidence | 일부 이미지 선택 Clue 없어도 진행 |
| G7 Control | Org ownership/control + Northstar mapping | 법적/실질적 지배 차이 설명 |

## 스토리와 스코어 독립성

- 버그 찾기 점수와 미스터리 해석 점수는 분리.
- 틀린 Root Cause/Severity/가설은 적정 피드백을 주되 무조건 Game Over 금지.
- 사진을 놓친 플레이어에게 NW-022/028에서 재학습 기회를 준다.
- **No Issue Found**는 `NO_BUG`에 대해 완전한 정답이 될 수 있으며 `WORKING_AS_DESIGNED`가 드러내는 윤리적 불편함과 충돌하지 않는다.


<!-- END 03_PLAYABLE_TICKETS.md -->

---

<!-- BEGIN 04_SCENARIO_ENGINE_CONTRACT.md -->

# NOTHING WRONG — Scenario Engine / Data / Review Contract

## 목적

개발 AI가 `03_PLAYABLE_TICKETS.md`의 각 Ticket을 독립적이고 재현 가능한 콘텐츠로 구현하기 위한 최소 계약. **지금 당장 코딩하라는 지시가 아니라 구현 시 준수할 명세**다.

## 시스템 경계

```text
Game Shell (Dashboard, Inbox, Career, Reports)
  ├── Ticket/Requirement
  ├── QA Workspace (Account, Locale, Viewport, Source/Target, Trace)
  │    └── Fake Product(s): Shoply / PeopleCore / Triply / Procura / etc.
  ├── Scenario Runtime (Fixtures + Conditions + Mutations)
  ├── Evidence / Case Notes
  ├── Report / Deterministic Reviewer
  └── Campaign Progression / Narrative Clues
```

- 별도의 실제 외부 사이트/운영 ERP/API 호출 없음. UI 안에서 Fake Product가 실제로 동작하는 React 컴포넌트.
- 정상 제품 Rule이 우선. `Scenario Mutation`은 기술 오류만 발생시키고 **범죄/정책 정황의 정합 데이터는 Base Fixture**에 보관.
- 시나리오 간 Entity, 사건 시점, 거래, 사진 식별자는 **Canonical Dataset**에서 공유. 다른 Ticket에서 같은 인물의 생년/이름·이벤트 시각이 바뀌면 안 됨.
- 같은 Seed/Action Log를 Replay하면 같은 상태/증거/Review가 나와야 함. 런타임 LLM 판정 없음.
- 사용자가 실제 원본 ERP 자료를 넣도록 요구하지 않는다. 모든 데이터는 픽션/테스트 데이터다.

## 디렉터리 제안

```text
src/
  game/domain/{ticket,scenario,evidence,report,narrative}.ts
  game/engine/{scenarioRuntime,mutationResolver,reviewEngine}.ts
  game/data/{entityBible,normalRules,fixtureFactory}.ts
  products/{shoply,peoplecore,triply,procura,...}/
  scenarios/campaign/NW-001.json ... NW-030.json
  assets/narrative/{images,metadata}.json
  ui/{gameShell,fakeBrowser,qaWorkspace,reportBuilder,caseNotes}/
  persistence/
tests/{unit,scenario,e2e,narrative}/
```

## 최소 TS 타입 예시

```ts
export type TicketOutcome =
  | 'BUG'
  | 'NO_BUG'
  | 'DOC_GAP'
  | 'DATA_INTEGRITY'
  | 'INCONCLUSIVE';

export type EvidenceType =
  | 'SCREENSHOT'
  | 'SOURCE_TARGET_COMPARE'
  | 'TRACE'
  | 'RECORD_SNAPSHOT'
  | 'IMAGE'
  | 'IMAGE_METADATA'
  | 'DOCUMENT_FRAGMENT'
  | 'AUDIT_METADATA'
  | 'TIMELINE';

export interface Scenario {
  id: string;                    // NW-001
  act: number;
  ticket: TicketDefinition;
  productIds: string[];
  fixtureId: string;
  initialContext: Record<string, unknown>;
  mutations: MutationDefinition[];
  expectedFindings: FindingDefinition[];
  evidenceRules: EvidenceRule[];
  narrativeClues: NarrativeClueDefinition[];
  review: ReviewConfig;
  unlocks: string[];
}

export interface TicketDefinition {
  title: string;
  senderEntityId: string;
  briefing: string;
  requirements: Array<{id: string; text: string}>;
  inScope: string[];
  permittedDataViews: string[];
}

export interface MutationDefinition {
  id: string;
  type: 'WRONG_STYLE' | 'WRONG_NUMBER' | 'HIDE_ELEMENT'
    | 'WRONG_STATE' | 'WRONG_ACTION' | 'WRONG_CALCULATION'
    | 'CROSS_SCREEN_MISMATCH' | 'WRONG_METADATA';
  target: string;
  conditions: Array<{field: string; op: 'EQ'|'NEQ'|'IN'|'GTE'|'LTE'; value: unknown}>;
  payload: Record<string, unknown>;
}

export interface FindingDefinition {
  id: string;
  outcome: TicketOutcome;
  target?: string;
  severity?: 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL';
  expected: string;
  actual: string;
  reproductionConditions: Record<string, unknown>;
  caveats?: string[];
}

export interface EvidenceRule {
  findingId: string;
  allowedTypes: EvidenceType[];
  requiredContextKeys: string[];
  minimumCount: number;
}

export interface NarrativeClueDefinition {
  id: string;                 // C004, IMG001 etc.
  source: EvidenceType | 'DIALOGUE';
  entityIds: string[];
  exposure: 'MANDATORY' | 'OPTIONAL' | 'MISSABLE';
  acquisitionCondition: string;
  initialMeaning: string;
  reinterpretAfter?: string[];
}

export interface ReviewConfig {
  expectedOutcomes: TicketOutcome[];
  scoringWeights: {detection: number; reproduction: number;
    evidence: number; classification: number};
  reviewOverride?: {
    actorEntityId: string;
    afterReport: 'ACCEPTED_EXCEPTION' | 'ESCALATED' | 'NO_ACTION';
    message: string;
  };
}

export interface NarrativeState {
  knownEntityIds: string[];
  foundClueIds: string[];
  hypotheses: Record<string, 'SUPPORTED'|'REJECTED'|'UNKNOWN'>;
  caseNotesUnlocked: boolean;
  relationshipEdges: Array<{sourceId: string; targetId: string; evidenceIds: string[]}>;
}
```

> 기존 프로젝트 엔진에 타입/명명 규칙이 이미 있다면 그것을 우선한다. 원칙(데이터·도메인 분리)을 보존하면서 호환하라. 브랜드명 접두어를 타입에 무조건 추가하지 말 것.

## 샘플 시나리오 1 — NW-005 (UI 오류 + Narrative Clue)

```json
{
  "id": "NW-005",
  "act": 1,
  "productIds": ["peoplecore", "payflow"],
  "fixtureId": "PAYROLL_SAMPLE_COMMUNITY_01",
  "ticket": {
    "title": "Payroll deduction display mismatch",
    "senderEntityId": "P-MINA",
    "briefing": "급여 요약의 공제 항목 및 실수령액 정합성을 검증하세요.",
    "requirements": [
      {"id":"R1", "text":"급여 상세 공제 항목은 요약에 모두 표시되어야 합니다."},
      {"id":"R2", "text":"실수령액은 총액에서 모든 공제액을 뺀 금액입니다."}
    ],
    "inScope": ["payroll.summary", "payroll.detail"],
    "permittedDataViews": ["masked_sample_payroll"]
  },
  "initialContext": {"account":"SAMPLE_BASIC", "viewport":"DESKTOP"},
  "mutations": [
    {"id":"M-NW005-01", "type":"HIDE_ELEMENT", "target":"payroll.summary.deduction.community",
     "conditions": [{"field":"account", "op":"EQ", "value":"SAMPLE_BASIC"}],
     "payload":{"hidden":true}}
  ],
  "expectedFindings": [{
    "id":"F-NW005-01", "outcome":"BUG", "target":"payroll.summary.deduction.community",
    "severity":"LOW", "expected":"Community Contribution 260이 summary에 표시된다.",
    "actual":"상세에 존재하지만 summary 행에서 누락된다.",
    "reproductionConditions":{"account":"SAMPLE_BASIC"}
  }],
  "evidenceRules": [{
    "findingId":"F-NW005-01", "allowedTypes":["SCREENSHOT","RECORD_SNAPSHOT"],
    "requiredContextKeys":["summary","detail","account"], "minimumCount":1
  }],
  "narrativeClues": [{
    "id":"C003", "source":"RECORD_SNAPSHOT", "entityIds":["O-FOUNDATION"],
    "exposure":"MANDATORY", "acquisitionCondition":"open(payroll.detail)",
    "initialMeaning":"사내 복지·기부 관련 공제 항목",
    "reinterpretAfter":["NW-022"]
  }],
  "review":{"expectedOutcomes":["BUG"],
    "scoringWeights":{"detection":40,"reproduction":25,"evidence":20,"classification":15}},
  "unlocks":["ACT1_CORE_COMPLETE"]
}
```

Normal Fixture 계산: `gross=5200; tax=410; insurance=190; community=260; net=4340`. 원본의 공제 `260`은 사라진 돈이라고 확정하지 않는다. `HIDE_ELEMENT` Mutation만 제거하면 UI는 정상으로 돌아와야 한다.

## 샘플 시나리오 2 — NW-020 (No Bug + 의미 있는 사실)

```json
{
  "id": "NW-020",
  "act": 5,
  "productIds": ["procura"],
  "fixtureId": "VENDOR_CLUSTER_01",
  "ticket": {
    "title": "Duplicate vendor candidate review",
    "senderEntityId": "P-MINA",
    "briefing": "중복 후보가 오탐인지 원본 속성을 비교해 검증하세요.",
    "requirements":[{"id":"R1", "text":"허용 임계값을 넘는 후보군은 관계 검토 대상으로 표시됩니다."}],
    "inScope":["vendor.matching", "vendor.candidate.detail"],
    "permittedDataViews":["masked_vendor_attributes", "approval_summary"]
  },
  "initialContext":{"matchGroupId":"V-GROUP-17"},
  "mutations":[],
  "expectedFindings":[{
    "id":"F-NW020-01", "outcome":"NO_BUG",
    "expected":"관계 검토 대상으로 표시", "actual":"관계 검토 대상으로 표시됨",
    "reproductionConditions":{"matchGroupId":"V-GROUP-17"},
    "caveats":["동일 범죄조직 또는 동일 법인이라고 단정할 수 없음"]
  }],
  "evidenceRules":[{
    "findingId":"F-NW020-01", "allowedTypes":["RECORD_SNAPSHOT"],
    "requiredContextKeys":["matchingSignals","threshold","candidateList"], "minimumCount":1
  }],
  "narrativeClues":[{
    "id":"C020", "source":"RECORD_SNAPSHOT", "entityIds":["P-DANIEL","O-BF-CONSULTING"],
    "exposure":"MANDATORY", "acquisitionCondition":"open(vendor.approvalSummary)",
    "initialMeaning":"과거 검토자가 거래를 반려함",
    "reinterpretAfter":["NW-027"]
  }],
  "review":{"expectedOutcomes":["NO_BUG"],
    "scoringWeights":{"detection":40,"reproduction":25,"evidence":20,"classification":15}},
  "unlocks":[]
}
```

## QA 리포트 판정 규칙

- 기본 점수: `Detection 40 + Reproduction 25 + Evidence 20 + Classification 15`.
- 예외/업무 결정은 **Reviewer Result**와 **Client Disposition**을 별개 필드로 저장한다. 예: QA Valid Data Issue이지만 Client Accepted Risk.
- `NO_BUG`는 정상 동작임을 입증한 비교/Requirement 인용이 필요하다. 아무것도 보지 않고 '문제없음'을 찍으면 낮은 점수.
- `DOC_GAP`는 구현이 정상이라도 요구사항에서 누락된 조건을 보고할 수 있게 해야 한다. NW-023에서 플레이어의 버그 오판을 일방적으로 'INVALID'로 모욕하지 말 것.
- `DATA_INTEGRITY`는 권한 있는 운영 주체가 사실관계 확인/정정할 수 있다. QA가 인적 사고·살인을 법적으로 확정하는 기능 없음.
- 시나리오에서 발견된 `Clue`는 Report 채점과 독립하며 Story 게이트/Case Notes에서 쓰인다.

## 데이터 접근 및 Case Notes 정책

- `TestDataScope`: `SYNTHETIC`, `MASKED_LEGACY`, `AUTHORIZED_RECORD_FRAGMENT`, `UNEXPECTED_SENSITIVE_EXPOSURE` 중 하나.
- `UNEXPECTED_SENSITIVE_EXPOSURE`를 Story에 활용하면 **보안/개인정보 QA 이슈**도 생성해야 하며 플레이어가 무단 복제·외부 공개하는 선택을 강제하지 않는다.
- Case Notes에는 Entity ID, 출처/스냅샷 버전, 그 시점에 플레이어가 알 수 있는 정보만 저장. 캐릭터의 추측을 사실 데이터로 덮어쓰지 않는다.
- 이미지 메타데이터의 `captureAt`과 `uploadedAt`을 분리. EXIF가 반드시 참이라는 UI 연출 금지.
- evidenceId/sourceTicketId/recordId/fixtureVersion/snapshotHash를 제공해 재현 가능한 QA 증거 구성.

## 엔진 테스트 항목

1. Normal fixture에서 Mutation OFF 시 모든 정상 Product Rule 통과.
2. 각 Mutation의 **positive trigger**와 **negative trigger** 검증.
3. 같은 Story Entity의 ID·날짜·명칭은 전체 캠페인에서 일치.
4. Story Clue는 업무 범위 내 행동만으로 획득 가능.
5. Required clue는 미획득 시 다른 합법적 Ticket/요약 힌트로 재접근 가능.
6. No-Bug도 진행과 점수 획득 가능.
7. 사용자 조작 없이 시간을 경과시키는 강제 마이크로타이밍 퍼즐 금지(시각 단서는 타임라인 비교).
8. Fresh Start/Save/Load/Replay에서 동일 Evidence/Review/Progression 재현.
9. 이미지를 제외한 시나리오에서 자산 누락이 생겨도 Game Shell 에러로 끝나지 않음.
10. Review/Client override가 독립적으로 기록되며 QA 결과를 임의 변조하지 않음.


<!-- END 04_SCENARIO_ENGINE_CONTRACT.md -->

---

<!-- BEGIN 05_QA_TEST_PLAN.md -->

# NOTHING WRONG — QA AI 검증 계획 / Acceptance Contract

## QA 목표

이 게임은 실제 QA를 흉내 내는 게임이므로 두 관점으로 검증한다.

1. **제품/기능 QA**: 시나리오 조건·정답·mutation·증거 판정·저장·UI 접근성의 기술적 정확성.
2. **서사/경험 QA**: 평범한 업무에서 단서에 닿는 개연성, 추리의 타당성, 반복되는 자료의 시점·인물 일치, 과도한 스포일러/무리한 결론 방지.

QA가 직접 시나리오의 정답을 새로 지어내면 안 된다. `02_NARRATIVE_CANON.md`, `03_PLAYABLE_TICKETS.md`와 충돌하면 `Narrative Conflict`로 기록한다.

## 필수 테스트 분류

| 영역 | 검증 내용 | 우선순위 |
|---|---|---|
| Schema | Scenario JSON 파싱/타입/Entity ID/Clue 경로 검증 | P0 |
| Base Rules | Mutation OFF 시 정상 업무 로직, 수량/급여/요건 정합성 | P0 |
| Mutation | 조건별 재현 + 비재현, 시나리오 외 제품 오염 방지 | P0 |
| Report | Expected/Actual/Severity/Evidence 평가, No Issue 정답 | P0 |
| Progress | 필수 Clue 접근성·막힘 방지·힌트/재시도·Save/Load | P0 |
| Narrative continuity | 사건일, 사망/퇴사, 인물/ID, 사진 재등장 | P0 |
| Permissions | 외주 QA 권한에 맞는 자료만 열림, PII 마스킹/노출 설명 | P0 |
| Review vs Disposition | QA 판정과 Grace/고객사 Accepted Exception 구분 | P0 |
| Photos | 이미지 내 동일 인물·상징·시간/원본/변환 일관성 | P1 |
| Usability | 1280px 데스크톱과 좁은 화면, 키보드, 스크롤, 읽기 | P1 |
| Narrative perception | Mystery를 너무 일찍 알아채거나 단서를 전혀 인지 못하는 문제 | P1 |
| Performance | 많은 레코드 / 빠른 Ticket 전환 / 중복 이벤트 | P1 |

## ACT별 Exit Criteria

### Act 1 (NW-001~005)
- 신규 저장파일로 시작→Inbox→NW-001→Shoply→Screenshot→Bug Report→Review→Dashboard 복귀 E2E 통과.
- NW-002 Qty=1/2/3에서 2에서만 계산 버그가 노출.
- NW-005 총액/순액 산술상 정상임. 누락은 Summary row만.
- `IMG001` 초반 화면에서 Clue처럼 강조되지 않고 원본/크롭 간 차이 비교 가능.
- 5개 완료 후 첫 Progress Review. Story가 이미 재단 음모를 밝히지 않음.

### Act 2 (NW-006~009)
- Source/Target 비교 기능이 신뢰할 수 있는 양방향 상태를 보여줌.
- NW-007의 `Target 38 outbound / 0 return`과 Source 일부 return 존재가 일관되게 표현됨.
- NW-008 직원 38, 퇴사 12는 전체 데이터 수로 유지(샘플 수와 혼동하지 않음).
- NW-009은 '급여 지속 = 범죄'로 자동 해석하지 않고 지급유형/원천상태 불일치에 대한 QA 결론 요구.
- Daniel 표기/사번이 NW-008과 NW-009에서 같음.

### Act 3 (NW-010~014)
- NW-010의 Merge는 정상. `No Bug` 선택 시 만점 가능.
- 별도 시점의 Migration 때문에 단일 ETL Batch 가설이 부정됨.
- Audit Metadata는 조작내용 원문 전부가 아니라 허용된 timestamp/reason만 제공.
- `IMG002`의 장소·일자·배지는 Canon과 일치. 지나친 '사진=범죄 증거' 연출 없음.

### Act 4 (NW-015~019)
- NW-015의 `DB-01`이 복리후생/보험 정산 코드여야 함. 의료 처치 코드로 표현 금지.
- NW-017의 0은 **해당 Dashboard 분류/범위**에 관한 숫자. 외부 공식 사고/사망 자체가 0이 아님.
- NW-018 `DB-01 = Death Benefit` 밝혀지는 전후 시점에서 스포일러가 없음.
- NW-019 보고서 작성에 필요한 증거가 재방문 가능. 사용자에게 의료 원본 무단 접근 강제 금지.
- Case Notes는 실재 자료와 플레이어 가설의 화면 스타일을 구분.

### Act 5 (NW-020~026)
- NW-020/021에 Bug가 없어도 Review 정답이 가능.
- NW-023 룰 구현이 정상일 때 **요구사항 문서 누락**을 유효한 QA Finding으로 다룸.
- NW-024 원장 산술 `1200−380−24−675=121` 확인. Transfer 표시 누락과 실제 유출 확정은 별개.
- NW-025의 수령인은 Foundation 연계 장소이지만 곧바로 마약 밀매 확정 메시지 없음.
- NW-026은 프로필/단체사진의 동일인 묘사가 외형적 우연보다 충분한 추가 매칭 근거로 보강됨.

### Act 6 / Final
- Daniel은 10/17 사망, Archive Case는 10/18 종료. 이 둘의 사실이 구분되어 표현됨.
- NW-028B 시간대 보정 후 남는 위치 불일치는 **살인 확증이 아니다**.
- 조직도에 법적 소유와 실질 의결/지배력 구분. 주식 100% 소유를 임의 단정하지 않음.
- Northstar 소유관계는 이전 직장 설정과 충돌하지 않고, 업무상 권한 설명에 도움이 됨.
- Final의 `Blocking Defects: 0`과 `Non-blocking data/policy risks` 공존 가능.
- 엔딩 결과는 미확정이므로 Codex 임의로 사실·유죄·살인범을 확정하지 않음.

## 최소 자동 테스트 사례 (Gherkin 형태)

```gherkin
Feature: NW-005 Payroll Summary
  Given normal fixture gross=5200 tax=410 insurance=190 community=260
  When mutation HIDE_ELEMENT is disabled
  Then the summary lists all deductions and the net pay is 4340
  When mutation HIDE_ELEMENT is enabled for SAMPLE_BASIC
  Then the summary hides Community Contribution
  And details still show 260
  And the net pay remains 4340

Feature: NW-010 Correct identity merge
  Given four legacy records with matching canonical person identity
  When the player selects No Issue Found and supplies identity evidence
  Then the QA review is valid
  And the global person view becomes available

Feature: NW-018 Benefit code reinterpretation
  Given the player already observed DB-01 in NW-015
  When the code mapping table is opened in NW-018
  Then DB-01 resolves to Death Benefit
  And no earlier ticket described DB-01 as an emergency medical procedure

Feature: NW-024 Transfer reconciliation
  Given received 1200 administered 380 wasted 24 transferred 675
  Then the correct remaining balance is 121
  When the transfer display is hidden by the scenario mutation
  Then the player can report an incomplete reconciliation view
  And the system does not state that every transferred unit was illicit

Feature: Report disposition separation
  Given a data-integrity finding accepted by the QA reviewer
  When Grace marks it Historical Exception
  Then the QA validity remains recorded
  And the client disposition is separately recorded
```

## 경로 E2E

1. 새 사용자→튜토리얼→NW-001 제출→Review→Saved State 정상.
2. NW-001~010 진행→`October 17`, Daniel 반복→Global Identity 정상 Merge→Source 오류 가설 변경.
3. NW-015 `DB-01` 노출→NW-018 Code mapping→Case Notes Unlock→NW-019 증거 조합→Grace 예외 종결.
4. NW-020 No Bug→NW-023 DOC_GAP→NW-024 재고 원장→NW-025 동일 SKU→NW-026 이주 데이터.
5. NW-027 Case metadata→NW-028 이미지→NW-028B(활성 시)→NW-029/030 지배구조→Final.
6. 필수 사진 선택 Clue를 일부 놓친 상태로도 전체 캠페인 완료.
7. 모든 중간 지점에서 저장/재접속/재시도/다른 답안을 선택하여 엔진 오류·Deadlock 없음.

## 콘텐츠 정적 검사기 요구

각 Scenario JSON에 대해:

- `id`, `ticket`, `fixtureId`, `expectedFindings`, `evidenceRules`, `review` 필수.
- 참조된 `entityIds`, `assetIds`, `recordIds`가 Canon에 존재.
- `MANDATORY` Clue는 테스트 가능한 행동 경로가 있고 불합리한 타 시스템 접근을 요구하지 않음.
- Finding마다 올바른 Evidence 경로 존재.
- 정상 Fixture 기준 재무/수량 계산이 명시된 공식과 일치.
- Timezone: local event time / UTC storage / capture/upload timestamp 혼동 없음.
- 진행 플래그 순환 의존/Deadlock 없음.
- 요구사항과 룰 구현이 다를 때 `DOC_GAP` 여부 검증.
- 모든 Image Asset은 인물/장소/촬영일/업로드일/가시적 표식 Canon 존재.
- 모든 리뷰 결과에 QA correctness와 고객의 업무상 disposition 구분 존재.

## Narrative Human Playtest (필수)

| Gate | 질문 | 이상적인 플레이어 반응 | 실패 신호 |
|---|---|---|---|
| NW-010 | 계속 반복되는 날짜/인물은? 왜? | '10/17, Daniel, Migration 또는 Source 문제 같다' | 이미 전체 사이비 음모를 확신 / 아무것도 기억 못함 |
| NW-019 | Ridge 사건과 Daniel 기록의 충돌은? | '실제 사고가 있었고 고용 기록이 이상하다' | '경찰이 사망을 몰랐다' 오해 |
| NW-026 | Foundation에 대해 확인된 사실과 추측은? | '인사/벤더 영향은 확실, 약품/사람 이동의 범죄성은 의심' | 미확증 범죄를 모두 사실로 받아들임 |
| NW-FINAL | 가장 큰 버그는? | '시스템이 의도한 대로 잘못된 정책을 수행' | 테마가 전달되지 않음 |

## 버그 리포트 서식

```text
Issue ID:
Ticket ID / Act:
Environment / Account / Viewport:
Source / Target / Correlation ID:
Steps to Reproduce:
Expected:
Actual:
Evidence IDs:
Observed vs Hypothesized:
Severity / Priority:
QA Reviewer Result:
Client Disposition:
Canon / Narrative Continuity Impact:
Reproducible? (Y/N):
```

## 결과 보고

QA AI는 실행 결과를 `PASS / FAIL / BLOCKED / NOT RUN`로 나눠 요약한다. 검증하지 않은 단계는 '확인 완료'라고 쓸 수 없다. 별도 항목으로 `Gameplay risk`, `Narrative realism risk`, `Privacy/permission risk`, `Continuity risk`, `Blocking issues`, `Recommended fixes`를 보고한다.


<!-- END 05_QA_TEST_PLAN.md -->

---

<!-- BEGIN 06_AGENT_PROMPTS.md -->

# NOTHING WRONG — AI 역할별 전달 프롬프트

> 먼저 이 문서 ZIP을 각 AI 작업 환경에 제공한다. AI가 한 개 파일만 받을 수 있다면 `NOTHING_WRONG_ALL_IN_ONE.md`를 전달한다. 아래 프롬프트를 역할에 맞게 복사한다.

## 1. 기획 / 내러티브 AI

```text
당신은 Nothing Wrong의 Narrative Designer 겸 Systems Game Designer다.
첨부한 Nothing Wrong AI Handoff 문서를 전부 읽고, 특히 01_MASTER_SYNOPSIS,
02_NARRATIVE_CANON, 03_PLAYABLE_TICKETS, 07_IMAGE_ASSET_BIBLE을 Source of Truth로 삼아라.

현재 목표:
1) 기존 메인 스토리의 핵심 사실을 보존하며 Act별 Ticket의 업무 동기·전후 의존성·
   NPC 메시지·UI 단서·False Hypothesis를 더 설득력 있게 구체화한다.
2) 각 Ticket을 '표면 QA 문제 / 재현 시나리오 / 정답 / 선택적 Story Clue /
   플레이어가 당시 합리적으로 알 수 있는 것 / 후행 재해석'으로 분리한다.
3) 단서가 뜬금없이 나타나는 장면을 제거하고, Ticket 범위·테스트 데이터 접근 권한의
   개연성을 검증한다.
4) 사진, 사람의 관계, 시간정보를 활용하되 사진 1장만으로 범죄를 확정하지 않는다.
5) 기존 Canon과 충돌하면 임의로 덮어쓰지 말고 제안 변경 사항을 별도로 보고한다.
6) 약물·인신매매·살인 가능성은 진실/추측의 증거단계를 지키고 선정적 묘사를 줄인다.

출력:
A. 변경 제안 목록(기존 vs 제안 / 이유 / 영향을 받는 Ticket)
B. 수정된 Act 요약과 Ticket 상세
C. Evidence Dependency Map
D. Narrative Continuity/Realism 위험 분석
E. 승인 전 보류할 결정

코딩이나 Git 커밋/배포를 실행하지 마라. 별도 요청받지 않는 한 구조적인 기획 산출물만 작성하라.
```

## 2. 개발 / Codex AI

```text
당신은 Nothing Wrong 게임의 Implementation Engineer다.
첨부한 Nothing Wrong AI Handoff 자료를 확인해라.
특히 00_START_HERE, 03_PLAYABLE_TICKETS, 04_SCENARIO_ENGINE_CONTRACT,
05_QA_TEST_PLAN을 구현 기준으로 사용하고, 02_NARRATIVE_CANON과 불일치하지 말라.

현재 구현 목표: NW-001의 End-to-End Vertical Slice 한 개만 우선 완성한다.

필수 결과:
- Company shell / Ticket / fake Shoply browser / basic QA tools / Evidence capture
- Report Builder / deterministic QA Review / navigation / local Save & Resume
- NW-001 scenario fixture, mutation and evidence-rule separation
- normal product rule와 mutation on/off 독립성
- Vitest 및 Playwright E2E 자동 검증
- 향후 시나리오를 추가하는 방법을 README에 설명

구현 제약:
- 실제 외부 사이트/API 호출 또는 실제 ERP 접근 금지.
- 시나리오 ID를 개별 UI 컴포넌트에 if문으로 하드코딩하지 말 것.
- Canon Entity와 Fixture, Mutation, NarrativeClue, Review, Client Disposition을 분리.
- LLM 런타임 판정 금지. 개발 QA 자동화는 허용.
- 웹 데스크톱(React + TypeScript + Vite)을 1차 대상으로 하고 기존 코드베이스가 있다면
  먼저 분석하여 호환성 있는 구조를 제안할 것.
- UI/콘텐츠를 만들 때 아직 스포일러로 공개되지 않은 Narrative 정보를 조기 노출하지 말 것.
- 승인되지 않은 Open Decision은 임의로 '확정 사실'로 만들지 말 것.

작업 절차:
1) 기존 프로젝트 구조/README/테스트 유무 조사
2) 구현 범위와 테스트 기준 제시
3) NW-001 end-to-end 구현
4) unit/component/e2e 테스트 실행
5) 결과와 변경 파일·테스트 로그·미해결 이슈 보고

주의: 첨부 자료 전체의 30개 Ticket을 한 번에 개발하지 말 것.
```

## 3. QA / 테스트 AI

```text
당신은 Nothing Wrong 게임의 독립적인 QA Reviewer다.
첨부한 01_MASTER_SYNOPSIS, 02_NARRATIVE_CANON, 03_PLAYABLE_TICKETS,
04_SCENARIO_ENGINE_CONTRACT, 05_QA_TEST_PLAN을 읽고 다음을 검증하라.

검증 축:
1) 기능: Ticket 조건, normal rule, mutation, expected/actual, Evidence, Review,
   progression, 저장 및 복구의 기술적 정확성
2) 콘텐츠: Ticket마다 실제로 플레이가 가능한 행동 경로가 있는지
3) 개연성: 외주 QA가 보지 못할 법한 내부 정보 무단 열람·사설 수사 행위가 없는지
4) 연속성: Daniel ID/사망일/퇴사일, 10월 17일, 사진 인물 및 시간,
   2022~2024 Migration의 서로 다른 시점
5) 자료 신뢰도: 사진 동석=공모, Death Benefit=살인, 통제 의료재고=마약 범죄 확정 같은
   성급한 결론이 없는지
6) 예외 리뷰: valid QA issue를 고객사가 accepted risk로 닫더라도
   판정 이력이 삭제/무효화되지 않는지
7) 접근성/UX: 사용자가 잘못 추리했더라도 단서/티켓 재방문이 가능하고
   선택적 사진 단서 누락이 진행을 영구 차단하지 않는지

자동화할 수 있는 모든 테스트는 실행하되, 화면/인물 기억/수사 개연성 등 자동 검증이
불가능한 부분은 Human Review Needed로 별도 표기하라.

출력:
- 테스트 환경 / 실행한 명령 / 증거
- Test Matrix(PASS/FAIL/BLOCKED/NOT RUN)
- Defect별 Severity와 재현 단계
- Canon과 충돌하는 부분
- 가장 위험한 5개 UX/Narrative 문제
- 다음 테스트에 필요한 전제

검증하지 못한 내용을 '완료'로 보고하지 말 것.
```

## 4. Cross-AI 협업 규칙

```text
공통 원칙:
- 범위 확장은 Owner(기획 AI 또는 사용자) 승인 전 '제안' 상태로 유지한다.
- 구현 AI는 기획 미결정을 임의로 확정하지 않는다.
- QA AI는 불일치를 찾아 Issue로 보고하고 요구사항을 자동으로 수정하지 않는다.
- Ticket ID, Clue ID, Entity ID, Image Asset ID, Scenario JSON ID를 서로 추적 가능하게 한다.
- 모든 변경마다 Change Log: WHY / WHAT / IMPACT / TEST / UNRESOLVED를 작성한다.
- 개발 완료 기준은 '코드 생성'이 아니라 '실제로 실행·테스트 검증됨'이다.
```

## 5. 단계별 권장 작업 오더

```text
M0 Documentation & Canon Validation
  01/02/03/07 ID 정합성, 필수 Clue 및 연대기 검사

M1 First Playable
  NW-001 + normal Shoply + scenario runtime + report/review + persistence

M2 Core QA
  NW-002~005 + image comparison + UI/report difficulty curve

M3 Cross-System Investigation
  NW-006~010 + date + identity clues + source-target workflow

M4 Zero Incident
  NW-011~019 + metadata + Claim + Case Notes

M5 Foundation
  NW-020~026 + no bug / policy rules / image relationships

M6 Last Case & Final
  NW-027~030 + optional NW-028B + Final Release

M7 Full QA & Narrative Playtest
  5~7h playtime 검증 / spoiler & permission review / localization / Polish
```


<!-- END 06_AGENT_PROMPTS.md -->

---

<!-- BEGIN 07_IMAGE_ASSET_BIBLE.md -->

# NOTHING WRONG — Narrative Image & Evidence Asset Bible

## 목적

웹/SaaS 화면 중심의 Nothing Wrong에서 반복 등장하는 사진은 서사의 **관계·장소·시간 단서**이자 정상적인 이미지 마이그레이션 QA 대상이다. 개발 또는 이미지 제작 AI가 사진별 얼굴·복장·상징·공간을 일관되게 생성할 수 있도록 정의한다.

이미지 자체는 **이 문서에 포함되지 않음**. AI 이미지 제작 단계에서 별도 생성해야 하며, 사용자가 이미지 생성을 요청한 상태가 아니다.

## 인물 시각 ID (외형 세부는 미확정)

| Character ID | 이름 | 반복 시 일관성 조건 | 설정된 역할 |
|---|---|---|---|
| `P-DANIEL` | Daniel Park | 동일 얼굴·피부톤·헤어 실루엣·연령대 변화(2019→2021) | Internal Control Analyst |
| `P-GRACE` | Grace Yoon | 동일 얼굴, 2019/2021의 직장 스타일 차이 허용 | Horizon PM |
| `P-SAMUEL` | Samuel Kwon | 동일 얼굴·체형·재단 행사 배지 | Foundation Director |
| `P-CEO` | Horizon CEO | 외형 미확정, IMG001/004 등장 시 동일 | Horizon 경영진 |
| `P-SECURITY` | Foundation Security Director | IMG007에서 식별 가능, 외형 미확정 | 사고 현장 관계자 |

**생성 순서**: Character Face Sheet → Foundation Badge/Logo Sheet → Horizon Ridge Environment Sheet → 실제 7장 사진 → CMS 썸네일/크롭/회전 등 결함 버전. 주연 얼굴을 사진마다 독립적으로 랜덤 생성하면 **관계 추리 시스템이 붕괴**한다.

## 사진·시각 증거 목록

| Asset | 촬영 콘셉트 / 인물 | 플레이가 먼저 요구하는 작업 | 서사적 재해석 | 관련 Ticket |
|---|---|---|---|---|
| `IMG001` | **Horizon Leadership Awards 2021**. Grace·Samuel·Daniel·임원. 공식 수상 행사, 무난한 회사 행사사진 | 크롭된 썸네일에서 오른쪽 인물 얼굴이 잘림 | 세 사람이 예전부터 서로 아는 관계였을 가능성 | NW-004 |
| `IMG002` | **Horizon Ridge Leadership Retreat**. Grace·직원·시설 배경, Foundation 상징 일부 | Album metadata category 수정 | 리트릿/날짜/재단 상징과 사고 장소 연결 | NW-014 |
| `IMG003` | **Foundation Gala 2019**. Samuel·Grace·Daniel | Foundation Portal 갤러리·반응형 이미지 테스트 | 재단과 기업인/직원의 오래된 인적 교류 | NW-022 |
| `IMG004` | **Leadership Dinner**. Samuel·Horizon CEO, 같은 배지/로고 | Tablet 사진 레이아웃 테스트 | 재단과 최고 경영진의 친밀한 접점 | NW-022 |
| `IMG005` | **Foundation Family Retreat**. Grace 포함 | 사진 확대/metadata 보기 | 공식 경력보다 오랜 재단 관계 암시 | NW-022 |
| `IMG006` | **International Opportunity Cohort**. 집단 사진, 일부 얼굴은 이후 다른 프로필에 재등장 | 직원/프로필 이미지 이관 비교 | 신원 중복/관리자 대리 관리 가능성 | NW-026 |
| `IMG007` | **Horizon Ridge 현장 사진**. 사고 전 Daniel·Grace·Samuel·보안책임자 | Orientation/Thumbnail 오류 비교 | Daniel의 행사 참석과 관계자 접점 | NW-028 |

## Canonical metadata fields

```ts
interface ImageNarrativeAsset {
  assetId: string;
  canonicalPeople: string[];      // person IDs
  locationId: string | null;
  capturedAtLocal: string | null;  // 시각 자체는 변조 가능
  capturedTimezone: string | null;
  uploadedAt: string | null;       // 촬영시각과 별개
  uploadedByEntityId: string | null;
  visibleSymbols: string[];
  narrativeMeaning: string[];
  linkedTicketIds: string[];
  cropVariants: Array<{id: string; focalPoint: string; defect: string}>;
  reliability: 'VERIFIED' | 'UNVERIFIED' | 'CORROBORATED';
}
```

`image metadata`는 검증 전까지 **UNVERIFIED**로 유지할 수 있다. 사진에서 서로 같은 사람처럼 보이는 것과 그 사람의 **신원 검증**은 다른 문제다. IMG006은 다른 자료(직원 참조/출입/프로필 과거 이력 등)와 조합했을 때만 강한 단서가 된다.

## 이미지 QA 메커니즘

1. **Source vs Target Crop**: 원본에는 4명이 있지만 Preview에는 3명만 보이는지.
2. **Orientation**: EXIF 미적용으로 90도 회전; 복구한 뒤에도 새로운 Narrative details가 보이는지.
3. **Gallery Category**: 사진의 행사 타입과 이관된 앨범 분류가 다름.
4. **Profile Identity**: 별명/Employee ID가 바뀌었어도 여러 사진의 인물이 같아 보임; 추가 데이터로 교차 검증.
5. **Time/Place**: 사진 metadata, 행사 배너, 출장 날짜, 근태 기록 비교.

## 시각적 연출 원칙

- 사진을 보는 즉시 `CRITICAL CLUE!` 알림 금지. 일반 QA Attachment처럼 보여준다.
- 관객에게 **누가 누구인지** 처음부터 캡션으로 알려주지 않는다. 사내 인물프로필을 나중에 접했을 때 스스로 알아차리도록 한다.
- 종교·사이비 심벌은 초기부터 과도하게 위협적이지 않아야 함. 사회공헌재단의 무난한 로고로 시작.
- 살인/약물/착취는 충격적인 피해 사진이 아니라 기록·사진의 **불편한 불일치**로 표현.
- 사진 한 장이 사건의 확정 판결이 되지 않는다. 반드시 문서/출장/입출입 등 추가 증거와 결합.
- Narrative-critical 이미지 7장은 보조 텍스트와 메타데이터 경로도 제공해 로딩 실패/접근성 이슈가 메인 플레이를 막지 않도록 한다.

## 아트 QA 체크리스트

- [ ] 동일 인물 얼굴이 모든 사진에서 추적 가능한 수준으로 유지되는가?
- [ ] 배지/로고의 형태가 동일한가? 다른 브랜드 로고와 혼동되지 않는가?
- [ ] 2019·2021 사진의 시대감과 촬영 장소가 자연스러운가?
- [ ] Narrative Canon상 없는 인물이 사진에 추가되어 진실을 바꾸지 않는가?
- [ ] Source Crop/Target Crop 재현을 위한 충분한 해상도와 Composition인가?
- [ ] EXIF `capturedAt`, CMS `uploadedAt`, Ticket Date가 각각 별도로 관리되는가?
- [ ] 배경의 우연한 AI 생성 텍스트가 스토리의 False Clue가 되지 않는가?
- [ ] 이미지 자체에 개인정보/실제 인물·실제 기관 연상 요소가 불필요하게 들어 있지 않은가?


<!-- END 07_IMAGE_ASSET_BIBLE.md -->

---

<!-- BEGIN 08_OPEN_DECISIONS.md -->

# NOTHING WRONG — Open Decisions / Continuity Risks

이 문서는 **결정되지 않은 값을 개발 AI가 무심코 확정하지 못하도록** 하는 이슈 레지스터다. 제안값은 메인 Story Canon과 동일한 효력을 갖지 않는다.

| ID | 이슈 | 현재 처리 / 제안 | 승인 필요 여부 / 영향 |
|---|---|---|---|
| `D-01` | **10월 17일의 연도** | `2021-10-17`을 가안으로 사용(제품별 Legacy Migration 2022·2023·2024보다 앞). | **필요**. 모든 자료·사진·로그 시각 변경 |
| `D-02` | **Leadership Awards 2021 사진 촬영일** | Daniel 사망 이전 촬영이어야 함. 2021년 상반기 가안. | 필요. IMG001 Continuity |
| `D-03` | **Northstar와 Horizon의 지분·지배 구조** | 법적 독립 계약사이지만 Trust/관계사를 통한 실질적 지배/영향권. '재단 100% 직접 소유' 주장 금지. | 필요. Organization Master/ending |
| `D-04` | **ONE HORIZON current project와 2022~24 Migration의 관계** | 제품별 과거 이전과 현재 글로벌 통합은 서로 다른 단계. | 설명 Canon으로 적용, 세부 일정 협의 |
| `D-05` | **외주 QA에 의료·인사 정보가 노출되는 현실성** | UAT에 비식별·토큰화 데이터, 부분적으로 원본의 잘못된 마스킹 또는 승인된 최소 감사 Fragment. | 세부 업무·보안 시나리오 필요. QA 접근 범위 |
| `D-06` | **Daniel 퇴사일과 사망 관계** | HR 소급정정 가능성을 의심하되, 입사/퇴사 문서의 진위는 결말에서도 확증이 아닐 수 있음. | 필요. 사망 보험/고용 책임 묘사 |
| `D-07` | **급여 지속의 의미** | 정산·미지급·보상 지급 등 합법적 가능성을 열고 데이터 유형 불일치를 QA 이슈로 구성. | CONTENT QA 필수 |
| `D-08` | **NW-007 귀환 0건 vs 실제 return migration bug** | Target 0이고 Legacy Source 일부 귀환 존재, 나머지 행은 원본에도 연결 없음. 이중 레이어 명시. | 제안 구체화. 데이터셋 생성 전 승인 |
| `D-09` | **NW-017 주요 사고 0건 vs 공식 사망사고** | 내부 월간 Dashboard의 대상 범위/분류 설정과 Orphan Ref 문제. 국가 공식 사고·사망 통계가 0인 것은 아님. | 반드시 스크립트 검증 |
| `D-10` | **CareBridge의 DB-01 노출** | 응급치료 코드가 아닌 회사 Benefits/Insurance Settlement 데이터 구획에 등장. | 엔진 타입/화면에서 검증 |
| `D-11` | **NW-023 기술 버그 없음과 'Invalid Report'의 부당성** | 검증된 Backend Rule은 Working as Designed. 하지만 Requirement 누락은 `DOC_GAP`이라는 정당한 QA 지적. | 게임 Theme에 중요. 리뷰 설계 확정 필요 |
| `D-12` | **NW-024 의약품 잔량 수식** | `1200-380-24-675=121`, Transfer 675가 UI에 누락된 Bug. 거래 자체 범죄성은 별개. | 명세 적용 |
| `D-13` | **NW-026 인신매매 소재** | 확실한 계정/근로 상태 데이터만 제시, 자율성 제한은 합리적 의혹. 최종 피해자 서사·증언 추가 여부 미결정. | 기획 승인 필요 |
| `D-14` | **Daniel 죽음의 최종 진실** | 사고/사후 조작/살인 의혹은 남지만 **살인 확증 없음**. 추후 제작 방향 결정 전 범인 설정 금지. | 중요. 엔딩/속편 |
| `D-15` | **Mina 전직 QA 사건** | 이전 인력이 프로젝트에서 제외된 사실. 구체적 인물/사유의 상세 재구성은 보류. | 캐릭터 대사 발전 시 필요 |
| `D-16` | **왜 감사가 못 잡았나** | 조사범위 분리 + Legacy ID 분리 + 일부 기존 지적 + 승인 예외/관리자 압력. 감사·공권력 전체를 무능/매수로 설정 금지. | Narrative QA 필수 |
| `D-17` | **Murder Mystery 게임 종료 판정** | 플레이어는 증거 신뢰도에 따라 선택적 가설을 제출할 수 있으나 유죄를 확정할 수 없음. | UX/추리 스코어 미정 |
| `D-18` | **Final Choice 및 엔딩** | `SHIP/HOLD`, 정식 이관·보존 등의 책임 있는 선택 후보만 정의. 구체적 결과는 미확정. | **확정 (2026-10-25, DEC-017)**: Working as Intended / Hold and Escalate / Off the Project 3개 엔딩. `docs/story/CANON-MAP.md` 참조 |
| `D-19` | **이미지 일관성** | 7개 사진 제작 전 반복 인물 Face Sheet, Foundation 로고, Ridge Layout 확정. | **확정 (2026-10-25, DEC-017)**: 기준 시트 후 사진 제작, `godot/assets/photos/` |
| `D-20` | **캠페인 예상 시간** | 30+ Tickets로 5–7시간이 실제 가능한지 인적 플레이테스트 후 조정. | 템포/콘텐츠 분량 |

## 변경 관리 절차

1. `D-XX` 해결을 제안한 AI는 **대안·장단점·연관 Ticket·검증 방법**을 먼저 기술한다.
2. 기획 담당자/사용자 승인을 받은 뒤 `02_NARRATIVE_CANON.md`를 갱신한다.
3. 관련 `03_PLAYABLE_TICKETS.md`, `04_SCENARIO_ENGINE_CONTRACT.md`, `07_IMAGE_ASSET_BIBLE.md`를 함께 갱신한다.
4. `05_QA_TEST_PLAN.md`에 Regression Test를 추가한다.
5. 변경 전후 결과가 확인되기 전에는 완료라고 보고하지 않는다.

## 후속 기획 우선순위

1. **D-05**: 의료/인사/감사 메타데이터에 접근할 수 있는 실제 QA 업무 경로 확정.
2. **D-06, D-07, D-09, D-10**: 사망·고용·보험·사고 분류의 증거 논리 정교화.
3. **D-11**: 기술적으로는 정상이나 문서 누락이 있는 Ticket의 정당한 Review 설계.
4. **D-03, D-18**: 최종 지배구조 발견 이후 플레이어의 선택과 결과 설계.
5. **D-13, D-14**: 인신매매/살인 의혹의 증거 수준·서사 결론과 피해자 관점 강화.


<!-- END 08_OPEN_DECISIONS.md -->
