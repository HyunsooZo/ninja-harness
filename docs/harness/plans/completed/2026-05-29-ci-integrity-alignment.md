# 작업 계획: CI integrity alignment

## 메타데이터

- 담당자: Codex
- 날짜: 2026-05-29
- 범위: CI examples, organization rollout guidance, project gate self-test coverage
- 위험 수준: medium
- 기본 실행자: `executor`
- Status: `DONE`
- 관련 컨텍스트: `docs/harness/CI_EXAMPLES.md`, `docs/harness/ORG_ROLLOUT.md`, `scripts/self-test-harness-gates.sh`

## 저장소 규칙 요약

- [x] `AGENTS.md` 읽음
- [x] `docs/harness/context/BASELINE.md` 읽음
- [x] `docs/harness/context/INDEX.md` 읽음
- [x] `docs/harness/README.md` 읽음
- [x] 관련 레이어/게이트 문서 읽음
- [x] 관련 `docs/harness/context/*` 읽음

## 사양

### 목표

로컬 최종 무결성 게이트가 CI/조직 표준 문서에도 일관되게 반영되고, project gate self-test가 허용/차단 경로를 더 직접 검증하게 만든다.

### 현재 상태

- `make integrity`는 존재하지만 CI 예시와 조직 롤아웃 문서는 아직 `make verify` 중심이다.
- self-test는 invalid gate rejection은 확인하지만, allowlisted repository script gate 성공 경로와 required/legacy 차단 경로는 직접 확인하지 않는다.

### 목표 상태

- CI 예시와 GitHub Actions 예시가 `make integrity`를 구조/로컬 무결성 단계로 사용한다.
- 조직 롤아웃 체크리스트가 `make integrity`를 포함한다.
- self-test가 script gate positive, required project gate negative, legacy command org-mode block을 포함한다.
- 구조 검증이 CI 예시와 self-test token을 강제한다.

### 하지 않을 일

- 실제 프로젝트용 `scripts/ci/*.sh` 파일을 배포하지 않는다.
- project gate script 내용을 특정 stack으로 고정하지 않는다.
- 기존 `verify-org` 정책을 완화하지 않는다.

## 요구사항 추적

| 요구사항 | 인수 기준 | 테스트 / 검증 | 구현 위치 | 증거 |
|---|---|---|---|---|
| CI integrity 정렬 | CI docs/examples가 `make integrity`를 사용한다 | `make verify` | `docs/harness/CI_EXAMPLES.md`, examples workflow | PASS |
| self-test 강화 | positive script gate와 negative required/legacy cases가 검증된다 | `make self-test-gates` | `scripts/self-test-harness-gates.sh` | PASS |
| 구조 검증 강제 | verify script가 새 CI/self-test 기준을 검사한다 | `make verify` | `scripts/verify-harness-structure.sh` | PASS |
| 최종 무결성 | 전체 local integrity가 통과한다 | `make integrity` | Makefile/scripts/docs | pending |

## 에이전트 오케스트레이션

- 모드: `SINGLE_AGENT`
- 기본 실행자: Codex
- 분리 위임 여부: `no`
- 분리 이유: N/A
- 단일 실행으로 충분하지 않은 이유: N/A
- 공통 결정: 하네스 문서/검증 스크립트 변경만 수행
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
| Test/Review | `yes` | Codex | CI docs/scripts | `make integrity` |

### 수렴 기준

- 중복 구현 확인: CI examples and Makefile semantics match
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
- 수정하지 않는 경우 근거: 하네스 CI 문서/검증 스크립트 변경만 수행
- contract/test evidence: N/A

## 병렬화 점검

- 모드: `SEQUENTIAL`
- 결정: `sequential`
- 이유: CI 문서와 verify script가 같은 정책을 공유한다.
- 공유 계약 고정 여부: `n/a`
- 겹치는 파일 여부: `yes`
- 트랜잭션 / 도메인 충돌 위험: `n/a`
- 통합 담당자: Codex

## 작업 목록

