---
title: MDBZ01 Mapper SQL · 사용처 매핑 (데이터 접근 계층)
description: mdbz01 MyBatis Mapper의 모든 statement를 호출 사슬(Controller→Comp→TxComp→Dao→Mapper→테이블)과 활성/레거시 상태로 정리한 데이터 접근 명세. data-model이 정의한 테이블을 실제로 어떻게 조회·변경하는지 기술하며, be-flow가 이를 조합한다.
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: reference
menu_code: mdbz01
domain: master
depends_on:
  - "70-knowledgebase/mdbz01/mdbz01-03-data-model.md"
related:
  - "70-knowledgebase/mdbz01/mdbz01-06-be-flow.md"
  - "70-knowledgebase/mdbz01/mdbz01-05-api.md"
tags:
  - detail-design
  - backend
  - mybatis
  - sql
  - 3pl
---

# MDBZ01 Mapper SQL · 사용처 매핑 (데이터 접근 계층)

> **데이터 접근 계층** 명세다. [`mdbz01-03-data-model.md`](mdbz01-03-data-model.md)가 테이블 *구조·관계*를 정의하면, 본 문서는 그 테이블을 **실제로 어떻게 조회·변경하는지(SQL)** 를 정의하고, [`mdbz01-06-be-flow.md`](mdbz01-06-be-flow.md)가 이 SQL들을 트랜잭션으로 *조합*한다. (`data-model → 본 문서 → be-flow` 순)
> 바이트 단위 원본은 `cloud-wms-be/src/main/java/be/md8000/mdbz01/MDBZ01Mapper.xml` (744줄) 참조. 본 문서는 **statement ↔ 호출 사슬 ↔ 대상 테이블 ↔ 활성/레거시**를 정리한다.
> 호출 사슬 규약: `Controller(엔드포인트) → Comp → TxComp(@Transactional) → Dao → Mapper(SQL) → 테이블`

## 1. 엔드포인트 → 트랜잭션 → Mapper 호출 사슬 (활성 경로)

| 엔드포인트 | Comp | TxComp | 호출 Mapper(순서) |
|---|---|---|---|
| GET `/{sel}` | `selectBiz` | — | `selectBiz` |
| POST `/` (수정) | `updateBiz` | `updateBizTX` | `selectBiz`(선조회) → `updateBiz` |
| GET `/{sel}/centers` | `selectBizCenter` | — | `selectBizCenter` |
| PUT `/centers` (저장) | `saveBizCenter` | `saveBizCenterTX` | (등록) `searchWhTemplate`·`checkDuplicateCenterNm`·`insertCenter`+`insertBizCenter`·`insertCenterAutorityToSuper`·`insertDefaultWh`+`insertbizWh`+`insertDefaultLoc` / (수정) `checkDuplicateCenterNm`·`checkExistTplBizCenter`·`updateBizCenter`+`updateCenter` / (삭제) `checkExistUserCenter`·`checkExistTplBizCenter`·`checkExistCenterWh`·`deleteBizCenter`+`deleteCenter`·`deleteCenterAutority` / (검증) `selectBizCenter` |
| POST `/tpl` (검색) | `searchTplBizCenter` | — | `searchTplBizCenter` |
| PUT `/tpl` (의뢰 신청) | `reqTplCenter` | `reqTplCenterTX` | `checkExistBizBiz`→`insertBizBiz` / `checkExistBizCenter`→(`updateBizCenter` \| `insertBizCenter`) |
| GET `/tpl` (P01 로드) | `selectTplBizCenter` | — | `selectTplBizCenter` |
| PATCH `/tpl` (P01 저장) | `update3plCenter` | `update3plCenterTX` | `updateTplCenter` (updateList 루프) |
| GET `editable/bizs/{reg}` | `searchEditableBizs` | — | `searchEditableBizs` |

