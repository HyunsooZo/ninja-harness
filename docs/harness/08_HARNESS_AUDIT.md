# 08. 하네스 감사

이 품질 게이트는 하네스 자체를 정리하거나, 하네스 지침 충돌을 해결하거나, 하네스가 프로젝트 간 재사용 가능한 상태인지 확인할 때 사용한다.

## 목표 구조

- `AGENTS.md`와 `CLAUDE.md`는 짧은 진입 지도 역할만 한다.
- `docs/harness/00~05`, `07`, `09~11`은 범용 작업 흐름, 레이어 규칙, 디자인 규칙, 품질 게이트, 증거 게이트, 병렬 에이전트 규칙을 정의한다.
- `docs/harness/context/**`는 적용 저장소의 사실과 장기 구현 맥락을 저장한다.
- `docs/harness/profiles/**`는 프로젝트별 행위자/리소스 용어, API prefix, 패키지 루트, 토큰 이름, 실행 명령, 런타임 결정을 저장한다.
- `docs/harness/plans/**`는 작업 단위 상태, 증거, 완료 보고를 저장한다.
- `.agents/skills/**`는 실행 가능한 스킬 지침을 저장한다.
- `.codex/agents/**`와 `.claude/agents/**`는 역할별 에이전트 지침을 저장하며 서로 미러 상태를 유지한다.

## 현재 정리 결정

- 저장소 로컬 스킬 로딩은 `.agents/skills`로 지원한다.
- `docs/harness/rubrics/*.md`는 기존 참조 호환을 위한 얇은 체크리스트로 남긴다.
- 오래된 호환 래퍼 문서는 유지하지 않는다.
- 폐기한 중복 핵심 문서는 다시 만들지 않는다.
  - `06_PROJECT_BASELINE.md`
  - `12_CONTEXT_LOADING_RULE.md`
- 현재 런타임/도구에 없는 이름은 필수 규칙으로 쓰지 않는다.
- 프로젝트별 어휘는 번호가 붙은 핵심 문서가 아니라 프로필/컨텍스트에 둔다.

## 우선순위

1. 실제 적용 저장소와의 호환성
2. 현재 에이전트 런타임에서 실행 가능한 지침
3. 짧고 읽기 쉬운 핵심 문서
4. 범용 규칙과 프로젝트 프로필 값의 명확한 분리
5. 필요한 기존 참조 호환성
6. 중복, 오래된, 오해를 부르는 래퍼 파일 제거

## 정리 체크리스트

- [x] `AGENTS.md`는 짧은 진입 지도다.
- [x] `docs/harness/README.md`가 문서 구조를 설명한다.
- [x] `docs/harness/skill-routing.md`가 사용 가능한 스킬과 에이전트를 매핑한다.
- [x] `.agents/skills/*/SKILL.md`가 현재 문서 경로를 참조한다.
- [x] `.codex/agents/*.toml`과 `.claude/agents/*.md`가 미러 상태다.
- [x] `.DS_Store` 같은 로컬 산출물이 없다.
- [x] 완료된 활성 계획은 `completed/`로 이동한다.
- [x] 활성/완료 계획이 실행 증거를 담당하고, 생성된 전체 스캔은 생성 산출물로만 남긴다.
- [x] 폐기한 `06_PROJECT_BASELINE.md`와 `12_CONTEXT_LOADING_RULE.md`가 없다.
- [x] 프로젝트별 행위자/API/토큰/패키지 값은 `profiles/**` 또는 `context/**`로 분리됐다.
- [x] 리뷰어 에이전트에 읽기 전용 안전 계약이 있다.
- [x] RED/GREEN/REFACTOR/VERIFY 정책이 핵심 문서, rubric, 스킬, 에이전트에서 일관된다.

## 범용 핵심 문서 감사

핵심 문서는 프로필 기반 구조여야 한다. 번호가 붙은 문서, rubric, routing 문서, 호환 문서를 감사할 때 특정 프로젝트 값이 새지 않았는지 확인한다.

핵심 문서에 있으면 안 되는 값의 예:

- 한 제품에만 맞는 구체 행위자 라벨
- 한 제품에만 맞는 API prefix
- 한 domain에만 맞는 구체 리소스 용어
- 구체 패키지 루트
- 구체 brand color 값 또는 토큰 접두사
- 의도적으로 스택별 문서가 아닌 곳의 구체 프레임워크/스택 이름

허용 위치:

- `docs/harness/context/**`
- `docs/harness/profiles/**`
- `docs/harness/plans/**`의 이력 증거

## 테스트 게이트 감사

- 동작 변경을 다루는 하네스/스킬/에이전트는 `05_TESTING.md`와 RED/GREEN/REFACTOR 증거 또는 문서화된 예외를 요구해야 한다.
- 레이어 rubric은 RED 증거, GREEN 확인, REFACTOR 재실행, VERIFY 결과, 예외 사유를 확인해야 한다.
- 예외는 문서만 변경, 순수 스타일, 조사, 플랫폼/런타임 제약, 또는 자동화 가치가 낮다는 명확한 근거가 있을 때로 좁게 둔다.
- 예외에도 대체 검증과 잔여 위험은 필요하다.

## 컨텍스트 생명주기 감사

- 단순하지 않은 작업은 활성 계획을 만들거나 갱신한다.
- 완료된 작업은 `docs/harness/plans/completed/`로 이동한다.
- `docs/harness/context/**`는 현재 사실을 기록하며 긴 명령 로그를 담지 않는다.
- 생성된 전체 스캔은 기본 컨텍스트가 아니다.
- 장기 결정은 `context/DECISIONS.md` 또는 관련 프로필/컨텍스트 파일에 둔다.

## 충돌 해결

- 구현 작업은 `AGENTS.md` 또는 `CLAUDE.md`와 `00_AGENT_BRIEF.md`를 따른다.
- 레이어 세부 기준은 `01_BACKEND`, `02_PRIMARY_FRONTEND`, `03_SECONDARY_APP`, `04_INTEGRATION`, `05_TESTING`, `07_DESIGN_SYSTEM`을 따른다.
- 백엔드 구조 품질은 `10_BACKEND_QUALITY_GATE.md`를 따른다.
- 병렬 에이전트 판단은 `11_PARALLEL_AGENT_GATE.md`를 따른다.
- 현재 적용 저장소 사실은 `context/**`와 `profiles/**`를 따른다.
- 문서와 코드가 충돌하면 코드를 확인하고 오래된 컨텍스트/프로필 문서를 갱신한다.

## 최종 검토

```bash
make integrity
bash scripts/verify-harness-structure.sh
find . -name .DS_Store -print
find docs/harness/plans/active -mindepth 1 ! -name .gitkeep -print
```

`make integrity`는 doctor, 구조 검증, gate self-test, completed plan 품질, active plan 잔여 여부, whitespace 검사를 묶은 최종 local gate다. 프로젝트별 표현 누출은 구조 검증 스크립트가 핵심 문서에 대해 확인한다. 이력 계획과 프로필/컨텍스트 파일은 의도적으로 제외한다.
