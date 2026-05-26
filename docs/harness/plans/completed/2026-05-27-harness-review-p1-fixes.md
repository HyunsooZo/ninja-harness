# 작업 계획: harness review P1 fixes

## 메타데이터

- 담당자: Codex
- 날짜: 2026-05-27
- 범위: GitHub Actions 예시 활성화 문제, Python assert 기반 검증 무력화 문제
- 위험 수준: medium
- 기본 실행자: `executor`
- Status: `completed`
- 관련 컨텍스트: `AGENTS.md`, `docs/harness/README.md`, `docs/harness/05_TESTING.md`, `docs/harness/08_HARNESS_AUDIT.md`, `docs/harness/09_EVIDENCE_GATE.md`

## 저장소 규칙 요약

- [x] `AGENTS.md` 읽음
- [x] `docs/harness/context/BASELINE.md` 읽음
- [x] `docs/harness/context/INDEX.md` 읽음
- [x] `docs/harness/README.md` 읽음
- [x] 관련 레이어/게이트 문서 읽음
- [x] 관련 `docs/harness/context/*` 읽음

## 사양

### 목표

- 배포된 템플릿에서 GitHub Actions example이 활성 workflow로 오동작하지 않게 한다.
- `PYTHONOPTIMIZE=1` 환경에서도 하네스 구조 검증이 무력화되지 않게 한다.

### 현재 상태

- `.github/workflows/harness-verify.example.yml`이 실제 GitHub Actions workflow 경로에 있고, 존재하지 않는 `scripts/ci/*.sh` gate를 호출한다.
- `scripts/verify-harness-structure.sh`의 Python 검증 대부분이 `assert`에 의존한다.

### 목표 상태

- GitHub Actions 예시는 비활성 문서/example 경로에 보관하고, 검증/문서는 새 경로를 참조한다.
- 검증 Python 코드는 `assert` 대신 명시적 실패 helper를 사용한다.

### 하지 않을 일

- 실제 프로젝트 gate script를 더미로 추가하지 않는다.
- 하네스 정책 자체를 완화하지 않는다.
- 커밋/푸시는 하지 않는다.

### 가정 / 질문

- 현재 요청은 구현과 검증까지이며, commit/push는 별도 요청 전에는 수행하지 않는다.

## 요구사항 추적

| 요구사항 | 인수 기준 | 테스트 / 검증 | 구현 위치 | 증거 |
|---|---|---|---|---|
| Actions example 비활성화 | `.github/workflows`에 활성 example workflow가 남지 않음 | `find .github/workflows -maxdepth 1 -type f` 확인, `make verify` | `.github/workflows`, `docs/harness/examples/**`, docs/script refs | RED/GREEN/VERIFY |
| Python optimize 안전성 | `PYTHONOPTIMIZE=1`에서도 invalid model check 실패 | wrapped optimize negative command | `scripts/verify-harness-structure.sh` | RED/GREEN/VERIFY |

## 접근 방식

### 결정

- GitHub Actions 예시는 `docs/harness/examples/github-actions/harness-verify.yml`로 이동한다.
- `verify-harness-structure.sh`는 Python `check()` helper로 실패를 명시하고, 모든 `assert`를 `check(...)` 또는 직접 예외로 교체한다.

## 에이전트 오케스트레이션

- 모드: `SINGLE_AGENT`
- 기본 실행자: Codex
- 분리 위임 여부: `no`
- 분리 이유: N/A
- 단일 실행으로 충분하지 않은 이유: N/A
- 공통 결정: 하네스 유지보수 범위의 문서/스크립트 수정
- 통합 담당자: Codex

### 레이어 영향도

| 레이어 | 영향 | 담당 에이전트 | 수정 가능 범위 | 검증 |
|---|---|---|---|---|
| Orchestration | `no` | `task-orchestrator` | N/A | N/A |
| Domain | `no` | N/A | N/A | N/A |
| Application | `no` | N/A | N/A | N/A |
| Persistence | `no` | N/A | N/A | N/A |
| Migration | `no` | N/A | N/A | N/A |
| API/Presentation | `no` | N/A | N/A | N/A |
| Test/Review | `yes` | Codex | harness verification scripts/docs | `make verify`, negative checks |

