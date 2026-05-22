# Vue / Vite 프론트엔드 프로파일 예시

이 파일은 예시다. 실제 프로젝트 값은 `docs/harness/profiles/project-profile.md` 또는 프로젝트별 profile에 복사해서 수정한다.

## Runtime

- Language: TypeScript `<version>`
- Framework: Vue `<version>`
- Build: Vite `<version>`
- State: Pinia, Vue Query, composable store 등
- Router: Vue Router
- Styling: SCSS, CSS Modules, design-token CSS variables 등
- Test: Vitest, Vue Test Utils, Playwright, Storybook/Histoire 선택

## Frontend script gate 예시

조직 표준에서는 repository script를 gate로 연결한다. 각 script 내부에서 실제 test/lint/typecheck/a11y/visual 명령을 실행한다.

```bash
HARNESS_PRIMARY_FRONTEND_TEST_SCRIPT='scripts/ci/primary-frontend-test.sh'
HARNESS_A11Y_CHECK_SCRIPT='scripts/ci/a11y-check.sh'
```

## Composition API 기준

- `ref`, `reactive`, `computed`, `watch`의 책임을 구분한다. 파생 상태는 `computed`, side effect는 명시적 `watch`로 제한한다.
- composable은 화면 전용 UI state와 API/domain state를 과하게 섞지 않는다.
- lifecycle에서 DOM/focus를 다루는 경우 mount/unmount와 route transition 영향을 확인한다.
- `v-if`/`v-show` 전환 시 focus, aria 관계, keep-alive, mounted lifecycle 영향이 확인됐는가?
- props/emits 타입은 부모-자식 계약과 일치해야 하며, API DTO를 component prop으로 직접 흘리지 않는다.

## Pinia / Store 기준

- Pinia store는 domain/client state 책임을 명확히 한다. 단순 화면 local state는 store로 올리지 않는다.
- action은 API 호출, loading/error state, optimistic/rollback 전략을 명확히 한다.
- store persist를 쓰는 경우 민감정보, stale resource scope, logout cleanup을 확인한다.
- API 응답 필드 변경 시 store state, getter, consuming component, test fixture를 함께 검색한다.
- Vue Query 또는 composable cache를 쓰는 경우 query key와 invalidation 기준을 문서화한다.

## Router / Auth / Resource Scope 기준

- route guard는 auth, resource scope, role/permission, redirect loop를 분리해 판단한다.
- 401/403/404/empty/error state를 UI에서 구분한다.
- URL query, pagination, filter, tab state는 reload/share/back navigation에서 깨지지 않는지 확인한다.
- Vite env 값은 `VITE_` prefix와 배포 환경 정책을 따른다. secret은 client bundle로 노출하지 않는다.

## Component / Accessibility 기준

- dialog, dropdown, datepicker, combobox 등 interactive component는 keyboard/focus/aria 관계를 유지한다.
- SCSS partial/import 경로, token 사용, cascade/specificity가 프로젝트 규칙과 맞는지 확인한다.
- table에서 card/list로 반응형 전환 시 label 관계와 reading order를 보존한다.
- validation error는 visible message, `aria-describedby`, focus 이동 기준을 함께 검증한다.

## Testing / Storybook/Histoire 기준

- Vitest + Vue Test Utils는 사용자 동작과 visible result 중심으로 작성한다.
- composable/store test는 loading/success/error/rollback state를 포함한다.
- Playwright e2e는 route guard, form validation, API error, keyboard navigation smoke를 포함한다.
- Storybook/Histoire가 있으면 loading/empty/error/permission/long content/breakpoint variant를 유지한다.

## Owned API Contract Impact

- API DTO/request/response/status/error/pagination/auth/resource scope 변경은 `docs/harness/04_INTEGRATION.md`의 Owned API Contract Impact Rule을 따른다.
- 프론트발 변경은 우리 백엔드 API 의도를 확인하고, 백엔드발 변경은 해당 API 호출부를 검색한다.
- 필요한 경우 backend/frontend 양쪽 수정과 contract/test evidence를 active plan에 남긴다.

## 추천 에이전트 흐름

- 단일 component 수정: `primary-frontend-component-implementer`
- 화면/route 흐름 변경: `primary-frontend-view-implementer` + `ux-flow-reviewer`
- 타입/DTO 계약 변경: `frontend-typescript-implementer` + `integration-reviewer`
- 접근성/반응형 검토: `primary-frontend-style-a11y-reviewer` + `responsive-layout-reviewer`
- owned API DTO/request/response 변경: `task-orchestrator` -> `integration-reviewer` -> 필요한 backend/frontend implementer
- 큰 화면 개편: `task-orchestrator` -> view/component/type/test 순서로 분리
