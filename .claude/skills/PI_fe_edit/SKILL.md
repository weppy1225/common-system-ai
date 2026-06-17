---
name: PI_fe_edit
description: FE 팝업 컴포넌트({메뉴코드}Edt.vue 기본, `Sch`/`Set`/업무별 팝업 변형 포함)만 생성. /PI_fe_edit {메뉴코드}
when_to_use: "FE 팝업 만들어줘", "등록 팝업 개발해줘", "수정 팝업 만들어줘", "Edt.vue 만들어줘" 요청 시 사용.
argument-hint: "[메뉴코드]"
user-invocable: true
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
model: claude-sonnet-4-6
---

# FE 등록·수정 팝업 개발 [PI_fe_edit]

BE spec.md 기반으로 팝업 컴포넌트만 생성한다. 기본형은 `{메뉴코드}Edt.vue` 등록/수정 팝업이고, 실제 FE 표본처럼 `mdbz01Sch.vue`(검색), `mdbz01Set.vue`(설정), `Ivst01Proc`/`Ivst01Cancel`/`Ivst01ProcCancel`/`Ivst01ReqInvenMove` 같은 업무별 팝업 분리도 허용한다.

## 사용법

```
/PI_fe_edit {메뉴코드}
예: /PI_fe_edit mdct01
```

## 실행 절차

### STEP 1. 레포 경로 결정 (BLOCKING)

스킬은 AI 허브(`wms-{code}-ai`)에서 실행된다. `.claude/rules/repo-paths.md` 규칙으로 `$FE_DIR`(생성 대상 FE 레포)와 `$BE_DIR`(spec 읽기 대상 BE 레포)를 결정한다.
- FE 코드 생성: `$FE_DIR/src/views/...` — 작업 시작 시 **`cd "$FE_DIR"`** 하면 본문의 `src/views/...`·`ai-docs/...` 상대경로가 그대로 동작한다.
- BE spec 읽기: `$BE_DIR/DEV_DOC/ai-docs/20-backend/80-spec/{메뉴코드}/` (읽기 전용)

### STEP 2. BE spec 파일 확인

경로: `$BE_DIR/DEV_DOC/ai-docs/20-backend/80-spec/{메뉴코드}/`

우선순위:
1. `{YYYYMMDD}_output.md` (날짜 최신 파일)
2. `output.md`
3. `spec.md`

파일이 없으면 사용자에게 BE spec 파일 경로를 직접 묻는다.

### STEP 3. spec 파싱 (팝업에 필요한 항목만)

- 업무군 코드
- 리소스명 (camelCase)
- 단건 조회 API URL 및 응답 네이밍 (`res.data.{resource}`)
- 등록 API: `PUT` URL
- 수정 API: `PATCH` URL + 복합키 (`{resourceSeq}/{bizSeq}`)
- 팝업 폼 필드 목록 (타입, 필수 여부, 최대 길이)
- 사용 공통코드 (`commHCd` 목록)

### STEP 4. 팝업 컴포넌트 생성

기준 템플릿: `ai-docs/20-frontend/30-convention/10-vue-file-template.md` §2

**파일 위치:** `src/views/be/{업무군}/{메뉴코드}/{실제확인한팝업파일명}.vue`

**파일명 결정 규칙:**
- 기본형: `{메뉴코드}Edt.vue`
- 검색 팝업 분리형: `{메뉴코드}Sch.vue`
- 설정 팝업 분리형: `{메뉴코드}Set.vue`
- 다중 업무 팝업형: `Ivst01Proc.vue`, `Ivst01Cancel.vue`, `Ivst01ProcCancel.vue`, `Ivst01ReqInvenMove.vue`처럼 업무 단위 suffix 사용
- suffix는 추정하지 말고 `src/views/.../{메뉴코드}/`의 실제 FE 파일명과 기존 표본을 확인한 뒤 정한다

**구조:**

```vue
<style scoped lang='scss'>
.button-wrapper { display: flex; justify-content: center; }
</style>

<template>
  <LayerPopup ref="editPopup" :title="confirmTitle" code="{MENUCODE}P01" width="{X}" :closeCallback="vfn_resetPopup">
    <ZCellBox>
      <!-- 폼 필드 (spec 기준) -->
    </ZCellBox>
    <div class="button-wrapper">
      <ZBtn skyblue @click="vfn_save">{{ confirmBtnText }}</ZBtn>
      <ZBtn gray @click="vfn_close" style="margin-left:10px;">{{ $t('message.닫기') }}</ZBtn>
    </div>
  </LayerPopup>
</template>

<script setup>
// import 순서: 3rd > store > gfn > 컴포넌트 > 변수선언
</script>
```

**폼 필드 컴포넌트 매핑:**