### 수렴 기준

- 중복 구현 확인: 단일 수정
- 레이어 경계 확인: 하네스 문서/스크립트 범위만 변경
- 계약 일치 확인: docs, Makefile/script 검증 참조 일치
- 수정 범위 이탈 확인: 제품 코드 없음
- 최종 VERIFY 명령: `make verify`, `make check-plans`, negative optimize check

## API 계약 영향도

API 요청/응답/DTO/status/error/pagination/auth/resource scope 변경이 아니면 `N/A`로 표시한다.

- 변경 대상 API: N/A
- 우리 백엔드 API 여부: `n/a`
- 변경 방향: `n/a`
- 확인한 backend 파일/문서: N/A
- 확인한 frontend 파일/검색 범위: N/A
- 프론트 호출부 검색어: N/A
- API matrix 갱신 필요: `n/a`
- 양쪽 수정 필요 여부: `n/a`
- 수정하지 않는 경우 근거: 하네스 문서/검증 스크립트 변경
- contract/test evidence: N/A

## 병렬화 점검

- 모드: `SEQUENTIAL`
- 결정: `sequential`
- 이유: 같은 검증 정책과 문서 참조를 함께 수렴해야 함
- 공유 계약 고정 여부: `n/a`
- 겹치는 파일 여부: `yes`
- 트랜잭션 / 도메인 충돌 위험: `n/a`
- 통합 담당자: Codex

## 테스트 계획

| 단계 | 명령 / 확인 | 기대 결과 | 메모 |
|---|---|---|---|
| RED | org gate example command | 실패 | 현재 활성 workflow 예시의 broken gate 재현 |
| RED | optimize invalid model wrapper | 실패 | 현재 optimize 환경에서 검증 무력화 재현 |
| GREEN | same negative checks | 의도한 방향으로 통과/실패 | invalid model은 실패해야 함 |
| VERIFY | `make verify`, `make check-plans` | 통과 | 구조 전체 검증 |

## 증거

### RED 증거

- 명령: `HARNESS_VERIFY_MODE=project HARNESS_ORG_STANDARD=1 HARNESS_ACK_TRUSTED_PROJECT_CMDS=1 HARNESS_BACKEND_TEST_SCRIPT='scripts/ci/backend-test.sh' HARNESS_PRIMARY_FRONTEND_TEST_SCRIPT='scripts/ci/primary-frontend-test.sh' bash scripts/verify-harness-structure.sh`
- 실패 테스트 / 확인: exit 2
- 실패 이유: `[FAIL] script gate not found: scripts/ci/backend-test.sh`
- 이 실패가 예상되는 이유: `.github/workflows/harness-verify.example.yml`이 실제 workflow 위치에서 없는 gate script를 참조한다.

- 명령: `if PYTHONOPTIMIZE=1 HARNESS_EXPECTED_CODEX_MODEL='definitely-not-the-model' HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh ...; then ... exit 1; fi`
- 실패 테스트 / 확인: wrapper exit 1
- 실패 이유: optimized verify accepted invalid model
- 이 실패가 예상되는 이유: Python `assert`가 optimize mode에서 제거된다.

### GREEN 증거

- 명령: `if [ -d .github/workflows ] && find .github/workflows -maxdepth 1 -type f | grep -q .; then ...; else echo '[OK] no active workflow files in .github/workflows'; fi`
- 통과 테스트 / 확인: `[OK] no active workflow files in .github/workflows`
- 변경 파일: `.github/workflows/harness-verify.example.yml` 삭제, `docs/harness/examples/github-actions/harness-verify.yml` 추가, 관련 README/CI 예시/manifest 참조 갱신
- 구현이 최소 범위인 이유: 활성 workflow로 실행되는 example만 비활성 문서 경로로 이동했고, 실제 gate 정책은 유지했다.

