# 프로젝트 프로파일

이 문서는 하네스가 적용되는 프로젝트의 구체 맥락을 둔다.
범용 핵심 문서에는 가능한 한 이 내용을 직접 박지 않는다.

새 프로젝트에 하네스를 넣은 뒤 아래 자리표시자를 실제 값으로 교체한다.

## 저장소 자리표시자

| Placeholder | 의미 | 현재 값 |
|---|---|---|
| `<workspace-root>` | 하나 이상의 Git 저장소를 담는 작업 루트 | `<fill-workspace-root>` |
| `<backend-dir>` | 백엔드 Git 저장소 또는 package | `<fill-backend-path-or-n/a>` |
| `<primary-frontend-dir>` | 주요 운영 프론트엔드 저장소 또는 package | `<fill-primary-frontend-path-or-n/a>` |
| `<secondary-app-dir>` | 보조 앱 저장소 또는 package | `<fill-secondary-app-path-or-n/a>` |

## 런타임 스택

| 영역 | Stack / Runtime | Package manager / Build tool |
|---|---|---|
| 백엔드 | `<fill-backend-stack>` | `<fill-backend-build-tool>` |
| 주요 프론트엔드 | `<fill-primary-frontend-stack>` | `<fill-primary-frontend-tooling>` |
| 보조 앱 | `<fill-secondary-app-stack>` | `<fill-secondary-app-tooling>` |

## 행위자와 리소스 용어

| 범용 용어 | 프로젝트 용어 | 메모 |
|---|---|---|
| 주요 행위자 | `<fill-primary-actor>` | 운영/관리 성격의 주 행위자 |
| 보조 행위자 | `<fill-secondary-actor>` | 보조 앱의 행위자 |
| 공개 행위자 | `<fill-public-actor-or-n/a>` | 익명/공개 흐름이 있으면 작성 |
| 리소스 범위 | `<fill-resource-term>` | 권한과 필터링 기준이 되는 리소스 |
| 소속 / 소유 관계 | `<fill-membership-rule>` | 행위자-리소스 접근 검증 방식 |

## API 경계

- 주요 API prefix: `<fill-primary-api-prefix>`
- 보조 앱 API prefix: `<fill-secondary-api-prefix>`
- 공개 API prefix: `<fill-public-api-prefix-or-n/a>`
- legacy route allow-list 위치: `docs/harness/context/integration/api-matrix.md`
- redaction policy: `<fill-sensitive-field-policy>`

규칙:

- 새 route 소비는 API matrix를 갱신한다.
- 공유 또는 레거시 엔드포인트는 API matrix가 해당 소비자를 허용할 때만 소비한다.
- 행위자별 서비스/타입 래퍼는 UI에 안전하지 않은 제공자 구조를 숨긴다.
- 민감 필드, 원본 토큰, 비공개 URL, 저장 경로, 구현 전용 ID는 명시 허용되지 않는 한 제외한다.

## 백엔드 패키지 경계

권장 표현 계층 분리 템플릿:

```text
<backend-root-package>/<domain>/presentation
  primary
  secondary
  public
```

`<backend-root-package>`와 화면 영역 이름은 실제 프로젝트 용어로 교체한다.

## 검증 명령

구체 명령은 `docs/harness/context/BASELINE.md`에도 둔다.

```bash
<backend-test-command>
<primary-frontend-build-command>
<secondary-app-build-command>
```
