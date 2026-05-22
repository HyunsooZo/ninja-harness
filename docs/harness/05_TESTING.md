# 05. 테스트 하네스

테스트는 변경 위험과 영향 범위에 맞춰 고른다. 작은 문구 수정에 전체 검증을 강제하지 않되, 공유 계약, 보안 경계, 영속성, 런타임, 교차 화면 동작은 더 넓게 확인한다.

## 일반 규칙

- 관련 테스트가 있으면 먼저 실행한다.
- 동작 변경에 의미 있는 테스트 범위가 없으면 테스트를 추가한다.
- 동작 변경은 RED -> GREEN -> REFACTOR -> VERIFY를 따른다.
- 대상 테스트에서 시작하고, 공유 동작이나 고위험 경계를 건드리면 전체 테스트/빌드로 확장한다.
- 실행하지 못한 검증은 이유와 잔여 위험을 보고한다.

## TDD 게이트

증거 위치와 hard-stop 규칙은 `docs/harness/09_EVIDENCE_GATE.md`를 따른다.

- RED: production 수정 전에 실패하는 자동화 테스트/회귀 check를 작성하거나 실행한다. 기존 테스트가 같은 결함으로 실패해도 된다. 명령과 실패 이유를 기록한다.
- GREEN: 최소 구현을 적용하고 RED 대상이 통과함을 확인한다.
- REFACTOR: 동작 변경 없이 직접 관련 코드만 정리하고 대상 검증을 다시 실행한다. 위험이 커졌다면 검증 범위를 넓힌다.
- VERIFY: 선택한 최종 test/빌드/typecheck/수동 확인 결과를 기록한다.
- 예외: 문서만 변경, 순수 스타일, 조사, 자동화 RED 가치가 낮은 변경은 예외 사유, 대체 검증, 잔여 위험으로 대체할 수 있다.
- RED 또는 문서화된 예외 없이 동작 변경을 구현하면 하네스 위반이다.
- 활성 계획을 쓰는 작업은 RED/GREEN/REFACTOR/VERIFY 증거를 `docs/harness/plans/active/`에 기록하고, 완료 시 `completed/`로 이동한다.

## 명령 출처

구체 명령은 프로젝트별 값이므로 `docs/harness/context/BASELINE.md`, `docs/harness/profiles/project-profile.md`, 또는 대상 repository에서 가져온다.

| 영역 | Placeholder |
|---|---|
| 백엔드 전체 테스트 | `<backend-test-command>` |
| 백엔드 대상 테스트 | `<backend-targeted-test-command>` |
| 백엔드 빌드 | `<backend-build-command>` |
| 백엔드 런타임/의존성 확인 | `<backend-runtime-command>` |
| 주요 프론트엔드 테스트 | `<primary-frontend-test-command>` |
| 주요 프론트엔드 대상 테스트 | `<primary-frontend-targeted-test-command>` |
| 주요 프론트엔드 빌드 | `<primary-frontend-build-command>` |
| 주요 프론트엔드 스타일/타입 확인 | `<primary-frontend-style-command>` |
| 보조 앱 테스트 | `<secondary-app-test-command>` |
| 보조 앱 빌드 | `<secondary-app-build-command>` |
| 보조 앱 런타임 확인 | `<secondary-app-runtime-command>` |

## 검증 범위 선택

- 문서만 변경: 링크/참조 `rg` 점검과 변경 문구 리뷰.
- 단일 표현 계층 변경: 대상 UI/단위 테스트 또는 재현 가능한 수동 확인, 가능하면 빌드.
- 공유 컴포넌트/스타일/토큰 변경: 관련 테스트와 빌드, 시각 위험이 있으면 브라우저/모바일 뷰포트 확인.
- 백엔드 도메인/애플리케이션 변경: 대상 도메인/애플리케이션 테스트, 공유 동작이면 더 넓은 백엔드 테스트.
- 백엔드 권한/리소스/영속성 변경: 대상 테스트와 전체 백엔드 테스트, 스키마/의존성이 바뀌면 초기 상태/런타임 검증.
- 프론트엔드/백엔드 계약 변경: 제공자와 소비자 대상 확인, 통합 문서 리뷰.
- 런타임/네이티브/PWA/저장소/deep-link/push 변경: 자동화 확인과 대상 런타임 검증 또는 문서화된 수동 절차.
- 보안 민감 또는 공개 링크/토큰 변경: 대상 테스트, 정화 로직/실패 시 차단 리뷰, 통합/보안 리뷰.

## 완료 기준

- 변경 위험에 맞는 검증을 실행했다.
- 동작 변경에는 RED/GREEN/REFACTOR 증거가 있거나 문서화된 예외가 있다.
- 실행하지 못한 검증은 이유와 잔여 위험이 보고됐다.
- 문서 변경은 오래된 경로, 오래된 참조, 프로젝트별 표현 누출을 필요에 따라 점검했다.
