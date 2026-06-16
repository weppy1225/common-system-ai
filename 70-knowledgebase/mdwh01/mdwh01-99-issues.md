---
title: MDWH01 Open Issues / 확인 필요 사항
description: mdwh01 창고 설계 문서화 과정에서 식별된 소스-문서 불일치·미연결 기능·정리 후보를 모은 확인/조치 레지스터.
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: task
menu_code: mdwh01
domain: master
related:
  - "70-knowledgebase/mdwh01/mdwh01-05-api.md"
  - "70-knowledgebase/mdwh01/mdwh01-04-be-mapper-sql.md"
  - "70-knowledgebase/mdwh01/mdwh01-06-be-flow.md"
tags: [open-issues, verification, master]
---

# MDWH01 Open Issues / 확인 필요 사항

## 요약

| # | 우선 | 이슈 | 근거 |
|---|---|---|---|
| 1 | 🟠 | 물리 DELETE 사용 — 소프트삭제 원칙과 상충 | Mapper.xml `deleteWhs`, `deleteLocs`, `deleteBizWhs` |
| 2 | 🟠 | 삭제 건수 판별 로직 결함 — 사업장-창고 매핑 누락 시 창고 본 테이블 미삭제 가능 | `MDWH01Dao.deleteWhs()` 내 조건 분기 |
| 3 | 🟡 | `lfn_searchMenuGroup()` 미완성 함수 — `onMounted`에서 인수 없이 호출, 실제 동작 불명 | `mdwh01Edt.vue` `onMounted` |
| 4 | 🟡 | `rpYn`(전환) 처리기능이 `checkHasAllWhFunc`의 필수 기능 목록에서 누락 | `MDWH01Comp.checkHasAllWhFunc()` |
| 5 | 🟡 | 위탁 사업장 창고 매핑 시 N+1 반복 DML | `MDWH01Comp.insertWhTX()` 위탁 사업장 반복 처리 |
| 6 | 🟡 | 주석 처리된 기능(논리창고, 보충창고, 전환처리) — 삭제 또는 구현 방향 결정 필요 | `mdwh01Edt.vue` 주석 블록 |

---

## 🟠 정책 / 정합

### ISSUE-01. 물리 DELETE 사용 — 소프트삭제 원칙과 상충

**현상**
창고 삭제 시 `MDM_WH`, `MDM_LOC`, `MDM_BIZ_WH` 테이블에 대해 `DELETE FROM` SQL이 실행된다. 소프트삭제(use_yn = 'N') 방식이 아닌 물리 삭제다.

**파급**
- 삭제된 창고를 참조하는 데이터(재고, 이력 등)가 있을 경우 참조 무결성 문제 발생 가능.
- 수불 이력(WMS_INVEN_INOUT) 외 다른 테이블에서 wh_seq를 참조하는 경우 삭제 후 고아 데이터가 생길 수 있다.
- 감사 추적(이력 관리)이 불가능해진다.

**확인 필요 항목**
- 전체 시스템에서 `wh_seq`를 참조하는 테이블 목록 확인.
- 물리 삭제가 의도된 설계인지, 아니면 소프트삭제로 전환해야 하는지 정책 결정 필요.

---

### ISSUE-02. 삭제 건수 판별 로직 결함

**현상**
`MDWH01Dao.deleteWhs()` 내에서 `deleteBizWhs` 실행 건수가 `whs.size()`보다 작으면 `deleteWhs`(창고 본 테이블 삭제)를 호출하지 않고 `bizCnt`를 반환한다. 이후 `MDWH01Comp`에서는 반환 건수와 요청 건수를 비교하여 `AlreadyProcessException`을 발생시킨다.

**파급**
- 사업장-창고 매핑이 누락된 창고(정합성 오류 데이터)가 존재할 경우, 창고 본 테이블은 남아 있는데 `AlreadyProcessException`이 발생하는 상황이 된다.
- 실제로는 창고가 삭제되지 않았으나 오류 메시지는 "이미 처리되었습니다"로 표시되어 운영자가 혼란을 겪을 수 있다.

