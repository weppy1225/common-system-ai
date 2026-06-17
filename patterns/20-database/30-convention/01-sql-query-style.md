---
title: SQL 쿼리 스타일 가이드
description: WMS 프로젝트에서 SQL 쿼리를 작성하거나 리뷰할 때 적용해야 하는 서식(들여쓰기·정렬·대소문자) 규칙
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: instruction
domain: database
tags:
  - database
  - sql
  - query-style
  - formatting
  - mybatis
related:
  - patterns/20-database/30-convention/02-mybatis-convention.md
---

# SQL 쿼리 스타일 가이드 (SQL Query Style Guide)
> 이 프로젝트의 SQL 쿼리 작성 시 준수해야 할 **서식(들여쓰기·정렬·대소문자) 전용** 가이드입니다.
> Claude가 쿼리를 작성하거나 리뷰할 때 반드시 이 가이드를 따릅니다.
>
> **본 문서 범위**: SQL 텍스트 서식만 다룹니다.
> MyBatis 구현 패턴(`<if>`, `<foreach>`, `<choose>`, `resultMap`, namespace 등)은
> [02-mybatis-convention.md](./02-mybatis-convention.md) 참조.

---

## 1. 대소문자 규칙

| 대상 | 표기 | 예시 |
|---|---|---|
| SQL 예약어 | **대문자** | `SELECT`, `FROM`, `WHERE`, `AND`, `OR`, `JOIN`, `ON`, `AS`, `IN`, `IS NULL`, `NOT`, `UNION ALL`, `ORDER BY`, `GROUP BY`, `HAVING`, `CASE`, `WHEN`, `THEN`, `ELSE`, `END`, `INSERT INTO`, `UPDATE`, `SET`, `DELETE FROM`, `CAST`, `COALESCE`, `SUM`, `MAX`, `MIN`, `COUNT` |
| 테이블명 | **대문자** | `WMS_OUTWH`, `MDM_PROD`, `SM_COMM_D` |
| 테이블 별칭(alias) | **대문자 약어** | `WO`, `WOP`, `MP`, `ML`, `MW` |
| 컬럼명 | **소문자** | `biz_seq`, `outwh_seq`, `prod_nm` |
| Java 매핑 별칭 (AS 뒤) | **camelCase** | `bizSeq`, `outwhSeq`, `prodNm` |
| 인라인 뷰(서브쿼리) 별칭 | **대문자** | `INVEN`, `OUTWH`, `ASSIGN`, `A` |
| MyBatis 파라미터 | **camelCase** | `#{bizSeq}`, `#{outwhProdSeq}` |
| 문자열 리터럴 | **그대로** | `'Y'`, `'N'`, `'UNIT_CD'` |

---

## 2. 쿼리 상단 주석

모든 쿼리의 **첫 번째 줄**에 반드시 작성합니다.

```sql
/* Mapper클래스명.메서드명 한글 설명 */
```

- Mapper클래스명과 메서드명 사이는 `.` 으로 구분
- 메서드명과 한글 설명 사이는 **공백 2칸**
- 단건 / 다건 구분이 필요한 경우 `(단 건)`, `(여러 건)` 으로 괄호 표기

**예시:**
```sql
/* OWRQ01Mapper.searchOutwhProds 출고 품목 조회 (여러 건) */
/* OWRQ01Mapper.searchOutwhProd 출고 품목 조회 (단 건) */
/* OWRQ01Mapper.insertOutwhAssigns 출고지시 지정데이터 일괄 등록 */
```

---

## 3. 키워드 세로 정렬 — anchor 규칙

> 이 규칙이 SELECT / FROM / JOIN / WHERE / ORDER BY / GROUP BY 모든 절의 들여쓰기 기준입니다.

### 3.1 anchor 정의

```
anchor = SELECT의 시작 indent + len("SELECT")
```

- `SELECT`의 마지막 글자 **T**가 `anchor` 열에 위치합니다.
- **모든 절의 마지막 글자**가 동일한 `anchor` 열에 오도록 들여쓰기를 맞춥니다.
- 각 키워드의 indent = `anchor - len(keyword)`

