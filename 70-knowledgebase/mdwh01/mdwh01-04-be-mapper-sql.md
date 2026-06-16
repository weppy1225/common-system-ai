---
title: MDWH01 SQL 목록
description: mdwh01 창고에서 사용하는 SQL statement 목록. 상세 구현은 Mapper.xml 참조.
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: spec
menu_code: mdwh01
domain: master
depends_on:
  - "70-knowledgebase/mdwh01/mdwh01-03-data-model.md"
related:
  - "70-knowledgebase/mdwh01/mdwh01-06-be-flow.md"
  - "70-knowledgebase/mdwh01/mdwh01-05-api.md"
tags: [detail-design, backend, sql, master]
---

# MDWH01 SQL 목록

## SQL 목록

| 화면 | 기능·버튼 | SQL명 | 유형 |
|---|---|---|---|
| 창고 목록 | 조회 | searchWhs | SELECT |
| 창고 수정 팝업 | 수정 팝업 열기 (단건 조회) | selectWh | SELECT |
| 창고 등록/수정 팝업 | 등록·수정 시 창고그룹별 기능 개수 확인 (유효성 검증) | selectWhFuncCount | SELECT |
| 창고 등록/수정 팝업 | 등록·수정 시 창고명 중복 확인 (유효성 검증) | checkDuplicateWhNm | SELECT |
| 창고 삭제 | 삭제 시 수불 이력 사용 여부 확인 (유효성 검증) | checkIsUsedWh | SELECT |
| 창고 등록 팝업 | 등록 시 위탁 사업장 목록 조회 | selectTplCenterBizSeq | SELECT |
| 창고 등록 팝업 | 등록 (창고 본 테이블 저장) | insertWh | INSERT |
| 창고 등록 팝업 | 등록 (사업장-창고 매핑 저장) | insertbizWh | INSERT |
| 창고 등록 팝업 | 등록 (기본 위치 자동 생성) | insertDefaultLoc | INSERT |
| 창고 등록 팝업 | 등록 (위탁 사업장-창고 매핑 저장, 위탁 사업장 수만큼 반복) | insertbizWh | INSERT |
| 창고 수정 팝업 | 수정 (창고 정보 갱신) | updateWh | UPDATE |
| 창고 수정 팝업 | 수정 (기본 위치명 갱신) | updateDefaultLoc | UPDATE |
| 창고 수정 팝업 | 수정 (IF창고ID 갱신) | updateIfWhId | UPDATE |
| 창고 등록 팝업 | 등록 (기본 위치 바코드 갱신) | updateDefLocBarcode | UPDATE |
| 창고 삭제 | 삭제 (위치 삭제) | deleteLocs | DELETE |
| 창고 삭제 | 삭제 (사업장-창고 매핑 삭제) | deleteBizWhs | DELETE |
| 창고 삭제 | 삭제 (창고 본 테이블 삭제) | deleteWhs | DELETE |

### 비고

- 창고 등록 시 `insertWh` → `insertbizWh` → `insertDefaultLoc` → `updateDefLocBarcode` 순으로 4개 SQL이 연속 실행된다.
- 창고가 위탁 센터에 속할 경우, 위탁 사업장 수만큼 `insertbizWh`가 추가로 반복 실행된다.
- 창고 수정 시 `updateWh` → `updateDefaultLoc` → `updateIfWhId` 순으로 3개 SQL이 연속 실행된다.
- 창고 삭제 시 `deleteLocs` → `deleteBizWhs` → `deleteWhs` 순으로 3개 SQL이 연속 실행된다.
- `selectWhFuncCount`는 등록 시와 수정 시 모두 호출되며, 각 처리기능별 활성 창고 개수를 집계한다.
- `checkDuplicateWhNm`는 등록과 수정 양쪽에서 호출된다.
