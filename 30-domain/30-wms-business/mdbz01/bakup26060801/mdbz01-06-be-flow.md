---
title: MDBZ01 BE 구현 흐름 (서버 처리)
description: mdbz01 사업장·물류센터·물류위탁(3PL) 관리의 백엔드 구현 흐름. Bean/DTO, 업무별 Comp/TxComp 처리 흐름, 예외 매핑, 식별된 기술 이슈를 기술. 기술스택은 공통 문서 참조.
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: spec
menu_code: mdbz01
domain: master
depends_on:
  - "70-knowledgebase/_common/tech-stack.md"
  - "70-knowledgebase/mdbz01/mdbz01-05-api.md"
  - "70-knowledgebase/mdbz01/mdbz01-03-data-model.md"
  - "70-knowledgebase/mdbz01/mdbz01-04-be-mapper-sql.md"
related:
  - "70-knowledgebase/_common/tech-stack.md"
  - "70-knowledgebase/mdbz01/mdbz01-04-be-mapper-sql.md"
tags:
  - detail-design
  - backend
  - mybatis
  - 3pl
---

# MDBZ01 BE 구현 흐름 — 「사업장」

> 서버에서 각 업무를 **어떤 구조·흐름으로 처리**하는지 기술한다.
> 기술 스택·레이어 아키텍처: [`_common/tech-stack.md`](../_common/tech-stack.md) · API 명세: [`mdbz01-05-api.md`](mdbz01-05-api.md) · 데이터 모델: [`mdbz01-03-data-model.md`](mdbz01-03-data-model.md)
> 구현 근거 소스: `cloud-wms-be` → `src/main/java/be/md8000/mdbz01/`

## 1. Bean (DTO)

| Bean | 역할 |
|---|---|
| `MDBZ01Biz` | 사업장 |
| `MDBZ01Center` | 센터 |
| `MDBZ01Search` | 검색조건 |
| `MDBZ01SaveCenter` | insert/update/delete 리스트 묶음 |
| `MDBZ01Response` | 응답 |

## 2. 업무 ↔ Comp 메서드 매핑

| 업무 | Comp 메서드 | 주요 처리 |
|---|---|---|
| ① 회사 조회 | `selectBiz` | `MDM_BIZ`+`SM_FILE` 조인, 로고 URL 변환 |
| ① 회사 수정 | `updateBiz` | 파일 업/삭제 후 `MDM_BIZ` update |
| ② 센터 조회 | `selectBizCenter` | `MDM_BIZ_CENTER` 조인 조회 |
| ② 센터 저장 | `saveBizCenter` | insert/update/delete 일괄 |
| ③ 신청업체 조회 | `selectReqBizCenter` | 들어온 의뢰 조회 — **🟠 화면 미연결** |
| ③ 수락/거절 | `respTplCenter` | 상태 갱신 + 창고연결(BR-9) — **🟠 화면 미연결** |
| ③ 위탁센터 조회 | `selectTplBizCenter` | 팝업용 조회 (P01 로드) |
| ③ 위탁센터 정보수정(대행 등록) | `update3plCenter` | `MDM_CENTER` `tpl_yn`·주소 update (P01 저장, **≠수락/거절**) |
| ③ 대행업체 검색 | `searchTplBizCenter` | 신청상태 표시 검색 (P02) |
| ③ 의뢰 신청 | `reqTplCenter` | 거래 생성/재신청 (P02) |
| ③ 의뢰 취소 | `cancelRequest` | 물리 DELETE — **🟠 화면 미연결** |
| 권한별 회사목록 | `searchEditableBizs` | 권한별 분기 쿼리 |

> ⚠️ **메서드-화면 매핑 주의:** P01 화면(`mdbz01Set.vue`, "센터정보수정")은 **`update3plCenter`(PATCH `/tpl`, `tpl_yn`·주소 갱신)** 를 호출하며, 이는 "위탁 의뢰 수락/거절"이 **아니다**(자기 센터를 대행용으로 등록·수정). 진짜 수락/거절인 `respTplCenter`(PATCH `/tplReq`, `cfm_yn/use_yn` + BR-9)·`selectReqBizCenter`·`cancelRequest`는 현재 3개 화면에서 호출이 확인되지 않는다(레거시 추정). 상세는 [`mdbz01-05-api.md`](mdbz01-05-api.md) §3 참조. **추후 개발 시 활성 경로 확인 필요.**

## 3. 업무별 구현 상세

### 업무 ③ 위탁 의뢰 신청 — `reqTplCenter → reqTplCenterTX`
```
for (선택 센터) {
   MDM_BIZ_BIZ 존재체크(checkExistBizBiz) → 없으면 insert (use_yn='N')
   상태분기(checkExistBizCenter):
     · 신규           → insertBizCenter4Tpl (cfm_yn='N', use_yn='N')
     · ACCEPT/REQUEST → AlreadyProcessException  (BR-6)
     · DENIED         → updateBizCenter4Tpl (cfm_yn='N' 재신청, BR-7)
}
```
> 구현 이슈: for 루프 내 단건 insert/update 반복 → **N+1 패턴** (backend-convention §8-2 위반 소지)

