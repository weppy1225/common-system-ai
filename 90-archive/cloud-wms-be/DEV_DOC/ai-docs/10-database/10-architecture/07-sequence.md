# 시퀀스(Sequence)

## 1. 마스터 테이블 시퀀스 (mdm_*)

| 스키마명 | 테이블명 | 컬럼명 | 시퀀스명 | 기본값 |
|---------|---------|--------|---------|--------|
| public | mdm_biz | biz_seq | mdm_biz_seq | nextval('mdm_biz_seq'::regclass) |
| public | mdm_car | car_seq | mdm_car_seq | nextval('mdm_car_seq'::regclass) |
| public | mdm_center | center_seq | mdm_center_seq | nextval('mdm_center_seq'::regclass) |
| public | mdm_cont | cont_seq | mdm_cont_seq | nextval('mdm_cont_seq'::regclass) |
| public | mdm_cont_prod | cont_prod_seq | mdm_cont_prod_seq | nextval('mdm_cont_prod_seq'::regclass) |
| public | mdm_label_paper | label_paper_seq | mdm_label_paper_seq | nextval('mdm_label_paper_seq'::regclass) |
| public | mdm_loc | loc_seq | mdm_loc_seq | nextval('mdm_loc_seq'::regclass) |
| public | mdm_prod | prod_seq | mdm_prod_seq | nextval('mdm_prod_seq'::regclass) |
| public | mdm_rp_prod | rp_prod_seq | mdm_rp_prod_seq | nextval('mdm_rp_prod_seq'::regclass) |
| public | mdm_st_config | st_config_seq | mdm_st_config_seq | nextval('mdm_st_config_seq'::regclass) |
| public | mdm_st_config_dtl | st_config_dtl_seq | mdm_st_config_dtl_seq | nextval('mdm_st_config_dtl_seq'::regclass) |
| public | mdm_st_prod | st_prod_seq | mdm_st_prod_seq | nextval('mdm_st_prod_seq'::regclass) |
| public | mdm_wh | wh_seq | mdm_wh_seq | nextval('mdm_wh_seq'::regclass) |

## 2. 입하 테이블 시퀀스 (wms_inbiz_*)

| 스키마명 | 테이블명 | 컬럼명 | 시퀀스명 | 기본값 |
|---------|---------|--------|---------|--------|
| public | wms_inbiz | inbiz_seq | wms_inbiz_seq | nextval('wms_inbiz_seq'::regclass) |
| public | wms_inbiz_prod | inbiz_prod_seq | wms_inbiz_prod_seq | nextval('wms_inbiz_prod_seq'::regclass) |

## 3. 입고 테이블 시퀀스 (wms_inwh_*)

| 스키마명 | 테이블명 | 컬럼명 | 시퀀스명 | 기본값 |
|---------|---------|--------|---------|--------|
| public | wms_inwh | inwh_seq | wms_inwh_seq | nextval('wms_inwh_seq'::regclass) |
| public | wms_inwh_label | inwh_label_seq | wms_inwh_label_seq | nextval('wms_inwh_label_seq'::regclass) |
| public | wms_inwh_prod | inwh_prod_seq | wms_inwh_prod_seq | nextval('wms_inwh_prod_seq'::regclass) |
| public | wms_inwh_tran | inwh_tran_seq | wms_inwh_tran_seq | nextval('wms_inwh_tran_seq'::regclass) |

## 4. 출하 테이블 시퀀스 (wms_outbiz_*)

| 스키마명 | 테이블명 | 컬럼명 | 시퀀스명 | 기본값 |
|---------|---------|--------|---------|--------|
| public | wms_outbiz | outbiz_seq | wms_outbiz_seq | nextval('wms_outbiz_seq'::regclass) |
| public | wms_outbiz_prod | outbiz_prod_seq | wms_outbiz_prod_seq | nextval('wms_outbiz_prod_seq'::regclass) |
| public | wms_outbiz_tran | outbiz_tran_seq | wms_outbiz_tran_seq | nextval('wms_outbiz_tran_seq'::regclass) |

## 5. 출고 테이블 시퀀스 (wms_outwh_*)

| 스키마명 | 테이블명 | 컬럼명 | 시퀀스명 | 기본값 |
|---------|---------|--------|---------|--------|
| public | wms_outwh | outwh_seq | wms_outwh_seq | nextval('wms_outwh_seq'::regclass) |
| public | wms_outwh_assign | outwh_assign_seq | wms_outwh_assign_seq | nextval('wms_outwh_assign_seq'::regclass) |
| public | wms_outwh_prod | outwh_prod_seq | wms_outwh_prod_seq | nextval('wms_outwh_prod_seq'::regclass) |
| public | wms_outwh_tran | outwh_tran_seq | wms_outwh_tran_seq | nextval('wms_outwh_tran_seq'::regclass) |

## 6. 재고 테이블 시퀀스 (wms_inven_*)

