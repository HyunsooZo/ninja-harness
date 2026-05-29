# 작업 계획: governance integrity alignment

## 메타데이터

- 담당자: Codex
- 날짜: 2026-05-29
- 범위: governance, adoption scorecard, plan lifecycle, structure verification policy
- 위험 수준: medium
- 기본 실행자: `executor`
- Status: `DONE`
- 관련 컨텍스트: `docs/harness/ADOPTION_SCORECARD.md`, `docs/harness/GOVERNANCE.md`, `docs/harness/plans/README.md`

## 저장소 규칙 요약

- [x] `AGENTS.md` 읽음
- [x] `docs/harness/context/BASELINE.md` 읽음
- [x] `docs/harness/context/INDEX.md` 읽음
- [x] `docs/harness/README.md` 읽음
- [x] 관련 레이어/게이트 문서 읽음
- [x] 관련 `docs/harness/context/*` 읽음

## 사양

### 목표

조직 거버넌스, 적용 점수표, plan lifecycle 문서가 최종 무결성 기준과 일치하게 만들고, 구조 검증이 이 drift를 잡게 한다.

### 현재 상태

- `ADOPTION_SCORECARD.md`는 구조 검증 기준을 `HARNESS_VERIFY_MODE=project`로만 본다.
- `GOVERNANCE.md` 표준 적용 단계도 `make integrity`를 포함하지 않는다.
- `plans/README.md`는 completed plan 디렉터리를 배포본 `.gitkeep` 중심으로 설명해 현재 completed evidence 포함 방식과 맞지 않는다.

### 목표 상태

- adoption scorecard와 governance가 `make integrity`를 기준으로 삼는다.
- plan lifecycle 문서가 completed plan evidence와 template package의 관계를 정확히 설명한다.
- `verify-harness-structure.sh`가 governance/adoption/plans 문서의 integrity alignment를 강제한다.

### 하지 않을 일

- score threshold 자체를 재설계하지 않는다.
- 기존 completed plan을 삭제하지 않는다.
- 실제 프로젝트 gate requirement를 완화하지 않는다.

## 요구사항 추적

| 요구사항 | 인수 기준 | 테스트 / 검증 | 구현 위치 | 증거 |
|---|---|---|---|---|
| adoption 기준 정렬 | scorecard가 `make integrity`와 project readiness를 반영한다 | `make verify` | `ADOPTION_SCORECARD.md` | PASS |
| governance 단계 정렬 | governance rollout 단계가 `make integrity`를 포함한다 | `make verify` | `GOVERNANCE.md` | PASS |
| plan lifecycle 정렬 | completed plan 보관 정책이 현재 운영과 모순되지 않는다 | `make verify` | `plans/README.md` | PASS |
| 검증 강제 | verify script가 문서 정렬을 검사한다 | `make integrity` | `verify-harness-structure.sh` | pending |

## 에이전트 오케스트레이션

- 모드: `SINGLE_AGENT`
- 기본 실행자: Codex
- 분리 위임 여부: `no`
- 분리 이유: N/A
- 단일 실행으로 충분하지 않은 이유: N/A
- 공통 결정: 하네스 문서/검증 정책 변경만 수행
- 통합 담당자: Codex

### 레이어 영향도

| 레이어 | 영향 | 담당 에이전트 | 수정 가능 범위 | 검증 |
|---|---|---|---|---|
| Orchestration | `yes` | Codex | active/completed plan | `make check-plans` |
| Domain | `no` |  |  |  |
| Application | `no` |  |  |  |
| Persistence | `no` |  |  |  |
| Migration | `no` |  |  |  |
| API/Presentation | `no` |  |  |  |
| Test/Review | `yes` | Codex | governance docs/scripts | `make integrity` |

### 수렴 기준

- 중복 구현 확인: governance/adoption/plans docs use the same final integrity vocabulary
- 레이어 경계 확인: harness-only changes
- 계약 일치 확인: N/A
- 수정 범위 이탈 확인: git diff review
- 최종 VERIFY 명령: `make integrity`

## API 계약 영향도

API 요청/응답/DTO/status/error/pagination/auth/resource scope 변경이 아니므로 `N/A`.

- 변경 대상 API: N/A
- 우리 백엔드 API 여부: `n/a`
- 변경 방향: `n/a`
- 확인한 backend 파일/문서: N/A
- 확인한 frontend 파일/검색 범위: N/A
- 프론트 호출부 검색어: N/A
- API matrix 갱신 필요: `n/a`
- 양쪽 수정 필요 여부: `n/a`
- 수정하지 않는 경우 근거: governance/plan lifecycle 문서와 verify script 변경만 수행
- contract/test evidence: N/A

