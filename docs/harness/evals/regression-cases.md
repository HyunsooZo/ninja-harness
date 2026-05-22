# 회귀 사례

실제 프로젝트에서 발견된 실패를 기록하고, 재발 방지 반영 위치를 연결한다.

| ID | Date | Area | Symptom | Root Cause | Captured As | Linked Change | Status |
|---|---|---|---|---|---|---|---|
| REG-001 | YYYY-MM-DD | `<area>` | `<what failed>` | `<why>` | test / doc / skill / agent / gate | `<path-or-command>` | open/closed |

## 반영 규칙

- 자동화 가능한 실패는 테스트나 project gate로 반영한다.
- 판단 기준 실패는 skill 또는 numbered core 문서에 반영한다.
- 프로젝트별 사실 누락은 `context/**` 또는 `profiles/**`에 반영한다.
