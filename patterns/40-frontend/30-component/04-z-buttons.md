---
title: Z* 버튼 / 편집 팝업 규약
description: ZBtn/ZBtnReg/ZBtnMod/ZBtnDel 등 버튼 컴포넌트 사용법과 LayerPopup 기반 편집 팝업 구현 패턴(openPopup 시그니처, emit, 리셋). FE 버튼 및 팝업 개발 시 필수 참조.
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: instruction
domain: frontend
tags:
  - zbtn
  - layerpopup
  - edit-popup
  - emit
  - vuelidate
related:
  - patterns/40-frontend/30-component/05-z-popups.md
  - patterns/40-frontend/50-pattern/01-crud-list-page.md
---

# Z* 버튼 / 편집 팝업 규약

`components/be/btnFuc/btnFuc.js` 에서 일괄 import.

```js
import { ZBtn, ZBtnReg, ZBtnMod, ZBtnDel, ZBtnDoc, ZBtnCopy, ZBtnProc, ZBtnJob, ZBtnRowAdd, ZBtnRowDel, ZBtnRowSave, ZBtnRowCopy } from '@/components/be/btnFuc/btnFuc.js';
```

## 1. ZBtn — 범용 버튼

```vue
<ZBtn skyblue @click="vfn_searchCt">{{ $t('message.검색') }}</ZBtn>
<ZBtn gray    @click="vfn_reset">{{ $t('message.초기화') }}</ZBtn>
<ZBtn red     @click="vfn_cancel">{{ $t('message.취소') }}</ZBtn>
```

컬러 prop (boolean) — `ZBtn.vue` 정의 기준:
- `skyblue` — 주 액션 (검색/저장)
- `gray` — 보조 (초기화/닫기)
- `red` — 위험 (삭제/취소)
- `blue` — 강조 액션
- `rainbow` — 특수 강조

## 2. 의미 버튼 (아이콘+텍스트 미리 지정)

```vue
<ZBtnReg @click="vfn_openInsertPopup" />      <!-- 등록 -->
<ZBtnMod @click="vfn_openUpdatePopup" />      <!-- 수정 -->
<ZBtnDel @click="vfn_deleteItems" :checkAuthS="true" />   <!-- 삭제 (권한 체크) -->
<ZBtnProc @click="vfn_process" />             <!-- 처리 -->
<ZBtnJob  @click="vfn_job" />               <!-- 작업 -->
<ZBtnDoc>                                     <!-- 문서/엑셀 드롭다운 컨테이너 -->
    <button class="excelDown-btn" @click="vfn_exportExcel">엑셀다운로드</button>
</ZBtnDoc>
```

- 아이콘·라벨·권한체크 내장 → **수동 조합 금지**, 이 컴포넌트 그대로 사용
- `checkAuthS` 등 권한 prop 은 login 권한에 따라 자동 disable

---

# 편집 팝업 규약 (`{메뉴코드}Edt.vue`)

## 3. LayerPopup 기본 구조

```vue
<template>
    <LayerPopup
        ref="editPopup"
        :title="confirmTitle"
        :code="confirmCode"
        width="50"
        :closeCallback="vfn_resetPopup"
    >
        <ZCellBox>
            <!-- 입력 필드들 -->
        </ZCellBox>

        <div class="button-wrapper">
            <ZBtn skyblue @click="vfn_save">{{ $t('message.저장') }}</ZBtn>
            <ZBtn gray    @click="vfn_close" style="margin-left:10px;">{{ $t('message.닫기') }}</ZBtn>
        </div>
    </LayerPopup>
</template>
```

## 4. openPopup(bizSeq, seq) 시그니처 — **프로젝트 표준**

```js
async function openPopup(bizSeq, contSeq) {
    if (bizSeq && contSeq) {
        // 수정 모드 — URL 은 `{리소스}Seq/{bizSeq}` 순, 응답은 `res.data.{resource}`
        isUpdate.value = true;
        const res = await axios.get(`/mdct01/conts/${contSeq}/${bizSeq}`);
        editCtObj.value = { ...initEditCtObj, ...res.data.cont };
    } else {
        // 등록 모드
        isUpdate.value = false;
        editCtObj.value = { ...initEditCtObj, bizSeq: props.selectedBizSeq };
    }
    editPopup.value.openPopup();   // LayerPopup expose: openPopup / closePopup
}

defineExpose({ openPopup });
```

