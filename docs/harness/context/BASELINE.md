# 프로젝트 기준

이 문서는 하네스를 적용한 프로젝트의 고정 기준을 짧게 유지하는 문서다.
범용 하네스를 새 프로젝트에 넣은 뒤, 아래 자리표시자를 실제 값으로 바꾼다.

## 사용 원칙

- 작업 시작 시 기본 컨텍스트로 읽는다.
- 긴 실행 로그, 파일 전체 목록, 일회성 조사 결과를 넣지 않는다.
- 기술 스택, 레이어 경계, 주요 명령, 운영 규칙처럼 반복적으로 필요한 사실만 남긴다.
- 코드와 충돌하면 코드를 확인한 뒤 이 문서를 갱신한다.

## 프로젝트 구조

| 영역 | 경로 | 기준 |
|---|---|---|
| 백엔드 | `<backend-dir>` | `<backend-stack-and-runtime>` |
| 주요 프론트엔드 | `<primary-frontend-dir>` | `<primary-frontend-stack-and-runtime>` |
| 보조 앱 | `<secondary-app-dir>` | `<secondary-app-stack-and-runtime>` |

필요 없는 영역은 `N/A`로 표시하고 관련 라우팅 문서에서도 사용하지 않는다.

## 아키텍처 기준

### 백엔드

- `presentation` / `application` / `domain` / `infrastructure` 레이어 경계를 유지한다.
- Presentation layer는 요청/응답 변환과 validation만 담당한다.
- 애플리케이션 서비스는 유스케이스 조율과 트랜잭션 경계를 담당한다.
- 도메인 모델은 불변 조건과 핵심 규칙을 보호한다.
- 영속성 구현은 도메인 규칙을 숨기거나 우회하지 않는다.

### 프론트엔드

- 사용자 표시 문구는 프로젝트의 i18n/content 시스템을 사용한다.
- 기존 컴포넌트, 스타일 토큰, 디자인 톤을 우선한다.
- 인라인 스타일과 임의 외부 UI 라이브러리 도입을 피한다.
- 접근성, 반응형, 로딩/빈 상태/오류 상태를 함께 검토한다.

### 통합

- API/인증/리소스/페이지네이션/목록 로딩 변경은 통합 리뷰를 거친다.
- API 계약 변경 시 소비자와 제공자를 함께 확인한다.
- 보조 앱은 행위자 안전 API 경계와 프로필 정의 런타임 경계를 우선한다.

## 기본 검증 명령

| 영역 | 명령 |
|---|---|
| 백엔드 테스트 | `<backend-test-command>` |
| 백엔드 빌드 | `<backend-build-command>` |
| 주요 프론트엔드 테스트 | `<primary-frontend-test-command>` |
| 주요 프론트엔드 빌드 | `<primary-frontend-build-command>` |
| 보조 앱 테스트 | `<secondary-app-test-command>` |
| 보조 앱 빌드 | `<secondary-app-build-command>` |

사용하지 않는 영역은 `N/A`로 둔다. 실제 명령이 바뀌면 이 표와 관련 프로필을 함께 갱신한다.

## 갱신 기준

아래 중 하나가 바뀌면 이 문서를 갱신한다.

- repo 구조 또는 주요 directory
- 기술 stack 또는 빌드/test 명령
- 백엔드 레이어 경계와 공통 정책
- 프론트 디자인 시스템/접근성/i18n 기준
- API/auth/resource/pagination 경계
- 운영/배포/환경 기준
