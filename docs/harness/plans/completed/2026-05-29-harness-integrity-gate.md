# 작업 계획: harness integrity gate

## 메타데이터

- 담당자: Codex
- 날짜: 2026-05-29
- 범위: final integrity command, negative gate self-tests, release-grade harness verification docs
- 위험 수준: medium
- 기본 실행자: `executor`
- Status: `DONE`
- 관련 컨텍스트: `docs/harness/README.md`, `docs/harness/08_HARNESS_AUDIT.md`, `Makefile`

## 저장소 규칙 요약

- [x] `AGENTS.md` 읽음
- [x] `docs/harness/context/BASELINE.md` 읽음
- [x] `docs/harness/context/INDEX.md` 읽음
- [x] `docs/harness/README.md` 읽음
- [x] 관련 레이어/게이트 문서 읽음
- [x] 관련 `docs/harness/context/*` 읽음

## 사양

### 목표

기본 구조 검증을 넘어, 최종 하네스 무결성을 한 명령으로 확인하고 중요한 failure gate가 실제로 실패하는지 self-test한다.

### 현재 상태

- `make doctor`, `make verify`, `make check-plans`는 통과한다.
- 최종 무결성 확인을 묶는 `make integrity` target은 없다.
- readiness/project gate 같은 negative behavior를 별도 self-test target으로 검증하지 않는다.

### 목표 상태

- `make integrity`가 최종 무결성 확인의 단일 진입점이 된다.
- `scripts/self-test-harness-gates.sh`가 주요 negative/positive gate 동작을 검증한다.
- 구조 검증이 새 integrity target과 self-test script 존재를 강제한다.
- README/Quickstart/Audit 문서가 `make integrity` 사용 시점을 명확히 안내한다.

### 하지 않을 일

- 실제 프로젝트 build/test/lint를 임의 연결하지 않는다.
- git clean 상태를 강제하지 않는다. 사용자가 커밋 전 검증할 수 있어야 한다.
- template placeholder 자체를 제거하지 않는다.

## 요구사항 추적

