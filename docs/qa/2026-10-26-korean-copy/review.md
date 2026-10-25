# CX-04 · 한국어 카피 검토

- 역할/결과: Codex 한국어 카피 검토 완료. 아래는 편집 제안이며 제품 반영 결과가 아니다. Claude가 수용 여부를 정해 적용한다.
- 범위: `godot/i18n/ko.json` **1,579개 키/값**을 전수 대조했다(한글이 있는 값 1,538개, 한글이 없는 이름·코드 등 41개). 줄 수는 JSON의 물리적 줄 수가 아니라 번역 항목 수다. 미사용 가능성이 있는 카탈로그 항목도 포함했다.
- 문맥: `scenarios.json`의 티켓 42개·챕터 10개, `intranet.json`, `people.json`, `horizon.json`의 레코드 뷰 30개, 캐논 2종, 용어/추리 테스트, 전일 처리 기록을 대조했다. Shoply 상점과 ONE HORIZON 포털에 의도적으로 남긴 영어는 번역 제안에서 제외했다.
- 제안: **52건 — P1 11 / P2 27 / P3 14**. 주요 패턴은 경곗값·기록 가용성의 의미 변화, 일정/보고 순서의 시점 혼동, Grace의 격식체 이탈, 지배 관계와 기술 설명의 직역, 동적 UI 라벨의 조사 병기다.
- 추리: **19개 문장 / 675개 선택지 조합**을 현재 번역과 제안 번역 각각에서 전개해 자리표시자와 조사 규칙을 검사했다. 기존 F04의 가변 조사 오류는 재발견되지 않았다. 선택지별 문법을 대조했으며, 추리 관련 제안 2건은 직역 표현을 다듬는 내용이다. F09의 공용 힌트·CA-70 설명·T21 근거 순서 수정은 유지한다.
- 기준: P1은 의미·연속성, P2는 말투·자연스러움, P3는 UI 표현·용어 정리다. 말투와 자연스러움은 편집 판단이며, 사람 플레이테스트 관찰로 주장하지 않는다.

각 표는 `suggestions.json`과 같은 항목이다. 영어 키와 현재 번역은 생략하지 않았으며 원본과 정확히 일치한다. 카테고리는 한 항목당 하나만 부여했다.

## 의미 (meaning) · 8건