| 키워드 | 길이 | indent 계산 (anchor=14 예시) | 마지막 글자 |
|---|---|---|---|
| `SELECT` | 6 | 14 - 6 = **8** | **T** = col 14 |
| `FROM` | 4 | 14 - 4 = **10** | **M** = col 14 |
| `WHERE` | 5 | 14 - 5 = **9** | **E** = col 14 |
| `JOIN` | 4 | 14 - 4 = **10** | **N** = col 14 |
| `INNER JOIN` | 10 | 14 - 10 = **4** | **N** = col 14 |
| `LEFT JOIN` | 9 | 14 - 9 = **5** | **N** = col 14 |
| `AND` (WHERE 하위) | 3 | 14 - 3 = **11** | **D** = col 14 |
| `ORDER BY` | 8 | 14 - 8 = **6** | **Y** = col 14 |
| `GROUP BY` | 8 | 14 - 8 = **6** | **Y** = col 14 |
| `HAVING` | 6 | 14 - 6 = **8** | **G** = col 14 |
| `UNION ALL` | 9 | 14 - 9 = **5** | **L** = col 14 |

```sql
        SELECT                            -- T = col 14  (anchor=14, indent=8)
               wi.prod_id   AS prodId     -- 첫 컬럼: col 16 시작 (indent=15)
             , wi.wh_id     AS whId       -- 콤마: col 14 (indent=13), 컬럼: col 16
          FROM WMS_INVEN WI               -- M = col 14  (indent=10)
    INNER JOIN MDM_WH MW ON ...           -- N = col 14  (indent=4)
         WHERE wi.inven_qty > 0           -- E = col 14  (indent=9)
           AND wi.del_yn = 'N'            -- D = col 14  (indent=11)
       GROUP BY wi.prod_id                -- Y = col 14  (indent=6)
       ORDER BY wi.prod_id                -- Y = col 14  (indent=6)
```

### 3.2 인라인뷰 내부

인라인뷰 내부의 `SELECT`를 기준으로 **anchor를 재계산**하여 동일 규칙을 적용합니다.

```sql
FROM WMS_INVEN WI -- 외부 anchor 기준
JOIN ( -- 인라인뷰 시작
            SELECT                        -- 내부 anchor 재계산
                   A.prod_id  AS prod_id  -- 첫 컬럼: 내부 anchor+2
                 , A.wh_id    AS wh_id
              FROM WMS_ASSIGN A           -- 내부 FROM: 내부 anchor 기준
             WHERE A.del_yn = 'N'         -- 내부 WHERE: 내부 anchor 기준
       ) ASSIGN ON WI.prod_id = ASSIGN.prod_id
```

---

## 4. SELECT 절

### 4.1 컬럼 나열 — comma-first + AS 정렬

> **comma-first 채택 이유**: 컬럼을 추가/삭제할 때 앞줄이 아닌 해당 줄만 수정하면 되어 **가독성**과 **유지보수성**이 높다.
> 또한 콤마가 줄 앞에 오면 누락 여부를 한눈에 확인할 수 있다.

- `SELECT` 키워드 다음 줄부터 컬럼 나열
- **첫 번째 컬럼 및 이후 모든 컬럼**의 시작 위치는 `anchor + 2` (col `anchor+2`)
- **콤마(`,`)**: `anchor` 열에 위치 (comma-first)
- `AS` 키워드 기준으로 컬럼명과 별칭을 **세로 정렬** (가장 긴 lhs 기준 고정폭)

```sql
SELECT
       WO.biz_seq               AS bizSeq
     , WO.center_seq            AS centerSeq
     , WO.outwh_seq             AS outwhSeq
     , WOP.outwh_prod_seq       AS outwhProdSeq
     , WOP.outwh_prod_sts_cd    AS outwhProdStsCd
     , MP.prod_no               AS prodNo
     , MP.prod_nm               AS prodNm
```

### 4.2 정렬 기준 (들여쓰기) 수치 정리

```
anchor = SELECT indent + 6

첫 번째 컬럼 indent = anchor + 1 → col anchor+2 에서 시작
콤마 indent = anchor - 1 → col anchor 에 콤마
콤마 뒤 컬럼 indent = anchor + 1 → col anchor+2 에서 시작 (첫 컬럼과 동일)
```

