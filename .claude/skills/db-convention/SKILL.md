---
name: db-convention
description: WMS MyBatis XML 쿼리 작성 컨벤션. Mapper XML 작성, 동적 SQL, EmptyTool, LIKE 검색, 페이징, foreach, 소프트 삭제, Audit 컬럼 세팅 패턴 포함.
user-invocable: false
---

# WMS MyBatis XML 쿼리 작성 컨벤션 (thin loader)

> 자동 로드 트리거: Mapper.xml / Mapper.java 작성·수정 시.
> 상세 XML 패턴은 `DEV_DOC/ai-docs/20-backend/40-guide/05-mapper-xml-writing-rules.md` 를 SSoT로 참조. 이 파일은 진입점 + 판단 기준 요약만 담는다.

## 로드 시점

- `/dev-mapper`, `/dev-if-mapper`, `/dev-all`, `/util-mybatis-sql` 실행 시
- 신규 Mapper.xml 작성, 기존 쿼리 수정·리팩터링 시
- 동적 SQL (`<where>`, `<if>`, `<foreach>`) 작성 시
- 페이징/LIKE 검색/소프트 삭제 쿼리 작성 시
- PK 채번(`NEXTVAL`), `<selectKey>` 사용 판단 시

## 참조 문서 (필독 — SSoT)

| 주제 | 문서 | 적용 레이어 |
|---|---|---|
| Mapper.java 시그니처·`@Param` | `DEV_DOC/ai-docs/20-backend/40-guide/04-mapper-writing-rules.md` | Mapper I/F |
| Mapper.xml 쿼리 패턴 (SELECT/INSERT/UPDATE/DELETE·페이징·동적 SQL) | `DEV_DOC/ai-docs/20-backend/40-guide/05-mapper-xml-writing-rules.md` | Mapper XML |
| Dao의 Mapper 위임 | `DEV_DOC/ai-docs/20-backend/40-guide/03-dao-writing-rules.md` | Dao |
| 테이블·컬럼 정의 | `DEV_DOC/ai-docs/10-database/00-database-overview.md`, `.../90-schema/20-tables/` | DB 문서 |
| 공통코드(`_cd`) 값 | `DEV_DOC/ai-docs/10-database/90-schema/30-data/01-common-code.md` | DB 문서 |

## 판단 기준 요약 (rules/ 링크)

- `.claude/rules/db-convention.md` §1 — Mapper 메서드 네이밍 (`search*`, `select*`, `insert*`, `update*`, `delete*`, `exist*`, `count*`)
- `.claude/rules/db-convention.md` §2 — `@Param` 사용 기준 (파라미터 2개 이상 필수)
- `.claude/rules/db-convention.md` §3 — SELECT/INSERT/UPDATE/DELETE 공통 체크리스트
- `.claude/rules/db-convention.md` §4 — 공통코드(`_cd`) 확인 절차
- `.claude/rules/db-convention.md` §6 — 금지 패턴 (`DELETE FROM`, `WHERE 1=1`, `!= null`, 직접 LIKE 연결 등)

## skill 고유 메모 (40-guide에 없는 내용만)

### 빠른 체크 — 쿼리 작성 시 반드시 확인

- SELECT: `AND t.use_yn='Y'` 조인 테이블 포함 모든 테이블에 적용
- 동적 조건: `@fw.tool.EmptyTool@notEmpty(param)` 사용 (`!= null` 금지)
- LIKE: `FN_CONCAT('%', #{keyword}, '%')` 패턴 (문자열 `||` 직접 연결 금지)
- 페이징: `pageSize` + `offset` 파라미터 (클라이언트 넘어옴, Mapper에서 계산 X)
- Audit: INSERT = `reg_id=#{regId}, reg_dt=NOW()` / UPDATE = `mod_id=#{modId}, mod_dt=NOW()`
- PK: `NEXTVAL('{테이블명}_seq')` — 실제 시퀀스명은 `90-schema/20-tables/` 문서에서 확인
- 삭제: 항상 `UPDATE ... SET use_yn='N'` (물리 삭제 금지)

### 재고·홀딩 테이블은 직접 쿼리 금지

`wms_inven`, `wms_inven_hold`, `wms_inven_inout` 직접 INSERT/UPDATE/DELETE 금지.
→ **InvenManager 경유**. 판단 기준·메서드는 `biz-framework` skill 참조.
