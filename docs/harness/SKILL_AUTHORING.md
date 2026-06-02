# 스킬 작성 정책

스킬은 독립 문서가 아니라 라우터다. 긴 규칙 본문은 numbered core 문서와 `docs/harness/context/**`, `docs/harness/profiles/**`에 둔다.

## 원칙

- 스킬은 "언제 트리거되는가"와 "어느 source-of-truth를 읽는가"를 짧게 안내한다.
- 정책 본문을 스킬마다 반복하지 않는다.
- 중복이 필요하면 numbered core 문서에 먼저 반영하고 스킬은 그 문서를 가리킨다.
- 스킬 변경 후 `scripts/sync-skills.py`로 `.claude/skills/**` mirror를 갱신한다.

## 공통 운영 블록

모든 `.agents/skills/**/SKILL.md`는 아래 공통 운영 기준을 이 문서로 위임한다. 스킬 파일에는 역할별 트리거, 읽을 문서, 고유 체크포인트만 남긴다.
스킬 파일의 SSOT 포인터는 `docs/harness/SKILL_AUTHORING.md#공통-운영-블록`이다.

### 기본 읽기

- `AGENTS.md`
- `docs/harness/README.md`
- `docs/harness/05_TESTING.md`
- 작업 범위에 맞는 numbered core 문서
- 관련 `docs/harness/context/**`와 `docs/harness/profiles/**`

### 증거 게이트

- 단순하지 않은 작업은 `docs/harness/plans/active/`에 활성 계획을 만든다.
- 동작 변경은 `docs/harness/09_EVIDENCE_GATE.md` 기준으로 RED/GREEN/REFACTOR/VERIFY 증거를 남긴다.
- 자동화 RED가 부적합하면 예외 사유, 대체 검증, 잔여 위험을 active plan에 기록한다.
- 완료 시 활성 계획을 `docs/harness/plans/completed/`로 이동한다.

### 기본 보고

- 적용한 기준
- 변경 또는 리뷰 범위
- 실행한 검증과 결과
- 남은 위험 또는 실행하지 못한 검증

## 허용 내용

- frontmatter `name`, `description`
- 먼저 읽을 문서
- 역할별 핵심 체크포인트 요약
- 출력 형식
- 직접 연결된 dispatch prompt 경로

## 금지 내용

- numbered core 문서와 충돌할 수 있는 긴 정책 재서술
- 프로젝트별 실제 경로, 토큰, API prefix
- 다른 스킬과 의미가 같은 규칙의 반복 확장
- `공통 운영 블록`과 같은 증거 게이트/기본 보고 boilerplate 반복

## 검증

구조 검증은 skill mirror drift, 기본 라우팅, 공통 운영 블록 포인터, 금지된 boilerplate 반복을 확인한다. 의미 중복은 리뷰에서 확인하고, 반복되는 중복은 이 문서와 `docs/harness/skill-routing.md` 기준으로 정리한다.
