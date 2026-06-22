---
title: MDBZ01 SQL 명세 (데이터 접근 설계)
description: mdbz01 사업장에서 사용하는 SQL의 목록·용도·파라미터·예시를 설계 문서 형태로 기술.
status: active
version: 1.0.0
wms_meta: true
repo_role: ai-hub
agent_usage: spec
menu_code: mdbz01
domain: master
depends_on:
  - "spec/common-system/mdbz01/mdbz01-03-data-model.md"
related:
  - "spec/common-system/mdbz01/mdbz01-06-be-flow.md"
  - "spec/common-system/mdbz01/mdbz01-05-api.md"
tags:
  - detail-design
  - backend
  - sql
  - master
---

# MDBZ01 SQL 명세 (데이터 접근 설계)

## 1. SQL 목록

| No. | SQL명 | 유형 | 업무 용도 |
|---|---|---|---|
| 1 | searchBizs | SELECT | 사용자가 접근 가능한 사업장 목록 조회 (검색 팝업용) |
| 2 | selectBiz | SELECT | 사업장 단건 조회 — 사업장 정보 폼 데이터 로드 |
| 3 | insertBiz | INSERT | 사업장 신규 등록 (회원가입 시 사용, 이 화면 직접 미사용) |
| 4 | insertUserBiz | INSERT | 사용자-사업장 권한 등록 (회원가입 시 사용) |
| 5 | insertBizBiz | INSERT | 사업장-사업장 연결 관계 등록 |
| 6 | insertDocNo | INSERT | 신규 사업장의 문서번호 시퀀스 초기화 (기준 사업장 데이터 복사) |
| 7 | updateBiz | UPDATE | 사업장 기본 정보 수정 — 사업장 저장 버튼 |
| 8 | selectBizCenter | SELECT | 사업장에 속한 물류센터 목록 조회 |
| 9 | insertCenter | INSERT | 물류센터 신규 등록 |
| 10 | insertBizCenter | INSERT | 사업장-센터 관계 등록 (소유 또는 위탁 신청) |
| 11 | updateCenter | UPDATE | 물류센터 기본 정보 수정 |
| 12 | updateBizCenter | UPDATE | 사업장-센터 관계 정보 수정 (승인상태, 사용여부, 비고) |
| 13 | deleteCenter | UPDATE | 물류센터 비활성화 (use_yn='N', 물리 삭제 아님) |
| 14 | deleteBizCenter | UPDATE | 사업장-센터 관계 비활성화 |
| 15 | deleteUserCenter | DELETE | 미확인: 물리 DELETE — `db-convention.md` §6의 소프트삭제 원칙과 상충하나, 실제 Mapper XML은 `DELETE FROM MDM_USER_CENTER` 구현 |
| 16 | searchWhTemplate | SELECT | 기본 창고 템플릿 조회 — 센터 등록 시 자동 창고 생성용 |
| 17 | insertDefaultWh | INSERT | 기본 창고 생성 |
| 18 | insertbizWh | INSERT | 사업장-창고 관계 등록 |
| 19 | insertDefaultLoc | INSERT | 기본 위치 생성 (창고당 1건) |
| 20 | checkExistCenterWh | SELECT | 센터 삭제 전 창고 존재 여부 확인 |
| 21 | checkExistUserCenter | SELECT | 센터 삭제 전 사용자 권한 존재 여부 확인 (슈퍼 제외) |
| 22 | checkExistTplBizCenter | SELECT | 센터 삭제/미사용 전환 전 위탁 관계 존재 여부 확인 |
| 23 | checkDuplicateCenterNm | SELECT | 센터명 중복 여부 확인 |
| 24 | selectTplBizCenter | SELECT | 위탁 센터 목록 조회 — 센터정보수정 팝업(MDBZ01P01) |
| 25 | updateTplCenter | UPDATE | 위탁 센터 물류대행 정보 수정 |
| 26 | searchTplBizCenter | SELECT | 물류 대행 업체 검색 — 물류대행업체검색 팝업(MDBZ01P02) |
| 27 | checkExistBizBiz | SELECT | 사업장-사업장 연결 관계 존재 여부 확인 |
| 28 | checkExistBizCenter | SELECT | 위탁 의뢰 중복 및 상태 확인 |
| 29 | selectReqBizCenter | SELECT | 대행의뢰신청업체 목록 조회 |
| 30 | respTplCenter | UPDATE | 위탁 의뢰 수락/거절 처리 |
| 31 | cancelRequest | DELETE | 미확인: 위탁 의뢰 취소 (물리 DELETE). `db-convention.md` §6과 상충하나 실제 Mapper XML은 `DELETE FROM MDM_BIZ_CENTER` 구현 |
| 32 | updateBizBiz | UPDATE | 위탁 수락/거절 후 사업장-사업장 관계 활성상태 재계산 |
| 33 | insertCenterAutorityToSuper | INSERT | 슈퍼 관리자 전원에게 신규 센터 접근 권한 부여 |
| 34 | deleteCenterAutority | DELETE | 센터 삭제 시 해당 센터의 사용자 권한 제거 |
| 35 | insertBizWh | INSERT | 위탁 수락 시 의뢰 사업장에 센터의 창고 접근 권한 부여 |
| 36 | updateAllCenterTplYnToN | UPDATE | 사업장 구분 변경 시 모든 센터의 물류대행여부를 일괄 미사용으로 전환 (현재 주석 처리됨) |
| 37 | searchEditableBizs | SELECT | 수정 가능한 사업장 목록 조회 — 화면 진입 시 드롭다운 데이터 |
| 38 | reqTplBiz | SELECT | 미확인: 의뢰 사업장 목록 조회 (Mapper XML 정의만 확인, `MDBZ01Mapper.java`/`MDBZ01Dao.java` 호출 미확인) |