> **DAO 복합 메서드 주의:** `Dao.insertCenter`=`insertCenter`+`insertBizCenter`, `Dao.updateCenter`=`updateBizCenter`+`updateCenter`, `Dao.deleteCenter`=`deleteBizCenter`+`deleteCenter`, `Dao.insertDefaultWh`=`insertDefaultWh`+`insertbizWh`+`insertDefaultLoc`. 1개 Dao 호출이 여러 테이블에 쓰기를 수행한다.

## 2. 레거시/미사용 경로 (⚠️ 현재 3개 화면 미연결)

| 엔드포인트 | Comp | TxComp | 호출 Mapper | 상태 |
|---|---|---|---|---|
| GET `/{sel}/tplReq` | `selectReqBizCenter` | — | `selectReqBizCenter` | 화면 미연결 |
| PATCH `/{selBiz}/tplReq` | `respTplCenter` | `respTplCenterTX` | `checkExistBizCenter` → `respTplCenter` → `updateBizBiz` → (수락 시)`insertBizWh` | 화면 미연결 (**BR-9 창고연결이 여기 있음**) |
| PATCH `/cancel` | `cancelRequest` | `cancelRequestTX` | `checkExistBizCenter`×2 → `cancelRequest`(물리 DELETE) | 화면 미연결 |

## 3. Mapper statement 전체 목록 (39개)

상태: 🟢 활성(화면 연결) · 🟠 레거시(엔드포인트 있으나 화면 미연결) · ⚫ Dead(호출자 없음/주석)