- **인자가 있으면 수정, 없으면 등록** — 화면 공통 규약
- 수정 모드 진입 시 단건 GET 으로 최신 데이터 재조회 (캐시 의존 금지)
- 등록 모드는 부모의 `selectedBizSeq` 로 초기값 설정

## 5. emit 으로 부모 재조회

```js
const emit = defineEmits(['vfn_searchCt']);

async function vfn_save() {
    const ok = await v$.value.$validate();
    if (!ok) { requiredSwal(); return; }

    try {
        // 등록=PUT, 수정=PATCH (FE 표준)
        const res = isUpdate.value
            ? await axios.patch(`/mdct01/conts`, editCtObj.value)
            : await axios.put(`/mdct01/conts`, editCtObj.value);

        successSwal(res.data);
        emit('vfn_searchCt');         // 부모 재조회
        editPopup.value.closePopup();
    } catch (error) {
        errorSwal(error);
    }
}
```

emit 이름 = **부모의 검색함수명** → 부모에서 `@vfn_searchCt="vfn_searchCt"` 그대로 매핑.

## 6. 닫기 / 리셋

```js
function vfn_close()      { editPopup.value.closePopup(); }
function vfn_resetPopup() { editCtObj.value = { ...initEditCtObj }; }
```

- `closeCallback` 에 `vfn_resetPopup` 를 연결 → 닫힐 때 자동 초기화
- 리셋은 반드시 **초기 객체 새 인스턴스** 로 (참조 공유 금지)

## 7. 체크리스트

- [ ] `defineExpose({ openPopup })` 로 부모에서 호출 가능하게
- [ ] `openPopup(bizSeq, seq)` 시그니처 준수
- [ ] 수정 모드 식별용 `isUpdate` ref 존재
- [ ] `required` 필드는 Vuelidate + `valid.xxx.class` 바인딩
- [ ] 저장 성공 → `successSwal` → `emit` → `close` 순
- [ ] `closeCallback` 으로 자동 리셋

---

## 그리드 행 조작 버튼 (ZBtnRow*)

인라인 편집 그리드의 툴바에서 행 추가/삭제/복사/저장에 사용하는 아이콘 버튼.

```js
import { ZBtnRowAdd, ZBtnRowDel, ZBtnRowCopy, ZBtnRowSave }
    from '@/components/be/btnFuc/btnFuc.js'
```

```vue
<div class="toolbar">
  <ZBtnRowAdd  :checkAuthS="authS" @click="vfn_addRow" />
  <ZBtnRowDel  :checkAuthS="authS" @click="vfn_delRow" />
  <ZBtnRowCopy :checkAuthS="authS" @click="vfn_copyRow" />
  <ZBtnRowSave :checkAuthS="authS" @click="vfn_saveRows" />
</div>
```

| 컴포넌트 | 아이콘 의미 | 사용 시점 |
|---|---|---|
| `ZBtnRowAdd` | 행 추가 | 그리드에 빈 행 삽입 |
| `ZBtnRowDel` | 행 삭제 | 체크된 행 그리드에서 제거 |
| `ZBtnRowCopy` | 행 복사 | 선택 행 복제 후 추가 |
| `ZBtnRowSave` | 저장 | 변경된 행 일괄 저장 |

모든 `ZBtnRow*` 는 `checkAuthS` prop으로 권한 제어.

---

## ZBtnCopy — 복사 버튼

단건 데이터를 복사해 신규 등록 화면을 여는 용도.

```vue
<ZBtnCopy :checkAuthS="authS" @click="vfn_copyItem" />
```

---

## ZBtnJob — Job 즉시 실행 버튼

Quartz 스케줄러 Job을 즉시 실행하는 버튼. 배치 수동 트리거 용도.

```vue
<ZBtnJob
  :jobClsNm="'be.sm9000.scrg01.job.DataSyncJob'"
  :dataMap="{ bizSeq: bizSeq }"
  :callback="vfn_jobCallback"
  title="데이터동기화"
/>
```

| prop | 타입 | 설명 |
|---|---|---|
| `jobClsNm` | String | 실행할 Job 클래스 풀 경로 (필수) |
| `dataMap` | Object | Job에 전달할 파라미터 |
| `callback` | Function | 실행 완료 후 콜백 |
| `title` | String | 버튼 표시명 (기본: 'Job버튼') |
| `hideButton` | Boolean | 버튼 숨김 여부 |

- 내부적으로 `/scrg01/schedulers/job/exec` POST 호출
- Job은 내일 같은 시각으로 Quartz Cron 예약 후 즉시 트리거
