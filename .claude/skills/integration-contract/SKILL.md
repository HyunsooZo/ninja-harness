---
name: integration-contract
description: use for owned API DTO/request/response impact, API auth, resource scope, provider-consumer drift, pagination, error contract, and integration boundary checks.
---

# 통합 계약

공통 운영 기준: `docs/harness/SKILL_AUTHORING.md#공통-운영-블록`

## 먼저 읽을 문서

- `AGENTS.md`
- `docs/harness/README.md`
- `docs/harness/05_TESTING.md`
- 작업 범위에 맞는 `docs/harness/01~09` 문서
- 관련 `docs/harness/context/**` 문서

## 핵심 기준

- 요청/응답 구조를 양쪽에서 확인한다.
- auth/resource boundary와 권한 실패 흐름을 점검한다.
- 페이지네이션 제한, 빈 페이지 종료, 전체 페이지 순회 조건을 본다.

## Owned API Contract Impact Rule

- 프론트에서 API DTO/request/response/status/error/pagination/auth/resource scope를 수정하면 해당 API가 우리 백엔드 API인지 확인한다.
- 우리 백엔드 API라면 backend controller/route, DTO/schema, validation, use case, OpenAPI/API 문서, `api-matrix.md`를 확인한다.
- 프론트 ViewModel/표시 매핑 변경인지, provider contract 변경인지 구분한다.
- 백엔드에서 API request/response/DTO/schema/status/error/pagination/auth/resource scope를 변경하면 호출하는 프론트 코드가 있는지 검색한다.
- 검색 범위는 endpoint path, generated client, API service/fetcher, query key, hook/composable, store/cache, validation schema, 화면 컴포넌트, 테스트를 포함한다.
- 호출 화면이 있으면 필요한 프론트 타입, 매핑, UI state, 테스트를 함께 수정한다.
- 수정하지 않는 경우에도 확인한 파일/검색어/근거를 active plan에 남긴다.

## 필수 계약 점검 항목

- request/response DTO 변경 시 Owned API Contract Impact Rule에 따라 provider와 소비자를 함께 확인한다.
- auth, actor, resource scope, ownership/membership 검증 위치를 명시한다.
- pagination은 page size 제한, 빈 페이지 종료 조건, 전체 페이지 순회 필요 여부를 확인한다.
- 민감 필드, 내부 저장 경로, 원본/공개 토큰, 내부 ID가 소비자 응답으로 새지 않는지 확인한다.
- 기존 API를 재사용할 경우 `docs/harness/context/integration/api-matrix.md` allow-list와 일치하는지 확인한다.
- 신규 래퍼 API가 필요한 경우 기존 API를 직접 확장하지 말고 주요/보조 경계를 분리한다.