- 명령: `if PYTHONOPTIMIZE=1 HARNESS_EXPECTED_CODEX_MODEL='definitely-not-the-model' HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh ...; then ... exit 1; else ...; fi`
- 통과 테스트 / 확인: `[FAIL] Python optimization mode is not supported for harness verification...` 후 wrapper `[OK] optimized verify rejected unsafe mode/invalid model`
- 변경 파일: `scripts/verify-harness-structure.sh`
- 구현이 최소 범위인 이유: `assert`/`AssertionError` 검증을 `check(...)`/`fail(...)` 명시 실패로 바꾸고 optimize mode는 하드 실패 처리했다.

### 리팩터링 기록

- REFACTOR decision: 명시 실패 helper로 기계 치환하되 검증 정책 의미는 유지했다.
- 변경: `verify-harness-structure.sh`의 Python 검증문을 `assert`에서 `check(...)` helper로 기계 치환했다.
- 동작 영향: 정상 검증 결과는 유지하고, optimize mode 우회를 실패로 바꿨다.
- 재실행 명령: `make clean && make verify`

### 검증 보고

| 확인 | 명령 / 방법 | 결과 |
|---|---|---|
| 테스트 | `make clean && make verify` | PASS |
| 타입체크 / 빌드 | N/A | N/A |
| 린트 / 정적 확인 | `git diff --check` | PASS |
| UI / 접근성 / 수동 확인 | N/A | N/A |
| 백엔드 안전성 | N/A | N/A |
| Negative check | `HARNESS_EXPECTED_CODEX_MODEL='definitely-not-the-model' HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh` | FAIL as expected: `[FAIL] model must be definitely-not-the-model...` |
| Negative check | `PYTHONOPTIMIZE=1 HARNESS_EXPECTED_CODEX_MODEL='definitely-not-the-model' HARNESS_VERIFY_MODE=template bash scripts/verify-harness-structure.sh` wrapper | PASS: unsafe optimized mode rejected |
| Workflow check | `.github/workflows` direct file scan | PASS: no active workflow files |
| Local artifact check | `find . -name .DS_Store -print` | PASS: no output |

### 건너뛴 검증

| 확인 | 이유 | 남은 위험 |
|---|---|---|
| 실제 GitHub Actions 원격 실행 | 로컬 하네스 repo 검증 범위 | YAML 이동/경로 확인으로 대체 |

## 백엔드 구조 품질 게이트

N/A

## 리뷰 보고

| 리뷰 | 리뷰어 / 방법 | 판정 | 메모 |
|---|---|---|---|
| 최종 품질 | self-review | PASS | 두 P1 재현/수정/검증 완료 |

## 실행 진행

- RED 재현 완료
- GREEN 수정 완료
- VERIFY 완료

## 완료 보고

- 요약: GitHub Actions 예시를 비활성 docs example 경로로 이동하고, 구조 검증 스크립트의 `assert` 기반 검증을 명시 실패 helper로 교체했다.
- 충족한 요구사항: 활성 workflow 오동작 제거, `PYTHONOPTIMIZE=1` 우회 차단, 관련 문서 참조 갱신.
- 추가 / 변경한 테스트: optimize negative wrapper, invalid model negative check, active workflow file scan.
- 구현: `docs/harness/examples/github-actions/harness-verify.yml`, `scripts/verify-harness-structure.sh`, `docs/harness/CI_EXAMPLES.md`, `README.md`, `MANIFEST.md`.
- 검증: `make clean && make verify`, `git diff --check`, negative checks, `.DS_Store` 확인.
- 리뷰 판정: PASS
- 잔여 위험: 실제 GitHub Actions 원격 실행은 수행하지 않았으나, 활성 workflow 파일 제거와 로컬 구조 검증으로 대체했다.