## 병렬화 점검

- 모드: `SEQUENTIAL`
- 결정: `sequential`
- 이유: 여러 정책 문서가 같은 integrity 기준을 공유한다.
- 공유 계약 고정 여부: `n/a`
- 겹치는 파일 여부: `yes`
- 트랜잭션 / 도메인 충돌 위험: `n/a`
- 통합 담당자: Codex

## 작업 목록

- [x] adoption/governance 문서 정렬
- [x] plans README completed policy 정렬
- [x] verify script 문서 정렬 검사 추가
- [x] 전체 검증 및 completed plan 이동
- [ ] `feat: ...` 커밋

## 테스트 계획

| 단계 | 명령 / 확인 | 기대 결과 | 메모 |
|---|---|---|---|
| RED | `rg -q "make integrity" docs/harness/ADOPTION_SCORECARD.md docs/harness/GOVERNANCE.md docs/harness/plans/README.md` | 기존 문서가 일관되게 못 찾음 | governance drift |
| GREEN | `make verify` | PASS | verify가 문서 정렬 검사 |
| REFACTOR | `make check-plans` | PASS | completed plan 품질 |
| VERIFY | `make integrity` | PASS | 최종 무결성 |

## 증거

### RED 증거

- 명령: `if rg -q "make integrity" docs/harness/ADOPTION_SCORECARD.md docs/harness/GOVERNANCE.md docs/harness/plans/README.md; then ...; else echo '[RED] governance/adoption/plan lifecycle docs still miss make integrity alignment'; fi`
- 실패 테스트 / 확인: governance/adoption/plan lifecycle docs가 `make integrity`를 일관되게 포함하지 않았다.
- 실패 이유: 최종 무결성 기준이 운영 거버넌스 문서까지 전파되지 않았다.
- 이 실패가 예상되는 이유: 직전 변경은 CI 예시와 ORG_ROLLOUT 중심이었다.
- RED가 부적합할 때의 예외 사유: N/A

### GREEN 증거

- 명령:
  - `make verify`
  - `make self-test-gates`
  - `git diff --check`
- 통과 테스트 / 확인:
  - `make verify` PASS, governance/adoption/plans 문서의 integrity alignment token 검사를 포함해 template/project 검증 통과.
  - `make self-test-gates` PASS, 8개 gate self-test 유지.
  - `git diff --check` PASS.
- 변경 파일:
  - `docs/harness/ADOPTION_SCORECARD.md`
  - `docs/harness/GOVERNANCE.md`
  - `docs/harness/plans/README.md`
  - `scripts/verify-harness-structure.sh`
  - `docs/harness/plans/completed/2026-05-29-governance-integrity-alignment.md`
- 구현이 최소 범위인 이유: 조직 운영 문서와 그 drift를 막는 검증만 변경했다.

### 리팩터링 기록

- 변경: adoption score threshold를 새 점수 배점에 맞춰 조정했다.
- 동작 영향: 조직 표준 후보 판단에서 `make integrity`와 project readiness를 반영한다.
- 재실행 명령: `make verify`

### 검증 보고

| 확인 | 명령 / 방법 | 결과 |
|---|---|---|
| 테스트 | `make self-test-gates` | PASS |
| 타입체크 / 빌드 | N/A | 하네스 문서/스크립트 변경 |
| 린트 / 정적 확인 | `make verify`; `git diff --check` | PASS |
| UI / 접근성 / 수동 확인 | N/A | UI 변경 없음 |
| 백엔드 안전성 | N/A | 제품 백엔드 변경 없음 |

### 건너뛴 검증

| 확인 | 이유 | 남은 위험 |
|---|---|---|
| 실제 프로젝트 build/test | 프로젝트별 gate script가 설정되지 않음 | 적용 저장소에서 `HARNESS_*_SCRIPT` 연결 필요 |

## 잔여 위험

- 실제 조직 표준 후보 판정은 completed plan, eval, regression 데이터가 쌓인 뒤에만 의미가 있다.
- `make integrity`는 local/package integrity이고, 실제 프로젝트 build/test/lint는 `HARNESS_*_SCRIPT` project gate 연결이 필요하다.

## 백엔드 구조 품질 게이트

백엔드 제품 코드 변경이 아니므로 `N/A`.
