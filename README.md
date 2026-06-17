# cloud-wms-doc

WMS AI 프레임워크 허브 레포. 화면설계·지식베이스·소스패턴·산출물·BE/FE 개발 자동화 스킬의 단일 허브.

## 최상위 폴더

| 폴더 | 역할 | 읽는 사람 |
|---|---|---|
| `knowledgebase/` | 메뉴 횡단 공통 배경지식 (개요·업무지식·색인·설치·워크플로우) | AI·개발자 |
| `spec/{메뉴}/` | 메뉴별 설계 정본 (`00-domain` ~ `07` + `99`) | AI·개발자 |
| `prototype/` | 검증용 화면 (공용 셸 + 메뉴별 wireframe, 모바일 `{메뉴}m`) | PL·PM·고객 |
| `patterns/` | 소스코드 패턴 표준 (WEB/PDA·DB·BE·FE) | AI·개발자 |
| `deliverables/` | 산출물 템플릿(10)·원천(20)·생성결과(30) | 고객 |
| `.claude/{skills,rules}/` | 슬래시 커맨드·규칙 | AI |

## 더 보기

| 무엇 | 문서 |
|---|---|
| 레포 구조·폴더 경계 규칙 | [`STRUCTURE.md`](./STRUCTURE.md) |
| AI 작업 지침·전체 명령 목록·동작 규칙 | [`CLAUDE.md`](./CLAUDE.md) |
| 🗺️ 전체 파일·폴더 지도 (브라우저) | [`knowledgebase/20-md-index.html`](./knowledgebase/20-md-index.html) |

> 처음 clone 후 엑셀/PPT 생성 스킬을 쓰려면 `npm install` 한 번 필요.
> 파일 지도 갱신: `python scripts/gen-md-map.py`
