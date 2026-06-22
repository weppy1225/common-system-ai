---
description: MyBatis Mapper.xml·Mapper.java 작성·수정 시 적용. SELECT/INSERT/UPDATE/DELETE 쿼리, 동적 SQL(where·if·foreach), 페이징, LIKE 검색(FN_CONCAT), 소프트삭제, Audit 컬럼, NEXTVAL 채번 패턴을 정의한다.
paths:
  - "**/*Mapper.xml"
  - "**/*Mapper.java"
---

# MyBatis XML 쿼리 작성 컨벤션

---

## 참조 문서 (SSoT)

| 주제 | 문서 |
|---|---|
| Mapper.java 시그니처·`@Param` | `patterns/30-backend/40-guide/04-mapper-writing-rules.md` |
| Mapper.xml 쿼리 패턴 (SELECT/INSERT/UPDATE/DELETE·페이징·동적 SQL) | `patterns/30-backend/40-guide/05-mapper-xml-writing-rules.md` |
| Dao의 Mapper 위임 | `patterns/30-backend/40-guide/03-dao-writing-rules.md` |
| 테이블·컬럼 정의 | `patterns/20-database/00-overview.md` |
| 공통코드(`_cd`) 값 | `spec/{프로젝트}/_knowledge/db-schema/90-common-code.md` |
| Mapper.java 시그니처·패턴·Dao 레이어 전체 구현 예제 | `patterns/20-database/30-convention/02-mybatis-convention.md` |

---

## §1 Mapper 메서드 네이밍

메서드 접두사 표(SSoT) → `patterns/20-database/30-convention/02-mybatis-convention.md §2.2` 참조
(`search*s`·`select*`·`insert*`/`insert*s`·`update*`/`update*s`·`delete*`/`delete*s`·`check*`·`get*`).

- 존재/중복 검증 조회는 `check*` 사용 (`exist*` 아님).
- 건수·단일 값 조회는 `get*` 사용 (`count*` 아님).

## §2 `@Param` 사용 기준

- 파라미터 2개 이상이면 반드시 `@Param` 지정
- DTO 1개만 넘길 때는 생략 가능

## §3 SELECT/INSERT/UPDATE/DELETE 공통 체크리스트

**SELECT**
- `use_yn` 컬럼이 있는 테이블은 `AND t.use_yn = 'Y'` 조건 추가 (조인 테이블 포함)
- `del_yn` 컬럼이 있는 테이블은 `AND t.del_yn = 'N'` 조건 추가
- `use_yn`/`del_yn` 컬럼이 없는 매핑·이력 테이블은 실제 스키마와 기존 Mapper 패턴을 따른다
- 동적 조건은 `<where>` + `<if>` 조합 사용
- 페이징: `LIMIT #{pageSize} OFFSET #{offset}` (offset은 Controller/Comp에서 계산해서 전달)

**INSERT**
- Audit 컬럼: `reg_id = #{regId}, reg_dt = NOW()`
- PK 채번: `NEXTVAL('{테이블명}_seq')` — 실제 시퀀스명은 psql `\d {테이블명}` 직접 조회

**UPDATE**
- Audit 컬럼: `mod_id = #{modId}, mod_dt = NOW()`
- 동적 SET: `<set>` + `<if>` 조합

**DELETE**
- `use_yn` 테이블: `UPDATE ... SET use_yn = 'N', mod_id = #{modId}, mod_dt = NOW()`
- `del_yn` 테이블: `UPDATE ... SET del_yn = 'Y', mod_id = #{modId}, mod_dt = NOW()`
- 삭제 플래그가 없는 순수 매핑·처리 테이블: 기존 Mapper 패턴 확인 후 `DELETE FROM` 허용

## §4 공통코드(`_cd`) 확인 절차

컬럼명이 `_cd`로 끝나면 반드시 `01-common-code.md`에서 허용 값을 확인 후 쿼리에 사용.

## §5 LIKE 검색 패턴

```sql
AND t.col_nm LIKE FN_CONCAT('%', #{keyword}, '%')
```

- 문자열 직접 연결(`|| '%'`) 금지
- `FN_CONCAT` 함수 사용 필수

## §6 금지 패턴 (BLOCKING)

| 금지 패턴 | 대체 |
|---|---|
| 삭제 플래그가 있는 테이블의 `DELETE FROM` | `UPDATE SET use_yn='N'` 또는 `UPDATE SET del_yn='Y'` |
| `WHERE 1=1` | `<where>` 태그 사용 |
| `!= null` | `@fw.tool.EmptyTool@notEmpty(param)` |
| `col LIKE '%' || #{v} || '%'` | `FN_CONCAT('%', #{v}, '%')` |
| `wms_inven*` 직접 DML | InvenManager 경유 (biz-framework.md 참조) |

---

## 재고·홀딩 테이블은 직접 쿼리 금지

`wms_inven`, `wms_inven_holding`, `wms_inven_inout` 직접 INSERT/UPDATE/DELETE 금지.
→ **InvenManager 경유**. 판단 기준·메서드는 `biz-framework.md` 참조.

---

## 상세 패턴 문서

Mapper.java 인터페이스, Mapper.xml 전체 구현 패턴, Dao 레이어, 동적 SQL 예제:
→ `patterns/20-database/30-convention/02-mybatis-convention.md`

SQL 텍스트 서식 (들여쓰기·anchor 규칙):
→ `patterns/20-database/30-convention/01-sql-query-style.md`
