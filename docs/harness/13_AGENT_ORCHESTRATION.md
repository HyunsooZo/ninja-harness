# 13. 에이전트 오케스트레이션 게이트

이 문서는 하나의 작업을 어떤 에이전트에게 맡길지 결정한다. 레이어별 에이전트 분리는 **항상 여러 에이전트를 실행하라는 뜻이 아니다.** 기본 원칙은 작업을 가장 작고 안전한 단위로 처리하고, 충돌 위험이 낮을 때만 분리 위임한다.

## 전담 오케스트레이터

복합 작업은 `task-orchestrator`가 먼저 분류한다. `task-orchestrator`는 제품 코드를 직접 구현하지 않고 active plan, 위임 순서, 수정 가능 범위, fan-in 기준, VERIFY/review 라우팅을 결정한다.

- Codex: `.codex/agents/task-orchestrator.toml`
- Claude: `.claude/agents/task-orchestrator.md`
- Skill: `.agents/skills/orchestration-planning/SKILL.md` / `.claude/skills/orchestration-planning/SKILL.md`

## 핵심 원칙

- 기본값은 `SINGLE_AGENT`다.
- 레이어별 에이전트는 전문가 역할이다. 작업이 해당 전문성에 걸릴 때만 호출한다.
- 작은 단일 수정은 한 에이전트가 처리한다.
- 큰 작업 감지 신호가 있으면 main agent가 혼자 구현하지 않고 `task-orchestrator` 또는 `orchestration-planning` skill로 먼저 계획한다.
- 여러 레이어의 도메인 규칙, 트랜잭션, 영속성, API 계약이 함께 바뀌면 `SEQUENTIAL_LAYERED`를 우선 고려한다.
- 병렬 실행은 오케스트레이션의 일부일 뿐이다. 병렬 여부는 `11_PARALLEL_AGENT_GATE.md`로 별도 확인한다.
- 분리 위임 후에는 반드시 단일 통합자가 결정사항, 충돌, 중복 구현, 검증 결과를 수렴한다.

## 비용 / 지연 가드

분리 위임은 품질을 높일 때만 정당화된다. 아래 항목을 active plan에 남기지 못하면 `SINGLE_AGENT` 또는 `SINGLE_AGENT_WITH_REVIEW`로 낮춘다.

| 항목 | 기준 |
|---|---|
| 작업 가치 | 실패 비용, 보안/계약 위험, 회귀 위험이 fanout 비용보다 크다 |
| 예상 fanout | 구현 에이전트 수, 읽기 전용 리뷰어 수, fan-in 횟수를 적는다 |
| 시간/토큰 예산 | 허용 가능한 지연과 재검증 횟수를 적는다 |
| 중단 기준 | 같은 blocker가 2회 반복되거나 계약이 흔들리면 통합자가 scope를 줄인다 |
| 축소 기준 | 독립성이 사라지거나 파일 범위가 겹치면 순차 또는 단일 실행으로 낮춘다 |

권장 상한은 기본적으로 구현 에이전트 1~3개, 읽기 전용 리뷰어 1~2개다. 이를 넘기려면 active plan에 수치화된 이유와 대체안을 남긴다.

## 모드

| 모드 | 사용 조건 | 실행 방식 |
|---|---|---|
| `SINGLE_AGENT` | 단일 파일/단일 레이어/낮은 위험 | 한 implementer가 계획, 구현, 검증을 수행 |
| `SINGLE_AGENT_WITH_REVIEW` | 변경은 작지만 보안/계약/접근성/테스트 충분성 위험 있음 | 한 implementer + 필요한 read-only reviewer |
| `SEQUENTIAL_LAYERED` | 여러 레이어가 순서 의존성을 가짐 | domain -> application -> persistence -> migration -> api -> test/review 순으로 진행 |
| `PARALLEL_INVESTIGATION` | 구현 전 영향도 조사를 나눌 수 있음 | 읽기 전용 조사만 병렬 수행 |
| `PARALLEL_REVIEW` | 구현 후 독립 검토가 유용함 | 보안/통합/품질/접근성 리뷰를 병렬 수행 |
| `PARALLEL_IMPLEMENT` | 계약이 고정됐고 파일 범위가 겹치지 않음 | 제한적으로 구현 병렬화 후 단일 통합자가 수렴 |

## 큰 작업 감지 신호

아래 중 하나라도 해당하면 `task-orchestrator`를 우선 사용한다.

- 도메인 불변 조건, aggregate boundary, 상태 전이, 정책이 바뀐다.
- application service의 use case 흐름, transaction boundary, idempotency가 바뀐다.
- repository/query/lock/pagination/mapping/migration/schema/index가 바뀐다.
- controller/DTO/validation/error response/API contract가 바뀐다.
- 권한, 인증, 리소스 범위, 소유/소속 검증이 바뀐다.
- 프론트/백 제공자-소비자 계약이 함께 바뀐다. 특히 owned API의 DTO/request/response/status/error/pagination/auth/resource scope 변경은 영향도 확인 대상이다.
- 테스트 전략이 단위/통합/e2e 여러 층에 걸친다.

## 단일 에이전트로 충분한 경우

아래는 보통 여러 레이어 에이전트를 호출하지 않는다.

- 오타, 문구, 라벨, 에러 메시지 수정
- 단일 DTO/응답 필드 이름 정리
- 단일 테스트 assertion 또는 mock 수정
- 단일 화면의 작은 스타일 보정
- 문서 일부 수정
- 명확한 단일 버그 수정이며 도메인/트랜잭션/스키마/API 계약이 변하지 않음

이 경우 active plan이 필요 없을 수 있다. 다만 동작 변경이 있으면 최소한 검증 방법은 보고한다.

