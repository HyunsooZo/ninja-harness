# 14. 스펙 / 요구사항 게이트

이 문서는 실행 전에 "무엇을 왜 만드는가"를 충분히 좁히기 위한 상류 스펙 기준이다. 모든 작업에 장문의 PRD를 요구하지 않는다. 모호한 신규 기능, 큰 리팩토링, API/권한/런타임 변경에서만 확장한다.

## 적용 기준

| 수준 | 사용 조건 | 요구 산출물 |
|---|---|---|
| `SPEC_LIGHT` | 단일 버그, 작은 문구/스타일, 명확한 단일 변경 | 목표, 현재 상태, 목표 상태, 하지 않을 일 |
| `SPEC_STANDARD` | 일반 기능/수정, 사용자 흐름 변경 | 요구사항 추적표, 인수 기준, 대안 2개 이상 |
| `SPEC_DEEP` | 신규 제품 기능, 모호한 요구, API/권한/도메인/런타임 변경 | EARS 요구사항, 사용자/행위자, 성공/비성공 상태, 옵션 비교, story slice |

## EARS 요구사항

필요한 경우 아래 형식을 사용한다.

- 보편 요구: `The system shall <capability>.`
- 조건 요구: `When <trigger>, the system shall <response>.`
- 상태 요구: `While <state>, the system shall <response>.`
- 예외 요구: `If <condition>, the system shall <response>.`
- 선택 요구: `Where <feature is included>, the system shall <response>.`

한국어 계획에는 식별자와 enum은 원문으로 두고 문장은 한국어로 작성할 수 있다.

## 옵션 탐색

`SPEC_STANDARD` 이상은 최소 두 접근을 비교한다.

- 사용자 가치
- 구현 복잡도
- 테스트 가능성
- 계약/권한/보안 영향
- 되돌리기 쉬움
- 비용/지연

## Story Slice

큰 작업은 작게 쪼갠다.

| Slice | 사용자 가치 | 포함 범위 | 제외 범위 | 완료 증거 |
|---|---|---|---|---|
|  |  |  |  |  |

## 완료 기준

- 모호한 요구는 질문, 가정, 제외 범위 중 하나로 처리했다.
- EARS 또는 인수 기준이 테스트/검증 방법과 연결된다.
- 선택한 접근과 버린 접근의 이유가 기록돼 있다.
- story slice가 독립 검증 가능하다.
