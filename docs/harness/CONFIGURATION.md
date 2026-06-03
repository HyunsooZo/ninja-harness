# 설정 레퍼런스 (HARNESS_* 환경변수)

이 문서는 하네스가 사용하는 모든 `HARNESS_*` 환경변수를 한곳에 모은 단일 레퍼런스다. 흩어진 설명을 집약한 것이며, `make verify`가 이 표와 현재 자동 대조 대상(`Makefile`, `scripts/*.sh`, `scripts/*.ps1`, `scripts/*.py`, `scripts/harness_lib/*.py`, `.github/workflows/*.yml`, `.github/workflows/*.yaml`, `docs/harness/harness.yaml`)을 **양방향으로 대조**한다. 사용하는데 미문서화된 변수나, 문서에만 있고 쓰이지 않는 유령 변수가 있으면 검증이 실패한다.

규칙: 새 `HARNESS_*` 변수를 추가/사용하면 반드시 이 표에 추가한다. 더 이상 쓰지 않으면 표에서도 제거한다.

## 검증 / 프로파일

| 변수 | 기본값 | 의미 |
|---|---|---|
| `HARNESS_VERIFY_MODE` | `template` | 구조 검증 모드. `template` 또는 `project`. |
| `HARNESS_REQUIRE_FILLED_PROFILE` | (off) | `1`이면 project 모드에서 프로파일 placeholder가 남아 있을 때 실패. |

## 프로젝트 게이트 실행

| 변수 | 기본값 | 의미 |
|---|---|---|
| `HARNESS_RUN_PROJECT_CHECKS` | (off) | `1`이면 실제 프로젝트 build/test/lint 게이트를 실행. |
| `HARNESS_REQUIRE_PROJECT_CHECKS` | (off) | `1`이면 게이트가 하나도 설정되지 않았을 때 실패. |

## 프로젝트 게이트 스크립트 (권장)

각 변수에 repository script 경로를 지정한다. `HARNESS_RUN_PROJECT_CHECKS=1`과 함께 사용한다.

| 변수 | 의미 |
|---|---|
| `HARNESS_BACKEND_TEST_SCRIPT` | 백엔드 테스트 게이트 스크립트. |
| `HARNESS_PRIMARY_FRONTEND_TEST_SCRIPT` | 주요 프론트엔드 테스트 게이트 스크립트. |
| `HARNESS_SECONDARY_APP_TEST_SCRIPT` | 보조 앱 테스트 게이트 스크립트. |
| `HARNESS_INTEGRATION_TEST_SCRIPT` | 통합 테스트 게이트 스크립트. |
| `HARNESS_SECURITY_SCAN_SCRIPT` | 보안 스캔 게이트 스크립트. |
| `HARNESS_A11Y_CHECK_SCRIPT` | 접근성 검사 게이트 스크립트. |

## 프로젝트 게이트 명령 (legacy)

`HARNESS_*_SCRIPT`가 우선이며, 아래 legacy 명령 문자열은 명시적 opt-in이 필요하다.

| 변수 | 의미 |
|---|---|
| `HARNESS_BACKEND_TEST_CMD` | 백엔드 테스트 legacy 명령. |
| `HARNESS_PRIMARY_FRONTEND_TEST_CMD` | 주요 프론트엔드 테스트 legacy 명령. |
| `HARNESS_SECONDARY_APP_TEST_CMD` | 보조 앱 테스트 legacy 명령. |
| `HARNESS_INTEGRATION_TEST_CMD` | 통합 테스트 legacy 명령. |
| `HARNESS_SECURITY_SCAN_CMD` | 보안 스캔 legacy 명령. |
| `HARNESS_A11Y_CHECK_CMD` | 접근성 검사 legacy 명령. |
| `HARNESS_ALLOW_LEGACY_BASH_LC` | `1`이면 `bash -lc` legacy 명령 실행을 허용. |

## 조직 표준