## Owned API 변경 오케스트레이션

아래 신호가 있으면 `SINGLE_AGENT`로 바로 구현하지 말고 Owned API Contract Impact Rule을 먼저 적용한다.

- 프론트 API client/type/hook/composable/query key/schema를 수정한다.
- 백엔드 controller/route/DTO/schema/status/error/pagination/auth/resource scope를 수정한다.
- API matrix의 route owner, allowed consumer, masking, wrapper 필요 여부가 바뀐다.
- 화면의 로딩/빈/오류/권한 없음 상태가 API 응답 구조에 의존한다.

권장 흐름:

1. `task-orchestrator`: 변경 API, route owner, 소비자 후보, 영향 레이어를 active plan에 기록한다.
2. 프론트발 변경이면 backend API 의도와 contract surface를 먼저 확인한다.
3. 백엔드발 변경이면 endpoint/path/type/query key/hook/store/component/test를 검색해 프론트 호출부를 확인한다.
4. 양쪽 수정이 필요하면 `SEQUENTIAL_LAYERED` 또는 `SINGLE_AGENT_WITH_REVIEW`로 전환하고 `integration-reviewer`를 라우팅한다.
5. 한쪽 수정이 불필요하면 검색/확인 근거를 active plan의 API 계약 영향도 블록에 남긴다.

## 백엔드 레이어 소유권

| 레이어 | 주 에이전트 | 소유 기준 | 주의 |
|---|---|---|---|
| Orchestration | `task-orchestrator` | 모드 선택, 위임 순서, 수정 범위, 통합 담당자, fan-in 기준 | 제품 코드를 직접 구현하지 않는다 |
| Domain | `backend-domain-modeler` | aggregate, entity, value object, invariant, state transition, business rule | 저장 방식이나 HTTP 표현에 끌려가지 않는다 |
| Application | `backend-application-implementer` | use case orchestration, transaction boundary, idempotency, external call ordering | 도메인 규칙을 중복 구현하지 않는다 |
| Persistence | `backend-persistence-implementer` | repository, ORM mapping, query, lock, pagination, persistence test | 도메인 규칙을 query에 숨기지 않는다 |
| Migration | `backend-db-migration-implementer` | schema, index, seed, runtime dependency, migration order | domain/persistence 결정 후 순서 검토 |
| API/Presentation | `backend-api-implementer` | controller, DTO, validation, response/error mapping | business rule을 controller에 넣지 않는다 |
| Review | `backend-security-reviewer`, `integration-reviewer`, `quality-reviewer` | auth/resource scope, contract, regression risk | 읽기 전용으로 판정만 남긴다 |

## 권장 백엔드 순서

대부분의 백엔드 교차 변경은 아래 순서가 안전하다.

1. `task-orchestrator`: 오케스트레이션 모드, 레이어 영향도, 위임 순서, fan-in 기준을 정한다.
2. `backend-domain-modeler`: 도메인 규칙, 불변 조건, 상태 전이를 확정한다.
3. `backend-application-implementer`: use case 흐름, transaction boundary, idempotency를 확정한다.
4. `backend-persistence-implementer`: repository/query/lock/mapping을 반영한다.
5. `backend-db-migration-implementer`: schema/index/migration 순서를 반영한다.
6. `backend-api-implementer`: DTO/validation/error response/API contract를 반영한다.
7. `test-automation-reviewer`: RED/GREEN/VERIFY 충분성을 검토한다.
8. `integration-reviewer` / `backend-security-reviewer` / `quality-reviewer`: 계약, 권한, 최종 품질을 검토한다.

이 순서는 기본값일 뿐이다. 단일 레이어 작업이면 해당 단계만 수행한다.

## 충돌 방지 규칙

- 같은 aggregate를 두 에이전트가 동시에 수정하지 않는다.
- 같은 repository interface를 domain/persistence가 동시에 바꾸지 않는다.
- transaction boundary는 application 또는 단일 통합자가 최종 결정한다.
- migration/schema는 domain/persistence 결정이 흔들리는 동안 병렬 작성하지 않는다.
- controller validation과 domain invariant를 중복 구현하지 않는다.
- repository query에 권한/도메인 정책을 숨기지 않는다. 필요한 정책은 application/domain에서 명시한다.
- 위임한 에이전트별 결정은 active plan의 `공통 결정`과 `수렴 결과`에 반영한다.

## 오케스트레이션 기록 형식

단순하지 않은 작업은 active plan에 아래 블록을 남긴다.

```md
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
```


## API 계약 영향도

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

## fan-in 완료 기준

분리 위임 후 `task-orchestrator` 또는 active plan의 통합 담당자는 아래를 확인한다.

- 공통 결정과 실제 변경이 일치한다.
- 같은 규칙을 domain/application/controller/query에 중복 구현하지 않았다.
- transaction boundary와 domain state transition이 충돌하지 않는다.
- migration/schema와 repository mapping이 일치한다.
- API contract와 소비자 기대가 일치한다.
- 각 에이전트가 수정 가능 범위를 벗어나지 않았다.
- VERIFY와 필요한 read-only review가 끝났다.

## 완료 기준

- 선택한 모드가 active plan에 기록되어 있다.
- 큰 작업이면 `task-orchestrator` 또는 `orchestration-planning` skill 사용 여부가 기록되어 있다.
- 분리 위임 시 각 에이전트의 수정 가능 범위가 겹치지 않는다.
- 공통 결정과 통합 담당자가 기록되어 있다.
- 단일 통합자가 중복 구현, 레이어 경계, 계약 일치를 확인했다.
- VERIFY와 필요한 read-only review가 끝났다.
