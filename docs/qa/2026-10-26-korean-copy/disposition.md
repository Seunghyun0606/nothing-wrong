# 한국어 카피 검토 처리 결과 · 2026-10-26

대상: [CX-04 한국어 카피 검토](review.md) (Codex, 제안 52건, 원문 확인 4건).
처리: Claude. 모두 `godot/i18n/ko.json`에 반영했다. 영문 원문 수정은 `scenarios.json`과 `intranet.json`에 함께 반영했다. 적용 스크립트는 `suggestions.json`의 현재 값이 파일과 정확히 같은지 확인한 뒤 바꿨다.

## 판정

| 구분 | 건수 | 처리 |
| --- | --- | --- |
| 제안 그대로 수용 | 50 | 의미 8 중 7, 연속성 3, 말투 13, 자연스러움 12, UI 14, 추리 2 |
| 문구를 바꿔 수용 | 2 | 아래 참조 |
| 원문 함께 수정 | 4 | 아래 참조 |
| 거절 | 0 | |

### 문구를 바꿔 수용
- **T11 요청 "more than one defect":** 제안은 "둘 이상"이었다. 안내 문장으로는 "여러 개"가 자연스럽고 의미도 같아서 "결함이 여러 개 숨어 있을 수 있어요"로 썼다.
- **T40 Mina "answers to":** 제안은 "통제를 받고 / 지휘를 받아요"였다. 캐논은 이사회 의석을 통한 영향(INFLUENCE)까지만 인정하고, "지휘"는 그보다 강한 말이다. 그래서 위계만 보여 주는 "Horizon Holdings 위에는 Horizon Community Trust가, Trust 위에는 Horizon Foundation이 있어요"로 썼다.

### 원문 함께 수정 (검토의 "원문도 함께 확인할 사항")
| 위치 | 확인 | 수정 |
| --- | --- | --- |
| DOC-PROMO-CALENDAR (SAVE10) | 코드(`shoply_rules.gd`)와 T09 요구사항은 최소 금액이 없다. 문서만 "over $30.00"이었다. | "SAVE10: everyone, 10% off the subtotal." / "SAVE10: 모든 고객, 소계 10% 할인." 따라서 검토의 "초과" 번역 제안은 이 원문 수정으로 대체됐다. |
| T27 보조 안내 | 원본 기록은 있지만 열 수 없다(레코드 `Original unavailable`). | "INC-1017's original record cannot be opened." / "INC-1017은 원본 기록을 열 수 없어요." |
| CH8 시놉시스 | 이 장의 T32·T34·T35·T36에는 실제 결함이 있다. 고장 나지 않은 것은 규칙이다. | "No rule in this chapter is broken." / "이 장에서 어긴 규칙은 없습니다." |
| T38 디브리핑 | 카메라 시각 21:40과 경보 23:06의 차이는 86분이고, 카메라 시각은 검증되지 않았다. | "About ninety minutes before the alarm, by the camera clock" / "카메라 시각으로 경보 약 90분 전" |

## 검증
- 한국어 키·용어·추리 문장 테스트를 포함해 Godot 테스트 전체 통과.
- 바뀐 영문 키 4개의 한국어가 모두 있다(`test_every_story_and_ticket_string_has_korean`).