| 요구사항 | 인수 기준 | 테스트 / 검증 | 구현 위치 | 증거 |
|---|---|---|---|---|
| 단일 무결성 진입점 | `make integrity` target 존재 및 통과 | `make integrity` | `Makefile` | PASS |
| gate self-test | invalid verify mode, profile readiness positive/negative, invalid project gate가 검증된다 | `make self-test-gates` | `scripts/self-test-harness-gates.sh` | PASS |
| 구조 검증 강제 | verify script가 target/script 문서화를 확인한다 | `make verify` | `scripts/verify-harness-structure.sh` | PASS |
| 문서 안내 | README/Quickstart/Audit가 final integrity check를 안내한다 | `make verify` | docs/harness/** | PASS |

## 에이전트 오케스트레이션

- 모드: `SINGLE_AGENT`
- 기본 실행자: Codex
- 분리 위임 여부: `no`
- 분리 이유: N/A
- 단일 실행으로 충분하지 않은 이유: N/A
- 공통 결정: 하네스 스크립트/문서 보강이며 제품 레이어 영향 없음
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
| Test/Review | `yes` | Codex | Makefile/scripts/docs | `make integrity` |

### 수렴 기준

- 중복 구현 확인: no overlapping integrity/self-test entrypoints with conflicting semantics
- 레이어 경계 확인: harness-only files
- 계약 일치 확인: N/A
- 수정 범위 이탈 확인: git diff review
- 최종 VERIFY 명령: `make integrity`, `make verify`, `make check-plans`, `git diff --check`

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
- 수정하지 않는 경우 근거: 하네스 스크립트/문서 변경만 수행
- contract/test evidence: N/A

## 병렬화 점검

- 모드: `SEQUENTIAL`
- 결정: `sequential`
- 이유: Makefile, verify script, docs가 같은 integrity contract를 공유한다.
- 공유 계약 고정 여부: `n/a`
- 겹치는 파일 여부: `yes`
- 트랜잭션 / 도메인 충돌 위험: `n/a`
- 통합 담당자: Codex

## 작업 목록

- [x] `make integrity` / `make self-test-gates` target 추가
- [x] self-test script 추가
- [x] verify script가 새 integrity contract를 강제하도록 보강
- [x] README/Quickstart/Audit 문서 보강
- [x] 전체 검증 및 completed plan 이동

## 테스트 계획

| 단계 | 명령 / 확인 | 기대 결과 | 메모 |
|---|---|---|---|
| RED | `make integrity` | target 없음으로 실패 | 현재 공백 확인 |
| GREEN | `make integrity` | PASS | self-test 포함 |
| REFACTOR | `make verify` | PASS | 구조 검증 통합 |
| VERIFY | `make check-plans`, `git diff --check` | PASS | 완료 품질/whitespace |

## 증거

### RED 증거

- 명령: `make integrity`
- 실패 테스트 / 확인: `make: *** No rule to make target 'integrity'.  Stop.`
- 실패 이유: 최종 무결성 단일 진입점이 없었다.
- 이 실패가 예상되는 이유: 기존 Makefile은 doctor/verify/check-plans를 분리 제공했다.
- RED가 부적합할 때의 예외 사유: N/A

### GREEN 증거

- 명령:
  - `make self-test-gates`
  - `make verify`
  - `make integrity` before moving active plan
  - `make integrity` after moving active plan to completed
- 통과 테스트 / 확인:
  - `make self-test-gates` PASS: profile readiness positive/negative, invalid verify mode, filled-profile template misuse, absolute project gate path rejection.
  - `make verify` PASS: template/project structure verification passed and now enforces the new integrity target/script contract.
  - `make integrity` reached the intended final active-plan gate and failed only because this plan was still active.
  - Final `make integrity` PASS after active plan was moved to completed.
- 변경 파일:
  - `Makefile`
  - `scripts/self-test-harness-gates.sh`
  - `scripts/verify-harness-structure.sh`
  - `AGENTS.md`, `CLAUDE.md`
  - `docs/harness/README.md`
  - `docs/harness/QUICKSTART_5_MIN.md`
  - `docs/harness/08_HARNESS_AUDIT.md`
  - `docs/harness/harness.yaml`
- 구현이 최소 범위인 이유: 최종 integrity 진입점과 그 self-test만 추가하고, 프로젝트별 gate나 실제 제품 검증은 기존 `HARNESS_*_SCRIPT` 정책에 남겼다.

### 리팩터링 기록

- 변경: self-test를 `make integrity`와 분리해 개별 실행 가능하게 유지했다.
- 동작 영향: 최종 integrity target은 active plan이 남아 있으면 실패한다.
- 재실행 명령: `make self-test-gates`, `make verify`, final `make integrity`

### 검증 보고

| 확인 | 명령 / 방법 | 결과 |
|---|---|---|
| 테스트 | `make self-test-gates`; `make integrity` | PASS |
| 타입체크 / 빌드 | N/A | 하네스 문서/스크립트 변경 |
| 린트 / 정적 확인 | `make verify` | PASS |
| UI / 접근성 / 수동 확인 | N/A | UI 변경 없음 |
| 백엔드 안전성 | N/A | 제품 백엔드 변경 없음 |

### 건너뛴 검증

| 확인 | 이유 | 남은 위험 |
|---|---|---|
| 실제 프로젝트 build/test | 프로젝트별 gate script가 설정되지 않음 | 적용 저장소에서 `HARNESS_*_SCRIPT` 연결 필요 |

## 잔여 위험

- `make integrity`는 local/package integrity를 검증한다. 실제 프로젝트의 build/test/lint 품질은 `HARNESS_*_SCRIPT` project gate 연결 후 `make verify-org`로 확인해야 한다.
- `make integrity`는 active plan이 남아 있으면 실패하므로, 작업 중간에는 `make verify`와 `make self-test-gates`를 먼저 사용하고 완료 직전에 active plan을 completed로 이동한 뒤 실행한다.

## 백엔드 구조 품질 게이트

백엔드 제품 코드 변경이 아니므로 `N/A`.
