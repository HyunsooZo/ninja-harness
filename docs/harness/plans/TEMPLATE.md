# 작업 계획: <work item>

## 메타데이터

- 담당자:
- 날짜:
- 범위:
- 위험 수준:
- 기본 실행자: `executor`
- Plan State: `draft`
- 관련 컨텍스트:

## 저장소 규칙 요약

- [ ] `AGENTS.md` 읽음
- [ ] `docs/harness/context/BASELINE.md` 읽음
- [ ] `docs/harness/context/INDEX.md` 읽음
- [ ] `docs/harness/README.md` 읽음
- [ ] 관련 레이어/게이트 문서 읽음
- [ ] 관련 `docs/harness/context/*` 읽음

## 사양

- 스펙 수준: `SPEC_LIGHT | SPEC_STANDARD | SPEC_DEEP`
- 사용자 / 행위자:
- 문제 / 기회:
- 성공 기준:
- 비성공 기준:

### 목표

### 현재 상태

### 목표 상태

### 하지 않을 일

### 가정 / 질문

### EARS 요구사항

| 유형 | 요구사항 | 인수 기준 | 검증 |
|---|---|---|---|
| 보편 / 조건 / 상태 / 예외 / 선택 |  |  |  |

### Story Slice

| Slice | 사용자 가치 | 포함 범위 | 제외 범위 | 완료 증거 |
|---|---|---|---|---|
|  |  |  |  |  |

## 요구사항 추적

| 요구사항 | 인수 기준 | 테스트 / 검증 | 구현 위치 | 증거 |
|---|---|---|---|---|
|  |  |  |  |  |

## 접근 방식

### 후보 접근

- A:
- B:

### 옵션 비교

| 옵션 | 사용자 가치 | 복잡도 | 테스트 가능성 | 계약/보안 영향 | 비용/지연 | 선택 |
|---|---|---|---|---|---|---|
| A |  |  |  |  |  |  |
| B |  |  |  |  |  |  |

### 결정


## 에이전트 오케스트레이션

- 모드: `SINGLE_AGENT | SINGLE_AGENT_WITH_REVIEW | SEQUENTIAL_LAYERED | PARALLEL_INVESTIGATION | PARALLEL_REVIEW | PARALLEL_IMPLEMENT`
- 기본 실행자:
- 분리 위임 여부: `yes | no`
- 분리 이유:
- 단일 실행으로 충분하지 않은 이유:
- 공통 결정:
- 통합 담당자:

### 비용 / 지연 가드

- 작업 가치:
- 예상 fanout:
- 시간/토큰 예산:
- 중단 기준:
- 축소 기준:

### 레이어 영향도

| 레이어 | 영향 | 담당 에이전트 | 수정 가능 범위 | 검증 |
|---|---|---|---|---|
| Orchestration | `yes/no` | `task-orchestrator` | active plan / dispatch only |  |
| Domain | `yes/no` |  |  |  |
| Application | `yes/no` |  |  |  |
| Persistence | `yes/no` |  |  |  |
| Migration | `yes/no` |  |  |  |
| API/Presentation | `yes/no` |  |  |  |
| Test/Review | `yes/no` |  |  |  |

### 수렴 기준

- 중복 구현 확인:
- 레이어 경계 확인:
- 계약 일치 확인:
- 수정 범위 이탈 확인:
- 최종 VERIFY 명령:

## API 계약 영향도

API 요청/응답/DTO/status/error/pagination/auth/resource scope 변경이 아니면 `N/A`로 표시한다.

- 변경 대상 API:
- 우리 백엔드 API 여부: `yes | no | unknown | n/a`
- 변경 방향: `frontend -> backend check | backend -> frontend check | both | n/a`
- 확인한 backend 파일/문서:
- 확인한 frontend 파일/검색 범위:
- 프론트 호출부 검색어:
- API matrix 갱신 필요: `yes | no | n/a`
- 양쪽 수정 필요 여부: `yes | no | unknown | n/a`
- 수정하지 않는 경우 근거:
- contract/test evidence:

## 병렬화 점검

