# 컨텍스트 문서 운영

`docs/harness/context/**`는 현재 프로젝트의 실제 사실을 저장하는 공간이다.
하네스 문서는 작업 기준이고, 컨텍스트 문서는 프로젝트 상태다.

## 핵심 원칙

- 전체 프로젝트 스캔 파일을 기본 컨텍스트로 사용하지 않는다.
- 기본 컨텍스트는 `BASELINE.md`, 활성 계획, 최근 완료 계획, 필요한 세부 컨텍스트 문서로 제한한다.
- 오래된 대화 기억에 의존하지 않는다.
- 도메인, API, 화면, 운영 기준이 바뀌면 관련 컨텍스트 문서를 갱신한다.
- 긴 실행 로그는 완료 계획에 남기고, context에는 현재 사실만 남긴다.

## 구조

- `BASELINE.md`: 반복적으로 필요한 프로젝트 고정 기준
- `DECISIONS.md`: 장기적으로 유효한 주요 결정
- `INDEX.md`: 작업별로 읽을 문서 색인
- `backend/`: 백엔드 도메인, API, 영속성, auth 맥락
- `frontend/`: 주요 화면, 컴포넌트, view 맥락
- `integration/`: API matrix, 프론트/백 계약
- `operations/`: 배포, 환경, 운영 메모
- `generated/`: 전체 스캔 등 일회성 생성 산출물. 기본 컨텍스트에 포함하지 않는다.
- `archive/`: 더 이상 active하지 않은 과거 문서

## 전체 스캔 산출물 정책

`docs/harness/context/generated/PROJECT_CONTEXT_SCAN.generated.md` 같은 전체 스캔 산출물은 생성 산출물로 본다.
필요하면 `docs/harness/context/generated/PROJECT_CONTEXT_SCAN.generated.md`처럼 저장할 수 있지만, 기본 읽기 순서에는 넣지 않는다.
스캔 결과 중 장기적으로 필요한 내용만 `BASELINE.md`, `DECISIONS.md`, 관련 세부 컨텍스트 문서에 반영한다.
