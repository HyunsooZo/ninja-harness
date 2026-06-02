# 스킬 작성 정책

스킬은 독립 문서가 아니라 라우터다. 긴 규칙 본문은 numbered core 문서와 `docs/harness/context/**`, `docs/harness/profiles/**`에 둔다.

## 원칙

- 스킬은 "언제 트리거되는가"와 "어느 source-of-truth를 읽는가"를 짧게 안내한다.
- 정책 본문을 스킬마다 반복하지 않는다.
- 중복이 필요하면 numbered core 문서에 먼저 반영하고 스킬은 그 문서를 가리킨다.
- 스킬 변경 후 `scripts/sync-skills.py`로 `.claude/skills/**` mirror를 갱신한다.

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

## 검증

구조 검증은 skill mirror drift와 기본 라우팅을 확인한다. 의미 중복은 리뷰에서 확인하고, 반복되는 중복은 이 문서와 `docs/harness/skill-routing.md` 기준으로 정리한다.
