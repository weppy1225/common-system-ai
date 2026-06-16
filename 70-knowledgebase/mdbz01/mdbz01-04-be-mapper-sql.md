---
title: MDBZ01 SQL 목록
description: mdbz01 사업장에서 사용하는 SQL statement 목록. 상세 구현은 Mapper.xml 참조.
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: spec
menu_code: mdbz01
domain: master
depends_on:
  - "70-knowledgebase/mdbz01/mdbz01-03-data-model.md"
related:
  - "70-knowledgebase/mdbz01/mdbz01-06-be-flow.md"
  - "70-knowledgebase/mdbz01/mdbz01-05-api.md"
tags: [detail-design, backend, sql, master]
---

# MDBZ01 SQL 목록

상세 SQL 구현은 `MDBZ01Mapper.xml` 참조.

| 화면 | 기능·버튼 | SQL명 | 유형 |
|---|---|---|---|
| 메인 | 화면 진입 시 수정 가능 사업장 목록 자동 조회 | searchEditableBizs | SELECT |
| 메인 | 사업장 선택 시 단건 정보 자동 조회 | selectBiz | SELECT |
| 메인 | 사업장 선택 시 센터 목록 자동 조회 | selectBizCenter | SELECT |
| 메인 | 사업장 기본정보 저장 | updateBiz | UPDATE |
| 메인 | 물류센터 저장 — 센터 추가 | insertCenter | INSERT |
| 메인 | 물류센터 저장 — 센터 추가 | insertBizCenter | INSERT |
| 메인 | 물류센터 저장 — 센터 추가 | insertCenterAutorityToSuper | INSERT |
| 메인 | 물류센터 저장 — 센터 추가 (기본창고 생성) | searchWhTemplate | SELECT |
| 메인 | 물류센터 저장 — 센터 추가 (기본창고 생성) | insertDefaultWh | INSERT |
| 메인 | 물류센터 저장 — 센터 추가 (기본창고 생성) | insertbizWh | INSERT |
| 메인 | 물류센터 저장 — 센터 추가 (기본창고 생성) | insertDefaultLoc | INSERT |
| 메인 | 물류센터 저장 — 센터 추가 전 중복명 체크 | checkDuplicateCenterNm | SELECT |
| 메인 | 물류센터 저장 — 센터 수정 | updateCenter | UPDATE |
| 메인 | 물류센터 저장 — 센터 수정 | updateBizCenter | UPDATE |
| 메인 | 물류센터 저장 — 센터 수정 전 중복명 체크 | checkDuplicateCenterNm | SELECT |
| 메인 | 물류센터 저장 — 센터 수정 전 위탁업체 존재 체크 | checkExistTplBizCenter | SELECT |
| 메인 | 물류센터 저장 — 센터 삭제 | deleteCenter | UPDATE |
| 메인 | 물류센터 저장 — 센터 삭제 | deleteBizCenter | UPDATE |
| 메인 | 물류센터 저장 — 센터 삭제 | deleteCenterAutority | DELETE |
| 메인 | 물류센터 저장 — 센터 삭제 전 권한 사용자 존재 체크 | checkExistUserCenter | SELECT |
| 메인 | 물류센터 저장 — 센터 삭제 전 위탁업체 존재 체크 | checkExistTplBizCenter | SELECT |
| 메인 | 물류센터 저장 — 센터 삭제 전 창고 존재 체크 | checkExistCenterWh | SELECT |
| 메인 | 물류센터 저장 — 저장 후 사용 센터 존재 확인 | selectBizCenter | SELECT |
| MDBZ01P01 | 팝업 열기 시 자사 위탁 센터 목록 조회 | selectTplBizCenter | SELECT |
| MDBZ01P01 | 저장 | updateTplCenter | UPDATE |
| MDBZ01P02 | 검색 | searchTplBizCenter | SELECT |
| MDBZ01P02 | 위탁 요청 — 사업장-사업장 관계 존재 확인 | checkExistBizBiz | SELECT |
| MDBZ01P02 | 위탁 요청 — 사업장-사업장 관계 신규 생성 | insertBizBiz | INSERT |
| MDBZ01P02 | 위탁 요청 — 사업장-센터 관계 존재 확인 | checkExistBizCenter | SELECT |
| MDBZ01P02 | 위탁 요청 — 사업장-센터 관계 신규 생성 | insertBizCenter | INSERT |
| MDBZ01P02 | 위탁 요청 — 이전 거절 이력 재신청 처리 | updateBizCenter | UPDATE |
| 대행의뢰신청업체 조회 (🟠 FE 미연결) | 의뢰 목록 조회 | selectReqBizCenter | SELECT |
| 대행의뢰 수락/거절 (🟠 FE 미연결) | 수락/거절 상태 변경 | respTplCenter | UPDATE |
| 대행의뢰 수락/거절 (🟠 FE 미연결) | 사업장-사업장 관계 사용여부 갱신 | updateBizBiz | UPDATE |
| 대행의뢰 수락/거절 (🟠 FE 미연결) | 수락 시 사업장-창고 연결 생성 | insertBizWh | INSERT |
| 의뢰 취소 (🟠 FE 미연결) | 의뢰 데이터 삭제 | cancelRequest | DELETE |

---

### 참고: Mapper.xml에 정의되었으나 현재 미사용인 statement

| SQL명 | 유형 | 비고 |
|---|---|---|
| searchBizs | SELECT | Dao에 호출 없음. 사업장 검색 기능으로 추정되나 미사용 상태 |
| insertBiz | INSERT | Dao에 호출 없음. 사업장 신규 등록 기능으로 추정되나 미사용 |
| insertUserBiz | INSERT | Dao에 호출 없음. 사용자-사업장 권한 등록으로 추정되나 미사용 |
| insertDocNo | INSERT | Dao에 호출 없음. 문서번호 초기 등록으로 추정되나 미사용 |
| reqTplBiz | SELECT | Dao에 호출 없음. 위탁 의뢰 사업장 목록 조회로 추정되나 미사용 |
| deleteUserCenter | DELETE | Dao에 호출 없음. 사용자-센터 권한 삭제로 추정되나 미사용 |
| updateAllCenterTplYnToN | UPDATE | Dao에 메서드는 존재하나 TxComp에서 주석 처리됨. 사업장 구분 변경 시 모든 센터 물류대행 여부 해제 |