- 첫 컬럼과 이후 콤마 컬럼의 **컬럼 시작 위치가 동일** (col `anchor+2`)
- 콤마는 SELECT 의 **T**와 같은 열에 위치

### 4.3 함수 / 표현식 컬럼

```sql
     , COALESCE(WOO.outwh_req_qty, 0)            AS outwhReqQty
     , SUM(A.outwh_req_qty)                       AS outwh_req_qty
     , 0                                          AS ex_qty
     , NULL                                       AS outwh_tran_seq
```

---

## 5. FROM / JOIN 절

### 5.1 기본 구조

- 모든 `FROM`, `JOIN`(종류 무관)의 **마지막 글자(M/N)**를 `anchor` 열에 정렬
- `FROM`과 `JOIN`이 혼재할 때, 가장 긴 키워드(`INNER JOIN` = 10글자)의 N이 `anchor`에 오도록 각 키워드 앞에 패딩
- `ON` 조건은 `JOIN` 라인 끝 테이블별칭 뒤에 위치 (별도 줄 사용 지양)

```sql
          FROM WMS_OUTWH        WO
     INNER JOIN WMS_OUTWH_PROD  WOP ON WO.outwh_seq  = WOP.outwh_seq
     INNER JOIN MDM_PROD        MP  ON WOP.prod_seq   = MP.prod_seq
      LEFT JOIN MDM_WH          MW  ON WOP.wh_seq     = MW.wh_seq
```

### 5.2 JOIN 종류 선택

| 상황 | 키워드 |
|---|---|
| 필수 조인 (없으면 행 제외) | `JOIN` 또는 `INNER JOIN` |
| 선택적 조인 (없어도 행 유지) | `LEFT JOIN` |
| 교차 조인 | `CROSS JOIN` |

> `JOIN`과 `INNER JOIN`은 혼용 가능하나, 한 쿼리 내에서는 일관성 유지 권장

### 5.3 다중 ON 조건 정렬

ON 조건이 2개 이상일 경우 줄바꿈 후 `AND`를 선행으로 정렬합니다.

- **`AND`의 마지막 글자 `D`** = **`ON`의 마지막 글자 `N`** 과 동일한 열

```sql
INNER JOIN WMS_INVEN_SKU WIS ON WI.biz_seq = WIS.biz_seq
                              AND WI.prod_seq = WIS.prod_seq
                              AND WI.sku1     = WIS.sku1
                              AND WI.sku2     = WIS.sku2
```

> `ON`의 N과 `AND`의 D가 같은 열에 위치합니다.
> `AND` indent = ON의 'O' 시작 위치 - 1

### 5.4 인라인 뷰(서브쿼리) JOIN

인라인 뷰의 닫는 괄호 `)` 뒤에 별칭을 붙이고, `ON` 절은 동일하게 정렬합니다.

```sql
JOIN (SELECT A.outbiz_seq
           , A.outbiz_prod_seq
           , SUM(A.outwh_req_qty) AS outwh_req_qty
        FROM WMS_OUTBIZ_OUTWH A
       WHERE A.del_yn = 'N'
         AND A.outwh_seq = #{outwhSeq}
       GROUP BY A.outbiz_seq, A.outbiz_prod_seq
     )                  WOO  ON WOP.outbiz_seq      = WOO.outbiz_seq
                             AND WOP.outbiz_prod_seq = WOO.outbiz_prod_seq
```

---

## 6. WHERE 절

### 6.1 and-first 방식

- `WHERE`와 `AND`의 **마지막 글자(E/D)**가 모두 `anchor` 열에 정렬 (§3-1 규칙 동일)
- `AND`는 줄 **앞**에 위치 (and-first)

```sql
         WHERE WO.outwh_seq     = #{outwhSeq}
           AND WOP.outwh_prod_seq = #{outwhProdSeq}
           AND WO.biz_seq        = #{bizSeq}
```

### 6.2 조건 인라인 주석

조건의 **의도나 이유**를 우측에 한글 주석으로 명시합니다.

```sql
           AND WI.inven_qty > 0            /* 가용재고가 남은 재고만 */
           AND MW.available_inven_yn = 'Y' /* 가용재고 창고 */
           AND MW.pick_yn = 'Y'
```

> MyBatis `<where>` 태그·`<if>` 동적 조건 등 구현 패턴은
> [02-mybatis-convention.md](./02-mybatis-convention.md) 참조.

