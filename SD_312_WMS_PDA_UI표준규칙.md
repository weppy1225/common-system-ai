# WMS PDA 표준 UI 규칙

> **참조 소스**  
> - `input/SD_312/매크로통상/` — 2024년 실제 운영 앱 스크린샷  
> - `input/SD_312/CLOUD_WMS/` — 2022~2023년 디자인 가이드  
> - `cloud-wms-fe/src/` — Vue 3 소스 (`components/bm/`, `assets/styles/mobile.scss`)  
>
> **작성일**: 2026-05-11  
> 두 버전의 공통 패턴 + Vue 소스 실측값을 통합하여 신규 프로젝트에 적용할 표준을 정의한다.

---

## 1. 컬러 팔레트

Vue 소스(`MzBtn.vue`, `mobile.scss`)에서 추출한 실제 사용 값 기준.

### 1-1. Primary / Brand

| 토큰 | HEX | 용도 |
|---|---|---|
| `--pda-primary` | `#00afec` | CTA 버튼, 활성 탭, 강조 텍스트, 토글 칩 선택 |
| `--pda-primary-dark` | `#0099cc` | Pressed 상태, 강조 구분선 |
| `--pda-skyblue` | `#86acea` | 보조 버튼(선택형, 테두리+텍스트) |
| `--pda-login-text` | `#00afec` | 로그인 환영 문구 강조 |

### 1-2. 버튼 & 액션

| 토큰 | HEX | 용도 |
|---|---|---|
| `--pda-btn-blue` | `#00afec` | 처리·등록·조회·완료 (primary action) |
| `--pda-btn-gray-bg` | `#e5ebee` | 닫기·취소·보조 버튼 배경 |
| `--pda-btn-gray-text` | `#5e7481` | 닫기·취소 텍스트 |
| `--pda-btn-red` | `#e65d6e` | 위험 액션 (강제취소 등) |
| `--pda-btn-green` | `#94c941` | 계속담기·완료 후 이어가기 |
| `--pda-btn-cancel` | `#eb757b` | 취소처리 반버튼 |
| `--pda-btn-delete-bg` | `#fff2f2` | 삭제 버튼 배경 |
| `--pda-btn-delete-border` | `#d47575` | 삭제 버튼 테두리·텍스트 |

### 1-3. 상태 코드 (STS)

`mobile.scss` `.tblListM-sign` 실측값.

| 코드 | 상태명 | HEX |
|---|---|---|
| STS-00 | 대기 | `#999999` |
| STS-11 | 예정 | `#999999` |
| STS-17 | 준비 | `#d99cff` |
| STS-33 | 지정 | `#ffc0cb` |
| STS-55 | 처리중 | `#9ebf43` |
| STS-77 | 확정 | `#424242` |
| STS-78 | 강제확정 | `#6e6e6e` |
| STS-79 | 마감 | `#6694da` |
| STS-99 | 취소 | `#eb757b` |

### 1-4. 기타

| 토큰 | HEX | 용도 |
|---|---|---|
| `--pda-bg` | `#ffffff` | 전체 배경 |
| `--pda-surface` | `#f9f9f9` | 입력 필드·필터 배경 |
| `--pda-surface-light` | `#f5f7fa` | 토글 칩 미선택 배경 |
| `--pda-border` | `#dcd9d9` | 입력 필드 하단 구분선 |
| `--pda-border-card` | `#f5f5f5` | 카드 테두리 |
| `--pda-border-divider` | `#dfdfdf` | 탭바 상단, 섹션 구분선 |
| `--pda-overlay` | `rgba(0,0,0,0.6)` | 레이어 오버레이 |
| `--pda-text` | `#000000` / `#555555` | 본문 / 보조 텍스트 |
| `--pda-text-sub` | `#6e6e6e` | 날짜·코드 등 약한 텍스트 |
| `--pda-tag-bg` | `#e9e9e9` | 사업장·유형 태그 배경 |
| `--pda-tag-text` | `#555555` | 태그 텍스트 |
| `--pda-toggle-active` | `#c7d300` | 상태 토글 버튼 선택 (일부 화면) |

