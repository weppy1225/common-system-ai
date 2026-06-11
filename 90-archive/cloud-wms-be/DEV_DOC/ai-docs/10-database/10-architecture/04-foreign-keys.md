# 테이블 외래키(Foreign Key)

## 1. 마스터 테이블 관련 외래키 (mdm_*)

| 외래키 테이블 | 외래키 컬럼 | 참조 테이블 | 참조 컬럼 | 제약조건명 |
|--------------|------------|------------|----------|-----------|
| mdm_biz_biz | ref_biz_seq | mdm_biz | biz_seq | mdm_biz_TO_mdm_biz_biz2 |
| mdm_biz_biz | biz_seq | mdm_biz | biz_seq | mdm_biz_TO_mdm_biz_biz |
| mdm_biz_center | center_seq | mdm_center | center_seq | mdm_center_TO_mdm_biz_center |
| mdm_biz_center | biz_seq | mdm_biz | biz_seq | mdm_biz_TO_mdm_biz_center |
| mdm_biz_cont | biz_seq | mdm_biz | biz_seq | mdm_biz_TO_mdm_biz_cont |
| mdm_biz_cont | cont_seq | mdm_cont | cont_seq | mdm_cont_TO_mdm_biz_cont |
| mdm_biz_prod | prod_seq | mdm_prod | prod_seq | mdm_prod_TO_mdm_biz_prod |
| mdm_biz_prod | biz_seq | mdm_biz | biz_seq | mdm_biz_TO_mdm_biz_prod |
| mdm_biz_wh | wh_seq | mdm_wh | wh_seq | mdm_wh_TO_mdm_biz_wh |
| mdm_biz_wh | biz_seq | mdm_biz | biz_seq | mdm_biz_TO_mdm_biz_wh |
| mdm_car | biz_seq | mdm_biz | biz_seq | mdm_biz_TO_mdm_car |
| mdm_cont_prod | prod_seq | mdm_prod | prod_seq | mdm_prod_TO_mdm_cont_prod |
| mdm_cont_prod | biz_seq | mdm_biz | biz_seq | mdm_biz_TO_mdm_cont_prod |
| mdm_cont_prod | cont_seq | mdm_cont | cont_seq | mdm_cont_TO_mdm_cont_prod |
| mdm_doc_no | biz_seq | mdm_biz | biz_seq | mdm_biz_TO_mdm_doc_no |
| mdm_loc | wh_seq | mdm_wh | wh_seq | mdm_wh_TO_mdm_loc |
| mdm_prod | parent_label_paper_seq | mdm_label_paper | label_paper_seq | mdm_label_paper_TO_mdm_prod2 |
| mdm_prod | label_paper_seq | mdm_label_paper | label_paper_seq | mdm_label_paper_TO_mdm_prod |
| mdm_rp_prod | prod_seq | mdm_prod | prod_seq | mdm_prod_TO_mdm_rp_prod |
| mdm_rp_prod | ref_rp_prod_seq | mdm_rp_prod | rp_prod_seq | mdm_rp_prod_TO_mdm_rp_prod |
| mdm_st_config_dtl | st_config_seq | mdm_st_config | st_config_seq | FK_mdm_st_config_dtl_st_config_seq |
| mdm_st_prod | ref_st_prod_seq | mdm_st_prod | st_prod_seq | mdm_st_prod_TO_mdm_st_prod |
| mdm_wh | center_seq | mdm_center | center_seq | mdm_center_TO_mdm_wh |

## 2. 시스템 관리 테이블 관련 외래키 (sm_*)

