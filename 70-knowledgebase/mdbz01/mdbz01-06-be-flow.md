---
title: MDBZ01 BE 구현 흐름 (서버 처리)
description: mdbz01 사업장의 API별 백엔드 컴포넌트 시퀀스 다이어그램과 메뉴 고유 예외·이슈를 기술.
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: spec
menu_code: mdbz01
domain: master
depends_on:
  - "70-knowledgebase/_common/be-architecture.md"
  - "70-knowledgebase/_common/be-exceptions.md"
  - "70-knowledgebase/mdbz01/mdbz01-05-api.md"
  - "70-knowledgebase/mdbz01/mdbz01-04-be-mapper-sql.md"
tags: [detail-design, backend, sequence, master]
---

# MDBZ01 BE 구현 흐름 (서버 처리)

## 1. API별 시퀀스 다이어그램

---

### GET /{bizSeq}/mdbz01/bizs/editable/bizs/{regBizSeq} — 수정 가능 사업장 목록 조회

```
Controller          Comp                    Dao
     │                │                      │
     │─ searchEditableBizs() ──────────────>  │
     │                │                      │
     │                │─ searchEditableBizs() ─────────────────>│
     │                │  (권한 유형에 따라 SQL 분기)            │
     │                │  [슈퍼: 전체 / 사업장: 소속 사업장 /    │
     │                │   센터: 소속 센터의 사업장]             │
     │                │  [화주 구분 사업장은 항상 제외]          │
     │                │<────────────────────────────────────────│
     │                │  bizList 반환                           │
     │<───────────────│                                         │
```

---

### GET /{bizSeq}/mdbz01/bizs/{selectedBizSeq} — 사업장 단건 조회

```
Controller          Comp                    Dao
     │                │                      │
     │─ getBizs() ──>│                       │
     │                │─ selectBiz() ───────>│
     │                │<────────────────────-│  biz 반환
     │                │  [로고 파일 번호 있으면]
     │                │─ 파일 경로를 URL로 변환 (내부 처리)
     │<───────────────│  biz 반환            │
```

---

### POST /{bizSeq}/mdbz01/bizs — 사업장 기본정보 수정

```
Controller          Comp                TxComp              Dao / FileComp
     │                │                    │                      │
     │─ patchBiz() ──>│                    │                      │
     │  (modId 자동 설정)                  │                      │
     │                │─ updateBiz() ────>│                       │
     │                │  기존 사업장 조회  │                       │
     │                │──────────────────────────────────────────>│ selectBiz
     │                │<──────────────────────────────────────────│ exBiz 반환
     │                │                    │                      │
     │                │─ updateBizTX() ──>│                       │
     │                │                   │                       │
     │                │  [신규 파일 있는 경우]                     │
     │                │                   │─ 기존 파일 삭제 ─────>│ FileComp.deleteFileBizImg
     │                │                   │─ 신규 파일 업로드 ───>│ FileComp.uploadFile
     │                │                   │  fileSeq 획득         │
     │                │                   │                       │
     │                │  [파일 삭제 요청 경우]                     │
     │                │                   │─ 기존 파일 삭제 ─────>│ FileComp.deleteFileBizImg
     │                │                   │  logoFileSeq = null   │
     │                │                   │                       │
     │                │                   │─ updateBiz() ────────>│ MDM_BIZ UPDATE
     │                │                   │<──────────────────────│ retCnt 반환
     │                │<─── retCnt ───────│                       │
     │<───────────────│  procCnt 반환     │                       │
```

---

### GET /{bizSeq}/mdbz01/bizs/{selectedBizSeq}/centers — 사업장 센터 목록 조회

```
Controller          Comp                    Dao
     │                │                      │
     │─ postBizCenters() ─────────────────>  │
     │                │                      │
     │                │─ selectBizCenter() ─>│
     │                │  (bizSeq, regBizSeq) │
     │                │<─────────────────────│  bizCenter 목록 반환
     │                │  (editableYn, tplCenterYn, authCnt 등 계산됨)
     │<───────────────│                       │
```

---

