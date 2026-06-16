---
title: MDWH01 API 명세 (FE·BE 공용)
description: mdwh01 창고의 REST API 명세. FE/BE가 함께 참조하는 단일 계약 문서.
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: spec
menu_code: mdwh01
domain: master
depends_on:
  - "70-knowledgebase/mdwh01/mdwh01-02-screen.md"
  - "70-knowledgebase/mdwh01/mdwh01-03-data-model.md"
related:
  - "70-knowledgebase/mdwh01/mdwh01-06-be-flow.md"
  - "70-knowledgebase/mdwh01/mdwh01-07-fe-flow.md"
tags: [detail-design, api, master]
---

# MDWH01 API 명세 (FE·BE 공용)

## 1. Base 경로

```
Controller @RequestMapping: /{bizSeq}/mdwh01/whs
```

- `{bizSeq}`: 사업장 순번 (Path Variable, 모든 API 공통)
- FE에서 `zAxios` 인터셉터가 `/{bizSeq}` 프리픽스를 자동으로 붙이므로, Vue 코드에서는 `/mdwh01/whs` 형태로 호출한다.

## 2. 엔드포인트 목록 (검증됨 — Vue 호출과 대조)

| 업무 | HTTP | URL (서버 기준) | 호출 화면 | 요청·응답 비고 |
|---|---|---|---|---|
| 창고 조회 | POST | `/{bizSeq}/mdwh01/whs` | 창고 목록(MDWH01) | 검색조건 Body, 창고 목록 반환 |
| 창고 등록 | PUT | `/{bizSeq}/mdwh01/whs` | 창고 등록 팝업(MDWH01P01) | 창고 데이터 Body, 201 Created 반환 |
| 창고 단건 조회 | GET | `/{bizSeq}/mdwh01/whs/{whSeq}` | 창고 수정 팝업(MDWH01P02) | whSeq Path Variable, 창고 단건 반환 |
| 창고 수정 | PATCH | `/{bizSeq}/mdwh01/whs` | 창고 수정 팝업(MDWH01P02) | 수정 데이터 Body, 처리 건수 반환 |
| 창고 삭제 | DELETE | `/{bizSeq}/mdwh01/whs?whSeqs={whSeqs}` | 창고 목록(MDWH01) | whSeqs Query Parameter(복수), 처리 건수 반환 |

### FE zAxios 인터셉터 주석

```
// FE 호출 예시 (zAxios 인터셉터가 /{bizSeq} 프리픽스를 자동 추가)
axios.post(`/mdwh01/whs`, searchWhObj.value)           // → POST /{bizSeq}/mdwh01/whs
axios.put(`/mdwh01/whs`, editWhObj.value)              // → PUT /{bizSeq}/mdwh01/whs
axios.get(`/mdwh01/whs/${whSeq}`)                      // → GET /{bizSeq}/mdwh01/whs/{whSeq}
axios.patch(`/mdwh01/whs`, editWhObj.value)            // → PATCH /{bizSeq}/mdwh01/whs
axios.delete(`/mdwh01/whs?whSeqs=${checkItems.map(it => it.whSeq)}`)  // → DELETE /{bizSeq}/mdwh01/whs?whSeqs=...
```

## 3. 레거시/미사용 엔드포인트

없음. Controller에 선언된 5개 엔드포인트 모두 Vue에서 호출되고 있다.

단, 아래 함수는 Vue에서 선언만 되고 실제 호출이 확인되지 않아 추가 확인이 필요하다.
- `lfn_searchMenuGroup(userId)` — `/mdus01/users/groups/{userId}` 를 호출하나, `onMounted`에서 인수 없이 실행되어 `userId`가 `undefined`로 전달됨. 자세한 내용은 99-issues 참조.

## 4. 주요 요청/응답 필드

### 4-1. 창고 조회 요청 (MDWH01Search)