### 업무 ③ 수락/거절 — `respTplCenter → respTplCenterTX`
```
checkExistBizCenter (없으면 NotFound)
respTplCenter   : MDM_BIZ_CENTER cfm_yn/use_yn 갱신
updateBizBiz    : MDM_BIZ_BIZ use_yn 재계산 (센터 사용 여부 집계)
if 수락(use_yn=Y): insertBizWh → 대행사 창고를 의뢰자 사업장에 연결 (BR-9)
```

### 업무 ③ 의뢰 취소 — `cancelRequest → cancelRequestTX`
```
checkExistBizCenter ×2 (상태 REQUEST 확인, BR-8)
cancelRequest : MDM_BIZ_CENTER 물리 DELETE
```
> 구현 이슈: 동일 `checkExistBizCenter` **2회 연속 호출**(불필요 쿼리), `DELETE FROM` **물리삭제**(소프트삭제 원칙 상충)

### 업무 ② 센터 저장 — `saveBizCenter → saveBizCenterTX`
```
[Comp] checkRequiredForSaveCenter : tplYn='Y' 시 주소/전화 필수 (ZinBadRequestException, BR-5)
[TxComp]
  insertCenter : 센터명중복체크(BR-2) → MDM_CENTER+MDM_BIZ_CENTER insert
                 → 슈퍼권한 자동부여 → 기본창고템플릿(TEMP_BIZ_SEQ) 복제생성
  updateCenter : 중복체크 + 위탁업체 존재체크(BR-3) → update
  deleteCenter : 권한센터/위탁/창고 3중 가드(BR-4) → 소프트삭제(use_yn='N')
  throwIfNoCenterUsed : 전체 미사용 시 NotMeetConditionsException (BR-1)
```
- **창고 자동생성**: `searchWhTemplate` → `insertDefaultWh`(MDM_WH) + `insertbizWh`(MDM_BIZ_WH) + `insertDefaultLoc`(MDM_LOC) 3건 묶음 (Dao에서 복수 Mapper 조합)

### 업무 ① 회사 수정 — `updateBiz → updateBizTX`
```
파일 분기 (MDBZ01CompUtil.makeFileData):
  · file 있음          → 기존 로고 삭제 후 업로드, logoFileSeq 세팅
  · file 없음+seq 없음  → 기존 로고 삭제
MDM_BIZ update
```

### 권한별 회사 목록 — `searchEditableBizs`
```sql
authTypeCd 분기:
  AUTH_TYPE_BIZ    → MDM_USER_BIZ 소속 사업장
  AUTH_TYPE_CENTER → MDM_USER_CENTER 권한 센터의 사업장
  공통             → biz_div_cd != SHIPPER 제외
```

## 4. 예외 처리 매핑

| 업무 규칙 | 구현 예외 클래스 |
|---|---|
| 주소/전화 필수(BR-5) | `ZinBadRequestException` |
| 센터명 중복(BR-2) | `ZinExistDataException` |
| 위탁중 센터 변경 불가(BR-3) | `AlreadyProcessException` |
| 최소 1센터 운영(BR-1) | `NotMeetConditionsException` |
| 중복 신청(BR-6) | `AlreadyProcessException` |

## 5. 식별된 기술 이슈 (리팩터링 후보)

| 구분 | 내용 |
|---|---|
| 물리 DELETE | `cancelRequest`, `deleteUserCenter`, `deleteCenterAutority` — 소프트삭제 원칙 상충 |
| N+1 | `reqTplCenterTX`, `update3plCenterTX` 루프 내 단건 DML |
| 중복 조회 | `cancelRequest`의 `checkExistBizCenter` 2회 호출 |
| 미사용 코드 | `insertBiz/insertUserBiz/insertDocNo/searchBizs/reqTplBiz/deleteUserCenter/updateAllCenterTplYnToN` — Signup 잔재·주석처리 호출부 (statement별 상태는 [`mdbz01-04-be-mapper-sql.md`](mdbz01-04-be-mapper-sql.md) §3 참조) |
| 주석 흔적 | 위탁 기능이 사업장 단위→센터 단위로 재설계된 흔적 다수 (TxComp 주석 처리 코드) |

> 📎 **SQL 수준 상세:** 모든 Mapper statement의 호출 사슬·대상 테이블·활성/레거시 상태와 핵심 SQL 발췌는 데이터 접근 계층 문서 [`mdbz01-04-be-mapper-sql.md`](mdbz01-04-be-mapper-sql.md)에 정리되어 있다.
