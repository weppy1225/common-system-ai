---
title: MDBZ01 데이터 모델 (테이블·상태·코드)
description: mdbz01 사업장 업무의 물리 테이블 매핑, 상태 흐름, 상태값/코드 규칙, 데이터 연쇄 규칙. 상태 관련 모든 정의의 단일 원천(Single Source of Truth).
status: active
version: 2.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: spec
menu_code: mdbz01
domain: master
depends_on:
  - "30-domain/30-wms-business/mdbz01/mdbz01-01-basic-design.md"
related:
  - "30-domain/30-wms-business/mdbz01/mdbz01-04-be-mapper-sql.md"
  - "30-domain/30-wms-business/mdbz01/mdbz01-05-api.md"
source_of_truth: true
tags:
  - detail-design
  - data-model
  - master
---

# MDBZ01 데이터 모델 (테이블·상태·코드)

> 미확인: 컬럼 타입·길이·NN·default는 운영/dev DB information_schema 직접 조회로 확인.
> ```sql
> SELECT column_name, column_type, is_nullable, column_default
> FROM information_schema.columns
> WHERE table_schema = DATABASE()
>   AND table_name IN ('MDM_BIZ','MDM_BIZ_BIZ','MDM_CENTER','MDM_BIZ_CENTER',
>                      'MDM_USER_BIZ','MDM_USER_CENTER','MDM_BIZ_WH','MDM_WH',
>                      'MDM_LOC','MDM_DOC_NO','SM_FILE')
> ORDER BY table_name, ordinal_position;
> ```

---

## 1. 물리 테이블 목록

| 업무 개념 | 물리 테이블명 | 비고 |
|---|---|---|
| 사업장 | MDM_BIZ | 사업장 기본 정보 마스터 |
| 사업장-사업장 관계 | MDM_BIZ_BIZ | 사업장 간 연결(상위↔하위, 위탁관계) 교차 테이블 |
| 물류센터 | MDM_CENTER | 물류센터 기본 정보 마스터 |
| 사업장-센터 관계 | MDM_BIZ_CENTER | 사업장과 센터의 소속 및 위탁 신청 상태 관리 |
| 사용자-사업장 권한 | MDM_USER_BIZ | 사용자가 접근 가능한 사업장 매핑 |
| 사용자-센터 권한 | MDM_USER_CENTER | 사용자가 접근 가능한 센터 매핑 |
| 창고 | MDM_WH | 물류센터 내 창고 마스터 |
| 사업장-창고 관계 | MDM_BIZ_WH | 사업장이 사용할 수 있는 창고 매핑 (위탁 수락 시 추가) |
| 위치(로케이션) | MDM_LOC | 창고 내 위치 마스터 |
| 문서번호 | MDM_DOC_NO | 사업장별 문서번호 시퀀스 |
| 파일 | SM_FILE | 업로드된 파일 정보 (로고 이미지 등) |

---

## 2. 테이블 관계

> 주의: 아래 JOIN 조건은 소스 SQL(`04-be-mapper-sql.md`) 기준으로 작성됨.
> 테이블 관계가 불명확할 경우 **소스 SQL의 실제 JOIN ON 조건을 우선** 참조한다.

| 관계 | 좌측 / 컬럼 | 우측 / 컬럼 | 의미 |
|---|---|---|---|
| 사업장 ↔ 파일 | MDM_BIZ.logo_file_seq | SM_FILE.file_seq | 사업장 로고 이미지 참조 (LEFT JOIN) |
| 센터 ↔ 사업장-센터 | MDM_CENTER.center_seq | MDM_BIZ_CENTER.center_seq | 센터와 소유/위탁 관계 매핑 |
| 사업장-센터 ↔ 사업장 | MDM_BIZ_CENTER.biz_seq / reg_biz_seq | MDM_BIZ.biz_seq | 소유 또는 원소유 사업장 참조 |
| 사용자-센터 ↔ 사용자 | MDM_USER_CENTER.user_id | MDM_USER.user_id | 센터 권한 보유 사용자 참조 |
| 창고 ↔ 센터 | MDM_WH.center_seq | MDM_CENTER.center_seq | 창고가 속한 센터 |
| 위치 ↔ 창고 | MDM_LOC.wh_seq | MDM_WH.wh_seq | 위치가 속한 창고 |
| 사업장-창고 ↔ 사업장 | MDM_BIZ_WH.biz_seq | MDM_BIZ.biz_seq | 사업장이 접근 가능한 창고 |
| 사업장-사업장 ↔ 사업장 | MDM_BIZ_BIZ.ref_biz_seq | MDM_BIZ.biz_seq | 상위/원소유 사업장 참조 |

### MDM_BIZ_CENTER 이중 역할

MDM_BIZ_CENTER는 두 가지 용도로 공용된다.

**용도 A — 자사 센터 소유 관계**
- `biz_seq` = 소유 사업장 (= `reg_biz_seq`)
- `cfm_yn` = 'Y', `use_yn` = 'Y'

