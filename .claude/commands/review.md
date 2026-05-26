# /review

## 목적

리뷰 단계를 수행한다.

## 절차

1. 요구사항, 변경 파일, 테스트 evidence, 문서 갱신을 대조한다.
2. 필요한 reviewer 에이전트를 라우팅한다.
3. 백엔드 변경이면 DDD/트랜잭션/OOP/SOLID를 `docs/harness/10_BACKEND_QUALITY_GATE.md` 기준으로 판정한다.
4. PASS / PASS_WITH_CONCERNS / FAIL 판정을 남긴다.
5. 차단 이슈와 권고를 구분한다.
6. `FAIL`이면 완료를 선언하지 않고 `/red` 또는 `/green`으로 되돌아간다.
