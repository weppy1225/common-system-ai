# 테이블 기본키(Primary Key)

## 1. 마스터 테이블 (mdm_*)

| 테이블명 | 기본키 컬럼 | 제약조건명 |
|---------|------------|-----------|
| mdm_biz | biz_seq | mdm_biz_PK |
| mdm_biz_biz | biz_seq, ref_biz_seq | mdm_biz_biz_PK |
| mdm_biz_center | - (UK: biz_seq, center_seq) | - |
| mdm_biz_cont | biz_seq, cont_seq | mdm_biz_cont_PK |
| mdm_biz_prod | biz_seq, prod_seq | mdm_biz_prod_PK |
| mdm_biz_wh | - (UK: biz_seq, wh_seq) | - |
| mdm_car | car_seq | mdm_car_PK |
| mdm_center | center_seq | mdm_center_PK |
| mdm_cont | cont_seq | mdm_cont_PK |
| mdm_cont_prod | cont_prod_seq | mdm_cont_prod_PK |
| mdm_doc_no | biz_seq, inout_type_cd, base_ymd | mdm_doc_no_PK |
| mdm_label_paper | label_paper_seq | mdm_label_paper_PK |
| mdm_loc | loc_seq | mdm_loc_PK |
| mdm_prod | prod_seq | mdm_prod_PK |
| mdm_rp_prod | rp_prod_seq | mdm_rp_prod_PK |
| mdm_st_config | st_config_seq | PK_mdm_st_config |
| mdm_st_config_dtl | st_config_dtl_seq | PK_mdm_st_config_dtl |
| mdm_st_prod | st_prod_seq | mdm_st_prod_PK |
| mdm_user | user_id | mdm_user_PK |
| mdm_user_biz | - (UK: user_id, biz_seq) | - |
| mdm_user_center | - (UK: user_id, center_seq) | - |
| mdm_wh | wh_seq | mdm_wh_PK |

## 2. 입하 테이블 (wms_inbiz_*)

| 테이블명 | 기본키 컬럼 | 제약조건명 |
|---------|------------|-----------|
| wms_inbiz | inbiz_seq | wms_inbiz_PK |
| wms_inbiz_inwh | - (PK 없음, 복합 인덱스 활용) | - |
| wms_inbiz_prod | inbiz_prod_seq, inbiz_seq | wms_inbiz_prod_PK |

## 3. 입고 테이블 (wms_inwh_*)

| 테이블명 | 기본키 컬럼 | 제약조건명 |
|---------|------------|-----------|
| wms_inwh | inwh_seq | wms_inwh_PK |
| wms_inwh_label | inwh_label_seq | wms_inwh_label_PK |
| wms_inwh_prod | inwh_prod_seq, inwh_seq | wms_inwh_prod_PK |
| wms_inwh_tran | inwh_tran_seq, inwh_prod_seq, inwh_seq | wms_inwh_tran_PK |

## 4. 출하 테이블 (wms_outbiz_*)

| 테이블명 | 기본키 컬럼 | 제약조건명 |
|---------|------------|-----------|
| wms_outbiz | outbiz_seq | wms_outbiz_PK |
| wms_outbiz_prod | outbiz_prod_seq, outbiz_seq | wms_outbiz_prod_PK |
| wms_outbiz_tran | outbiz_tran_seq, outbiz_prod_seq, outbiz_seq | wms_outbiz_tran_PK |
| wms_outbiz_invoice | outbiz_seq, outbiz_prod_seq, invoice_seq, invoice_prod_seq | wms_outbiz_invoice_PK |
| wms_outbiz_load | load_seq, load_prod_seq, outbiz_seq, outbiz_prod_seq | wms_outbiz_load_PK |
| wms_outbiz_outwh | outbiz_seq, outbiz_prod_seq, outwh_seq, outwh_prod_seq | wms_outbiz_outwh_PK |

## 5. 출고 테이블 (wms_outwh_*)

| 테이블명 | 기본키 컬럼 | 제약조건명 |
|---------|------------|-----------|
| wms_outwh | outwh_seq | wms_outwh_PK |
| wms_outwh_prod | outwh_prod_seq, outwh_seq | wms_outwh_prod_PK |
| wms_outwh_tran | outwh_tran_seq, outwh_prod_seq, outwh_seq | wms_outwh_tran_PK |
| wms_outwh_assign | outwh_assign_seq | wms_outwh_assign_PK |

