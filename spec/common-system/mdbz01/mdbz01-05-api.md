---
title: MDBZ01 API 명세 (FE·BE 공용)
description: mdbz01 사업장의 REST API 명세. FE/BE가 함께 참조하는 단일 계약 문서.
status: active
version: 1.0.0
repo_role: ai-hub
agent_usage: spec
menu_code: mdbz01
domain: master
depends_on:
  - "spec/common-system/mdbz01/mdbz01-02-ui.md"
  - "spec/common-system/mdbz01/mdbz01-03-data-model.md"
related:
  - "spec/common-system/mdbz01/mdbz01-06-be-flow.md"
  - "spec/common-system/mdbz01/mdbz01-07-fe-flow.md"
tags:
  - detail-design
  - api
  - master
---

# MDBZ01 API 명세 (FE·BE 공용)

## 1. Base 경로

```
Controller @RequestMapping: /{bizSeq}/mdbz01/bizs
```

> **FE zAxios 인터셉터 처리 주의:**
> FE에서 axios 호출 시 URL을 `/mdbz01/bizs/...` 형태로 사용하며, 인터셉터가 현재 로그인 사용자의 `bizSeq`를 앞에 자동으로 추가한다.
> 즉, FE 코드의 `/mdbz01/bizs/editable/bizs/${regBizSeq}` 는 실제 서버에 `/{bizSeq}/mdbz01/bizs/editable/bizs/{regBizSeq}` 로 전달된다.

---

## 2. 엔드포인트 목록 (검증됨 — Vue 호출과 대조)

| 업무 | HTTP | URL (서버 기준, /{bizSeq} prefix 포함) | 호출 화면 | 요청·응답 비고 |
|---|---|---|---|---|
| 수정 가능 사업장 목록 조회 | GET | `/{bizSeq}/mdbz01/bizs/editable/bizs/{regBizSeq}` | mdbz01.vue (화면 진입 시) | 응답: `bizList` 배열 |
| 사업장 단건 조회 | GET | `/{bizSeq}/mdbz01/bizs/{selectedBizSeq}` | mdbz01.vue (사업장 선택 시) | 응답: `biz` 객체 |
| 사업장 수정 | POST | `/{bizSeq}/mdbz01/bizs` | mdbz01.vue (사업장 저장 버튼) | 요청: multipart/form-data (사업장 정보 + 이미지 파일), 응답: `procCnt` |
| 물류센터 목록 조회 | GET | `/{bizSeq}/mdbz01/bizs/{selectedBizSeq}/centers` | mdbz01.vue (사업장 선택 후) | 응답: `bizCenter` 배열 |
| 물류센터 저장 (추가/수정/삭제) | PUT | `/{bizSeq}/mdbz01/bizs/centers` | mdbz01.vue (센터 저장 버튼) | 요청: `{insertList, updateList, deleteList}`, 응답: `succeed` |
| 대행의뢰신청업체 목록 조회 | GET | `/{bizSeq}/mdbz01/bizs/{selCenterSeq}/tplReq` | 미확인: Vue 호출 미확인 | 응답: `bizCenter` 배열 |
| 위탁 의뢰 수락/거절 | PATCH | `/{bizSeq}/mdbz01/bizs/{selBizSeq}/tplReq` | 미확인: Vue 호출 미확인 | 요청: `MDBZ01Center` 객체, 응답: `procCnt` |
| 위탁 센터 목록 조회 (팝업) | GET | `/{bizSeq}/mdbz01/bizs/tpl` | mdbz01Set.vue (MDBZ01P01 팝업 열기) | 응답: `bizCenter` 배열 |
| 위탁 센터 정보 수정 | PATCH | `/{bizSeq}/mdbz01/bizs/tpl` | mdbz01Set.vue (MDBZ01P01 저장 버튼) | 요청: `{updateList}`, 응답: `procCnt` |
| 물류 대행 업체 검색 | POST | `/{bizSeq}/mdbz01/bizs/tpl` | mdbz01Sch.vue (MDBZ01P02 검색 버튼) | 요청: `MDBZ01Search` 객체, 응답: `bizCenter` 배열 |
| 위탁 의뢰 신청 | PUT | `/{bizSeq}/mdbz01/bizs/tpl` | mdbz01Sch.vue (MDBZ01P02 위탁 의뢰 버튼) | 요청: `{bizSeq, note, checkedList}`, 응답: `procCnt` |
| 위탁 의뢰 취소 (의뢰자) | PATCH | `/{bizSeq}/mdbz01/bizs/cancel` | 미확인: Vue 호출 미확인 | 요청: `MDBZ01Center` 객체, 응답: `procCnt` |

---

## 3. 레거시/미사용 엔드포인트

| HTTP | URL | 이유 | 권장 조치 |
|---|---|---|---|
| GET | `/{bizSeq}/mdbz01/bizs/{selCenterSeq}/tplReq` | Vue 파일에서 호출 코드 미발견 | 현재 상태 및 사용 이력 확인 후 제거 여부 결정 — 삭제 전 반드시 확인 필요 |
| PATCH | `/{bizSeq}/mdbz01/bizs/{selBizSeq}/tplReq` | Vue 파일에서 호출 코드 미발견 | 동일 |
| PATCH | `/{bizSeq}/mdbz01/bizs/cancel` | Vue 파일에서 호출 코드 미발견 | 동일 |

