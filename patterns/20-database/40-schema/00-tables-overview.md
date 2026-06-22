---
title: WMS 테이블 목록 및 설명
description: WMS 전체 테이블 목록과 도메인별 그룹을 확인할 때 읽는다
status: active
version: 1.0.0
repo_role: ai-hub
agent_usage: instruction
domain: database
tags:
  - database
  - table
  - schema
  - wms
---

# WMS 테이블 목록 및 설명

## 1. 기준정보 테이블 (mdm_*)

> 상세 테이블 정의서: [01-mdm-tables.md](./01-mdm-tables.md)

| 테이블명 | 테이블 설명 |
|---------|------------|
| mdm_biz | MDM_사업장 |
| mdm_center | MDM_센터 |
| mdm_biz_biz | MDM_사업장_사업장 |
| mdm_biz_center | MDM_사업장_센터 |
| mdm_prod | MDM_품목 |
| mdm_biz_prod | MDM_사업장_품목 |
| mdm_cont | MDM_거래처 |
| mdm_biz_cont | MDM_사업장_거래처 |
| mdm_cont_prod | MDM_거래처_품목 |
| mdm_wh | MDM_창고 |
| mdm_biz_wh | MDM_사업장_창고 |
| mdm_loc | MDM_위치 |
| mdm_doc_no | MDM_문서번호 |
| mdm_label_paper | MDM_라벨_용지 |
| mdm_rp_prod | MDM_전환품목 |
| mdm_st_prod | MDM_세트구성 |
| mdm_st_config | MDM_세트_구성 |
| mdm_st_config_dtl | MDM_세트_구성_상세 |
| mdm_user | MDM_사용자 |
| mdm_user_biz | MDM_권한사업장 |
| mdm_user_center | MDM_권한센터 |
| mdm_car | MDM_차량 |

## 2. 입하/입고 테이블 (wms_inbiz_*/wms_inwh_*)

> 상세 테이블 정의서: [02-inbound-tables.md](./02-inbound-tables.md)

| 테이블명 | 테이블 설명 |
|---------|------------|
| wms_inbiz | WMS_입하 |
| wms_inbiz_prod | WMS_입하_품목 |
| wms_inbiz_inwh | WMS_입하_입고 |
| wms_inwh | WMS_입고 |
| wms_inwh_prod | WMS_입고_품목 |
| wms_inwh_tran | WMS_입고_처리 |
| wms_inwh_label | WMS_입고_라벨 |

## 3. 반품 테이블 (wms_return_*)

> 상세 테이블 정의서: [03-return-tables.md](./03-return-tables.md)

| 테이블명 | 테이블 설명 |
|---------|------------|
| wms_return | WMS_반품 |
| wms_return_prod | WMS_반품_품목 |
| wms_return_tran | WMS_반품_처리 |

## 4. 출하/출고/송장/상차 테이블 (wms_outbiz_*/wms_outwh_*/wms_invoice_*/wms_load_*)

> 상세 테이블 정의서: [04-outbound-tables.md](./04-outbound-tables.md)

| 테이블명 | 테이블 설명 |
|---------|------------|
| wms_outbiz | WMS_출하 |
| wms_outbiz_prod | WMS_출하_품목 |
| wms_outbiz_tran | WMS_출하_처리 |
| wms_outwh_assign | WMS_출고지시 |
| wms_outbiz_outwh | WMS_출하_출고 |
| wms_outwh | WMS_출고 |
| wms_outwh_prod | WMS_출고_품목 |
| wms_outwh_tran | WMS_출고_처리 |
| wms_outbiz_invoice | WMS_출하_송장 |
| wms_invoice | WMS_송장 |
| wms_invoice_prod | WMS_송장_품목 |
| wms_invoice_tran | WMS_송장_처리 |
| wms_outbiz_load | WMS_출하_상차 |
| wms_load | WMS_상차 |
| wms_load_prod | WMS_상차_품목 |
| wms_load_tran | WMS_상차_처리 |

## 5. 재고 테이블 (wms_inven_*)

> 상세 테이블 정의서: [05-inventory-tables.md](./05-inventory-tables.md)

| 테이블명 | 테이블 설명 |
|---------|------------|
| wms_inven_sku | WMS_재고_SKU이력 |
| wms_inven_inout | WMS_재고_수불 |
| wms_inven | WMS_재고 |
| wms_inven_holding | WMS_재고_예약 |
| wms_inven_month | WMS_재고_월마감 |

## 6. 재고관리 테이블

> 상세 테이블 정의서: [06-inventory-mgmt-tables.md](./06-inventory-mgmt-tables.md)

### 6.1 차감조정 (wms_inven_ad_*)

| 테이블명 | 테이블 설명 |
|---------|------------|
| wms_inven_ad | WMS_재고조정 |
| wms_inven_ad_prod | WMS_재고조정_품목 |
| wms_inven_ad_tran | WMS_재고조정_처리 |

