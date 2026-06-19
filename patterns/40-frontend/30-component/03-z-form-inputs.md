---
title: 폼 입력 컴포넌트 (Z*)
description: ZText/ZSelect/ZCodeSelect/ZCodeMulti/ZRadio/ZCheckbox/ZCalendar/ZCalendarRange 컴포넌트 사용법과 Vuelidate 유효성 검사 패턴. FE 폼 입력 구현 시 필수 참조.
status: active
version: 1.0.0
wms_meta: true
repo_role: ai-hub
agent_usage: instruction
domain: frontend
tags:
  - ztext
  - zselect
  - zcodeselect
  - zcalendar
  - vuelidate
  - form-input
---

# 폼 입력 컴포넌트 (Z*)

주로 `components/be/searchItem/schItems.js` 에서 일괄 import.

```js
import {
    ZText, ZSelect, ZRadio, ZCheckbox, ZCalendar, ZCalendarRange,
    ZCodeSelect, ZCodeMulti, ZMulti,
} from '@/components/be/searchItem/schItems.js';
```

## 1. ZText — 텍스트/숫자 입력

```vue
<ZText type="text"   v-model="obj.contNm" />
<ZText type="number" v-model="obj.qty" />
<ZText type="text"   v-model="obj.addr" readonly :disabled="isUpdate" />
<ZText type="text"   v-model="obj.contNm" :class="valid.contNm.class" />
```

| prop | 설명 |
| --- | --- |
| `type` | text / number / password |
| `readonly` | 읽기전용 (값은 유지) |
| `disabled` | 비활성 |
| `class` | valid 실패 시 빨간 테두리 클래스 바인딩 |
| `maxlength` | 최대 글자 |

## 2. ZSelect — 일반 select

```vue
<ZSelect v-model="searchCtObj.bizSeq" :items="searchBizList" text="bizNm" val="bizSeq" />
```

| prop | 설명 |
| --- | --- |
| `items` | 배열 of object |
| `text` | 표시용 필드명 (예: `bizNm`) |
| `val` | 값으로 쓸 필드명 (예: `bizSeq`) |
| `optionNm` | 최상단 "전체/선택" 옵션 텍스트 (선택) |
| `disabled` | 비활성 |

## 3. ZCodeSelect / ZCodeMulti — 공통코드 select

내부에서 `commCdStore` 를 호출하므로 options 을 수동으로 넘길 필요 없음.

```vue
<ZCodeSelect commCd="USE_YN" v-model="searchCtObj.useYn" :bizSeq="searchCtObj.bizSeq"
             :optionNm="$t('message.전체')" />

<ZCodeMulti  commCd="CONT_DIV_CD" v-model="searchCtObj.contDivCds" :bizSeq="searchCtObj.bizSeq"
             :optionNm="$t('message.전체')" />
```

| prop | 설명 |
| --- | --- |
| `commCd` | 공통코드 그룹 (예: `USE_YN`) |
| `bizSeq` | 사업장별 코드 필터 (검색 bizSeq 와 연동) |
| `optionNm` | 최상단 옵션 라벨 — 없으면 표시 안 함 |
| `useYnFilter` | Y 만 / 전체 (기본 Y) |

- `ZCodeMulti` 의 v-model 은 **배열** (`contDivCds` 처럼 복수형 네이밍)
- `ZCodeSelect` 의 v-model 은 단일 값

## 4. ZRadio / ZCheckbox

```vue
<ZRadio v-model="editCtObj.useYn" value="Y" :text="$t('message.사용')" />
<ZRadio v-model="editCtObj.useYn" value="N" :text="$t('message.미사용')" />

<ZCheckbox v-model="editCtObj.isDefault" />
```

## 5. ZCalendar / ZCalendarRange — 날짜/기간

```vue
<!-- 단일 날짜 -->
<ZCalendar v-model="searchObj.baseDt" />

<!-- 기간 (시작~종료) -->
<ZCalendarRange v-model:start="searchObj.startDt" v-model:end="searchObj.endDt" />
```

- 실제 컴포넌트 파일: `components/be/searchItem/ZCalendar.vue`, `ZCalendarRange.vue`
- 기본 포맷: `YYYY-MM-DD` (서버 저장 포맷과 동일)
- `DateTool` (common.js) 로 서버 시간 변환 — `DateTool.toServerDate(d)`

## 6. 유효성 검사 (Vuelidate)

