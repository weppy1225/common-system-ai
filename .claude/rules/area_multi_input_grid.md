---
description: 행(Row) 단위로 데이터를 직접 인라인 입력·관리하는 그리드 영역 HTML 작성 시 적용. 인라인 셀 입력·체크박스 다중 선택·계층 컬럼 배치의 금지/필수 기준. 상세 구현은 patterns/10-screen-design/10-web/05-multi-input-grid.md.
paths:
  - "**/*.html"
---

# 다중 입력 그리드 영역 규칙 (얇은 rule)

> 판단 기준(금지/필수)만 둔다. **상세 구현은 SSoT 문서를 연다 → `patterns/10-screen-design/10-web/05-multi-input-grid.md`.**

## 핵심 판단 기준 (금지/필수)

- 기본 컬럼 구성: No.(자동 순번) / 체크박스 / 데이터 컬럼들. 그리드/툴바에 제목 텍스트를 표시하지 **않는다**.
- 체크박스 다중 선택 후 툴바 버튼으로 일괄 작업한다. 체크박스 `12px × 12px`.
- 그리드 td의 input/select 스타일은 체크박스를 반드시 제외한다: `input:not([type="checkbox"])`.
- 아이콘을 사용하지 **않는다**. 확장/추가는 텍스트 버튼(+)으로, 구분은 텍스트·테두리만으로 표현한다.
- 계층 구조 데이터(랙/단/열 등)는 상위 → 하위 순으로 컬럼을 배치한다.

## 상세 패턴 (SSoT)

- 다중 입력 그리드 구현 전체: → `patterns/10-screen-design/10-web/05-multi-input-grid.md`
- 영역별 인덱스: → `patterns/10-screen-design/10-web/00-overview.md`
