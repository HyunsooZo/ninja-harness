# 03. 보조 앱 하네스

> 앱의 의미, 행위자 라벨, API prefix, 런타임 스택, 네이티브 셸, 패키지 이름, 실행 명령은 프로젝트 프로필/컨텍스트 값이다. 이 문서는 범용 기준만 둔다.

이 문서는 주요 운영 프론트엔드와 분리된 보조 앱을 다룬다. 고객 앱, 회원 포털, 파트너 포털, 현장 앱, 모바일 앱, PWA, 하이브리드 앱 등 어떤 형태든 될 수 있다. 파일명 `SECONDARY_APP`은 호환용 이름이며 제품 의미를 고정하지 않는다.

## 기본 경계

```text
<primary-frontend-dir>   # 주요 운영/관리 프론트엔드 화면 영역
<secondary-app-dir>           # 보조 앱 화면 영역
```

보조 앱이 별도 저장소인지, 작업공간 패키지인지, 라우트 그룹인지, 네이티브 래퍼인지, 서버 렌더링 화면인지는 프로젝트가 결정한다. 이 결정은 `context/BASELINE.md`와 `profiles/project-profile.md`에 기록한다.

## 필수 읽기 문서

- `AGENTS.md` 또는 `CLAUDE.md`
- `docs/harness/context/BASELINE.md`
- `docs/harness/profiles/project-profile.md`
- `docs/harness/context/frontend/README.md`
- `docs/harness/context/integration/api-matrix.md`
- `docs/harness/04_INTEGRATION.md`
- 디자인 추가 또는 시각 리팩토링 시 `docs/harness/07_DESIGN_SYSTEM.md`

## 백엔드 경계

- 백엔드를 공유하더라도 행위자가 다르면 표현 계층 컨트롤러, DTO, 응답 구조, 마스킹 규칙, API prefix를 분리하는 것을 우선 검토한다.
- 기존 주요 API 호환성은 활성 계획에서 명시적으로 바꾸지 않는 한 유지한다.
- 보조 앱 API는 프로필에 정의된 prefix와 계약을 사용한다. 핵심 문서에 prefix를 하드코딩하지 않는다.
- 레거시/공유 엔드포인트는 API matrix가 보조 행위자에게 허용한다고 명시하고, 마스킹, 권한, 페이지네이션, 현재 상태 규칙이 모두 충족될 때만 소비한다.
- 보조 앱 서비스/타입 래퍼는 UI에 맞지 않거나 안전하지 않은 제공자 응답 구조를 숨긴다.
- 내부 식별자, 원본/공개 토큰, 저장 경로, 비공개 URL, 구현 전용 필드, 다른 화면 영역 전용 필드는 프로필이 허용하지 않는 한 제외한다.
- 기존 응답 구조가 보조 작업 흐름에 안전하지 않거나 사용성이 낮으면 레거시 엔드포인트를 직접 확장하지 말고 프로필이 승인한 래퍼를 추가한다.

## 프론트엔드 경계

- 런타임, 밀도, 내비게이션, 권한 모델이 다르면 주요 화면 영역의 컴포넌트/스타일을 직접 가져오지 않는다.
- 실제 중복이 있고 공유 계약이 안정된 뒤에만 코드를 공유한다.
- 모바일, 네이티브, PWA, 오프라인, 앱 재개, push/deep-link, 브라우저 대체 동작은 런타임 프로필에서 결정한다.
- 데모/목 모드는 개발 전용이어야 하며 프로덕션 빌드에서 API나 권한 경계를 우회할 수 있으면 안 된다.
- 프로젝트가 소유한 스타일과 디자인 토큰은 디자인 시스템 프로필을 통해 적용한다.

## 기능 분리 기준

작업은 화면 복사가 아니라 행위자 작업 흐름 단위로 자른다.

| 작업 조각 | 백엔드/API | 보조 앱 | 리뷰 게이트 |
|---|---|---|---|
| 인증/부트스트랩 | 세션, 행위자 권한, 리소스 컨텍스트 | 최초 진입, 세션 복원, 거부/만료 상태 | 통합 |
| 프로필/리소스 컨텍스트 | 현재 행위자와 허용 리소스 | 프로필 요약, 리소스 전환/선택 | 통합 |
| 핵심 작업 흐름 | 행위자별 읽기 모델과 행동 | 주요 목록/상세/행동 흐름 | 통합 + 품질 |
| 행동 작업 흐름 | 제출, 상태 전이, 멱등성 | 주요 행동, 비활성/충돌/재시도 상태 | 스펙 + 통합 |
| 문서/파일 | 안전한 미리보기/다운로드/서명/업로드 흐름 | 문서 목록, 미리보기, CTA, 완료 상태 | 보안 + 통합 |
| 알림 | 대상 지정, 읽음 상태, deep-link payload | 앱 내부/push 진입과 오래된 상태 처리 | 통합 |
| 런타임 통합 | 저장소, 권한, 재개, deep link | 네이티브/PWA/브라우저 대체 동작 | 런타임 리뷰 |

## API 정책