| English key | 현재 한국어 | 제안 한국어 | 이유 | 심각도 |
| --- | --- | --- | --- | --- |
| SAVE10: everyone, 10% off orders over $30.00. | SAVE10: 모든 고객, $30.00 이상 주문 10% 할인. | SAVE10: 모든 고객, $30.00 초과 주문 10% 할인. | DOC-PROMO-CALENDAR: over는 초과이며 이상은 $30.00까지 포함한다. T09 요건과 원문 자체도 충돌하므로 적용 전 원문 확인이 필요하다. | P1 |
| Spot-check prices and the bag on every device. This Ticket may hide more than one defect; report each one. | 가격과 장바구니를 모든 기기에서 점검하세요. 이 티켓에는 결함이 하나 이상 숨어 있을 수 있어요. 하나씩 모두 보고하세요. | 가격과 장바구니를 모든 기기에서 점검하세요. 이 티켓에는 결함이 둘 이상 숨어 있을 수 있어요. 하나씩 모두 보고하세요. | T11 요청: more than one은 둘 이상이다. 하나 이상으로 옮기면 여러 결함을 찾아야 한다는 안내가 약해진다. | P1 |
| That's the record, and that's the rule. But is it a broken feature, or records that disagree with each other? Pick the kind of problem again. | 기록도 맞고 규칙도 맞아요. 그런데 기능이 고장 난 건가요, 아니면 기록끼리 서로 맞지 않는 건가요? 문제의 종류를 다시 골라 보세요. | 기록과 규칙은 확인했어요. 그런데 기능이 고장 난 건가요, 아니면 기록끼리 서로 맞지 않는 건가요? 문제의 종류를 다시 골라 보세요. | T19 분류 피드백: that is the record는 해당 기록을 짚는 말이다. 기록도 맞다고 단정하면 기록 간 불일치를 고르는 문제와 충돌한다. | P1 |
| INC-1017 · duplicate, original unavailable | INC-1017 · 중복, 원본 없음 | INC-1017 · 중복, 원본 열람 불가 | T27 단서 제목: unavailable는 열람할 수 없다는 뜻이다. 원본 없음은 기록의 부재까지 단정하며 본문과 Original unavailable보다 강하다. | P1 |
| PeopleCore: resigned 16 October (corrected 18 October). Triply: outbound to Horizon Ridge on 17 October, no return. CareBridge: emergency record, then a death benefit. The official summary: an accidental facility incident at Horizon Ridge, one fatality, investigated by the authorities. Grace Yoon closed the report as a Historical Exception. | PeopleCore: 10월 16일 퇴사(10월 18일 정정). Triply: 10월 17일 Horizon Ridge로 출발, 귀환 없음. CareBridge: 응급 기록, 이어서 사망 보험금. 공식 요약: Horizon Ridge 시설 사고, 사고사로 분류, 사망 1명, 당국 조사. Grace Yoon이 이 보고를 Historical Exception으로 종결했다. | PeopleCore: 10월 16일 퇴사(10월 18일 정정). Triply: 10월 17일 Horizon Ridge로 출발, 귀환 없음. CareBridge: 응급 기록, 이어서 사망 보험금. 공식 요약: Horizon Ridge 시설에서 발생한 우발적 사고, 사망 1명, 당국 조사. Grace Yoon이 이 보고를 Historical Exception으로 종결했다. | T29 단서: accidental은 공식 요약의 시설 사고 분류다. 사고사로 분류는 개인의 사망 경위까지 분류한 것으로 읽힌다. 공식 사고 분류와 미확정 사망 경위를 구분한다. | P1 |
| Horizon Holdings answers to Horizon Community Trust, and the Trust to Horizon Foundation. The public tree stops one step short of that. | Horizon Holdings는 Horizon Community Trust에, Trust는 Horizon Foundation에 닿아요. 공개 조직도는 그 한 걸음 앞에서 멈추고요. | Horizon Holdings는 Horizon Community Trust의 통제를 받고, Trust는 Horizon Foundation의 지휘를 받아요. 공개 조직도는 그 한 걸음 앞에서 멈추고요. | T40 디브리핑·Mina: answers to의 통제 방향이 닿아요라는 단순 연결로 약해졌다. 이사회·의결권의 지배 관계를 밝히되 소유 관계로 바꾸지 않는다. | P1 |
| Check that every vendor record names its legal parent and its controlling interest. | 모든 벤더 기록에 법적 모회사와 지배 지분이 적혀 있는지 확인하세요. | 모든 벤더 기록에 법적 모회사와 영향력을 행사하는 주체가 적혀 있는지 확인하세요. | T41 요청: Controlling interest 열에는 조직명과 이사회 의석·협약이 나온다. 지배 지분은 주식 소유를 뜻해 Northstar의 INFLUENCE를 지분 관계로 오인하게 한다. | P1 |
| Every vendor record names its legal parent and its controlling interest. | 모든 벤더 기록에는 법적 모회사와 지배 지분이 적혀 있다. | 모든 벤더 기록에는 법적 모회사와 영향력을 행사하는 주체가 적혀 있다. | T41·REQ-T41-01: 요청과 같은 지분 오역이다. 법적 모회사와 영향력을 행사하는 조직을 분리해 INFLUENCE를 유지한다. | P1 |

## 연속성 (continuity) · 3건

| English key | 현재 한국어 | 제안 한국어 | 이유 | 심각도 |
| --- | --- | --- | --- | --- |
| NS Browser | NW 브라우저 | NS 브라우저 | 브라우저 UI: Northstar 약칭 NS가 NW로 바뀌었다. NS Search와도 일치시킨다. | P1 |
| That's a root cause, not four separate bugs. But we missed code freeze, so RC3 went out to the partner preview before we pulled it. Friday is still safe, barely. | 네 개의 버그가 아니라 하나의 근본 원인이에요. 그런데 코드 프리즈를 놓쳐서 RC3가 회수 전에 파트너 프리뷰로 나가 버렸어요. 금요일은 간신히 지켰고요. | 네 개의 버그가 아니라 하나의 근본 원인이에요. 그런데 코드 프리즈를 놓쳐서 RC3가 회수 전에 파트너 프리뷰로 나가 버렸어요. 금요일 출시는 아직 간신히 지킬 수 있어요. | CH1 지연 에필로그·Mina: Friday is still safe는 앞으로의 출시 전망인데, 지켰고요는 이미 지킨 과거로 바꾼다. | P1 |
| We missed 09:00. Leadership heard about RC5 from customers before they heard it from us. RC6 is built from SNAP-0901 now, and it passes every check. | 09:00를 놓쳤어요. 경영진은 RC5 얘기를 우리보다 고객에게서 먼저 들었죠. RC6는 이제 SNAP-0901에서 빌드됐고, 모든 점검을 통과해요. | 09:00 마감을 놓쳤어요. 경영진은 우리 보고를 받기 전에 고객에게서 RC5 얘기를 먼저 들었죠. RC6는 이제 SNAP-0901에서 빌드됐고, 모든 점검을 통과해요. | CH4 지연 에필로그·Mina: 경영진이 고객과 우리에게 소식을 들은 순서다. 우리보다 먼저는 우리가 알게 된 시점과 비교하게 된다. | P1 |

