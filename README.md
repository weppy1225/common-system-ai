# cloud-wms-doc

WMS AI 프레임워크 허브 레포. 화면설계·지식베이스·소스패턴·산출물·BE/FE 개발 자동화 스킬의 단일 허브.

## 어디서 시작하나

| 무엇 | 문서 |
|---|---|
| 전체 진입점·섹션 역할 | [`00-overview.md`](./00-overview.md) |
| 레포 구조·폴더 경계 규칙 | [`STRUCTURE.md`](./STRUCTURE.md) |
| AI(Claude) 작업 지침·명령 목록 | [`CLAUDE.md`](./CLAUDE.md) |

## 최상위 폴더

- `knowledgebase/` — 메뉴 횡단 공통 배경지식 (AI가 읽는 도서관)
- `spec/{메뉴}/` — 메뉴별 설계 정본 (`00-domain` ~ `07` + `99`)
- `prototype/` — 검증용 화면 (공용 셸 + 메뉴별 wireframe)
- `patterns/` — 소스코드 패턴 (HOW)
- `deliverables/` — 고객 제출 산출물
- `.claude/{skills,rules}/` — 슬래시 커맨드·규칙

> 처음 clone 후 엑셀/PPT 생성 스킬을 쓰려면 `npm install` 한 번 필요.
> 폴더 재설계 이력: `_archive/`