| 스키마명 | 테이블명 | 컬럼명 | 시퀀스명 | 기본값 |
|---------|---------|--------|---------|--------|
| public | wms_inven_holding | inven_holding_seq | wms_inven_holding_seq | nextval('wms_inven_holding_seq'::regclass) |
| public | wms_inven_inout | inven_inout_seq | wms_inven_inout_seq | nextval('wms_inven_inout_seq'::regclass) |
| public | wms_inven_month | inven_month_seq | wms_inven_month_seq | nextval('wms_inven_month_seq'::regclass) |

## 7. 재고조정 테이블 시퀀스

### 7.1 차감조정 (wms_inven_ad_*)

| 스키마명 | 테이블명 | 컬럼명 | 시퀀스명 | 기본값 |
|---------|---------|--------|---------|--------|
| public | wms_inven_ad | ad_seq | wms_inven_ad_seq | nextval('wms_inven_ad_seq'::regclass) |
| public | wms_inven_ad_prod | ad_prod_seq | wms_inven_ad_prod_seq | nextval('wms_inven_ad_prod_seq'::regclass) |
| public | wms_inven_ad_tran | ad_tran_seq | wms_inven_ad_tran_seq | nextval('wms_inven_ad_tran_seq'::regclass) |

### 7.2 예외출고 (wms_inven_etc_*)

| 스키마명 | 테이블명 | 컬럼명 | 시퀀스명 | 기본값 |
|---------|---------|--------|---------|--------|
| public | wms_inven_etc | etc_seq | wms_inven_etc_seq | nextval('wms_inven_etc_seq'::regclass) |
| public | wms_inven_etc_prod | etc_prod_seq | wms_inven_etc_prod_seq | nextval('wms_inven_etc_prod_seq'::regclass) |
| public | wms_inven_etc_tran | etc_tran_seq | wms_inven_etc_tran_seq | nextval('wms_inven_etc_tran_seq'::regclass) |

### 7.3 재고이동 (wms_inven_mv_*)

| 스키마명 | 테이블명 | 컬럼명 | 시퀀스명 | 기본값 |
|---------|---------|--------|---------|--------|
| public | wms_inven_mv | mv_seq | wms_inven_mv_seq | nextval('wms_inven_mv_seq'::regclass) |
| public | wms_inven_mv_prod | mv_prod_seq | wms_inven_mv_prod_seq | nextval('wms_inven_mv_prod_seq'::regclass) |
| public | wms_inven_mv_tran | mv_tran_seq | wms_inven_mv_tran_seq | nextval('wms_inven_mv_tran_seq'::regclass) |

### 7.4 품목전환 (wms_inven_rp_*)

| 스키마명 | 테이블명 | 컬럼명 | 시퀀스명 | 기본값 |
|---------|---------|--------|---------|--------|
| public | wms_inven_rp | rp_seq | wms_inven_rp_seq | nextval('wms_inven_rp_seq'::regclass) |
| public | wms_inven_rp_prod | rp_prod_seq | wms_inven_rp_prod_seq | nextval('wms_inven_rp_prod_seq'::regclass) |
| public | wms_inven_rp_tran | rp_tran_seq | wms_inven_rp_tran_seq | nextval('wms_inven_rp_tran_seq'::regclass) |

### 7.5 세트작업 (wms_inven_st_*)

| 스키마명 | 테이블명 | 컬럼명 | 시퀀스명 | 기본값 |
|---------|---------|--------|---------|--------|
| public | wms_inven_st | st_seq | wms_inven_st_seq | nextval('wms_inven_st_seq'::regclass) |
| public | wms_inven_st_prod | st_prod_seq | wms_inven_st_prod_seq | nextval('wms_inven_st_prod_seq'::regclass) |
| public | wms_inven_st_tran | st_tran_seq | wms_inven_st_tran_seq | nextval('wms_inven_st_tran_seq'::regclass) |

## 8. 재고실사 테이블 시퀀스 (wms_st_*)

| 스키마명 | 테이블명 | 컬럼명 | 시퀀스명 | 기본값 |
|---------|---------|--------|---------|--------|
| public | wms_st_inven | st_inven_seq | wms_st_inven_seq | nextval('wms_st_inven_seq'::regclass) |
| public | wms_st_sch | st_sch_seq | wms_st_sch_seq | nextval('wms_st_sch_seq'::regclass) |
| public | wms_st_target | st_target_seq | wms_st_target_seq | nextval('wms_st_target_seq'::regclass) |
| public | wms_st_tran | st_tran_seq | wms_st_tran_seq | nextval('wms_st_tran_seq'::regclass) |

## 9. 반품 테이블 시퀀스 (wms_return_*)

| 스키마명 | 테이블명 | 컬럼명 | 시퀀스명 | 기본값 |
|---------|---------|--------|---------|--------|
| public | wms_return | return_seq | wms_return_seq | nextval('wms_return_seq'::regclass) |
| public | wms_return_prod | return_prod_seq | wms_return_prod_seq | nextval('wms_return_prod_seq'::regclass) |
| public | wms_return_tran | return_tran_seq | wms_return_tran_seq | nextval('wms_return_tran_seq'::regclass) |

