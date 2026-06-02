# 하네스 소유권

이 문서는 템플릿을 적용한 조직에서 책임 경계를 채우기 위한 자리다.

## 필수 값

| 항목 | 값 |
|---|---|
| Harness Owner | `<harness-owner-team>` |
| Maintainer | `<project-maintainer>` |
| Security Contact | `<security-contact>` |
| Code Owners | `.github/CODEOWNERS` |
| License | `LICENSE` |

## 책임

- Harness Owner: 버전, 업그레이드 정책, source-of-truth 변경 승인.
- Maintainer: verifier, scripts, agents, skills, CI 상태 유지.
- Security Contact: project gate 실행 정책, secret 노출, 취약점 제보 접수.
- Code Owners: workflow, gate script, security policy, license 변경 리뷰.

## 적용 시 교체

새 레포에 하네스를 적용하면 `<...>` placeholder를 실제 팀/연락처 또는 내부 표준 값으로 바꾼다. 외부 공개나 외주 공유가 있으면 `LICENSE`를 조직 승인 license로 교체한다.
