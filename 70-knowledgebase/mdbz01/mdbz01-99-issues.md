---
title: MDBZ01 Open Issues / 확인 필요 사항
description: mdbz01 사업장 설계 문서화 과정에서 식별된 소스-문서 불일치·미연결 기능·정리 후보를 모은 확인/조치 레지스터.
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: task
menu_code: mdbz01
domain: master
related:
  - "70-knowledgebase/mdbz01/mdbz01-05-api.md"
  - "70-knowledgebase/mdbz01/mdbz01-04-be-mapper-sql.md"
  - "70-knowledgebase/mdbz01/mdbz01-06-be-flow.md"
tags: [open-issues, verification, master]
---

# MDBZ01 Open Issues / 확인 필요 사항

## 요약

| # | 우선 | 이슈 | 근거 |
|---|---|---|---|
| 1 | 🔴 | 대행의뢰 수락/거절/취소 기능이 FE에서 호출되지 않음 | Controller 3개 엔드포인트가 Vue 어느 파일에서도 호출되지 않음 |
| 2 | 🔴 | mdbz01Set.vue, mdbz01Sch.vue가 mdbz01.vue에 마운트되지 않음 | mdbz01.vue에 import 및 ref 선언 없음 |
| 3 | 🔴 | searchBizs, insertBiz, insertUserBiz, insertDocNo, reqTplBiz, deleteUserCenter SQL이 Dao에서 미호출 | Mapper.xml에 statement 존재, Dao 또는 Mapper 인터페이스에 선언 없거나 호출 없음 |
| 4 | 🟠 | cancelRequest가 물리 DELETE 사용 — 소프트삭제 원칙 불일치 | `DELETE FROM MDM_BIZ_CENTER` 확인 |
| 5 | 🟠 | 사업장 구분 변경 연동 로직 주석 처리 — 코드와 동작 불일치 | `updateAllCenterTplYnToN` 관련 코드 전체 주석 처리 |
| 6 | 🟡 | 센터 수정·삭제 루프 내 반복 DB 조회 (N+1 패턴) | updateCenter, deleteCenter 처리 loop 내 체크 쿼리 반복 |
| 7 | 🟡 | Mapper.xml에 Dead SQL 다수 존재 | searchBizs, insertBiz, insertUserBiz, insertDocNo, reqTplBiz, deleteUserCenter |
| 8 | 🟡 | checkExistBizCenter에서 cancelRequest 시 같은 쿼리를 2번 호출 | cancelRequest 메서드 내 `checkExistBizCenter` 두 번 연속 호출 |

---

## 🔴 기능 공백

### 이슈 1: 대행의뢰 수락/거절/취소 기능이 FE에서 사용되지 않음

| 항목 | 내용 |
|---|---|
| 현상 | `GET /{bizSeq}/mdbz01/bizs/{selCenterSeq}/tplReq`, `PATCH /{bizSeq}/mdbz01/bizs/{selBizSeq}/tplReq`, `PATCH /{bizSeq}/mdbz01/bizs/cancel` 세 엔드포인트가 Controller에 존재하지만, mdbz01.vue / mdbz01Set.vue / mdbz01Sch.vue 어디에서도 axios 호출이 없음 |
| 파급 | 대행의뢰를 신청할 수는 있지만 (MDBZ01P02), 대행업체 측에서 수락/거절하거나 의뢰자가 신청을 취소하는 기능이 현재 화면에서 작동하지 않음 |
| 확인 필요 | 이 기능이 다른 메뉴(예: 대행업체 전용 화면)에서 처리되는지, 아니면 MDBZ01 화면에서 구현 예정인지 확인 필요 |

### 이슈 2: MDBZ01P01, MDBZ01P02 팝업이 메인 화면에 마운트되지 않음

| 항목 | 내용 |
|---|---|
| 현상 | mdbz01Set.vue(MDBZ01P01)와 mdbz01Sch.vue(MDBZ01P02)는 `defineExpose`로 `openPopup`을 노출하고 있으나, mdbz01.vue에서 이 두 컴포넌트를 import하거나 템플릿에 배치하는 코드가 없음. mdbz01.vue에 `searchTplPopUp = ref()`만 선언되어 있고 실제 컴포넌트와 연결되어 있지 않음 |
| 파급 | 현재 메인 화면에서 대행의뢰센터 정보수정(MDBZ01P01)과 물류대행업체 검색(MDBZ01P02) 팝업을 열 방법이 없음 |
| 확인 필요 | 팝업을 여는 버튼 및 컴포넌트 연결이 누락된 것인지, 별도 구조로 처리하는지 확인 필요 |

### 이슈 3: Mapper.xml에 정의되었으나 Dao 호출자가 없는 SQL (Dead SQL)

