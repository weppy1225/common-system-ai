---
description: 그리드 상단 툴바 영역의 버튼 종류·배치 순서·스타일의 금지/필수 기준. CRUD 아이콘 버튼(btn-icon)·텍스트 버튼·엑셀 버튼을 다룬다. 상세 구현은 patterns/10-screen-design/10-web/03-toolbar-buttons.md.
paths:
  - "**/*.html"
---

# 기능 버튼 영역 (Toolbar) 규칙 (얇은 rule)

> 판단 기준(금지/필수)만 둔다. **상세 구현(버튼 크기·색상·툴바 CSS)은 SSoT 문서를 연다 → `patterns/10-screen-design/10-web/03-toolbar-buttons.md`.**

## 핵심 판단 기준 (금지/필수)

- CRUD 버튼(추가/수정/삭제/복사)은 텍스트 없이 SVG 아이콘 버튼(`btn-icon`)으로 둔다.
- 버튼 명칭·순서는 **추가 / 수정 / 삭제 / 복사 / 저장** 으로 고정하고 그리드 상단 **좌측**에 배치한다(저장도 우측 분리 금지).
- 버튼 배경은 흰색 기본, 별도 언급 없으면 색상을 넣지 **않는다**.
- 엑셀등록/엑셀다운로드 버튼은 별도 언급 없으면 추가하지 **않는다**. (엑셀 버튼만 아이콘+텍스트 조합)
- 좌측=데이터 변경/입력 액션, 우측=출력(엑셀다운로드) 액션으로 정렬을 분리한다.

## 상세 패턴 (SSoT)

- 툴바 버튼 구현 전체: → `patterns/10-screen-design/10-web/03-toolbar-buttons.md`
- 영역별 인덱스: → `patterns/10-screen-design/10-web/00-overview.md`