## 인물 말투 (voice) · 13건

| English key | 현재 한국어 | 제안 한국어 | 이유 | 심각도 |
| --- | --- | --- | --- | --- |
| You'll work on read-only UAT snapshots in the QA portal. Shoply's order history is first. | QA 포털의 읽기 전용 UAT 스냅샷으로 작업하시게 됩니다. 첫 번째는 Shoply 주문 이력이에요. | QA 포털의 읽기 전용 UAT 스냅샷으로 작업하시게 됩니다. 첫 번째는 Shoply 주문 이력입니다. | T13 브리핑·Grace: 한 대사 안에서 됩니다와 이에요가 섞인다. 격식 있는 고객사 PM의 종결형으로 맞춘다. | P2 |
| Some legacy trips never had a return recorded. Please flag only what the source actually had. | 레거시 출장 중엔 귀환이 처음부터 기록되지 않은 것도 있어요. 원본에 실제로 있던 것만 지적해 주세요. | 레거시 출장 중에는 처음부터 귀환 기록이 없는 건도 있습니다. 원본에 실제로 있던 항목만 지적해 주십시오. | T17 브리핑·Grace: 동료식 해요체를 격식체로 맞춘다. 원본에도 없던 귀환을 결함으로 보지 말라는 뜻을 유지한다. | P2 |
| This one is sensitive. Report what the data says, and nothing more. | 이건 민감한 건이에요. 데이터가 말하는 것만, 그 이상은 말고 보고해 주세요. | 민감한 사안입니다. 데이터에 나타난 내용만 보고해 주십시오. | T19 브리핑·Grace: 민감한 건이에요를 격식체로 맞추고, 데이터 밖의 주장을 제한하는 태도를 유지한다. | P2 |
| Thank you, this phase is complete. Remaining legacy items will go through the exceptions board. | 감사합니다. 이번 단계는 완료됐습니다. 남은 레거시 항목은 예외 처리 위원회를 거칠 거예요. | 감사합니다. 이번 단계는 완료됐습니다. 남은 레거시 항목은 예외 처리 위원회를 거칩니다. | CH6 에필로그·Grace: 완료됐습니다 다음의 거칠 거예요만 해요체로 바뀐다. 공식 안내 말투로 맞춘다. | P2 |
| Benefit data is restricted. You will only see the settlement section. | 복리후생 데이터는 제한돼 있어요. 정산 구획만 보시게 됩니다. | 복리후생 데이터는 열람이 제한됩니다. 정산 구획만 보시게 됩니다. | T25 브리핑·Grace: 제한돼 있어요를 격식체로 맞춘다. 정산 구획만 열람한다는 권한 경계는 유지한다. | P2 |
| Thank you. This concerns a closed historical incident. I am applying Historical Exception: no action required. | 감사합니다. 종결된 과거 사고에 관한 건이에요. Historical Exception을 적용합니다. 조치는 필요 없습니다. | 감사합니다. 종결된 과거 사고에 관한 사안입니다. Historical Exception을 적용합니다. 조치는 필요 없습니다. | T29 디브리핑·Grace: 공식 처분을 통보하는 중간 문장만 건이에요로 풀어진다. 나머지 격식체와 맞춘다. | P2 |
| People in the same photo knew each other. That is all a photo proves. | 같은 사진에 있는 사람들은 서로 알았다. 사진이 증명하는 건 거기까지예요. | 같은 사진에 있는 사람들은 서로 알고 있었어요. 사진이 증명하는 건 거기까지예요. | T32 디브리핑·Mina: 첫 문장의 알았다만 기록체다. 해요체로 맞추며 사진이 입증하는 수준은 친분에 한정한다. | P2 |
| Restricted inventory. Quantities and movements only, please. | 제한 재고예요. 수량과 이동만 다뤄 주세요. | 제한 품목의 재고입니다. 수량과 이동만 다뤄 주십시오. | T34 브리핑·Grace: 제한 재고예요를 공식 범위 안내 말투로 맞춘다. 최종 사용처에 대한 추측은 추가하지 않는다. | P2 |
| Your scope is migration quality, not Horizon's policies. Please keep your reports to that. | 여러분의 범위는 이관 품질이지, Horizon의 정책이 아니에요. 보고서도 거기까지만 해 주세요. | 담당 범위는 Horizon의 정책이 아니라 이관 품질입니다. 보고서도 그 범위로 한정해 주십시오. | CH8 에필로그·Grace: 정책을 다루지 말라는 경계 설정을 동료식 해요체 대신 격식체로 전달한다. | P2 |
| Ninety minutes before the alarm: Daniel, Grace, Kwon, and a man in a Foundation security jacket, on the terrace of Building B. Together. That's all the photo says. | 경보 90분 전. Building B 테라스의 Daniel, Grace, Kwon, 그리고 Foundation 보안 재킷을 입은 남자. 함께였다. 사진이 말하는 건 거기까지예요. | 경보 90분 전. Building B 테라스의 Daniel, Grace, Kwon, 그리고 Foundation 보안 재킷을 입은 남자. 함께 있었어요. 사진이 말하는 건 거기까지예요. | T38 디브리핑·Mina: 함께였다만 기록체로 튄다. 동석만 확인하는 해요체로 맞춘다. 90분의 원문 시간 문제는 별도 기록하며 이 제안에서는 바꾸지 않는다. | P2 |
| ONE HORIZON final validation is scheduled for Monday. Northstar will sign the release. | ONE HORIZON 최종 검증은 월요일로 잡혔습니다. Northstar가 릴리스에 서명할 거예요. | ONE HORIZON 최종 검증은 월요일로 잡혔습니다. Northstar가 릴리스에 서명할 예정입니다. | CH9 에필로그·Grace: 잡혔습니다 다음의 서명할 거예요가 말투를 바꾼다. 공식 일정 통보의 격식체로 맞춘다. | P2 |
| Thank you. ONE HORIZON ships on schedule. Every validation passed. | 감사합니다. ONE HORIZON은 일정대로 출시됩니다. 모든 검증을 통과했어요. | 감사합니다. ONE HORIZON은 일정대로 출시됩니다. 모든 검증을 통과했습니다. | FINAL 기본 에필로그·Grace: 마지막 통과했어요만 해요체다. 앞의 공식 출시 통보와 맞춘다. | P2 |
| Now the legacy migration itself. Shoply's order history is first. | 이제 레거시 이관 본 작업이에요. 첫 번째는 Shoply 주문 이력입니다. | 이제 레거시 이관 본 작업입니다. 첫 번째는 Shoply 주문 이력입니다. | T16 브리핑·Grace: 본 작업이에요와 이력입니다가 섞인다. 격식체로 통일한다. | P2 |