| 변수 | 기본값 | 의미 |
|---|---|---|
| `HARNESS_ORG_STANDARD` | (off) | `1`이면 조직 표준 모드. repository script gate를 강제. |
| `HARNESS_ACK_TRUSTED_PROJECT_CMDS` | (off) | `1`이면 신뢰된 프로젝트 명령 실행을 명시 승인. |
| `HARNESS_REQUIRE_FILLED_OWNERSHIP` | (off) | `1`이면 LICENSE/CODEOWNERS/OWNERSHIP/SECURITY placeholder가 남아 있으면 실패. |

## 업그레이드 / 드리프트 감사

| 변수 | 기본값 | 의미 |
|---|---|---|
| `HARNESS_CHECK_UPGRADE` | `scripts/check-harness-upgrade.py` | upgrade readiness 체크 스크립트 경로. |
| `HARNESS_REQUIRE_DOWNSTREAM_AUDIT` | (off) | `1`이면 downstream audit 입력이 없을 때 실패. |
| `HARNESS_REQUIRE_CLEAN_DOWNSTREAM` | (off) | `1`이면 downstream에서 manual review 대상이 있으면 실패. |

## 증거 게이트 훅

| 변수 | 기본값 | 의미 |
|---|---|---|
| `HARNESS_EVIDENCE_HOOK_MODE` | `strict` | `strict`(차단) / `warn`(경고만) / `off`(우회). |
| `HARNESS_EVIDENCE_HOOK_BYPASS_REASON` | (없음) | `off`/우회 시 필수 감사 사유. 비어 있으면 차단 유지. |

## eval / 운영 지표 임계값

| 변수 | 기본값 | 의미 |
|---|---|---|
| `HARNESS_EVAL_FAIL_ON_GUARDRAIL` | (off) | `1`이면 가드레일 임계값 초과 시 eval 실패. |
| `HARNESS_MAX_REVIEW_FAIL_RATE` | `10` | 최종 리뷰/검증 FAIL 비율 상한(%). |
| `HARNESS_MAX_REWORK_RATE` | `20` | 재작업 발생 비율 상한(%). |
| `HARNESS_MAX_GATE_FAIL_RATE` | `10` | project gate 실패 비율 상한(%). |
| `HARNESS_MAX_FAN_IN_CONFLICT_RATE` | `10` | fan-in 충돌 발생률 상한(%). |
| `HARNESS_MIN_REGRESSION_CAPTURE_RATE` | `80` | 회귀 사례 반영률 하한(%). |

## 완료 계획 집계

| 변수 | 기본값 | 의미 |
|---|---|---|
| `HARNESS_COMPLETED_PLAN_DIR` | `docs/harness/plans/completed` | 완료 계획 집계 대상 디렉터리. |
| `HARNESS_COMPLETED_PLAN_SOURCE` | `local` | `local`(디스크) 또는 `tracked`(git ls-files). |

## 런타임

| 변수 | 기본값 | 의미 |
|---|---|---|
| `HARNESS_EXPECTED_CODEX_MODEL` | (harness.yaml 값) | Codex 에이전트 기대 모델명 override. |
| `HARNESS_POSIX_UTILITIES` | (내장 목록) | `make doctor`가 점검하는 POSIX 유틸리티 목록 override. |

## Makefile 스크립트 오버라이드 (고급)

진입점 스크립트 경로를 교체할 때만 사용한다. 일반 adopter는 건드리지 않는다.

| 변수 | 기본 경로 |
|---|---|
| `HARNESS_VERIFY` | `scripts/verify-harness-structure.sh` |
| `HARNESS_PROJECT_GATES` | `scripts/verify-project-gates.sh` |
| `HARNESS_SYNC_SKILLS` | `scripts/sync-skills.sh` |
| `HARNESS_CHECK_PROFILE` | `scripts/check-profile-readiness.sh` |
| `HARNESS_SELF_TEST_GATES` | `scripts/self-test-harness-gates.sh` |
| `HARNESS_EVAL` | `scripts/collect-eval-metrics.sh` |
| `HARNESS_CHECK_PLANS` | `scripts/check-completed-plan-quality.sh` |
| `HARNESS_SET_MODEL` | `scripts/set-codex-agent-model.sh` |