---

## 7. ORDER BY / GROUP BY 절

- **마지막 글자 `Y`** 가 `anchor` 열에 위치 (§3-1 규칙 동일)
- 한 줄로 나열 (컬럼이 많아도 줄바꿈 없이 작성)
- 정렬 기준 컬럼은 업무 논리 순서대로 명시

```sql
       ORDER BY MP.prod_no, MP.prod_nm, WOP.est_mng_ymd, WOP.est_exp_ymd, WOP.est_lot_no

       GROUP BY A.outbiz_seq, A.outbiz_prod_seq
```

---

## 8. INSERT 절

### 8.1 컬럼 목록

- `INSERT INTO 테이블명` 다음 줄에 `(` 로 시작하여 컬럼 목록 나열
- 컬럼이 많을 경우 논리적 그룹별로 줄바꿈

```sql
INSERT INTO WMS_OUTWH_ASSIGN
( biz_seq, center_seq, req_seq, req_prod_seq, prod_seq, wh_seq, loc_seq
, sku1, sku2
, mng_ymd, exp_ymd, lot_no, req_qty, req_no, strng_asgn_yn, reg_id, reg_dt )
```

### 8.2 Bulk INSERT VALUES 반복 서식

VALUES 행은 컬럼 목록과 동일한 그룹 단위 줄바꿈을 유지합니다.

```sql
VALUES
( :bizSeq, :centerSeq, :reqSeq, :reqProdSeq
, :prodSeq, :whSeq, :locSeq
, :sku1, :sku2
, :mngYmd, :expYmd, :lotNo, :reqQty )
```

> MyBatis `<foreach>` 사용 패턴은
> [02-mybatis-convention.md](./02-mybatis-convention.md) 참조.

---

## 9. UPDATE 절

- `SET` 다음 줄부터 comma-first 방식으로 컬럼 나열
- `FROM` 절을 사용한 서브쿼리 UPDATE 패턴 지원 (PostgreSQL 스타일)
- **anchor 규칙**: UPDATE 문은 `SET`, `FROM`, `WHERE` 절의 마지막 글자를 동일 열에 정렬 (단순 UPDATE 기준 — `SET`의 `T`, `WHERE`의 `E`가 같은 anchor 열)

```sql
UPDATE WMS_OUTWH_ASSIGN
SET req_qty = req_qty + ASSIGN.reqQty
     , mod_id  = ASSIGN.modId
     , mod_dt  = ASSIGN.modDt
FROM (
         SELECT outwhAssignSeq
              , SUM(reqQty) AS reqQty
              , MAX(modId)  AS modId
              , MAX(modDt)  AS modDt
           FROM ( /* MyBatis foreach UNION ALL 반복 — 02-mybatis-convention.md 참조 */
                SELECT :outwhAssignSeq AS outwhAssignSeq
                     , :reqQty         AS reqQty
                     , :modId          AS modId
                     , :modDt          AS modDt
                ) A
          GROUP BY outwhAssignSeq
       ) ASSIGN
WHERE WMS_OUTWH_ASSIGN.outwh_assign_seq = ASSIGN.outwhAssignSeq
```

---

## 10. DELETE 절

> | 테이블 유형 | 삭제 방식 | 비고 |
> |---|---|---|
> | `MDM_*` 기준정보 테이블 | 논리삭제 `UPDATE SET use_yn = 'N'` | 조회 조건 `AND use_yn = 'Y'` 필수 |
> | `WMS_*` 업무 테이블 | `del_yn` 컬럼이 있으면 논리삭제 `UPDATE SET del_yn = 'Y'` | 조회 조건 `AND del_yn = 'N'` 필수 |
> | 삭제 플래그 없는 매핑·처리 테이블 | 물리삭제 `DELETE FROM` | 기존 소스/스키마 확인 |

```sql
-- MDM_* 기준정보 테이블: 논리삭제
UPDATE MDM_PROD
   SET use_yn = 'N'
     , mod_id = #{modId}
     , mod_dt = NOW()
 WHERE prod_seq = #{prodSeq}

-- 삭제 플래그 없는 매핑·처리 테이블: 물리삭제
DELETE FROM WMS_OUTWH_ASSIGN
 WHERE outwh_assign_seq IN ( :seq1, :seq2, ... )
```