## 자연스러움 (naturalness) · 12건

| English key | 현재 한국어 | 제안 한국어 | 이유 | 심각도 |
| --- | --- | --- | --- | --- |
| Second job. Shoply Support got a strange email: a customer bought two packs and was charged less than expected. | 두 번째 업무예요. Shoply 고객지원팀에 이상한 메일이 왔어요. 가방 두 개를 산 고객이 예상보다 적게 결제됐대요. | 두 번째 업무예요. Shoply 고객지원팀에 이상한 메일이 왔어요. 가방 두 개를 산 고객에게 예상보다 적은 금액이 청구됐대요. | T02 브리핑·Mina: 고객이 적게 결제됐다는 피동 구문이 어색하다. 고객에게 금액이 청구됐다는 관계로 바로잡는다. | P2 |
| Right. A rollback is only as clean as the point it rolls back to. | 맞아요. 롤백은 되돌아가는 지점만큼만 깨끗해요. | 맞아요. 롤백한 결과가 깨끗하려면 되돌아갈 지점부터 깨끗해야 해요. | T11 추리 성공·Mina: 지점만큼만 깨끗해요는 only as clean as의 직역이다. 복원 지점의 품질이 롤백 결과를 좌우한다는 뜻을 풀어 쓴다. | P2 |
| Alex Han, integration. Before you sign off on one bad batch: those systems weren't migrated together. I'll show you on Monday. | 통합 개발의 Alex Han이에요. 배치 하나가 망가졌다고 결론 내리기 전에요. 그 시스템들은 같이 이관되지 않았어요. 월요일에 보여 드릴게요. | 통합팀 Alex Han이에요. 배치 하나가 망가졌다고 결론 내리기 전에 알아둘 게 있어요. 그 시스템들은 같이 이관되지 않았어요. 월요일에 보여 드릴게요. | CH5 에필로그·Alex: 통합 개발의는 소속 소개로 어색하고 결론 내리기 전에요는 매달린 절이다. 기술적 반론의 도입을 완결한다. | P2 |
| Compare the birth hash and email on each candidate with the proposal it got. | 후보마다 생년 해시와 이메일을 받은 제안과 비교해 보세요. | 후보별 생년 해시와 이메일을 대조해, 각 후보의 병합 제안이 맞는지 확인해 보세요. | T20 힌트·Mina: 이메일을 받은 제안으로 읽히는 잘못된 수식 관계를 해소한다. 속성 대조로 병합 제안을 검증하는 행동을 명확히 한다. | P2 |
| Here's what I promised. Last week's theory was one bad batch. Check the migration history yourself. | 약속한 거예요. 지난주 가설은 망가진 배치 하나였죠. 이관 이력을 직접 확인해 보세요. | 약속했던 자료예요. 지난주 가설은 배치 하나에 문제가 있었다는 거였죠. 이관 이력을 직접 확인해 보세요. | T21 브리핑·Alex: 약속한 거예요는 지금 약속한다는 말처럼 들린다. 이전에 보여 주기로 한 자료를 제시하는 문맥을 살린다. | P2 |
| From 23:20 on 17 October 2021, Horizon raised emergency orders for medical supplies, patient transport, and fire safety equipment, all for HRDG-01. | 2021년 10월 17일 23:20부터 Horizon은 의료용품, 환자 이송, 소방 장비 긴급 주문을 냈고, 모두 HRDG-01 앞이었다. | 2021년 10월 17일 23:20부터 Horizon은 의료용품, 환자 이송, 소방 장비 긴급 주문을 냈고, 목적지는 모두 HRDG-01이었다. | T26 단서: 주문이 HRDG-01 앞이었다는 표현은 불명확하다. all for의 배송 목적지 관계를 직접 적는다. | P2 |
| That's the candidate, and that's the rule. But the system does exactly what an approved rule says. What's missing is that rule in the published requirements. Pick the kind of problem again. | 후보도 맞고 규칙도 맞아요. 그런데 시스템은 승인된 규칙대로 정확히 동작해요. 빠진 건 공개된 요구사항 속의 그 규칙이에요. 문제의 종류를 다시 골라 보세요. | 해당 후보와 적용 규칙은 확인했어요. 그런데 시스템은 승인된 규칙대로 정확히 동작해요. 빠진 건 공개된 요구사항 속의 그 규칙이에요. 문제의 종류를 다시 골라 보세요. | T33 분류 피드백: 후보도 맞고는 무엇이 맞다는 것인지 불명확하다. 후보와 적용 규칙을 짚고 문서 누락으로 안내하는 흐름을 분명히 한다. | P2 |
| Noted. From here on, word every report so it stands on the records alone. | 알겠습니다. 지금부터 모든 보고서는 기록만으로 설 수 있게 쓰세요. | 알겠습니다. 지금부터 모든 보고서는 기록만으로 뒷받침할 수 있게 쓰세요. | CH8 에필로그·Mina: 보고서가 기록만으로 선다는 영어 비유가 어색하다. 기록으로 뒷받침되는 주장만 쓰라는 뜻을 살린다. | P2 |
| Document archive migration. Your role can preview attachments, not case bodies. Check the permission rule does what it says. | 문서 아카이브 이관이에요. 여러분 역할은 첨부 미리보기만 되고, 케이스 본문은 안 돼요. 권한 규칙이 적힌 대로 동작하는지 확인하세요. | 문서 아카이브 이관이에요. 지금 권한으로는 첨부 파일만 미리 볼 수 있고, 케이스 본문은 볼 수 없어요. 권한 규칙이 적힌 대로 동작하는지 확인하세요. | T37 브리핑·Alex: 여러분 역할은 미리보기만 된다는 구문 대신 해당 역할이 허용하는 동작을 기술적으로 분명히 안내한다. | P2 |
| With the clocks corrected: Daniel's badge enters Building B at 22:48 with no exit; the alarm sounds at 23:06; a medical event is logged in Building A at 23:11; Foundation vehicle FS-01 leaves at 23:18; the hospital transfer is at 00:14. The records place him in two buildings. They do not say how or why. | 시각을 보정하면: 22:48 Daniel의 배지가 Building B에 들어가고 퇴실 기록은 없다. 23:06 경보, 23:11 Building A에서 의료 이벤트, 23:18 Foundation 차량 FS-01 출차, 00:14 병원 이송. 기록은 그를 두 건물에 두고 있다. 어떻게, 왜인지는 말하지 않는다. | 시각을 보정하면: 22:48 Daniel의 배지가 Building B에 들어가고 퇴실 기록은 없다. 23:06 경보, 23:11 Building A에서 의료 이벤트, 23:18 Foundation 차량 FS-01 출차, 00:14 병원 이송. 기록에는 그가 두 건물에 있었던 것으로 나온다. 어떻게, 왜인지는 말하지 않는다. | T39 단서: 기록은 그를 두 건물에 두고 있다는 place의 직역이다. 실제 동선을 확정하지 않고 기록상 위치가 둘이라는 수준으로 표현한다. | P2 |
| That's the chain, and that's the rule. The tree stops at Holdings because a setting tells it to; nobody wrote that limit into the requirements. Pick the kind of problem again. | 계통도 맞고 규칙도 맞아요. 조직도가 Holdings에서 멈추는 건 설정이 그렇게 시켜서예요. 그 제한을 요구사항에 적은 사람이 없을 뿐이죠. 문제의 종류를 다시 골라 보세요. | 지배 계통과 적용 규칙은 확인했어요. 조직도가 Holdings에서 멈추는 건 설정이 그렇게 시켜서예요. 그 제한을 요구사항에 적은 사람이 없을 뿐이죠. 문제의 종류를 다시 골라 보세요. | T40 분류 피드백: 계통도 맞고는 조직도라는 명사로도 읽혀 주제가 흐려진다. 확인한 지배 계통과 규칙을 먼저 명시한다. | P2 |
| Northstar Quality Services is a legally independent contractor whose parent, Northstar Services Holdings, has board seats held by Horizon Community Trust. The record is correct. The QA vendor checking ONE HORIZON answers, in part, to the same Trust. | Northstar Quality Services는 법적으로 독립된 계약사지만, 그 모회사 Northstar Services Holdings의 이사회 의석을 Horizon Community Trust가 쥐고 있다. 기록은 정확하다. ONE HORIZON을 검증하는 QA 회사가 일부는 같은 Trust에 답하고 있다. | Northstar Quality Services는 법적으로 독립된 계약사지만, 그 모회사 Northstar Services Holdings의 이사회 의석을 Horizon Community Trust가 쥐고 있다. 기록은 정확하다. ONE HORIZON을 검증하는 QA 회사도 같은 Trust의 영향을 일부 받고 있다. | T41 단서: Trust에 답하고 있다는 answer to의 직역이다. 이사회 의석에 의한 영향력을 자연스럽게 표현하고 지분 소유로 확대하지 않는다. | P2 |