**용도 B — 위탁 의뢰/수락 관계**
- `biz_seq` = 의뢰 사업장(위탁 사용자 측)
- `reg_biz_seq` = 센터 소유 사업장(대행 업체 측)
- 구분 조건: `biz_seq != reg_biz_seq`

---

## 3. 상태값 / 코드 규칙

### 3-1. 위탁 의뢰 상태 흐름

```
[신청가능]
     │ 위탁 요청 신청
     ▼
[신청중 (REQUEST)]
     │ 대행 업체 처리
     ├──── 수락 ──────► [승인 (ACCEPT)]
     │                        │ 이미 처리된 건으로 취소 불가
     └──── 거절 ──────► [거절 (DENIED)]
                              │ 재신청 가능
                              └──────────► [신청중 (REQUEST)]

[신청중] 상태에서만 의뢰자 측 취소 가능
     │ 의뢰자 취소
     ▼
[신청가능] (MDM_BIZ_CENTER 레코드 물리 삭제)
```

### 3-2. 위탁 의뢰 상태 표 (MDM_BIZ_CENTER.cfm_yn + use_yn 조합)

| cfm_yn | use_yn | 상태 코드 | 표시명 | 의미 |
|---|---|---|---|---|
| 'N' | 'N' | REQUEST | 신청중 | 의뢰 보냄, 대행 업체 미처리 |
| 'Y' | 'Y' | ACCEPT | 승인 | 대행 업체 수락, 위탁 관계 유효 |
| 'Y' | 'N' | DENIED | 거절 | 대행 업체 거절 |
| — | — | — | 신청가능 | MDM_BIZ_CENTER 레코드 없음 (COALESCE 기본값) |

### 3-3. 사업장 구분 코드 (MDM_BIZ.biz_div_cd)

| 코드 상수 | 의미 | 비고 |
|---|---|---|
| WMSPool.BIZ_DIV_OWN | 자사물류 | 자체 물류 인프라 보유·운영 |
| WMSPool.BIZ_DIV_TPL | 물류대행 | 외부 물류 대행 서비스 제공 업체 |
| WMSPool.BIZ_DIV_SHIPPER | 화주 | 납품업체 유형, MDBZ01 수정 대상 제외 |

> 미확인: 실제 코드 문자열 값은 `fw.constant.WMSPool` 클래스에서 확인.

### 3-4. 사용여부 (use_yn)

| 값 | 의미 |
|---|---|
| 'Y' | 사용 (활성) |
| 'N' | 미사용 (비활성) |

MDM_BIZ, MDM_CENTER, MDM_BIZ_CENTER, MDM_BIZ_BIZ 모두 동일 패턴 적용.

### 3-5. 승인여부 (cfm_yn)

| 값 | 의미 |
|---|---|
| 'Y' | 승인 완료 (자사 센터 또는 위탁 수락 완료) |
| 'N' | 미승인 (신청 중) |

### 3-6. 물류대행 여부 (MDM_CENTER.tpl_yn)

| 값 | 의미 |
|---|---|
| 'Y' | 외부 의뢰를 받을 수 있는 물류대행 가능 센터 |
| 'N' | 물류대행 미운영 센터 |

> 미확인: 소스에서 `tpl_yn`을 `updateCenter` SQL에서 주석 처리하고 `updateTplCenter` SQL에서만 사용한다. 운영 컬럼 정책은 DB 확인이 필요하다.

### 3-7. 사용자 권한 유형 (MDM_USER.auth_type_cd)

| 코드 상수 | 의미 |
|---|---|
| WMSPool.AUTH_TYPE_SUPER | 슈퍼 관리자 — 신규 센터 등록 시 자동 권한 부여 대상 |
| WMSPool.AUTH_TYPE_BIZ | 사업장 권한 — 사업자번호 기준 사업장 접근 |
| WMSPool.AUTH_TYPE_CENTER | 센터 권한 — 센터 소속 사업장만 접근 |

> 미확인: 실제 코드 문자열 값은 `fw.constant.WMSPool` 클래스에서 확인.

---

## 4. 데이터 생성 연쇄 규칙

### 신규 물류센터 등록 시

```
MDM_CENTER (센터 기본 정보)
     │
     ├─► MDM_BIZ_CENTER (사업장-센터 소유 관계, biz_seq = reg_biz_seq)
     │
     ├─► MDM_USER_CENTER (슈퍼 관리자 전원에게 자동 부여)
     │
     └─► MDM_WH × N (기본 창고 템플릿 복사 생성)
          │
          ├─► MDM_BIZ_WH (사업장-창고 관계)
          └─► MDM_LOC (기본 위치 1건 자동 생성)
```

### 위탁 의뢰 수락 시

```
MDM_BIZ_CENTER (위탁 관계 레코드, use_yn='Y', cfm_yn='Y')
     │
     ├─► MDM_BIZ_WH (의뢰 사업장이 해당 센터 창고에 접근 가능하도록 추가)
     │
     └─► MDM_BIZ_BIZ (의뢰 사업장과 대행 업체 사업장의 관계 갱신)
```
