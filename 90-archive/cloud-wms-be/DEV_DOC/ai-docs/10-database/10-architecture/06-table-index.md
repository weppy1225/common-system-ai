# 테이블 인덱스 (Table Index)

## 1. 마스터 테이블 (mdm_*)

| 테이블명 | 인덱스명 | Unique | Primary | 컬럼 |
|---------|---------|--------|---------|------|
| mdm_biz | mdm_biz_PK | true | true | biz_seq |
| mdm_biz_biz | mdm_biz_biz_PK | true | true | biz_seq, ref_biz_seq |
| mdm_biz_center | UK_mdm_biz_center | true | false | biz_seq, center_seq |
| mdm_biz_cont | mdm_biz_cont_PK | true | true | biz_seq, cont_seq |
| mdm_biz_prod | mdm_biz_prod_PK | true | true | biz_seq, prod_seq |
| mdm_biz_wh | UK_mdm_biz_wh | true | false | biz_seq, wh_seq |
| mdm_car | mdm_car_PK | true | true | car_seq |
| mdm_center | mdm_center_PK | true | true | center_seq |
| mdm_cont | mdm_cont_PK | true | true | cont_seq |
| mdm_cont_prod | UK_mdm_cont_prod | true | false | cont_seq, prod_seq |
| mdm_cont_prod | mdm_cont_prod_PK | true | true | cont_prod_seq |
| mdm_doc_no | mdm_doc_no_PK | true | true | biz_seq, inout_type_cd, base_ymd |
| mdm_label_paper | mdm_label_paper_PK | true | true | label_paper_seq |
| mdm_loc | mdm_loc_PK | true | true | loc_seq |
| mdm_prod | mdm_prod_PK | true | true | prod_seq |
| mdm_rp_prod | mdm_rp_prod_PK | true | true | rp_prod_seq |
| mdm_st_config | PK_mdm_st_config | true | true | st_config_seq |
| mdm_st_config_dtl | FK_mdm_st_config_dtl_st_config_seq | false | false | st_config_seq |
| mdm_st_config_dtl | PK_mdm_st_config_dtl | true | true | st_config_dtl_seq |
| mdm_st_prod | mdm_st_prod_PK | true | true | st_prod_seq |
| mdm_user | mdm_user_PK | true | true | user_id |
| mdm_user_biz | UK_mdm_user_biz | true | false | biz_seq, user_id |
| mdm_user_center | UK_mdm_user_center | true | false | center_seq, user_id |
| mdm_wh | mdm_wh_PK | true | true | wh_seq |

## 2. 입하 테이블 (wms_inbiz_*)

| 테이블명 | 인덱스명 | Unique | Primary | 컬럼 |
|---------|---------|--------|---------|------|
| wms_inbiz | wms_inbiz_PK | true | true | inbiz_seq |
| wms_inbiz_inwh | IX_wms_inbiz_inwh_inbiz | false | false | inbiz_seq, inbiz_prod_seq |
| wms_inbiz_inwh | IX_wms_inbiz_inwh_inwh | false | false | inwh_seq, inwh_prod_seq |
| wms_inbiz_prod | wms_inbiz_prod_PK | true | true | inbiz_prod_seq, inbiz_seq |

## 3. 입고 테이블 (wms_inwh_*)

| 테이블명 | 인덱스명 | Unique | Primary | 컬럼 |
|---------|---------|--------|---------|------|
| wms_inwh | IX_wms_inwh2 | false | false | biz_seq, center_seq, req_ymd |
| wms_inwh | UK_wms_inwh | true | false | biz_seq, inwh_no |
| wms_inwh | wms_inwh_PK | true | true | inwh_seq |
| wms_inwh_label | wms_inwh_label_PK | true | true | inwh_label_seq |
| wms_inwh_prod | wms_inwh_prod_PK | true | true | inwh_prod_seq, inwh_seq |
| wms_inwh_tran | wms_inwh_tran_PK | true | true | inwh_tran_seq, inwh_prod_seq, inwh_seq |

## 4. 출하 테이블 (wms_outbiz_*)

