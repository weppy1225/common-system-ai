---
description: OMS 도메인 MyBatis Mapper.xml·Dao 작성 시 common DB 컨벤션 대비 OMS 고유 판단 기준·금지만 적용. 고객사가 달라도 OMS 도메인이면 동일 규칙 적용. Mapper.xml 또는 Dao를 다룰 때 로딩한다.
paths:
  - "**/*Mapper.xml"
  - "**/*Dao.java"
  - "**/*Mapper.java"
---

# OMS DB(MyBatis) 개발 규칙 — OMS 고유 판단 기준

> 공통 골격은 [DB 컨벤션](./db-convention.md) 과 동일하다. 이 문서는 **OMS 고유 판단 기준·금지만** 담는다. 상세 작성 패턴은 아래 patterns·소스를 본다.
> 전제: OMS=PostgreSQL + ERP=SQL Server 멀티DB · MyBatis.
> 고객사별 프로젝트 경로(`$PROJECT`, `$BE_DIR`) 도출 → `.claude/rules/repo-paths.md`.

## 상세는 어디에 (라우팅)

| 필요한 것 | 위치 |
|---|---|
| SQL 서식 | `spec/{$PROJECT}/_knowledge/patterns/db/01-sql-query-style.md` |
| MyBatis 구현 | `spec/{$PROJECT}/_knowledge/patterns/db/02-mybatis-convention.md` |
| 명명 규칙 | `spec/{$PROJECT}/_knowledge/patterns/db/03-naming-rule.md` |
| 채번(시퀀스·문서번호) | `spec/{$PROJECT}/_knowledge/patterns/be/03-numbering-module.md` |
| 테이블·컬럼·코드값 | `{$BE_DIR}/DEV_DOC/erd/oms.exerd` · `spec/{$PROJECT}/_knowledge/db-schema/90-common-code.md` · `fw/constant/OMSPool.java` |
| MyBatis 설정 | `{$BE_DIR}/src/main/resource/sqlmap-config.xml` |

## OMS 고유 판단 기준 (MUST / NEVER)

1. **멀티 DB** — ERP DB(SQL Server) 조회 매퍼는 `@OutDbLink` 로 라우팅, OMS DB(PostgreSQL) 매퍼와 구분한다. (common 은 단일 DB)

2. **메서드 네이밍** — 존재검증 `exist*`, 카운트 `count*` (common 의 `check*`/`get*` 아님). 목록 `search*`/`select*`, 단건 `select*`, 등록 `insert*`, 수정 `update*`, 소프트삭제 `delete*`. 새 메서드는 같은 모듈 기존 Mapper 네이밍을 먼저 확인한다.

3. **동적 조건** — `<if test="@fw.tool.EmptyTool@notEmpty(field)">` 사용. NEVER `#{field} != null` 직접 null 체크.

4. **소프트 삭제 컬럼** — `use_yn`/`del_yn` 혼용. MUST 대상 테이블 실제 컬럼을 ERD/기존 Mapper 로 확인 후 사용. NEVER 임의 가정. INSERT 초기값 `use_yn='Y'` 또는 `del_yn='N'`(컬럼에 맞게).

5. **채번** — INSERT PK 는 `NEXTVAL('{시퀀스명}')`, 시퀀스명은 ERD/실 DDL 확인(추정 금지). 업무번호·다건 채번은 → 03-numbering-module.md.

6. **페이징 생략 허용** — 결과 건수 상한이 예측 가능할 때만(소규모 마스터/기준데이터 ≤1,000건, 드롭다운, 단건 헤더+상세). MUST 트랜잭션성 테이블(주문·출하·이력) 전체목록·자유검색 화면은 페이징 필수.

7. **성능 (BLOCKING, NEVER — 예외는 spec/plan 사유 주석)** — 스칼라 서브쿼리(→ LEFT JOIN), SELECT `*`, 앞 와일드카드 LIKE(`'%kw%'`/`'%kw'` — 후방일치 `FN_CONCAT('kw','%')`만 허용), `IN` 1,000건 초과(분할), Java 루프 내 단건 DML(→ `<foreach>`). SHOULD JOIN 3개 이상·서브쿼리는 `EXPLAIN ANALYZE` 로 `Seq Scan` 확인.

> common 과 동일(→ [db-convention.md](./db-convention.md)): `WHERE 1=1` 금지·`<where>` 태그, JOIN 테이블 소프트삭제 필터, 첫 줄 주석 `/* Class.method 설명 */`, `<set>` UPDATE, Audit 컬럼(`reg_id`/`reg_dt`/`mod_id`/`mod_dt`), 물리삭제(`DELETE FROM`) 금지, `@Param` 2개 이상 필수, 신규 테이블 CREATE 금지. ※ `wms_inven*`·InvenManager 규칙은 OMS 무관(InvenManager 부재).
