---
name: backend-api
description: use for backend controller, DTO, validation, request/response mapping, status/error shape, and presentation-layer API contract work.
---

# 백엔드 API / Presentation 스킬

공통 운영 기준: `docs/harness/SKILL_AUTHORING.md#공통-운영-블록`

## 먼저 읽을 문서

- `AGENTS.md`
- `docs/harness/README.md`
- `docs/harness/01_BACKEND.md`
- `docs/harness/04_INTEGRATION.md`
- `docs/harness/05_TESTING.md`
- `docs/harness/10_BACKEND_QUALITY_GATE.md`
- `docs/harness/context/backend/README.md`
- `docs/harness/context/integration/api-matrix.md`

## 적용 범위

- Controller, route, handler, resolver 같은 presentation entrypoint
- DTO, request/response mapper, validation, status/error shape
- OpenAPI/API 문서와 API matrix에 드러나는 provider contract
- application service 호출 경계와 presentation 전용 변환

## 핵심 기준

- Controller/DTO에는 요청/응답 변환, validation, protocol concern만 둔다.
- 도메인 규칙, 트랜잭션, 멱등성, 권한 정책 본체는 application/domain 경계에 둔다.
- API request/response/status/error/pagination/auth/resource scope가 바뀌면 `docs/harness/04_INTEGRATION.md`의 Owned API Contract Impact Rule을 적용한다.
- 백엔드발 계약 변경이면 frontend service/fetcher, generated client, query key, hook/composable, store/cache, 화면, 테스트 호출부를 검색한다.
- 호출부가 없거나 수정이 불필요해도 검색어와 근거를 active plan에 남긴다.

## 증거 게이트

- 동작/계약 변경은 RED -> GREEN -> REFACTOR -> VERIFY 증거를 남긴다.
- 자동화 RED가 부적합하면 예외 사유, 대체 검증, 잔여 위험을 기록한다.
- 관련 테스트가 있으면 대상 API/presentation 테스트에서 시작하고, 공유 계약이면 통합/소비자 확인으로 확장한다.

## 출력

- 적용한 API/presentation 기준
- 수정한 request/response/status/error/auth/resource scope
- provider/consumer 영향도 확인 결과
- 실행한 검증과 남은 위험
