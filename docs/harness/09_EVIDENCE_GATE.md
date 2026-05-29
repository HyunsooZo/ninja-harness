# 09. 증거 게이트

이 문서는 실행 증거를 어디에, 어떤 형태로 남길지 정의한다. `05_TESTING.md`가 무엇을 검증할지 정한다면, 이 문서는 그 증거를 어떻게 기록할지 정한다.

## 단일 상태 위치

별도 `.harness/` 상태 폴더를 만들지 않는다. 아래 경로를 사용한다.

```txt
docs/harness/plans/active/<YYYY-MM-DD-slug>.md
docs/harness/plans/completed/<YYYY-MM-DD-slug>.md
```

`docs/harness/plans/active`가 활성 증거 저장소다.

## Plan State

활성 계획의 `Metadata > Plan State`는 아래 값 중 정확히 하나만 쓴다.
`Status`는 에이전트 종료 보고 enum(`DONE`, `DONE_WITH_CONCERNS`, `NEEDS_CONTEXT`, `BLOCKED`)에 남겨 plan lifecycle과 혼동하지 않는다.

| Plan State | 의미 |
|---|---|
| `draft` | 요구사항이나 계획을 정리 중 |
| `red` | 실패 테스트 또는 회귀 재현 증거를 확보함 |
| `green` | 최소 구현으로 대상 테스트/check가 통과함 |
| `refactor` | GREEN 이후 직접 관련 정리 중 |
| `verify` | 최종 또는 확장 검증 중 |
| `review` | 필요한 integration/security/a11y/quality review 중 |
| `completed` | `completed/`로 이동할 준비가 됨 |
| `blocked` | context, 권한, 환경, 사용자 결정 부족으로 중단됨 |

## 필수 증거

동작 변경은 아래 증거를 기록한다.

| Gate | 필수 증거 | 위치 |
|---|---|---|
| RED | 실패 command/check, 실패 테스트 또는 재현 절차, 실패 이유, 기대 실패 사유 | 활성 계획 `RED Evidence` |
| GREEN | 통과 command/check, 변경 파일, 최소 구현 요약 | 활성 계획 `GREEN Evidence` |
| REFACTOR | 정리 요약, 동작 영향 없음, 재실행 command/check | 활성 계획 `Refactor Note` |
| VERIFY | test/빌드/typecheck/browser/platform/manual 결과 | 활성 계획 `Verify Report` |
| REVIEW | 리뷰 종류, 판정, 잔여 위험 | 활성 계획 `Review gates` / `Completion Report` |

## 중단 규칙

- RED 증거 또는 문서화된 예외 없이 production 동작을 수정하지 않는다.
- GREEN 전에는 refactor하지 않는다.
- VERIFY 전에는 완료를 선언하지 않는다.
- 필요한 review가 빠졌다면 최대로 보고해도 `DONE_WITH_CONCERNS`다.
- 보안, 인증, 권한, 리소스 범위, 공개 링크/토큰, API 계약 변경은 활성 계획에 불필요 사유를 남기지 않는 한 관련 리뷰가 필요하다.

## 되돌림 규칙

검증이나 리뷰가 실패하면 작업을 loop로 되돌린다.

- VERIFY 실패는 구현 결함이면 `green`, 테스트/재현 결함이면 `red`로 되돌린다.
- REVIEW `FAIL`은 `red` 또는 `green`으로 되돌린다. 수정 전에 문제를 재현하거나 성격을 명확히 한다.
- REVIEW `PASS_WITH_CONCERNS`는 잔여 concern을 `Risks Left`에 기록하고, 차단 concern은 loop로 되돌린다.
- 재진입 사유와 이전 실패 증거는 활성 계획에 누적하고 덮어쓰지 않는다.

## 예외 규칙

아래 작업은 자동화 RED 대신 대체 증거를 사용할 수 있다.

- 문서만 변경
- 순수 시각/스타일 변경
- 조사/리뷰 작업
- 런타임/플랫폼 작업에서 자동화가 없거나 문서화된 수동 확인보다 가치가 낮은 경우
- 자동화 RED 비용이 변경 위험보다 명확히 큰 경우

`RED Evidence`에는 아래 형식을 사용한다.

```md
- 예외 사유:
- 대체 검증:
- Risk left:
```

## 완료 규칙

완료 전 아래를 수행한다.

1. `Completion Report`를 채운다.
2. `Plan State`를 `completed`로 바꾼다.
3. plan을 `docs/harness/plans/completed/`로 이동한다.
4. 적용 저장소의 장기 사실이 바뀌었을 때만 `docs/harness/context/**` 또는 `docs/harness/profiles/**`를 갱신한다.
5. 긴 로그는 컨텍스트 문서에 넣지 말고 완료 계획에 실행 요약으로 남긴다.