| spec 타입 | 컴포넌트 |
|---|---|
| 사업장 | `ZSelect :items="editBizList" text="bizNm" val="bizSeq"` |
| 물류센터 | `ZSelect :items="editCenterList" text="centerNm" val="centerSeq"` |
| 공통코드 선택 | `ZCodeSelect commCd="XXX_CD" :bizSeq="editObj.bizSeq"` |
| 텍스트 입력 | `ZText v-model="..." maxLength="{n}"` |
| 날짜 | `ZCalendar v-model="..."` |
| 텍스트에어리어 | `ZTextArea v-model="..." height="60px"` |
| 거래처 팝업 | `ZContPopup v-model="..." :callback="lfn_editContCallback"` |
| 품목 팝업 | `ZProdPopup :callback="lfn_editProdCallback" v-model="..."` |

필수 필드에는 `:class="valid.fieldName.class"` + `required` props 추가.

**필수 코드 패턴:**

```js
// 등록/수정 모드 전환
const isUpdate = ref(false);
const confirmTitle = computed(() => isUpdate.value ? `${menunm} 수정` : `${menunm} 등록`);
const confirmBtnText = computed(() => isUpdate.value ? t('message.수정') : t('message.등록'));
// LayerPopup code는 모드와 무관하게 고정한다. 실제 표본: IVST01P01, MDBZ01P01

// 팝업 열기 (등록: seq 없음, 수정: seq 있음)
async function openPopup(bizSeq, resourceSeq) {
  if (bizSeq && resourceSeq) {
    isUpdate.value = true;
    // GET 단건 조회: URL은 {resourceSeq}/{bizSeq} 순
    const res = await axios.get(`/{메뉴코드}/{리소스}s/${resourceSeq}/${bizSeq}`);
    editObj.value = { ...initEditObj, ...res.data.{resource} };
  } else {
    isUpdate.value = false;
    editObj.value = { ...initEditObj, bizSeq: props.selectedBizSeq };
  }
  editPopup.value.openPopup();
}

// 저장
async function vfn_save() {
  // 1. 유효성 검증 (gfn_useValid 사용)
  const isValid = await validate();
  if (!isValid) return;

  try {
    let res;
    if (isUpdate.value) {
      // 수정: PATCH + 복합키 ({resourceSeq}/{bizSeq})
      res = await axios.patch(`/{메뉴코드}/{리소스}s/${editObj.value.{resourceSeq}}/${editObj.value.bizSeq}`, editObj.value);
    } else {
      // 등록: PUT
      res = await axios.put(`/{메뉴코드}/{리소스}s`, editObj.value);
    }
    successSwal(res.data);
    emit('vfn_search{Resource}');
    vfn_close();
  } catch (error) {
    errorSwal(error);
  }
}

// 팝업 닫기 / 리셋
function vfn_close() { editPopup.value.closePopup(); }
function vfn_resetPopup() { editObj.value = { ...initEditObj }; }

// 부모에서 openPopup 호출 가능하도록 노출
defineExpose({ openPopup });
```

- `LayerPopup code`는 등록/수정 모드에 따라 바꾸지 않는다
- 모드 분기는 `title`, 저장 버튼 텍스트, 내부 저장 로직(`PUT`/`PATCH`)으로 처리한다
- 실제 FE 표본 근거:
  - `ivst01Edt.vue` → `code="IVST01P01"` 고정, 제목/버튼만 `isUpdate`로 분기
  - `mdbz01Set.vue` → `code="MDBZ01P01"` 고정

**유효성 검증 패턴:**

```js
import { required, gfn_useValid } from '@/assets/plugin/vuelidate/zValid.js';

const validRules = {
  fieldName: { required },
  // spec 필수 필드 목록 기준
};
const { valid, validate } = gfn_useValid(editObj, validRules);
```

**팝업 너비 기준:**
- 폼 항목 1~2개: `width="40"`
- 폼 항목 3~6개: `width="50"`
- 폼 항목 7개 이상 또는 그리드 포함: `width="70"`

**코드 규칙:**
- `regBizSeq` URL 하드코딩 금지
- 수정 모드에서 PK 필드는 `:disabled="isUpdate"` 또는 `readonly`
- `closeCallback`에 `vfn_resetPopup` 연결
- `defineExpose({ openPopup })` 반드시 포함
- 영어 주석 금지 — 한글 유지
- `vfn_` 접두사: view 로컬 함수, `lfn_` 접두사: 모듈 내부 함수

### STEP 5. 완료 보고

```
생성 파일:
  src/views/be/{업무군}/{메뉴코드}/{실제확인한팝업파일명}.vue

API 연결:
  단건 조회: GET  /{메뉴코드}/{리소스}s/{resourceSeq}/{bizSeq}
  등록:      PUT  /{메뉴코드}/{리소스}s
  수정:      PATCH /{메뉴코드}/{리소스}s/{resourceSeq}/{bizSeq}

부모 화면에서 팝업 연결:
  <{메뉴코드}Edt ref="editPopup" @vfn_search{Resource}="vfn_search{Resource}" :selectedBizSeq="searchObj.bizSeq"/>
```

## 주의사항

- BE spec에 없는 정보는 `// TODO:` 주석으로 표시
- 복합키 순서: `{resourceSeq}/{bizSeq}` (절대 반대 금지)
- BE 저장소(`$BE_DIR`) 파일은 읽기만 함, 수정 금지
