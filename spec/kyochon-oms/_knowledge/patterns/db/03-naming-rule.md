---
description: oms-be DB 테이블·컬럼 네이밍 규칙 중 OMS 고유 차이분(MDM/SM/SIF prefix·주문/출하 도메인 prefix 미확인 경고·OMS ERD 경로·camelCase 매핑 접미어 링크). 테이블·컬럼명을 정하거나 매핑 별칭을 지을 때 공통 규칙과 함께 적용한다.
---

# DB 테이블·컬럼 네이밍 규칙 — OMS 고유 차이

> 공통 네이밍 골격(`lower_snake_case` 일반규칙·표준 약어 seq/no/cd/nm/ymd/hms/dt/qty/yn/sts·컬럼 유형별 패턴·감사컬럼 `reg_id`/`reg_dt`/`mod_id`/`mod_dt`·`if_*`/`fr_*`/`to_*`·생성 템플릿)은 [common 문서](../../../../../patterns/20-database/20-rule/01-naming-rule.md)와 동일하다. 이 문서는 **OMS 고유 차이분만** 담는다.

전제(숨은 전제 명시): OMS DB = PostgreSQL. 컬럼은 `lower_snake_case`, Java 매핑 별칭은 `camelCase`.

근거(OMS 실제 적용 확인): `oms-be` Mapper.xml 들 — `MDM_USER`, `MDM_CONT`, `MDM_BIZ_CONT`, `SM_USER_PWD_HISTORY`, 컬럼 `user_id`/`cont_nm`/`reg_dt`/`use_yn`/`del_yn` 등 동일 컨벤션 사용.

---

## 1. OMS 테이블 Prefix 사용 상태 (vs common)

> common 문서는 WMS 도메인 prefix(`WMS`, `WES`)와 예시 테이블을 포함한다. OMS 는 아래 prefix 만 **실제 사용 확인**되었고, 주문/출하 도메인 prefix 는 미확인이다.

| Prefix | 용도 | OMS 확인 상태 |
|---|---|---|
| `MDM` | 기준정보(Master Data) | OMS 사용 확인(`MDM_USER`, `MDM_CONT`, `MDM_BIZ_CONT`) |
| `SM` | 시스템관리(System Mgmt) | OMS 사용 확인(`SM_USER_PWD_HISTORY`) |
| `SIF` | 외부 인터페이스 | 미확인: OMS ERD(`oms-be/DEV_DOC/erd/oms.exerd`) 확인 |

> 미확인: OMS 고유 주문/출하 도메인 테이블 prefix 는 위 외에 별도 체계가 있을 수 있다. 신규 테이블·기존 테이블명은 `oms-be/DEV_DOC/erd/oms.exerd`(ERD) 와 같은 도메인 기존 Mapper.xml 로 **반드시 확인** 후 사용한다. 추정 금지.

---

## 2. OMS 소프트삭제 컬럼 판단 (use_yn vs del_yn)

근거(OMS 실제 사용 확인): Mapper.xml 들에서 `use_yn`/`del_yn`/`reg_id`/`reg_dt`/`mod_id`/`mod_dt` 사용.

소프트삭제 컬럼 판단 기준·MUST/NEVER 규칙 → `.claude/rules/oms-db-convention.md §4`

---

## 3. OMS 참조 링크

- 컬럼 → camelCase 매핑(Java 필드 접미어)은 → `spec/kyochon-oms/_knowledge/db-schema/90-common-code.md` 및 `fw/constant/OMSPool.java`.
- 테이블/컬럼/코드값 확인: `oms-be/DEV_DOC/erd/oms.exerd`(ERD), `fw/constant/OMSPool.java`.

---

## 4. OMS 네이밍 체크리스트 (고유 추가분)

- [ ] 신규/기존 테이블명·prefix 를 OMS ERD(`oms-be/DEV_DOC/erd/oms.exerd`) 로 확인(추정 금지)
- [ ] 소프트삭제 컬럼(`use_yn`/`del_yn`)을 ERD/기존 Mapper 로 확인
