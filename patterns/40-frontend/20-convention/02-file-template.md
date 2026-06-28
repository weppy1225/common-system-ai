---
title: FE 표준 .vue 파일 템플릿
description: 신규 CRUD 화면 개발 시 복사해서 시작하는 리스트 화면({메뉴코드}.vue)과 편집 팝업({메뉴코드}Edt.vue) 스켈레톤 템플릿.
status: active
version: 1.0.0
repo_role: ai-hub
agent_usage: instruction
domain: frontend
tags:
  - template
  - vue-sfc
  - crud
  - skeleton
depends_on:
  - patterns/40-frontend/20-convention/01-naming.md
  - patterns/40-frontend/30-component/01-search-section.md
  - patterns/40-frontend/30-component/02-zauigrid.md
---

# 표준 .vue 파일 템플릿

신규 CRUD 화면을 만들 때는 이 템플릿을 **복사해서 시작**한다. `mdct01.vue` 를 축약한 것이다.

## 1. 리스트 화면 `{메뉴코드}.vue`

```vue
<style scoped lang="scss"></style>

<template>
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
                <ZSelect v-model="searchCtObj.bizSeq" :items="searchBizList" text="bizNm" val="bizSeq"></ZSelect>
            </ZCell>
            <!-- ...추가 검색조건 -->
        </ZCellBox>
    </SearchSection>

    <ContentSection style="margin-top: 7px">
        <div class="content-warpper">
            <div class="content-header">
                <div class="content-header-fncL" style="display:flex;align-items: center;">
                    <ZBtnMod @click="vfn_openUpdatePopup"></ZBtnMod>
                </div>
                <div class="content-header-fncR">
                    <ZBtnDoc>
                        <button type="button" class="excelDown-btn" @click="vfn_exportExcel">{{ $t('message.엑셀다운로드') }}</button>
                    </ZBtnDoc>
                </div>
            </div>
            <div class="content-body">
                <ZAuiGrid ref="ctGrid" v-bind="ctGridProperties" v-on="ctGridEvent"></ZAuiGrid>
            </div>
        </div>
    </ContentSection>

    <Mdct01Edt ref="editPopup" @vfn_searchCt="vfn_searchCt" :selectedBizSeq="searchCtObj.bizSeq"></Mdct01Edt>
</template>

<script setup>
import { ref, onActivated } from "vue";
import { useRoute } from "vue-router";

////////// 3rd
import axios from "axios";

////////// 컴포넌트
import { ZText, ZSelect, ZCodeMulti, ZCodeSelect } from '@/components/be/searchItem/schItems.js';
import { ZCell, ZCellBox } from '@/components/comm/section/section.js';
import { ZBtn, ZBtnMod, ZBtnDoc } from '@/components/be/btnFuc/btnFuc.js';
import ZAuiGrid from "@/components/be/grid/ZAuiGrid.vue";

////////// 팝업
import Mdct01Edt from './mdct01Edt.vue';

////////// store
import { sfn_useBizCenterStore } from "@/stores/bizCenterStore";
import { sfn_useCommCdStore } from "@/stores/commCdStore";

////////// gfn
import { gfn_getBizCenter, OptionTool, searchRef, gfn_openManual } from '@/assets/js/common.js';
import { zAuiGridReadonlyPros, gfn_exportTo } from '@/assets/zAuiGrid_common';

////////// 변수선언
const bizCenterStore = sfn_useBizCenterStore();
const commCdStore = sfn_useCommCdStore();
const editPopup = ref();
const route = useRoute();

////////// 검색영역 START
const searchOption = OptionTool.getSearchOption(route.meta.menuCd);

const initSearchCtObj = {
    bizSeq: searchOption.bizSeq,
    contNm: null,
    useYn: 'Y',
};
const searchCtObj = searchRef({ ...initSearchCtObj.deepCopy() });

onActivated(() => {
    const so = OptionTool.getSearchOption(route.meta.menuCd);
    if (so.bizSeq !== searchCtObj.value.bizSeq) {
        initSearchCtObj.bizSeq = so.bizSeq;
        vfn_resetSeachCt();
        ctGrid.value.grid.clearGridData();
    }
});

function vfn_resetSeachCt() {
    searchCtObj.value = { ...initSearchCtObj.deepCopy() };
}

const { bizList: searchBizList } = gfn_getBizCenter(searchCtObj);

async function vfn_searchCt() {
    try {
        const res = await axios.post(`/mdct01/conts`, searchCtObj.value);
        const postConts = res.data.postConts;

        const commCdList = [
            { commHCd: 'CONT_DIV_CD', commDCd: 'contDivCd', commDNm: 'contDivNm' },
            { commHCd: 'USE_YN',      commDCd: 'useYn',     commDNm: 'useYnNm'   },
        ];
        await Promise.all([
            commCdStore.convertCommDNms(commCdList, postConts),
            bizCenterStore.convertBizCenterNms(postConts),
        ]);

        ctGrid.value.grid.setGridData(postConts);
    } catch (error) {
        ctGrid.value.grid.clearGridData();
        errorSwal(error);
    }
}
////////// 검색영역 END

////////// 버튼영역 START
function vfn_openUpdatePopup() {
    const checkItems = ctGrid.value.grid.getCheckedRowItemsAll();
    if (checkItems.length === 0) { noSelectSwal(); return; }
    if (checkItems.length > 1)   { oneSelectSwal(); return; }

    const { bizSeq, contSeq } = checkItems[0];
    editPopup.value.openPopup(bizSeq, contSeq);
}

function vfn_exportExcel() {
    const excelOptions = { fileName: '거래처_' + new Date().yyyymmdd('-') };
    gfn_exportTo('xlsx', excelOptions, ctGrid.value.grid);
}
////////// 버튼영역 END

////////// 그리드 영역 START
const ctGrid = ref();

const ctGridProps = {
    ...zAuiGridReadonlyPros,
    enableFilter: true,
    showRowCheckColumn: true,
    softRemoveRowMode: false,
    showStateColumn: false,
};

const ctGridColumnLayout = [
    { dataField: 'bizNm',      headerText: '사업장',    width: '6%',  style: 'gridTxt-l', filter: { showIcon: true } },
    { dataField: 'contNo',     headerText: '거래처번호', width: '8%',  style: 'gridTxt-c' },
    { dataField: 'contNm',     headerText: '거래처명',   width: '15%', style: 'gridTxt-l' },
    { dataField: 'contDivNm',  headerText: '거래처구분', width: '8%',  style: 'gridTxt-c', filter: { showIcon: true } },
    { dataField: 'useYnNm',    headerText: '사용여부',   width: '6%',  style: 'gridTxt-c' },
];

const ctGridProperties = { gridProps: ctGridProps, columnLayout: ctGridColumnLayout, gridKey: '{메뉴코드}CtGrid' };
const ctGridEvent = {
    // cellClick, cellDoubleClick 등
};
////////// 그리드 영역 END
</script>
```

