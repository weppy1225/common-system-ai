---
title: 출고 업무 워크플로우
description: 즉시출하·출고출하·상차처리·송장처리 등 출고 프로세스별 단계와 관련 테이블을 참조할 때 사용
status: active
version: 1.0.0
repo_role: ai-hub
agent_usage: reference
domain: backend
tags:
  - outbound
  - workflow
  - process
  - inventory
---

## 1. 즉시출하 프로세스

> **흐름:** 출하예정 등록 → 출하준비 → 출하처리

| 단계 | 주요 작업 내용 | 관련 테이블 |
| --- | --- | --- |
| **1. 출하예정 등록** | 출하 비즈니스 및 품목 데이터 생성 | `WMS_OUTBIZ`, `WMS_OUTBIZ_PROD` |
| **2. 출하준비** | 상태 변경(출하준비/재고부족) 및 예약재고 등록 | `WMS_INVEN_HOLDING` |
| **3. 출하처리** | 예약재고 삭제, 실제 재고 차감 및 수불 등록 | `WMS_INVEN_HOLDING` (삭제), `WMS_INVEN`, `WMS_INVEN_INOUT`, `WMS_OUTBIZ_TRAN`, `WMS_OUTBIZ_PROD`(수정), `WMS_OUTBIZ`(수정) |

---

## 2. 출고출하(일반) 프로세스

> **흐름:** 출하예정 등록 → 출하준비 → 출고지시 → 출고처리 → 출하처리

| 단계 | 주요 작업 내용 | 관련 테이블 |
| --- | --- | --- |
| **1. 출하예정 등록** | 출하 기본 정보 등록 | `WMS_OUTBIZ`, `WMS_OUTBIZ_PROD` |
| **2. 출하준비** | 재고 가용성 확인 및 예약재고 등록 | `WMS_INVEN_HOLDING` |
| **3. 출고지시** | 출고 창고 지정 및 SKU 할당 (강지정 시 대기재고화) | `WMS_OUTWH`, `WMS_OUTWH_PROD`, `WMS_OUTBIZ_OUTWH`, `WMS_OUTWH_ASSIGN`, `WMS_INVEN` |
| **4. 출고처리** | **예약재고 삭제**, 출하창고 재고이동 및 수불 등록 | `WMS_INVEN`, `WMS_INVEN_INOUT`, **`WMS_INVEN_HOLDING` (삭제)**, `WMS_OUTWH_ASSIGN` (삭제), `WMS_OUTWH_TRAN` |
| **5. 출하처리** | 최종 재고 차감 및 출하 완료 처리 | `WMS_INVEN`, `WMS_INVEN_INOUT`, `WMS_OUTBIZ_TRAN`, `WMS_OUTBIZ_PROD`, `WMS_OUTBIZ` |

---

## 3. 상차처리 프로세스

> **흐름:** 출하예정 등록 → 출하준비 → 출고지시 → 출고처리 → 상차처리 → (출하처리)

| 단계 | 주요 작업 내용 | 관련 테이블 |
| --- | --- | --- |
| **1~2. 등록/준비** | 일반 출하와 동일 (상태 관리 및 예약재고 등록) | `WMS_OUTBIZ`, `WMS_INVEN_HOLDING` |
| **3. 출고지시** | SKU 데이터 할당 및 출고 창고 연결 | `WMS_OUTWH`, `WMS_OUTWH_PROD`, `WMS_OUTBIZ_OUTWH`, `WMS_OUTWH_ASSIGN` |
| **4. 출고처리** | **예약재고 삭제**, 출하창고로 재고 이동 | `WMS_INVEN`, `WMS_INVEN_INOUT`, **`WMS_INVEN_HOLDING` (삭제)**, `WMS_OUTWH_ASSIGN` |
| **5. 상차지시** | 차량 등록 및 상차 정보 생성 | `MDM_CAR`, `WMS_LOAD`, `WMS_LOAD_PROD`, `WMS_OUTBIZ_LOAD` |
| **6. 상차 재고지정** | 상차를 위한 대기재고화 및 확정 처리 | `WMS_INVEN`, `WMS_LOAD_TRAN`, `WMS_LOAD_PROD` |
| **7. 상차처리** | 자동출하 설정 시 재고 차감 및 출하 동시 처리 | `WMS_INVEN`, `WMS_INVEN_INOUT`, `WMS_OUTBIZ_TRAN`, `WMS_LOAD` |
| **8. 출하처리** | (선택 사항) 최종 출하 확정 | 일반 출하와 동일 |

---

## 4. 송장처리 프로세스

> **흐름:** 출하예정 등록 → 출하준비 → 송장발행 → 출고지시 → 출고처리 → 송장처리 → 출하처리

| 단계 | 주요 작업 내용 | 관련 테이블 |
| --- | --- | --- |
| **1~2. 등록/준비** | 자동출하 유무 설정 및 예약재고 등록 | `WMS_OUTBIZ`, `WMS_INVEN_HOLDING` |
| **3. 송장발행** | 송장 정보 생성 및 출하 정보 연결 | `WMS_INVOICE`, `WMS_INVOICE_PROD`, `WMS_OUTBIZ_INVOICE` |
| **4. 출고지시** | 출고 차수 기입 및 SKU 할당 | `WMS_OUTWH`, `WMS_OUTWH_ASSIGN`, `WMS_INVOICE` |
| **5. 출고처리** | **예약재고 삭제**, 출하창고 재고 이동 | `WMS_INVEN`, `WMS_INVEN_INOUT`, **`WMS_INVEN_HOLDING` (삭제)** |
| **6. 송장처리** | 대기재고화 및 송장 수량 업데이트 | `WMS_INVEN`, `WMS_INVOICE_TRAN`, `WMS_INVOICE_PROD`, `WMS_OUTBIZ_INVOICE` |
| **7. 출하처리** | 재고 차감 및 최종 출하 완료 | `WMS_INVEN`, `WMS_INVEN_INOUT`, `WMS_OUTBIZ_TRAN`, `WMS_OUTBIZ` |
| **8. 자동출하(옵션)** | 송장 처리와 동시에 재고 차감 및 출하 수행 | 상기 출하처리 로직과 동일 (이력 생성 시점 유의) |