---

## 2. SQL 상세

### searchBizs

**용도:** 사용자가 접근 가능한 사업장 목록을 조회한다. 사업장-사업장 연결 테이블을 통해 해당 사용자가 권한을 가진 사업장만 반환하며, 검색 조건(사업장명, 사업자번호, 사용여부)으로 필터링이 가능하다.

**파라미터:**

| 파라미터 | 설명 | 예시값 |
|---|---|---|
| userId | 로그인 사용자 ID | 'user01' |
| bizNm | 사업장명 부분 검색 (선택) | '진' |
| bizNo | 사업자번호 부분 검색 (선택) | '123' |
| useYn | 사용여부 필터 (선택) | 'Y' |

**반환 컬럼:**

| 컬럼명 | 설명 |
|---|---|
| bizSeq | 사업장 순번 |
| bizNm | 사업장명 |
| bizNo | 사업자등록번호 |
| useYn | 사용여부 |

```sql
-- 예시: userId='user01', bizNm='진', useYn='Y'
SELECT MB.biz_seq   AS bizSeq
     , MB.biz_nm    AS bizNm
     , MB.biz_no    AS bizNo
     , MB.use_yn    AS useYn
  FROM MDM_BIZ_BIZ MBB
  JOIN MDM_BIZ MB ON (MBB.BIZ_SEQ = MB.BIZ_SEQ)
 WHERE MBB.use_yn = 'Y'
   AND MBB.REF_BIZ_SEQ IN (SELECT BIZ_SEQ
                             FROM MDM_USER_BIZ
                            WHERE USER_ID = 'user01')
   AND MB.biz_nm LIKE FN_CONCAT('%', '진', '%')
   AND MB.use_yn = 'Y'
 GROUP BY MB.biz_seq, MB.biz_nm, MB.biz_no, MB.use_yn
 ORDER BY
 (CASE WHEN MB.biz_seq = (SELECT BIZ_SEQ
                           FROM MDM_USER_BIZ
                          WHERE USER_ID = 'user01') THEN 0 END), MB.reg_dt
```

---

### selectBiz

**용도:** 특정 사업장의 상세 정보를 단건 조회한다. 사업장 선택 드롭다운에서 사업장 변경 시 또는 화면 초기 로드 시 좌측 폼을 채우기 위해 호출된다. 로고 이미지 파일이 있으면 파일 정보도 함께 반환한다.