---

## 2. 타이포그래피

| 역할 | 크기 | 굵기 | 색상 | 소스 |
|---|---|---|---|---|
| 헤더 화면명 | `1.1rem` | bold | `#000` | `mobile-header-logo` |
| 필터 섹션 레이블 | `18px` | 600 | `#000` | `.layer-schInp p` |
| 카드 1행 (번호·날짜) | `20px` | 400 | `#555` | `info-row-type01` |
| 카드 2행 (거래처·품목명) | `19px` | bold | `#000` | `info-row-type02` |
| 카드 하단 강조 텍스트 | `16px` | bold | `#000` | `listM-info-bot` |
| 카드 태그 (사업장·유형) | `12~14px` | 400 | `#555` | `listM-tag` |
| 수량 숫자 (처리 카드) | `1.8rem` | 400 | `#000` | `proc-qty-type01-cont` |
| 버튼 텍스트 | `14~16px` | 400~600 | 흰색/`#5e7481` | `MzBtn` |
| 탭바 레이블 | `10px` | 400 | `#3d3d3c` | `mobile-footer-container` |
| 처리 정보 레이블 | `0.9rem` | 400 | `#555` | `.proc-info` |

---

## 3. 전체 레이아웃

```
┌────────────────────────────────────────┐  ← Status Bar (시스템)
│  [←]         화면명          [액션아이콘] │  ← 헤더 47px
├────────────────────────────────────────┤
│                                        │
│           콘텐츠 영역                   │  ← flex: 1, overflow-y: auto
│        (스크롤 가능)                    │  scrollbar-width: none
│                                        │
├────────────────────────────────────────┤
│  [메뉴] [입고]  [메인]  [출고] [재고이동] │  ← 하단 탭바 ~60px
└────────────────────────────────────────┘
```

Vue 구현체: `MzContentSection` 컴포넌트 (`#search` / `#scroll` / `#footer` 슬롯)

```html
<MzContentSection>
  <template #search>    <!-- 검색바·탭 영역 (sticky) -->
  <template #scroll>    <!-- 스크롤 목록 영역 (flex: 1) -->
  <template #footer>    <!-- 하단 액션 버튼 (fixed) -->
</MzContentSection>
```

---

## 4. 상단 헤더

| 속성 | 값 | 소스 |
|---|---|---|
| 높이 | `47px` | `mobile-header-container` |
| 배경 | `#ffffff` | 기본 |
| 환경별 배경 | test: `#ffc0cb` / dev: `#b2e0fc` | |
| 하단 여백 | `margin-bottom: 2px` | |
| 뒤로가기 영역 | `width: 15%` | `mobile-header-goBack` |
| 화면명 | `font-size: 1.1rem; font-weight: bold; justify-content: center` | `mobile-header-logo` |

- **목록 화면**: 뒤로가기 없음, 탭 네비게이션으로 이동
- **상세/처리 화면**: 좌측 `←` 뒤로가기
- **레이어/팝업**: 레이어 자체 헤더에 `✕` 닫기 버튼 포함

---

## 5. 하단 탭 네비게이션

| 속성 | 값 | 소스 |
|---|---|---|
| 배경 | `#ffffff` | |
| 상단 구분선 | `border-top: 1px solid #dfdfdf` | |
| 그림자 | `box-shadow: 0 -1px 10px 0 #00000029` | |
| 패딩 | `5px 0` | |
| 탭 텍스트 | `font-size: 10px; color: #3d3d3c` | |
| 탭 너비 | 균등: `width: 20%` | |
| 아이콘 크기 | 이미지 기반 SVG/PNG | |

**탭 구성 (5탭):**

| 순서 | 탭명 | 연결 도메인 |
|---|---|---|
| 1 | 메뉴 | 전체메뉴 (grid) |
| 2 | 입고 | `iv3000m` |
| 3 | 메인화면 | 대시보드 (중앙 강조) |
| 4 | 출고 | `ow5000m` |
| 5 | 재고이동 | `iv3200m` |

