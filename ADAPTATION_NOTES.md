# 적용 메모

이 패키지는 특정 프로젝트 이름에 묶이지 않는 범용 Codex/Claude 하네스다.

## 적용 방식

1. 프로젝트 루트에 압축을 푼다.
2. `<backend-dir>`, `<primary-frontend-dir>`, `<secondary-app-dir>` 자리표시자를 실제 경로로 바꾼다.
3. 프로젝트에 보조 앱 영역이 없으면 관련 문서는 `N/A` 상태로 둔다.
4. `docs/harness/context/BASELINE.md`, `docs/harness/profiles/**`, `docs/harness/harness.yaml`에 실제 경로, 도메인, API, 화면 맥락을 채운다.
5. `scripts/verify-harness-structure.sh`로 구조를 확인한다.

## 운영 원칙

- 공통 기준은 `AGENTS.md`와 `docs/harness/**`에 둔다.
- 런타임별 파일은 Codex/Claude가 읽기 쉽게 미러링한다.
- 상세 실행 로그는 활성/완료 계획에 남긴다. 전체 스캔 산출물은 생성 산출물로 취급하고 기본 컨텍스트에 포함하지 않는다.
