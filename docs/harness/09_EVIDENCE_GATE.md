# 09. 증거 게이트

이 문서는 실행 증거를 어디에, 어떤 형태로 남길지 정의한다. `05_TESTING.md`가 무엇을 검증할지 정한다면, 이 문서는 그 증거를 어떻게 기록할지 정한다.

## 단일 상태 위치

별도 `.harness/` 상태 폴더를 만들지 않는다. 아래 경로를 사용한다.

```txt
docs/harness/plans/active/<YYYY-MM-DD-slug>.md
docs/harness/plans/completed/<YYYY-MM-DD-slug>.md
```

`docs/harness/plans/active`가 활성 증거 저장소다.

## Plan State

활성 계획의 `Metadata > Plan State`는 아래 값 중 정확히 하나만 쓴다.
`Status`는 에이전트 종료 보고 enum(`DONE`, `DONE_WITH_CONCERNS`, `NEEDS_CONTEXT`, `BLOCKED`)에 남겨 plan lifecycle과 혼동하지 않는다.

| Plan State | 의미 |
|---|---|
| `draft` | 요구사항이나 계획을 정리 중 |
| `red` | 실패 테스트 또는 회귀 재현 증거를 확보함 |
| `green` | 최소 구현으로 대상 테스트/check가 통과함 |
| `refactor` | GREEN 이후 직접 관련 정리 중 |
| `verify` | 최종 또는 확장 검증 중 |
| `review` | 필요한 integration/security/a11y/quality review 중 |
| `completed` | `completed/`로 이동할 준비가 됨 |
| `blocked` | context, 권한, 환경, 사용자 결정 부족으로 중단됨 |

## 필수 증거

동작 변경은 아래 증거를 기록한다.

| Gate | 필수 증거 | 위치 |
|---|---|---|
| RED | 실패 command/check, 실패 테스트 또는 재현 절차, 실패 이유, 기대 실패 사유 | 활성 계획 `RED Evidence` |
| GREEN | 통과 command/check, 변경 파일, 최소 구현 요약 | 활성 계획 `GREEN Evidence` |
| REFACTOR | 정리 요약, 동작 영향 없음, 재실행 command/check | 활성 계획 `Refactor Note` |
| VERIFY | test/빌드/typecheck/browser/platform/manual 결과 | 활성 계획 `Verify Report` |
| REVIEW | 리뷰 종류, 판정, 잔여 위험 | 활성 계획 `Review gates` / `Completion Report` |

## 중단 규칙

- RED 증거 또는 문서화된 예외 없이 production 동작을 수정하지 않는다.
- GREEN 전에는 refactor하지 않는다.
- VERIFY 전에는 완료를 선언하지 않는다.
- 필요한 review가 빠졌다면 최대로 보고해도 `DONE_WITH_CONCERNS`다.
- 보안, 인증, 권한, 리소스 범위, 공개 링크/토큰, API 계약 변경은 활성 계획에 불필요 사유를 남기지 않는 한 관련 리뷰가 필요하다.

## Claude Code Inline Hook

Claude Code project settings는 `PreToolUse` hook으로 직접 파일 수정 도구를 실행 전에 차단한다.

- 설정: `.claude/settings.json`
- hook command: `"$CLAUDE_PROJECT_DIR/scripts/check-evidence-gate-hook.sh"`
- Windows native settings: `.claude/settings.windows.json`
- 본체: `scripts/check-evidence-gate-hook.py`
- Bash wrapper: `scripts/check-evidence-gate-hook.sh`
- PowerShell wrapper: `scripts/check-evidence-gate-hook.ps1`
- 대상 도구: `Edit`, `MultiEdit`, `Write`, `NotebookEdit`

hook은 `docs/harness/plans/active/*.md` 수정을 허용한다. 그 외 파일을 직접 수정하려면 활성 plan에 `RED Evidence` / `RED 증거`가 있거나 RED 예외 사유가 기록되어 있어야 하고, 같은 plan의 명시적 `Editable Scope` 또는 `Scope` 섹션에 대상 파일 또는 glob 범위가 있어야 한다. 증거와 명시 범위가 없으면 exit code 2로 tool call을 차단한다.
Scope 패턴은 repository-relative 경로만 허용한다. 절대경로와 `..` parent traversal은 유효한 scope로 취급하지 않는다. 대상 경로도 repository-relative가 아니면 scope와 매칭하지 않는다.