| SQL명 | 유형 | 비고 |
|---|---|---|
| searchBizs | SELECT | Dao에 대응 메서드 없음. 사업장 검색 기능으로 추정 |
| insertBiz | INSERT | Dao에 대응 메서드 없음. 사업장 신규 등록으로 추정 |
| insertUserBiz | INSERT | Dao에 대응 메서드 없음. 사용자-사업장 권한 등록으로 추정 |
| insertDocNo | INSERT | Dao에 대응 메서드 없음. 문서번호 초기화로 추정 |
| reqTplBiz | SELECT | Dao에 대응 메서드 없음. 위탁 의뢰 사업장 목록으로 추정 |
| deleteUserCenter | DELETE | Mapper 인터페이스에 선언은 있으나 Dao 및 TxComp에서 호출 없음 |

| 항목 | 내용 |
|---|---|
| 현상 | 위 SQL들이 Mapper.xml에 정의되어 있으나 실제로 호출되는 경로가 없음 |
| 파급 | 유지보수 혼란 및 미사용 코드 증가. 사업장 신규 등록 기능이 다른 경로(예: 가입 프로세스)에서 처리되는지 파악 불가 |
| 확인 필요 | 사업장 신규 등록이 SignupMapper 등 별도 경로에서 처리되는지 확인 필요. 완전히 미사용이라면 정리 검토 |

---

## 🟠 정책 / 정합

### 이슈 4: cancelRequest에서 물리 DELETE 사용 — 소프트삭제 원칙 불일치

| 항목 | 내용 |
|---|---|
| 현상 | 의뢰 취소 처리 시 `DELETE FROM MDM_BIZ_CENTER`를 실행하여 데이터를 물리적으로 삭제함. 반면 동일한 MDM_BIZ_CENTER 테이블의 센터 삭제(`deleteBizCenter`)는 `use_yn='N'`으로 소프트삭제 처리함 |
| 파급 | 취소된 의뢰 이력이 복구 불가능하게 삭제됨. 감사(audit) 추적 불가. 동일 테이블의 두 가지 삭제 방식이 혼재하여 운영 혼란 가능성 |
| 확인 필요 | 의도적인 설계(의뢰 취소는 이력 남기지 않음)인지, 아니면 소프트삭제 방식으로 변경해야 하는지 정책 확인 |

### 이슈 5: 사업장 구분 변경 연동 로직이 주석 처리됨

| 항목 | 내용 |
|---|---|
| 현상 | `updateBizTX`에서 사업장 구분이 물류대행→자사물류로 변경될 때 모든 센터의 물류대행 여부를 자동으로 N으로 변경하는 로직이 주석 처리됨. `updateBiz`에서도 위탁업체 존재 여부 검증 로직이 주석 처리됨. Dao 및 Mapper에는 관련 메서드(`updateAllCenterTplYnToN`)가 여전히 존재함 |
| 파급 | 사업장 구분을 변경해도 센터의 물류대행 여부가 연동되지 않아 데이터 불일치 발생 가능. Dao 메서드는 존재하지만 호출되지 않아 Dead Code 상태 |
| 확인 필요 | 물류대행→자사물류 전환 기능 자체가 비활성화된 것인지(고객문의를 통해서만 변경), 아니면 향후 복원 예정인지 확인 |

---

## 🟡 정리 / 개선

### 이슈 6: 센터 수정·삭제 처리에서 루프 내 반복 DB 조회 (N+1)

| 항목 | 내용 |
|---|---|
| 현상 | 수정 목록(`updateList`)의 각 센터에 대해 루프마다 `checkDuplicateCenterNm`과 `checkExistTplBizCenter`를 개별 실행. 삭제 목록은 전체 건에 대해 먼저 일괄 체크하는 반면, 수정은 건별 반복 조회함 |
| 파급 | 수정 건수가 많을수록 DB 왕복 횟수 증가. 성능 저하 가능성 |
| 개선 후보 | 중복명 체크를 일괄 처리 방식으로 변경하거나, IN 절로 묶어서 단건 쿼리로 처리 |

### 이슈 7: cancelRequest에서 checkExistBizCenter 동일 쿼리 2회 중복 호출

| 항목 | 내용 |
|---|---|
| 현상 | `cancelRequest` 메서드 내에서 `mdbzDao.checkExistBizCenter(postCenter)`가 두 번 연속 호출됨. 첫 번째는 데이터 존재 확인, 두 번째는 상태값 확인. 두 번째 호출은 첫 번째 결과를 재사용하지 않고 다시 DB 조회 |
| 파급 | 불필요한 DB 조회 1회 추가 |
| 개선 후보 | 첫 번째 결과를 변수에 저장하여 재사용 |

### 이슈 8: FE 미사용 ref 선언 (searchTplPopUp)

| 항목 | 내용 |
|---|---|
| 현상 | mdbz01.vue에 `const searchTplPopUp = ref()` 선언이 있으나, 실제 팝업 컴포넌트와 연결되지 않고 어디서도 `searchTplPopUp.value`를 사용하는 코드가 없음 |
| 파급 | 코드 혼란. 이슈 2(팝업 미마운트)와 연관된 문제 |
| 개선 후보 | 팝업을 실제 마운트하거나, 해당 ref 선언 제거 |

> 본 레지스터는 소스를 수정하지 않는다.