**파라미터:**

| 파라미터 | 설명 | 예시값 |
|---|---|---|
| bizSeq | 조회할 사업장 순번 | 100 |

**반환 컬럼:**

| 컬럼명 | 설명 |
|---|---|
| bizSeq | 사업장 순번 |
| bizNm | 사업장명 |
| bizNmShort | 사업장 약칭 |
| bizNo | 사업자등록번호 |
| ceoNm | 대표자명 |
| subBizNo | 종사업자번호 |
| bizDivCd | 사업장 구분 코드 |
| bizType | 업태 |
| bizItem | 업종 |
| postNo | 우편번호 |
| addr | 주소 |
| addrDtl | 주소 상세 |
| tel | 전화번호 |
| email | 이메일 |
| fax | 팩스 |
| stampFileSeq | 직인 파일 순번 |
| logoFileSeq | 로고 파일 순번 |
| fileNm | 로고 파일명 |
| fileUuid | 로고 파일 UUID |
| fileExtension | 로고 파일 확장자 |
| filePath | 로고 파일 경로 |
| bizColor | 사업장 테마색 |
| note | 비고 |
| useYn | 사용여부 |

```sql
-- 예시: bizSeq=100
SELECT MB.biz_seq              AS bizSeq
     , MB.biz_nm               AS bizNm
     , MB.biz_nm_short         AS bizNmShort
     , MB.biz_no               AS bizNo
     , MB.ceo_nm               AS ceoNm
     , MB.sub_biz_no           AS subBizNo
     , MB.biz_div_cd           AS bizDivCd
     , MB.biz_type             AS bizType
     , MB.biz_item             AS bizItem
     , MB.post_no              AS postNo
     , MB.addr                 AS addr
     , MB.addr_dtl             AS addrDtl
     , MB.tel                  AS tel
     , MB.email                AS email
     , MB.fax                  AS fax
     , MB.logo_file_seq        AS logoFileSeq
     , SF.file_nm              AS fileNm
     , SF.file_uuid            AS fileUuid
     , SF.file_extension       AS fileExtension
     , SF.file_path            AS filePath
     , MB.biz_color            AS bizColor
     , MB.note                 AS note
     , MB.use_yn               AS useYn
  FROM MDM_BIZ MB
  LEFT JOIN SM_FILE SF ON MB.logo_file_seq = SF.file_seq
 WHERE MB.biz_seq = 100
```

---

### updateBiz

**용도:** 사업장의 기본 정보를 수정한다. 사업장명, 약칭, 대표자, 사업자등록번호, 업태/업종, 주소, 연락처, 로고 파일 순번, 테마색, 사용여부 등 거의 모든 필드를 갱신한다.

**파라미터:** MDBZ01Biz 객체 전체 (bizSeq 필수, 나머지 수정 가능 필드들)

| 주요 파라미터 | 설명 | 예시값 |
|---|---|---|
| bizSeq | 수정 대상 사업장 순번 | 100 |
| bizNm | 수정할 사업장명 | '진아이드 물류' |
| logoFileSeq | 로고 파일 순번 (삭제 시 null) | 55 |
| bizColor | 테마색 HEX | '#00afec' |
| modId | 수정자 ID | 'user01' |
| modDt | 수정일시 | '20260608120000' |

```sql
-- 예시: bizSeq=100, bizNm='진아이드 물류', logoFileSeq=55, modId='user01'
UPDATE MDM_BIZ
   SET biz_nm = '진아이드 물류'
     , biz_nm_short = '진아이드'
     , ceo_nm = '홍길동'
     , biz_no = '123-45-67890'
     , sub_biz_no = null
     , biz_type = '도소매업'
     , biz_item = '물류'
     , biz_div_cd = 'OWN'
     , email = 'admin@zin.co.kr'
     , tel = '02-1234-5678'
     , fax = null
     , post_no = '12345'
     , addr = '서울시 강남구'
     , addr_dtl = '테헤란로 123'
     , logo_file_seq = 55
     , biz_color = '#00afec'
     , note = null
     , use_yn = 'Y'
     , mod_id = 'user01'
     , mod_dt = FN_GET_DT('20260608120000')
 WHERE biz_seq = 100
```

