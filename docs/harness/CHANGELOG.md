# 하네스 변경 이력

## 0.1.0

- 초기 버전 식별자와 schema version을 도입했다.
- 다운스트림 레포가 `VERSION`과 `docs/harness/harness.yaml`의 `harness_version`으로 적용 버전을 확인할 수 있게 했다.
- 업그레이드 절차 문서를 추가했다.

## 기록 규칙

- breaking change는 `major`, 새 gate/문서/런타임은 `minor`, 문구/검증 보강은 `patch`로 올린다.
- 다운스트림 적용자가 해야 할 작업은 `docs/harness/UPGRADE.md`에 함께 기록한다.
- 변경이 verifier 요구사항을 바꾸면 `make integrity` 통과 여부를 함께 남긴다.