```md
## Editable Scope

- `src/example.py`
- `tests/example/**`
```

`Plan State: red`만으로는 통과하지 않는다. completed plan 직접 편집도 bootstrap 경로가 아니므로 active plan에 수정 범위로 명시되어야 한다.

`Files` 같은 일반 변경 파일 목록은 편집 허용 범위로 해석하지 않는다. RED 예외는 `예외 사유`와 `대체 검증`을 함께 기록해야 하며, `Risk left`만으로는 RED evidence가 아니다. `FAIL`, `실패`, `재현` 같은 서술형 단어만 있는 RED Evidence도 편집 허용 증거가 아니다.

긴급 우회가 필요하면 승인 사유를 plan에 남기고 `HARNESS_EVIDENCE_HOOK_MODE=off`와 `HARNESS_EVIDENCE_HOOK_BYPASS_REASON=<approved-reason>`을 세션 환경변수로 함께 설정한다. `HARNESS_EVIDENCE_HOOK_MODE=off`만 설정하면 hook은 exit code 2로 차단한다. 경고만 받고 싶을 때는 `HARNESS_EVIDENCE_HOOK_MODE=warn`을 사용할 수 있다. 이 우회는 하네스 규칙의 예외이며 completed plan에 사유와 잔여 위험을 남긴다.

Windows native PowerShell에서 hook을 직접 실행하거나 설정을 분리해야 하는 경우 `.claude/settings.windows.json`의 `pwsh -NoProfile -Command ... scripts/check-evidence-gate-hook.ps1` command를 사용한다. 기본 `.claude/settings.json` command는 `CLAUDE_PROJECT_DIR` 기준 Bash wrapper를 호출해 repo 외부 cwd에서도 같은 Python 본체를 실행하고, interpreter fallback은 wrapper 내부의 command 존재 여부로만 판단한다.

Bash 도구로 파일을 수정하는 우회는 명령 파싱 오탐 위험 때문에 1차 hook의 선행 차단 범위에 넣지 않는다. Bash 기반 파일 변경은 기존 `make integrity`, `git diff --check`, completed plan 품질 검사, reviewer 검토로 보완한다.

## 되돌림 규칙

검증이나 리뷰가 실패하면 작업을 loop로 되돌린다.

- VERIFY 실패는 구현 결함이면 `green`, 테스트/재현 결함이면 `red`로 되돌린다.
- REVIEW `FAIL`은 `red` 또는 `green`으로 되돌린다. 수정 전에 문제를 재현하거나 성격을 명확히 한다.
- REVIEW `PASS_WITH_CONCERNS`는 잔여 concern을 `Risks Left`에 기록하고, 차단 concern은 loop로 되돌린다.
- 재진입 사유와 이전 실패 증거는 활성 계획에 누적하고 덮어쓰지 않는다.

## 예외 규칙

아래 작업은 자동화 RED 대신 대체 증거를 사용할 수 있다.

- 문서만 변경
- 순수 시각/스타일 변경
- 조사/리뷰 작업
- 런타임/플랫폼 작업에서 자동화가 없거나 문서화된 수동 확인보다 가치가 낮은 경우
- 자동화 RED 비용이 변경 위험보다 명확히 큰 경우

`RED Evidence`에는 아래 형식을 사용한다.

```md
- 예외 사유:
- 대체 검증:
- Risk left:
```

## 완료 규칙

완료 전 아래를 수행한다.

1. `Completion Report`를 채운다.
2. `Plan State`를 `completed`로 바꾼다.
3. 이동 전 후보 plan에 `bash scripts/check-completed-plan-quality.sh --file <active-plan-path>`를 실행한다.
4. 단일 후보 검사가 통과할 때만 plan을 `docs/harness/plans/completed/`로 이동한다.
5. 이동 후 `make check-plans`를 실행해 completed 전체 품질을 확인한다.
6. 적용 저장소의 장기 사실이 바뀌었을 때만 `docs/harness/context/**` 또는 `docs/harness/profiles/**`를 갱신한다.
7. 긴 로그는 컨텍스트 문서에 넣지 말고 완료 계획에 실행 요약으로 남긴다.
