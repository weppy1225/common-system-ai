---
description: 검색 결과 데이터 그리드(Data Grid) 영역 HTML 작성 시 적용. 헤더·셀·컬럼 너비·페이징·다중 패널 높이 제어의 금지/필수 기준. 컬럼 너비 기준표·CSS 상세는 patterns/10-screen-design/10-web/04-result-grid.md.
paths:
  - "**/*.html"
---

# 결과 그리드 영역 규칙 (얇은 rule)

> 판단 기준(금지/필수)만 둔다. **컬럼 너비 기준표 전체·CSS 상세는 SSoT 문서를 연다 → `patterns/10-screen-design/10-web/04-result-grid.md`.**

## 핵심 판단 기준 (금지/필수)

- 첫 컬럼은 항상 **No.**, 체크박스가 있으면 No. 다음에 둔다.
- 헤더는 `position: sticky`로 고정한다. 그리드/툴바에 제목 텍스트(예: "프로모션 목록")를 표시하지 **않는다**.
- **컬럼 너비 — BLOCKING**: `white-space: nowrap`인 헤더 텍스트가 잘리는 너비를 절대 쓰지 **않는다**. 컬럼명별 최소 보장 너비 기준표(→ SSoT 문서)에 따라 `<col>` 너비를 정하고, 좁으면 컬럼을 숨기지 말고 가로 스크롤을 허용한다.
- 컬럼을 숨기지 **않는다**. 그리드 테이블은 `width: max-content; min-width: 100%`.
- 그리드 td의 input/select 스타일은 체크박스를 반드시 제외한다: `input:not([type="checkbox"])`.
- 페이징(페이지 번호·크기 셀렉터 50/100/200·건수)을 하단에 둔다.
- **다중 패널 높이 제어(필수)**: 모든 `.panel`과 중간 flex 래퍼에 `overflow: hidden` + `min-height: 0`을 둔다(높이 체인 전체). 고정 높이 자식(툴바·footer·h-scroll)에 `flex-shrink: 0`.

## 상세 패턴 (SSoT)

- 결과 그리드 구현 전체·컬럼 너비 기준표: → `patterns/10-screen-design/10-web/04-result-grid.md`
- 영역별 인덱스: → `patterns/10-screen-design/10-web/00-overview.md`
