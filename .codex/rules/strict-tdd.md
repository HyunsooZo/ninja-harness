# Strict TDD Rule

동작 변경은 RED -> GREEN -> REFACTOR 순서를 따른다.

## 금지

- RED 증거 없이 production code 수정 금지
- GREEN 전 refactor 금지
- VERIFY 전 완료 선언 금지
- active plan을 completed로 이동하기 전 `bash scripts/check-completed-plan-quality.sh --file <active-plan-path>` 통과 필요
- 테스트 실패를 숨기거나 임시 mock으로 통과 처리 금지

## 예외

문서 변경, 순수 스타일 조정, 조사/탐색처럼 자동화 테스트가 부적합한 작업은 active plan에 예외 사유, 대체 검증, 잔여 위험을 기록한다.