## UI (ui) · 14건

| English key | 현재 한국어 | 제안 한국어 | 이유 | 심각도 |
| --- | --- | --- | --- | --- |
| A core flow is blocked or sends the customer somewhere harmful, such as an unintended payment. | 핵심 흐름이 막히거나, 원치 않는 결제처럼 고객을 해로운 곳으로 보냅니다. | 핵심 흐름이 막히거나, 원치 않는 결제처럼 고객에게 피해를 주는 절차로 이어집니다. | 심각도 안내: 해로운 곳은 웹 흐름의 결과를 가리키기 어렵다. 원치 않는 결제 같은 피해를 주는 절차로 명확히 표현한다. | P3 |
| ← Back to %s | ← %s(으)로 돌아가기 | ← 돌아가기: %s | 탐색 버튼: 동적 이름 뒤의 (으)로 병기 없이 짧게 표시한다. %s 유지. | P3 |
| Back to %s | %s(으)로 돌아가기 | 돌아가기: %s | 탐색 버튼: 화살표가 있는 동형 라벨과 동일하게 조사 병기를 없앤다. %s 유지. | P3 |
| Good catch. Design confirms Confirm order should be primary, and they say they never touched it. | 잘 찾았어요. 디자인팀도 주문 확정 버튼은 기본 스타일이어야 한다고 확인했고, 자기들은 손댄 적이 없대요. | 잘 찾았어요. 디자인팀도 'Confirm order'는 주요(primary) 버튼이어야 한다고 확인했고, 자기들은 손댄 적이 없대요. | T01 디브리핑·Mina: 명세의 주요(primary)와 기본 스타일을 통일하고, 영어로 표시되는 Confirm order 버튼을 그대로 지칭한다. | P3 |
| Is this where the action should lead? | 이 행동이 와야 할 곳이 여기가 맞나요? | 이 동작으로 열려야 하는 화면이 맞나요? | T03 가이드: 행동이 와야 할 곳이라는 부자연스러운 주어 대신 동작으로 열리는 화면을 묻는다. | P3 |
| Blocks a core flow or sends the customer somewhere harmful. | 핵심 기능이 막히거나 고객을 해로운 곳으로 보냄. | 핵심 기능이 막히거나 고객에게 피해를 주는 절차로 이어짐. | 짧은 심각도 안내: 상세 설명과 같이 해로운 곳을 피해를 주는 절차로 명확히 한다. | P3 |
| Test %s and keep an eye on the Console. | %s을(를) 테스트하면서 콘솔을 지켜보세요. | %s 테스트를 진행하면서 콘솔을 지켜보세요. | 안내 템플릿: 을(를) 병기를 없애고 모든 티켓 ID에 자연스럽게 읽히게 한다. %s 유지. | P3 |
| The spec says the button that completes a step is solid dark (primary). If Confirm order looks different, press 📌 Note and click it. | 명세에 따르면 단계를 완료하는 버튼은 진한 색으로 채워진 기본(primary) 버튼입니다. 'Confirm order'가 다르게 보이면 📌 메모를 누르고 그 버튼을 클릭하세요. | 명세에 따르면 단계를 완료하는 버튼은 진한 색으로 채워진 주요(primary) 버튼입니다. 'Confirm order'가 다르게 보이면 📌 메모를 누르고 그 버튼을 클릭하세요. | T01 가이드: 주요(primary)와 기본(primary)이 같은 스타일에 혼용된다. 명세의 주요(primary)로 맞춘다. | P3 |
| Here's how, so you can move on: on the checkout screen press 📌 Note and click the Confirm order button. Then report it to me here with REQ-T01-02. The spec says it should be primary. | 다음으로 넘어갈 수 있게 방법을 알려줄게요. 결제 화면에서 📌 메모를 누르고 'Confirm order' 버튼을 클릭하세요. 그다음 여기서 REQ-T01-02와 함께 저에게 보고해 주세요. 명세에는 기본(primary) 버튼이어야 한다고 되어 있어요. | 다음으로 넘어갈 수 있게 방법을 알려줄게요. 결제 화면에서 📌 메모를 누르고 'Confirm order' 버튼을 클릭하세요. 그다음 여기서 REQ-T01-02와 함께 저에게 보고해 주세요. 명세에는 주요(primary) 버튼이어야 한다고 되어 있어요. | T01 보조 안내·Mina: 명세와 가이드의 primary를 주요(primary)로 통일한다. 요구사항 ID와 📌 메모를 유지한다. | P3 |
| %s is waiting in QA Notes. | %s이(가) QA 노트에서 기다리고 있습니다. | QA 노트에 대기 중인 티켓: %s. | 티켓 대기 안내: %s이(가) 병기 대신 라벨형으로 써서 코드·이름에 따른 조사 문제를 없앤다. | P3 |
| Test %s and read the Console carefully. | %s을(를) 테스트하면서 콘솔을 꼼꼼히 읽어 보세요. | %s 테스트를 진행하면서 콘솔을 꼼꼼히 읽어 보세요. | QA 노트 안내: 같은 형식의 짧은 템플릿과 함께 을(를) 병기를 제거한다. %s 유지. | P3 |
| Ending · Off the Project | 결말 · 프로젝트 이탈 | 결말 · 프로젝트에서 제외 | FINAL removed 결말: 이탈보다 제외가 접근 권한 정지와 이전 QA 두 명의 배제라는 결과를 명확히 연결한다. | P3 |
| Direct reports | 팀원 | 직속 팀원 | 조직도: Direct reports는 일반 팀원이 아니라 해당 인물에게 직접 보고하는 구성원이다. 보고선의 직접성을 표시한다. | P3 |
| Runs the release pipeline and release-bot, including its merge rule. | 릴리스 파이프라인과 release-bot을 운영해요. 머지 규칙도 포함이에요. | 병합 규칙을 포함해 릴리스 파이프라인과 release-bot을 운영해요. | 조직도·Marcus 업무: 본문과 명세의 병합 규칙으로 용어를 맞추고 포함이에요의 중복 문장을 줄인다. | P3 |