| statement | 종류 | 대상 테이블 | 용도 | 호출 Dao | 상태 |
|---|---|---|---|---|---|
| `selectBiz` | SELECT | MDM_BIZ ⟕ SM_FILE | 사업장 단건+로고 | selectBiz | 🟢 |
| `updateBiz` | UPDATE | MDM_BIZ | 사업장 수정 | updateBiz | 🟢 |
| `selectBizCenter` | SELECT | MDM_CENTER+MDM_BIZ_CENTER+MDM_BIZ | 센터목록(상태/소유 파생) | selectBizCenter | 🟢 |
| `insertCenter` | INSERT | MDM_CENTER | 센터 생성 | insertCenter | 🟢 |
| `insertBizCenter` | INSERT | MDM_BIZ_CENTER | 회사-센터 관계 생성 | insertCenter / insertBizCenter4Tpl | 🟢 |
| `updateCenter` | UPDATE | MDM_CENTER | 센터 수정 | updateCenter | 🟢 |
| `updateBizCenter` | UPDATE | MDM_BIZ_CENTER | 관계(note/cfm/use) 수정 | updateCenter / updateBizCenter4Tpl | 🟢 |
| `deleteCenter` | UPDATE | MDM_CENTER | 센터 소프트삭제(use_yn=N) | deleteCenter | 🟢 |
| `deleteBizCenter` | UPDATE | MDM_BIZ_CENTER | 관계 소프트삭제 | deleteCenter | 🟢 |
| `searchWhTemplate` | SELECT | MDM_WH+MDM_BIZ_WH | 기본창고 템플릿(TEMP_BIZ_SEQ) | searchWhTemplate | 🟢 |
| `insertDefaultWh` | INSERT | MDM_WH | 센터 기본창고 생성 | insertDefaultWh | 🟢 |
| `insertbizWh` | INSERT | MDM_BIZ_WH | 사업장-창고 연결 | insertDefaultWh | 🟢 |
| `insertDefaultLoc` | INSERT | MDM_LOC | 기본 로케이션 생성 | insertDefaultWh | 🟢 |
| `checkExistCenterWh` | SELECT | MDM_WH | 삭제가드: 창고존재(BR-4) | checkExistCenterWh | 🟢 |
| `checkExistUserCenter` | SELECT | MDM_USER_CENTER+MDM_USER | 삭제가드: 권한존재(BR-4) | checkExistUserCenter | 🟢 |
| `checkExistTplBizCenter` | SELECT | MDM_BIZ_CENTER | 수정/삭제가드: 위탁중(BR-3) | checkExistTplBizCenter | 🟢 |
| `checkDuplicateCenterNm` | SELECT | MDM_CENTER+MDM_BIZ_CENTER | 센터명 중복(BR-2) | checkDuplicateCenterNm | 🟢 |
| `insertCenterAutorityToSuper` | INSERT | MDM_USER_CENTER | 슈퍼권한 자동부여 | insertCenterAutorityToSuper | 🟢 |
| `deleteCenterAutority` | DELETE | MDM_USER_CENTER | 센터삭제 시 권한정리 | deleteCenterAutority | 🟢 |
| `selectTplBizCenter` | SELECT | MDM_CENTER+MDM_BIZ_CENTER+MDM_BIZ | **자기 센터(biz=reg)** 위탁정보 | selectTplBizCenter | 🟢 |
| `updateTplCenter` | UPDATE | MDM_CENTER | **tpl_yn·주소·연락처 수정(P01)** | updateTplCenter | 🟢 |
| `searchTplBizCenter` | SELECT | MDM_CENTER+MDM_BIZ_CENTER+MDM_BIZ | tpl_yn=Y 위탁가능 센터 검색 | searchTplBizCenter | 🟢 |
| `checkExistBizBiz` | SELECT | MDM_BIZ_BIZ | 회사간 관계 존재 | checkExistBizBiz | 🟢 |
| `insertBizBiz` | INSERT | MDM_BIZ_BIZ | 회사간 관계 생성 | insertBizBiz | 🟢 |
| `checkExistBizCenter` | SELECT | MDM_BIZ_CENTER | 상태판별(REQUEST/ACCEPT/DENIED) | checkExistBizCenter | 🟢(신청) / 🟠(응답·취소) |
| `searchEditableBizs` | SELECT | MDM_BIZ+MDM_BIZ_BIZ | 권한별 사업장 목록 | searchEditableBizs | 🟢 |
| `selectReqBizCenter` | SELECT | MDM_BIZ_CENTER+… | 들어온 의뢰 목록 | selectReqBizCenter | 🟠 |
| `respTplCenter` | UPDATE | MDM_BIZ_CENTER | 수락/거절(cfm_yn·use_yn) | respTplCenter | 🟠 |
| `updateBizBiz` | UPDATE | MDM_BIZ_BIZ | 센터 사용집계로 use_yn 재계산 | updateBizBiz | 🟠 |
| `insertBizWh` | INSERT | MDM_BIZ_WH | **3PL 수락 시 창고 자동연결(BR-9)** | insertBizWh | 🟠 |
| `cancelRequest` | DELETE | MDM_BIZ_CENTER | 의뢰 취소(물리삭제) | cancelRequest | 🟠 |
| `searchBizs` | SELECT | MDM_BIZ_BIZ+MDM_BIZ | 사업장 검색 | (없음) | ⚫ Signup 잔재 |
| `insertBiz` | INSERT | MDM_BIZ | 사업장 등록 | (없음) | ⚫ |
| `insertUserBiz` | INSERT | MDM_USER_BIZ | 권한사업장 등록 | (없음) | ⚫ |
| `insertDocNo` | INSERT | MDM_DOC_NO | 문서번호 시드 | (없음) | ⚫ |
| `reqTplBiz` | SELECT | MDM_BIZ_CENTER+… | 의뢰 사업장 목록 | (없음) | ⚫ |
| `deleteUserCenter` | DELETE | MDM_USER_CENTER | 센터-유저 삭제 | deleteUserCenter(미호출) | ⚫ |
| `updateAllCenterTplYnToN` | UPDATE | MDM_CENTER | TPL→OWN 전환 시 tpl_yn 일괄 N | updateAllCenterTplYnToN | ⚫ 호출부 주석처리 |

