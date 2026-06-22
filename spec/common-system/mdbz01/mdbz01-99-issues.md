---
title: MDBZ01 Open Issues / 확인 필요 사항
description: mdbz01 사업장 설계 문서화 과정에서 식별된 소스-문서 불일치·미연결 기능·정리 후보를 모은 확인/조치 레지스터.
status: active
version: 1.0.0
wms_meta: true
repo_role: ai-hub
agent_usage: task
menu_code: mdbz01
domain: master
related:
  - "spec/common-system/mdbz01/mdbz01-05-api.md"
  - "spec/common-system/mdbz01/mdbz01-04-be-mapper-sql.md"
  - "spec/common-system/mdbz01/mdbz01-06-be-flow.md"
tags:
  - open-issues
  - verification
  - master
---

# MDBZ01 Open Issues / 확인 필요 사항

## 요약

| # | 우선 | 이슈 | 근거 |
|---|---|---|---|
| 1 | 🔴 (높음) | Controller 엔드포인트 3건 Vue 미연결 | tplReq GET, tplReq PATCH, cancel PATCH — 3개 Vue 파일 어디에도 호출 미확인 |
| 2 | 🔴 (높음) | `vfn_searchCenterDtl` 미정의 함수 호출 | mdbz01.vue `lfn_reqGridKeydown`에서 호출하나 함수 정의 없음 |
| 3 | 🟠 (중간) | cancelRequest 동일 쿼리 2회 호출 | MDBZ01Comp.cancelRequest에서 checkExistBizCenter 연속 2회 호출 |
| 4 | 🟠 (중간) | for 루프 내 단건 DML 반복 (N+1) | insertCenter, updateCenter, deleteCenter, reqTplCenterTX, update3plCenterTX |
| 5 | 🟠 (중간) | searchBizs SQL — Dao/Mapper 호출자 없음 | Mapper.xml에 정의되어 있으나 MDBZ01Mapper.java에 인터페이스 메서드 없음 |
| 6 | 🟠 (중간) | 사업장 수정 @PostMapping (REST 관례 불일치) | 실제 구현은 POST 사용, multipart 전송 목적 여부는 미확인 |
| 7 | 🟠 (중간) | Controller 메서드명 오류 (`postBizCenters`) | @GetMapping인데 메서드명 'post'로 시작 |
| 8 | 🟡 (낮음) | MDBZ01Request 클래스 미사용 | bean 폴더에 존재하지만 어디서도 사용 확인 안 됨 |
| 9 | 🟡 (낮음) | 주석 처리된 위탁 관련 코드 | updateBizTX, updateBiz Comp에 위탁 관련 코드 주석 처리됨 |
| 10 | 🟡 (낮음) | insertBiz/insertUserBiz/insertDocNo — 이 화면 미사용 SQL | 회원가입 흐름용으로 보이나 다른 모듈과 공유 여부 확인 필요 |
| 11 | 🟡 (낮음) | reqTplBiz SQL — 호출자 확인 필요 | Mapper.xml 정의 존재, Dao/Mapper 인터페이스 미확인 |

---

## 🔴 (높음) 기능 공백

### ISSUE-01: Controller 엔드포인트 3건 Vue 미연결

**현상:**
`MDBZ01Controller.java`에 다음 3개 엔드포인트가 존재하지만, `mdbz01.vue`, `mdbz01Set.vue`, `mdbz01Sch.vue` 세 Vue 파일 어디에서도 해당 API 호출이 확인되지 않는다.

- `GET /{bizSeq}/mdbz01/bizs/{selCenterSeq}/tplReq` → `selectReqBizCenter`
- `PATCH /{bizSeq}/mdbz01/bizs/{selBizSeq}/tplReq` → `respTplCenter`
- `PATCH /{bizSeq}/mdbz01/bizs/cancel` → `cancelRequest`