## 추리 문장·선택지 (deduction) · 2건

| English key | 현재 한국어 | 제안 한국어 | 이유 | 심각도 |
| --- | --- | --- | --- | --- |
| still place Daniel in two buildings | 여전히 Daniel을 두 건물에 두고 있고 | 여전히 Daniel이 두 건물에 있었다고 하고 | T39·DED-T39 선택지: place를 두고 있다로 직역한 표현을 기록이 말하는 내용으로 바꾼다. 기존 문장에 넣으면 기록은 … 있었다고 하고로 연결된다. | P2 |
| Daniel opened a case on {topic} on 12 October; it was closed the day after he died, and the companies he questioned, and {employer}, answer to {top}. | Daniel은 10월 12일 {topic}에 대한 케이스를 열었다. 그 케이스는 그가 사망한 다음 날 종료됐고, 그가 문제 삼은 회사들도, {employer}도 모두 {top}에 답한다. | Daniel은 10월 12일 {topic}에 대한 케이스를 열었다. 그 케이스는 그가 사망한 다음 날 종료됐다. 그가 문제 삼은 회사들과 {employer}에 공통으로 영향력을 행사하는 곳: {top}. | T41·DED-T41: 답한다 직역을 영향력 관계로 고친다. 마지막을 라벨형으로 써 Horizon Holdings 단독까지 자연스럽게 들어가게 하고 가변 조사를 추가하지 않는다. | P2 |

