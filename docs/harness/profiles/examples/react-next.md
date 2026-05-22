# React / Next.js 프론트엔드 프로파일 예시

이 파일은 예시다. 실제 프로젝트 값은 `docs/harness/profiles/project-profile.md` 또는 프로젝트별 profile에 복사해서 수정한다.

## Runtime

- Language: TypeScript `<version>`
- Framework: Next.js `<version>` 또는 React SPA
- Package manager: npm/pnpm/yarn
- Router: App Router, Pages Router, React Router 등
- Data fetching/cache: TanStack Query(React Query), SWR, Server Component fetch, route loader 중 프로젝트 표준
- Styling: CSS Modules, Tailwind, CSS-in-JS, design-token CSS variables 등
- Test: Vitest/Jest, React Testing Library, Playwright, Storybook 선택

## Frontend script gate 예시

조직 표준에서는 repository script를 gate로 연결한다. 각 script 내부에서 실제 test/lint/typecheck/a11y/visual 명령을 실행한다.

```bash
HARNESS_PRIMARY_FRONTEND_TEST_SCRIPT='scripts/ci/primary-frontend-test.sh'
HARNESS_A11Y_CHECK_SCRIPT='scripts/ci/a11y-check.sh'
```

## Next.js Server / Client Component 기준

- Server Component는 data read, static/streaming rendering, server-only dependency에 우선 사용한다.
- Client Component는 browser event, local state, focus control, form interaction, client cache가 필요한 경우에만 사용한다.
- `window`, `document`, `localStorage`, media query, focus trap, pointer event는 client boundary 안에서만 사용한다.
- Server Component에서 secret, token, internal URL이 client prop으로 노출되지 않는지 확인한다.
- server action 또는 route handler 변경 시 validation, auth/resource scope, error shape를 함께 확인한다.
- hydration mismatch 위험이 있는 date/time/random/browser-only 값은 client boundary 또는 deterministic rendering으로 격리한다.
- loading/error/not-found/empty state가 route segment 또는 화면 컴포넌트 기준으로 정의되어 있는지 확인한다.

## TanStack Query / React Query 기준

- query key는 domain resource, filter, pagination, active resource scope를 포함해 안정적으로 구성한다.
- mutation 후 invalidate/update/optimistic update/rollback 전략을 명시한다.
- staleTime/cacheTime 또는 gcTime은 화면 UX와 서버 freshness 요구사항에 맞춘다.
- query function은 DTO/request/response schema와 owned API contract를 따른다.
- API 응답 필드 변경 시 hook, query key, cache update, mock fixture, 화면 state를 함께 검색한다.
- error boundary와 toast/form error가 중복되거나 사용자 메시지가 누락되지 않는지 확인한다.
- 권한/리소스 scope 변경 시 401/403/empty/error UI를 구분한다.

## Form / Validation 기준

- form library와 schema validator는 프로젝트 표준을 따른다.
- client validation과 backend validation message가 충돌하지 않게 한다.
- error message는 visible text와 accessible description을 함께 제공한다.
- submit 중복 방지, optimistic transition, 실패 복구, focus 이동을 확인한다.
- API request DTO 변경 시 backend route/DTO/schema를 확인하고 active plan의 API 계약 영향도에 근거를 남긴다.

## Component / Design System 기준

- 새 UI는 기존 공통 컴포넌트와 design token을 먼저 사용한다.
- 승인 없는 외부 UI library, adhoc color/spacing/z-index를 추가하지 않는다.
- component prop은 화면 전용 상태와 API DTO를 직접 섞지 않는다. 필요하면 ViewModel/mapper를 둔다.
- dialog, popover, datepicker, combobox는 focus open/restore, keyboard navigation, aria 관계를 검증한다.
- responsive layout은 content overflow, touch target, keyboard focus visibility를 함께 확인한다.

## Testing / Storybook 기준

- component test는 role/name 기반 assertion을 우선한다.
- API hook은 MSW/fixture 등 프로젝트 표준 mock으로 contract drift를 잡는다.
- Storybook이 있다면 loading/empty/error/permission/long content 상태를 story로 유지한다.
- Playwright e2e는 핵심 flow, 권한 실패, form validation, API error state를 최소 smoke로 유지한다.
- visual regression은 주요 breakpoint와 interactive state를 포함한다.

## Owned API Contract Impact

- API DTO/request/response/status/error/pagination/auth/resource scope 변경은 `docs/harness/04_INTEGRATION.md`의 Owned API Contract Impact Rule을 따른다.
- 프론트발 변경은 우리 백엔드 API 의도를 확인하고, 백엔드발 변경은 해당 API 호출부를 검색한다.
- 필요한 경우 backend/frontend 양쪽 수정과 contract/test evidence를 active plan에 남긴다.

## 추천 에이전트 흐름

- 단일 component 수정: `primary-frontend-component-implementer`
- 화면 흐름/상태 변경: `primary-frontend-view-implementer` + `ux-flow-reviewer`
- TypeScript 타입/계약 변경: `frontend-typescript-implementer` + `integration-reviewer`
- 접근성/스타일 검토: `primary-frontend-style-a11y-reviewer` + `responsive-layout-reviewer`
- owned API DTO/request/response 변경: `task-orchestrator` -> `integration-reviewer` -> 필요한 backend/frontend implementer
- 큰 화면 개편: `task-orchestrator` -> view/component/type/test 순서로 분리