## 2. 편집 팝업 `{메뉴코드}Edt.vue`

```vue
<template>
    <LayerPopup ref="editPopup" :title="confirmTitle" :code="confirmCode" width="50" :closeCallback="vfn_resetPopup">
        <ZCellBox>
            <ZCell cols="3" :title="$t('message.사업장')">
                <ZSelect :items="editBizList" v-model="editCtObj.bizSeq" text="bizNm" val="bizSeq" :disabled="isUpdate"></ZSelect>
            </ZCell>
            <ZCell cols="3" :title="$t('message.거래처명')" required>
                <ZText type="text" v-model="editCtObj.contNm" :class="valid.contNm.class" />
            </ZCell>
            <!-- ... -->
        </ZCellBox>

        <div class="button-wrapper">
            <ZBtn skyblue @click="vfn_save">{{ $t('message.저장') }}</ZBtn>
            <ZBtn gray @click="vfn_close" style="margin-left:10px;">{{ $t('message.닫기') }}</ZBtn>
        </div>
    </LayerPopup>
</template>

<script setup>
import { ref, computed } from 'vue';
import axios from 'axios';
import LayerPopup from '@/components/be/popup/LayerPopup.vue';
// ...

const emit = defineEmits(['vfn_searchCt']);
const props = defineProps({ selectedBizSeq: Number });

const editPopup = ref();
const isUpdate = ref(false);
const confirmTitle = computed(() => isUpdate.value ? '거래처 수정' : '거래처 등록');
const confirmCode = 'MDCT01';

const initEditCtObj = { bizSeq: null, contNo: null, contNm: null, useYn: 'Y' };
const editCtObj = ref({ ...initEditCtObj });

async function openPopup(bizSeq, contSeq) {
    if (bizSeq && contSeq) {
        isUpdate.value = true;
        // 단건 조회: URL 은 `{리소스}Seq/{bizSeq}` 순, 응답은 `res.data.{resource}`
        const res = await axios.get(`/mdct01/conts/${contSeq}/${bizSeq}`);
        editCtObj.value = { ...initEditCtObj, ...res.data.cont };
    } else {
        isUpdate.value = false;
        editCtObj.value = { ...initEditCtObj, bizSeq: props.selectedBizSeq };
    }
    editPopup.value.openPopup();
}

function vfn_close() { editPopup.value.closePopup(); }
function vfn_resetPopup() { editCtObj.value = { ...initEditCtObj }; }

async function vfn_save() {
    // 1. valid 검사
    // 2. 등록=axios.put, 수정=axios.patch
    // 3. successSwal + emit('vfn_searchCt') + closePopup
}

defineExpose({ openPopup });
</script>
```

## 3. 작성 시 체크리스트

- [ ] `<style scoped lang="scss">` 를 **맨 위**에 둠
- [ ] import 블록을 `////////// 3rd / 컴포넌트 / 팝업 / store / gfn / 변수선언` 순으로 구분
- [ ] 섹션을 `////////// {영역명} START/END` 주석으로 감쌈
- [ ] 검색 초기값은 `initXxxObj` 상수로 분리
- [ ] 초기화는 `{ ...initXxxObj.deepCopy() }` 스프레드 (prototype 확장된 deepCopy 사용)
- [ ] 그리드 조회 실패 시 `clearGridData()` + `errorSwal(error)`
- [ ] 수정 팝업은 `체크 0건 → noSelectSwal`, `2건+ → oneSelectSwal`
- [ ] `onActivated` 에서 bizSeq 변경 감지