## 원문도 함께 확인할 사항

아래는 한영이 함께 가진 문제이므로 한국어만 임의로 고치는 JSON 제안에 추가하지 않았다. 제안 52건과 별도로 원문 작성자가 확인할 사항이다.

| 위치 | 대조한 내용 | 후속 처리 |
| --- | --- | --- |
| DOC-PROMO-CALENDAR / T09 | `over $30.00`은 $30.00 초과지만 T09 요건은 SAVE10이 모든 고객에게 적용된다고 하며, 보조 안내는 가방 1개($30.00)로 비교하도록 한다. | 위 의미 표의 번역은 영문 경곗값에 맞춘 제안이다. 적용 전 실제 의도한 하한을 정하고 영문 문서·요건과 함께 맞출 것. 이번 검토에서 할인 정책은 결정하지 않았다. |
| T27 보조 안내 | `INC-1017 has no original record`는 레코드의 `Original unavailable`, 디브리핑의 원본 열람 불가보다 강한 말이다. | 원본의 존재 여부와 현재 열람 가능 여부를 원문에서 구분할 것. 제목의 한국어 오역 제안과 별개다. |
| CH8 synopsis | `Nothing in this chapter is broken`이라고 하지만 T32·T34·T35·T36에는 실제 레이아웃/표시/매핑 결함이 있다. | 승인된 정책 규칙이 정상이라는 뜻과 기술 결함의 존재를 원문에서 구분할 것. 한국어만 변경하면 두 언어가 달라진다. |
| T38 디브리핑 / T39 타임라인 | 원문과 번역 모두 사진을 경보 90분 전이라고 한다. 카메라 시각 21:40과 현장 경보 23:06의 차이는 86분이며, 사진 시각은 미검증이다. | 원문에서 근삿값 여부와 카메라 시각의 신뢰도를 확인할 것. 위 말투 제안은 원문의 90분을 그대로 둔다. |

