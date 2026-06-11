---
title: SearchSection / ContentSection / ZCellBox 컴포넌트
description: 리스트 화면의 검색영역(SearchSection)과 콘텐츠영역(ContentSection), 입력 레이아웃(ZCellBox/ZCell) 사용법. FE 화면 개발 시 필수 참조.
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: instruction
domain: frontend
tags:
  - search-section
  - content-section
  - zcellbox
  - layout
related:
  - 10-src-pattern/40-frontend/30-component/02-zauigrid.md
  - 10-src-pattern/40-frontend/50-pattern/01-crud-list-page.md
---

# SearchSection / ContentSection

리스트 화면의 **두 축** — 상단 검색영역과 하단 컨텐츠영역. `components/comm/section/` 에 정의.

## 1. SearchSection

```vue
<SearchSection :title="$t('message.거래처')" code="MDCT01">
    <template #btn>
        <ZBtn skyblue @click.prevent="vfn_searchCt">{{ $t('message.검색') }}</ZBtn>
        <ZBtn gray @click="vfn_resetSeachCt" style="margin-left:10px;">{{ $t('message.초기화') }}</ZBtn>
        <div class="manual-btn">
            <button type="button" @click="gfn_openManual('MDCT01')">{{ $t('message.PC매뉴얼') }}</button>
        </div>
    </template>

    <ZCellBox @keyup.enter.exact="vfn_searchCt">
        <ZCell cols="5" :title="$t('message.사업장')">
            <ZSelect v-model="searchCtObj.bizSeq" :items="searchBizList" text="bizNm" val="bizSeq" />
        </ZCell>
        <!-- ... -->
    </ZCellBox>
</SearchSection>
```

### Props
| prop | 용도 |
| --- | --- |
| `title` | 섹션 제목 (보통 i18n 메시지) |
| `code` | 메뉴 코드. 접힘/펼침 상태 저장 키로 사용 |

### Slot
- `#btn` — 제목 옆 버튼/매뉴얼 링크 영역
- 기본 슬롯 — 검색조건 본문 (보통 `ZCellBox`)

## 2. ZCellBox / ZCell

검색영역·팝업 입력폼의 **그리드 레이아웃**.

```vue
<ZCellBox>
    <ZCell cols="5" :title="$t('message.거래처번호')">
        <ZText type="text" v-model="searchCtObj.contNo" />
    </ZCell>
    <ZCell cols="5" :title="$t('message.거래처명')">
        <ZText type="text" v-model="searchCtObj.contNm" />
    </ZCell>
    <ZCell cols="5" :title="$t('message.사용여부')">
        <ZCodeSelect commCd="USE_YN" v-model="searchCtObj.useYn" :optionNm="$t('message.전체')" />
    </ZCell>
</ZCellBox>
```

### ZCell props
| prop | 의미 |
| --- | --- |
| `cols` | 한 row 에 몇 개 배치할지 (5 = 1/5 너비) |
| `maxCols` | 여러 셀 차지 (예: 주소 `cols="1" maxCols="3"`) |
| `title` | 라벨 |
| `required` | 빨간 * 표시 (편집 팝업에서) |

### enter 검색
```vue
<ZCellBox @keyup.enter.exact="vfn_searchCt">
```
`.exact` 로 IME 한글 입력 중 엔터 오발사 방지.

## 3. ContentSection

```vue
<ContentSection style="margin-top: 7px">
    <div class="content-warpper">
        <div class="content-header">
            <div class="content-header-fncL" style="display:flex;align-items: center;">
                <ZBtnReg @click="vfn_openInsertPopup"></ZBtnReg>
                <ZBtnMod @click="vfn_openUpdatePopup"></ZBtnMod>
                <ZBtnDel @click="vfn_deleteCts"></ZBtnDel>
            </div>
            <div class="content-header-fncR">
                <ZBtnDoc>
                    <button type="button" class="excelDown-btn" @click="vfn_exportExcel">
                        {{ $t('message.엑셀다운로드') }}
                    </button>
                </ZBtnDoc>
            </div>
        </div>
        <div class="content-body">
            <ZAuiGrid ref="ctGrid" v-bind="ctGridProperties" v-on="ctGridEvent" />
        </div>
    </div>
</ContentSection>
```

### 레이아웃 클래스 (style 은 전역 scss)
- `.content-warpper` (오타 그대로 유지 — 기존 규약)
- `.content-header` — 툴바 라인
- `.content-header-fncL` — 좌측 (등록/수정/삭제 등 주요 액션)
- `.content-header-fncR` — 우측 (엑셀 다운/출력 등 보조 액션)
- `.content-body` — 그리드/컨텐츠 본체

## 4. 자주 하는 실수

| 실수 | 해결 |
| --- | --- |
| `SearchSection` 없이 `<div class="search">` 수제작 | SearchSection 사용 — 접힘/매뉴얼 버튼 통합 |
| `cols` 숫자를 틀려서 레이아웃 깨짐 | 한 줄에 배치할 총 개수로 통일 (대부분 3 또는 5) |
| `content-warpper` 오타 수정 | 수정 금지 (전역 CSS 선택자와 일치) |