> MyBatis `<foreach>` IN절 사용 패턴은
> [02-mybatis-convention.md](./02-mybatis-convention.md) 참조.

---

## 11. UNION ALL 패턴

- 각 SELECT 블록 내부도 동일한 컬럼 정렬 스타일 유지
- 서브쿼리 내부 컬럼 별칭은 외부에서 참조하므로 `snake_case` 사용
- `UNION ALL` 키워드는 별도 줄에 작성, **마지막 글자 `L`이 `anchor` 열**에 위치

```sql
FROM (
      SELECT
             WOA.req_seq          AS outwh_seq
           , NULL                 AS outwh_tran_seq
           , WOA.outwh_assign_seq AS outwh_assign_seq
           , WOA.req_qty          AS req_qty
           , 0                    AS ex_qty
        FROM WMS_OUTWH_PROD WOP
        JOIN WMS_OUTWH_ASSIGN WOA ON WOP.outwh_seq    = WOA.req_seq
                                  AND WOP.outwh_prod_seq = WOA.req_prod_seq
       WHERE WOA.req_seq = #{outwhSeq}
      UNION ALL
      SELECT
             WO.outwh_seq         AS outwh_seq
           , WOT.outwh_tran_seq   AS outwh_tran_seq
           , NULL                 AS outwh_assign_seq
           , WOT.proc_qty         AS req_qty
           , WOT.ex_qty           AS ex_qty
        FROM WMS_OUTWH WO
        JOIN WMS_OUTWH_TRAN WOT ON WO.outwh_seq = WOT.outwh_seq
       WHERE WOT.outwh_seq = #{outwhSeq}
     ) INVEN
```

---

## 12. MyBatis 구현 패턴 (별도 문서)

본 문서는 SQL 서식 전용입니다. 아래 구현 패턴은
[02-mybatis-convention.md](./02-mybatis-convention.md)를 참조하세요.

- `<if>`, `<choose>` / `<when>` / `<otherwise>` 동적 분기
- `<foreach>` IN절 / Bulk INSERT / UNION ALL 반복
- `<where>` 동적 WHERE
- `<include refid>` 공통 SQL 재사용
- `<resultMap>`, `<id>`, `<result>`, `<collection>` 매핑
- OGNL 정적 메서드 / 필드 참조 (`@fw.tool.EmptyTool@notEmpty`, `${@fw.config.DBConfig@DB_PREFIX}` 등)
- `#{}` 파라미터 vs `${}` 정적 치환 사용 기준

---

## 13. 종합 스타일 요약표

| 항목 | 규칙 |
|---|---|
| SQL 예약어 | **대문자** |
| 테이블명 / 함수명 | **대문자** |
| 컬럼명 | **소문자** (snake_case) |
| 테이블 별칭 | **대문자** 약어 |
| Java 매핑 별칭 | **camelCase** |
| 서브쿼리 내부 별칭 | snake_case (외부 참조용) |
| **키워드 정렬 기준** | **anchor = SELECT indent + 6** |
| **각 키워드 indent** | **anchor - len(keyword)** → 끝 글자가 anchor 열에 일치 |
| SELECT 컬럼 구분자 | **comma-first** — 콤마가 anchor 열에 위치 |
| 컬럼 시작 위치 | anchor + 2 열 (첫 컬럼 / 콤마 뒤 컬럼 동일) |
| AS 정렬 | 최장 lhs 기준 **고정폭 세로 정렬** |
| WHERE/AND 방식 | **and-first**, D가 anchor 열 |
| JOIN ON 다중 조건 | AND의 **D** = ON의 **N** 같은 열 |
| ORDER BY / GROUP BY | **Y** 가 anchor 열 |
| 조건 설명 | 우측 인라인 한글 주석 `/* */` |
| 파라미터 | `#{}` (동적 DB prefix 한정 `${}`) |
| 쿼리 주석 | `/* Mapper명.메서드명 한글설명 */` (공백 **2칸**) |
| WHERE 1=1 | **사용 금지** → and-first 방식 사용 |
| 인라인뷰 내부 | 동일 anchor 규칙 **재귀 적용** |
