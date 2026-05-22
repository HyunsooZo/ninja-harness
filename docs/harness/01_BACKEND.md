# 01. 백엔드 하네스

> 백엔드 기술 스택, 패키지 루트, 실제 행위자 이름, 리소스 이름, 실행 명령은 프로젝트 프로필/컨텍스트 값이다. 이 문서는 범용 기준만 둔다.

## 필수 읽기 문서

- `AGENTS.md` 또는 `CLAUDE.md`
- `docs/harness/context/BASELINE.md`
- `docs/harness/context/backend/README.md`
- 대상 도메인 컨텍스트: `docs/harness/context/backend/domains/*.md`
- 백엔드 품질 게이트: `docs/harness/10_BACKEND_QUALITY_GATE.md`
- 계약 변경 시: `docs/harness/04_INTEGRATION.md`, `docs/harness/context/integration/api-matrix.md`, `docs/harness/profiles/project-profile.md`

## 아키텍처

- 도메인/애플리케이션/표현/인프라 경계를 명확히 유지한다. DDD/OOP/SOLID 판단은 `10_BACKEND_QUALITY_GATE.md`를 따른다.
- 표현 계층 코드는 요청/응답 매핑, 검증, 프로토콜 관심사만 담당한다.
- 애플리케이션 서비스는 유스케이스 조율, 트랜잭션 경계, 멱등성, 부수효과 순서를 담당한다.
- 도메인 모델, 도메인 서비스, 정책, 값 객체는 불변 조건과 비즈니스 규칙을 보호한다.
- 인프라 어댑터는 영속성, 외부 시스템, 메시징, 저장소, 프레임워크 연동을 구현하되 도메인/애플리케이션으로 세부사항을 누수하지 않는다.
- 리포지토리/영속성 변경은 스키마, 쿼리 구조, 잠금, 페이지네이션, 트랜잭션 동작을 함께 검토한다.

## DDD / OOP / SOLID

- 도메인 규칙을 컨트롤러, DTO, 매퍼, 리포지토리 쿼리, UI 편의 로직에 흩어두지 않는다.
- 엔티티, 값 객체, 애그리거트, 리포지토리, 도메인 서비스, 정책, 애플리케이션 서비스 역할을 섞지 않는다.
- God Service, public setter 남발, 빈약한 데이터 묶음, map/string 기반 도메인 로직, primitive obsession은 리뷰 우려로 기록한다.
- SOLID 위반은 현재 작업의 변경 비용, 테스트 난이도, 결함 가능성을 키우는 경우 차단 이슈로 다룬다.
- 실제 변형 축이나 기존 로컬 패턴이 있을 때만 추상화를 추가한다.

## 권한과 리소스 경계

- 행위자 또는 리소스 범위 API는 행위자 식별, 역할/capability, 활성 리소스 상태, 소유/소속 관계를 먼저 검증한다.
- 행위자, 마스킹 규칙, 공개 범위가 다르면 주요/보조/공개/통합 API 영역을 의도적으로 분리한다.
- 민감 응답에는 내부 식별자, 저장 경로, 원본 토큰, 공개 토큰, 비공개 URL, 구현 전용 필드를 직접 노출하지 않는다.
- 공개 링크, 서명, 미리보기, 다운로드, 첨부, 파일 흐름은 실패 시 차단 헬퍼나 정화 경계를 우선 사용한다.

## 트랜잭션과 멱등성

- 트랜잭션 경계는 애플리케이션 서비스 또는 그에 준하는 유스케이스 경계에 둔다. 프레임워크/프로필이 다른 패턴을 요구하면 활성 계획에 이유를 남긴다.
- 선택한 스택에서 쓰기/읽기 전용 동작, propagation, rollback, self-invocation/proxy 제약, 비동기 경계, lazy loading 동작을 확인한다.
- 재시도, 콜백, 중복 제출, 반복 사용자 행동은 unique constraint, 상태 전이 가드, 멱등성 키 또는 동등한 장치로 방어한다.
- 외부 API 호출, 파일 I/O, 알림, 메시징 같은 부수효과는 트랜잭션 내부 실행, 커밋 후 실행, outbox, 재시도 정책 중 무엇을 쓸지 명시한다.
- 동시성 위험이 있는 변경은 선택한 잠금, 제약, 충돌 처리 전략을 문서화하고 테스트 또는 재현 절차로 검증한다.

## 목록과 페이지네이션

- 목록 API는 page/size 제한, 정렬, 필터링, total/last 의미, 빈 페이지 종료 조건을 정의한다.
- 여러 페이지를 모으는 소비자 헬퍼는 제공자 제한과 종료 조건을 따라야 한다.
- 목록 로딩, 페이지네이션, 필터링 변경은 통합 리뷰 후보로 본다.

