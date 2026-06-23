---
description: 단건 데이터를 등록·수정하는 모달 팝업 HTML 작성 시 적용. 팝업 너비·헤더·폼 테이블·푸터·모드 전환·팝업코드 채번의 금지/필수 기준. 상세 구현은 patterns/10-screen-design/10-web/06-popup-register.md.
paths:
  - "**/*.html"
---

# 등록/수정 팝업 규칙 (얇은 rule)

> 판단 기준(금지/필수)만 둔다. **상세 구현(너비 기준·폼 테이블·CSS·참조 이미지)은 SSoT 문서를 연다 → `patterns/10-screen-design/10-web/06-popup-register.md`.**

## 핵심 판단 기준 (금지/필수)

- 구성: 헤더 → 폼 본문(테이블) → 푸터. 헤더는 드래그 이동 가능(`.modal` `position: absolute`, `.modal-header` `cursor: move`).
- **팝업 코드 자동 채번 필수**: `"{메뉴코드}P{순번2자리}"`(예: MDFG01P01). 명세에 없어도 채번해 "팝업명 [팝업코드]" 형식으로 표시한다. 코드 없이 팝업명만 표시하지 **않는다**.
- 폼은 `<table>` 기반, 한 행 최대 **3세트(레이블 th + 입력 td)**. 레이블(th) 너비는 가장 긴 레이블이 잘리지 않게 잡는다(부족 시 모달 너비 확장).
- 모달 바디는 `overflow-x: hidden`으로 가로 스크롤을 차단한다. 팝업 내 그리드 가로 넘침은 `.grid-wrap`에 `overflow-x: auto`를 **CSS 클래스로** 적용하고 인라인 `style`로 `overflow-x:hidden`을 걸지 **않는다**.
- 팝업 내 검색/초기화 버튼은 검색 테이블 아래 중앙에 둔다(좌측 상단 별도 배치 금지).
- 등록/수정은 동일 HTML 재사용 — 모드별 헤더 제목 변경, 수정 모드 PK는 `readonly`+회색.
- 거래처/품목 필드는 `readonly` + 공통 팝업(CPCT01/CPPD01) 연결(통신은 postMessage → `01-common-ui.md`).
- 팝업 내부에서 공통 클래스 사용 시 팝업 선택자 스코프(`#xxxModal .input-with-popup`)로 스타일을 별도 정의한다.

## 상세 패턴 (SSoT)

- 등록/수정 팝업 구현 전체: → `patterns/10-screen-design/10-web/06-popup-register.md`
- 영역별 인덱스: → `patterns/10-screen-design/10-web/00-overview.md`
