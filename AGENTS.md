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
dist/
├── index.html                        # 메인 프레임 (좌측 메뉴 + 탭 + iframe)
├── common/                           # 공통 UI 파일
│   ├── left-menu.html                # 메뉴 네비게이션 (index.html과 동일)
│   ├── CPCT01_popup.html             # 거래처 검색 공통 팝업
│   ├── CPPD01_popup.html             # 품목 검색 공통 팝업
│   └── icon-preview.html             # 사용 가능한 SVG 아이콘 목록
└── {메뉴코드}/                        # 메뉴별 화면 (예: mdfg01, dlvo01)
    ├── ui.md                          # 화면요건정리 문서 (입력)
    ├── wireframe.html                 # 프로토타입 HTML (산출물)
    └── mock-data.js                   # 테스트 데이터 JS (산출물)
```

### 파일 역할

| 파일 | 역할 |
|---|---|
| `index.html` | 좌측 메뉴 트리, 탭 바, 콘텐츠 iframe 포함. 메뉴 클릭 시 `loadContent('{메뉴코드}/{메뉴코드}.html')` 호출 |
| `common/left-menu.html` | `index.html`과 동일 파일. `common/` 경로에서 직접 접근할 때 사용 |
| `common/CPCT01_popup.html` | 거래처 검색 팝업. `postMessage` 방식으로 부모와 통신 |
| `common/CPPD01_popup.html` | 품목 검색 팝업. `postMessage` 방식으로 부모와 통신 |
| `common/icon-preview.html` | 툴바 버튼에 사용할 수 있는 SVG 아이콘 목록. **이 파일에 없는 아이콘은 사용 금지** |
| `ui.md` | 화면요건정리 문서. `/ui {메뉴코드}` 명령어의 입력 소스 |
| `wireframe.html` | 완성된 프로토타입. `index.html`의 iframe 안에서 로드됨 |
| `mock-data.js` | 테스트 데이터. `const {MENUCODE}_DATA = {...}` 형태로 선언. HTML에서 `<script src>` 로 로드 |

### 팝업 통신 방식

메뉴 화면(iframe) → 부모(`index.html`) → 팝업 iframe 순서로 `postMessage`로 통신한다.

```
{메뉴코드}.html  →  window.parent.postMessage({ type: 'OPEN_CP_LAYER' })
index.html      →  CPCT01_popup.html 오픈
CPCT01_popup    →  postMessage({ type: 'CPCT01_select', data: {...} })
index.html      →  {메뉴코드}.html 로 결과 전달
```

## Slash Commands

| 명령어 | 설명 |
|---|---|
| `/ui {메뉴코드}` | `{메뉴코드}.md` 를 읽어 `.html` + `-data.js` 생성, 메뉴 자동 등록 |
| `/deploy {메뉴코드}` | `index.html` + `common/*` + `{메뉴코드}/*` 를 FTP 서버에 업로드 |
| `/deploy` | `dist/` 전체를 FTP 서버에 업로드 (확인 후 실행) |

## UI 규칙

프로토타입 HTML 작성 규칙은 `.codex/rules/`에 정의되어 있으며 자동으로 적용된다.