## 6. 재고 테이블 (wms_inven_*)

| 테이블명 | 기본키 컬럼 | 제약조건명 |
|---------|------------|-----------|
| wms_inven | biz_seq, center_seq, prod_seq, sku1, sku2, wh_seq, loc_seq | wms_inven_PK |
| wms_inven_sku | biz_seq, prod_seq, sku1, sku2 | wms_inven_sku_PK |
| wms_inven_holding | inven_holding_seq | wms_inven_holding_PK |
| wms_inven_inout | inven_inout_seq | wms_inven_inout_PK |
| wms_inven_month | inven_month_seq | wms_inven_month_PK |

## 7. 재고조정 테이블

### 7.1 차감조정 (wms_inven_ad_*)

| 테이블명 | 기본키 컬럼 | 제약조건명 |
|---------|------------|-----------|
| wms_inven_ad | ad_seq | wms_inven_ad_PK |
| wms_inven_ad_prod | ad_prod_seq, ad_seq | wms_inven_ad_prod_PK |
| wms_inven_ad_tran | ad_tran_seq, ad_prod_seq, ad_seq | wms_inven_ad_tran_PK |

### 7.2 예외출고 (wms_inven_etc_*)

| 테이블명 | 기본키 컬럼 | 제약조건명 |
|---------|------------|-----------|
| wms_inven_etc | etc_seq | wms_inven_etc_PK |
| wms_inven_etc_prod | etc_prod_seq, etc_seq | wms_inven_etc_prod_PK |
| wms_inven_etc_tran | etc_tran_seq, etc_prod_seq, etc_seq | wms_inven_etc_tran_PK |

### 7.3 재고이동 (wms_inven_mv_*)

| 테이블명 | 기본키 컬럼 | 제약조건명 |
|---------|------------|-----------|
| wms_inven_mv | mv_seq | wms_inven_mv_PK |
| wms_inven_mv_prod | mv_prod_seq, mv_seq | wms_inven_mv_prod_PK |
| wms_inven_mv_tran | mv_tran_seq, mv_prod_seq, mv_seq | wms_inven_mv_tran_PK |

### 7.4 품목전환 (wms_inven_rp_*)

| 테이블명 | 기본키 컬럼 | 제약조건명 |
|---------|------------|-----------|
| wms_inven_rp | rp_seq | wms_inven_rp_PK |
| wms_inven_rp_prod | rp_prod_seq, rp_seq | wms_inven_rp_prod_PK |
| wms_inven_rp_tran | rp_tran_seq, rp_prod_seq, rp_seq | wms_inven_rp_tran_PK |

### 7.5 세트작업 (wms_inven_st_*)

| 테이블명 | 기본키 컬럼 | 제약조건명 |
|---------|------------|-----------|
| wms_inven_st | st_seq | wms_inven_st_PK |
| wms_inven_st_prod | st_prod_seq, st_seq | wms_inven_st_prod_PK |
| wms_inven_st_tran | st_tran_seq, st_prod_seq, st_seq | wms_inven_st_tran_PK |

## 8. 재고실사 테이블 (wms_st_*)

| 테이블명 | 기본키 컬럼 | 제약조건명 |
|---------|------------|-----------|
| wms_st_sch | st_sch_seq | wms_st_sch_PK |
| wms_st_inven | st_inven_seq, st_sch_seq | wms_st_inven_PK |
| wms_st_target | st_target_seq, st_sch_seq | wms_st_target_PK |
| wms_st_tran | st_tran_seq, st_sch_seq | wms_st_tran_PK |

## 9. 반품 테이블 (wms_return_*)

| 테이블명 | 기본키 컬럼 | 제약조건명 |
|---------|------------|-----------|
| wms_return | return_seq | wms_return_PK |
| wms_return_prod | return_prod_seq, return_seq | wms_return_prod_PK |
| wms_return_tran | return_tran_seq, return_prod_seq, return_seq | wms_return_tran_PK |

## 10. 송장 테이블 (wms_invoice_*)

