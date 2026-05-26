# /refactor

## 목적

REFACTOR 정리 단계를 수행한다.

## 절차

1. GREEN 이후 직접 관련된 코드만 정리한다. 동작 변경은 하지 않는다.
2. 관련 없는 리팩토링, 포맷 변경, dead code 삭제를 하지 않는다.
3. 백엔드 구조 변경이면 DDD/OOP/SOLID/트랜잭션 기준을 `docs/harness/10_BACKEND_QUALITY_GATE.md`로 점검한다.
4. RED에서 사용한 대상 테스트를 다시 실행해 동작이 그대로인지 확인한다.
5. 정리 내용, 동작 영향 없음, 재실행 명령을 활성 계획의 `Refactor Note`에 기록한다.
6. GREEN 증거가 없으면 리팩토링하지 않는다.