**파급:**
- 위탁 의뢰 수락/거절 기능(`respTplCenter`)과 의뢰 취소 기능(`cancelRequest`)이 화면에서 접근 불가 상태일 수 있다.
- 단, 조사 범위가 mdbz01 폴더의 3개 파일에 한정되어 있어 다른 화면에서 호출하는지 확인 필요.

**확인 필요 항목:**
- 전체 Vue 소스에서 `/tplReq` 및 `/cancel` 경로 호출 여부 전수 검색
- 위탁 의뢰 수락/거절 UI가 어느 화면에 있는지 확인
- 의뢰 취소 UI 존재 여부 확인

---

### ISSUE-02: `vfn_searchCenterDtl` 미정의 함수 호출

**현상:**
`mdbz01.vue`의 `lfn_reqGridKeydown` 함수에서 엔터 키 입력 시 `vfn_searchCenterDtl(selectedRows[0])`을 호출하지만, 이 함수는 `mdbz01.vue` 내에 정의되어 있지 않다.

**파급:**
그리드에서 엔터 키를 누르면 `ReferenceError: vfn_searchCenterDtl is not defined` 오류가 발생한다.

**확인 필요 항목:**
- `vfn_searchCenterDtl` 함수가 부모 컴포넌트나 전역에 정의되어 있는지 확인
- 해당 기능이 실제로 필요한지, 제거 대상인지 확인

---

## 🟠 (중간) 정책 / 정합

### ISSUE-03: cancelRequest — 동일 쿼리 2회 호출

**현상:**
`MDBZ01Comp.cancelRequest`에서 `mdbzDao.checkExistBizCenter(postCenter)`를 두 줄 연속으로 호출한다. 첫 번째는 레코드 존재 확인, 두 번째는 상태 값(REQUEST) 확인인데, 첫 번째 결과를 재사용하지 않고 동일 쿼리를 재실행한다.

**파급:**
불필요한 DB 조회 1회 발생. 건수가 많지 않아 현재는 무해하나 코드 의도 파악이 어렵다.

**확인 필요 항목:**
첫 번째 결과 리스트를 재사용하는 방향으로 리팩토링 필요 여부 확인.

---

### ISSUE-04: for 루프 내 단건 DML 반복 (N+1)

**현상:**
다음 메서드들에서 리스트 크기만큼 단건 INSERT/UPDATE/DELETE가 반복 호출된다:
- `insertCenter`: 센터 1건당 6회 DML (center, biz_center, user_center, wh×N, biz_wh×N, loc×N)
- `updateCenter`, `deleteCenter`: 건수만큼 반복
- `reqTplCenterTX`, `update3plCenterTX`: 건수만큼 반복

**파급:**
센터 수가 적은 일반적 사용에서는 영향 미미. 하지만 대량 등록 시 성능 저하 가능성 있음.

**확인 필요 항목:**
운영 환경에서 1회 저장 시 평균 센터 처리 건수 파악 후 배치 처리 전환 여부 결정.

---

### ISSUE-05: searchBizs SQL — 호출자 없음

**현상:**
`MDBZ01Mapper.xml`에 `searchBizs` SELECT SQL이 정의되어 있으나, `MDBZ01Mapper.java` 인터페이스와 `MDBZ01Dao.java` 모두에서 해당 메서드가 확인되지 않는다.

**파급:**
현재 기능에 영향 없음. Dead SQL로 코드 혼란을 야기할 수 있다.

**확인 필요 항목:**
- 다른 Mapper나 클래스에서 namespacing으로 직접 호출하는지 확인
- 사용하지 않는다면 제거 검토

---

### ISSUE-06: 사업장 수정 @PostMapping (HTTP 메서드 불일치)

**현상:**
`MDBZ01Controller.patchBiz` 메서드가 `@PostMapping`으로 선언되어 있다. 기능은 사업장 수정(Update)이나 POST를 사용하고 있다. 메서드명이 `patchBiz`임에도 불구하고 실제 어노테이션은 `@PostMapping`이다. multipart/form-data 전송 목적 여부는 소스상 미확인이다.