## 검증 증거와 한계

- PASS — Python으로 JSON을 다시 파싱하고 모든 객체의 7개 필드, 허용 카테고리/심각도, 중복 키 없음, 현재 값의 원본 일치, 실질 변경 여부를 검사했다.
- PASS — 모든 제안에서 `%s`·`%d`·이름 있는 중괄호 자리표시자의 종류·개수 및 `%s`/`%d`의 순서를 보존했다. 현재 번역의 숫자·금액·시각도 제안에서 보존했다. 이름과 ID는 문맥 대조로 확인했다.
- PASS — 제안만 메모리에서 덮어쓴 전체 카탈로그가 `test_workstation.gd`의 금지 대체 용어 규칙을 통과했다. 티켓·보고·QA 노트·사건 파일·조직도·추리·📌 메모를 유지하며, 기록은 레코드를 뜻하는 자리에 남겼다.
- PASS — 현재/제안 각각 19개 추리 문장의 675개 조합에 누락된 자리표시자가 없고, 빈칸 바로 뒤의 가변 조사와 선택지의 괄호 조사 병기가 없음을 검사했다. 변경되는 T39 선택지와 T41 문장은 각 선택지를 넣어 별도 읽기 검토했다. 이 정규식 검사는 문장 전체의 자연스러움을 증명하는 검사가 아니다.
- PASS — 제안문에 금지된 단정 표현을 추가하지 않았고, DB-01의 복리후생 코드 성격, 사진의 친분 수준, 해외 인력 기록의 정황 수준, Northstar의 INFLUENCE를 유지했다. Daniel의 사망 경위는 확정하지 않는다.
- PASS — 표와 JSON의 항목/내용이 일치함을 다시 파싱해 검사했다. 기준 `ko.json` SHA-256: `f641f533ce5c37c8d3bcba4ed805f96486e1d0d14b5e01e9d6c62f222be37967`.
- NOT RUN — Godot 실행·전체 게임 테스트·화면 렌더링·사람 플레이테스트. 이 작업은 문구 검토와 제안 파일 검증이며 줄바꿈/버튼 폭/플레이 경험은 검증하지 않았다.

## 구조화된 작업 결과

| 항목 | 결과 |
| --- | --- |
| 변경 파일 | 출력 폴더의 `review.md`, `suggestions.json` |
| 작업 내용 | 한국어 전수 검토, 카테고리별 수정 제안, 적용 가능성 정적 검증 |
| 관련 티켓·단서 | T01–T42/CH1–FINAL 문맥 검토. 주요 의미 항목: T11, T19, T27의 INC-1017 단서, T29, T40, T41. 추리 수정 대상: DED-T39, DED-T41 |
| 테스트 증거 | 위 Python 정적 검사. 제품 테스트 통과나 사람 관찰을 대신하지 않음 |
| 기존 캐논과 차이 | 제안은 캐논 사실을 추가·변경하지 않음. 현재 번역의 증거 수준·영향력 표현을 교정 |
| 남은 이슈 | 원문 확인 4건, 제안의 수용/적용, 적용 후 실제 화면 확인. TASK-010은 이 검토와 별개 |
| 다음 우선순위 | 원문 경곗값 확인 → P1 의미/연속성 수용·반영 → P2/P3 반영 → Godot 테스트 및 화면 확인 |
| 상태 변경 | Project OS 상태와 제품/캐논 파일을 변경하지 않음 |
