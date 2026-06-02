# 하네스 업그레이드 절차

다운스트림 레포는 `VERSION`과 `docs/harness/harness.yaml`의 `harness_version`으로 현재 적용 버전을 확인한다.

## 업그레이드 전

1. 현재 레포에서 `make integrity`를 실행한다.
2. `VERSION`, `docs/harness/harness.yaml`, `docs/harness/CHANGELOG.md`를 확인한다.
3. 적용 중인 active plan이 있으면 완료하거나 업그레이드를 미룬다.
4. 프로젝트별 값은 `docs/harness/context/**`와 `docs/harness/profiles/**`에만 남아 있는지 확인한다.
5. 현재 버전 기준 업그레이드 메타데이터를 확인한다.

```bash
make harness-upgrade
FROM_VERSION=0.1.0 make harness-upgrade
```

Windows native PowerShell에서는 아래처럼 실행한다.

```powershell
pwsh -File scripts/check-harness-upgrade.ps1 --from-version 0.1.0
```

## 업그레이드 적용

1. 새 템플릿의 `CHANGELOG.md`에서 현재 버전 이후 항목을 읽는다.
2. core 문서, scripts, agents, skills, `.claude/**`, `.codex/**`, Makefile 변경을 가져온다.
3. 프로젝트별 `context/**`, `profiles/**`, 완료 plan은 덮어쓰지 않는다.
4. 스킬을 수정했다면 `scripts/sync-skills.sh`, `python3 scripts/sync-skills.py`, 또는 `pwsh -File scripts/sync-skills.ps1`를 실행한다.

## 업그레이드 후

```bash
make harness-upgrade
make integrity
make project-ready
```

조직 표준 레포에서는 최소 하나 이상의 project gate를 연결해 아래도 실행한다.

```bash
HARNESS_BACKEND_TEST_SCRIPT='scripts/ci/backend-test.sh' make verify-org
```

## 기록

- 업그레이드 결과는 completed plan에 남긴다.
- verifier 실패가 template 변경 때문이면 `CHANGELOG.md`와 이 문서를 함께 갱신한다.
- 다운스트림에서 임시 예외를 둔 경우 승인자, 만료 일정, 제거 계획을 completed plan에 남긴다.