---

## 6. 검색 바

두 가지 형태로 사용된다.

### 6-1. 목록 화면 상단 검색바 (인라인)

```
┌───────────────────────────────────────────┐
│ 🔍  입고번호 스캔 및 입력          [▦] [≡] │
└───────────────────────────────────────────┘
```

```scss
.searchM-rowCont {
  width: 100%;
  height: 2.5em;
  position: relative;

  .inpM-form {
    width: 84%;
    height: 37px;
    border-radius: 10px;
    border: 1px solid #eee;
    padding: 0 0 0 15%;
    background-color: #f9f9f9;
  }
  .inp-sch    { position: absolute; top: 6px; left: 8px; }
  .inp-reset  { position: absolute; top: 6px; right: 6px; }
}
```

- 좌측 아이콘: `icon-search.png` (26×26)
- 우측 아이콘: 입력값 없음 → `icon-schBarcode.png`, 있음 → `icon-reset.png`
- 바코드 스캔: 아이콘 탭 시 카메라 스캐너 오픈
- placeholder: 검색 대상 명시 (예: `입고번호 스캔 및 입력`)

### 6-2. 필터 레이어 내 검색 입력

```scss
.layer-schInp .inpM-form {
  width: 94%;
  height: 37px;
  border-radius: 10px;
  border: 1px solid #dcd9d9;
  padding: 0 0 0 5%;
  background-color: #f9f9f9;
  color: #999;
}
```

---

## 7. 목록 카드 (tblListM)

`mobile.scss` `.tblListM-wrap` / `.tblListM-row` 실측 구조.

### 7-1. 전체 구조

```
┌────────────────────────────────────────────┐
│  [STS]  [사업장태그]     문서번호     날짜  │
│         유형 텍스트                         │
│         거래처명 / 품목명 (bold)    3건 →   │
└────────────────────────────────────────────┘
```

```scss
.tblListM-wrap {
  padding: 5px 10px;
  display: inline-block;
  overflow-y: scroll;
  width: 100%;
}

.tblListM-row {
  width: 100%;
  margin-bottom: 0.7em;

  .tblListM-sign {
    width: 50px;
    flex: 0 0 auto;
    color: #fff;
    font-size: 14px;
    font-weight: 600;
    padding: 6% 0;
    border-top-left-radius: 12px;
    border-bottom-left-radius: 12px;
    /* 상태코드별 배경색 — 섹션 1-3 참조 */
  }

  .tblListM-info {
    flex: 1;
    background: #fff;
    border: 1px solid #f5f5f5;
    border-top-right-radius: 12px;
    border-bottom-right-radius: 12px;
    padding: 15px 10px;
    word-break: break-all;
  }
}
```

### 7-2. 카드 내부 행 구성

| 클래스 | 내용 | 스타일 |
|---|---|---|
| `info-row-type01` | 1행: 번호 + 날짜 | `font-size: 20px; color: #555` |
| `info-row-type02` | 2행: 거래처명 (좌80%) + 건수 (우20%) | `font-size: 19px; font-weight: bold` |
| `listM-info-head` | 상단: 태그 + 편집/삭제 버튼 | — |
| `listM-info-mid` | 중단: 유형(좌70%) + 부가정보(우30%) | `font-size: 13~14px` |
| `listM-info-bot` | 하단: 주요 텍스트 | `font-size: 16px; bold` |

### 7-3. 사업장·유형 태그 (listM-tag)

```scss
.listM-tag {
  font-size: 12~14px;
  border-radius: 8px;
  background-color: #e9e9e9;
  padding: 4px 9px 5px 8px;
  color: #555;
  float: left;
}
```

---

## 8. 필터 레이어 (layer-schInp)

목록 화면 우측 `≡` 버튼 탭 시 슬라이드업 레이어 또는 전체 팝업으로 표시.