### PUT /{bizSeq}/mdbz01/bizs/centers — 물류센터 저장 (추가·수정·삭제)

```
Controller          Comp                TxComp              Dao
     │                │                    │                  │
     │─ saveBizCenters() ─────────────────>│                  │
     │                │                    │                  │
     │                │─ saveBizCenter() ─>│                  │
     │                │  필수값 검증 (물류대행 여부=Y이면 주소·전화번호 필수)
     │                │  [검증 실패 → ZinBadRequestException]  │
     │                │                    │                  │
     │                │─ saveBizCenterTX() ─────────────────>│  (트랜잭션 시작)
     │                │                   │                  │
     │                │  [추가 목록 있는 경우]                 │
     │                │                   │─ 중복명 체크 ────>│ checkDuplicateCenterNm
     │                │                   │  [중복 → ZinExistDataException]
     │                │                   │─ insertCenter ───>│ MDM_CENTER INSERT
     │                │                   │─ insertBizCenter ─>│ MDM_BIZ_CENTER INSERT
     │                │                   │─ insertCenterAutorityToSuper ─>│ MDM_USER_CENTER INSERT
     │                │                   │─ 기본창고 생성 loop [템플릿 창고 수만큼 반복]
     │                │                   │  │─ insertDefaultWh ─>│ MDM_WH INSERT
     │                │                   │  │─ insertbizWh ─────>│ MDM_BIZ_WH INSERT
     │                │                   │  │─ insertDefaultLoc ─>│ MDM_LOC INSERT
     │                │                   │                  │
     │                │  [수정 목록 있는 경우]                 │
     │                │                   │─ loop [수정 건수만큼 반복]
     │                │                   │  │─ 중복명 체크 ──>│ checkDuplicateCenterNm
     │                │                   │  │  [중복 → AlreadyProcessException]
     │                │                   │  │─ 위탁업체 존재 체크 ─>│ checkExistTplBizCenter
     │                │                   │  │  [존재 → AlreadyProcessException]
     │                │                   │  │─ updateBizCenter ─>│ MDM_BIZ_CENTER UPDATE
     │                │                   │  └─ updateCenter ────>│ MDM_CENTER UPDATE
     │                │                   │                  │
     │                │  [삭제 목록 있는 경우]                 │
     │                │                   │─ 권한 사용자 존재 체크 ─>│ checkExistUserCenter
     │                │                   │  [존재 → AlreadyProcessException]
     │                │                   │─ 위탁업체 존재 체크 ─>│ checkExistTplBizCenter
     │                │                   │  [존재 → AlreadyProcessException]
     │                │                   │─ 창고 존재 체크 ──>│ checkExistCenterWh
     │                │                   │  [존재 → AlreadyProcessException]
     │                │                   │─ loop [삭제 건수만큼 반복]
     │                │                   │  │─ deleteBizCenter ─>│ MDM_BIZ_CENTER 소프트삭제
     │                │                   │  │─ deleteCenter ────>│ MDM_CENTER 소프트삭제
     │                │                   │  └─ deleteCenterAutority ─>│ MDM_USER_CENTER DELETE
     │                │                   │                  │
     │                │                   │─ 저장 후 사용 센터 존재 확인 ─>│ selectBizCenter
     │                │                   │  [사용 센터 없음 → NotMeetConditionsException]
     │<───────────────│<──────────────────│                  │  (트랜잭션 종료)
```

---

### GET /{bizSeq}/mdbz01/bizs/tpl — 자사 위탁 센터 목록 조회 (MDBZ01P01)

```
Controller          Comp                    Dao
     │                │                      │
     │─ selectTplBizCenter() ─────────────>  │
     │                │─ selectTplBizCenter() ──────────────>│
     │                │<─────────────────────────────────────│ bizCenter 목록 반환
     │                │  (자사 등록 센터, tplCenterYn=N인 것만)
     │<───────────────│                       │
```

---

### PATCH /{bizSeq}/mdbz01/bizs/tpl — 위탁 센터 정보 수정 (MDBZ01P01)

