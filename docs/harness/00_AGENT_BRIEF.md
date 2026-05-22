# 00. 에이전트 브리프

> 프로젝트별 저장소 경로, 행위자/리소스 용어, API prefix, 패키지 이름, 실행 명령, 디자인 토큰 이름은 `docs/harness/context/**`와 `docs/harness/profiles/**`에 둔다.

이 문서는 하네스를 사용하는 에이전트의 공통 작업 브리프다. 루트 `AGENTS.md`와 `CLAUDE.md`는 짧은 진입 지도만 담당하고, 실제 판단 기준은 이 문서와 각 레이어/gate 문서가 나눠 가진다.

## 운영 모델

- 루트 작업공간은 하나의 저장소일 수도 있고, 여러 관련 저장소를 담는 상위 폴더일 수도 있다. 실제 경로는 프로필/컨텍스트 값이다.
- 핵심 하네스 문서는 작업 흐름, 품질 게이트, 리뷰 경계를 정의한다. 제품 행위자, API prefix, 기술 스택, 패키지 루트, 브랜드 토큰을 하드코딩하지 않는다.
- `docs/harness/context/**`는 현재 프로젝트의 사실과 장기 구현 맥락을 저장한다.
- `docs/harness/profiles/**`는 프로젝트별 어휘, 행위자/리소스 용어, API prefix, 패키지 루트, 디자인 토큰 이름, 실행 명령을 저장한다.
- `docs/harness/plans/active/**`는 진행 중인 작업 상태와 증거를 저장한다. `docs/harness/plans/completed/**`는 완료 기록을 저장한다.
- subagent나 병렬 fan-out은 사용자가 요청했거나 활성 계획에서 안전하게 분리 가능하다고 확인된 경우에만 사용한다.
- 레이어별 에이전트는 항상 실행하지 않는다. 단일 레이어/작은 수정은 `SINGLE_AGENT`로 처리하고, 교차 레이어 작업만 `13_AGENT_ORCHESTRATION.md` 기준으로 분리한다.

## 필수 읽기 순서

1. `AGENTS.md` 또는 `CLAUDE.md`
2. `docs/harness/context/BASELINE.md`
3. `docs/harness/context/INDEX.md`
4. `docs/harness/README.md`
5. `docs/harness/09_EVIDENCE_GATE.md`
6. 작업 범위에 맞는 layer/gate 문서
7. 프로젝트별 사실이 필요한 경우 관련 `docs/harness/profiles/**`와 `docs/harness/context/**`

## 우선순위

문서와 구현이 충돌하면 아래 순서로 판단한다.

1. 사용자의 최신 요청
2. 코드의 현재 동작
3. `AGENTS.md` / `CLAUDE.md`
4. `docs/harness/context/BASELINE.md`
5. 관련 `docs/harness/context/**`
6. `docs/harness/profiles/**`
7. 핵심 `docs/harness/**`
8. 최근 완료 계획

비교, 감사, 동기화 작업에서 사용자가 원문 기준 자료를 명시하면 그 자료를 비교 기준으로 삼고, 반영은 적용 저장소의 프로필/컨텍스트 규칙에 맞춘다.

## 작업 규칙

- 추측하지 않는다. 모호함이 결과를 바꾸면 구현 전에 질문한다.
- 여러 단계 작업은 `1. [Step] 구현 -> verify: [검증 방법]` 형식으로 짧은 계획을 둔다.
- 단순하지 않은 작업은 `docs/harness/plans/active/`에 스펙, 테스트 계획, 증거, 진행 상황, 위험을 기록한다.
- 동작 변경은 RED -> GREEN -> REFACTOR -> VERIFY를 따른다. production 동작 수정 전 실패 증거를 남기고, 최소 구현으로 통과시킨 뒤, 직접 관련 정리만 하고 다시 검증한다.
- 문서만 변경, 순수 스타일, 조사 작업은 자동화 RED 대신 예외 사유, 대체 검증, 잔여 위험을 기록할 수 있다.
- 요청과 직접 연결된 파일만 수정한다.
- 관련 없는 리팩토링, 포맷 변경, dead code 삭제를 섞지 않는다.
- 적용 저장소의 기존 코드 스타일과 레이어 경계를 따른다.
- 근거 없는 일회성 추상화, 상태 라이브러리, 런타임 의존성을 추가하지 않는다.
- 마치기 전 원래 요청, 변경 파일, 검증 결과, 문서 갱신 여부를 대조한다.

## 하네스 라우팅

- 리뷰, PR 리뷰, 감사는 `review-pr`를 먼저 적용한다.
- 구현, 수정, 리팩토링, 단순하지 않은 멀티스텝 작업은 `executor`를 먼저 적용한다.
- 계획, 영향도 분석, 리스크 정리는 사용 가능한 계획 도구를 쓰고, 없으면 현재 에이전트가 직접 활성 계획을 관리한다.
- 프론트 UI/UX 작업은 `02_PRIMARY_FRONTEND.md` 또는 `03_SECONDARY_APP.md`를 읽는다. 디자인 추가/시각 리팩토링이면 `07_DESIGN_SYSTEM.md`도 함께 읽는다.
- 프론트/백 계약 변경은 `04_INTEGRATION.md`와 대상 API matrix를 읽는다.
- 백엔드 구조 변경은 `01_BACKEND.md`와 `10_BACKEND_QUALITY_GATE.md`를 읽는다.
- 어떤 에이전트에게 나눌지 애매하면 `13_AGENT_ORCHESTRATION.md`에서 `SINGLE_AGENT`, `SEQUENTIAL_LAYERED`, 병렬 모드를 먼저 고른다.

## 컨텍스트 문서

- 진행 중 상태는 활성 계획에 둔다.
- 완료된 실행 기록은 완료 계획에 둔다.
- 장기 시스템 사실은 `docs/harness/context/**`에 둔다.
- 프로젝트별 이름, 행위자 용어, API prefix, 패키지 루트, 토큰 이름, 실행 명령은 `docs/harness/profiles/**` 또는 `context/BASELINE.md`에 둔다.
- `docs/harness/context/generated/**`는 임시 생성 산출물이며 기본 컨텍스트가 아니다.
- API 계약, 인증, 권한, 리소스 선택, 페이지네이션, 목록 로딩 변경은 통합 컨텍스트를 갱신한다.

## 커밋 정책

- 에이전트는 사용자가 명시적으로 요청한 경우에만 commit, amend, push를 수행한다.
- commit 전에는 변경 파일과 검증 결과를 보고한다.
