# API 테스트 파일 위치 규칙

> 항상 로딩(`paths` 생략) — Bruno 파일 생성 시 예외 없이 적용.

## Bruno 파일 생성 위치 (MUST)

| 파일 | 저장 위치 |
|---|---|
| `bruno.json` (컬렉션 메타) | `spec/{프로젝트}/{메뉴코드}/bruno.json` |
| `*.bru` (요청 파일) | `spec/{프로젝트}/{메뉴코드}/{순번}_{이름}.bru` |

**이유**: 메뉴별 설계 정본(`-03-data-model.md`, `-05-api.md`)과 함께 관리하면 설계·테스트를 한 디렉토리에서 추적할 수 있다.

```
spec/kyochon-oms/shsb01c/        ← 예시
├── shsb01c-03-data-model.md
├── shsb01c-05-api.md
├── bruno.json
├── 01_login.bru
├── 02_list.bru
└── 03_cancel.bru
```

## NEVER

- `C:\zinide\workspace\api-test\` 등 별도 api-test 디렉토리에 생성하지 않는다.
- 레포 루트나 `deliverables/` 등 spec 외부 경로에 두지 않는다.