```
┌──────────────────────────────────┐
│  입고 검색                    ✕  │
├──────────────────────────────────┤
│ 사업장 ▼            물류센터 ▼   │
│                                  │
│ 입고유형                         │
│ [전체] [국내입고] [수입입고] ...  │  ← 토글 칩
│                                  │
│ 요청일자                         │
│ 📅 2024-10-01  ~  📅 2024-10-31  │
│                           초기화↺│
├──────────────────────────────────┤
│       [닫기]        [검색]        │
└──────────────────────────────────┘
```

```scss
.layer-schInp {
  margin-bottom: 20px;

  p { /* 섹션 레이블 */
    font-size: 18px;
    color: #000;
    font-weight: 600;
    margin-bottom: 5px;
  }
}
```

### 8-1. 토글 칩 (layer-stsBtn02)

```scss
.layer-stsBtn02 button {
  min-width: 18%;
  height: 37px;
  background-color: #f5f7fa;  /* 미선택 */
  border: 0;
  border-radius: 10px;
  font-size: 14px;
  font-weight: 500;
  margin-right: 2.5%;
  margin-bottom: 5px;
}

.layer-stsBtn02 button.mchk {  /* 선택됨 */
  background-color: #fff;
  border: 1px solid #00afec;
  color: #00afec;
}
```

### 8-2. 날짜 입력 (mobile-dateForm)

```scss
.mobile-dateForm {
  width: 86%;
  height: 37px;
  border-radius: 10px;
  border: 1px solid #dcd9d9;
  background-color: #f9f9f9;
  font-size: 1.2rem;
  padding-left: 15px;
}
/* 아이콘: icon_Mcalendar.png (23×23), 우측 absolute */
/* ~ 구분자: .mobile-tilde { height: 37px; line-height: 37px; color: #999; } */
```

### 8-3. Select (드롭다운)

```scss
/* MzSelect */
.layer-select-one {
  width: 100%;
  height: 3em;
  border: 0;
  border-bottom: 1px solid #dcd9d9;
  font-size: 20px;
  color: #555;
  background: url('icon-select-mideum.png') no-repeat right 3% center;
  background-size: 30px;
  -webkit-appearance: none;
}
```

### 8-4. 초기화 버튼

```scss
/* MzBtn[reset] */
height: 28px;
padding: 5px 10px;
border-radius: 12px;
background-color: #e5ebee;
border: 1px solid #e5ebee;
color: #5e7481;
/* ::after로 icon-schReset.png (20×20) 표시 */
```

---

## 9. 버튼 (MzBtn)

`components/bm/mobile/MzBtn.vue` 실측값.

| 속성 | 기본값 |
|---|---|
| 높이 | `37px` |
| 모서리 | `border-radius: 10px` |
| 디스플레이 | `flex; align-items: center; justify-content: center` |

| 타입 attribute | 배경 | 테두리 | 텍스트 | 용도 |
|---|---|---|---|---|
| `blue` / `insert` / `update` / `proc` | `#00afec` | `#00afec` | `#fff` | 처리·등록·수정·조회 |
| `gray` | `#e5ebee` | `#e5ebee` | `#5e7481` | 닫기·취소 |
| `red` | `#e65d6e` | `#e65d6e` | `#fff` | 강제 취소·삭제 |
| `green` | `#94c941` | `#94c941` | `#fff` | 계속담기·후속처리 |
| `skyblue` | `#fff` | `#86acea` | `#86acea` | 선택형 보조 액션 |
| `reset` | `#e5ebee` | `#e5ebee` | `#5e7481` | 초기화 (28px, icon) |
| `delete` | `#fff2f2` | `#d47575` | `#d47575` | 삭제 (28px, icon) |

### 하단 CTA 버튼 패턴

```html
<!-- 단일 버튼 -->
<MzBtn blue class="w-100p">처리</MzBtn>

<!-- 2열 버튼 -->
<MzBtn gray style="width:49%">닫기</MzBtn>
<MzBtn blue style="width:49%; margin-left:2%">처리</MzBtn>
```

---

## 10. 숫자 키패드 (MzNumpad)

`components/bm/mobile/MzNumpad.vue` 실측값.