```js
import { useVuelidate } from '@vuelidate/core';
import { required } from '@vuelidate/validators';

const rules = computed(() => ({
    contNm: { required },
    contDivCd: { required },
}));
const v$ = useVuelidate(rules, editCtObj);

const valid = computed(() => ({
    contNm:    { class: v$.value.contNm.$error    ? 'invalid' : '' },
    contDivCd: { class: v$.value.contDivCd.$error ? 'invalid' : '' },
}));

async function vfn_save() {
    const ok = await v$.value.$validate();
    if (!ok) { requiredSwal(); return; }
    // ...
}
```

템플릿에서:
```vue
<ZText v-model="editCtObj.contNm" :class="valid.contNm.class" />
```

## 7. 자주 하는 실수

| 실수 | 해결 |
| --- | --- |
| `ZCodeSelect` 에 `bizSeq` 안 넘겨서 사업장별 코드 안 나옴 | 검색조건의 `bizSeq` 를 반드시 전달 |
| `ZCodeMulti` v-model 을 단일값으로 | 배열로 선언 |
| `ZSelect` `text`/`val` 생략 | 필수 — 필드명 명시 |
| `ZCalendar`/`ZCalendarRange` 포맷을 화면마다 다르게 | 서버는 `YYYY-MM-DD` 로 통일. 표시만 다르게 |

## 8. ZTextArea — 다중행 텍스트 입력

```vue
<ZTextArea v-model="editObj.note" :height="'80px'" />
```

| prop | 설명 |
|---|---|
| `modelValue` | 바인딩 값 |
| `height` | 높이 (기본값 없음, CSS 문자열 지정) |
| `label` | 내부 라벨 (선택) |

- `resize: none` 고정 (사용자 크기 조절 비활성)
- 비고/메모 필드에 사용

---

## 9. ZRadioBtn — 버튼 형태 라디오

공통코드 없이 정적 items로 버튼 UI 라디오를 구성할 때 사용.

```vue
<ZRadioBtn
  v-model="editObj.typeCd"
  :items="typeList"
  text="typeNm"
  val="typeCd"
/>
```

| prop | 타입 | 기본값 | 설명 |
|---|---|---|---|
| `items` | Array | — | 선택 항목 배열 |
| `text` | String | `'text'` | 표시 필드명 |
| `val` | String | `'value'` | 값 필드명 |
| `required` | String | `'true'` | `'false'` 로 설정하면 같은 값 재클릭 시 NULL로 토글 |
| `textTranslation` | Boolean | false | true면 text 값을 `$t()` 로 번역 |
| `disabled` | Boolean | — | 비활성 |

---

## 10. ZMultiRadio — 공통코드 버튼 라디오

`ZCodeSelect` 의 버튼 UI 버전. 공통코드를 가로 버튼 라디오로 표시.

```vue
<ZMultiRadio commCd="USE_YN" v-model="editObj.useYn" :bizSeq="bizSeq" />

<!-- required='false': 선택 취소 가능 -->
<ZMultiRadio commCd="PROC_TYPE_CD" v-model="searchObj.procTypeCd"
             :bizSeq="bizSeq" required="false" />
```

| prop | 설명 |
|---|---|
| `commCd` | 공통코드 그룹 (필수) |
| `bizSeq` | 사업장별 필터 |
| `required` | `'false'` 면 클릭 토글로 null 허용 |
| `ignoreCds` | 제외할 코드 배열 |

---

## 11. ZToggle — 토글 스위치

```vue
<ZToggle v-model="editObj.useYn" trueValue="Y" falseValue="N" />

<!-- 크기 커스터마이징 -->
<ZToggle v-model="editObj.isActive"
         toggleWidth="55px" toggleHeight="24px" togglePadding="3px" />
```

| prop | 기본값 | 설명 |
|---|---|---|
| `trueValue` | `true` | ON 상태 값 |
| `falseValue` | `false` | OFF 상태 값 |
| `toggleWidth` | `'45px'` | 토글 너비 |
| `toggleHeight` | `'20px'` | 토글 높이 |
| `togglePadding` | `'2px'` | 내부 패딩 |
| `label` | — | 우측 라벨 텍스트 |
| `disabled` | — | 비활성 |

---

## 12. ZDlvSelect — 배송사 선택

배송사 목록을 비동기로 로드하는 셀렉트박스.

```vue
<ZDlvSelect
  v-model="editObj.dlvCompSeq"
  :bizSeq="bizSeq"
  :centerSeq="centerSeq"
  :optionNm="$t('message.전체')"
/>
```

| prop | 설명 |
|---|---|
| `bizSeq` | 사업장 SEQ 필터 |
| `centerSeq` | 센터 SEQ 필터 (배송사는 센터별 설정) |
| `optionNm` | 최상단 옵션 라벨 |
| `resetValOnListChange` | true면 목록 변경 시 선택값 초기화 |
| `disabled` | 비활성 |
