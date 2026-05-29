# 프로젝트 프로파일

`docs/harness/profiles/**`는 범용 핵심 하네스와 실제 프로젝트 값을 분리하기 위한 맞춤 계층이다.

## 파일

- `project-profile.md`: 저장소 경로, 스택, 행위자/리소스 용어, API prefix, 패키지 경계, 민감 필드 정책을 둔다.
- `design-system-profile.md`: 테마 이름, 토큰 접두사, 브랜드 색상, 글꼴 묶음, 간격/반경 척도, 호환 별칭을 둔다.

## 규칙

- 번호가 붙은 핵심 문서는 재사용 가능하고 프로필 기반이어야 한다.
- 프로젝트별 값은 이 디렉터리 또는 `docs/harness/context/**`에 둔다.
- 새 프로젝트에 하네스를 적용할 때는 핵심 문서를 바꾸기 전에 이 프로필부터 채운다.
- 적용 준비도를 확인할 때는 `make project-ready` 또는 `bash scripts/check-profile-readiness.sh`를 실행한다. 남은 `<...>` placeholder는 실패 처리되며, 사용하지 않는 영역은 `N/A`처럼 angle bracket 없는 값으로 적는다.

## Examples

- `examples/spring-boot-rest.md`: JVM REST/JPA backend profile example
- `examples/node-nestjs.md`: Node layered backend profile example
- `examples/react-next.md`: react-next frontend profile example
- `examples/vue-vite.md`: vue-vite frontend profile example
- `examples/frontend-testing.md`: frontend testing/a11y/visual regression profile example

## 예시 프로파일

`examples/`에는 실제 프로젝트에 복사해서 수정할 수 있는 시작점을 둔다.

- `spring-boot-rest.md`: spring-boot-rest/JPA 백엔드 예시
- `node-nestjs.md`: node-nestjs 백엔드 예시
- `react-next.md`: react-next 프론트엔드 예시
- `vue-vite.md`: vue-vite 프론트엔드 예시
- `frontend-testing.md`: 프론트 테스트/접근성/시각 회귀 게이트