| 테이블명 | 기본키 컬럼 | 제약조건명 |
|---------|------------|-----------|
| wms_invoice | invoice_seq | wms_invoice_PK |
| wms_invoice_prod | invoice_prod_seq, invoice_seq | wms_invoice_prod_PK |
| wms_invoice_tran | invoice_tran_seq, invoice_prod_seq, invoice_seq | wms_invoice_tran_PK |

## 11. 상차 테이블 (wms_load_*)

| 테이블명 | 기본키 컬럼 | 제약조건명 |
|---------|------------|-----------|
| wms_load | load_seq | wms_load_PK |
| wms_load_prod | load_prod_seq, load_seq | wms_load_prod_PK |
| wms_load_tran | load_tran_seq, load_prod_seq, load_seq | wms_load_tran_PK |

## 12. 시스템 관리 테이블 (sm_*)

| 테이블명 | 기본키 컬럼 | 제약조건명 |
|---------|------------|-----------|
| sm_alarm_history | alarm_history_seq | sm_alarm_history_PK |
| sm_alarm_unrcv | user_id, menu_cd | sm_alarm_unrcv_PK |
| sm_api_config | biz_seq, if_id | sm_api_config_PK |
| sm_biz_config | biz_seq | sm_biz_config_PK |
| sm_board | board_seq | sm_board_PK |
| sm_comm_d | biz_seq, comm_h_cd, comm_d_cd | sm_comm_d_PK |
| sm_comm_h | biz_seq, comm_h_cd | sm_comm_h_PK |
| sm_dlv_config | dlv_config_seq | sm_dlv_config_PK |
| sm_dlv_config_applied | dlv_config_applied_seq | sm_dlv_config_applied_PK |
| sm_file | file_seq | sm_file_PK |
| sm_file_req | file_seq, req_type_cd, req_seq | sm_file_req_PK |
| sm_group | group_seq | sm_group_PK |
| sm_log_api | log_api_seq | sm_log_api_PK |
| sm_log_conn | log_conn_seq | sm_log_conn_PK |
| sm_log_conn_dtl | log_conn_seq | sm_log_conn_dtl_PK |
| sm_log_error | log_error_seq | sm_log_error_PK |
| sm_log_menu | biz_seq, yyyymmdd, menu_cd | sm_log_menu_PK |
| sm_menu | menu_cd | sm_menu_PK |
| sm_menu_group | menu_cd, group_seq | sm_menu_group_PK |
| sm_menu_opt_config | biz_seq, menu_cd | sm_menu_opt_config_PK |
| sm_ob_proc_opt_config | biz_seq, outbiz_type_cd | sm_ob_proc_opt_config_PK |
| sm_opt_config | biz_seq | sm_opt_config_PK |
| sm_prod_opt_config | biz_seq, prod_div_cd | sm_prod_opt_config_PK |
| sm_push_cycle | push_cycle_seq | sm_push_cycle_PK |
| sm_push_history | push_history_seq | sm_push_history_PK |
| sm_push_unrcv | user_id, push_type_cd | sm_push_unrcv_PK |
| sm_qrtz_change_log | qrtz_change_log_seq | sm_qrtz_change_log_PK |
| sm_qrtz_exec_log | qrtz_exec_log_seq | sm_qrtz_exec_log_PK |
| sm_qrtz_job_state | job_cls_nm | sm_qrtz_job_state_PK |
| sm_user_pwd_history | user_pwd_history_seq | sm_user_pwd_history_PK |

## 13. 외부시스템 인터페이스 테이블 (sif_*)

| 테이블명 | 기본키 컬럼 | 제약조건명 |
|---------|------------|-----------|
| sif_batch_history | if_seq | sif_batch_history_PK |

## 14. 장비 인터페이스 테이블 (wes_*)

| 테이블명 | 기본키 컬럼 | 제약조건명 |
|---------|------------|-----------|
| wes_process_history | wes_proc_seq | wes_process_history_PK |

## 15. 첨부: 실행한 SQL

```sql
SELECT
    tc.table_name,
    kcu.column_name,
    tc.constraint_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
WHERE tc.constraint_type = 'PRIMARY KEY'
AND tc.table_schema = 'public'
ORDER BY tc.table_name, kcu.ordinal_position;
```