| 테이블명 | 인덱스명 | Unique | Primary | 컬럼 |
|---------|---------|--------|---------|------|
| wms_outbiz | wms_outbiz_PK | true | true | outbiz_seq |
| wms_outbiz_prod | wms_outbiz_prod_PK | true | true | outbiz_prod_seq, outbiz_seq |
| wms_outbiz_tran | UK_wms_outbiz_tran | true | false | outbiz_tran_seq |
| wms_outbiz_tran | wms_outbiz_tran_PK | true | true | outbiz_tran_seq, outbiz_prod_seq, outbiz_seq |
| wms_outbiz_invoice | wms_outbiz_invoice_PK | true | true | outbiz_seq, outbiz_prod_seq, invoice_seq, invoice_prod_seq |
| wms_outbiz_load | wms_outbiz_load_PK | true | true | load_seq, load_prod_seq, outbiz_seq, outbiz_prod_seq |
| wms_outbiz_outwh | wms_outbiz_outwh_PK | true | true | outbiz_seq, outbiz_prod_seq, outwh_seq, outwh_prod_seq |

## 5. 출고 테이블 (wms_outwh_*)

| 테이블명 | 인덱스명 | Unique | Primary | 컬럼 |
|---------|---------|--------|---------|------|
| wms_outwh | wms_outwh_PK | true | true | outwh_seq |
| wms_outwh_prod | wms_outwh_prod_PK | true | true | outwh_prod_seq, outwh_seq |
| wms_outwh_tran | wms_outwh_tran_PK | true | true | outwh_tran_seq, outwh_prod_seq, outwh_seq |
| wms_outwh_assign | IX_wms_outwh_assign | false | false | biz_seq, center_seq, prod_seq |
| wms_outwh_assign | IX_wms_outwh_assign2 | false | false | req_seq, req_prod_seq |
| wms_outwh_assign | wms_outwh_assign_PK | true | true | outwh_assign_seq |

## 6. 재고 테이블 (wms_inven_*)

| 테이블명 | 인덱스명 | Unique | Primary | 컬럼 |
|---------|---------|--------|---------|------|
| wms_inven | UK_wms_inven | true | false | biz_seq, center_seq, prod_seq, sku1, sku2, wh_seq, loc_seq |
| wms_inven | wms_inven_PK | true | true | biz_seq, center_seq, prod_seq, sku1, sku2, wh_seq, loc_seq |
| wms_inven_sku | wms_inven_sku_PK | true | true | biz_seq, prod_seq, sku1, sku2 |
| wms_inven_holding | wms_inven_holding_PK | true | true | inven_holding_seq |
| wms_inven_inout | wms_inven_inout_PK | true | true | inven_inout_seq |
| wms_inven_month | wms_inven_month_PK | true | true | inven_month_seq |

> **참고**: `UK_wms_inven`은 PK(`wms_inven_PK`)와 동일한 컬럼 조합으로 구성되어 있으며, DB에 중복 UK 제약조건이 존재한다.

## 7. 재고조정 테이블

### 7.1 차감조정 (wms_inven_ad_*)

| 테이블명 | 인덱스명 | Unique | Primary | 컬럼 |
|---------|---------|--------|---------|------|
| wms_inven_ad | IX_wms_inven_ad | false | false | biz_seq, center_seq, req_ymd |
| wms_inven_ad | UK_wms_inven_ad | true | false | biz_seq, ad_no |
| wms_inven_ad | wms_inven_ad_PK | true | true | ad_seq |
| wms_inven_ad_prod | wms_inven_ad_prod_PK | true | true | ad_prod_seq, ad_seq |
| wms_inven_ad_tran | wms_inven_ad_tran_PK | true | true | ad_tran_seq, ad_prod_seq, ad_seq |

### 7.2 예외출고 (wms_inven_etc_*)

| 테이블명 | 인덱스명 | Unique | Primary | 컬럼 |
|---------|---------|--------|---------|------|
| wms_inven_etc | IX_wms_inven_etc | false | false | biz_seq, center_seq, req_ymd |
| wms_inven_etc | UK_wms_inven_etc | true | false | biz_seq, etc_no |
| wms_inven_etc | wms_inven_etc_PK | true | true | etc_seq |
| wms_inven_etc_prod | wms_inven_etc_prod_PK | true | true | etc_prod_seq, etc_seq |
| wms_inven_etc_tran | wms_inven_etc_tran_PK | true | true | etc_tran_seq, etc_prod_seq, etc_seq |

### 7.3 재고이동 (wms_inven_mv_*)

