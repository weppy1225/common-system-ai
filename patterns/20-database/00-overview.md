---
title: 데이터베이스 개요
description: 업무 시스템 PostgreSQL DB의 전체 스키마 구조·도메인 구성·테이블 prefix 분류를 파악해야 할 때 읽는다 (상세 카탈로그는 spec/{프로젝트}/_knowledge/db-schema/)
status: active
version: 1.0.0
repo_role: ai-hub
agent_usage: reference
domain: database
tags:
  - database
  - overview
  - schema
  - postgresql
  - wms
---

# 데이터베이스 개요 (Database Overview)

## 1. DB 기본 정보

| 항목 | 값 |
|------|-----|
| DBMS | PostgreSQL 15.2 (64-bit) |
| Charset | UTF8 |
| Collation | Korean_Korea.949 |
| Engine | PostgreSQL 네이티브 엔진 (MVCC 기반) |
| Timezone | Asia/Seoul |

## 2. 시스템 목적

업무 시스템 운영 데이터 저장 (현재 프로젝트 도메인 예: WMS — 창고관리)

## 3. 스키마 구조

DB의 전체 스키마 구조입니다. **public 단일 스키마에 업무 테이블 + Quartz 스케줄러 테이블(11개)**이 있으며, 테이블 prefix 기준으로 도메인이 구분되어 있습니다. 실제 테이블 목록·개수 등 상세 카탈로그는 → `spec/{프로젝트}/_knowledge/db-schema/00-tables-overview.md`.

### 3.1 스키마 구성
- **public**: 전체 테이블이 위치한 단일 스키마
- **테이블 prefix**: 도메인 구분자로 활용 (mdm_*, wms_*, sm_*, sif_*, wes_*)

## 4. 도메인 구성

### 4.1 마스터 테이블 (mdm_*)
기준정보 관리 - 사업장, 거래처, 품목, 창고, 위치, 사용자 등 기본 정보

### 4.2 입하 테이블 (wms_inbiz_*)
입하관리 - 입하 예정 정보 및 품목 관리

### 4.3 입고 테이블 (wms_inwh_*)
입고관리 - 실제 입고 처리, 라벨, 처리 이력 관리

### 4.4 출하 테이블 (wms_outbiz_*)
출하관리 - 출하 예정, 송장, 상차 연동 정보 관리

### 4.5 출고 테이블 (wms_outwh_*)
출고관리 - 실제 출고 처리, 지시, 처리 이력 관리

### 4.6 재고 테이블 (wms_inven_*)
재고관리 - 현재고, 예약, 수불, 월마감, SKU 이력 관리

### 4.7 재고조정 테이블 (wms_inven_ad_*, wms_inven_etc_*, wms_inven_mv_*, wms_inven_rp_*, wms_inven_st_*)
#### 4.7.1 차감조정 (wms_inven_ad_*)
재고 차감 조정 관리
#### 4.7.2 예외출고 (wms_inven_etc_*)
예외적인 출고 처리 관리
#### 4.7.3 재고이동 (wms_inven_mv_*)
위치 간 재고 이동 관리
#### 4.7.4 품목전환 (wms_inven_rp_*)
품목 속성 전환 관리
#### 4.7.5 세트작업 (wms_inven_st_*)
세트 구성/해체 작업 관리

### 4.8 재고실사 테이블 (wms_st_*)
재고실사 일정, 대상, 처리 결과 관리

### 4.9 반품 테이블 (wms_return_*)
반품 처리 및 이력 관리

### 4.10 송장 테이블 (wms_invoice_*)
송장 발행 및 처리 관리

### 4.11 상차 테이블 (wms_load_*)
상차 작업 및 처리 관리

### 4.12 시스템 관리 테이블 (sm_*)
공통코드, 메뉴, 권한, 로그, 설정 등 시스템 운영 관리

### 4.13 외부시스템 인터페이스 테이블 (sif_*)
외부 시스템 연동 및 배치 이력 관리

### 4.14 장비 인터페이스 테이블 (wes_*)
물류 장비(WES) 연동 및 처리 이력 관리

### 4.15 Quartz 스케줄러 테이블 (qrtz_*)
Quartz 2.3.2 프레임워크 내부 테이블 — Job/Trigger 정의, 실행 상태, 클러스터 락 관리

> WMS 커스텀 Quartz 로그 테이블(`sm_qrtz_*`)은 4.12 시스템 관리 테이블에 포함.

| 테이블명 | 설명 |
|---|---|
| qrtz_job_details | Job 메타정보 (클래스명, JobDataMap) |
| qrtz_triggers | 트리거 기본 정보 (상태, 실행 시각) |
| qrtz_cron_triggers | CRON 표현식 트리거 |
| qrtz_simple_triggers | 고정 간격/횟수 트리거 |
| qrtz_simprop_triggers | 확장 트리거 속성 |
| qrtz_blob_triggers | 커스텀 트리거 (직렬화) |
| qrtz_fired_triggers | 현재 실행 중인 트리거 상태 |
| qrtz_calendars | 실행 제외 캘린더 |
| qrtz_locks | 클러스터 비관적 락 |
| qrtz_paused_trigger_grps | 일시 중지된 트리거 그룹 |
| qrtz_scheduler_state | 스케줄러 노드 heartbeat |

## 5. 상세 문서 목록

> 실 테이블 카탈로그·공통코드는 **프로젝트 확정 데이터**라 프로젝트 네임스페이스에 있다: `spec/{프로젝트}/_knowledge/db-schema/`.

### 5.1 테이블 구조
- [테이블 목록 및 설명](../../spec/{프로젝트}/_knowledge/db-schema/00-tables-overview.md) - 전체 테이블 목록과 설명

### 5.2 코드 정보
- [공통코드 목록](../../spec/{프로젝트}/_knowledge/db-schema/90-common-code.md) - 코드 헤더 및 상세 정보

### 5.3 데이터베이스 함수
- [PostgreSQL 함수 목록](./11-postgresql-functions.md) - 주요 함수 설명