- [x] CI examples를 `make integrity` 기준으로 정렬
- [x] self-test project gate coverage 확장
- [x] verify script에 새 정책 검사 추가
- [x] 전체 검증 및 completed plan 이동
- [ ] `feat: ...` 커밋

## 테스트 계획

| 단계 | 명령 / 확인 | 기대 결과 | 메모 |
|---|---|---|---|
| RED | `rg -q "make integrity" docs/harness/CI_EXAMPLES.md docs/harness/examples/github-actions/harness-verify.yml docs/harness/ORG_ROLLOUT.md` | 기존 문서가 일관되게 못 찾음 | CI 정렬 공백 |
| GREEN | `make self-test-gates` | PASS | project gate allow/block 검증 |
| REFACTOR | `make verify` | PASS | 구조 검증 통합 |
| VERIFY | `make integrity` | PASS | 최종 무결성 |

## 증거

### RED 증거

- 명령: `if rg -q "make integrity" docs/harness/CI_EXAMPLES.md docs/harness/examples/github-actions/harness-verify.yml docs/harness/ORG_ROLLOUT.md; then ...; else echo '[RED] CI/org docs do not consistently use make integrity yet'; fi`
- 실패 테스트 / 확인: CI/org 문서가 `make integrity`를 일관되게 포함하지 않았다.
- 실패 이유: 새 최종 local integrity gate가 CI/조직 안내에 수렴되지 않았다.
- 이 실패가 예상되는 이유: 직전 변경은 README/Quickstart/Audit 중심이었다.
- RED가 부적합할 때의 예외 사유: N/A

### GREEN 증거

- 명령:
  - `make self-test-gates`
  - `make verify`
- 통과 테스트 / 확인:
  - `make self-test-gates` PASS, 8개 gate self-test 통과.
  - `make verify` PASS, CI example의 `make integrity` 사용과 확장된 self-test token 검사를 포함해 template/project 검증 통과.
  - self-test가 만든 임시 `scripts/ci/.harness-self-test-ok.sh`는 cleanup되어 배포 파일로 남지 않았다.
- 변경 파일:
  - `docs/harness/CI_EXAMPLES.md`
  - `docs/harness/examples/github-actions/harness-verify.yml`
  - `docs/harness/ORG_ROLLOUT.md`
  - `scripts/self-test-harness-gates.sh`
  - `scripts/verify-harness-structure.sh`
  - `docs/harness/plans/completed/2026-05-29-ci-integrity-alignment.md`
- 구현이 최소 범위인 이유: CI/조직 안내와 gate self-test 정책만 정렬하고, 실제 프로젝트 CI script는 생성하지 않았다.

### 리팩터링 기록

- 변경: self-test에서 임시 allowlisted script gate를 생성/삭제하도록 cleanup 경로를 추가했다.
- 동작 영향: 배포 산출물에는 dummy CI script가 남지 않는다.
- 재실행 명령: `make self-test-gates`, `make verify`

### 검증 보고

| 확인 | 명령 / 방법 | 결과 |
|---|---|---|
| 테스트 | `make self-test-gates` | PASS |
| 타입체크 / 빌드 | N/A | 하네스 문서/스크립트 변경 |
| 린트 / 정적 확인 | `make verify` | PASS |
| UI / 접근성 / 수동 확인 | N/A | UI 변경 없음 |
| 백엔드 안전성 | N/A | 제품 백엔드 변경 없음 |

### 건너뛴 검증

| 확인 | 이유 | 남은 위험 |
|---|---|---|
| 실제 프로젝트 build/test | 프로젝트별 gate script가 설정되지 않음 | 적용 저장소에서 `HARNESS_*_SCRIPT` 연결 필요 |

## 잔여 위험

- `make integrity`는 active plan이 남아 있으면 실패하므로 이 plan을 completed로 이동한 뒤 최종 실행한다.
- 실제 CI에서 프로젝트 build/test/lint를 보장하려면 각 저장소가 `scripts/ci/**` gate script를 별도로 제공해야 한다.

## 백엔드 구조 품질 게이트

백엔드 제품 코드 변경이 아니므로 `N/A`.