| 테이블명 | 인덱스명 | Unique | Primary | 컬럼 |
|---------|---------|--------|---------|------|
| wms_inven_mv | IX_wms_inven_mv | false | false | biz_seq, center_seq, req_ymd |
| wms_inven_mv | UK_wms_inven_mv | true | false | biz_seq, mv_no |
| wms_inven_mv | wms_inven_mv_PK | true | true | mv_seq |
| wms_inven_mv_prod | wms_inven_mv_prod_PK | true | true | mv_prod_seq, mv_seq |
| wms_inven_mv_tran | wms_inven_mv_tran_PK | true | true | mv_tran_seq, mv_prod_seq, mv_seq |

### 7.4 품목전환 (wms_inven_rp_*)

| 테이블명 | 인덱스명 | Unique | Primary | 컬럼 |
|---------|---------|--------|---------|------|
| wms_inven_rp | wms_inven_rp_PK | true | true | rp_seq |
| wms_inven_rp_prod | wms_inven_rp_prod_PK | true | true | rp_prod_seq, rp_seq |
| wms_inven_rp_tran | wms_inven_rp_tran_PK | true | true | rp_tran_seq, rp_prod_seq, rp_seq |

### 7.5 세트작업 (wms_inven_st_*)

| 테이블명 | 인덱스명 | Unique | Primary | 컬럼 |
|---------|---------|--------|---------|------|
| wms_inven_st | IX_wms_inven_st | false | false | biz_seq, center_seq, req_ymd |
| wms_inven_st | UK_wms_inven_st | true | false | biz_seq, st_no |
| wms_inven_st | wms_inven_st_PK | true | true | st_seq |
| wms_inven_st_prod | wms_inven_st_prod_PK | true | true | st_prod_seq, st_seq |
| wms_inven_st_tran | wms_inven_st_tran_PK | true | true | st_tran_seq, st_prod_seq, st_seq |

## 8. 재고실사 테이블 (wms_st_*)

| 테이블명 | 인덱스명 | Unique | Primary | 컬럼 |
|---------|---------|--------|---------|------|
| wms_st_sch | UK_wms_st_sch | true | false | yyyy, biz_seq, center_seq, st_idx |
| wms_st_sch | wms_st_sch_PK | true | true | st_sch_seq |
| wms_st_inven | wms_st_inven_PK | true | true | st_inven_seq, st_sch_seq |
| wms_st_target | IX_wms_st_target | false | false | st_sch_seq |
| wms_st_target | wms_st_target_PK | true | true | st_target_seq, st_sch_seq |
| wms_st_tran | wms_st_tran_PK | true | true | st_tran_seq, st_sch_seq |

## 9. 반품 테이블 (wms_return_*)

| 테이블명 | 인덱스명 | Unique | Primary | 컬럼 |
|---------|---------|--------|---------|------|
| wms_return | IX_wms_return | false | false | biz_seq, center_seq, req_ymd |
| wms_return | UK_wms_return | true | false | biz_seq, return_no |
| wms_return | wms_return_PK | true | true | return_seq |
| wms_return_prod | wms_return_prod_PK | true | true | return_prod_seq, return_seq |
| wms_return_tran | wms_return_tran_PK | true | true | return_tran_seq, return_prod_seq, return_seq |

## 10. 송장 테이블 (wms_invoice_*)

| 테이블명 | 인덱스명 | Unique | Primary | 컬럼 |
|---------|---------|--------|---------|------|
| wms_invoice | IX_wms_invoice | false | false | biz_seq, group_outwh_no |
| wms_invoice | wms_invoice_PK | true | true | invoice_seq |
| wms_invoice_prod | wms_invoice_prod_PK | true | true | invoice_prod_seq, invoice_seq |
| wms_invoice_tran | wms_invoice_tran_PK | true | true | invoice_tran_seq, invoice_prod_seq, invoice_seq |

## 11. 상차 테이블 (wms_load_*)

| 테이블명 | 인덱스명 | Unique | Primary | 컬럼 |
|---------|---------|--------|---------|------|
| wms_load | wms_load_PK | true | true | load_seq |
| wms_load_prod | wms_load_prod_PK | true | true | load_prod_seq, load_seq |
| wms_load_tran | wms_load_tran_PK | true | true | load_tran_seq, load_prod_seq, load_seq |

## 12. 시스템 관리 테이블 (sm_*)

