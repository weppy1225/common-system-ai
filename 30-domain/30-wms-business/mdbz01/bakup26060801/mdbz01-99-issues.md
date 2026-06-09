---
title: MDBZ01 Open Issues / 확인 필요 사항
description: mdbz01 사업장·물류센터·물류위탁(3PL) 설계 문서화 과정에서 식별된 소스-문서 불일치·미연결 기능·정리 후보를 모은 확인/조치 레지스터. 개발 착수 전 반드시 검토.
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
tags:
  - open-issues
  - verification
  - 3pl
---

# MDBZ01 Open Issues / 확인 필요 사항

> mdbz01 문서화 과정에서 **소스 확인으로 드러난 "문제 포인트·확인 필요 사항"만** 모았다. 정상 동작 부분은 각 설계 문서(01~07)에 있고, 여기는 **개발 착수 전 확인·결정이 필요한 것**만 담는다.
> 우선순위: 🔴 기능 공백 · 🟠 정책/정합 · 🟡 정리/개선

## 요약

| # | 우선 | 이슈 | 근거 |
|---|:---:|---|---|
| I-1 | 🔴 | 위탁 의뢰 **수락/거절 화면 미연결** (BR-9 창고연결 포함) | api §3 / mapper-sql §2 |
| I-2 | 🔴 | 위탁 의뢰 **취소 화면 미연결** | api §3 |
| I-3 | 🔴 | **팝업(P01/P02) 진입점 없음** (메인이 import/open 안 함) | screen §5 |
| I-4 | 🟠 | 상태머신 **ACCEPT/DENIED 도달 불가** (REQUEST에 정체) | mapper-sql §5-4 |
| I-5 | 🟠 | **물리 DELETE** 2건 — 소프트삭제 원칙 상충 | be-flow §5 |
| I-6 | 🟡 | **Dead 코드/SQL 7건** 정리 후보 | mapper-sql §3 |
| I-7 | 🟡 | **N+1** 루프 2건 | be-flow §5 |
| I-8 | 🟡 | FE 잠재 버그: `vfn_searchCenterDtl` 미정의 호출 | `mdbz01.vue` keyDown |
| I-9 | 🟡 | 문구 드리프트: BR-5 "수락 시" vs 실제 "tpl_yn=Y 등록 시" | basic §7 / screen §4 |

---

## 🔴 기능 공백 (가동 화면에 없음)

### I-1. 위탁 의뢰 수락/거절 미연결
- **현상:** 대행사가 들어온 의뢰를 수락/거절하는 기능(`respTplCenter`, PATCH `/{selBiz}/tplReq`)과 들어온 의뢰 조회(`selectReqBizCenter`, GET `/tplReq`)가 **3개 vue 화면 어디에서도 호출되지 않음**.
- **파급:** **BR-9(수락 시 대행사 창고 자동연결, `insertBizWh`)** 와 `cfm_yn/use_yn` 상태 변경이 이 경로에만 존재 → 라이브에서 미작동.
- **확인 필요:** (a) 수락/거절을 다른 메뉴/화면에서 처리하는가? (b) 미구현이라면 P01에 수락/거절 UI를 붙일지, 별도 화면을 만들지 결정.

### I-2. 위탁 의뢰 취소 미연결
- **현상:** `cancelRequest`(PATCH `/cancel`)를 호출하는 화면/버튼 없음. 의뢰자가 신청중(REQUEST) 건을 철회하는 BR-8 기능이 가동되지 않음.
- **확인 필요:** 취소 기능 필요 여부 및 진입 화면 결정.

### I-3. 팝업 진입점 없음
- **현상:** `mdbz01.vue`(메인)가 `mdbz01Sch`(P02)·`mdbz01Set`(P01)를 **import하지 않고**, 여는 버튼도 없음. `searchTplPopUp` ref만 선언되고 미사용.
- **확인 필요:** P01/P02를 **어디서 어떻게 여는지**(메인 버튼? 다른 메뉴? 라우팅?) 확인. 미구현이면 진입 트리거 추가.

---

## 🟠 정책 / 정합

### I-4. 상태머신 도달성
- **현상:** `cfm_yn/use_yn`의 ACCEPT/DENIED는 `respTplCenter`(I-1, 미연결)에서만 생성 → 라이브 신청 건은 **REQUEST 상태에 머묾**.
- **확인 필요:** I-1 해소와 함께 상태 전이가 정상화되는지 검증.

### I-5. 물리 DELETE (소프트삭제 원칙 상충)
- **현상:** `cancelRequest`(`DELETE FROM MDM_BIZ_CENTER`), `deleteUserCenter`(`DELETE FROM MDM_USER_CENTER`)가 물리 삭제. 프로젝트 소프트삭제(`use_yn='N'`) 원칙과 상충.
- **확인 필요:** 의도된 물리삭제인지, 소프트삭제로 전환할지 정책 결정.

---

## 🟡 정리 / 개선

### I-6. Dead 코드/SQL 정리 후보 (7건)
- `searchBizs` / `insertBiz` / `insertUserBiz` / `insertDocNo` / `reqTplBiz` (Signup 잔재, Dao 호출자 없음)
- `deleteUserCenter` (Dao 메서드는 있으나 호출 안 함)
- `updateAllCenterTplYnToN` (호출부가 `MDBZ01TxComp`에 주석 처리됨)
- **확인 필요:** 타 메뉴에서 참조하지 않음을 확인 후 제거.

### I-7. N+1 패턴
- `reqTplCenterTX`, `update3plCenterTX`가 리스트를 **for 루프 내 단건 DML**로 처리.
- **확인 필요:** 건수 많을 때 성능. 배치(bulk) DML 검토.

### I-8. FE 잠재 버그
- `mdbz01.vue`의 센터 그리드 `keyDown` 핸들러(`lfn_reqGridKeydown`)가 **Enter 시 `vfn_searchCenterDtl(...)`** 를 호출하나, 해당 함수가 **파일에 정의되어 있지 않음** → 런타임 오류 가능.
- **확인 필요:** 핸들러 제거 또는 함수 구현.

### I-9. 문구 드리프트 (경미)
- BR-5(basic-design)는 "**수락 시** 주소·연락처 필수", 실제 검증은 "**`tpl_yn='Y'` 등록 시** 필수"(P01 `lfn_validUpdateTpl`). 같은 규칙이나 발생 시점 표현이 다름.
- **확인 필요:** I-1 정리 시 BR-5 문구를 실제 시점에 맞춰 정리.

---

> 본 레지스터는 **소스를 수정하지 않는다.** 각 항목은 개발 착수 시 확인·결정할 과제이며, 해소되면 해당 설계 문서(01~07)에 반영하고 여기서 닫는다.