> 미확인: 다른 Vue 화면(사업장 관련 화면 전체)에서 사용 중일 가능성이 있으므로 즉시 삭제하지 말 것.

---

## 4. 주요 요청/응답 필드

### MDBZ01Biz (사업장 정보)

| 필드명 | 설명 | 비고 |
|---|---|---|
| bizSeq | 사업장 순번 | 내부 식별키 |
| bizNm | 사업장명 | 필수 (@NotBlank) |
| bizNmShort | 사업장 약칭 | |
| ceoNm | 대표자명 | |
| bizNo | 사업자등록번호 | |
| subBizNo | 종사업자번호 | |
| bizType | 업태 | |
| bizItem | 업종 | |
| bizDivCd | 사업장 구분 코드 | OWN/TPL/SHIPPER |
| email | 이메일 | |
| tel | 전화번호 | |
| fax | 팩스 | |
| postNo | 우편번호 | |
| addr | 주소 | |
| addrDtl | 주소 상세 | |
| logoFileSeq | 로고 파일 순번 | null이면 이미지 없음 |
| bizColor | 사업장 테마색 | HEX 코드 |
| note | 비고 | |
| useYn | 사용여부 | Y/N |
| filePath | 로고 이미지 URL (응답 전용) | Comp에서 URL로 변환 후 반환 |

### MDBZ01Center (물류센터 정보)

| 필드명 | 설명 | 비고 |
|---|---|---|
| centerSeq | 센터 순번 | 내부 식별키 |
| bizSeq | 사업장 순번 | |
| bizNm | 사업장명 | 조회 응답용 |
| centerNm | 센터명 | 필수 (@NotBlank) |
| tel | 전화번호 | 위탁 센터 시 필수 |
| email | 이메일 | |
| postNo | 우편번호 | |
| addr | 주소 | |
| addrDtl | 주소 상세 | |
| note | 비고 / 위탁 의뢰 메모 | |
| useYn | 사용여부 | Y/N |
| tplYn | 물류대행 가능 여부 | Y/N |
| tplCenterYn | 위탁 센터(외부 소유) 여부 | 응답 전용 |
| cfmYn | 승인여부 | Y/N |
| editableYn | 현재 사용자 수정 가능 여부 | 응답 전용 |
| reqSts | 위탁 의뢰 상태 | 신청가능/신청중/승인/거절 |
| authCnt | 승인 건수 | 응답 전용 |
| unauthCnt | 미승인 건수 | 응답 전용 |

### MDBZ01SaveCenter (센터 저장 요청)

| 필드명 | 설명 | 비고 |
|---|---|---|
| insertList | 추가할 센터 목록 | |
| updateList | 수정할 센터 목록 | |
| deleteList | 삭제할 센터 목록 | |
| checkedList | 위탁 의뢰 신청 시 선택된 센터 목록 | |
| bizSeq | 사업장 순번 | |
| note | 위탁 의뢰 요청 내용 | |

### MDBZ01Response (공통 응답)

| 필드명 | 설명 | 비고 |
|---|---|---|
| biz | 사업장 단건 정보 | selectBiz 응답 시 사용 |
| bizCenter | 물류센터 목록 | 센터 관련 조회 응답 시 사용 |
| bizList | 사업장 목록 | searchEditableBizs 응답 시 사용 |
| procCnt | 처리 건수 | 저장/수정/삭제 응답 시 사용 |
| succeed | 성공 여부 | 센터 저장 응답 시 사용 |

---

## 5. 설계 포인트

### 5-1. 동일 URL 다중 HTTP 메서드 사용 (`/tpl` 엔드포인트)

`/{bizSeq}/mdbz01/bizs/tpl` 경로에 4가지 HTTP 메서드가 모두 존재한다:

| HTTP | 용도 |
|---|---|
| GET | 위탁 센터 목록 조회 (MDBZ01P01 팝업용) |
| PATCH | 위탁 센터 정보 수정 |
| POST | 물류 대행 업체 검색 (MDBZ01P02 팝업 검색) |
| PUT | 위탁 의뢰 신청 |

FE에서 호출 시 HTTP 메서드를 MUST 정확히 지정해야 한다. GET과 POST가 완전히 다른 업무이므로 혼동 주의.

### 5-2. 사업장 수정 메서드 불일치

사실: 사업장 수정(`updateBiz`)은 실제 구현에서 `MDBZ01Controller.patchBiz`가 `@PostMapping`으로 선언되어 있고, FE도 `axios.post`로 호출한다.

추정: multipart/form-data 전송 처리 때문에 POST를 유지한 것으로 해석할 수 있으나, 그 이유 자체는 소스에 명시돼 있지 않다.

현재 문서 기준에서는 현 구현(POST)을 유지 대상으로 본다.

### 5-3. 미연결 엔드포인트 3건

Controller에 존재하지만 현재 소스의 어떤 Vue 파일에서도 호출이 확인되지 않는 엔드포인트 3건(tplReq GET, tplReq PATCH, cancel PATCH)이 있다. 별도 화면이나 다른 경로의 Vue에서 사용할 가능성이 있으므로 전체 소스 탐색 후 판단 필요.
