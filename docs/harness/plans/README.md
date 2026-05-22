# 작업 계획 생명주기

`docs/harness/plans`는 대화 기억이 아니라 파일 상태로 작업 맥락과 검증 증거를 남기기 위한 저장소다.

## 디렉터리

- `active/`: 진행 중인 단순하지 않은 작업 계획과 단계별 증거를 둔다.
- `completed/`: 현재 프로젝트에서 완료된 작업의 최종 실행 기록을 둔다. 배포본에는 `.gitkeep`만 둔다.
- `examples/`: 하네스 작성/정리 예시 plan을 둔다. 실제 프로젝트 컨텍스트로 기본 로딩하지 않는다.
- `TEMPLATE.md`: 새 plan의 기본 형식이다.

작업 파일명은 가능하면 `YYYY-MM-DD-short-slug.md` 형식을 쓴다. 기존 활성 계획을 이어서 작업하면 새 파일을 만들지 말고 해당 파일을 갱신한다.

## 작업 계획을 써야 하는 경우

아래 중 하나라도 해당하면 활성 계획을 만든다.

- 여러 파일이나 여러 레이어를 바꾼다.
- 여러 에이전트에게 분리 위임할지 판단해야 한다.
- API/인증/리소스/페이지네이션/목록 로딩 계약이 바뀐다.
- RED -> GREEN -> REFACTOR 증거를 남겨야 하는 동작 변경이다.
- 사용자가 계획, 단계별 진행, 장기 작업, 후속 검토를 요청했다.

작은 문서 수정이나 단일 변경은 대화 내 체크리스트와 최종 보고로 충분하다.

## 증거 모델

활성 계획은 아래 증거 구역을 작업 진행에 맞춰 갱신한다.

- `Spec`: 요구사항과 acceptance criteria
- `Requirement Traceability`: 요구사항, AC, 테스트, 구현 위치, 증거 연결
- `Agent Orchestration`: 단일/순차/병렬 위임 모드, 레이어 영향도, 통합 담당자
- `Test Plan`: RED/GREEN/verification에 쓸 명령과 예외 사유
- `RED Evidence`: production code 변경 전 실패 명령과 실패 이유
- `GREEN Evidence`: 최소 구현 후 통과 명령과 변경 파일
- `Refactor Note`: GREEN 이후 동작 변경 없는 정리와 재실행 결과
- `Verify Report`: 최종 테스트/build/typecheck/manual 검증과 skipped check
- `Review Report`: integration/security/a11y/quality review 결과
- `Completion Report`: 완료 요약, 요구사항 충족, 남은 위험

문서만 변경, 탐색, 순수 스타일처럼 자동화 RED가 부적합하면 `RED Evidence`에 예외 사유와 대체 검증을 적는다.

## 완료

완료 시 활성 계획을 `completed/`로 이동하고 `Completion Report`를 채운다. 관련 domain/view/API 사실은 `docs/harness/context/**`에 반영한다.

전체 스캔 산출물은 완료 계획에 복사하지 않는다. 장기적으로 필요한 사실만 `docs/harness/context/BASELINE.md`, `DECISIONS.md`, 관련 세부 컨텍스트 문서에 반영한다.

## 게이트 상태

`Metadata > Status`는 가능하면 아래 값 중 하나를 쓴다.

- `draft`
- `red`
- `green`
- `refactor`
- `verify`
- `review`
- `completed`
- `blocked`

자세한 기준은 `../09_EVIDENCE_GATE.md`를 따른다.