| 외래키 테이블 | 외래키 컬럼 | 참조 테이블 | 참조 컬럼 | 제약조건명 |
|--------------|------------|------------|----------|-----------|
| mdm_user | group_seq | sm_group | group_seq | sm_group_TO_mdm_user |
| mdm_user_biz | user_id | mdm_user | user_id | mdm_user_TO_mdm_user_biz |
| mdm_user_biz | biz_seq | mdm_biz | biz_seq | mdm_biz_TO_mdm_user_biz |
| mdm_user_center | center_seq | mdm_center | center_seq | mdm_center_TO_mdm_user_center |
| mdm_user_center | user_id | mdm_user | user_id | mdm_user_TO_mdm_user_center |
| sm_alarm_history | biz_seq | mdm_biz | biz_seq | mdm_biz_TO_sm_alarm_history |
| sm_comm_d | biz_seq, comm_h_cd | sm_comm_h | biz_seq, comm_h_cd | sm_comm_h_TO_sm_comm_d |
| sm_dlv_config_applied | dlv_config_seq | sm_dlv_config | dlv_config_seq | sm_dlv_config_TO_sm_dlv_config_applied |
| sm_file | biz_seq | mdm_biz | biz_seq | mdm_biz_TO_sm_file |
| sm_file_req | file_seq | sm_file | file_seq | sm_file_TO_sm_file_req |
| sm_group | biz_seq | mdm_biz | biz_seq | mdm_biz_TO_sm_group |
| sm_log_conn_dtl | log_conn_seq | sm_log_conn | log_conn_seq | sm_log_conn_TO_sm_log_conn_dtl |
| sm_menu_group | group_seq | sm_group | group_seq | sm_group_TO_sm_menu_group |
| sm_menu_group | menu_cd | sm_menu | menu_cd | sm_menu_TO_sm_menu_group |
| sm_menu_opt_config | menu_cd | sm_menu | menu_cd | sm_menu_TO_sm_menu_opt_config |

## 3. WMS 입하/입고 테이블 외래키 (wms_inbiz_*, wms_inwh_*)

| 외래키 테이블 | 외래키 컬럼 | 참조 테이블 | 참조 컬럼 | 제약조건명 |
|--------------|------------|------------|----------|-----------|
| wms_inbiz_inwh | inbiz_seq, inbiz_prod_seq | wms_inbiz_prod | inbiz_seq, inbiz_prod_seq | wms_inbiz_prod_TO_wms_inbiz_inwh |
| wms_inbiz_inwh | inwh_seq, inwh_prod_seq | wms_inwh_prod | inwh_seq, inwh_prod_seq | wms_inwh_prod_TO_wms_inbiz_inwh |
| wms_inbiz_prod | inbiz_seq | wms_inbiz | inbiz_seq | wms_inbiz_TO_wms_inbiz_prod |
| wms_inwh_prod | inwh_seq | wms_inwh | inwh_seq | wms_inwh_TO_wms_inwh_prod |
| wms_inwh_tran | inwh_prod_seq, inwh_seq | wms_inwh_prod | inwh_prod_seq, inwh_seq | wms_inwh_prod_TO_wms_inwh_tran |

## 4. WMS 출하/출고 테이블 외래키 (wms_outbiz_*, wms_outwh_*)

| 외래키 테이블 | 외래키 컬럼 | 참조 테이블 | 참조 컬럼 | 제약조건명 |
|--------------|------------|------------|----------|-----------|
| wms_outbiz_invoice | outbiz_seq, outbiz_prod_seq | wms_outbiz_prod | outbiz_seq, outbiz_prod_seq | wms_outbiz_prod_TO_wms_outbiz_invoice |
| wms_outbiz_invoice | invoice_seq, invoice_prod_seq | wms_invoice_prod | invoice_seq, invoice_prod_seq | wms_invoice_prod_TO_wms_outbiz_invoice |
| wms_outbiz_load | outbiz_seq, outbiz_prod_seq | wms_outbiz_prod | outbiz_seq, outbiz_prod_seq | wms_outbiz_prod_TO_wms_outbiz_load |
| wms_outbiz_load | load_seq, load_prod_seq | wms_load_prod | load_seq, load_prod_seq | wms_load_prod_TO_wms_outbiz_load |
| wms_outbiz_outwh | outbiz_seq, outbiz_prod_seq | wms_outbiz_prod | outbiz_seq, outbiz_prod_seq | wms_outbiz_prod_TO_wms_outbiz_outwh |
| wms_outbiz_outwh | outwh_seq, outwh_prod_seq | wms_outwh_prod | outwh_seq, outwh_prod_seq | wms_outwh_prod_TO_wms_outbiz_outwh |
| wms_outbiz_outwh | prod_seq | mdm_prod | prod_seq | mdm_prod_TO_wms_outbiz_outwh |
| wms_outbiz_prod | outbiz_seq | wms_outbiz | outbiz_seq | wms_outbiz_TO_wms_outbiz_prod |
| wms_outbiz_tran | outbiz_prod_seq, outbiz_seq | wms_outbiz_prod | outbiz_prod_seq, outbiz_seq | wms_outbiz_prod_TO_wms_outbiz_tran |
| wms_outbiz_tran | prod_seq | mdm_prod | prod_seq | mdm_prod_TO_wms_outbiz_tran |
| wms_outbiz_tran | fr_wh_seq | mdm_wh | wh_seq | mdm_wh_TO_wms_outbiz_tran |
| wms_outbiz_tran | fr_loc_seq | mdm_loc | loc_seq | mdm_loc_TO_wms_outbiz_tran |
| wms_outbiz_tran | invoice_seq | wms_invoice | invoice_seq | wms_invoice_TO_wms_outbiz_tran |
| wms_outwh_prod | outwh_seq | wms_outwh | outwh_seq | wms_outwh_TO_wms_outwh_prod |
| wms_outwh_tran | outwh_prod_seq, outwh_seq | wms_outwh_prod | outwh_prod_seq, outwh_seq | wms_outwh_prod_TO_wms_outwh_tran |
| wms_outwh_tran | prod_seq | mdm_prod | prod_seq | mdm_prod_TO_wms_outwh_tran |
| wms_outwh_tran | fr_wh_seq | mdm_wh | wh_seq | mdm_wh_TO_wms_outwh_tran |
| wms_outwh_tran | fr_loc_seq | mdm_loc | loc_seq | mdm_loc_TO_wms_outwh_tran |