**확인 필요 항목**
- 사업장-창고 매핑이 없는 창고 데이터가 실제 DB에 존재하는지 확인.
- 삭제 조건 판별 로직(bizCnt 비교) 재검토 필요.

---

## 🟡 정리 / 개선

### ISSUE-03. `lfn_searchMenuGroup()` 미완성 함수

**현상**
`mdwh01Edt.vue`의 `onMounted`에서 `lfn_searchMenuGroup()` 함수가 인수 없이 호출된다. 함수 내부에서는 `axios.get('/mdus01/users/groups/${userId}')`를 호출하는데, `userId`가 `undefined`로 전달되어 실제 API 호출 시 `/mdus01/users/groups/undefined` 경로로 요청이 발생한다.

**파급**
- API 호출 오류가 발생하더라도 `catch`에서 `errorSwal(error)`로 처리되어 화면에 오류가 표시될 수 있다.
- 권한그룹 선택 필드가 주석 처리된 상태로 폼에 미표시되므로, 현재는 기능상 영향이 없을 수 있으나 불필요한 API 호출이 매 팝업 오픈 시 발생한다.

**확인 필요 항목**
- 권한그룹 기능이 폼에서 제거(주석)된 상태이므로 `onMounted`의 `lfn_searchMenuGroup()` 호출도 함께 제거하거나, 기능 구현 완료 후 정상 연결 필요.

---

### ISSUE-04. `rpYn`(전환) 처리기능이 필수 기능 보장 목록에서 누락

**현상**
`MDWH01Comp.checkHasAllWhFunc()`에서 기능별 창고 최소 1개 존재 검증 시 확인하는 처리기능 목록은 `inYnCnt, pickYnCnt, outYnCnt, etcYnCnt, returnYnCnt` 5가지다. `stYnCnt`(세트작업)와 `rpYnCnt`(전환)는 이 목록에서 제외되어 있다.

**파급**
- 전환 기능을 가진 마지막 창고를 삭제하거나 기능을 제거해도 서버에서 차단되지 않는다.
- 세트작업 역시 동일하게 보호되지 않는다.

**확인 필요 항목**
- 전환(`rpYn`)과 세트작업(`stYn`) 기능이 최소 1개 창고 보장 대상인지 업무 정책 확인 필요.
- 정책상 보장 대상이면 `checkHasAllWhFunc()`의 검증 목록에 추가해야 한다.

---

### ISSUE-05. 위탁 사업장 창고 매핑 시 N+1 반복 DML

**현상**
`MDWH01Comp.insertWhTX()`에서 위탁 사업장 목록을 조회한 후 for 루프로 각 사업장마다 `insertbizWh()`를 개별 호출한다.

**파급**
- 위탁 사업장이 다수인 경우 DB 왕복이 사업장 수만큼 증가하여 성능 저하 가능.

**확인 필요 항목**
- 위탁 사업장 수가 통상 적은 수준이면 현재 구현으로 충분.
- 위탁 사업장이 많은 경우 배치 INSERT(bulk insert)로 개선 고려.

---

### ISSUE-06. 주석 처리된 기능 — 구현 방향 결정 필요

**현상**
`mdwh01Edt.vue`에서 아래 기능들이 주석 처리된 상태다.
- 논리창고(logicWhYn) 라디오 버튼
- 보충창고 설정(replCd) 드롭다운
- 전환처리(rpYn) 체크박스

**파급**
- `initEditWhObj`에는 `logicWhYn`, `replCd` 등 필드가 선언되어 있으나 화면에서 입력받지 않는다.
- `lfn_setGroupWh()`에서 `logicWhYn`을 자동 설정하는 코드가 있으나 화면에서 실제로 사용되지 않는다.

**확인 필요 항목**
- 논리창고·보충창고·전환처리 기능이 향후 구현될 예정인지, 아니면 영구 제거 대상인지 정책 결정 필요.
- 영구 제거 대상이면 관련 코드(initEditWhObj 필드, lfn_setGroupWh 내 logicWhYn 설정, mdwh01Com.js)도 함께 정리 필요.

---

> 본 레지스터는 소스를 수정하지 않는다.