## 10. 송장 테이블 시퀀스 (wms_invoice_*)

| 스키마명 | 테이블명 | 컬럼명 | 시퀀스명 | 기본값 |
|---------|---------|--------|---------|--------|
| public | wms_invoice | invoice_seq | wms_invoice_seq | nextval('wms_invoice_seq'::regclass) |
| public | wms_invoice_prod | invoice_prod_seq | wms_invoice_prod_seq | nextval('wms_invoice_prod_seq'::regclass) |
| public | wms_invoice_tran | invoice_tran_seq | wms_invoice_tran_seq | nextval('wms_invoice_tran_seq'::regclass) |

## 11. 상차 테이블 시퀀스 (wms_load_*)

| 스키마명 | 테이블명 | 컬럼명 | 시퀀스명 | 기본값 |
|---------|---------|--------|---------|--------|
| public | wms_load | load_seq | wms_load_seq | nextval('wms_load_seq'::regclass) |
| public | wms_load_prod | load_prod_seq | wms_load_prod_seq | nextval('wms_load_prod_seq'::regclass) |
| public | wms_load_tran | load_tran_seq | wms_load_tran_seq | nextval('wms_load_tran_seq'::regclass) |

## 12. 시스템 관리 테이블 시퀀스 (sm_*)

| 스키마명 | 테이블명 | 컬럼명 | 시퀀스명 | 기본값 |
|---------|---------|--------|---------|--------|
| public | sm_alarm_history | alarm_history_seq | sm_alarm_history_seq | nextval('sm_alarm_history_seq'::regclass) |
| public | sm_board | board_seq | sm_board_seq | nextval('sm_board_seq'::regclass) |
| public | sm_dlv_config | dlv_config_seq | sm_dlv_config_seq | nextval('sm_dlv_config_seq'::regclass) |
| public | sm_dlv_config_applied | dlv_config_applied_seq | sm_dlv_config_applied_seq | nextval('sm_dlv_config_applied_seq'::regclass) |
| public | sm_file | file_seq | sm_file_seq | nextval('sm_file_seq'::regclass) |
| public | sm_group | group_seq | sm_group_seq | nextval('sm_group_seq'::regclass) |
| public | sm_log_api | log_api_seq | sm_log_api_seq | nextval('sm_log_api_seq'::regclass) |
| public | sm_log_conn | log_conn_seq | sm_log_conn_seq | nextval('sm_log_conn_seq'::regclass) |
| public | sm_log_error | log_error_seq | sm_log_error_seq | nextval('sm_log_error_seq'::regclass) |
| public | sm_push_cycle | push_cycle_seq | sm_push_cycle_seq | nextval('sm_push_cycle_seq'::regclass) |
| public | sm_push_history | push_history_seq | sm_push_history_seq | nextval('sm_push_history_seq'::regclass) |
| public | sm_qrtz_change_log | qrtz_change_log_seq | sm_qrtz_change_log_seq | nextval('sm_qrtz_change_log_seq'::regclass) |
| public | sm_qrtz_exec_log | qrtz_exec_log_seq | sm_qrtz_exec_log_seq | nextval('sm_qrtz_exec_log_seq'::regclass) |
| public | sm_user_pwd_history | user_pwd_history_seq | sm_user_pwd_history_seq | nextval('sm_user_pwd_history_seq'::regclass) |

## 13. 외부시스템 인터페이스 테이블 시퀀스 (sif_*)

| 스키마명 | 테이블명 | 컬럼명 | 시퀀스명 | 기본값 |
|---------|---------|--------|---------|--------|
| public | sif_batch_history | if_seq | sif_batch_history_seq | nextval('sif_batch_history_seq'::regclass) |

## 14. 장비 인터페이스 테이블 시퀀스 (wes_*)

| 스키마명 | 테이블명 | 컬럼명 | 시퀀스명 | 기본값 |
|---------|---------|--------|---------|--------|
| public | wes_process_history | wes_proc_seq | wes_proc_seq | nextval('wes_proc_seq'::regclass) |

> **네이밍 예외**: DB 시퀀스명이 `wes_process_history_seq`가 아닌 `wes_proc_seq`로 생성되어 있다.

---

## 15. 첨부: 실행한 SQL

```sql
SELECT
    n.nspname AS schema_name,
    c.relname AS table_name,
    a.attname AS column_name,
    pg_get_serial_sequence(n.nspname || '.' || c.relname, a.attname) AS sequence_name,
    pg_get_expr(d.adbin, d.adrelid) AS default_value
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
JOIN pg_attribute a ON a.attrelid = c.oid
JOIN pg_attrdef d ON d.adrelid = c.oid AND d.adnum = a.attnum
WHERE c.relkind = 'r'
AND n.nspname NOT IN ('information_schema', 'pg_catalog')
AND pg_get_expr(d.adbin, d.adrelid) LIKE 'nextval%'
ORDER BY n.nspname, c.relname, a.attnum;
```
