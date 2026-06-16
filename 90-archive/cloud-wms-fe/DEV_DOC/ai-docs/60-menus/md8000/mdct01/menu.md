# MDCT01 거래처

## 1. 업무 개요

- **역할**: 거래처(납품처/고객사/대표업체)의 기본정보 관리
- **사용자**: 기준정보 담당자
- **빈도**: 신규 거래 발생 시

## 2. 화면 구성

| 파일 | 역할 |
| --- | --- |
| `views/be/md8000/mdct01/mdct01.vue` | 리스트/검색 |
| `views/be/md8000/mdct01/mdct01Edt.vue` | 등록/수정 팝업 |
| `views/be/md8000/mdct01/mdct01Lbs.vue` | 거래처 라벨 출력 |

## 3. API 매핑

| 기능 | FE 호출 | BE 기준 경로 |
| --- | --- | --- |
| 리스트 | `POST /mdct01/conts` | `Mdct01Controller` / `Mdct01Mapper.selectContList` |
| 단건 | `GET  /mdct01/conts/{contSeq}/{bizSeq}` → `res.data.cont` | `.selectCont` |
| 등록 | `PUT  /mdct01/conts` | `.insertCont` |
| 수정 | `PATCH /mdct01/conts` | `.updateCont` |
| 삭제 | `DELETE /mdct01/conts` | `.deleteConts` |

복합키: **(bizSeq, contSeq)** — URL 파라미터 순서는 `{contSeq}/{bizSeq}` (실제 코드 `mdct01Edt.vue:136` 기준)

## 4. 사용 공통코드

| commHCd | 의미 |
| --- | --- |
| `CONT_DIV_CD` | 거래처구분 (납품처/고객사 등) |
| `REP_CONT_CD` | 대표업체 |
| `USE_YN` | 사용여부 |

## 5. 데이터 변환 목록

```js
const commCdList = [
    { commHCd: 'CONT_DIV_CD', commDCd: 'contDivCd', commDNm: 'contDivNm' },
    { commHCd: 'REP_CONT_CD', commDCd: 'repContCd', commDNm: 'repContNm' },
    { commHCd: 'USE_YN',      commDCd: 'useYn',     commDNm: 'useYnNm'   },
];
await Promise.all([
    commCdStore.convertCommDNms(commCdList, postConts),
    bizCenterStore.convertBizCenterNms(postConts),
]);
```

## 6. 특수 로직

- **대표업체 (`REP_CONT_CD`)**: 값이 `REP_CO_NONE` (`assets/constant/zConstant.js`) 이면 빈값으로 표시
- **등록/삭제 버튼 현재 비활성**: `mdct01.vue` 에 주석 처리됨 — 정책 변경으로 수정만 허용
- **수정 모드 대부분 필드 `:disabled="isUpdate"`**: 기준정보 무결성 유지 목적

## 7. 관련 / 연동

- 사업자번호 유효성은 `common.js` 의 `gfn_validBizNo` (있다면) 사용

## 8. AI 작업용 재사용 프롬프트

프롬프트 본문은 **`70-prompts/73-common-code-column.md` 단일 소스**에 둔다.
메뉴별 중복 복사 금지 — 이 문서는 링크만 유지한다.

- 공통코드 컬럼 추가 → [`70-prompts/73-common-code-column.md`](../70-prompts/73-common-code-column.md)
- 신규 CRUD 메뉴 생성 → [`70-prompts/70-new-crud-menu.md`](../70-prompts/70-new-crud-menu.md)
- 그리드 컬럼 추가 → [`70-prompts/71-add-grid-column.md`](../70-prompts/71-add-grid-column.md)
- 검색 필드 추가 → [`70-prompts/72-add-search-field.md`](../70-prompts/72-add-search-field.md)
- BE 스펙 동기화 → [`70-prompts/74-sync-be-spec.md`](../70-prompts/74-sync-be-spec.md)
- BE 스펙 기반 신규 메뉴 → [`70-prompts/75-new-menu-from-be-spec.md`](../70-prompts/75-new-menu-from-be-spec.md)
- 메뉴 계약 정적 감사 → [`70-prompts/76-verify-menu-contract.md`](../70-prompts/76-verify-menu-contract.md)
