# 하네스 변경 이력

## 0.2.0

- evidence hook command를 `CLAUDE_PROJECT_DIR` 기준 wrapper 호출로 고쳐 repo 외부 cwd와 exit code 보존을 강화했다.
- evidence hook의 editable scope 판정을 `Editable Scope`/`Scope` 계열로 제한하고, generic `Files` heading과 `Risk left` 단독 RED evidence를 거부한다.
- `make harness-upgrade`와 `scripts/check-harness-upgrade.py` / `.ps1`를 upgrade readiness gate로 편입했다.
- Python runtime cache clean/ignore, UTF-8 stdio, unit tests, active CI dogfood, ownership/security metadata를 보강했다.
- verifier와 self-test가 새 hook/upgrade invariants를 강제한다. `make integrity` 통과 기준을 유지한다.

## 0.1.0

- 초기 버전 식별자와 schema version을 도입했다.
- 다운스트림 레포가 `VERSION`과 `docs/harness/harness.yaml`의 `harness_version`으로 적용 버전을 확인할 수 있게 했다.
- 업그레이드 절차 문서를 추가했다.

## 기록 규칙

- breaking change는 `major`, 새 gate/문서/런타임은 `minor`, 문구/검증 보강은 `patch`로 올린다.
- 다운스트림 적용자가 해야 할 작업은 `docs/harness/UPGRADE.md`에 함께 기록한다.
- 변경이 verifier 요구사항을 바꾸면 `make integrity` 통과 여부를 함께 남긴다.
