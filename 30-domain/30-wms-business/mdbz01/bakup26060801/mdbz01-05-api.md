---
title: MDBZ01 API 명세 (FE·BE 공용)
description: mdbz01 사업장·물류센터·물류위탁(3PL) 관리의 REST API 명세. FE/BE가 함께 참조하는 단일 계약 문서. 서버 라우팅 기준으로 단일화.
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: spec
menu_code: mdbz01
domain: master
depends_on:
  - "70-knowledgebase/mdbz01/mdbz01-02-screen.md"
  - "70-knowledgebase/mdbz01/mdbz01-03-data-model.md"
related:
  - "70-knowledgebase/mdbz01/mdbz01-06-be-flow.md"
  - "70-knowledgebase/mdbz01/mdbz01-07-fe-flow.md"
tags:
  - detail-design
  - api
  - 3pl
---

# MDBZ01 API 명세 — 「사업장」 (FE·BE 공용)

> 사업장·물류센터·물류위탁(3PL) 관리 업무의 REST API 계약이다. **FE·BE 양쪽이 이 문서를 참조**한다.
> URL은 **실제 서버 라우팅 기준**으로 표기한다.
> **FE 주의:** zAxios 인터셉터가 `regBizSeq`(`{bizSeq}`)를 자동으로 prepend하므로, FE 코드에서는 `/mdbz01/bizs/...`처럼 앞의 `/{bizSeq}`가 생략되어 보인다.

## 1. Base 경로

```
/{bizSeq}/mdbz01/bizs
```

## 2. 엔드포인트 목록 (현재 화면 사용 — 검증됨)

아래는 `mdbz01.vue` / `mdbz01Sch.vue`(P02) / `mdbz01Set.vue`(P01) 소스에서 **실제 호출이 확인된** 엔드포인트다.

| 업무 | HTTP | URL (서버 기준) | 호출 화면 | 요청/응답 비고 |
|---|---|---|---|---|
| ① 사업장 콤보 조회(권한별) | GET | `/{bizSeq}/mdbz01/bizs/editable/bizs/{regBizSeq}` | mdbz01 | 권한별 분기. 응답 `res.data.bizList` |
| ① 사업장 1건 조회 | GET | `/{bizSeq}/mdbz01/bizs/{sel}` | mdbz01 | `MDM_BIZ`+`SM_FILE` 조인. 응답 `res.data.biz` |
| ① 사업장 수정 | POST | `/{bizSeq}/mdbz01/bizs` | mdbz01 | `multipart/form-data` (로고 이미지 포함) |
| ② 물류센터 목록 | GET | `/{bizSeq}/mdbz01/bizs/{sel}/centers` | mdbz01 | 응답 `res.data.bizCenter` |
| ② 자사센터 일괄 저장 | PUT | `/{bizSeq}/mdbz01/bizs/centers` | mdbz01 | insert/update/delete 묶음 |
| ③ 대행업체 검색 | POST | `/{bizSeq}/mdbz01/bizs/tpl` | P02 (Sch) | 신청상태 표시 검색 (검색조건 body) |
| ③ 위탁 의뢰 신청 | PUT | `/{bizSeq}/mdbz01/bizs/tpl` | P02 (Sch) | `{bizSeq, note, checkedList}` 거래 생성/재신청 |
| ③ 위탁센터(자기 센터) 조회 | GET | `/{bizSeq}/mdbz01/bizs/tpl` | P01 (Set) | 자기 센터(`biz_seq=reg_biz_seq`) 조회. 응답 `res.data.bizCenter` |
| ③ **위탁센터 정보수정(대행 등록)** | PATCH | `/{bizSeq}/mdbz01/bizs/tpl` | P01 (Set) | **`MDM_CENTER`의 `tpl_yn`(물류대행여부)·주소·연락처 갱신.** `update3plCenter` |

> ⚠️ **P01(`mdbz01Set` "센터정보수정")은 "위탁 의뢰 수락/거절"이 아니다.** 대행사가 **자기 센터를 물류대행용으로 등록·수정**(`tpl_yn`+주소/연락처)하는 화면이며, `MDM_BIZ_CENTER`의 `cfm_yn/use_yn` 상태머신은 건드리지 않는다. 진짜 위탁 의뢰 수락/거절은 §3 참조(현재 화면 미연결).

## 3. 엔드포인트 — 레거시/미사용 추정 (⚠️ 추후 개발 시 확인 필요)

BE에는 존재하나 **위 3개 화면에서 호출이 확인되지 않은** 엔드포인트다. 사업장 단위→센터 단위 재설계 과정의 잔재로 추정된다([`mdbz01-06-be-flow.md`](mdbz01-06-be-flow.md) §5 기술이슈 참조). **삭제하지 말고, 실제 사용처를 확인한 뒤 정리할 것.**