| 테이블명 | 인덱스명 | Unique | Primary | 컬럼 |
|---------|---------|--------|---------|------|
| sm_alarm_history | sm_alarm_history_PK | true | true | alarm_history_seq |
| sm_alarm_unrcv | sm_alarm_unrcv_PK | true | true | user_id, menu_cd |
| sm_api_config | sm_api_config_PK | true | true | biz_seq, if_id |
| sm_biz_config | sm_biz_config_PK | true | true | biz_seq |
| sm_board | sm_board_PK | true | true | board_seq |
| sm_comm_d | sm_comm_d_PK | true | true | biz_seq, comm_h_cd, comm_d_cd |
| sm_comm_h | sm_comm_h_PK | true | true | biz_seq, comm_h_cd |
| sm_dlv_config | sm_dlv_config_PK | true | true | dlv_config_seq |
| sm_dlv_config_applied | UK_sm_dlv_config_applied | true | false | dlv_config_seq, center_seq, biz_seq |
| sm_dlv_config_applied | sm_dlv_config_applied_PK | true | true | dlv_config_applied_seq |
| sm_file | UK_sm_file | true | false | file_uuid |
| sm_file | sm_file_PK | true | true | file_seq |
| sm_file_req | sm_file_req_PK | true | true | file_seq, req_type_cd, req_seq |
| sm_group | sm_group_PK | true | true | group_seq |
| sm_log_api | sm_log_api_PK | true | true | log_api_seq |
| sm_log_conn | sm_log_conn_PK | true | true | log_conn_seq |
| sm_log_conn_dtl | sm_log_conn_dtl_PK | true | true | log_conn_seq |
| sm_log_error | sm_log_error_PK | true | true | log_error_seq |
| sm_log_menu | sm_log_menu_PK | true | true | biz_seq, yyyymmdd, menu_cd |
| sm_menu | sm_menu_PK | true | true | menu_cd |
| sm_menu_group | sm_menu_group_PK | true | true | menu_cd, group_seq |
| sm_menu_opt_config | sm_menu_opt_config_PK | true | true | biz_seq, menu_cd |
| sm_ob_proc_opt_config | sm_ob_proc_opt_config_PK | true | true | biz_seq, outbiz_type_cd |
| sm_opt_config | sm_opt_config_PK | true | true | biz_seq |
| sm_prod_opt_config | sm_prod_opt_config_PK | true | true | biz_seq, prod_div_cd |
| sm_push_cycle | sm_push_cycle_PK | true | true | push_cycle_seq |
| sm_push_history | sm_push_history_PK | true | true | push_history_seq |
| sm_push_unrcv | sm_push_unrcv_PK | true | true | user_id, push_type_cd |
| sm_qrtz_change_log | sm_qrtz_change_log_PK | true | true | qrtz_change_log_seq |
| sm_qrtz_exec_log | sm_qrtz_exec_log_PK | true | true | qrtz_exec_log_seq |
| sm_qrtz_job_state | sm_qrtz_job_state_PK | true | true | job_cls_nm |
| sm_user_pwd_history | sm_user_pwd_history_PK | true | true | user_pwd_history_seq |

## 13. 외부시스템 인터페이스 테이블 (sif_*)

| 테이블명 | 인덱스명 | Unique | Primary | 컬럼 |
|---------|---------|--------|---------|------|
| sif_batch_history | sif_batch_history_PK | true | true | if_seq |

## 14. 장비 인터페이스 테이블 (wes_*)

| 테이블명 | 인덱스명 | Unique | Primary | 컬럼 |
|---------|---------|--------|---------|------|
| wes_process_history | wes_process_history_PK | true | true | wes_proc_seq |

## 15. 첨부: 실행한 SQL

```sql
SELECT
    t.relname  AS table_name,
    i.relname  AS index_name,
    ix.indisunique AS is_unique,
    ix.indisprimary AS is_primary,
    array_agg(a.attname ORDER BY array_position(ix.indkey, a.attnum)) AS columns
FROM pg_class t
JOIN pg_index ix ON t.oid = ix.indrelid
JOIN pg_class i ON i.oid = ix.indexrelid
JOIN pg_attribute a ON a.attrelid = t.oid AND a.attnum = ANY(ix.indkey)
JOIN pg_namespace n ON n.oid = t.relnamespace
WHERE n.nspname = 'public'
AND t.relkind = 'r'
GROUP BY t.relname, i.relname, ix.indisunique, ix.indisprimary
ORDER BY t.relname, i.relname;
```