---

### selectBizCenter

**용도:** 특정 사업장에 속한 물류센터 전체 목록을 조회한다. 자사 센터와 위탁 센터를 모두 포함하며, 각 센터의 위탁 관계 상태와 편집 가능 여부를 함께 반환한다. 메인 화면 우측 그리드에 표시된다.

**파라미터:**

| 파라미터 | 설명 | 예시값 |
|---|---|---|
| bizSeq | 조회할 사업장 순번 | 100 |
| regBizSeq | 현재 로그인 사용자의 소속 사업장 순번 (편집 가능 여부 판단용) | 100 |

**반환 컬럼:**

| 컬럼명 | 설명 |
|---|---|
| bizSeq | 사업장 순번 |
| bizNm | 사업장명 |
| centerSeq | 센터 순번 |
| centerNm | 센터명 |
| tplYn | 물류대행 여부 |
| postNo | 우편번호 |
| addr | 주소 |
| addrDtl | 주소상세 |
| tel | 전화번호 |
| note | 비고 |
| useYn | 사용여부 |
| cfmYn | 승인여부 |
| editableYn | 현재 로그인 사용자가 수정 가능한지 여부 |
| tplCenterYn | 위탁 센터(외부 업체 소유) 여부 |
| authCnt | 이 센터를 승인 사용 중인 다른 사업장 수 |
| unauthCnt | 이 센터에 미승인 의뢰가 있는 다른 사업장 수 |

```sql
-- 예시: bizSeq=100, regBizSeq=100
SELECT MBC.reg_biz_seq  AS bizSeq
     , MB.biz_nm        AS bizNm
     , MC.center_seq    AS centerSeq
     , MC.center_nm     AS centerNm
     , MC.tpl_yn        AS tplYn
     , MC.addr          AS addr
     , MC.addr_dtl      AS addrDtl
     , MC.tel           AS tel
     , MC.note          AS note
     , MBC.use_yn       AS useYn
     , MBC.cfm_yn       AS cfmYn
     , CASE WHEN MBC.reg_biz_seq = 100 THEN 'Y' ELSE 'N' END AS editableYn
     , CASE WHEN MBC.biz_seq = MBC.reg_biz_seq THEN 'N' ELSE 'Y' END AS tplCenterYn
     , (SELECT COUNT(center_seq) FROM MDM_BIZ_CENTER
         WHERE biz_seq != 100 AND center_seq = MC.center_seq
           AND cfm_yn = 'Y' AND use_yn = 'Y') AS authCnt
     , (SELECT COUNT(center_seq) FROM MDM_BIZ_CENTER
         WHERE biz_seq != 100 AND center_seq = MC.center_seq
           AND cfm_yn = 'N') AS unauthCnt
  FROM MDM_CENTER MC
  JOIN MDM_BIZ_CENTER MBC ON (MC.CENTER_SEQ = MBC.CENTER_SEQ)
  LEFT JOIN MDM_BIZ MB ON MBC.reg_biz_seq = MB.biz_seq
 WHERE MBC.biz_seq = 100
   AND MC.use_yn = 'Y'
 ORDER BY useYn DESC, bizSeq, centerSeq
```

---

### insertCenter

**용도:** 물류센터 신규 등록 시 센터 기본 정보를 MDM_CENTER 테이블에 삽입한다. 생성된 centerSeq를 auto-key로 반환하며, 이후 insertBizCenter 호출의 키로 사용된다.

**파라미터:**

| 파라미터 | 설명 | 예시값 |
|---|---|---|
| centerNm | 센터명 | '서울 물류센터' |
| regId | 등록자 ID | 'user01' |
| regDt | 등록일시 | '20260608120000' |

```sql
-- 예시: centerNm='서울 물류센터', regId='user01'
INSERT INTO MDM_CENTER (center_nm, reg_id, reg_dt)
VALUES ('서울 물류센터', 'user01', FN_GET_DT('20260608120000'))
-- 반환: 자동 생성된 center_seq
```

---

