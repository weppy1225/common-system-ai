---
description: oms-be MyBatis Mapper.xml SQL 텍스트 서식 중 OMS 고유 차이분(DB_PREFIX 동적주입·OMS 실제 테이블/별칭·쿼리주석 [검색]/[수정] 표기). SQL 작성·리뷰 시 공통 서식과 함께 적용한다.
---

# SQL 쿼리 스타일 가이드 — OMS 고유 차이

> 공통 SQL 서식 골격(대소문자·anchor 정렬·comma-first·and-first·INSERT/UPDATE/DELETE/UNION ALL 서식·종합 요약표)은 [common 문서](../../../../../patterns/20-database/30-convention/01-sql-query-style.md)와 동일하다. 이 문서는 **OMS 고유 차이분만** 담는다.

전제(숨은 전제 명시): OMS DB = PostgreSQL. ERP = SQL Server (멀티 DB 동시 사용). DB 벤더 prefix 는 `${@fw.config.DBConfig@DB_PREFIX}` 로 동적 주입한다.

근거(OMS 실제 적용 확인): `oms-be/src/main/java/bc/co1000c/mypg01c/MYPG01CMapper.xml` — OMS Mapper 는 공통 서식을 동일하게 따른다.

---

## 1. OMS 고유 차이 (vs common)

| 항목 | common 일반 | OMS 고유 |
|---|---|---|
| DB 벤더 prefix | (해당 없음) | `${@fw.config.DBConfig@DB_PREFIX}` 로 동적 주입(ERP=SQL Server 멀티 DB 대응) |
| 쿼리 상단 주석 동작 구분 | `(단 건)`/`(여러 건)` | `[검색]`/`[수정]` 또는 `(단 건)`/`(여러 건)` 표기 |
| 예시 테이블 | `WMS_OUTWH`, `MDM_PROD`, `SM_COMM_D` 등 WMS 도메인 | `MDM_USER`, `MDM_CONT`, `MDM_USER_BIZ`, `MDM_BIZ_CONT`, `SM_USER_PWD_HISTORY` 등 OMS 도메인 |
| 예시 별칭(alias) | `WO`, `WOP`, `MP` | `MU`, `MC`, `MBC`, `MUB` |
| 금지패턴(`WHERE 1=1` 등)·소프트삭제 컬럼 판단 SSoT | (common 문서 내) | `.claude/rules/oms-db-convention.md §4·§8` |

---

## 2. OMS 쿼리 상단 주석 예시 ([검색]/[수정] 표기)

근거(OMS 실제 `MYPG01CMapper.xml`):
```sql
/* MYPG01CMapper.searchMyPage 마이페이지 [검색] */
/* MYPG01CMapper.updateMyPage 마이페이지 비밀번호 [수정] */
```

- 클래스명·메서드명 사이는 `.`, 메서드명·설명 사이는 **공백 2칸**(common 동일).

---

## 3. OMS 실제 SELECT 정렬 예시 (MYPG01CMapper.searchMyPage)

근거(OMS 실제): `MDM_USER` / `MDM_USER_BIZ` / `MDM_BIZ_CONT` 조인, 별칭 `MU`/`MUB`/`MBC`/`MC`.

```sql
        SELECT MU.user_id                AS userId
             , MU.tel                    AS telEncrypt
             , MC.cont_nm                AS contNm
             , MC.replace_prod_accept_yn AS replaceProdAcceptYn
          FROM MDM_USER     MU
          JOIN MDM_USER_BIZ MUB ON MU.user_id  = MUB.user_id
          JOIN MDM_BIZ_CONT MBC ON MUB.biz_seq = MBC.biz_seq
         WHERE MU.user_id = #{userId}
```

---

## 4. OMS DB_PREFIX 함수 (이력 컬럼·UPDATE)

MUST: 이력/일시 컬럼은 DB 벤더 prefix 함수 `${@fw.config.DBConfig@DB_PREFIX}FN_GET_DT(...)` 로 작성. 일반 파라미터는 반드시 `#{}`.

```sql
UPDATE MDM_USER
   SET password = #{password}
     , mod_id   = #{modId}
     , mod_dt   = ${@fw.config.DBConfig@DB_PREFIX}FN_GET_DT(#{modDt})
 WHERE user_id  = #{userId}
```

> `<insert>`/`<update>` MyBatis 태그·시퀀스·DB_PREFIX 함수 **구현 예시는 → [02-mybatis-convention.md](./02-mybatis-convention.md) §4**(SSoT). 소프트삭제 컬럼(`use_yn`/`del_yn`) 판단은 → `.claude/rules/oms-db-convention.md §4`.
