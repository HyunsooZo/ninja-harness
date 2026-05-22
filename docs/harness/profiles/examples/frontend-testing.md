# 프론트엔드 테스트 / 접근성 / 시각 회귀 프로파일 예시

이 파일은 예시다. 실제 프로젝트 값은 `docs/harness/profiles/project-profile.md` 또는 프로젝트별 profile에 복사해서 수정한다.

## Gate script 예시

조직 표준에서는 repository script를 gate로 연결한다. 각 script 내부에서 실제 명령을 실행한다.

```bash
HARNESS_PRIMARY_FRONTEND_TEST_SCRIPT='scripts/ci/primary-frontend-test.sh'
HARNESS_SECONDARY_APP_TEST_SCRIPT='scripts/ci/secondary-app-test.sh'
HARNESS_A11Y_CHECK_SCRIPT='scripts/ci/a11y-check.sh'
```

## 권장 script 내부 예시

- `scripts/ci/primary-frontend-test.sh`
  - install/cache는 CI workflow에서 처리
  - `npm run typecheck`
  - `npm run lint`
  - `npm run test -- --run`
  - 필요한 경우 `npm run build`
- `scripts/ci/a11y-check.sh`
  - Playwright + axe 또는 Storybook accessibility check
  - keyboard navigation smoke test
  - dialog/focus trap/restore 확인
- `scripts/ci/visual-check.sh`
  - Storybook screenshot 또는 Playwright screenshot diff
  - 디자인 시스템 token drift 확인

## Test Pyramid 기준

- unit/component test: formatter, mapper, form validation, component state, composable/store logic.
- integration test: API mock + screen behavior, query/store/cache update, owned API contract drift.
- e2e test: 핵심 사용자 flow, 권한/실패/재시도, route transition, critical regression.
- visual regression: design token, layout breakpoint, overflow, modal/popover layer, long content.
- accessibility smoke: role/name, keyboard order, focus trap/restore, error description, color/contrast는 프로젝트 도구 기준.

## Playwright 기준

- selector는 `data-testid`보다 role/name 우선. 테스트 안정성이 필요할 때만 test id를 사용한다.
- API mocking은 실제 contract fixture와 동기화한다. backend response 변경 시 fixture를 같이 갱신한다.
- auth/resource scope가 필요한 화면은 401/403/empty/success를 구분해 검증한다.
- dialog/popover/datepicker는 open focus, keyboard move, close restore를 최소 smoke로 검증한다.
- flaky test는 retry로 숨기지 말고 원인, 네트워크 mock, wait condition을 점검한다.

## Storybook / Visual Regression 기준

- story는 happy path만 두지 않는다. loading/empty/error/permission/long content를 포함한다.
- design system component는 disabled, focus, hover, active, invalid, responsive state를 포함한다.
- screenshot diff는 허용 threshold, 승인자, baseline 갱신 사유를 기록한다.
- Storybook accessibility addon 또는 axe check는 주요 interactive story에 연결한다.
- 시각 회귀 실패가 의도된 변경이면 active/completed plan에 승인 근거를 남긴다.

## Testing Library / Component Test 기준

- role/name 기반 assertion을 우선한다.
- form/input은 validation message, describedby, error focus를 함께 검증한다.
- userEvent를 사용해 실제 사용자 입력 흐름을 검증한다.
- implementation detail(className, internal state)보다 visible behavior를 검증한다.
- API contract가 바뀌면 mock fixture와 integration test를 같이 갱신한다.
- loading/empty/error/permission denied/stale state를 최소 하나 이상 검증한다.

## 추천 에이전트 흐름

- 테스트 전략 수립: `test-automation-reviewer`
- 접근성 게이트: `primary-frontend-style-a11y-reviewer`
- 반응형/뷰포트 게이트: `responsive-layout-reviewer`
- 플로우/e2e 게이트: `ux-flow-reviewer`
- 데이터 시각화 화면: `data-viz-reviewer`
- owned API fixture/mock 변경: `integration-reviewer` + `frontend-typescript-implementer`
