---
name: db-psql
description: >
  OMS DB 테이블·컬럼·공통코드 정보가 필요할 때 참조한다.
  "DB 테이블 확인", "컬럼 구조", "공통코드 값", "테이블 찾아줘", "DB 스키마 확인" 등
  DB 구조를 알아야 할 때 이 스킬을 참조한다.
when_to_use: "DB 테이블 목록", "컬럼 확인", "공통코드 조회", "스키마 확인" 요청 시 사용.
---

# OMS DB 스키마 참조 가이드

## 테이블·컬럼 정보 — 문서 먼저 확인

DB 직접 조회 전에 아래 문서에서 테이블명·컬럼 정보를 먼저 확인한다.

| 도메인 | 문서 경로 |
|---|---|
| 전체 테이블 목록 + 그룹별 분류 | `spec/kyochon_oms/_knowledge/db-schema/00-tables-overview.md` |
| 기준정보 (`mdm_*`) | `spec/kyochon_oms/_knowledge/db-schema/01-mdm-tables.md` |
| OMS 업무 (`oms_*`) | `spec/kyochon_oms/_knowledge/db-schema/02-oms-tables.md` |
| 쇼핑몰 (`shop_*`) | `spec/kyochon_oms/_knowledge/db-schema/03-shop-tables.md` |
| 시스템·메뉴·공통코드 (`sm_*`) | `spec/kyochon_oms/_knowledge/db-schema/04-system-tables.md` |
| 인터페이스 (`sif_*`·`vacs_*`) | `spec/kyochon_oms/_knowledge/db-schema/05-interface-tables.md` |
| 공통코드 값 | `spec/kyochon_oms/_knowledge/db-schema/90-common-code.md` |

> 문서에 없는 컬럼 상세·실제 데이터는 각자 환경에 맞는 DB 툴로 직접 조회한다.

## DB 접속 정보

접속 정보는 BE 레포의 `src/main/resource/prop/application-dev.properties` 에 있다.

```
db.url      → PostgreSQL 접속 URL (host·port·dbname 포함)
db.username → DB 계정
db.password → DB 비밀번호
```

> 숨은 전제: OMS=PostgreSQL, ERP=SQL Server 멀티 DB.
> ERP(SQL Server) 데이터는 PostgreSQL로 조회하지 않는다.