```
/* 전체화면 오버레이 */
.mz-numpad-frame {
  position: fixed; top: 0; left: 0;
  width: 100%; height: 100%;
  z-index: 999999;
  background-color: rgba(255,255,255,0.8);
  display: flex; align-items: center; justify-content: center;
}

/* 컨테이너 */
.mz-numpad-container {
  max-width: 300px;
  border: 1px solid #d1d1d1;
  padding: 10px;
  background: #fff;
}

/* 출력값 */
.mz-numpad-output {
  font-size: 28px;
  justify-content: right;
  min-height: 60px;
}

/* 숫자 버튼 */
.mz-numpad-number-warp {
  height: 40px;
  line-height: 40px;
  font-size: 18px;
  font-weight: bold;
  border: 1px solid #e3e3e3;
  border-radius: 12px;
  background: #fff;
  /* hover: background #f4f6f7 */
}

/* 0은 2칸: grid-area: 4 / 1 / 4 / 3 */
/* 삭제: icon-num-delete.png (29×17) */

/* 완료 버튼 */
.numpad-apply {
  background-color: #00afec;
  border: 1px solid #00afec;
  color: #fff;
  width: 49%;
  border-radius: 12px;
  padding: 12px 0;
}

/* 취소 버튼 */
.numpad-cancel {
  background-color: #e5ebee;
  border: 1px solid #e5ebee;
  color: #5e7481;
  width: 49%;
  border-radius: 12px;
  padding: 12px 0;
}
```

- **진동**: 버튼 탭 시 `navigator.vibrate(60)` 호출
- **소수점**: 미지원 (주석 처리됨)
- **천단위 콤마**: `FormatTool.comma()` 자동 적용

---

## 11. Input 컴포넌트 (MzInput)

`components/bm/mobile/MzInput.vue` 실측값.

```scss
.inpM-form {
  border-radius: 0;
  background-color: #fff;
  border: 0;
  border-bottom: 1px solid #dcd9d9;  /* 하단 라인만 */
  height: 32px;
  padding: 0 0 0 2%;
  width: 95%;
  color: #000;
  font-size: 1rem;
}
```

- **일반 텍스트 입력**: `MzInput`
- **숫자 입력 (키패드)**: `MzNumpad` 또는 `MzNumInput`
- **유효성 오류**: `border-bottom: 1px solid red !important`
- **숫자 타입**: `text-align: right`

---

## 12. 처리 레이어 팝업

하단에서 슬라이드업 방식으로 열리는 처리 레이어.

```scss
/* 오버레이 */
.layer-bg {
  background: #000;
  opacity: 0.6;
  position: fixed;
  z-index: 4;
}

/* 레이어 컨테이너 */
.procQtyPopLayer-wrap {
  width: 89%;
  background: #fff;
  position: fixed;
  top: 7%;
  left: 0;
  padding: 20px;
  z-index: 5;
  border-top-left-radius: 15px;
  border-top-right-radius: 15px;
  height: 87%;
}

/* 슬라이드업 애니메이션 */
.procQtyLayer-enter-active,
.procQtyLayer-leave-active {
  transition: transform 0.7s ease;
}
.procQtyLayer-enter-from,
.procQtyLayer-leave-to {
  transform: translateY(100vh);
}
```

### 처리 팝업 내부 구조

```
┌─────────────────────────────────┐
│  처리제목 (pop-tle)              │
├─────────────────────────────────┤  ← border-bottom: 3px solid #dfdfdf
│ 품목번호  │  01531               │
│ 품목명    │  르라보 상탈 50ml    │
├─────────────────────────────────┤
│ 위치명/바코드 검색  [▦]          │
├─────────────────────────────────┤
│ □ 전체선택          총처리 40/100│
│ ─────────────────────────────── │
│ □  [제 1창고]   [40] / 40        │
│ □  [제 2창고]   [ 0] / 80        │
└─────────────────────────────────┘
│      [닫기]         [처리]       │
└─────────────────────────────────┘
```

```scss
.proc-info { padding: 0.8em 0; font-size: 0.9rem; color: #555; }
.proc-info-title { width: 35%; }
.proc-info-cont  { width: 65%; }
```

