# cloud-wms-doc

WMS 프로젝트의 회의록·미팅 자료를 수집하고, 이를 바탕으로 화면설계를 진행하는 저장소다.

## 목적

- 회의록과 미팅 내용을 문서화하여 요건을 정리한다.
- 정리된 요건을 기반으로 화면설계 MD 파일과 프로토타입 HTML 파일을 생성한다.
- 생성된 화면설계 산출물은 백엔드 DB 설계 및 개발의 기준 자료로 사용된다.

## 산출물 생성

화면설계 MD 파일과 프로토타입 HTML 파일은 Codex slash command로 생성한다.

## 프로토타입 파일 구조

```
50-prototype/
├── index.html                              # 메인 프레임 (좌측 메뉴 + 탭 + iframe)
└── 10-common/                              # 공통 UI 파일
    ├── left-menu.html                      # 메뉴 네비게이션 (index.html과 동일)
    ├── CPCT01_popup.html                   # 거래처 검색 공통 팝업
    ├── CPPD01_popup.html                   # 품목 검색 공통 팝업
    ├── icon-preview.html                   # 사용 가능한 SVG 아이콘 목록
    ├── wms-ui.css
    ├── wms-common.js
    └── _template/                          # SD_311 생성 템플릿

30-domain/{메뉴코드}/                       # 메뉴별 지식베이스 + 프로토타입
├── {메뉴코드}-01-basic-design.md
├── {메뉴코드}-02-ui.md                     # 화면요건정리 문서 (입력)
├── {메뉴코드}-02-wireframe.html            # 프로토타입 HTML (산출물)
├── {메뉴코드}-02-mock-data.js              # 테스트 데이터 JS (산출물)
├── {메뉴코드}-03-data-model.md
├── {메뉴코드}-04-be-mapper-sql.md
├── {메뉴코드}-05-api.md
├── {메뉴코드}-06-be-flow.md
├── {메뉴코드}-07-fe-flow.md
└── {메뉴코드}-99-issues.md
```

### 파일 역할

| 파일 | 역할 |
|---|---|
| `50-prototype/index.html` | 좌측 메뉴 트리, 탭 바, 콘텐츠 iframe 포함. 메뉴 클릭 시 `loadContent('../30-domain/{메뉴코드}/{메뉴코드}-02-wireframe.html')` 호출 |
| `50-prototype/10-common/left-menu.html` | `index.html`과 동일 파일. `10-common/` 경로에서 직접 접근할 때 사용 |
| `50-prototype/10-common/CPCT01_popup.html` | 거래처 검색 팝업. `postMessage` 방식으로 부모와 통신 |
| `50-prototype/10-common/CPPD01_popup.html` | 품목 검색 팝업. `postMessage` 방식으로 부모와 통신 |
| `50-prototype/10-common/icon-preview.html` | 툴바 버튼에 사용할 수 있는 SVG 아이콘 목록. **이 파일에 없는 아이콘은 사용 금지** |
| `30-domain/{메뉴코드}/{메뉴코드}-02-ui.md` | 화면요건정리 문서. `/SD_310_UI {메뉴코드}` 명령어의 입력 소스 |
| `30-domain/{메뉴코드}/{메뉴코드}-02-wireframe.html` | 완성된 프로토타입. `50-prototype/index.html`의 iframe 안에서 로드됨 |
| `30-domain/{메뉴코드}/{메뉴코드}-02-mock-data.js` | 테스트 데이터. `const {MENUCODE}_DATA = {...}` 형태로 선언. HTML에서 `<script src>` 로 로드 |

### 팝업 통신 방식

메뉴 화면(iframe) → 부모(`50-prototype/index.html`) → 팝업 iframe 순서로 `postMessage`로 통신한다.

```
{메뉴코드}-02-wireframe.html  →  window.parent.postMessage({ type: 'OPEN_CP_LAYER' })
index.html                    →  CPCT01_popup.html 오픈
CPCT01_popup                  →  postMessage({ type: 'CP_SELECTED', data: {...} })
index.html                    →  {메뉴코드}-02-wireframe.html 로 결과 전달
```

## Slash Commands

| 명령어 | 설명 |
|---|---|
| `/SD_310_UI {메뉴코드}` | `30-domain/{메뉴코드}/{메뉴코드}-02-ui.md` 생성 |
| `/SD_311 {메뉴코드}` | `30-domain/{메뉴코드}/{메뉴코드}-02-wireframe.html` + `-02-mock-data.js` 생성, 메뉴 자동 등록 |
| `/deploy {메뉴코드}` | `50-prototype/index.html` + `50-prototype/10-common/*` + `30-domain/{메뉴코드}/*` 를 FTP 서버에 업로드 |
| `/deploy` | 변경된 메뉴를 감지해 FTP 서버에 업로드 (필요 시 전체 배포) |

## UI 규칙

프로토타입 HTML 작성 규칙은 `.codex/rules/`에 정의되어 있으며 자동으로 적용된다.
