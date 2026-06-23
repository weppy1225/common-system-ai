---
description: oms-be MyBatis Mapper.xml·Dao 작성 시 common DB 컨벤션 대비 OMS 고유 차이(OMS=PostgreSQL+ERP=SQL Server 멀티DB·@OutDbLink·exist*/count* 네이밍·EmptyTool 동적조건·use_yn/del_yn 혼용·후방일치 LIKE·스칼라서브쿼리 금지·InvenManager 부재)만 적용. Mapper.xml 또는 Dao를 다룰 때 로딩한다.
paths:
  - "**/*Mapper.xml"
  - "**/*Dao.java"
  - "**/*Mapper.java"
---

# OMS DB(MyBatis) 개발 규칙 — OMS 고유 차이

> 공통 골격은 [DB 컨벤션](./db-convention.md) 와 동일하다. 이 문서는 **OMS 고유 차이분만** 담는다.
> 전제: 전통 Spring(Boot 아님) · MyBatis · OMS=PostgreSQL + ERP=SQL Server 멀티DB.
> 상세 작성 패턴은 → `knowledgebase/domains/oms/patterns/db/oms-01-sql-query-style.md`(서식), `oms-02-mybatis-convention.md`(구현), `oms-03-naming-rule.md`(명명).
> 테이블·컬럼·코드값 확인은 → `oms-be/DEV_DOC/erd/oms.exerd`(ERD) + `oms-ai/04-도메인-코드값.md` + `fw/constant/OMSPool.java`.
> MyBatis 설정 근거: `oms-be/src/main/resource/sqlmap-config.xml`.

전제(숨은 전제 명시): OMS DB = PostgreSQL, ERP DB = SQL Server 멀티 DB. ERP DB 매퍼는 `@OutDbLink` 로 라우팅(상세 → `02-백엔드-패턴.md §6`).

---

## OMS 고유 차이 (vs common)

### 1. 멀티 DB 라우팅 — @OutDbLink (ERP=SQL Server)

MUST: ERP DB(SQL Server) 를 조회하는 매퍼는 `@OutDbLink` 로 라우팅한다(상세 → `02-백엔드-패턴.md §6`). OMS DB(PostgreSQL) 매퍼와 구분한다.

> common 은 단일 DB 전제다. OMS 는 OMS=PostgreSQL + ERP=SQL Server 멀티 DB 라서 ERP 매퍼 라우팅 규칙이 추가된다.

### 2. Mapper 메서드 네이밍 — exist* / count* (check*/get* 아님)

| 작업 | 메서드명 패턴 | 예 |
|---|---|---|
| 목록 조회 | `search{복수명}` / `select{복수명}` | `searchOrders` |
| 단건 조회 | `select{단수명}` | `selectOrder` |
| 등록 | `insert{단수/복수명}` | `insertOrder` |
| 수정 | `update{단수/복수명}` | `updateOrder` |
| 소프트 삭제 | `delete{단수/복수명}` | UPDATE use_yn/del_yn |
| 상태 변경 / 존재 / 카운트 | `update{단수명}Status` / `exist{단수명}` / `count{단수/복수명}` | |

MUST: 새 메서드명은 같은 모듈 기존 Mapper 의 네이밍을 먼저 확인해 일관성을 맞춘다.

> common 은 존재검증=`check*`, 건수=`get*` 이나, OMS 는 존재=`exist*`, 카운트=`count*` 를 사용한다.

### 3. 동적 조건 — EmptyTool (null 직접 체크 아님)

- 동적 조건은 `<if test="@fw.tool.EmptyTool@notEmpty(field)">` (근거: 실제 존재 `fw/tool/EmptyTool.java`).
- `#{field} != null` 직접 null 체크 금지.

> common 도 `@fw.tool.EmptyTool@notEmpty()` 를 쓰나, OMS 의 동적 조건 작성 시 이 패턴을 기본으로 사용한다.

### 4. 소프트 삭제 컬럼 — use_yn / del_yn 혼용 (테이블별 확인 필수)

MUST: 테이블마다 소프트삭제 컬럼이 다르다. 대상 테이블의 실제 컬럼을 ERD/기존 Mapper 로 확인 후 사용한다.
근거: `grep oms-be/src/main` 결과 `use_yn` 과 `del_yn` 둘 다 사용됨(`use_yn='Y'` 다수, `del_yn='N'` 다수).

NEVER: 컬럼 확인 없이 `use_yn`/`del_yn` 중 하나를 임의 가정.