| 필드 | 설명 | 비고 |
|---|---|---|
| bizSeq | 사업장 순번 | Path Variable에서 주입 |
| centerSeq | 물류센터 순번 | 선택 검색조건 |
| whGroupCds | 창고그룹 코드 배열 | 다중 선택 |
| whNm | 창고명 | 부분 일치 검색 |
| useYn | 사용여부 | Y/N |
| cfdCd | 온도구분 코드 | 단일 선택 |
| cfdCds | 온도구분 코드 배열 | 다중 선택 |
| whSeq | 창고 순번 | 단건 필터용 |
| notWhSeq | 제외할 창고 순번 | 특정 창고 제외 필터용 |

### 4-2. 창고 등록/수정 요청 (MDWH01Wh)

| 필드 | 설명 | 필수 여부 | 비고 |
|---|---|---|---|
| centerSeq | 물류센터 순번 | 필수 | @NotNull, @Min(0) |
| whNm | 창고명 | 필수 | @NotBlank, 최대 30자 |
| whGroupCd | 창고그룹 코드 | - | 등록 시 필수 (FE 검증) |
| cfdCd | 온도구분 코드 | - | 기본값 'D'(상온) |
| inYn | 입고기능 여부 | - | Y/N, 미입력 시 N |
| pickYn | 출고(fr)기능 여부 | - | Y/N |
| outYn | 출하(fr)기능 여부 | - | Y/N |
| returnYn | 반품기능 여부 | - | Y/N |
| etcYn | 예외기능 여부 | - | Y/N |
| stYn | 세트작업 기능 여부 | - | Y/N |
| rpYn | 전환기능 여부 | - | Y/N |
| availableInvenYn | 가용재고 여부 | - | Y/N, 기본값 Y |
| useYn | 사용여부 | - | Y/N, 수정 시에만 사용 |
| ifWhId | IF창고ID | - | 외부 ERP 연동 식별자 |
| whSeq | 창고 순번 | - | 수정 시 필수 |

### 4-3. 응답 구조 (MDWH01Response)

| 필드 | 설명 | 사용 API |
|---|---|---|
| postWhs | 창고 목록 (MDWH01Search 배열) | POST /whs (조회) |
| wh | 창고 단건 정보 (MDWH01Wh) | GET /whs/{whSeq} |
| procCnt | 처리 건수 | PUT, PATCH, DELETE |
| (공통) warn | 업무 경고 메시지 | 검증 실패 시 |
| (공통) systemError | 시스템 오류 정보 | 예외 발생 시 |

### 4-4. 조회 응답 필드 중 추가 제공 항목 (MDWH01Search)

| 필드 | 설명 |
|---|---|
| centerNm | 물류센터명 |
| whGroupNm | 창고그룹명 (공통코드 변환) |
| cfdNm | 온도구분명 (공통코드 변환, FE에서 변환) |
| useYnNm | 사용여부명 (FE에서 변환) |
| availableInvenNm | 가용재고여부명 (FE에서 변환) |
| tplCenterYn | 물류대행센터 여부 (Y: 위탁 사업장 소속) |
| regBizSeq | 센터를 등록한 원 사업장 순번 |
| locSeq | 기본 위치 순번 |
| locNm | 기본 위치명 |
| ifWhId | IF창고ID (사업장-창고 매핑 테이블에서 조회) |

## 5. 설계 포인트

- 조회 API가 GET이 아닌 **POST**로 설계된 것은 다중 배열 파라미터(whGroupCds, cfdCds) 전달의 편의성을 위한 설계 선택이다.
- 삭제 API는 Query Parameter로 복수의 창고 순번을 전달한다. 대량 삭제 시 URL 길이 제한에 주의가 필요하다.
- 수정 API는 PATCH를 사용하나 실제로는 전체 필드를 전송하는 형태로 구현되어 있다 (부분 업데이트 아님).
- 창고 등록(PUT)과 수정(PATCH) 모두 동일한 `MDWH01Wh` Bean을 사용하며, 팝업 내에서 `isUpdate` 상태로 모드를 전환한다.
