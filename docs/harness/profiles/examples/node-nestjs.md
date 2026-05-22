# Node / NestJS 프로파일 예시

이 파일은 예시다. 실제 프로젝트 값은 `docs/harness/profiles/project-profile.md` 또는 프로젝트별 profile에 복사해서 수정한다.

## Runtime

- Language: TypeScript
- Framework: NestJS `<version>`
- Package manager: npm/pnpm/yarn
- Database/ORM: TypeORM, Prisma, MikroORM 등
- Test: Jest, Supertest, Testcontainers 선택

## Backend script gate 예시

조직 표준에서는 repository script를 gate로 연결한다. 각 script 내부에서 실제 빌드/테스트 명령을 실행한다.

```bash
HARNESS_BACKEND_TEST_SCRIPT='scripts/ci/backend-test.sh'
HARNESS_INTEGRATION_TEST_SCRIPT='scripts/ci/integration-test.sh'
HARNESS_SECURITY_SCAN_SCRIPT='scripts/ci/security-scan.sh'
```

## NestJS 체크

- Controller는 protocol mapping과 validation에 집중하는가?
- Use case/application service가 transaction boundary를 가진다면 ORM transaction API 사용 위치가 명확한가?
- Guard/Interceptor/Pipe에서 도메인 규칙을 과도하게 처리하지 않는가?
- DTO validation과 domain invariant가 중복되거나 충돌하지 않는가?
- Prisma/TypeORM repository query에 authorization/resource scope가 숨어 있지 않은가?
- 외부 API 호출과 DB commit 순서가 명확한가?

## 추천 에이전트 흐름

- Controller/DTO 변경: `backend-api-implementer`
- Use case/transaction 변경: `backend-application-implementer`
- ORM query/migration 변경: `backend-persistence-implementer` 또는 `backend-db-migration-implementer`
- 도메인 상태 전이 변경: `task-orchestrator` -> `backend-domain-modeler`