```
Controller          Comp                TxComp              Dao
     │                │                    │                  │
     │─ update3plCenter() ────────────────>│                  │
     │                │─ update3plCenter() ─────────────────>│
     │                │                   │─ loop [수정 목록 반복]
     │                │                   │  └─ updateTplCenter ─>│ MDM_CENTER UPDATE
     │                │                   │     (tplYn, 주소, 전화번호 업데이트)
     │<───────────────│<──────────────────│                  │
```

---

### POST /{bizSeq}/mdbz01/bizs/tpl — 물류대행업체 검색 (MDBZ01P02)

```
Controller          Comp                    Dao
     │                │                      │
     │─ get3plBizCenters() ───────────────>  │
     │                │                      │
     │                │  (userId 자동 설정)   │
     │                │─ searchTplBizCenter() ──────────────>│
     │                │  [물류대행 여부=Y, 사업장구분=TPL,     │
     │                │   자사 사업장 제외, 사용 중 센터만]    │
     │                │  (reqSts: 신청 가능/신청중/승인/거절)  │
     │                │<─────────────────────────────────────│ bizCenter 목록 반환
     │<───────────────│                       │
```

---

### PUT /{bizSeq}/mdbz01/bizs/tpl — 위탁 의뢰 신청 (MDBZ01P02)

```
Controller          Comp                TxComp              Dao
     │                │                    │                  │
     │─ reqTplCenter() ───────────────────>│                  │
     │                │─ reqTplCenter() ──>│                  │
     │                │                   │─ reqTplCenterTX() ─> (트랜잭션 시작)
     │                │                   │─ loop [선택한 센터 수만큼 반복]
     │                │                   │  │─ 사업장-사업장 관계 존재 확인 ─>│ checkExistBizBiz
     │                │                   │  │  [없으면] ─ insertBizBiz ──────>│ MDM_BIZ_BIZ INSERT
     │                │                   │  │─ 사업장-센터 관계 존재 확인 ────>│ checkExistBizCenter
     │                │                   │  │  [ACCEPT/REQUEST → AlreadyProcessException]
     │                │                   │  │  [DENIED → updateBizCenter (재신청)]
     │                │                   │  │  [없으면] → insertBizCenter ───>│ MDM_BIZ_CENTER INSERT
     │                │                   │                  │
     │<───────────────│<──────────────────│                  │  (트랜잭션 종료)
```

---

### 🟠 GET /{bizSeq}/mdbz01/bizs/{selCenterSeq}/tplReq — 대행의뢰신청업체 조회 (FE 미연결)

```
Controller          Comp                    Dao
     │                │                      │
     │─ postReqBizCenters() ──────────────>  │
     │                │─ selectReqBizCenter() ──────────────>│
     │                │<─────────────────────────────────────│ bizCenter 목록 반환
     │<───────────────│                       │
```

---

### 🟠 PATCH /{bizSeq}/mdbz01/bizs/{selBizSeq}/tplReq — 대행의뢰 수락/거절 (FE 미연결)

```
Controller          Comp                TxComp              Dao
     │                │                    │                  │
     │─ respTplCenterTX() ────────────────>│                  │
     │                │─ respTplCenter() ─>│                  │
     │                │  bizCenter 존재 확인                  │
     │                │──────────────────────────────────────>│ checkExistBizCenter
     │                │  [없으면 → AlreadyProcessException]   │
     │                │  [cfmYn=N이면 Y로 변경]               │
     │                │                   │─ respTplCenterTX() ─> (트랜잭션 시작)
     │                │                   │─ respTplCenter ───>│ MDM_BIZ_CENTER UPDATE
     │                │                   │─ updateBizBiz ────>│ MDM_BIZ_BIZ UPDATE
     │                │                   │  [수락(useYn=Y)이면]
     │                │                   │─ insertBizWh ─────>│ MDM_BIZ_WH INSERT
     │<───────────────│<──────────────────│                  │  (트랜잭션 종료)
```

---

### 🟠 PATCH /{bizSeq}/mdbz01/bizs/cancel — 의뢰 취소 (FE 미연결)