### 6.2 예외출고 (wms_inven_etc_*)

| 테이블명 | 테이블 설명 |
|---------|------------|
| wms_inven_etc | WMS_예외출고 |
| wms_inven_etc_prod | WMS_예외출고_품목 |
| wms_inven_etc_tran | WMS_예외출고_처리 |

### 6.3 재고이동 (wms_inven_mv_*)

| 테이블명 | 테이블 설명 |
|---------|------------|
| wms_inven_mv | WMS_재고이동 |
| wms_inven_mv_prod | WMS_재고이동_품목 |
| wms_inven_mv_tran | WMS_재고이동_처리 |

### 6.4 품목전환 (wms_inven_rp_*)

| 테이블명 | 테이블 설명 |
|---------|------------|
| wms_inven_rp | WMS_품목전환 |
| wms_inven_rp_prod | WMS_품목전환_품목 |
| wms_inven_rp_tran | WMS_품목전환_처리 |

### 6.5 세트작업 (wms_inven_st_*)

| 테이블명 | 테이블 설명 |
|---------|------------|
| wms_inven_st | WMS_세트작업 |
| wms_inven_st_prod | WMS_세트작업_품목 |
| wms_inven_st_tran | WMS_세트작업_처리 |

## 7. 재고실사 테이블 (wms_st_*)

> 상세 테이블 정의서: [07-inventory-count-tables.md](./07-inventory-count-tables.md)

| 테이블명 | 테이블 설명 |
|---------|------------|
| wms_st_sch | WMS_재고실사_일정 |
| wms_st_target | WMS_재고실사_대상 |
| wms_st_inven | WMS_재고실사_재고 |
| wms_st_tran | WMS_재고실사_처리 |

## 8. 시스템 관리 테이블 (sm_*)

> 상세 테이블 정의서: [08-system-tables.md](./08-system-tables.md)

| 테이블명 | 테이블 설명 |
|---------|------------|
| sm_alarm_history | 시스템_알람_이력 |
| sm_alarm_unrcv | 시스템_알람_미수신 |
| sm_api_config | 시스템_API_설정 |
| sm_biz_config | 시스템_사업장_설정(NEW) |
| sm_board | 시스템_게시판 |
| sm_comm_d | 시스템_공통코드_상세 |
| sm_comm_h | 시스템_공통코드 |
| sm_dlv_config | 시스템_택배_설정 |
| sm_dlv_config_applied | 시스템_택배_적용 |
| sm_file | 시스템_파일 |
| sm_file_req | 시스템_파일_업무(NEW) |
| sm_group | 시스템_그룹 |
| sm_log_api | 시스템_로그_API |
| sm_log_conn | 시스템_로그_접근 |
| sm_log_conn_dtl | 시스템_로그_접근_상세(NEW) |
| sm_log_error | 시스템_로그_에러 |
| sm_log_menu | 시스템_로그_메뉴접근 |
| sm_menu | 시스템_메뉴 |
| sm_menu_group | 시스템_메뉴_그룹 |
| sm_menu_opt_config | 시스템_메뉴_옵션_설정 |
| sm_ob_proc_opt_config | 시스템_출하_처리_옵션_설정 |
| sm_opt_config | 시스템_출력물_설정 |
| sm_prod_opt_config | 시스템_품목_옵션_설정 |
| sm_push_history | 시스템_푸시_이력 |
| sm_push_cycle | 시스템_푸시_주기 |
| sm_push_unrcv | 시스템_푸시_미수신(NEW) |
| sm_qrtz_change_log | 시스템_쿼츠_변경_이력 |
| sm_qrtz_exec_log | 시스템_쿼츠_실행_이력 |
| sm_qrtz_job_state | 시스템_쿼츠_작업_현황(NEW) |
| sm_user_pwd_history | 시스템_비밀번호_변경_이력(NEW) |

## 9. 외부시스템 인터페이스 테이블 (sif_*)

| 테이블명 | 테이블 설명 |
|---------|------------|
| sif_batch_history | SIF_배치_이력 |

## 10. 장비 인터페이스 테이블 (wes_*)

| 테이블명 | 테이블 설명 |
|---------|------------|
| wes_process_history | WES_처리_이력 |

---

## 첨부: 실행한 SQL

```sql
SELECT 
    t.table_name,
    obj_description(pc.oid, 'pg_class') AS table_comment
FROM information_schema.tables t
JOIN pg_class pc ON pc.relname = t.table_name
JOIN pg_namespace pn ON pn.oid = pc.relnamespace 
    AND pn.nspname = t.table_schema
WHERE t.table_schema = 'public'
  AND t.table_type = 'BASE TABLE'
  AND obj_description(pc.oid, 'pg_class') IS NOT NULL
ORDER BY t.table_name;
```