- 모드: `SEQUENTIAL | PARALLEL_REVIEW | PARALLEL_IMPLEMENT | PARALLEL_INVESTIGATION`
- 결정: `parallel | sequential`
- 이유:
- 공유 계약 고정 여부: `yes | no | n/a`
- 겹치는 파일 여부: `yes | no`
- 트랜잭션 / 도메인 충돌 위험: `yes | no | n/a`
- 통합 담당자:

### 병렬 에이전트 디스패치

| 에이전트 | 역할 | 범위 | 수정 가능 파일 | 읽기 전용 파일 | 검증 | 상태 |
|---|---|---|---|---|---|---|
|  |  |  |  |  |  |  |

### 수렴 결과

- 충돌:
- 중복:
- 누락:
- 최종 통합 결정:

## 작업 목록

- [ ] 작업 1
  - 담당자:
  - 파일:
  - 인수 기준:
  - 검증:

- [ ] 작업 2
  - 담당자:
  - 파일:
  - 인수 기준:
  - 검증:

## 테스트 계획

| 단계 | 명령 / 확인 | 기대 결과 | 메모 |
|---|---|---|---|
| RED |  |  |  |
| GREEN |  |  |  |
| REFACTOR |  |  |  |
| VERIFY |  |  |  |

## 증거

### RED 증거

- 명령:
- 실패 테스트 / 확인:
- 실패 이유:
- 이 실패가 예상되는 이유:
- RED가 부적합할 때의 예외 사유:

### GREEN 증거

- 명령:
- 통과 테스트 / 확인:
- 변경 파일:
- 구현이 최소 범위인 이유:

### 리팩터링 기록

- 변경:
- 동작 영향:
- 재실행 명령:

### 검증 보고

| 확인 | 명령 / 방법 | 결과 |
|---|---|---|
| 테스트 |  |  |
| 타입체크 / 빌드 |  |  |
| 린트 / 정적 확인 |  |  |
| UI / 접근성 / 수동 확인 |  |  |
| 백엔드 안전성 |  |  |

### 건너뛴 검증

| 확인 | 이유 | 남은 위험 |
|---|---|---|
|  |  |  |


## 백엔드 구조 품질 게이트

백엔드 변경이 아니면 `N/A`로 표시한다. 백엔드 단순하지 않은 변경이면 `docs/harness/10_BACKEND_QUALITY_GATE.md` 기준으로 작성한다.

### DDD

- 판정:
- 도메인 에이전트: `backend-domain-modeler | n/a`
- 애그리거트 / 불변 조건:
- 도메인 / 영속성 분리: `clear | mixed with reason | n/a`
- 메모:

### 영속성

- 판정:
- 영속성 에이전트: `backend-persistence-implementer | n/a`
- 리포지토리 / ORM / 쿼리 / 잠금 영향:
- 도메인 누수 위험:
- 메모:

### 트랜잭션 관리

- 판정:
- 트랜잭션 경계:
- 멱등성 / 동시성:
- 메모:

### OOP

- 판정:
- 메모:

### 클린 코드

- 판정:
- 메모:

### SOLID

- 판정:
- SRP:
- OCP:
- LSP:
- ISP:
- DIP:

### 남은 위험

- 

## 리뷰 보고

| 리뷰 | 리뷰어 / 방법 | 판정 | 메모 |
|---|---|---|---|
| 스펙 |  |  |  |
| 통합 |  |  |  |
| 보안 |  |  |  |
| 접근성 / 반응형 |  |  |  |
| 최종 품질 |  |  |  |

## 리뷰 게이트

- [ ] 스펙 리뷰가 필요한가?
- [ ] 통합 리뷰가 필요한가?
- [ ] 보안 리뷰가 필요한가?
- [ ] 접근성/반응형 리뷰가 필요한가?
- [ ] 최종 품질 리뷰가 통과했는가?

## 실행 진행

- 대기 중

## 완료 보고

- 요약:
- 충족한 요구사항:
- 추가 / 변경한 테스트:
- 구현:
- 검증:
- 리뷰 판정:
- 남은 위험:
- 컨텍스트 문서 갱신:
- `docs/harness/context/BASELINE.md` / `DECISIONS.md` / 세부 컨텍스트 갱신 필요:
