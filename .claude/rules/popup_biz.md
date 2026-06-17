---
description: 업무규칙 버튼 클릭 시 표시되는 모달 팝업 HTML 작성 시 적용. 화면구성 테이블, 업무규칙 목록, 드래그 이동, CSS 패턴을 정의한다.
paths:
  - "**/*.html"
---

# 업무규칙 팝업 규칙

---

## 1. 전체 레이아웃

- 모달 팝업 형태로 화면 중앙에 표시한다.
- 구성: **헤더** → **바디(화면구성 테이블 + 업무규칙 목록)** → **푸터(닫기 버튼)**.
- 모달 너비: `width: 520px`, `max-height: 90vh`.
- 모달 컨테이너: `border: 1px solid #999; border-radius: 6px; box-shadow: 0 8px 32px rgba(0,0,0,0.25); background: #fff`.
- 오버레이(`.modal-bg`): `z-index: 1000`, 배경 `rgba(0,0,0,0.45)`.

---

## 2. 헤더

- 배경색 `#304a6e`, 텍스트 흰색, `font-size: 13px; font-weight: 600`.
- 패딩 `8px 14px`, `border-radius: 6px 6px 0 0`.
- 좌측에 **"업무규칙"** 텍스트를 표시한다 (메뉴명이 아닌 고정 텍스트).
- **헤더 영역을 드래그하면 팝업 전체가 이동한다.** `.modal`에 `position: absolute`, `.modal-header`에 `cursor: move; user-select: none`을 적용한다. 팝업이 열릴 때 화면 중앙에 자동 위치하고, 헤더를 마우스로 드래그하여 자유롭게 이동할 수 있다.
- 우측에 닫기 버튼 `✕` (`font-size: 20px; color: #fff`)을 배치한다.

---

## 3. 바디

- 패딩 `16px 18px`, `overflow-y: auto`.

### 3-1. 화면구성 섹션

- **"화면구성"** 소제목을 먼저 표시한다.
- 소제목 스타일: `font-size: 13px; font-weight: 700; color: #304a6e; margin-bottom: 6px`.
- 소제목 아래에 `<table>` 형태로 화면 정보를 표시한다.
- 테이블 구성 (4행 고정):

| 행 | th (좌) | td (좌) | th (우) | td (우) |
|---|---|---|---|---|
| 1행 | 메뉴그룹명 | {값} | 메뉴그룹코드 | {값} |
| 2행 | 메뉴명 | {값} | 메뉴코드 | {값} |
| 3행 | UI유형 | {값, colspan=3} | | |
| 4행 | 목적 | {값, colspan=3} | | |

- th 스타일: `background: #f3f4f6; text-align: left; padding: 6px 10px; border: 1px solid #e5e7eb; font-size: 12px; font-weight: 600; color: #374151; white-space: nowrap`.
- td 스타일: `padding: 6px 10px; border: 1px solid #e5e7eb; font-size: 12px; color: #111827`.
- 테이블 하단 여백: `margin-bottom: 12px`.

### 3-2. 업무규칙 섹션

- **"업무규칙"** 소제목을 표시한다 (화면구성과 동일 스타일).
- 소제목 아래에 `<ol>` (순서 있는 목록)로 규칙을 나열한다.
- 항목 스타일: `font-size: 12px; color: #374151; line-height: 1.6; margin-bottom: 6px`.
- 목록 패딩: `padding-left: 18px`.
- 업무규칙 내용은 화면요건정리 md 파일의 **"공통 업무규칙"** 섹션에서 가져온다.
- **업무규칙 내용을 임의로 작성하지 않는다.** 반드시 md 명세서의 규칙을 그대로 옮긴다.

---

## 4. 푸터

- `padding: 8px 12px`, `border-top: 1px solid #ddd`.
- **"닫 기"** 버튼 1개를 중앙 정렬한다.
- 버튼 스타일: `border: 1px solid #d1d5db; background: #fff; padding: 0 18px; height: 30px; font-size: 13px; border-radius: 4px; cursor: pointer`.

---

## 5. 참조 구조 (HTML 패턴)

```html
<div class="modal-bg" id="ruleModal">
  <div class="modal" style="width:520px">
    <div class="modal-header">
      <span>업무규칙</span>
      <button class="close-btn" onclick="closeRule()">✕</button>
    </div>
    <div class="modal-body">
      <p class="rule-title">화면구성</p>
      <table>
        <tr><th>메뉴그룹명</th><td>{값}</td><th>메뉴그룹코드</th><td>{값}</td></tr>
        <tr><th>메뉴명</th><td>{값}</td><th>메뉴코드</th><td>{값}</td></tr>
        <tr><th>UI유형</th><td colspan="3">{값}</td></tr>
        <tr><th>목적</th><td colspan="3">{값}</td></tr>
      </table>
      <p class="rule-title">업무규칙</p>
      <ol>
        <li>{규칙1}</li>
        <li>{규칙2}</li>
      </ol>
    </div>
    <div class="modal-footer">
      <button class="btn-modal-close" onclick="closeRule()">닫 기</button>
    </div>
  </div>
</div>
```

---

## 6. CSS 참조

```css
.rule-title {
  font-size: 13px;
  font-weight: 700;
  color: #304a6e;
  margin-bottom: 6px;
}
.modal-body table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 12px;
}
.modal-body table th {
  background: #f3f4f6;
  text-align: left;
  padding: 6px 10px;
  border: 1px solid #e5e7eb;
  font-size: 12px;
  font-weight: 600;
  color: #374151;
  white-space: nowrap;
}
.modal-body table td {
  padding: 6px 10px;
  border: 1px solid #e5e7eb;
  font-size: 12px;
  color: #111827;
}
.modal-body ol {
  padding-left: 18px;
}
.modal-body ol li {
  font-size: 12px;
  color: #374151;
  line-height: 1.6;
  margin-bottom: 6px;
}
.btn-modal-close {
  border: 1px solid #d1d5db;
  background: #fff;
  padding: 0 18px;
  height: 30px;
  font-size: 13px;
  font-weight: 500;
  border-radius: 4px;
  cursor: pointer;
  color: #374151;
}
.btn-modal-close:hover {
  border-color: #9ca3af;
  background: #f9fafb;
  color: #111827;
}
```
---

## 상세 패턴 문서

WEB 화면 영역별 패턴 인덱스 (팝업 영역 포함):
→ `patterns/10-screen-design/10-web/00-overview.md`
