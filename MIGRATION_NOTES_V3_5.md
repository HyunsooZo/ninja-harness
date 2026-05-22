# 마이그레이션 메모 v3.5

## 변경 요약

- `AGENTS.md`를 짧은 진입 문서로 축소하고, 세부 매핑은 `docs/harness/skill-routing.md`와 `docs/harness/harness.yaml`로 이동했다.
- 파일명으로 쓰면 안 되는 경로 자리표시자 참조를 실제 agent/skill 이름으로 수정했다.
- `docs/harness/profiles/`를 추가해 행위자/API prefix/토큰/패키지 같은 프로젝트별 맥락을 핵심 문서와 분리했다.
- `*-reviewer` Codex agent의 sandbox를 `read-only`로 바꾸고 읽기 전용 안전 계약을 추가했다.
- 프론트엔드 접근성, 반응형 레이아웃, 통합 계약, 디자인 시스템 스킬에 실무 점검 항목을 보강했다.
- `scripts/verify-harness-structure.sh`에 자리표시자, 리뷰어 sandbox, 프로필 문서, source-of-truth 중복 검사를 추가했다.

## 적용 시 주의

- 새 프로젝트에 복사할 때는 `docs/harness/profiles/project-profile.md`, `docs/harness/profiles/design-system-profile.md`, `docs/harness/context/BASELINE.md`를 먼저 실제 프로젝트 기준으로 갱신한다.
- 기존 프로젝트별 토큰 별칭은 새 프로젝트에서 프로필 기준 prefix로 교체한다.
