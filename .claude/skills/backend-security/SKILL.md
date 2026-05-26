---
name: backend-security
description: use for authentication, authorization, tenant/resource scope, input validation, secret handling, audit log, rate limit, and backend security review.
---

# 백엔드 보안

## 먼저 읽을 문서

- `AGENTS.md`
- `docs/harness/README.md`
- `docs/harness/05_TESTING.md`
- 작업 범위에 맞는 `docs/harness/01~09` 문서
- 관련 `docs/harness/context/**` 문서

## 핵심 기준

- actor/resource 권한과 소유/소속 관계를 확인한다.
- public token, 파일 다운로드, 로그, 응답 DTO에서 민감 정보 노출을 막는다.
- 권한 실패/만료/비활성 리소스 시나리오를 점검한다.

## 증거 게이트

- 단순하지 않은 작업은 `docs/harness/plans/active/`에 활성 계획을 만든다.
- 동작 변경은 RED/GREEN/REFACTOR/VERIFY 증거를 남긴다.
- 자동화 테스트가 부적합하면 예외 사유, 대체 검증, 잔여 위험을 기록한다.

## 출력

- 적용한 기준
- 변경/리뷰 범위
- 검증 또는 검토 결과
- 남은 위험