## 4. 비즈니스 로직이 담긴 핵심 SQL 발췌

### 4-1. `selectBizCenter` — 센터 상태·소유 파생 (🟢 메인 그리드)
```sql
SELECT MBC.reg_biz_seq AS bizSeq, MB.biz_nm AS bizNm, MC.center_seq AS centerSeq
     , MC.center_nm, MC.tpl_yn AS tplYn, MC.post_no, MC.addr, MC.addr_dtl, MC.tel, MC.note
     , MBC.use_yn AS useYn, MBC.cfm_yn AS cfmYn
     , CASE WHEN MBC.reg_biz_seq = #{regBizSeq} THEN 'Y' ELSE 'N' END AS editableYn
     , CASE WHEN MBC.biz_seq = MBC.reg_biz_seq THEN 'N' ELSE 'Y' END AS tplCenterYn  -- 위탁센터 여부
     , (SELECT COUNT(*) FROM MDM_BIZ_CENTER WHERE biz_seq != #{bizSeq} AND center_seq = MC.center_seq AND cfm_yn='Y' AND use_yn='Y') AS authCnt
     , (SELECT COUNT(*) FROM MDM_BIZ_CENTER WHERE biz_seq != #{bizSeq} AND center_seq = MC.center_seq AND cfm_yn='N') AS unauthCnt
  FROM MDM_CENTER MC
  JOIN MDM_BIZ_CENTER MBC ON MC.center_seq = MBC.center_seq
  LEFT JOIN MDM_BIZ MB ON MBC.reg_biz_seq = MB.biz_seq
 WHERE MBC.biz_seq = #{bizSeq} AND MC.use_yn = 'Y'
 ORDER BY useYn DESC, bizSeq, centerSeq
```
> FE의 `tplCenterYn`/`cfmYn`/`useYn` 회색표시 규칙([screen §2-3])이 이 컬럼들에서 나온다.

### 4-2. `checkExistBizCenter` — 상태머신 코드값 파생 (data-model §3의 근거)
```sql
SELECT MBC.center_seq AS field,
       CASE WHEN MBC.cfm_yn='Y' AND MBC.use_yn='Y' THEN 'ACCEPT'
            WHEN MBC.cfm_yn='Y' AND MBC.use_yn='N' THEN 'DENIED'
            WHEN MBC.cfm_yn='N' AND MBC.use_yn='N' THEN 'REQUEST' END AS invalidValue,
       'DUPLICATE' AS code
  FROM MDM_BIZ_CENTER MBC
 WHERE MBC.biz_seq = #{bizSeq} AND MBC.center_seq = #{centerSeq}
```

### 4-3. `searchTplBizCenter` — 위탁가능 센터 + 신청상태 (🟢 P02 검색)
```sql
SELECT MB.biz_seq, MB.biz_nm, MC.center_seq, MC.center_nm, MC.addr, MC.addr_dtl, MC.tel, MC.email, MC.note
     , COALESCE((SELECT CASE WHEN MBC2.cfm_yn='Y' AND MBC2.use_yn='Y' THEN '승인'
                             WHEN MBC2.cfm_yn='Y' AND MBC2.use_yn='N' THEN '거절'
                             WHEN MBC2.cfm_yn='N' AND MBC2.use_yn='N' THEN '신청중' END
                  FROM MDM_BIZ_CENTER MBC2
                 WHERE MBC2.reg_id = #{userId} AND MBC2.center_seq = MC.center_seq), '신청가능') AS reqSts
  FROM MDM_CENTER MC
  JOIN MDM_BIZ_CENTER MBC ON MC.center_seq = MBC.center_seq
  JOIN MDM_BIZ MB ON MBC.biz_seq = MB.biz_seq
 WHERE MC.tpl_yn = 'Y' AND MB.biz_div_cd = '${BIZ_DIV_TPL}' AND MC.use_yn='Y' AND MBC.use_yn='Y'
   AND MB.biz_seq NOT IN (SELECT biz_seq FROM MDM_USER_BIZ WHERE user_id = #{userId})
   AND MBC.biz_seq = MBC.reg_biz_seq
   /* + bizNm/centerNm/addr LIKE 동적조건 */
 ORDER BY MB.reg_dt
```
> P02 그리드의 `reqSts`(신청가능/신청중/승인/거절)는 **로그인 사용자(`reg_id`) 기준 서브쿼리**로 산출된다.