## 5. WMS 재고조정 테이블 외래키 (wms_inven_*)

| 외래키 테이블 | 외래키 컬럼 | 참조 테이블 | 참조 컬럼 | 제약조건명 |
|--------------|------------|------------|----------|-----------|
| wms_inven_ad_prod | ad_seq | wms_inven_ad | ad_seq | wms_inven_ad_TO_wms_inven_ad_prod |
| wms_inven_ad_tran | ad_prod_seq, ad_seq | wms_inven_ad_prod | ad_prod_seq, ad_seq | wms_inven_ad_prod_TO_wms_inven_ad_tran |
| wms_inven_ad_tran | prod_seq | mdm_prod | prod_seq | mdm_prod_TO_wms_inven_ad_tran |
| wms_inven_ad_tran | wh_seq | mdm_wh | wh_seq | mdm_wh_TO_wms_inven_ad_tran |
| wms_inven_ad_tran | loc_seq | mdm_loc | loc_seq | mdm_loc_TO_wms_inven_ad_tran |
| wms_inven_etc_prod | etc_seq | wms_inven_etc | etc_seq | wms_inven_etc_TO_wms_inven_etc_prod |
| wms_inven_etc_tran | etc_seq, etc_prod_seq | wms_inven_etc_prod | etc_seq, etc_prod_seq | wms_inven_etc_prod_TO_wms_inven_etc_tran |
| wms_inven_mv_prod | mv_seq | wms_inven_mv | mv_seq | wms_inven_mv_TO_wms_inven_mv_prod |
| wms_inven_mv_tran | mv_prod_seq, mv_seq | wms_inven_mv_prod | mv_prod_seq, mv_seq | wms_inven_mv_prod_TO_wms_inven_mv_tran |
| wms_inven_mv_tran | prod_seq | mdm_prod | prod_seq | mdm_prod_TO_wms_inven_mv_tran |
| wms_inven_mv_tran | fr_wh_seq | mdm_wh | wh_seq | mdm_wh_TO_wms_inven_mv_tran_fr |
| wms_inven_mv_tran | fr_loc_seq | mdm_loc | loc_seq | mdm_loc_TO_wms_inven_mv_tran_fr |
| wms_inven_mv_tran | to_wh_seq | mdm_wh | wh_seq | mdm_wh_TO_wms_inven_mv_tran_to |
| wms_inven_mv_tran | to_loc_seq | mdm_loc | loc_seq | mdm_loc_TO_wms_inven_mv_tran_to |
| wms_inven_rp_prod | rp_seq | wms_inven_rp | rp_seq | wms_inven_rp_TO_wms_inven_rp_prod |
| wms_inven_rp_tran | rp_seq, rp_prod_seq | wms_inven_rp_prod | rp_seq, rp_prod_seq | wms_inven_rp_prod_TO_wms_inven_rp_tran |
| wms_inven_st_prod | st_seq | wms_inven_st | st_seq | wms_inven_st_TO_wms_inven_st_prod |
| wms_inven_st_prod | mdm_st_prod_seq | mdm_st_prod | st_prod_seq | mdm_st_prod_TO_wms_inven_st_prod |
| wms_inven_st_tran | st_seq, st_prod_seq | wms_inven_st_prod | st_seq, st_prod_seq | wms_inven_st_prod_TO_wms_inven_st_tran |

