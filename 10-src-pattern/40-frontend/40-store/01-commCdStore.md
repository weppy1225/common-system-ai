---
title: 공통코드 스토어 (commCdStore)
description: 공통코드 조회·캐싱·변환 Pinia 스토어 사용법. convertCommDNms/getCommHCd API, 배치 캐싱 동작, bizSeq 규약. 공통코드 사용 시 반드시 이 스토어를 경유해야 한다.
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: instruction
domain: frontend
tags:
  - commcdstore
  - pinia
  - common-code
  - caching
related:
  - 10-src-pattern/40-frontend/30-component/03-z-form-inputs.md
  - 10-src-pattern/40-frontend/50-pattern/01-crud-list-page.md
---

# 공통코드 스토어 (`commCdStore`)

공통코드 조회·캐싱·변환. **반드시** 이 스토어를 통해서만 공통코드를 사용한다. (`/code/commcds` 직접 호출 금지)

## 1. import / 초기화

```js
import { sfn_useCommCdStore } from "@/stores/commCdStore";
const commCdStore = sfn_useCommCdStore();
```

## 2. 주요 API

### `convertCommDNms(commCdList, rows)` ★ 가장 많이 씀

그리드 데이터의 코드값 필드를 명칭으로 변환한다.

```js
const commCdList = [
    { commHCd: 'CONT_DIV_CD', commDCd: 'contDivCd', commDNm: 'contDivNm' },
    { commHCd: 'USE_YN',      commDCd: 'useYn',     commDNm: 'useYnNm'   },
];
await commCdStore.convertCommDNms(commCdList, postConts);
```

- `commHCd`: 공통코드 그룹 (DB sm_code 테이블의 comm_h_cd)
- `commDCd`: 응답 객체 내 **코드값이 들어 있는 필드명**
- `commDNm`: 변환 후 **명칭을 저장할 새 필드명**
- 동작: 각 row 에 `commDNm` 필드를 직접 세팅 (`row.contDivNm = '납품처'`)

### `getCommHCd(commHCd, bizSeq)`

특정 공통코드 그룹의 전체 코드 리스트를 반환 (ZCodeSelect/ZCodeMulti 가 내부에서 사용).

```js
const codes = await commCdStore.getCommHCd('CONT_DIV_CD', bizSeq);
// [{ commDCd: '1', commDNm: '납품처', useYn: 'Y', ... }, ...]
```

## 3. 배치 캐싱 동작

- 첫 호출 시 100ms 대기하면서 **같은 bizSeq 의 모든 요청을 모아 한 번에** `/code/commcds` 호출
- 이미 메모리에 있는 코드는 서버 재호출 없음
- 결과적으로 한 화면에서 `ZCodeSelect` 가 10개 있어도 서버 요청은 1회

→ **절대 우회하지 말 것**. 여러 컴포넌트에서 같은 코드를 써도 걱정 없다.

## 4. bizSeq 규약

| 전달값 | 동작 |
| --- | --- |
| 유효한 숫자 | 해당 사업장 코드 |
| `null` / `undefined` / `-1` | `bizCenterStore.regBizSeq` (로그인 기본 사업장)로 fallback |

공통코드는 사업장별로 다를 수 있음 → 검색영역의 `bizSeq` 를 그대로 전달.

## 5. 관련 컴포넌트

- `ZCodeSelect` (단일 선택)
- `ZCodeMulti` (다중 선택, 내부적으로 `commDCds` 배열)
- 둘 다 `commCd` prop + `bizSeq` prop 전달

```vue
<ZCodeSelect commCd="CONT_DIV_CD" v-model="editCtObj.contDivCd" :bizSeq="editCtObj.bizSeq" />
<ZCodeMulti  commCd="REP_CONT_CD" v-model="searchCtObj.repContCds" :bizSeq="searchCtObj.bizSeq" :optionNm="$t('message.전체')" />
```

## 6. 자주 쓰는 공통코드

| commHCd | 의미 |
| --- | --- |
| `USE_YN` | 사용여부 Y/N |
| `CONT_DIV_CD` | 거래처구분 |
| `REP_CONT_CD` | 대표업체 |
| `REP_CO_CD` | 대표회사 |
| `AUTH_TYPE_CD` | 권한유형 |
| `LOC_TYPE_CD` | 위치유형 |
| ... | 추가는 BE sm_code 참조 |

## 7. 자주 하는 실수

| 실수 | 올바른 방법 |
| --- | --- |
| `axios.get('/code/commcds')` 직접 호출 | `commCdStore.getCommHCd(...)` |
| 응답 데이터를 수동 map 으로 매핑 | `convertCommDNms(...)` |
| `commDNm` 을 이미 있는 필드명으로 설정 | 새 필드명 사용 (예: `contDivNm`) |
| 변환 없이 그리드에 `contDivCd` 바로 표시 | 그리드 `dataField` 를 `contDivNm` 으로 |