INSERT 소프트삭제 컬럼 초기값: `use_yn = 'Y'` 또는 `del_yn = 'N'`(테이블 컬럼에 맞게).

### 5. 채번 — NEXTVAL('{시퀀스명}') 시퀀스명 직접 확인

INSERT PK 채번: `NEXTVAL('{시퀀스명}')`(시퀀스명 ERD/실제 DDL 확인 — 추정 금지).

> common 은 `NEXTVAL('{테이블명}_seq')` 관례를 제시하나, OMS 는 시퀀스명을 ERD/실제 DDL 에서 확인하고 추정하지 않는다.

### 6. 페이징 생략 허용 조건 (OMS 기준)

페이징 없이 전체 조회 가능 — 단 **결과 건수 상한이 예측 가능**할 때만.

| 허용 유형 | 예 | 상한 |
|---|---|---|
| 소규모 마스터/기준 데이터 | 공통코드, 사업장·센터 목록, 메뉴·권한 목록 | 1,000건 이하 |
| 드롭다운·콤보박스 | 상태 코드, 구분 코드 | 수백 건 이하 |
| 단건 헤더 + 부속 상세 | 주문 1건의 상세 행 | 헤더 단위 자연 제한 |

MUST: 트랜잭션성 테이블(주문·출하·이력 등) 전체 목록, 자유 검색 화면은 페이징 필수.

### 7. 쿼리 성능 규칙 — BLOCKING (OMS PostgreSQL 기준)

NEVER(예외는 spec/plan 에 사유 주석):
- **스칼라 서브쿼리** (`SELECT ... (SELECT x FROM ...) ...`) — 행마다 재실행됨. → `LEFT JOIN` 전환.
- **SELECT `*`** — 필요한 컬럼만 명시(특히 `text`/`jsonb` 대용량).
- 앞 와일드카드 LIKE(`'%keyword%'`, `'%keyword'`) — 후방 일치만 허용(`FN_CONCAT('keyword','%')` 등 인덱스 활용 패턴).
- `IN` 절 1,000건 초과(Postgres 파라미터 한계) — 분할 처리.
- Java 루프 안 단건 INSERT/UPDATE 반복 — `<foreach>` 배치.

SHOULD: JOIN 3개 이상 또는 서브쿼리 포함 쿼리는 `EXPLAIN ANALYZE` 로 `Seq Scan on {대용량테이블}` 여부 확인.

> common 은 `FN_CONCAT('%', #{v}, '%')` 양방향 LIKE 를 허용하나, OMS 는 인덱스 활용을 위해 **후방 일치(`FN_CONCAT('keyword','%')`)만 허용**하고 앞 와일드카드를 금지한다. 또 OMS 는 PostgreSQL 기준 스칼라 서브쿼리·SELECT `*`·`IN` 1,000건 초과를 추가로 금지한다.

### 8. OMS 금지 패턴 요약 (common 과 다른 것만)

- ERP(SQL Server) 매퍼 `@OutDbLink` 라우팅 누락 (§1)
- 존재검증을 `check*`, 건수를 `get*` 로 명명 → OMS 는 `exist*`/`count*` (§2)
- 스칼라 서브쿼리 / SELECT `*` / 앞 와일드카드 LIKE / `IN` 1,000건 초과 (§7)
- 소프트삭제 컬럼(use_yn/del_yn) 임의 가정 (§4)
- 시퀀스명 추정(`NEXTVAL` 대상) → ERD/실제 DDL 확인 (§5)

> 아래는 common 과 동일하므로 [DB 컨벤션](./db-convention.md) 을 따른다: `WHERE 1=1` 금지·`<where>` 태그, JOIN 테이블 소프트삭제 필터, 첫 줄 주석 `/* MapperClassName.methodName 설명 */`, `<set>` 태그 UPDATE, `reg_id`/`reg_dt`/`mod_id`/`mod_dt` Audit 컬럼, `DELETE FROM` 물리 삭제 금지(소프트 삭제), `@Param` 2개 이상 필수, Java 루프 단건 DML 금지(`<foreach>` 배치), 테이블 영향 범위 확인·신규 테이블 CREATE 금지.
> common 의 `wms_inven*` 직접 DML 금지·InvenManager 경유 규칙은 OMS 에 적용하지 않는다 — oms-be 에 InvenManager 가 존재하지 않는다(`find -iname "*InvenManager*"` 0건).
