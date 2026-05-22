# 보안 정책

## Project gate 실행 정책

`HARNESS_*_SCRIPT`가 기본이다. 지정된 script는 repository 내부의 허용 경로에 있어야 하고 실행 가능해야 한다.

허용 기본 경로:

- `scripts/ci/**`
- `.github/scripts/**`
- `ci/**`

`HARNESS_*_CMD`는 legacy escape hatch다. 조직 표준에서는 아래 두 값을 모두 설정해야만 동작한다.

```bash
HARNESS_ACK_TRUSTED_PROJECT_CMDS=1
HARNESS_ALLOW_LEGACY_BASH_LC=1
```

금지:

- PR/issue/user input을 command 또는 script 변수로 전달
- secret/token/key 출력
- 외부 contributor가 approval 없이 workflow/gate script 변경
- reviewer agent에 `Bash`, `Write`, `Edit`, `MultiEdit` 부여

## 권한 모델

- implementer: 필요한 경우 `Read`, `Grep`, `Glob`, `Bash`, `Edit`, `MultiEdit`, `Write`
- reviewer: `Read`, `Grep`, `Glob`만 허용
- task-orchestrator: 계획과 라우팅 중심. 제품 코드 직접 수정은 최소화한다.

## Secret / 민감정보

- completed plan에는 secret 값을 적지 않는다.
- 로그에는 토큰, 키, 비밀번호, 개인정보를 남기지 않는다.
- 보안 스캔 실패를 `SKIP`하려면 completed plan에 승인자, 대체 검증, 만료 일정을 남긴다.

## 외부 기여자 PR

- workflow와 `scripts/ci/**` 변경은 code-owner 리뷰를 요구한다.
- fork PR에서 secret이 필요한 gate는 실행하지 않거나 restricted event로 분리한다.
- project gate 명령은 PR 본문/issue 본문에서 읽지 않는다.
