---
description: 업무규칙 버튼 클릭 시 표시되는 모달 팝업 HTML 작성 시 적용. 화면구성 테이블·업무규칙 목록·드래그 이동의 금지/필수 기준. 상세 구현(HTML/CSS 패턴)은 patterns/10-screen-design/10-web/07-popup-biz-rule.md.
paths:
  - "**/*.html"
---

# 업무규칙 팝업 규칙 (얇은 rule)

> 판단 기준(금지/필수)만 둔다. **상세 구현(테이블 구조·HTML/CSS 참조)은 SSoT 문서를 연다 → `patterns/10-screen-design/10-web/07-popup-biz-rule.md`.**

## 핵심 판단 기준 (금지/필수)

- 구성: 헤더("업무규칙" 고정 텍스트) → 바디(화면구성 테이블 + 업무규칙 `<ol>` 목록) → 푸터("닫 기"). 헤더 드래그로 이동 가능.
- 화면구성 테이블은 **4행 고정**: 1행 메뉴그룹명/메뉴그룹코드, 2행 메뉴명/메뉴코드, 3행 UI유형(colspan), 4행 목적(colspan).
- 업무규칙 내용은 화면요건정리 md의 **"공통 업무규칙"** 섹션에서 그대로 옮긴다. 임의로 작성하지 **않는다**.

## 상세 패턴 (SSoT)

- 업무규칙 팝업 구현 전체(HTML/CSS): → `patterns/10-screen-design/10-web/07-popup-biz-rule.md`
- 영역별 인덱스: → `patterns/10-screen-design/10-web/00-overview.md`
