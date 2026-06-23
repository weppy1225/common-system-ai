---
description: 모든 와이어프레임 HTML에 예외 없이 적용되는 공통 규칙. 페이지 래퍼, 헤더, 모달, 그리드, 버튼, 공통 팝업(거래처/품목), 테스트 데이터를 다룬다. 상세 구현은 patterns/10-screen-design/10-web/01-common-ui.md.
paths:
  - "**/*.html"
---

# 공통 UI 규칙 (얇은 rule)

> 판단 기준(금지/필수)만 둔다. **상세 구현 패턴(CSS 값·HTML 템플릿·테스트 항목)은 SSoT 문서를 연다 → `patterns/10-screen-design/10-web/01-common-ui.md`.**

## 핵심 판단 기준 (금지/필수)

- 인라인 `style`로 `overflow`/`width`/`height` 등 레이아웃 스타일을 직접 지정하지 **않는다**. 모든 스타일은 CSS 클래스로 관리한다.
- 공통 컴포넌트의 HTML 구조·CSS 클래스명·이벤트 핸들러를 임의로 수정하지 **않는다**. 페이지별 콘텐츠는 반드시 `<main class="main-content">` 안에서만 작업한다.
- 원본에 없는 요소(버튼·텍스트·장식)를 추가하지 **않고**, 원본 요소를 누락하지 **않는다**. 색상·간격·px·레이아웃을 임의로 바꾸지 않는다.
- 입력 필드에 placeholder를 임의로 추가하지 **않는다**(명세 명시 시에만).
- 사용여부 컬럼에 색상 badge(초록/빨강)를 쓰지 **않고** "사용"/"미사용" 텍스트만 표시한다.
- 아이콘 버튼은 `prototype/{프로젝트}/_common/icon-preview.html`에 정의된 아이콘만 사용한다(없으면 텍스트 버튼).
- 기능 버튼을 빈 stub으로 남기지 **않는다** — 반드시 동작하도록 구현하고 확인한다.
- 거래처/품목 필드는 공통 팝업(CPCT01/CPPD01)을 연결하고 **`window.open()` 금지, `postMessage`** 방식만 사용한다(거래처·품목 동일).
- 테스트 데이터는 HTML에 하드코딩하지 **않고** 별도 JS 파일(`{메뉴코드}-data.js`)로 분리한다. 메인 그리드 10건↑, 디테일 5건↑.
- 업무규칙 팝업 화면구성 섹션에 메뉴그룹명·메뉴그룹코드·메뉴명·메뉴코드·UI유형·목적을 반드시 기입한다.

## 상세 패턴 (SSoT)

- 공통 UI 구현 전체: → `patterns/10-screen-design/10-web/01-common-ui.md`
- 영역별 인덱스: → `patterns/10-screen-design/10-web/00-overview.md`
