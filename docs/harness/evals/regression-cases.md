# 회귀 사례

실제 프로젝트에서 발견된 실패를 기록하고, 재발 방지 반영 위치를 연결한다.

| ID | Date | Area | Symptom | Root Cause | Captured As | Linked Change | Status |
|---|---|---|---|---|---|---|---|
| REG-HOOK-CWD-2026-06-03 | 2026-06-03 | evidence hook | `.claude/settings.json` hook command failed outside repo cwd | active command used repo-relative script path | self-test / verifier | `evidence hook settings command works outside repo cwd` | closed |
| REG-HOOK-EXIT-2026-06-03 | 2026-06-03 | evidence hook | block exit code was obscured by interpreter fallback | `python3 ... || python ...` retried after intentional block exit | self-test / verifier | `evidence hook settings command preserves block exit code` | closed |
| REG-HOOK-SCOPE-2026-06-03 | 2026-06-03 | evidence hook | generic `Files` heading and weak RED evidence could over-authorize edits | scope headings and RED evidence fields were too broad | unit test / self-test / doc | `test_files_section_does_not_allow_target`, `test_risk_left_only_is_not_red_evidence` | closed |
| REG-UPGRADE-2026-06-03 | 2026-06-03 | upgrade lifecycle | version/changelog and upgrade readiness could drift | new target and release metadata were not fully canonicalized | verifier / checker | `make harness-upgrade`, `CHANGELOG.md 0.2.0` | closed |

## 반영 규칙

- 자동화 가능한 실패는 테스트나 project gate로 반영한다.
- 판단 기준 실패는 skill 또는 numbered core 문서에 반영한다.
- 프로젝트별 사실 누락은 `context/**` 또는 `profiles/**`에 반영한다.
- 새 행은 `REG-<area>-<YYYY-MM-DD>` 형식의 실제 ID, 날짜, 원인, 반영 위치를 채운 뒤 추가한다.