### 4-4. `updateTplCenter` (= Comp `update3plCenter`) — P01 저장의 실체 (🟢)
```sql
UPDATE MDM_CENTER
   SET tpl_yn = #{tplYn}, addr = #{addr}, addr_dtl = #{addrDtl}, post_no = #{postNo}
     , tel = #{tel}, email = #{email}, note = #{note}, mod_id = #{modId}, mod_dt = FN_GET_DT(#{modDt})
 WHERE center_seq = #{centerSeq}
```
> **P01(센터정보수정)은 `MDM_CENTER.tpl_yn`과 주소/연락처만 갱신**한다. `cfm_yn/use_yn` 상태머신은 건드리지 않는다 (→ §5 정정 사항).

### 4-5. `searchEditableBizs` — 권한별 분기 (🟢 콤보)
```sql
SELECT MB.biz_seq, MB.biz_nm, MB.biz_div_cd
  FROM MDM_BIZ MB JOIN MDM_BIZ_BIZ MBB ON MB.biz_seq = MBB.biz_seq
 WHERE MBB.ref_biz_seq = #{regBizSeq}
   /* authTypeCd=BIZ → MDM_USER_BIZ 소속 / =CENTER → MDM_USER_CENTER 권한센터의 biz */
   AND MB.biz_div_cd != '${BIZ_DIV_SHIPPER}'
 ORDER BY MB.biz_seq
```

> 단순 CRUD(`insertBiz`류, `insertDefaultWh`류 등)의 컬럼 매핑은 [`mdbz01-03-data-model.md`](mdbz01-03-data-model.md) + 운영/dev DB 직접 조회(공용 §3)로 갈음한다. 바이트 단위 SQL은 `MDBZ01Mapper.xml` 원본 참조.

## 5. 핵심 발견 (다른 문서 정정 근거)

소스 사슬 확인 결과, 상위 설계 문서의 **라벨을 정정**했다.

1. **P01(`mdbz01Set`)은 "위탁 수락/거절"이 아니다.** 실제는 Controller `update3plCenter` = "대행의뢰센터지정 / 센터 수정(위탁)" → `updateTplCenter`로 **자기 센터의 `tpl_yn`·주소·연락처를 갱신**(대행 제공 등록). 즉 *"내 센터를 위탁 마켓에 등록·수정"* 화면이다.
2. **진짜 수락/거절**(`respTplCenter`, `MDM_BIZ_CENTER.cfm_yn/use_yn` + BR-9 `insertBizWh`)은 **PATCH `/tplReq`** 경로이며 **현재 3개 vue 화면에 연결되어 있지 않다**(레거시/미완성).
3. 위 사실에 따라 [`mdbz01-02-screen.md`] §4·§5, [`mdbz01-05-api.md`] §2·§3, [`mdbz01-07-fe-flow.md`] §1의 P01 표기를 **"위탁센터 정보수정(tpl_yn 등록)"으로 정정 완료**했다. (이전 "위탁 응답/수락·거절" 표기는 오기재)
4. `cfm_yn/use_yn` 상태머신(data-model §3)은 **신청(`reqTplCenter`)에서 생성·판별**되나, 그 상태를 변경하는 **수락/거절(`respTplCenter`)이 미연결**이므로, 현재 라이브에서 상태는 `REQUEST`에 머문다(추정). **추후 개발 시 수락/거절 연결 필요.**