| 업무(원래 의도) | HTTP | URL (서버 기준) | BE 메서드 | 확인 필요 사항 |
|---|---|---|---|---|
| 신청업체(들어온 의뢰) 조회 | GET | `/{bizSeq}/mdbz01/bizs/{sel}/tplReq` | `selectReqBizCenter` | 호출 화면 미확인 |
| **위탁 의뢰 수락/거절 (진짜)** | PATCH | `/{bizSeq}/mdbz01/bizs/{selBiz}/tplReq` | `respTplCenter` | `MDM_BIZ_CENTER`의 `cfm_yn/use_yn` 상태 변경 + **수락 시 창고 자동연결(BR-9, `insertBizWh`)**. 현재 3개 화면 미연결 — §2의 P01 `/tpl`(tpl_yn 등록)과는 **다른 기능** |
| 위탁 의뢰 취소 | PATCH | `/{bizSeq}/mdbz01/bizs/cancel` | `cancelRequest` | 호출 화면 미확인 + 물리 DELETE(소프트삭제 원칙 상충) |

> 📌 **해소 방식:** 본 문서는 소스를 수정하지 않는다. 위 표는 "문서-소스 불일치"를 숨기지 않고 **개발자가 확인할 과제로 남겨두기 위한** 것이다. 실제 사용처가 확인되면 §2(활성) 또는 삭제 대상으로 이관한다.

## 4. 주요 요청/응답 필드

> 필드의 타입·길이·제약은 [`mdbz01-03-data-model.md`](mdbz01-03-data-model.md) → 운영/dev DB 직접 조회(공용 [`tech-stack`](../_common/tech-stack.md) §3)로 확인. 아래는 API 페이로드 구성 기준이다.

### 4-1. 사업장(`biz`) 객체

| 필드 | 설명 | 비고 |
|---|---|---|
| `bizSeq` | 사업장 PK | |
| `bizNm` | 사업장명 | **필수** |
| `bizNo` / `subBizNo` | 사업자번호 / 종사업자번호 | |
| `ceoNm` | 대표자 | |
| `bizType` / `bizItem` | 업태 / 업종 | |
| `postNo` / `addr` / `addrDtl` | 우편번호 / 주소 / 주소상세 | |
| `tel` / `email` / `fax` | 연락처 | |
| `bizDivCd` | 사업장구분(OWN/TPL/SHIPPER) | 화면 변경 불가 |
| `useYn` | 사용여부 | 화면 변경 불가 |
| `logoFileSeq` | 로고 파일 | 응답 시 `filePath`/`fileNm`/`fileExtension` 동반 |
| `bizColor` | 테마색 | 기본 `#00afec` |
| `note` | 비고 | |

### 4-2. 센터(`center`) 객체

| 필드 | 설명 | 비고 |
|---|---|---|
| `centerSeq` | 센터 PK | |
| `centerNm` | 센터명 | **필수** |
| `postNo` / `addr` / `addrDtl` / `tel` | 주소·연락처 | `tpl_yn='Y'`(대행 등록) 시 필수 |
| `tplYn` | 물류대행여부(`MDM_CENTER`) | P01에서 사용/미사용 설정 |
| `useYn` | 사용여부 | |
| `tplCenterYn` / `cfmYn` | 위탁센터 여부 / 승인여부 | 상태 판별용(→ data-model §3) |
| `note` | 비고 | |

### 4-3. 위탁 요청/응답 페이로드

| 용도 | 구조 |
|---|---|
| 자사센터 일괄 저장 (PUT centers) | `{ insertList:[center], updateList:[center], deleteList:[center] }` |
| 대행업체 검색 (POST tpl) | 요청 `{ bizNm, centerNm, addr }` / 응답 row `{ reqSts, bizNm, centerNm, addr, addrDtl, tel, email, bizSeq, centerSeq }` |
| 위탁 의뢰 신청 (PUT tpl) | `{ bizSeq, note, checkedList:[{ bizSeq, centerSeq, ... }] }` |
| 위탁센터 정보수정 (PATCH tpl, P01) | 변경분 `{ insertList, updateList, deleteList }` — row 에 `tplYn`(물류대행여부), `addr`, `addrDtl`, `tel`, `email`, `note` 포함 |

## 5. 설계 포인트

- `/mdbz01/bizs/tpl` **단일 엔드포인트를 HTTP 메서드로 위탁 CRUD를 구분** 처리한다.
  - `POST` = 대행업체 검색 / `PUT` = 의뢰 신청 / `GET` = 자기 센터 조회 / `PATCH` = 위탁센터 정보수정(`tpl_yn`·주소 등록)
- **주의:** `/tpl PATCH`(P01, `tpl_yn` 등록)와 `/tplReq PATCH`(위탁 의뢰 수락/거절, `cfm_yn/use_yn`)는 **이름이 비슷하지만 다른 기능**이다. 전자는 활성, 후자는 현재 화면 미연결(§3).
- 상태값/코드 의미는 [`mdbz01-03-data-model.md`](mdbz01-03-data-model.md), 메서드별 서버 처리는 [`mdbz01-06-be-flow.md`](mdbz01-06-be-flow.md) 참조.
