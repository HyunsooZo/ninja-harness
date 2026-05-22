# v3 마이그레이션 메모

## 변경점

- Codex용 `.codex/agents/*.toml`과 Claude용 `.claude/agents/*.md`를 함께 제공한다.
- 본문 기준 언어를 한국어로 통일했다.
- Codex model 기본값을 `gpt-5.5`로 맞췄다.
- 작업 evidence 저장소를 `docs/harness/plans/active/`로 고정했다.
- 별도 `.harness/` 폴더를 만들지 않는다.

## 적용 시 확인

- 기존 프로젝트의 Codex 설정을 덮어쓰기 전에 diff를 확인한다.
- 프로젝트별 경로 플레이스홀더를 실제 경로로 바꾼다.
- 하네스 문서와 context 문서가 충돌하면 `AGENTS.md`와 `docs/harness/**`를 우선한다.

## v3.3

- 백엔드 도메인/영속성 통합 에이전트를 제거하고 `backend-domain-modeler`, `backend-persistence-implementer`로 분리했다.
- 기존 `backend-domain-modeler / backend-persistence-implementer` 참조는 두 에이전트 중 하나로 바꾼다.