---

## 13. 품목 처리 카드 (procListType)

`components/bm/templet/procListType01.vue` 기반.

```
┌───────────────────────────────────────────┐
│ □  1000531   투게더2              [위치]   │
│ ─────────────────────────────────────────  │
│      50              50             100    │
│   기처리수량 🕐     처리수량 ⋯     요청수량  │
└───────────────────────────────────────────┘
```

```scss
.proc-qty-type01-cont {
  font-size: 1.8rem;
}
```

- **기처리수량** 우측: `icon-history.png` (이력 확인)
- **처리수량** 우측: `icon-mobile-more.png` → 처리수량 입력 레이어 오픈
- 3열 수량: `display: flex; justify-content: space-around`

---

## 14. 탭 화면 (MobileTabSection)

화면 내 탭 전환 (`품목` / `위치` 등).

| 속성 | 값 |
|---|---|
| 구현 컴포넌트 | `MobileTabSection` |
| 활성 탭 | 하단 `2px solid #00afec` 밑줄 |
| 비활성 탭 | 밑줄 없음, 회색 텍스트 |
| 탭 너비 | `flex: 1` 균등 |
| URL 연동 | `router.replace({ hash: #tabName })` |

```javascript
const tabList = [
  { tab: 'prodMvTab', tabName: '품목' },
  { tab: 'locMvTab',  tabName: '위치' },
];
```

---

## 15. 스크롤 레이어 검색 (MzScrollSearch / MzLocSearch / MzProdSearch)

목록에서 항목 선택 시 아래에서 올라오는 전체 팝업.

| 컴포넌트 | 용도 |
|---|---|
| `MzLocSearch` | 위치(창고·랙·단·열) 검색·선택 |
| `MzProdSearch` | 품목 검색·선택 |
| `MzScrollSearch` | 일반 스크롤 검색 |

---

## 16. Vue 모바일 컴포넌트 목록

`components/bm/mobile/mobile.js` export 기준.

| 컴포넌트 | 설명 |
|---|---|
| `MzBtn` | 버튼 (blue/gray/red/green/skyblue/delete/reset) |
| `MzInput` | 텍스트 입력 (하단 라인 스타일) |
| `MzNumInput` | 숫자 입력 (키패드 내장) |
| `MzNumpad` | 숫자 전용 키패드 오버레이 |
| `MzSelect` | 셀렉트박스 (커스텀 화살표 아이콘) |
| `MzCodeSelect` | 공통코드 기반 셀렉트박스 |
| `MzCodeMulti` | 공통코드 다중선택 |
| `MzCodeRadio` | 공통코드 라디오 |
| `MzCodeYnRadio` | Y/N 공통코드 라디오 |
| `MzRadio` | 일반 라디오 |
| `MzYnRadio` | Y/N 라디오 |
| `MzCheckbox` | 체크박스 |
| `MzCalendar` | 날짜 선택 (VueDatePicker 래퍼) |
| `MzCalendarRange` | 날짜 범위 선택 |
| `MzSearch` | 검색 입력 (돋보기·바코드·리셋 아이콘 내장) |
| `MzScrollSearch` | 스크롤 목록 검색 |
| `MzLocSearch` | 위치 검색 팝업 |
| `MzProdSearch` | 품목 검색 팝업 |
| `MzAddBtn` | 추가 버튼 (FAB 유사) |
| `MzScrollToTop` | 상단 이동 버튼 |
| `MzMulti` | 다중선택 |

---

## 17. 레이아웃 컴포넌트

| 컴포넌트 | 설명 |
|---|---|
| `MzContentSection` | 전체 화면 틀 (`#search`·`#scroll`·`#footer` 슬롯) |
| `MobileTabSection` | 화면 내 탭 전환 |
| `MzContLayer` | 콘텐츠 레이어 (슬라이드업, 오버레이 포함) |
| `MzContLayerCont` | 레이어 내부 콘텐츠 |
| `MzProdLayer` | 품목 선택 레이어 |
| `MzProdLayerCont` | 품목 레이어 내부 |
| `MzLayer` | 기본 레이어 (상·하 버튼 슬롯 포함) |

