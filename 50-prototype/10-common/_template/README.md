---
title: HTML 스켈레톤 템플릿
description: /ui 명령으로 HTML 화면 스켈레톤을 만들 때 사용할 템플릿 종류와 플레이스홀더 치환 규칙을 안내하는 문서.
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: reference
---

# HTML 스켈레톤 템플릿

`/ui` 명령은 UI유형에 따라 아래 템플릿을 복사한 뒤 플레이스홀더를 치환한다.

| 파일 | UI유형 |
|---|---|
| `base.html` | 헤더 + 공통 팝업 로드 + 업무규칙 모달이 포함된 최소 베이스 |
| `grid1.html` | 그리드 1개 |
| `grid2-tb.html` | 그리드 2개 (상하) |
| `grid2-lr.html` | 그리드 2개 (좌우) |
| `grid3-lrt.html` | 그리드 3개 (좌측 + 우측 상하) |
| `grid3-tlb.html` | 그리드 3개 (상단 + 하단 좌우) |

## 플레이스홀더

| 토큰 | 치환 대상 |
|---|---|
| `{{MENU_CODE}}`    | 메뉴코드 소문자 (예: `mdfg01`) |
| `{{MENU_CODE_UP}}` | 메뉴코드 대문자 (예: `MDFG01`) |
| `{{MENU_NAME}}`    | 메뉴명 (예: `사은품관리`) |
| `{{SEARCH_ROWS}}`  | 검색 영역 `<tr>...</tr>` (명세 기준) |
| `{{GRID_MAIN_TOOLBAR}}` / `{{GRID_MAIN_COLGROUP}}` / `{{GRID_MAIN_THEAD}}` | 메인 그리드 구성 |
| `{{GRID_D1_*}}`, `{{GRID_D2_*}}` | 디테일 그리드 구성 (해당 UI유형만) |
| `{{REG_POPUPS}}`   | 등록/수정·전용 팝업 HTML |
| `{{RULE_TABLE}}`   | 업무규칙 모달의 `<table>` 4행 (메뉴그룹명/메뉴그룹코드/메뉴명/메뉴코드/UI유형/목적) |
| `{{RULE_LIST}}`    | 업무규칙 모달의 `<ol>` 항목 (명세 원문 그대로) |
| `{{CUSTOM_CSS}}`   | 화면 고유 CSS (대부분 비워둔다) |
| `{{SCRIPT_BODY}}`  | 검색/렌더/CRUD 등 화면 고유 JS |

공통 CSS는 `../common/wms-ui.css`, 공통 JS는 `../common/wms-common.js` 로 자동 포함된다.
