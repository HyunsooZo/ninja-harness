# 하네스 변경 이력

## 0.3.1

- evidence hook의 `scoped_patterns`가 Editable Scope 섹션의 루트 bare 파일명(`MANIFEST.md`, 점 포함 파일, 실제 존재하는 `VERSION`/`LICENSE`/`Makefile`)을 인식하도록 보강했다. 공백 포함 backtick(명령 문자열)은 scope 패턴에서 제외한다.
- 회귀 단위테스트 3개를 추가했다(루트 파일명/확장자 없는 루트 파일/공백 backtick).
- 5분 온보딩에 최소 적용 경로, 개인/라이트 운영, `HARNESS_EVIDENCE_HOOK_MODE=warn` 로컬 설정 예시를 추가해 adopter 진입 표면을 줄였다.
- `CONFIGURATION.md` drift 대조에 `.github/workflows/*.yml` / `.github/workflows/*.yaml`의 `HARNESS_*` 사용을 포함하고, 관련 단위테스트와 문서 표현을 정합화했다.
- completed plan 품질 검사를 보강해 미완성 evidence placeholder를 더 넓게 거부하고, Python 상수명과 shell/workflow 주석을 `HARNESS_*` 환경변수로 오인하지 않도록 설정 대조 정밀도를 조정했다.

## 0.3.0

- `docs/harness/CONFIGURATION.md`를 추가해 모든 `HARNESS_*` 환경변수/모드를 단일 레퍼런스로 집약했다.
- verifier가 문서 표와 실제 사용처(스크립트, `harness.yaml`)를 양방향 대조해 미문서화/유령 변수를 거부한다(`scripts/harness_lib/config_reference.py`, 단위테스트, self-test 포함).
- 루트 README, 5분 온보딩, 하네스 README에서 설정 레퍼런스를 직접 안내하고, Python 상수는 환경변수로 오인하지 않도록 drift 검사를 조정했다.
- adopter가 해야 할 작업은 없다. 새 `HARNESS_*` 변수를 추가/제거하면 `CONFIGURATION.md`를 함께 갱신한다.

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
