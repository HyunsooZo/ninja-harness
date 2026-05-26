# /verify

## 목적

검증 단계를 수행한다.

## 절차

1. `docs/harness/05_TESTING.md` 기준으로 위험도에 맞는 테스트/빌드를 실행한다.
2. 실행하지 못한 검증은 이유와 잔여 위험을 적는다.
3. 계약/auth/resource/pagination 변경은 integration review를 포함한다.
4. 백엔드 구조/트랜잭션 변경은 `docs/harness/10_BACKEND_QUALITY_GATE.md` 기준을 활성 계획에 기록한다.
5. 검증 결과를 활성 계획 또는 최종 보고에 남긴다.
6. 검증이 실패하면 완료를 선언하지 않고 `/red` 또는 `/green`으로 되돌아간다.