### insertBizCenter

**용도:** 사업장과 센터의 소유 관계, 또는 위탁 의뢰 관계를 MDM_BIZ_CENTER 테이블에 등록한다. 자사 센터 등록 시와 위탁 의뢰 신청 시 모두 이 SQL을 공유한다.

**파라미터:**

| 파라미터 | 설명 | 예시값 |
|---|---|---|
| regBizSeq | 원소유 사업장 순번 | 100 |
| bizSeq | 소유/의뢰 사업장 순번 | 100 (자사) 또는 200 (위탁) |
| centerSeq | 센터 순번 | 5 |
| useYn | 사용여부 | 'Y' (자사) 또는 'N' (위탁 신청 중) |
| cfmYn | 승인여부 | 'Y' (자사) 또는 'N' (위탁 신청 중) |
| note | 비고 / 위탁 요청 내용 | null |

```sql
-- 예시: 자사 센터 등록 (bizSeq=regBizSeq=100, centerSeq=5)
INSERT INTO MDM_BIZ_CENTER
       (reg_biz_seq, biz_seq, center_seq, use_yn, cfm_yn, note, reg_id, reg_dt)
VALUES (100, 100, 5, 'Y', 'Y', null, 'user01', FN_GET_DT('20260608120000'))
```

---

### updateCenter

**용도:** 물류센터의 기본 정보(이름, 주소, 연락처, 비고, 사용여부)를 수정한다. 메인 화면 센터 그리드에서 편집 후 저장 시 호출된다. 주의: tpl_yn(물류대행여부)은 이 SQL에서 주석 처리되어 있어 별도 updateTplCenter SQL로만 변경 가능하다.

**파라미터:**

| 파라미터 | 설명 | 예시값 |
|---|---|---|
| centerSeq | 수정 대상 센터 순번 | 5 |
| centerNm | 수정할 센터명 | '서울 물류센터(수정)' |
| useYn | 사용여부 | 'Y' |
| modId | 수정자 ID | 'user01' |
| modDt | 수정일시 | '20260608120000' |

```sql
-- 예시: centerSeq=5, centerNm='서울 물류센터(수정)', useYn='Y', modId='user01'
UPDATE MDM_CENTER
   SET center_nm = '서울 물류센터(수정)'
     , post_no = '12345'
     , addr = '서울시 강남구'
     , addr_dtl = '테헤란로 456'
     , tel = '02-9876-5432'
     , note = null
     , use_yn = 'Y'
     , mod_id = 'user01'
     , mod_dt = FN_GET_DT('20260608120000')
 WHERE center_seq = 5
```

---

### deleteCenter

**용도:** 물류센터를 비활성화한다. MDM_CENTER의 use_yn을 'N'으로 변경하는 소프트 삭제 방식이다. 물리적으로 데이터를 삭제하지 않는다.

**파라미터:**

| 파라미터 | 설명 | 예시값 |
|---|---|---|
| centerSeq | 비활성화할 센터 순번 | 5 |
| modId | 수정자 ID | 'user01' |
| modDt | 수정일시 | '20260608120000' |

```sql
-- 예시: centerSeq=5, modId='user01'
UPDATE MDM_CENTER
   SET use_yn = 'N'
     , mod_id = 'user01'
     , mod_dt = FN_GET_DT('20260608120000')
 WHERE center_seq = 5
```

---

### deleteUserCenter

**용도:** 센터 삭제 시 해당 센터에 부여된 사용자 권한 레코드를 물리 삭제한다. `MDBZ01Mapper.xml`의 실제 구현은 `DELETE FROM MDM_USER_CENTER`이다.

**미확인:** 이 SQL은 `db-convention.md` §6의 물리 삭제 금지 원칙과 상충한다. 현재 문서 범위에서는 예외 허용 근거를 소스에서 확인하지 못했다.

**파라미터:**

| 파라미터 | 설명 | 예시값 |
|---|---|---|
| centerSeq | 삭제할 센터 순번 | 5 |

```sql
-- 예시: centerSeq=5
DELETE FROM MDM_USER_CENTER
 WHERE center_seq = 5
```

