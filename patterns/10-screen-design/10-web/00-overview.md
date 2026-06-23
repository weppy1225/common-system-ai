---
title: WEB 화면 설계 패턴
description: PC 웹 화면 설계 패턴. 검색영역·그리드·툴바·팝업의 레이아웃·CSS·동작 규칙 인덱스.
status: active
version: 1.1.0
repo_role: ai-hub
agent_usage: reference
domain: frontend
tags:
  - web
  - screen-design
  - ui-pattern
---

# WEB 화면 설계 패턴

## UI 유형 (화면 구성 패턴)

| 유형 | 설명 |
|---|---|
| 그리드 1개 | 검색조건 + 단일 그리드 |
| 그리드 2개 상하단 | 메인 그리드 + 하단 상세 그리드 |
| 그리드 2개 좌우측 | 좌측 분류 그리드 + 우측 상세 그리드 |
| 그리드 3개 (좌·우상·우하) | 좌측 분류 + 우측 상단/하단 |
| 그리드 3개 (상·하좌·하우) | 상단 메인 + 하단 좌/우 |

## 영역별 패턴 문서 (SSoT)

각 영역의 **상세 구현 패턴(CSS 값·HTML 템플릿·기준표)은 아래 leaf 패턴 문서가 SSoT**다. `.claude/rules/*`는 HTML 작업 시 자동 로드되는 **얇은 트리거**로, 금지/필수 판단 기준만 두고 이 패턴 문서로 라우팅한다(참조 방향: rule → pattern).

| 영역 | 패턴 문서 (SSoT) | 얇은 rule (트리거) | 핵심 규칙 요약 |
|---|---|---|---|
| 공통 UI | `01-common-ui.md` | `.claude/rules/common_ui.md` | 페이지 래퍼(`page-wrap`, `height: 100vh`, `overflow: hidden`), 헤더(`메뉴명[코드]`·검색·초기화·업무규칙), 모달 공통 구조, 공통 팝업, 테스트 데이터 |
| 검색 필터 | `02-search-area.md` | `.claude/rules/area_search.md` | 5컬럼 레이아웃, 레이블 80px 고정, 입력 높이 26px, 검색 테이블 `table-layout: fixed` |
| 기능 버튼 | `03-toolbar-buttons.md` | `.claude/rules/area_btn.md` | CRUD 아이콘 버튼(`btn-icon`), 추가/수정/삭제/복사 순서, 툴바 좌측 정렬 중심 |
| 결과 그리드 | `04-result-grid.md` | `.claude/rules/area_result_grid.md` | 헤더 `sticky`, 컬럼명 기준 최소 너비표, 페이징(50/100/200), 다중 패널 높이 제어 |
| 다중 입력 그리드 | `05-multi-input-grid.md` | `.claude/rules/area_multi_input_grid.md` | 인라인 셀 입력, 체크박스 12x12px, `input:not([type="checkbox"])`로 스타일 격리 |
| 등록/수정 팝업 | `06-popup-register.md` | `.claude/rules/popup_reg.md` | 드래그 가능 모달, table 기반 폼(행당 3세트), 팝업코드 자동 채번(`{메뉴코드}P{순번2자리}`) |
| 업무규칙 팝업 | `07-popup-biz-rule.md` | `.claude/rules/popup_biz.md` | 드래그 가능 모달, 화면구성 테이블 4행 고정, 업무규칙 `ol` 목록 |

> 패턴 문서 경로는 이 디렉토리(`patterns/10-screen-design/10-web/`) 기준이다.

## 프로토타입 생성 스킬

| 스킬 | 설명 |
|---|---|
| `/SD_310_UI {메뉴코드}` | 대화형 인터뷰로 `{메뉴코드}-02-ui.md` 작성 |
| `/SD_311 {메뉴코드}` | `ui.md` → `wireframe.html` + `mock-data.js` 생성 |

## 공통 CSS/JS 리소스

| 파일                                    | 역할               |
| ------------------------------------- | ---------------- |
| `prototype/{프로젝트}/_common/common.css`        | 공통 스타일시트         |
| `prototype/{프로젝트}/_common/common.js`     | 공통 스크립트          |
| `prototype/{프로젝트}/_common/CPCT01_popup.html` | 거래처 검색 공통 팝업     |
| `prototype/{프로젝트}/_common/CPPD01_popup.html` | 품목 검색 공통 팝업      |
| `prototype/{프로젝트}/_common/icon-preview.html` | 사용 가능 SVG 아이콘 목록 |
