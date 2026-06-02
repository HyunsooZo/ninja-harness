---
name: frontend-typescript
description: use for TypeScript props, types, generics, null handling, state typing, API response typing, and frontend type safety.
---

# 프론트 TypeScript

공통 운영 기준: `docs/harness/SKILL_AUTHORING.md#공통-운영-블록`

## 먼저 읽을 문서

- `AGENTS.md`
- `docs/harness/README.md`
- `docs/harness/05_TESTING.md`
- 작업 범위에 맞는 `docs/harness/01~09` 문서
- 관련 `docs/harness/context/**` 문서

## 핵심 기준

- API 계약은 타입으로 명확히 표현한다.
- any 우회를 피하고 변환 지점을 분리한다.
- 계약 변경은 integration review 대상이다.
