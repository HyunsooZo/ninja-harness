# /complete

## 목적

완료 단계를 수행한다.

## 절차

1. 변경 파일과 요구사항 충족 여부를 요약한다.
2. RED/GREEN/REFACTOR/VERIFY evidence 또는 예외 사유를 정리한다.
3. 남은 위험과 후속 작업을 적는다.
4. 이동할 후보 plan 파일에 `bash scripts/check-completed-plan-quality.sh --file <active-plan-path>`를 실행하고 통과할 때만 `docs/harness/plans/completed/`로 이동한다.
5. 이동 후 `make check-plans`를 실행해 completed 전체 품질을 확인한다.
6. 사용자가 명시하지 않았다면 커밋/푸시는 하지 않는다.