---

### checkDuplicateCenterNm

**용도:** 동일 사업장 내에서 같은 이름의 사용 중인 센터가 있는지 확인한다. 센터 등록/수정 전에 호출되며, 결과가 비어있으면 중복 없음(저장 가능), 결과가 있으면 중복(저장 차단).

**파라미터:**

| 파라미터 | 설명 | 예시값 |
|---|---|---|
| bizSeq | 검색 대상 사업장 순번 | 100 |
| centerSeq | 수정 중인 센터 순번 (등록 시는 null 또는 0) | null |
| centerNm | 확인할 센터명 | '서울 물류센터' |

**반환 컬럼:** 중복 건이 있으면 센터명(field)과 코드 'DUPLICATE' 반환, 없으면 빈 목록 반환

```sql
-- 실제 Mapper.xml 기준 예시: bizSeq=100, centerSeq=null, centerNm='서울 물류센터'
SELECT MC.center_nm AS field, 'DUPLICATE' AS code
  FROM MDM_CENTER MC
  JOIN MDM_BIZ_CENTER MBC ON MC.center_seq = MBC.center_seq
 WHERE MC.center_seq != #{centerSeq}  -- 수정 시 자기 자신 제외
   AND MBC.biz_seq = 100
   AND MC.center_nm = '서울 물류센터'
   AND MC.USE_YN = 'Y'
   AND MBC.USE_YN = 'Y'
```

---

### searchTplBizCenter

**용도:** 위탁 의뢰가 가능한 물류 대행 업체의 센터를 검색한다. 물류대행 업체 유형 사업장 중 tpl_yn='Y'인 센터만 반환하며, 현재 사용자의 의뢰 상태(신청가능/신청중/승인/거절)를 함께 표시한다. 물류대행업체검색 팝업(MDBZ01P02)의 검색 버튼에서 호출된다.

**파라미터:**

| 파라미터 | 설명 | 예시값 |
|---|---|---|
| userId | 로그인 사용자 ID (의뢰 상태 조회용) | 'user01' |
| bizNm | 사업장명 부분 검색 (선택) | '물류' |
| centerNm | 센터명 부분 검색 (선택) | '서울' |
| addr | 주소 부분 검색 (선택) | '강남' |

**반환 컬럼:** bizSeq, bizNm, centerSeq, centerNm, addr, addrDtl, tel, email, note, reqSts (신청가능/신청중/승인/거절)

```sql
-- 예시: userId='user01', bizNm='물류', centerNm='서울'
SELECT MB.biz_seq    AS bizSeq
     , MB.biz_nm     AS bizNm
     , MC.center_seq AS centerSeq
     , MC.center_nm  AS centerNm
     , MC.addr       AS addr
     , MC.tel        AS tel
     , COALESCE((SELECT CASE WHEN MBC2.cfm_yn = 'Y' AND MBC2.use_yn = 'Y' THEN '승인'
                              WHEN MBC2.cfm_yn = 'Y' AND MBC2.use_yn = 'N' THEN '거절'
                              WHEN MBC2.cfm_yn = 'N' AND MBC2.use_yn = 'N' THEN '신청중' END
                   FROM MDM_BIZ_CENTER MBC2
                  WHERE MBC2.REG_ID = 'user01'
                    AND MBC2.center_seq = MC.center_seq), '신청가능') AS reqSts
  FROM MDM_CENTER MC
  JOIN MDM_BIZ_CENTER MBC ON MC.CENTER_SEQ = MBC.CENTER_SEQ
  JOIN MDM_BIZ MB ON MBC.BIZ_SEQ = MB.BIZ_SEQ
 WHERE MC.tpl_yn = 'Y'
   AND MB.biz_div_cd = 'TPL'           -- 물류대행 업체 유형
   AND MC.use_yn = 'Y'
   AND MBC.use_yn = 'Y'
   AND MB.BIZ_SEQ NOT IN (SELECT BIZ_SEQ FROM MDM_USER_BIZ WHERE USER_ID = 'user01')
   AND MBC.biz_seq = MBC.reg_biz_seq   -- 자사 센터만
   AND MB.biz_nm LIKE FN_CONCAT('%', '물류', '%')
   AND MC.center_nm LIKE FN_CONCAT('%', '서울', '%')
 ORDER BY MB.reg_dt
```