```
Controller          Comp                TxComp              Dao
     │                │                    │                  │
     │─ cancelRequest() ──────────────────>│                  │
     │                │─ cancelRequest() ─>│                  │
     │                │  bizCenter 존재 확인                  │
     │                │──────────────────────────────────────>│ checkExistBizCenter
     │                │  [없으면 → AlreadyProcessException]   │
     │                │  [상태가 REQUEST가 아니면 → AlreadyProcessException]
     │                │                   │─ cancelRequestTX() ─> (트랜잭션 시작)
     │                │                   │─ cancelRequest ───>│ MDM_BIZ_CENTER DELETE
     │<───────────────│<──────────────────│                  │  (트랜잭션 종료)
```

---

## 2. 예외 처리 목록 (메뉴 고유)

| 조건 | 예외 유형 | 메시지 키 | 결과 |
|---|---|---|---|
| 사업장명이 비어 있음 | ZinBadRequestException | 프론트엔드 검증 처리 (서버 미검증) | 저장 거부 |
| 물류대행 여부=사용 상태에서 주소·주소상세·전화번호 중 하나라도 비어 있음 | ZinBadRequestException | message.md8000.mdbz01.RequiredAddressAndPhone | 센터 저장 거부 |
| 센터명이 동일 사업장 내에서 중복됨 | ZinExistDataException | message.md8000.mdbz01.DuplicatedCenterNm | 센터 추가/수정 거부 |
| 저장 후 사용 중인 센터가 하나도 없음 | NotMeetConditionsException | message.md8000.mdbz01.NoCenterUsed | 센터 저장 롤백 |
| 삭제 대상 센터에 일반 사용자 권한이 존재함 | AlreadyProcessException | message.md8000.mdbz01.ExistUserCenter | 센터 삭제 거부 |
| 삭제 또는 비활성화 대상 센터에 위탁 계약이 존재함 | AlreadyProcessException | message.md8000.mdbz01.ExistTplBizCenter | 센터 삭제/수정 거부 |
| 삭제 대상 센터에 창고가 연결되어 있음 | AlreadyProcessException | message.md8000.mdbz01.ExistCenterWh | 센터 삭제 거부 |
| 위탁 의뢰 수락/거절 시 대상 bizCenter 데이터가 없음 | AlreadyProcessException | message.error.NotFound | 처리 거부 |
| 이미 ACCEPT 또는 REQUEST 상태인 센터에 재의뢰 신청 | AlreadyProcessException | message.warn.AlreadyProcess | 의뢰 신청 거부 |
| REQUEST 상태가 아닌 의뢰를 취소 시도 | AlreadyProcessException | message.warn.AlreadyProcess | 취소 거부 |

---

## 3. 기술 이슈

### 이슈 1: cancelRequest에서 물리 DELETE 사용

- **현상**: `cancelRequest` SQL이 `DELETE FROM MDM_BIZ_CENTER`를 사용한다. 다른 센터 삭제 처리(`deleteCenter`, `deleteBizCenter`)는 소프트삭제(use_yn='N')를 사용하는 것과 불일치.
- **영향**: 의뢰 취소된 기록이 완전히 사라지므로 이력 추적 불가. 재신청 시 거절 이력 조회가 불필요하게 복잡해질 수 있음.

### 이슈 2: 센터 수정 루프 내 반복 DB 조회

- **현상**: 수정 목록의 각 센터에 대해 중복명 체크, 위탁업체 존재 체크를 루프 내에서 건별 실행한다.
- **영향**: 수정 건수가 많을수록 DB 왕복 횟수 비례 증가 (N+1 패턴).

### 이슈 3: 주석 처리된 로직 잔재

- **현상**: `updateBiz`에서 사업장 구분 변경 시 모든 센터 물류대행 여부 일괄 해제 로직이 주석 처리됨. `updateAllCenterTplYnToN` Dao 메서드와 Mapper SQL은 여전히 존재.
- **영향**: 소스 코드와 실제 동작 간의 불일치. 향후 혼란 가능성.

### 이슈 4: Mapper.xml에 Dao 호출자 없는 statement 다수 존재

- 상세 내용은 `mdbz01-04-be-mapper-sql.md` 참조.
