# 04. 통합 하네스

> 행위자 라벨, API prefix, 리소스 이름, 라우트 예시, 소비자 이름은 프로필/컨텍스트 값이다. 이 문서는 범용 기준만 둔다.

이 문서는 제공자와 소비자 사이의 프론트엔드/백엔드 계약, 인증과 권한 경계, 리소스 범위, 페이지네이션/목록 로딩, API 화면 영역 변경 기준을 다룬다.

## 필수 읽기 문서

- `AGENTS.md` 또는 `CLAUDE.md`
- `docs/harness/context/BASELINE.md`
- `docs/harness/context/integration/api-matrix.md`
- 백엔드 변경: `docs/harness/01_BACKEND.md`
- 주요 프론트엔드 변경: `docs/harness/02_PRIMARY_FRONTEND.md`
- 보조 앱 변경: `docs/harness/03_SECONDARY_APP.md`
- 프로젝트 어휘: `docs/harness/profiles/project-profile.md`

## 짝 검토 규칙

- 프론트엔드 변경이 백엔드 API 구조, DTO/schema, 권한, 응답 구조, status/error, 페이지네이션 계약, 마스킹에 의존하면 Owned API Contract Impact Rule에 따라 제공자와 소비자를 함께 수정하거나 검증한다.
- 프론트엔드 변경이 표현 전용이라면 백엔드를 수정하지 않는다.
- 백엔드 요청/응답 구조가 바뀌면 해당 API를 호출하는 프론트 서비스, 타입, hook/composable, query key, 화면, 테스트, 로딩/빈 상태/오류 상태, 등록된 소비자를 함께 검색하고 확인한다.
- 공유 계약은 제공자 동작과 소비자 사용이 일치할 때 완료다.

## Owned API Contract Impact Rule

프론트엔드와 백엔드가 같은 조직/저장소/서비스 경계 안에서 소유한 API를 함께 다루는 경우, API 요청/응답/DTO 변경은 단일 레이어 변경으로 보지 않는다. 표현 전용 변경이면 한쪽만 수정할 수 있지만, 계약 변경 가능성이 있으면 제공자와 소비자 양쪽 영향도를 반드시 확인한다.

### 프론트엔드에서 API DTO, 요청, 응답, 에러, pagination, auth/resource scope를 수정하는 경우

1. 해당 API가 우리 백엔드 API인지 확인한다.
2. 우리 백엔드 API라면 backend controller/route, DTO/schema, validation, use case, OpenAPI/API 문서 또는 `docs/harness/context/integration/api-matrix.md`를 확인한다.
3. 프론트 ViewModel/표시 매핑만 바꾸면 되는지, 백엔드 API contract 자체 수정이 필요한지 구분한다.
4. 백엔드 contract 수정이 필요하면 `backend-api-implementer`, 필요 시 `backend-application-implementer`, `backend-persistence-implementer`, `integration-reviewer`를 함께 라우팅한다.
5. 수정하지 않는 경우에도 “백엔드 수정 불필요” 근거와 확인한 파일/문서를 active plan에 남긴다.

### 백엔드에서 API 요청/응답, DTO/schema, status/error, pagination, auth/resource scope를 변경하는 경우

1. 해당 API를 호출하는 프론트엔드 코드가 있는지 검색한다.
2. endpoint path, generated client, API service/fetcher, query key, hook/composable, store/cache, validation schema, 화면 컴포넌트, 테스트를 확인한다.
3. 호출 화면이 있으면 필요한 프론트 타입, 매핑, 상태 처리, 로딩/빈/오류/권한 없음 UI, 테스트까지 함께 수정한다.
4. 호출 화면이 없다고 판단한 경우에도 검색어, 검색 범위, 확인 결과를 active plan에 남긴다.

### 수정 판단

- 프론트 전용 ViewModel/표시명/정렬만 바뀌고 provider contract가 그대로면 백엔드 수정은 하지 않는다.
- 백엔드 내부 DTO/refactor가 외부 API surface를 바꾸지 않으면 프론트 수정은 하지 않는다.
- 우리 소유 API가 아닌 외부 API/서드파티 계약이면 adapter 또는 wrapper 영향도를 별도로 기록한다.
- API matrix가 있으면 route owner, allowed consumers, auth/resource scope, masking, pagination, wrapper 필요 여부를 함께 갱신한다.

## 계약 점검

- 요청/응답 구조가 소비자 사용과 일치한다.
- 인증 헤더, 세션 refresh/logout, 행위자 capability, 리소스 선택, 소속/소유 확인이 일관된다.
- 목록 API는 page/size 제한, total/last 의미, 정렬/필터링, 빈 페이지 종료 조건을 정의한다.
- 행위자, 권한, 마스킹 규칙이 다르면 주요/보조/공개/통합 API 영역을 분리한다.
- 소비자용 응답은 다른 화면 영역 전용 필드나 내부 구현 필드를 피한다.
- 오류 응답이 소비자의 로딩, 빈 상태, 재시도, 인증 필요, 권한 없음, 오래된 상태, 검증 상태와 맞는다.

## 고위험 영역

- 인증/부트스트랩/토큰 보존
- 리소스 선택과 행위자 capability 경계
- 공개 링크, 서명 세션, 공개 토큰, 비공개 URL, 다운로드 흐름
- HTML 미리보기, 외부 이미지, OAuth 또는 서드파티 리다이렉트
- 페이지네이션, 필터, 정렬, 전체 목록 집계
- 문서/템플릿/파일/서명 작업 흐름
- 새 행위자별 API 영역

## 문서화

- 공유 API 동작이 바뀌면 `docs/harness/context/integration/api-matrix.md`를 갱신한다.
- 백엔드 도메인 변경은 관련 `docs/harness/context/backend/domains/*.md`를 갱신한다.
- 프론트엔드 화면/작업 흐름 변경은 관련 `docs/harness/context/frontend/**` 문서를 갱신한다.
- 프로젝트별 route 이름, 행위자 용어, 리소스 이름은 이 핵심 문서가 아니라 `docs/harness/profiles/project-profile.md`와 API matrix에 둔다.

## 리뷰 게이트

아래 변경은 통합 리뷰 대상이다.

- 요청/응답 계약 변경
- 인증, 권한, 리소스 범위, 페이지네이션, 필터링, 목록 로딩 변경
- 주요/보조/공개/통합 API 영역 사이의 경계 변경
- 프론트엔드/백엔드를 함께 수정한 변경
- 민감 정보 마스킹 또는 공개 URL/토큰 정책 변경
- 런타임 저장소, refresh/logout, deep-link 계약 변경

## 완료 기준

- 제공자/소비자 계약 불일치가 남아 있지 않다.
- 인증, 권한, 리소스 범위, 페이지네이션, 마스킹 경계가 테스트 또는 명확한 검증으로 확인됐다.
- 동작 또는 계약 변경에는 RED/GREEN/REFACTOR 증거가 있거나, 예외 사유와 대체 검증이 문서화됐다.
- 장기 사실이 바뀌었다면 공유 컨텍스트와 API matrix가 갱신됐다.
- 프론트엔드와 백엔드가 필요한 경우 함께 처리됐다.
