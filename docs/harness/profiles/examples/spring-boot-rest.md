# Spring Boot REST / JPA 프로파일 예시

이 파일은 예시다. 실제 프로젝트 값은 `docs/harness/profiles/project-profile.md` 또는 프로젝트별 profile에 복사해서 수정한다.

## Runtime

- Language: Java `<version>`
- Framework: Spring Boot `<version>`
- Build: Gradle 또는 Maven
- Database: `<database>`
- Migration: Flyway 또는 Liquibase
- Test: JUnit 5, Spring Boot Test, Testcontainers 선택

## Backend script gate 예시

조직 표준에서는 repository script를 gate로 연결한다. 각 script 내부에서 실제 빌드/테스트 명령을 실행한다.

```bash
HARNESS_BACKEND_TEST_SCRIPT='scripts/ci/backend-test.sh'
HARNESS_INTEGRATION_TEST_SCRIPT='scripts/ci/integration-test.sh'
HARNESS_SECURITY_SCAN_SCRIPT='scripts/ci/security-scan.sh'
```

## Spring/JPA 체크

- `@Transactional` self-invocation이 없는가?
- transaction boundary가 application service에 있는가?
- `readOnly=true` 사용이 실제 변경 없는 조회에만 적용되는가?
- lazy loading으로 인한 N+1 위험을 확인했는가?
- flush timing과 dirty checking이 의도한 시점에 맞는가?
- optimistic lock 또는 pessimistic lock 선택 근거가 있는가?
- unique constraint와 idempotency key가 함께 필요한가?
- domain event 또는 외부 호출은 commit 전/후/outbox 중 어디에 속하는가?
- migration은 rollback/compatibility/zero-downtime 영향이 검토됐는가?

## 추천 에이전트 흐름

- 단일 service bug: `backend-application-implementer`
- aggregate/state transition 변경: `task-orchestrator` -> `backend-domain-modeler` -> `backend-application-implementer`
- JPA mapping/query/lock 변경: `backend-persistence-implementer`
- schema/index 변경: `backend-db-migration-implementer`
- auth/resource scope 변경: `backend-security-reviewer` + `integration-reviewer`