---

## 18. 라우터 모듈 (bm)

`router/modules/bm/` 기준 도메인별 모바일 라우터.

| 파일 | 도메인 | 주요 화면 |
|---|---|---|
| `iv3000m.js` | 입고 관리 | 입고처리(`ivmv01m`), 이동요청(`ivmvrq01m`), 적하(`ivad01m`) |
| `iv3100m.js` | 입고 통제 | — |
| `iv3200m.js` | 재고 관리 | 재고이동(`strg01m`), 재고스캔(`stsc01m`) |
| `iw1000m.js` | 라벨 | 라벨인쇄처리(`iwpc01m`), 라벨요청(`iwrq01m`) |
| `ow5000m.js` | 출고 관리 | 출고처리(`owpc01m`), 배송완료(`dlpc01m`), 적재(`ldpc01m`), 배송요청(`obrq01m`) |
| `rt2000m.js` | 반품 | 반품처리(`rtpc01m`), 반품요청(`rtrq01m`) |
| `md8000m.js` | 기준정보 | 창고(`mdwh01m`), 위치(`mdlc01m`), 품목(`mdpd01m`), 사용자(`mdus01m`) |

---

## 19. 화면 유형 분류

신규 화면 설계 시 아래 유형 중 선택하여 `MzContentSection` 슬롯에 맞게 구현.

| 유형 | 구조 | 대표 화면 | 컴포넌트 패턴 |
|---|---|---|---|
| **A. 목록형** | 검색바 + 카드 리스트 | 입고목록, 출고목록, 반품예정 | `#search`: MzSearch / `#scroll`: tblListM |
| **B. 처리형** | 요약헤더 + 검색바 + 처리카드 | 입고처리, 출고처리 | `#scroll`: procListType / `#footer`: MzBtn[blue] |
| **C. 탭형** | MobileTabSection + 검색바 + 결과 | 재고이동, 재고조회 | `#search`: MobileTabSection / `#scroll`: 탭별 component |
| **D. 스캔형** | 바코드 검색바 + 결과 영역 | 파렛트 병합·분할 | `#search`: MzSearch(barcode only) |
| **E. 조회결과형** | 정보섹션 + 구분된 목록 | 재고조회 결과, 입고내역 | `#scroll`: proc-info + tblListM-type02 |
| **F. 설정형** | 드롭다운 + 검색버튼 | 재고실사일정, 설정 | `#scroll`: MzSelect + MzBtn[blue][w-100p] |

---

## 20. 공통 상호작용 규칙

| 패턴 | 구현 방식 |
|---|---|
| **바코드 스캔** | `gfn_getOnLoadBarcodeHandler()` → `addOnLoadBarcode(callback)` 등록 |
| **수량 입력** | `MzNumpad` 또는 `MzNumInput` — 시스템 소프트 키보드 사용 금지 (`inputmode="none"`) |
| **레이어 오픈** | 슬라이드업 + 오버레이 (`transform: translateY(100vh)` → 0, duration 0.7s) |
| **초기화** | `icon-schReset.png` 아이콘 버튼, `MzBtn[reset]` |
| **진동 피드백** | 키패드 탭 시 `navigator.vibrate(60)` |
| **빈 상태** | 결과 없음 시 안내 문구 표시 |
| **로딩** | `Suspense` + fallback 컴포넌트 (`MzSelect[loading]`) |

---

## 21. 접근성 & 환경 고려사항

- 최소 터치 영역: **44px × 44px** (창고 환경, 장갑 착용)
- 최소 글자 크기: **12px** (야외·저조도 환경)
- 색상 단독으로 상태 구분 금지 → 텍스트 병용 (STS 텍스트 + 컬러)
- 세로 모드 고정 (가로 모드 미지원)
- 스크롤바 숨김: `scrollbar-width: none` (모바일 UX)
- 다국어: `vue-i18n` (`$t('message.키')`) 적용 — 한국어 기준 설계