---

### checkExistBizCenter

**용도:** 특정 사업장-센터 조합의 위탁 의뢰 레코드가 존재하는지 확인하고, 존재한다면 현재 상태(ACCEPT/DENIED/REQUEST)를 반환한다. 위탁 의뢰 신청 전 중복 확인 및 수락/거절/취소 처리 전 레코드 존재 확인에 사용된다.

**파라미터:**

| 파라미터 | 설명 | 예시값 |
|---|---|---|
| bizSeq | 의뢰를 보낸 사업장 순번 | 200 |
| centerSeq | 의뢰 대상 센터 순번 | 5 |

**반환 컬럼:** field(centerSeq), invalidValue(ACCEPT/DENIED/REQUEST), code('DUPLICATE')

```sql
-- 예시: bizSeq=200, centerSeq=5
SELECT MBC.center_seq AS field
     , CASE WHEN MBC.cfm_yn = 'Y' AND MBC.use_yn = 'Y' THEN 'ACCEPT'
            WHEN MBC.cfm_yn = 'Y' AND MBC.use_yn = 'N' THEN 'DENIED'
            WHEN MBC.cfm_yn = 'N' AND MBC.use_yn = 'N' THEN 'REQUEST' END AS invalidValue
     , 'DUPLICATE' AS code
  FROM MDM_BIZ_CENTER MBC
 WHERE MBC.biz_seq = 200
   AND MBC.center_seq = 5
```

---

### respTplCenter

**용도:** 대행 업체가 위탁 의뢰를 수락하거나 거절할 때 MDM_BIZ_CENTER의 cfm_yn과 use_yn을 갱신한다. 수락 시 cfm_yn='Y', use_yn='Y', 거절 시 cfm_yn='Y', use_yn='N'으로 변경된다.

**파라미터:**

| 파라미터 | 설명 | 예시값 |
|---|---|---|
| bizSeq | 의뢰를 보낸 사업장 순번 | 200 |
| centerSeq | 처리할 센터 순번 | 5 |
| cfmYn | 처리 여부 | 'Y' |
| useYn | 수락(Y) 또는 거절(N) | 'Y' (수락) |
| modId | 처리자 ID | 'admin01' |
| modDt | 처리일시 | '20260608120000' |

```sql
-- 예시: bizSeq=200, centerSeq=5, cfmYn='Y', useYn='Y' (수락)
UPDATE MDM_BIZ_CENTER
   SET cfm_yn = 'Y'
     , use_yn = 'Y'
     , mod_id = 'admin01'
     , mod_dt = FN_GET_DT('20260608120000')
 WHERE biz_seq = 200
   AND center_seq = 5
```

---

### cancelRequest

**용도:** 의뢰자가 아직 처리되지 않은 위탁 의뢰를 취소한다. `MDBZ01Mapper.xml`의 실제 구현은 `DELETE FROM MDM_BIZ_CENTER`이다.

**미확인:** 이 SQL은 `db-convention.md` §6의 물리 삭제 금지 원칙과 상충한다. 현재 문서 범위에서는 예외 허용 근거를 소스에서 확인하지 못했다.

**파라미터:**

| 파라미터 | 설명 | 예시값 |
|---|---|---|
| bizSeq | 의뢰를 보낸 사업장 순번 | 200 |
| centerSeq | 취소할 센터 순번 | 5 |

```sql
-- 예시: bizSeq=200, centerSeq=5
DELETE FROM MDM_BIZ_CENTER
 WHERE biz_seq = 200
   AND center_seq = 5
```

---

### searchEditableBizs

**용도:** 현재 로그인 사용자가 수정할 수 있는 사업장 목록을 조회한다. 화면 진입 시 사업장 선택 드롭다운에 사용된다. 사용자의 권한 유형에 따라 반환 범위가 달라지며, 화주 유형 사업장은 항상 제외된다.

**파라미터:**