## 6. WMS 재고실사 테이블 외래키 (wms_st_*)

| 외래키 테이블 | 외래키 컬럼 | 참조 테이블 | 참조 컬럼 | 제약조건명 |
|--------------|------------|------------|----------|-----------|
| wms_st_inven | st_sch_seq | wms_st_sch | st_sch_seq | wms_st_sch_TO_wms_st_inven |
| wms_st_target | st_sch_seq | wms_st_sch | st_sch_seq | wms_st_sch_TO_wms_st_target |
| wms_st_tran | st_sch_seq | wms_st_sch | st_sch_seq | wms_st_sch_TO_wms_st_tran |

## 7. WMS 반품 테이블 외래키 (wms_return_*)

| 외래키 테이블 | 외래키 컬럼 | 참조 테이블 | 참조 컬럼 | 제약조건명 |
|--------------|------------|------------|----------|-----------|
| wms_return_prod | return_seq | wms_return | return_seq | wms_return_TO_wms_return_prod |
| wms_return_tran | return_seq, return_prod_seq | wms_return_prod | return_seq, return_prod_seq | wms_return_prod_TO_wms_return_tran |

## 8. WMS 송장/상차 테이블 외래키 (wms_invoice_*, wms_load_*)

| 외래키 테이블 | 외래키 컬럼 | 참조 테이블 | 참조 컬럼 | 제약조건명 |
|--------------|------------|------------|----------|-----------|
| wms_invoice_prod | invoice_seq | wms_invoice | invoice_seq | wms_invoice_TO_wms_invoice_prod |
| wms_invoice_tran | outbiz_tran_seq | wms_outbiz_tran | outbiz_tran_seq | wms_outbiz_tran_TO_wms_invoice_tran |
| wms_invoice_tran | invoice_seq, invoice_prod_seq | wms_invoice_prod | invoice_seq, invoice_prod_seq | wms_invoice_prod_TO_wms_invoice_tran |
| wms_invoice_tran | prod_seq | mdm_prod | prod_seq | mdm_prod_TO_wms_invoice_tran |
| wms_invoice_tran | fr_wh_seq | mdm_wh | wh_seq | mdm_wh_TO_wms_invoice_tran |
| wms_invoice_tran | fr_loc_seq | mdm_loc | loc_seq | mdm_loc_TO_wms_invoice_tran |
| wms_load | car_seq | mdm_car | car_seq | mdm_car_TO_wms_load |
| wms_load_prod | load_seq | wms_load | load_seq | wms_load_TO_wms_load_prod |
| wms_load_tran | load_seq, load_prod_seq | wms_load_prod | load_seq, load_prod_seq | wms_load_prod_TO_wms_load_tran |
| wms_load_tran | outbiz_tran_seq | wms_outbiz_tran | outbiz_tran_seq | wms_outbiz_tran_TO_wms_load_tran |
| wms_load_tran | prod_seq | mdm_prod | prod_seq | mdm_prod_TO_wms_load_tran |
| wms_load_tran | fr_wh_seq | mdm_wh | wh_seq | mdm_wh_TO_wms_load_tran |
| wms_load_tran | fr_loc_seq | mdm_loc | loc_seq | mdm_loc_TO_wms_load_tran |

## 9. 첨부: 실행한 SQL

```sql
-- 복합 FK를 1행으로 집계 (카테시안 곱 방지)
SELECT
    c.conrelid::regclass::text                                          AS fk_table,
    string_agg(a.attname, ', ' ORDER BY u.ord)                         AS fk_columns,
    c.confrelid::regclass::text                                         AS ref_table,
    string_agg(af.attname, ', ' ORDER BY u.ord)                        AS ref_columns,
    c.conname                                                           AS constraint_name
FROM pg_constraint c
CROSS JOIN LATERAL UNNEST(c.conkey, c.confkey) WITH ORDINALITY AS u(fk_attnum, ref_attnum, ord)
JOIN pg_attribute a  ON a.attrelid = c.conrelid  AND a.attnum = u.fk_attnum
JOIN pg_attribute af ON af.attrelid = c.confrelid AND af.attnum = u.ref_attnum
WHERE c.contype = 'f'
  AND c.conrelid::regclass::text NOT LIKE 'pg_%'
GROUP BY c.conrelid, c.confrelid, c.conname
ORDER BY fk_table, constraint_name;
```