## Owned API 소비자 영향 확인

백엔드에서 controller/route/DTO/schema/request/response/status/error/pagination/auth/resource scope를 변경하면 해당 API를 호출하는 프론트엔드가 있는지 확인한다.

- `docs/harness/04_INTEGRATION.md`의 Owned API Contract Impact Rule을 따른다.
- endpoint path, generated client, API service/fetcher, query key, hook/composable, store/cache, validation schema, 화면 컴포넌트, 테스트를 검색한다.
- 호출 화면이 있으면 필요한 프론트 타입, 매핑, 로딩/빈/오류/권한 없음 상태, 테스트를 함께 수정한다.
- 호출 화면이 없거나 수정이 불필요하면 검색어와 근거를 active plan에 남긴다.

## 테스트

- 관련 테스트가 있으면 먼저 실행한다.
- 동작 변경이 있는데 의미 있는 테스트 범위가 없으면 테스트를 추가한다.
- RED -> GREEN -> REFACTOR -> VERIFY는 `05_TESTING.md`와 `09_EVIDENCE_GATE.md`를 따른다.
- 먼저 대상 테스트를 실행하고, 공유 동작/보안/영속성/계약에 영향이 있으면 더 넓은 테스트와 빌드로 확장한다.

## 검증

실제 명령은 `docs/harness/context/BASELINE.md` 또는 `docs/harness/profiles/project-profile.md`에서 가져온다.

```bash
<backend-test-command>
<backend-targeted-test-command>
<backend-build-command>
<backend-runtime-command>
```

런타임이나 의존 서비스는 프로필별 값이다. 필요하면 시작/중지 명령과 정리 절차를 활성 계획에 기록한다.

## 완료 기준

- 레이어 경계가 유지된다.
- DDD/OOP/SOLID/Clean Code와 트랜잭션 검토 결과가 활성 계획 또는 리뷰 보고에 남았다.
- 권한, 리소스 범위, 페이지네이션, 동시성, 멱등성, 민감 정보 노출 위험을 점검했다. API 계약 변경이면 프론트 호출부 영향도도 확인했다.
- 동작 변경에는 RED/GREEN/REFACTOR 증거가 있거나 문서화된 예외가 있다.
- 장기 사실이 바뀌었다면 관련 백엔드/통합 컨텍스트가 갱신됐다.

## 도메인 / 영속성 분리

백엔드 작업이 도메인 규칙과 영속성 구현을 함께 건드리면, 에이전트를 나눌 수 있는지 먼저 판단한다.

| 범위 | 에이전트 | 기준 |
|---|---|---|
| 엔티티, 값 객체, 애그리거트, 불변 조건, 상태 전이, 도메인 서비스, 정책 | `backend-domain-modeler` | 도메인 언어와 비즈니스 규칙을 보호한다. |
| 리포지토리 어댑터, ORM 매핑, 쿼리, 잠금, 페이지네이션, 영속성 테스트 | `backend-persistence-implementer` | 인프라 세부사항이 도메인/애플리케이션으로 새지 않게 한다. |
| 트랜잭션 경계, 유스케이스 조율, 멱등성, 부수효과 | `backend-application-implementer` | 원자성과 부수효과 순서를 명확히 관리한다. |
| 마이그레이션, 스키마/인덱스, 데이터 런타임, 로컬 의존 런타임 | `backend-db-migration-implementer` | 스키마와 실행 환경 리스크를 관리한다. |

분리하더라도 도메인 계약, 리포지토리 계약, 트랜잭션 경계는 활성 계획에 먼저 고정한다. 같은 애그리거트, 리포지토리 인터페이스, 마이그레이션/스키마 파일, 트랜잭션 경계를 여러 에이전트가 병렬로 수정하지 않는다.


## 백엔드 에이전트 오케스트레이션

백엔드 레이어별 에이전트는 항상 동시에 협업하지 않는다. 작은 단일 변경은 한 에이전트가 처리한다. 도메인 규칙, 트랜잭션, 영속성, API 계약이 함께 바뀌는 작업만 `13_AGENT_ORCHESTRATION.md` 기준으로 분리 위임한다.

권장 기본 순서는 domain -> application -> persistence -> migration -> API -> test/review다. 단, 특정 레이어만 바뀌면 해당 에이전트만 사용한다. 분리 위임 시 active plan에 공통 결정, 레이어별 수정 가능 범위, 통합 담당자를 기록한다.