| 파라미터 | 설명 | 예시값 |
|---|---|---|
| regBizSeq | 상위 사업장 순번 | 1 |
| authTypeCd | 사용자 권한 유형 | 'BIZ' 또는 'CENTER' |
| loginUserId | 로그인 사용자 ID | 'user01' |

**반환 컬럼:** bizSeq, bizNm, bizDivCd

```sql
-- 예시: regBizSeq=1, authTypeCd='BIZ', loginUserId='user01'
SELECT MB.biz_seq    AS bizSeq
     , MB.biz_nm     AS bizNm
     , MB.biz_div_cd AS bizDivCd
  FROM MDM_BIZ MB
  JOIN MDM_BIZ_BIZ MBB ON MB.biz_seq = MBB.biz_Seq
 WHERE MBB.ref_biz_seq = 1
   AND MB.biz_seq IN (SELECT biz_seq FROM MDM_USER_BIZ WHERE user_id = 'user01')
   AND MB.biz_div_cd != 'SHIPPER'   -- 화주 제외
 ORDER BY MB.biz_seq
```

---

### insertCenterAutorityToSuper

**용도:** 신규 센터 등록 시 슈퍼 관리자 권한을 가진 사용자 전원에게 해당 센터 접근 권한을 자동으로 부여한다. 이미 권한이 있는 사용자는 중복 삽입하지 않는다.

**파라미터:**

| 파라미터 | 설명 | 예시값 |
|---|---|---|
| centerSeq | 권한 부여 대상 센터 순번 | 5 |
| regBizSeq | 사업장 순번 | 100 |
| loginAuthTypeCd | 슈퍼 권한 코드 | 'SUPER' |
| regId | 등록자 ID | 'user01' |

```sql
-- 예시: centerSeq=5, regBizSeq=100, loginAuthTypeCd='SUPER'
INSERT INTO MDM_USER_CENTER (center_seq, user_id, reg_id, reg_dt)
  SELECT 5 AS center_seq
       , MU.user_id
       , 'user01' AS reg_id
       , FN_GET_DT('20260608120000') AS reg_dt
    FROM MDM_USER MU
    LEFT JOIN MDM_USER_CENTER MUC ON MU.user_id = MUC.user_id AND muc.center_seq = 5
   WHERE REG_BIZ_SEQ = 100
     AND AUTH_TYPE_CD = 'SUPER'
     AND MUC.center_seq IS NULL   -- 이미 권한이 없는 사용자만 삽입
```

---

### updateBizBiz

**용도:** 위탁 의뢰 수락 또는 거절 후 사업장-사업장 연결 관계(MDM_BIZ_BIZ)의 활성 상태를 재계산한다. 해당 사업장 조합에서 승인 사용 중인 센터가 하나라도 있으면 use_yn='Y', 모두 미사용이면 'N'으로 갱신한다.

**파라미터:**

| 파라미터 | 설명 | 예시값 |
|---|---|---|
| bizSeq | 의뢰를 보낸 사업장 순번 | 200 |
| regBizSeq | 센터 소유 사업장 순번 | 100 |
| modId | 수정자 ID | 'admin01' |
| modDt | 수정일시 | '20260608120000' |

```sql
-- 예시: bizSeq=200, regBizSeq=100
UPDATE MDM_BIZ_BIZ
   SET use_yn = A.useYn
     , mod_id = 'admin01'
     , mod_dt = FN_GET_DT('20260608120000')
  FROM (
        SELECT MBC.biz_seq, MBC.reg_biz_seq
             , CASE WHEN MAX(MBC.use_yn) = 'N' AND MIN(MBC.use_yn) = 'N' THEN 'N'
                    ELSE 'Y' END AS useYn
          FROM MDM_BIZ_CENTER MBC
         WHERE MBC.biz_seq = 200 AND MBC.reg_biz_seq = 100
         GROUP BY MBC.biz_seq, MBC.reg_biz_seq
  ) A
 WHERE MDM_BIZ_BIZ.biz_seq = A.biz_seq
   AND MDM_BIZ_BIZ.ref_biz_seq = A.reg_biz_seq
```
