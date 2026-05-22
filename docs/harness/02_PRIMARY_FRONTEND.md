# 02. 주요 프론트엔드 하네스

> 프론트엔드 스택, 디렉터리 이름, 프레임워크 명령, 행위자 라벨, 토큰 이름은 프로젝트 프로필/컨텍스트 값이다. 이 문서는 범용 기준만 둔다.

이 문서는 운영/관리 성격의 주요 프론트엔드 화면 영역을 다룬다. 제품별 명칭은 프로필에 둔다.

## 필수 읽기 문서

- `AGENTS.md` 또는 `CLAUDE.md`
- `docs/harness/context/BASELINE.md`
- `docs/harness/context/frontend/README.md`
- 디자인 추가 또는 시각 리팩토링 시 `docs/harness/07_DESIGN_SYSTEM.md`
- 대상 화면 컨텍스트: `docs/harness/context/frontend/**`
- 계약 변경 시: `docs/harness/04_INTEGRATION.md`, `docs/harness/context/integration/api-matrix.md`

## 아키텍처

- 서비스, 화면, 컴포넌트, 상태, 스타일, 테스트, 타입 구조는 대상 앱의 기존 모듈 구조를 따른다.
- 기존 프로젝트 컴포넌트, 토큰, 상태 헬퍼, 데이터 조회 헬퍼, API 서비스 패턴을 우선 사용한다.
- 전역 추상화나 상태 라이브러리는 반복 증거와 유지보수 이점이 확인될 때만 추가한다.
- 프로덕션 빌드에서 목/데모 코드가 실제 API, 인증, 권한 경계를 우회하면 안 된다.

## UI와 스타일링

- 프로젝트에 명시 예외가 없으면 인라인 스타일을 사용하지 않는다.
- 명시 승인 없이 외부 스타일 라이브러리, UI 컴포넌트 프레임워크, 유틸리티 CSS 프레임워크, 복사한 디자인 키트, CDN 스타일시트를 추가하지 않는다.
- UI 형태, 간격, 색상, 타입, 반응형 동작은 프로젝트가 소유한 CSS/SCSS 또는 기존 로컬 스타일 시스템을 따른다.
- 디자인 추가/리팩토링은 `07_DESIGN_SYSTEM.md`와 디자인 시스템 프로필을 적용한다.
- 버튼, 배지, 카드, 모달, 검색/필터, 페이지네이션, 내비게이션, 데이터 표, 폼 상태 같은 공통 패턴은 기존 로컬 컴포넌트를 먼저 확인한다.
- 운영 화면은 밀도 있고, 훑기 쉽고, 반복 업무에 집중되어야 한다. 소개/홍보 성격의 화면이 아니면 표현 중심 레이아웃을 피한다.
- 터치 영역, 포커스 상태, 움직임 줄이기, 키보드 내비게이션, 스크린 리더 라벨은 완료 기준에 포함한다.
- 사용자에게 보이는 문구는 프로젝트의 i18n/content 시스템을 사용한다. 프로젝트가 i18n을 쓰는 경우 컴포넌트 템플릿에 사용자 표시 문구를 하드코딩하지 않는다.

## 디자인 리뷰 관점

- 디자인 시스템: `.agents/skills/design-system/SKILL.md`
- 반응형 레이아웃: `.agents/skills/responsive-layout/SKILL.md`
- UX flow: `.agents/skills/ux-flow/SKILL.md`
- 데이터 시각화: `.agents/skills/data-visualization/SKILL.md`
- 콘텐츠/i18n UX: `.agents/skills/content-i18n-ux/SKILL.md`

## API와 상태

- API 구조, 인증, 권한, 리소스 선택, 페이지네이션, 응답 계약에 영향을 주는 프론트엔드 변경은 제공자/소비자 짝 검토 대상이다.
- 리다이렉트, 공개 링크, 외부 이미지, HTML 미리보기, 파일/다운로드 URL, 토큰화된 흐름은 기존 정화 로직 또는 실패 시 차단 헬퍼를 사용한다.
- 전체 목록 집계는 서버 페이지 제한, 종료 조건, 필터, 정렬과 일치해야 한다.
- 로딩, 빈 상태, 오류, 재시도, 인증 필요, 권한 없음, 오래된 상태, 부분 데이터 상태는 사용자 작업 흐름과 맞아야 한다.

## Owned API 제공자 영향 확인

프론트엔드에서 API client/type/hook/query key/schema, request parameter, response DTO, status/error 처리, pagination, auth/resource scope를 수정하면 해당 API가 우리 백엔드 API인지 확인한다.

- 우리 백엔드 API라면 `docs/harness/04_INTEGRATION.md`의 Owned API Contract Impact Rule을 따른다.
- backend controller/route, DTO/schema, validation, use case, OpenAPI/API 문서, API matrix를 확인한다.
- 프론트 ViewModel/표시 매핑만 바꾸는 변경인지, provider contract 수정이 필요한 변경인지 구분한다.
- 백엔드 수정이 필요하면 active plan에 backend 영향 레이어와 검증 근거를 남긴다.

## 검증

동작 변경은 `05_TESTING.md`와 `09_EVIDENCE_GATE.md`를 따른다. 순수 스타일 또는 문서 변경은 예외 사유와 diff/rg/browser 검증으로 대체할 수 있다.

실제 명령은 `docs/harness/context/BASELINE.md` 또는 프로젝트 프로필에서 가져온다.

```bash
<primary-frontend-test-command>
<primary-frontend-targeted-test-command>
<primary-frontend-build-command>
<primary-frontend-style-command>
```

큰 UI 변경은 관련 데스크톱/모바일 뷰포트에서 브라우저 검증을 수행한다.

## 완료 기준

- 기존 컴포넌트/스타일 패턴을 유지하거나 의도적으로 확장했다.
- 새 사용자 표시 문구가 프로젝트의 i18n/content 시스템을 따른다.
- 인라인 스타일과 승인 없는 외부 UI/스타일 라이브러리가 없다.
- 반응형 레이아웃, 포커스 상태, 터치 영역, 텍스트 넘침, 로딩/빈 상태/오류 상태, 접근성 라벨을 확인했다.
- 계약에 영향을 주는 변경은 Owned API Contract Impact Rule에 따라 백엔드/통합 검증과 함께 처리했다.
- 동작 변경에는 RED/GREEN/REFACTOR 증거가 있거나 문서화된 예외가 있다.
- 장기 사실이 바뀌었다면 관련 프론트엔드/통합 컨텍스트가 갱신됐다.