- `docs/harness/context/integration/api-matrix.md`가 라우트 소유권, 허용 소비자, 행위자/리소스 검증, 마스킹, 페이지네이션, 래퍼 필요 여부의 기준 정보다.
- 새 라우트 소비나 허용 목록 변경은 API matrix와 관련 컨텍스트를 함께 갱신한다.
- 인증/부트스트랩 계약은 다른 행위자 데이터를 노출하지 않으면서 허용 내비게이션을 렌더링할 만큼의 정보를 제공해야 한다.
- 반복 제출 흐름은 멱등성, 상태 가드, 비활성 행동, 충돌 처리, 제출 후 새로고침을 갖춘다.
- 목록은 모바일/압축 페이지네이션, 날짜/범위 필터, 빈 상태, 종료 조건을 정의한다.
- 공개 링크, 서명 세션, 미리보기, 다운로드, 업로드, 외부 리다이렉트는 사용 시점에 안전한 래퍼를 통해 발급한다.

## 제외할 주요 화면 범위

프로필이 해당 행위자의 범위에 포함한다고 명시하지 않는 한, 주요 운영 기능을 보조 앱에 그대로 복사하지 않는다.

- 현재 app 경계를 벗어난 행위자 관리 화면
- 현재 행위자/리소스 범위를 넘는 전역 운영 대시보드
- 관리성 생성/재계산/재설정 흐름
- 템플릿, 시스템 설정, 조직 수준 설정 흐름
- 주요 화면 영역 전용 필드, 내부 경로, 원본 토큰, 비공개 ID, 구현 전용 상태

## UX와 접근성

- 데스크톱, 모바일, 태블릿, 터치, 키보드, 네이티브 셸, 브라우저 등 실제 런타임/입력 방식에 맞춰 설계한다.
- 주요 행동은 도달 가능하고, 제출 중에는 잠기며, 실패 후 복구 가능해야 한다.
- 로딩, 빈 상태, 오류, 재시도, 인증 필요, 권한 없음, 오래된 상태, 오프라인, 권한 거부, 리소스 없음 상태를 명시적으로 둔다.
- 사용자에게 보이는 문구는 프로젝트의 i18n/content 시스템을 따른다.
- 상태 표시는 색상만으로 의미를 전달하지 않는다. 텍스트, 아이콘, 다른 비색상 단서를 함께 쓴다.
- 모바일/터치 맥락의 터치 영역은 프로젝트 프로필이 더 엄격한 기준을 두지 않는 한 최소 44px x 44px다.
- 안전 영역, 움직임 줄이기, 포커스 상태, 스크린 리더 라벨, 텍스트 넘침을 대상 런타임에서 확인한다.

## 디자인 리뷰 관점

- 모바일/런타임 UX: `.agents/skills/secondary-app-runtime/SKILL.md`
- 디자인 시스템: `.agents/skills/design-system/SKILL.md`
- 반응형 레이아웃: `.agents/skills/responsive-layout/SKILL.md`
- UX flow: `.agents/skills/ux-flow/SKILL.md`
- 콘텐츠/i18n UX: `.agents/skills/content-i18n-ux/SKILL.md`

## Owned API 제공자 영향 확인

보조 앱에서 API client/type/hook/query key/schema, request parameter, response DTO, status/error 처리, pagination, auth/resource scope를 수정하면 해당 API가 우리 백엔드 API인지 확인한다.

- 우리 백엔드 API라면 `docs/harness/04_INTEGRATION.md`의 Owned API Contract Impact Rule을 따른다.
- backend controller/route, DTO/schema, validation, use case, OpenAPI/API 문서, API matrix를 확인한다.
- 보조 앱 ViewModel/표시 매핑만 바꾸는 변경인지, provider contract 수정이 필요한 변경인지 구분한다.
- 백엔드 수정이 필요하면 active plan에 backend 영향 레이어와 검증 근거를 남긴다.

## 검증

동작 변경은 `05_TESTING.md`와 `09_EVIDENCE_GATE.md`를 따른다. 런타임별 변경은 자동화 검증과 플랫폼/브라우저/수동 검증을 함께 사용할 수 있다.

실제 명령은 `docs/harness/context/BASELINE.md` 또는 프로젝트 프로필에서 가져온다.

```bash
<secondary-app-test-command>
<secondary-app-build-command>
<secondary-app-runtime-command>
```

네이티브, PWA, deep-link, push, 보안 저장소, 권한, 재개 변경은 대상 런타임 검증 또는 잔여 위험을 포함한 명시적 예외 기록이 필요하다.

## 완료 기준

- 앱 경계와 행위자/리소스 가정이 프로필에 근거한다.
- API 소비가 API matrix와 일치하고, 안전하지 않은 주요 계약을 재사용하지 않는다. 계약 변경이면 Owned API Contract Impact Rule에 따라 제공자/소비자 영향도를 확인했다.
- 민감 필드와 다른 화면 영역 전용 데이터가 마스킹됐다.
- 런타임 상태와 접근성 상태가 UI에 반영됐다.
- 데모/목 동작이 프로덕션 API 또는 권한 경계를 우회하지 않는다.
- 동작 변경에는 RED/GREEN/REFACTOR 증거가 있거나 문서화된 예외가 있다.
- 장기 사실이 바뀌었다면 관련 프론트엔드/백엔드/통합 컨텍스트가 갱신됐다.

## 열린 결정 템플릿

프로젝트에 보조 앱을 도입할 때 아래 결정을 프로필 또는 컨텍스트에 기록한다.

- 앱 런타임: web, PWA, native shell, hybrid, mixed
- 저장소/작업공간 배치
- 행위자 라벨과 권한 capability
- API prefix와 레거시 라우트 허용 목록
- 세션 보존과 refresh/logout 동작
- Push/deep-link/provider 전략
- 주요 프론트엔드와의 공유 패키지 경계