**파급:**
기능 동작에는 영향 없으나 API 명세 이해 혼란 야기.

**확인 필요 항목:**
의도적 선택인지 실수인지 확인. 유지한다면 주석 설명 추가.

---

### ISSUE-07: Controller 메서드명 오류

**현상:**
`MDBZ01Controller.postBizCenters` 메서드가 `@GetMapping("{selectedBizSeq}/centers")`로 선언되어 있으나 메서드명이 `post`로 시작한다.

**파급:**
기능 동작에는 영향 없으나 코드 가독성 저하.

**확인 필요 항목:**
`getBizCenters` 등으로 메서드명 변경 검토.

---

## 🟡 (낮음) 정리 / 개선

### ISSUE-08: MDBZ01Request 클래스 미사용

**현상:**
`be.md8000.mdbz01.bean.MDBZ01Request` 클래스가 존재하지만 Controller, Comp, TxComp, Dao 어디에서도 사용이 확인되지 않는다.

**파급:**
현재 기능에 영향 없음. 불필요한 코드 잔존.

**확인 필요 항목:**
전체 소스에서 `MDBZ01Request` 사용 여부 확인 후 미사용 시 제거.

---

### ISSUE-09: 주석 처리된 위탁 관련 코드

**현상:**
다음 두 위치에서 위탁 관련 코드가 주석 처리되어 있다:

1. `MDBZ01Comp.updateBiz`: 위탁업체 존재 시 사업장 수정 차단 로직 주석 처리
2. `MDBZ01TxComp.updateBizTX`: 자사물류로 변경 시 모든 센터 물류대행여부를 N으로 일괄 변경 로직 주석 처리

"위탁 미사용으로 인해 주석 처리"라는 설명이 있으며 관련 Dao 메서드(`updateAllCenterTplYnToN`)와 Mapper SQL도 여전히 존재한다.

**파급:**
현재 기능에 영향 없음. 코드 이해 혼란 가능성.

**확인 필요 항목:**
위탁 기능이 완전히 제거된 것인지, 또는 향후 재사용 예정인지 확인. 완전 제거라면 관련 코드(Dao 메서드, Mapper SQL) 함께 정리 검토.

---

### ISSUE-10: 이 화면 미사용 SQL (회원가입 관련)

**현상:**
`MDBZ01Mapper.xml`에 `insertBiz`, `insertUserBiz`, `insertDocNo` SQL이 정의되어 있다. 이 화면(MDBZ01)에서는 호출되지 않으며, 회원가입 처리 플로우에서 사용되는 것으로 추정된다.

**파급:**
기능 영향 없음. 다른 Mapper와 코드 분리가 되어 있지 않아 이 메뉴의 Mapper에 다른 도메인 SQL이 혼재하는 상황.

**확인 필요 항목:**
회원가입 관련 SQL을 별도 Mapper(예: SignupMapper)로 분리하거나, 의도적으로 MDBZ01Mapper를 공유하는지 확인.

---

### ISSUE-11: reqTplBiz SQL — 호출자 확인

**현상:**
`MDBZ01Mapper.xml`에 `reqTplBiz` SELECT SQL이 정의되어 있다. 의뢰 사업장 목록을 조회하는 SQL로 보이나, `MDBZ01Mapper.java` 인터페이스에서 메서드 정의 여부와 Dao 호출자 존재 여부가 확인되지 않는다.

**파급:**
현재 기능에 영향 없음.

**확인 필요 항목:**
MDBZ01Mapper 인터페이스에서 `reqTplBiz` 메서드 존재 여부 확인. 없다면 Dead SQL.

---

> 본 레지스터는 소스를 수정하지 않는다. 확인 및 조치는 개발팀의 판단에 따른다.
