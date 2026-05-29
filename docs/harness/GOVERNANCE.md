# 중앙 거버넌스 정책

이 문서는 하네스를 대형 조직 표준 후보로 운영할 때 필요한 중앙 관리 기준을 정의한다.

## 역할

| 역할 | 책임 |
|---|---|
| Harness Maintainer | 하네스 버전, source of truth, mirror drift, 검증 스크립트 관리 |
| Platform/DevEx Owner | CI 템플릿, branch protection, project gate 표준화 |
| Security Reviewer | project gate 명령 정책, secret 노출, 권한 모델 검토 |
| Team Adopter | project profile/context 작성, 실제 gate 연결, completed plan 기록 |

## 표준 적용 단계

1. 파일럿 프로젝트 1~3개 선정
2. `make integrity` 통과
3. 적용 저장소에서 `make project-ready` 또는 동등한 profile readiness 통과
4. `HARNESS_ORG_STANDARD=1`과 최소 1개 실제 project gate 연결
5. completed plan 20개 이상 또는 2주 이상 운영 데이터 수집
6. eval 지표 검토
7. 회귀 사례를 `docs/harness/evals/regression-cases.md`에 반영
8. 팀 표준 또는 조직 표준으로 승격

## 필수 정책

- agent/skill 수정 시 mirror sync와 `make integrity`를 모두 통과한다.
- 조직 표준 CI는 `HARNESS_ACK_TRUSTED_PROJECT_CMDS=1`을 명시한다.
- project gate는 `HARNESS_*_SCRIPT`를 기본으로 사용한다.
- legacy `HARNESS_*_CMD`는 예외 승인 없이 사용하지 않는다.
- reviewer agent의 read-only tool set은 변경하지 않는다.
- 예외는 completed plan에 사유, 승인자, 대체 검증, 만료 일정을 남긴다.

## 변경 관리

- patch: 문구, 설명, 검증 보강
- minor: 새 agent/skill/gate 추가, source of truth 변경 없음
- major: source of truth, agent 계약, 조직 표준 gate의 breaking change

## 운영 회의 체크리스트

- 최근 2주 project gate 실패율
- reviewer FAIL 사유 TOP N
- orchestration mode별 실패율/소요
- fan-in conflict 발생률
- regression case 반영률
- team adoption scorecard 상태
