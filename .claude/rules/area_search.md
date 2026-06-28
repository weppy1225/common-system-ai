---
description: 화면 상단 검색 조건 입력 영역(search-area)을 포함한 HTML 작성 시 적용. 레이아웃·레이블·입력 컴포넌트·헤더 버튼 배치의 금지/필수 기준. 상세 구현은 patterns/10-screen-design/10-web/02-search-area.md.
paths:
  - "**/*.html"
---

# 검색 필터 영역 규칙 (얇은 rule)

> 판단 기준(금지/필수)만 둔다. **상세 구현(레이아웃·CSS 값·헤더 버튼 스타일)은 SSoT 문서를 연다 → `patterns/10-screen-design/10-web/02-search-area.md`.**

## 핵심 판단 기준 (금지/필수)

- 한 행 최대 **5컬럼**, 레이블+입력창을 한 세트로 반복 배치한다.
- 검색 항목은 명세 순번 단위 그대로 **1항목 = 1레이블 + 1입력 셀**로 둔다. 임의로 합치거나(`colspan`) 숨기지(`display:none`) **않는다**.
- 빈 셀은 레이블 위치 `#f3f4f6`, 입력 위치 `#ffffff`로 구분해 채워 시각 구조를 유지한다.
- 검색 Select에 "전체" 옵션을 임의로 추가하지 **않는다**(명세 옵션만).
- 검색 테이블에 `table-layout: fixed`를 적용해 입력 컬럼 너비를 균등 강제한다.
- 헤더 하단 구분선(border-bottom)을 사용하지 **않는다**. 업무규칙 버튼은 헤더 우측(`margin-left: auto`).

## 상세 패턴 (SSoT)

- 검색 영역 구현 전체: → `patterns/10-screen-design/10-web/02-search-area.md`
- 영역별 인덱스: → `patterns/10-screen-design/10-web/00-overview.md`
