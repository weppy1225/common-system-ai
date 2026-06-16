-- ============================================================
-- Database  : wms-cloud-test
-- Schema    : public
-- Generated : 2026-05-11 10:08:46
-- ============================================================

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

-- ============================================================
-- 1. SEQUENCES
-- ============================================================

CREATE SEQUENCE IF NOT EXISTS mdm_biz_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 2
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS mdm_car_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS mdm_center_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 2
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS mdm_cont_prod_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS mdm_cont_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS mdm_freegift_gift_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS mdm_freegift_promo_no
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS mdm_freegift_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS mdm_freegift_target_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS mdm_label_paper_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 25
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS mdm_loc_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 13
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS mdm_prod_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS mdm_rp_prod_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS mdm_st_config_dtl_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS mdm_st_config_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS mdm_st_prod_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS mdm_wh_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 13
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS proc_bundle_no
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS sif_batch_history_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS sm_alarm_history_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS sm_biz_config_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 4
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS sm_board_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS sm_dlv_config_applied_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS sm_dlv_config_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS sm_file_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS sm_group_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 2
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS sm_log_api_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS sm_log_conn_dtl_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS sm_log_conn_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS sm_log_error_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS sm_push_cycle_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS sm_push_history_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS sm_qrtz_change_log_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS sm_qrtz_exec_log_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS sm_user_pwd_history_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS wes_proc_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS wms_inbiz_prod_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS wms_inbiz_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS wms_inven_ad_prod_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS wms_inven_ad_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS wms_inven_ad_tran_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS wms_inven_etc_prod_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS wms_inven_etc_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS wms_inven_etc_tran_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS wms_inven_holding_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS wms_inven_inout_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS wms_inven_month_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS wms_inven_mv_prod_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS wms_inven_mv_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS wms_inven_mv_tran_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS wms_inven_rp_prod_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS wms_inven_rp_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS wms_inven_rp_tran_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS wms_inven_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS wms_inven_st_prod_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS wms_inven_st_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS wms_inven_st_tran_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS wms_invoice_prod_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS wms_invoice_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS wms_invoice_tran_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS wms_inwh_label_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS wms_inwh_prod_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS wms_inwh_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS wms_inwh_tran_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS wms_load_prod_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS wms_load_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS wms_load_tran_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS wms_outbiz_label_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS wms_outbiz_prod_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS wms_outbiz_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS wms_outbiz_tran_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS wms_outwh_assign_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS wms_outwh_prod_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS wms_outwh_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS wms_outwh_tran_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS wms_return_prod_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS wms_return_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS wms_return_tran_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS wms_st_inven_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS wms_st_sch_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS wms_st_target_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS wms_st_tran_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NO CYCLE;


-- ============================================================
-- 2. TABLES
-- ============================================================

CREATE TABLE flyway_schema_history (
    installed_rank integer NOT NULL,
    version character varying(50),
    description character varying(200) NOT NULL,
    type character varying(20) NOT NULL,
    script character varying(1000) NOT NULL,
    checksum integer,
    installed_by character varying(100) NOT NULL,
    installed_on timestamp without time zone DEFAULT now() NOT NULL,
    execution_time integer NOT NULL,
    success boolean NOT NULL
);

CREATE TABLE mdm_biz (
    biz_seq integer DEFAULT nextval('mdm_biz_seq'::regclass) NOT NULL,
    biz_nm character varying(100) NOT NULL,
    biz_nm_short character varying(100),
    ceo_nm character varying(100),
    biz_no character varying(20),
    sub_biz_no character(4),
    biz_type character varying(100),
    biz_item character varying(100),
    biz_div_cd character varying(50) DEFAULT 'OWN'::character varying NOT NULL,
    contract_ymd character varying(8),
    hq_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    email character varying(100),
    tel character varying(500),
    fax character varying(500),
    post_no character varying(10),
    addr character varying(200),
    addr_dtl character varying(200),
    stamp_file_seq integer,
    logo_file_seq integer,
    if_biz_id character varying(50),
    biz_color character varying(50) DEFAULT '#00afec'::character varying,
    note character varying(1000),
    use_yn character(1) DEFAULT 'Y'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE mdm_biz_biz (
    biz_seq integer NOT NULL,
    ref_biz_seq integer NOT NULL,
    use_yn character(1) DEFAULT 'Y'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE mdm_biz_center (
    biz_seq integer NOT NULL,
    center_seq integer NOT NULL,
    reg_biz_seq integer NOT NULL,
    note character varying(1000),
    cfm_yn character(1) DEFAULT 'Y'::bpchar NOT NULL,
    use_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE mdm_biz_cont (
    biz_seq integer NOT NULL,
    cont_seq integer NOT NULL,
    use_yn character(1) DEFAULT 'Y'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE mdm_biz_prod (
    biz_seq integer NOT NULL,
    prod_seq integer NOT NULL,
    use_yn character(1) DEFAULT 'Y'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE mdm_biz_wh (
    biz_seq integer NOT NULL,
    wh_seq integer NOT NULL,
    if_wh_id character varying(50),
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE mdm_car (
    car_seq integer DEFAULT nextval('mdm_car_seq'::regclass) NOT NULL,
    biz_seq integer NOT NULL,
    car_no character varying(100) NOT NULL,
    car_div_cd character varying(50) DEFAULT 'DIRECT'::character varying NOT NULL,
    car_type_cd character varying(50) DEFAULT 'BOX'::character varying NOT NULL,
    driver_nm character varying(100),
    driver_tel character varying(500),
    cfd_cd character varying(50) DEFAULT 'D'::character varying NOT NULL,
    cbm numeric(10,2) DEFAULT 0,
    length numeric(10,2) DEFAULT 0,
    width numeric(10,2) DEFAULT 0,
    height numeric(10,2) DEFAULT 0,
    wgt numeric(10,2) DEFAULT 0,
    self_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    use_yn character(1) DEFAULT 'Y'::bpchar NOT NULL,
    note character varying(1000),
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE mdm_center (
    center_seq integer DEFAULT nextval('mdm_center_seq'::regclass) NOT NULL,
    center_nm character varying(100) NOT NULL,
    tel character varying(100),
    email character varying(100),
    post_no character varying(10),
    addr character varying(200),
    addr_dtl character varying(200),
    center_file_seq integer,
    tpl_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    note character varying(1000),
    use_yn character(1) DEFAULT 'Y'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE mdm_cont (
    cont_seq integer DEFAULT nextval('mdm_cont_seq'::regclass) NOT NULL,
    if_cont_id character varying(50),
    cont_no character varying(30) NOT NULL,
    cont_nm character varying(100) NOT NULL,
    cont_nm_short character varying(100),
    cont_div_cd character varying(50) DEFAULT '3'::character varying,
    ceo_nm character varying(100),
    biz_no character varying(20),
    sub_biz_no character(4),
    cont_type character varying(100),
    cont_item character varying(100),
    email character varying(100),
    tel character varying(500),
    fax character varying(500),
    post_no character varying(10),
    addr character varying(200),
    addr_dtl character varying(200),
    manager_nm character varying(100),
    rep_cont_seq integer,
    label_paper_seq integer,
    barcode_type_cd1 character varying(50) DEFAULT '16'::character varying NOT NULL,
    barcode_type_cd2 character varying(50) DEFAULT '32'::character varying NOT NULL,
    note character varying(1000),
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE mdm_cont_prod (
    cont_prod_seq integer DEFAULT nextval('mdm_cont_prod_seq'::regclass) NOT NULL,
    biz_seq integer NOT NULL,
    cont_seq integer NOT NULL,
    prod_seq integer NOT NULL,
    label_prod_nm character varying(100) NOT NULL,
    disp_prod_barcode character varying(100),
    cont_prod_code character varying(100),
    in_qty smallint DEFAULT 1 NOT NULL,
    exp_date_disp_yn character(1) DEFAULT 'Y'::bpchar NOT NULL,
    print_cnt smallint DEFAULT 1 NOT NULL,
    note character varying(1000),
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE mdm_doc_no (
    biz_seq integer NOT NULL,
    inout_type_cd character varying(50) NOT NULL,
    base_ymd character varying(8) NOT NULL,
    next_seq integer DEFAULT 1 NOT NULL
);

CREATE TABLE mdm_label_paper (
    label_paper_seq integer DEFAULT nextval('mdm_label_paper_seq'::regclass) NOT NULL,
    label_paper_nm character varying(100) NOT NULL,
    label_paper_div_cd character varying(50) NOT NULL,
    label_paper_type_cd character varying(50) NOT NULL,
    barcode_dim_cd character varying(50),
    manufacturer_nm character varying(100),
    product_code character varying(100),
    product_nm character varying(100),
    paper_type character varying(100),
    name_tag_cnt character varying(100),
    name_tag_size character varying(100),
    file_seq integer NOT NULL,
    def_label_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    note character varying(1000),
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE mdm_loc (
    loc_seq bigint DEFAULT nextval('mdm_loc_seq'::regclass) NOT NULL,
    wh_seq integer NOT NULL,
    rack_no character varying(100) DEFAULT '-'::character varying NOT NULL,
    row_no character varying(100),
    column_no character varying(100),
    loc_nm character varying(100) NOT NULL,
    loc_barcode character varying(100),
    def_loc_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    loc_mng_nm character varying(100),
    use_yn character(1) DEFAULT 'Y'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE mdm_prod (
    prod_seq integer DEFAULT nextval('mdm_prod_seq'::regclass) NOT NULL,
    if_prod_id character varying(50),
    prod_no character varying(30) NOT NULL,
    prod_nm character varying(100) NOT NULL,
    prod_nm_short character varying(100),
    prod_size character varying(100),
    prod_div_cd character varying(50),
    large_cd character varying(50),
    middle_cd character varying(50),
    small_cd character varying(50),
    sku_mng_cd character varying(50) DEFAULT 'N'::character varying NOT NULL,
    mng_ymd_mng_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    eff_mng_yn character(1) DEFAULT 'Y'::bpchar NOT NULL,
    eff_base smallint DEFAULT 60,
    eff_base_unit_cd character varying(50) DEFAULT 'DAYS'::character varying,
    lot_no_mng_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    cn_mng_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    sku2_mng_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    unit_cd character varying(50) DEFAULT 'EA'::character varying NOT NULL,
    parent_unit_nm character varying(100),
    in_qty smallint DEFAULT 1 NOT NULL,
    imm_days smallint DEFAULT 90 NOT NULL,
    prod_barcode character varying(100),
    parent_barcode character varying(100),
    pallet_stack_qty smallint DEFAULT 1 NOT NULL,
    pallet_bottom_qty smallint DEFAULT 1 NOT NULL,
    file_seq integer,
    label_paper_seq integer,
    parent_label_paper_seq integer,
    qc_yn character(1) DEFAULT 'N'::bpchar,
    cfd_cd character varying(50) DEFAULT 'D'::character varying,
    hs_code character varying(50),
    abc_cd character varying(50) DEFAULT 'D'::character varying,
    net_weight numeric(10,2) DEFAULT 0,
    unit_pack_qty smallint DEFAULT 1,
    origin_cd character varying(50),
    inqty_pack smallint DEFAULT 0,
    brand_cd character varying(50),
    len_x numeric(10,2) DEFAULT 1,
    len_y numeric(10,2) DEFAULT 1,
    len_z numeric(10,2) DEFAULT 1,
    wes_if_send_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    wes_if_err_seq integer,
    note character varying(1000),
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone,
    barcode_type_cd character varying(50),
    parent_barcode_type_cd character varying(50)
);

CREATE TABLE mdm_rp_prod (
    rp_prod_seq integer DEFAULT nextval('mdm_rp_prod_seq'::regclass) NOT NULL,
    biz_seq integer NOT NULL,
    st_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    ref_rp_prod_seq integer,
    prod_seq integer,
    qty numeric(10,2) DEFAULT 1.00 NOT NULL,
    note character varying(1000) NOT NULL,
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE mdm_st_config (
    st_config_seq integer DEFAULT nextval('mdm_st_config_seq'::regclass) NOT NULL,
    biz_seq integer NOT NULL,
    st_prod_seq integer NOT NULL,
    note character varying(1000),
    use_yn character(1) DEFAULT 'Y'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE mdm_st_config_dtl (
    st_config_dtl_seq bigint DEFAULT nextval('mdm_st_config_dtl_seq'::regclass) NOT NULL,
    st_config_seq integer NOT NULL,
    prod_seq integer NOT NULL,
    config_qty numeric(10,2) DEFAULT 1.00 NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE mdm_st_prod (
    st_prod_seq integer DEFAULT nextval('mdm_st_prod_seq'::regclass) NOT NULL,
    biz_seq integer NOT NULL,
    st_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    ref_st_prod_seq integer,
    prod_seq integer NOT NULL,
    qty numeric(10,2) DEFAULT 1.00 NOT NULL,
    note character varying(1000),
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE mdm_user (
    user_id character varying(20) NOT NULL,
    if_emp_no character varying(50),
    password character varying(500) NOT NULL,
    user_nm character varying(100) NOT NULL,
    dvsn_nm character varying(100),
    email character varying(100),
    tel bytea,
    group_seq integer NOT NULL,
    reg_biz_seq integer NOT NULL,
    reg_center_seq integer,
    auth_type_cd character varying(50) NOT NULL,
    pwd_fail_cnt integer DEFAULT 0 NOT NULL,
    lock_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    pwd_upd_date timestamp without time zone DEFAULT now() NOT NULL,
    admin_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    disp_qty_cd character varying(50) DEFAULT 'ALL'::character varying NOT NULL,
    lpa_port character(5) DEFAULT '8888'::bpchar NOT NULL,
    auth_no character varying(50),
    auth_time timestamp without time zone,
    mobile_token character varying(1000),
    dormancy_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    last_login_dt timestamp without time zone DEFAULT now() NOT NULL,
    user_file_seq integer,
    use_yn character(1) DEFAULT 'Y'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_dt timestamp without time zone,
    mod_id character varying(20)
);

CREATE TABLE mdm_user_biz (
    biz_seq integer NOT NULL,
    user_id character varying(20) NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE mdm_user_center (
    center_seq integer NOT NULL,
    user_id character varying(20) NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE mdm_wh (
    wh_seq integer DEFAULT nextval('mdm_wh_seq'::regclass) NOT NULL,
    center_seq integer NOT NULL,
    wh_nm character varying(100) NOT NULL,
    wh_group_cd character varying(50) NOT NULL,
    in_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    return_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    pick_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    st_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    rp_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    out_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    etc_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    def_wh_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    available_inven_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    cfd_cd character varying(50) DEFAULT 'D'::character varying NOT NULL,
    use_yn character(1) DEFAULT 'Y'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE qrtz_blob_triggers (
    sched_name character varying(120) NOT NULL,
    trigger_name character varying(200) NOT NULL,
    trigger_group character varying(200) NOT NULL,
    blob_data bytea
);

CREATE TABLE qrtz_calendars (
    sched_name character varying(120) NOT NULL,
    calendar_name character varying(200) NOT NULL,
    calendar bytea NOT NULL
);

CREATE TABLE qrtz_cron_triggers (
    sched_name character varying(120) NOT NULL,
    trigger_name character varying(200) NOT NULL,
    trigger_group character varying(200) NOT NULL,
    cron_expression character varying(120) NOT NULL,
    time_zone_id character varying(80)
);

CREATE TABLE qrtz_fired_triggers (
    sched_name character varying(120) NOT NULL,
    entry_id character varying(95) NOT NULL,
    trigger_name character varying(200) NOT NULL,
    trigger_group character varying(200) NOT NULL,
    instance_name character varying(200) NOT NULL,
    fired_time bigint NOT NULL,
    sched_time bigint NOT NULL,
    priority integer NOT NULL,
    state character varying(16) NOT NULL,
    job_name character varying(200),
    job_group character varying(200),
    is_nonconcurrent boolean,
    requests_recovery boolean
);

CREATE TABLE qrtz_job_details (
    sched_name character varying(120) NOT NULL,
    job_name character varying(200) NOT NULL,
    job_group character varying(200) NOT NULL,
    description character varying(250),
    job_class_name character varying(250) NOT NULL,
    is_durable boolean NOT NULL,
    is_nonconcurrent boolean NOT NULL,
    is_update_data boolean NOT NULL,
    requests_recovery boolean NOT NULL,
    job_data bytea
);

CREATE TABLE qrtz_locks (
    sched_name character varying(120) NOT NULL,
    lock_name character varying(40) NOT NULL
);

CREATE TABLE qrtz_paused_trigger_grps (
    sched_name character varying(120) NOT NULL,
    trigger_group character varying(200) NOT NULL
);

CREATE TABLE qrtz_scheduler_state (
    sched_name character varying(120) NOT NULL,
    instance_name character varying(200) NOT NULL,
    last_checkin_time bigint NOT NULL,
    checkin_interval bigint NOT NULL
);

CREATE TABLE qrtz_simple_triggers (
    sched_name character varying(120) NOT NULL,
    trigger_name character varying(200) NOT NULL,
    trigger_group character varying(200) NOT NULL,
    repeat_count bigint NOT NULL,
    repeat_interval bigint NOT NULL,
    times_triggered bigint NOT NULL
);

CREATE TABLE qrtz_simprop_triggers (
    sched_name character varying(120) NOT NULL,
    trigger_name character varying(200) NOT NULL,
    trigger_group character varying(200) NOT NULL,
    str_prop_1 character varying(512),
    str_prop_2 character varying(512),
    str_prop_3 character varying(512),
    int_prop_1 integer,
    int_prop_2 integer,
    long_prop_1 bigint,
    long_prop_2 bigint,
    dec_prop_1 numeric(13,4),
    dec_prop_2 numeric(13,4),
    bool_prop_1 boolean,
    bool_prop_2 boolean
);

CREATE TABLE qrtz_triggers (
    sched_name character varying(120) NOT NULL,
    trigger_name character varying(200) NOT NULL,
    trigger_group character varying(200) NOT NULL,
    job_name character varying(200) NOT NULL,
    job_group character varying(200) NOT NULL,
    description character varying(250),
    next_fire_time bigint,
    prev_fire_time bigint,
    priority integer,
    trigger_state character varying(16) NOT NULL,
    trigger_type character varying(8) NOT NULL,
    start_time bigint NOT NULL,
    end_time bigint,
    calendar_name character varying(200),
    misfire_instr smallint,
    job_data bytea
);

CREATE TABLE sif_batch_history (
    if_seq integer DEFAULT nextval('sif_batch_history_seq'::regclass) NOT NULL,
    biz_seq integer,
    if_id character varying(50) NOT NULL,
    if_nm character varying(100) NOT NULL,
    if_system_cd character varying(50) DEFAULT 'WMS'::character varying NOT NULL,
    if_type_cd character varying(50) DEFAULT 'N'::character varying NOT NULL,
    if_status_cd character varying(50) NOT NULL,
    req_ymd character varying(8),
    req_hms character varying(6),
    req_json_data text,
    res_ymd character varying(8),
    res_hms character varying(6),
    res_json_data text,
    res_cnt integer DEFAULT 0,
    sif_cnt integer DEFAULT 0,
    wms_cnt integer DEFAULT 0,
    err_key text,
    err_msg text,
    end_ymd character varying(8),
    end_hms character varying(6),
    re_send_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone,
    org_if_seq integer
);

CREATE TABLE sm_alarm_history (
    alarm_history_seq bigint DEFAULT nextval('sm_alarm_history_seq'::regclass) NOT NULL,
    biz_seq integer NOT NULL,
    biz_nm character varying(100) NOT NULL,
    center_seq integer NOT NULL,
    center_nm character varying(100) NOT NULL,
    menu_cd character varying(50) NOT NULL,
    menu_nm character varying(100) NOT NULL,
    req_seq integer,
    req_no character varying(30) NOT NULL,
    alarm_message character varying(1000) NOT NULL,
    group_seq integer,
    proc_user_id character varying(20) NOT NULL,
    proc_user_nm character varying(100) NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL
);

CREATE TABLE sm_alarm_unrcv (
    user_id character varying(20) NOT NULL,
    menu_cd character varying(50) NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL
);

CREATE TABLE sm_api_config (
    biz_seq integer NOT NULL,
    if_id character varying(50) NOT NULL,
    if_nm character varying(100) NOT NULL,
    api_url character varying(512) NOT NULL,
    api_method_cd character varying(50) NOT NULL,
    if_type_cd character varying(50) DEFAULT 'N'::character varying NOT NULL,
    if_proc_type_cd character varying(50) DEFAULT 'N'::character varying NOT NULL,
    req_json_data text,
    use_yn character(1) DEFAULT 'Y'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE sm_biz_config (
    biz_seq integer NOT NULL,
    mail_host character varying(512),
    mail_port character(5),
    mail_user character varying(20),
    mail_pass bytea,
    mail_sender character varying(20),
    system_lock_cnt smallint DEFAULT 5 NOT NULL,
    system_dormancy_cycle smallint DEFAULT 30 NOT NULL,
    system_pwd_cycle smallint DEFAULT 90 NOT NULL,
    pwd_caps character(1) DEFAULT 'N'::bpchar NOT NULL,
    pwd_small character(1) DEFAULT 'N'::bpchar NOT NULL,
    pwd_num character(1) DEFAULT 'Y'::bpchar NOT NULL,
    pwd_special character(1) DEFAULT 'N'::bpchar NOT NULL,
    pwd_min_len smallint DEFAULT 4 NOT NULL,
    pwd_init character varying(20) DEFAULT '1111'::character varying NOT NULL,
    pwd_reuse_lmt smallint DEFAULT 3 NOT NULL,
    api_key character varying(500),
    api_key_exp_ymd character varying(8),
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone,
    session_timeout_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    session_timeout_minutes smallint DEFAULT 0
);

CREATE TABLE sm_board (
    board_seq bigint DEFAULT nextval('sm_board_seq'::regclass) NOT NULL,
    board_type_cd character varying(50) NOT NULL,
    board_cat_cd character varying(50),
    board_cat_dtl_cd character varying(50),
    title character varying(100),
    contents text,
    board_yn character(1) DEFAULT 'N'::bpchar,
    top_board_seq bigint,
    reply_cnt integer DEFAULT 0,
    view_cnt integer DEFAULT 0,
    file_seq integer,
    disp_no smallint DEFAULT 1 NOT NULL,
    board_pwd character varying(500),
    disp_yn character(1) DEFAULT 'N'::bpchar,
    start_ymd character varying(8),
    end_ymd character varying(8),
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE sm_comm_d (
    biz_seq integer NOT NULL,
    comm_h_cd character varying(50) NOT NULL,
    comm_d_cd character varying(50) NOT NULL,
    comm_d_nm character varying(100) NOT NULL,
    ref_h_cd character varying(50),
    ref_d_cd character varying(50),
    disp_no smallint DEFAULT 1 NOT NULL,
    disp_yn character(1) DEFAULT 'Y'::bpchar NOT NULL,
    fr_val character varying(100),
    to_val character varying(100),
    note1 character varying(100),
    note2 character varying(100),
    note3 character varying(100),
    use_yn character(1) DEFAULT 'Y'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE sm_comm_h (
    biz_seq integer NOT NULL,
    comm_h_cd character varying(50) NOT NULL,
    comm_h_nm character varying(100) NOT NULL,
    user_cd_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    user_edit_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    use_yn character(1) DEFAULT 'Y'::bpchar NOT NULL,
    inout_cd character varying(50),
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE sm_dlv_config (
    dlv_config_seq integer DEFAULT nextval('sm_dlv_config_seq'::regclass) NOT NULL,
    center_seq integer NOT NULL,
    contract_biz_seq integer NOT NULL,
    dlv_co_cd character varying(50) NOT NULL,
    use_yn character(1) DEFAULT 'Y'::bpchar NOT NULL,
    cust_id character varying(20),
    biz_no character varying(20),
    invoice_assign_type_cd character varying(50) DEFAULT 'MANUAL'::character varying NOT NULL,
    token_num character varying(50),
    token_exprtn_dtm character varying(14),
    invoice_no_start character varying(30),
    invoice_no_end character varying(30),
    invoice_no_current character varying(30),
    invoice_no_add character varying(30),
    box_type_cd character varying(50),
    frt_dv_cd character varying(50),
    frt character varying(50),
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE sm_dlv_config_applied (
    dlv_config_applied_seq integer DEFAULT nextval('sm_dlv_config_applied_seq'::regclass) NOT NULL,
    dlv_config_seq integer NOT NULL,
    center_seq integer NOT NULL,
    biz_seq integer NOT NULL,
    disp_no smallint DEFAULT 0 NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE sm_file (
    file_seq integer DEFAULT nextval('sm_file_seq'::regclass) NOT NULL,
    biz_seq integer NOT NULL,
    file_div_cd character varying(50),
    file_uuid character varying(300) NOT NULL,
    file_nm character varying(100),
    file_path character varying(512),
    disp_no smallint DEFAULT 0 NOT NULL,
    file_size integer,
    file_extension character varying(100),
    use_yn character(1) DEFAULT 'Y'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE sm_file_req (
    file_seq integer NOT NULL,
    req_type_cd character varying(50) NOT NULL,
    req_seq integer NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE sm_group (
    group_seq integer DEFAULT nextval('sm_group_seq'::regclass) NOT NULL,
    biz_seq integer NOT NULL,
    group_nm character varying(100) NOT NULL,
    use_yn character(1) DEFAULT 'Y'::bpchar NOT NULL,
    biz_admin_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE sm_log_api (
    log_api_seq bigint DEFAULT nextval('sm_log_api_seq'::regclass) NOT NULL,
    biz_seq integer NOT NULL,
    user_id character varying(20) NOT NULL,
    methods character varying(50) NOT NULL,
    menu_url character varying(512) NOT NULL,
    req_dt timestamp without time zone DEFAULT now() NOT NULL,
    request_body text,
    query_param text,
    path_param text,
    res_dt timestamp without time zone DEFAULT now(),
    response_body text
);

CREATE TABLE sm_log_conn (
    log_conn_seq bigint DEFAULT nextval('sm_log_conn_seq'::regclass) NOT NULL,
    user_id character varying(20) NOT NULL,
    conn_dt timestamp without time zone NOT NULL,
    conn_type_cd character varying(50) NOT NULL,
    ip_addr character varying(40) NOT NULL,
    user_agent character varying(200) NOT NULL,
    device_type character varying(100) NOT NULL,
    os_type character varying(100) NOT NULL,
    browser_type character varying(100) NOT NULL,
    proc_user_id character varying(20)
);

CREATE TABLE sm_log_conn_dtl (
    log_conn_seq bigint NOT NULL,
    log_conn_dtl_text text
);

CREATE TABLE sm_log_error (
    log_error_seq bigint DEFAULT nextval('sm_log_conn_dtl_seq'::regclass) NOT NULL,
    biz_seq integer NOT NULL,
    user_id character varying(20) NOT NULL,
    req_url character varying(512) NOT NULL,
    req_dt timestamp without time zone DEFAULT now() NOT NULL,
    err_type character varying(100),
    err_title character varying(100),
    err_text text,
    ex_nm character varying(100),
    sts_cd character varying(50),
    sts_nm character varying(100)
);

CREATE TABLE sm_log_menu (
    biz_seq integer NOT NULL,
    yyyymmdd character varying(8) NOT NULL,
    menu_cd character varying(50) NOT NULL,
    view_cnt smallint DEFAULT 0 NOT NULL,
    yyyy character varying(4) NOT NULL,
    mm character(2) NOT NULL,
    dd character(2) NOT NULL
);

CREATE TABLE sm_menu (
    menu_cd character varying(50) NOT NULL,
    menu_nm character varying(100) NOT NULL,
    h_menu_cd character varying(50) NOT NULL,
    menu_idx smallint DEFAULT 0 NOT NULL,
    menu_type_cd character varying(50) NOT NULL,
    menu_url character varying(512),
    ui_type_cd character varying(50),
    alarm_use_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    proc_ymd_chng_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    sch_ymd_set_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    menu_icon character varying(512),
    pda_disp_no smallint DEFAULT 0,
    login_acc_yn character(1) DEFAULT 'Y'::bpchar,
    login_disp_yn character(1) DEFAULT 'Y'::bpchar,
    def_menu_yn character(1) DEFAULT 'Y'::bpchar NOT NULL,
    use_yn character(1) DEFAULT 'Y'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE sm_menu_group (
    menu_cd character varying(50) NOT NULL,
    group_seq integer NOT NULL,
    ui_type_cd character varying(50) NOT NULL,
    read_auth_yn character(1) DEFAULT 'Y'::bpchar NOT NULL,
    create_auth_yn character(1) DEFAULT 'Y'::bpchar NOT NULL,
    alarm_auth_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE sm_menu_opt_config (
    biz_seq integer NOT NULL,
    menu_cd character varying(50) NOT NULL,
    search_start_ymd smallint DEFAULT 0 NOT NULL,
    search_end_ymd smallint DEFAULT 0 NOT NULL,
    proc_ymd_edit_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE sm_ob_proc_opt_config (
    biz_seq integer NOT NULL,
    outbiz_type_cd character varying(50) NOT NULL,
    outbiz_proc_type_cd character varying(50) DEFAULT 'N'::character varying NOT NULL,
    outbiz_auto_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    outwh_proc_yn character(1) DEFAULT 'Y'::bpchar NOT NULL,
    if_device_cd character varying(50) DEFAULT '-'::character varying NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE sm_opt_config (
    biz_seq integer NOT NULL,
    outbiz_inven_check_yn character(1) DEFAULT 'Y'::bpchar NOT NULL,
    outbiz_label_yn character(1) DEFAULT 'Y'::bpchar NOT NULL,
    outwh_div_cd character varying(50) DEFAULT '-'::character varying NOT NULL,
    strng_asgn_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    def_barcode_type1 character varying(50) NOT NULL,
    def_barcode_type2 character varying(50) NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE sm_prod_opt_config (
    biz_seq integer NOT NULL,
    prod_div_cd character varying(50) NOT NULL,
    prod_sku_mng_cd character varying(50) DEFAULT 'N'::character varying NOT NULL,
    prod_mng_ymd_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    prod_eff_mng_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    prod_lot_no_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    prod_cn_mng_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    prod_sku2_mng_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    label_paper_seq integer NOT NULL,
    parent_label_paper_seq integer,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE sm_push_cycle (
    push_cycle_seq integer DEFAULT nextval('sm_push_cycle_seq'::regclass) NOT NULL,
    biz_seq integer NOT NULL,
    center_seq_str character varying(1000),
    group_seq_str character varying(1000),
    push_type_cd character varying(50) NOT NULL,
    push_cycle_cd character varying(50) NOT NULL,
    push_note character varying(1000) NOT NULL,
    mon character(1) DEFAULT 'N'::bpchar,
    tue character(1) DEFAULT 'N'::bpchar,
    wed character(1) DEFAULT 'N'::bpchar,
    thu character(1) DEFAULT 'N'::bpchar,
    fri character(1) DEFAULT 'N'::bpchar,
    sat character(1) DEFAULT 'N'::bpchar,
    sun character(1) DEFAULT 'N'::bpchar,
    push_cycle_dd character(2),
    push_start_ymd character varying(8),
    push_end_ymd character varying(8),
    push_send_hms1 character varying(6),
    push_send_hms2 character varying(6),
    use_yn character(1) DEFAULT 'Y'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE sm_push_history (
    push_history_seq bigint DEFAULT nextval('sm_push_history_seq'::regclass) NOT NULL,
    push_cycle_seq integer,
    biz_seq integer NOT NULL,
    center_seq integer NOT NULL,
    group_seq integer NOT NULL,
    push_type_cd character varying(50) NOT NULL,
    push_message character varying(1000) NOT NULL,
    send_dt timestamp without time zone NOT NULL,
    prod_seq integer,
    req_no character varying(30),
    cfm_dt timestamp without time zone,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE sm_push_unrcv (
    user_id character varying(20) NOT NULL,
    push_type_cd character varying(50) NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL
);

CREATE TABLE sm_qrtz_change_log (
    qrtz_change_log_seq bigint DEFAULT nextval('sm_qrtz_change_log_seq'::regclass) NOT NULL,
    job_nm character varying(100),
    job_cls_nm character varying(100),
    job_data text,
    description character varying(1000),
    qrtz_type_cd character varying(100),
    cron character varying(100),
    trigger_nm character varying(100),
    proc_ymd character varying(8),
    proc_hms character varying(6),
    proc_user_id character varying(20)
);

CREATE TABLE sm_qrtz_exec_log (
    qrtz_exec_log_seq bigint DEFAULT nextval('sm_qrtz_exec_log_seq'::regclass) NOT NULL,
    instance_id character varying(100),
    qrtz_status_cd character varying(100),
    err_msg text,
    job_nm character varying(100),
    job_cls_nm character varying(100),
    job_data text,
    description character varying(1000),
    cron character varying(100),
    trigger_nm character varying(100),
    start_ymd character varying(8),
    start_hms character varying(6),
    end_ymd character varying(8),
    end_hms character varying(6)
);

CREATE TABLE sm_qrtz_job_state (
    job_cls_nm character varying(100) NOT NULL,
    job_nm character varying(100),
    job_status_cd character varying(100),
    proc_ymd character varying(8),
    proc_hms character varying(6)
);

CREATE TABLE sm_user_pwd_history (
    user_pwd_history_seq integer DEFAULT nextval('sm_user_pwd_history_seq'::regclass) NOT NULL,
    user_id character varying(20) NOT NULL,
    password character varying(500) NOT NULL,
    pwd_upd_date timestamp without time zone NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE wes_process_history (
    wes_proc_seq integer DEFAULT nextval('wes_proc_seq'::regclass) NOT NULL,
    biz_seq integer NOT NULL,
    if_seq integer,
    wes_proc_no integer DEFAULT 0 NOT NULL,
    invoice_seq integer NOT NULL,
    parent_invoice_seq integer,
    invoice_no character varying(30),
    add_invoice_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    proc_ymd character varying(8),
    proc_hms character varying(6),
    proc_user_id character varying(20),
    invoice_prod_seq bigint,
    prod_seq integer NOT NULL,
    proc_qty numeric(10,2) DEFAULT 0 NOT NULL,
    proc_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    err_msg text,
    wms_proc_ymd character varying(8),
    wms_proc_hms character varying(6)
);

CREATE TABLE wms_inbiz (
    inbiz_seq integer DEFAULT nextval('wms_inbiz_seq'::regclass) NOT NULL,
    biz_seq integer NOT NULL,
    inbiz_no character varying(30) NOT NULL,
    center_seq integer NOT NULL,
    inbiz_type_cd character varying(50) NOT NULL,
    inbiz_sts_cd character varying(50),
    po_no character varying(100) NOT NULL,
    po_ymd character varying(8),
    po_user_nm character varying(100),
    bl_no character varying(100),
    cc_no character varying(100),
    req_ymd character varying(8) NOT NULL,
    req_hms character varying(6),
    req_user_nm character varying(100),
    cont_seq integer,
    cfm_ymd character varying(8),
    cfm_hms character varying(6),
    cfm_user_id character varying(20),
    note character varying(1000),
    req_no character varying(30),
    erp_wh_cd character varying(50),
    if_key character varying(50),
    if_err_seq integer,
    if_send_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE wms_inbiz_inwh (
    inbiz_seq integer,
    inbiz_prod_seq bigint,
    inwh_seq integer,
    inwh_prod_seq bigint,
    req_qty numeric(10,2) DEFAULT 0,
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE wms_inbiz_prod (
    inbiz_prod_seq bigint DEFAULT nextval('wms_inbiz_prod_seq'::regclass) NOT NULL,
    inbiz_seq integer NOT NULL,
    prod_seq integer NOT NULL,
    inbiz_prod_sts_cd character varying(50) NOT NULL,
    req_qty numeric(10,2) DEFAULT 0 NOT NULL,
    ex_qty numeric(10,2) DEFAULT 0 NOT NULL,
    lot_no character varying(30),
    if_send_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    if_idx character varying(20),
    if_err_seq integer,
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE wms_inven (
    biz_seq integer NOT NULL,
    center_seq integer NOT NULL,
    prod_seq integer NOT NULL,
    sku1 character varying(100) NOT NULL,
    sku2 character varying(100) NOT NULL,
    wh_seq integer NOT NULL,
    loc_seq bigint NOT NULL,
    inven_qty numeric(10,2) DEFAULT 0 NOT NULL,
    wt_qty numeric(10,2) DEFAULT 0 NOT NULL,
    qc_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE wms_inven_ad (
    ad_seq integer DEFAULT nextval('wms_inven_ad_seq'::regclass) NOT NULL,
    biz_seq integer NOT NULL,
    ad_no character varying(30) NOT NULL,
    center_seq integer NOT NULL,
    ad_type_cd character varying(50) NOT NULL,
    ad_sts_cd character varying(50) NOT NULL,
    req_ymd character varying(8) NOT NULL,
    req_hms character varying(6),
    req_user_nm character varying(100),
    req_dept_nm character varying(100),
    req_no character varying(30),
    st_seq integer,
    note character varying(1000),
    if_send_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    if_key character varying(50),
    if_err_seq integer,
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE wms_inven_ad_prod (
    ad_prod_seq bigint DEFAULT nextval('wms_inven_ad_prod_seq'::regclass) NOT NULL,
    ad_seq integer NOT NULL,
    prod_seq integer NOT NULL,
    ad_prod_sts_cd character varying(50) NOT NULL,
    req_qty numeric(10,2) DEFAULT 0 NOT NULL,
    ex_qty numeric(10,2) DEFAULT 0 NOT NULL,
    new_inven_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    est_wh_seq integer,
    est_mng_ymd character varying(8),
    est_exp_ymd character varying(8),
    est_lot_no character varying(30),
    if_err_seq integer,
    if_idx character varying(20),
    if_send_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE wms_inven_ad_tran (
    ad_tran_seq bigint DEFAULT nextval('wms_inven_ad_tran_seq'::regclass) NOT NULL,
    ad_prod_seq bigint NOT NULL,
    ad_seq integer NOT NULL,
    prod_seq integer NOT NULL,
    wh_seq integer NOT NULL,
    loc_seq bigint NOT NULL,
    sku1 character varying(100) NOT NULL,
    sku2 character varying(100) NOT NULL,
    proc_qty numeric(10,2) DEFAULT 0 NOT NULL,
    ex_qty numeric(10,2) DEFAULT 0 NOT NULL,
    mng_ymd character varying(8),
    exp_ymd character varying(8),
    lot_no character varying(30),
    cn integer,
    proc_bundle_no character varying(30),
    proc_ymd character varying(8),
    proc_hms character varying(6),
    proc_user_id character varying(20),
    if_err_seq integer,
    if_send_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE wms_inven_etc (
    etc_seq integer DEFAULT nextval('wms_inven_etc_seq'::regclass) NOT NULL,
    biz_seq integer NOT NULL,
    etc_no character varying(30) NOT NULL,
    center_seq integer NOT NULL,
    etc_type_cd character varying(50) NOT NULL,
    etc_sts_cd character varying(50) NOT NULL,
    req_ymd character varying(8) NOT NULL,
    req_hms character varying(6),
    req_user_nm character varying(100),
    req_dept_nm character varying(100),
    req_no character varying(30),
    erp_wh_cd character varying(50),
    note character varying(1000),
    if_send_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    if_key character varying(50),
    if_err_seq integer,
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE wms_inven_etc_prod (
    etc_prod_seq bigint DEFAULT nextval('wms_inven_etc_prod_seq'::regclass) NOT NULL,
    etc_seq integer NOT NULL,
    prod_seq integer NOT NULL,
    etc_prod_sts_cd character varying(50) NOT NULL,
    req_qty numeric(10,2) DEFAULT 0 NOT NULL,
    ex_qty numeric(10,2) DEFAULT 0 NOT NULL,
    est_exp_ymd character varying(8),
    est_mng_ymd character varying(8),
    est_lot_no character varying(30),
    if_idx character varying(20),
    if_send_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    if_err_seq integer,
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE wms_inven_etc_tran (
    etc_tran_seq bigint DEFAULT nextval('wms_inven_etc_tran_seq'::regclass) NOT NULL,
    etc_prod_seq bigint NOT NULL,
    etc_seq integer NOT NULL,
    prod_seq integer NOT NULL,
    wh_seq integer NOT NULL,
    loc_seq bigint NOT NULL,
    sku1 character varying(100) NOT NULL,
    sku2 character varying(100) NOT NULL,
    proc_qty numeric(10,2) DEFAULT 0 NOT NULL,
    ex_qty numeric(10,2) DEFAULT 0 NOT NULL,
    proc_bundle_no character varying(30),
    proc_ymd character varying(8),
    proc_hms character varying(6),
    proc_user_id character varying(20),
    lot_no character varying(30),
    if_send_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    if_err_seq integer,
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE wms_inven_holding (
    inven_holding_seq bigint DEFAULT nextval('wms_inven_holding_seq'::regclass) NOT NULL,
    biz_seq integer NOT NULL,
    center_seq integer NOT NULL,
    prod_seq integer NOT NULL,
    mng_ymd character varying(8),
    exp_ymd character varying(8),
    lot_no character varying(30),
    sku1 character varying(100),
    req_qty numeric(10,2) DEFAULT 0,
    proc_qty numeric(10,2) DEFAULT 0 NOT NULL,
    proc_ymd character varying(8),
    proc_hmsms character varying(9),
    proc_user_id character varying(20),
    proc_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    inout_type_cd character varying(50) NOT NULL,
    inout_dtl_cd character varying(50),
    req_seq integer,
    req_prod_seq bigint,
    req_no character varying(30)
);

CREATE TABLE wms_inven_inout (
    inven_inout_seq bigint DEFAULT nextval('wms_inven_inout_seq'::regclass) NOT NULL,
    biz_seq integer NOT NULL,
    prod_seq integer NOT NULL,
    proc_ymd character varying(8) NOT NULL,
    proc_hmsms character varying(9) NOT NULL,
    inout_type_cd character varying(50) NOT NULL,
    inout_dtl_cd character varying(50) NOT NULL,
    proc_qty numeric(10,2) DEFAULT 0 NOT NULL,
    proc_user_id character varying(20) NOT NULL,
    center_seq integer NOT NULL,
    fr_wh_seq integer,
    fr_loc_seq bigint,
    fr_sku1 character varying(100),
    fr_sku2 character varying(100),
    to_wh_seq integer,
    to_loc_seq bigint,
    to_sku1 character varying(100),
    to_sku2 character varying(100),
    fr_lot_no character varying(30),
    fr_mng_ymd character varying(8),
    fr_exp_ymd character varying(8),
    to_lot_no character varying(30),
    to_mng_ymd character varying(8),
    to_exp_ymd character varying(8),
    proc_bundle_no character varying(30),
    req_seq integer NOT NULL,
    req_no character varying(30) NOT NULL,
    proc_sts_cd character(1) DEFAULT 'Y'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE wms_inven_month (
    inven_month_seq bigint DEFAULT nextval('wms_inven_month_seq'::regclass) NOT NULL,
    biz_seq integer NOT NULL,
    center_seq integer DEFAULT nextval('mdm_center_seq'::regclass) NOT NULL,
    prod_seq integer NOT NULL,
    wh_seq integer NOT NULL,
    yyyymm character varying(6) NOT NULL,
    inven_qty numeric(10,2) DEFAULT 0 NOT NULL,
    inwh_qty numeric(10,2) DEFAULT 0 NOT NULL,
    outbiz_qty numeric(10,2) DEFAULT 0 NOT NULL,
    return_qty numeric(10,2) DEFAULT 0 NOT NULL,
    etc_qty numeric(10,2) DEFAULT 0 NOT NULL,
    mng_ymd character varying(8),
    exp_ymd character varying(8),
    lot_no character varying(30),
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE wms_inven_mv (
    mv_seq integer DEFAULT nextval('wms_inven_mv_seq'::regclass) NOT NULL,
    biz_seq integer NOT NULL,
    mv_no character varying(30) NOT NULL,
    center_seq integer NOT NULL,
    mv_type_cd character varying(50) NOT NULL,
    mv_sts_cd character varying(50) NOT NULL,
    req_ymd character varying(8) NOT NULL,
    req_hms character varying(6),
    req_user_nm character varying(100),
    req_dept_nm character varying(100),
    to_wh_seq integer,
    fr_wh_seq integer,
    req_no character varying(30),
    note character varying(1000),
    if_key character varying(50),
    if_err_seq integer,
    if_send_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE wms_inven_mv_prod (
    mv_prod_seq bigint DEFAULT nextval('wms_inven_mv_prod_seq'::regclass) NOT NULL,
    mv_seq integer NOT NULL,
    prod_seq integer NOT NULL,
    mv_prod_sts_cd character varying(50) NOT NULL,
    req_qty numeric(10,2) DEFAULT 0 NOT NULL,
    ex_qty numeric(10,2) DEFAULT 0 NOT NULL,
    est_mng_ymd character varying(8),
    est_exp_ymd character varying(8),
    est_lot_no character varying(30),
    est_cn character varying(1000),
    if_send_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    if_idx character varying(20),
    if_err_seq integer,
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE wms_inven_mv_tran (
    mv_tran_seq bigint DEFAULT nextval('wms_inven_mv_tran_seq'::regclass) NOT NULL,
    mv_prod_seq bigint NOT NULL,
    mv_seq integer NOT NULL,
    prod_seq integer NOT NULL,
    fr_wh_seq integer NOT NULL,
    fr_loc_seq bigint NOT NULL,
    fr_sku1 character varying(100) NOT NULL,
    fr_sku2 character varying(100) NOT NULL,
    proc_qty numeric(10,2) DEFAULT 0 NOT NULL,
    ex_qty numeric(10,2) DEFAULT 0 NOT NULL,
    to_wh_seq integer NOT NULL,
    to_loc_seq bigint NOT NULL,
    to_sku2 character varying(100),
    mng_ymd character varying(8),
    exp_ymd character varying(8),
    lot_no character varying(30),
    proc_bundle_no character varying(30),
    proc_ymd character varying(8),
    proc_hms character varying(6),
    proc_user_id character varying(20),
    if_err_seq integer,
    if_send_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE wms_inven_rp (
    rp_seq integer DEFAULT nextval('wms_inven_rp_seq'::regclass) NOT NULL,
    biz_seq integer NOT NULL,
    rp_no character varying(30) NOT NULL,
    center_seq integer NOT NULL,
    rp_type_cd character varying(50) NOT NULL,
    rp_sts_cd character varying(50) NOT NULL,
    req_ymd character varying(8) NOT NULL,
    req_hms character varying(6),
    req_user_nm character varying(100),
    req_dept_nm character varying(100),
    note character varying(1000),
    if_key character varying(50),
    if_err_seq integer,
    if_send_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE wms_inven_rp_prod (
    rp_prod_seq bigint DEFAULT nextval('wms_inven_rp_prod_seq'::regclass) NOT NULL,
    rp_seq integer NOT NULL,
    rp_prod_sts_cd character varying(50) NOT NULL,
    st_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    prod_seq integer NOT NULL,
    req_qty numeric(10,2) DEFAULT 0 NOT NULL,
    est_exp_ymd character varying(8),
    est_mng_ymd character varying(8),
    est_lot_no character varying(30),
    if_idx character varying(20),
    if_err_seq integer,
    if_send_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE wms_inven_rp_tran (
    rp_tran_seq bigint DEFAULT nextval('wms_inven_rp_tran_seq'::regclass) NOT NULL,
    rp_prod_seq bigint NOT NULL,
    rp_seq integer NOT NULL,
    st_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    prod_seq integer NOT NULL,
    wh_seq integer NOT NULL,
    loc_seq bigint NOT NULL,
    sku1 character varying(100) NOT NULL,
    sku2 character varying(100) NOT NULL,
    proc_qty numeric(10,2) DEFAULT 0 NOT NULL,
    lot_no character varying(30),
    proc_bundle_no character varying(30),
    proc_ymd character varying(8) NOT NULL,
    proc_hms character varying(6) NOT NULL,
    proc_user_id character varying(20) NOT NULL,
    if_send_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    if_err_seq integer,
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE wms_inven_sku (
    biz_seq integer NOT NULL,
    prod_seq integer NOT NULL,
    sku1 character varying(100) NOT NULL,
    sku2 character varying(100) NOT NULL,
    center_seq integer NOT NULL,
    sku1_seq integer,
    sku2_seq integer,
    load_qty numeric(10,2) DEFAULT 0 NOT NULL,
    create_ymd character varying(8) NOT NULL,
    create_hms character varying(6) NOT NULL,
    create_user_id character varying(20) NOT NULL,
    mng_ymd character varying(8),
    exp_ymd character varying(8),
    lot_no character varying(30),
    bl_no character varying(30),
    inout_type_cd character varying(50) NOT NULL,
    inout_dtl_cd character varying(50) NOT NULL,
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE wms_inven_st (
    st_seq integer DEFAULT nextval('wms_inven_st_seq'::regclass) NOT NULL,
    biz_seq integer NOT NULL,
    st_no character varying(30) NOT NULL,
    center_seq integer NOT NULL,
    wh_seq integer NOT NULL,
    assembly_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    st_type_cd character varying(50) NOT NULL,
    st_sts_cd character varying(50) NOT NULL,
    req_ymd character varying(8) NOT NULL,
    req_hms character varying(6),
    req_user_nm character varying(100),
    req_dept_nm character varying(100),
    req_no character varying(30),
    note character varying(1000),
    if_key character varying(50),
    if_err_seq integer,
    if_send_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE wms_inven_st_prod (
    st_prod_seq bigint DEFAULT nextval('wms_inven_st_prod_seq'::regclass) NOT NULL,
    st_seq integer NOT NULL,
    st_prod_sts_cd character varying(50) NOT NULL,
    mdm_st_prod_seq integer,
    prod_seq integer NOT NULL,
    req_qty numeric(10,2) DEFAULT 0 NOT NULL,
    est_exp_ymd character varying(8),
    est_mng_ymd character varying(8),
    est_lot_no character varying(30),
    mv_seq integer,
    if_idx character varying(20),
    if_err_seq integer,
    if_send_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE wms_inven_st_tran (
    st_tran_seq bigint DEFAULT nextval('wms_inven_st_tran_seq'::regclass) NOT NULL,
    st_prod_seq bigint NOT NULL,
    st_seq integer NOT NULL,
    prod_seq integer NOT NULL,
    wh_seq integer NOT NULL,
    loc_seq bigint NOT NULL,
    sku1 character varying(100) NOT NULL,
    sku2 character varying(100) NOT NULL,
    proc_qty numeric(10,2) DEFAULT 0 NOT NULL,
    disassy_qty numeric(10,2) DEFAULT 0 NOT NULL,
    proc_bundle_no character varying(30),
    proc_ymd character varying(8) NOT NULL,
    proc_hms character varying(6) NOT NULL,
    proc_user_id character varying(20) NOT NULL,
    if_send_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    if_err_seq integer,
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE wms_invoice (
    invoice_seq integer DEFAULT nextval('wms_invoice_seq'::regclass) NOT NULL,
    parent_invoice_seq integer,
    biz_seq integer NOT NULL,
    invoice_no character varying(30),
    invoice_sts_cd character varying(50) NOT NULL,
    rcpt_div_cd character varying(50) NOT NULL,
    invoice_pack_cd character varying(50) NOT NULL,
    proc_ymd character varying(8),
    proc_hms character varying(6),
    proc_user_id character varying(20),
    re_print_cnt smallint DEFAULT 0 NOT NULL,
    group_outwh_no character varying(30),
    note character varying(1000),
    if_send_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    if_err_seq integer,
    wes_if_err_seq integer,
    wes_if_send_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone,
    check_yn character(1) DEFAULT 'N'::bpchar NOT NULL
);

CREATE TABLE wms_invoice_prod (
    invoice_prod_seq bigint DEFAULT nextval('wms_invoice_prod_seq'::regclass) NOT NULL,
    invoice_seq integer NOT NULL,
    parent_invoice_prod_seq bigint,
    prod_seq integer NOT NULL,
    req_qty numeric(10,2) DEFAULT 0 NOT NULL,
    ex_qty numeric(10,2) DEFAULT 0 NOT NULL,
    invoice_prod_nm character varying(100),
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE wms_invoice_tran (
    invoice_tran_seq bigint DEFAULT nextval('wms_invoice_tran_seq'::regclass) NOT NULL,
    invoice_prod_seq bigint NOT NULL,
    invoice_seq integer NOT NULL,
    prod_seq integer NOT NULL,
    sku1 character varying(100) NOT NULL,
    sku2 character varying(100) NOT NULL,
    exp_ymd character varying(8),
    lot_no character varying(30),
    mng_ymd character varying(8),
    fr_wh_seq integer,
    fr_loc_seq bigint,
    proc_qty numeric(10,2) DEFAULT 0 NOT NULL,
    ex_qty numeric(10,2) DEFAULT 0 NOT NULL,
    to_wh_seq integer,
    to_loc_seq bigint,
    proc_bundle_no character varying(30),
    proc_ymd character varying(8),
    proc_hms character varying(6),
    proc_user_id character varying(20),
    outbiz_tran_seq bigint,
    if_err_seq integer,
    if_send_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE wms_inwh (
    inwh_seq integer DEFAULT nextval('wms_inwh_seq'::regclass) NOT NULL,
    biz_seq integer NOT NULL,
    inwh_no character varying(30) NOT NULL,
    center_seq integer NOT NULL,
    inwh_type_cd character varying(50) NOT NULL,
    inwh_sts_cd character varying(50) NOT NULL,
    req_ymd character varying(8) NOT NULL,
    req_hms character varying(6),
    req_user_nm character varying(100),
    cont_seq integer,
    cfm_ymd character varying(8),
    cfm_hms character varying(6),
    cfm_user_id character varying(20),
    req_no character varying(30),
    erp_wh_cd character varying(50),
    note character varying(1000),
    if_key character varying(50),
    if_err_seq integer,
    if_send_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE wms_inwh_label (
    inwh_label_seq bigint DEFAULT nextval('wms_inwh_label_seq'::regclass) NOT NULL,
    req_seq integer NOT NULL,
    req_prod_seq bigint NOT NULL,
    inout_type_cd character varying(50) NOT NULL,
    biz_seq integer NOT NULL,
    center_seq integer NOT NULL,
    prod_seq integer NOT NULL,
    sku1_seq integer,
    sku2_seq integer,
    sku_base character varying(100) NOT NULL,
    mng_ymd character varying(8),
    exp_ymd character varying(8),
    lot_no character varying(30),
    sku1 character varying(100) NOT NULL,
    sku2 character varying(100) NOT NULL,
    load_qty numeric(10,2) DEFAULT 1 NOT NULL,
    create_ymd character varying(8) NOT NULL,
    create_hms character varying(6) NOT NULL,
    create_user_id character varying(20) NOT NULL,
    note character varying(1000),
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE wms_inwh_prod (
    inwh_prod_seq bigint DEFAULT nextval('wms_inwh_prod_seq'::regclass) NOT NULL,
    inwh_seq integer NOT NULL,
    prod_seq integer NOT NULL,
    inwh_prod_sts_cd character varying(50) NOT NULL,
    req_qty numeric(10,2) DEFAULT 0 NOT NULL,
    ex_qty numeric(10,2) DEFAULT 0 NOT NULL,
    est_exp_ymd character varying(8),
    est_mng_ymd character varying(8),
    est_lot_no character varying(30),
    pub_sku1_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    pub_sku2_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    pltzing_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    if_send_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    if_idx character varying(20),
    if_err_seq integer,
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE wms_inwh_tran (
    inwh_tran_seq bigint DEFAULT nextval('wms_inwh_tran_seq'::regclass) NOT NULL,
    inwh_prod_seq bigint NOT NULL,
    inwh_seq integer NOT NULL,
    prod_seq integer NOT NULL,
    sku1 character varying(100) NOT NULL,
    sku2 character varying(100) NOT NULL,
    mng_ymd character varying(8),
    exp_ymd character varying(8),
    lot_no character varying(30),
    proc_qty numeric(10,2) DEFAULT 0 NOT NULL,
    ex_qty numeric(10,2) DEFAULT 0 NOT NULL,
    to_wh_seq integer NOT NULL,
    to_loc_seq bigint NOT NULL,
    proc_bundle_no character varying(30),
    proc_ymd character varying(8),
    proc_hms character varying(6),
    proc_user_id character varying(20),
    if_err_seq integer,
    if_send_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE wms_load (
    load_seq integer DEFAULT nextval('wms_load_seq'::regclass) NOT NULL,
    biz_seq integer NOT NULL,
    load_no character varying(30) NOT NULL,
    center_seq integer NOT NULL,
    load_sts_cd character varying(50) NOT NULL,
    car_seq integer,
    driver_nm character varying(100),
    driver_tel character varying(500),
    load_idx smallint DEFAULT 0,
    proc_ymd character varying(8),
    proc_hms character varying(6),
    cfm_ymd character varying(8),
    cfm_hms character varying(6),
    note character varying(1000),
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE wms_load_prod (
    load_prod_seq bigint DEFAULT nextval('wms_load_prod_seq'::regclass) NOT NULL,
    load_seq integer NOT NULL,
    prod_seq integer NOT NULL,
    load_prod_sts_cd character varying(50) NOT NULL,
    req_qty numeric(10,2) DEFAULT 0 NOT NULL,
    ex_qty numeric(10,2) DEFAULT 0 NOT NULL,
    est_mng_ymd character varying(8),
    est_exp_ymd character varying(8),
    est_lot_no character varying(30),
    group_outwh_no character varying(30) NOT NULL,
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE wms_load_tran (
    load_tran_seq bigint DEFAULT nextval('wms_load_tran_seq'::regclass) NOT NULL,
    load_prod_seq bigint NOT NULL,
    load_seq integer NOT NULL,
    prod_seq integer NOT NULL,
    sku1 character varying(100) NOT NULL,
    sku2 character varying(100) NOT NULL,
    lot_no character varying(30),
    mng_ymd character varying(8),
    exp_ymd character varying(8),
    fr_wh_seq integer,
    fr_loc_seq bigint,
    proc_qty numeric(10,2) DEFAULT 0 NOT NULL,
    ex_qty numeric(10,2) DEFAULT 0 NOT NULL,
    to_wh_seq integer,
    to_loc_seq bigint,
    proc_bundle_no character varying(30),
    proc_ymd character varying(8),
    proc_hms character varying(6),
    proc_user_id character varying(20),
    outbiz_tran_seq bigint,
    if_err_seq integer,
    if_send_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE wms_outbiz (
    outbiz_seq integer DEFAULT nextval('wms_outbiz_seq'::regclass) NOT NULL,
    biz_seq integer NOT NULL,
    outbiz_no character varying(30) NOT NULL,
    center_seq integer NOT NULL,
    outbiz_proc_type_cd character varying(50) NOT NULL,
    trn_type_cd character varying(50),
    outbiz_type_cd character varying(50) NOT NULL,
    outbiz_sts_cd character varying(50) NOT NULL,
    outwh_proc_yn character(1) DEFAULT 'Y'::bpchar NOT NULL,
    auto_outbiz_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    if_device_cd character varying(50) DEFAULT '-'::character varying NOT NULL,
    outbiz_stop_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    sales_user_nm character varying(100),
    sales_dept_nm character varying(100),
    req_ymd character varying(8) NOT NULL,
    req_hms character varying(6),
    req_user_nm character varying(100) NOT NULL,
    cont_seq integer,
    so_ymd character varying(8),
    so_hms character varying(6),
    so_no character varying(30),
    req_no character varying(30),
    erp_wh_cd character varying(50),
    delivery_nm character varying(100),
    delivery_ymd character varying(8),
    delivery_hms character varying(6),
    delivery_mng_nm character varying(100),
    delivery_tel character varying(500),
    delivery_addr character varying(200),
    delivery_addr_dtl character varying(200),
    ord_nm character varying(100),
    rcv_nm character varying(100),
    rcv_tel character varying(500),
    rcv_addr character varying(200),
    rcv_addr_dtl character varying(200),
    rcv_post_no character varying(10),
    send_nm character varying(100),
    send_tel character varying(500),
    invoice_info character varying(1000),
    cfm_ymd character varying(8),
    cfm_hms character varying(6),
    cfm_user_id character varying(20),
    ship_msg character varying(1000),
    inwh_seq integer,
    dlv_config_seq integer,
    note character varying(1000),
    if_key character varying(50),
    if_err_seq integer,
    if_send_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    mod_id character varying(20),
    reg_id character varying(20) NOT NULL,
    mod_dt timestamp without time zone,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL
);

CREATE TABLE wms_outbiz_invoice (
    outbiz_seq integer NOT NULL,
    outbiz_prod_seq bigint NOT NULL,
    invoice_seq integer NOT NULL,
    invoice_prod_seq bigint NOT NULL,
    outbiz_req_qty numeric(10,2) DEFAULT 0 NOT NULL,
    outbiz_ex_qty numeric(10,2) DEFAULT 0 NOT NULL,
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE wms_outbiz_load (
    load_seq integer NOT NULL,
    load_prod_seq bigint NOT NULL,
    outbiz_seq integer NOT NULL,
    outbiz_prod_seq bigint NOT NULL,
    load_qty numeric(10,2) DEFAULT 0 NOT NULL,
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE wms_outbiz_outwh (
    outbiz_seq integer NOT NULL,
    outbiz_prod_seq bigint NOT NULL,
    outwh_seq integer NOT NULL,
    outwh_prod_seq bigint NOT NULL,
    prod_seq integer NOT NULL,
    outwh_req_qty numeric(10,2) DEFAULT 0 NOT NULL,
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE wms_outbiz_prod (
    outbiz_prod_seq bigint DEFAULT nextval('wms_outbiz_prod_seq'::regclass) NOT NULL,
    outbiz_seq integer NOT NULL,
    prod_seq integer NOT NULL,
    outbiz_prod_sts_cd character varying(50) NOT NULL,
    req_qty numeric(10,2) DEFAULT 0 NOT NULL,
    ex_qty numeric(10,2) DEFAULT 0 NOT NULL,
    est_mng_ymd character varying(8),
    est_exp_ymd character varying(8),
    est_lot_no character varying(30),
    est_cn character varying(1000),
    if_send_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    if_idx character varying(20),
    if_err_seq integer,
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE wms_outbiz_tran (
    outbiz_tran_seq bigint DEFAULT nextval('wms_outbiz_tran_seq'::regclass) NOT NULL,
    outbiz_prod_seq bigint NOT NULL,
    outbiz_seq integer NOT NULL,
    prod_seq integer NOT NULL,
    sku1 character varying(100) NOT NULL,
    sku2 character varying(100) NOT NULL,
    mng_ymd character varying(8),
    exp_ymd character varying(8),
    lot_no character varying(30),
    fr_wh_seq integer,
    fr_loc_seq bigint,
    proc_qty numeric(10,2) DEFAULT 0 NOT NULL,
    ex_qty numeric(10,2) DEFAULT 0 NOT NULL,
    to_wh_seq integer,
    to_loc_seq bigint,
    proc_bundle_no character varying(30),
    proc_ymd character varying(8),
    proc_hms character varying(6),
    proc_user_id character varying(20),
    group_outwh_no character varying(30),
    invoice_seq integer,
    if_err_seq integer,
    if_send_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE wms_outwh (
    outwh_seq integer DEFAULT nextval('wms_outwh_seq'::regclass) NOT NULL,
    biz_seq integer NOT NULL,
    outwh_no character varying(30) NOT NULL,
    center_seq integer NOT NULL,
    outwh_type_cd character varying(50) NOT NULL,
    outwh_sts_cd character varying(50) NOT NULL,
    outwh_proc_type_cd character varying(50) DEFAULT 'B2B'::character varying NOT NULL,
    outwh_div_cd character varying(50) NOT NULL,
    outwh_div_key character varying(50),
    outwh_div_id character varying(50),
    strng_asgn_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    group_outwh_no character varying(30) NOT NULL,
    req_ymd character varying(8) NOT NULL,
    req_hms character varying(6),
    req_user_nm character varying(100) NOT NULL,
    req_dept_nm character varying(100),
    cfm_ymd character varying(8),
    cfm_hms character varying(6),
    cfm_user_id character varying(20),
    note character varying(1000),
    if_key character varying(50),
    if_err_seq integer,
    if_send_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE wms_outwh_assign (
    outwh_assign_seq bigint DEFAULT nextval('wms_outwh_assign_seq'::regclass) NOT NULL,
    biz_seq integer NOT NULL,
    center_seq integer NOT NULL,
    req_seq integer NOT NULL,
    req_prod_seq bigint NOT NULL,
    prod_seq integer NOT NULL,
    wh_seq integer,
    loc_seq bigint,
    sku1 character varying(100),
    sku2 character varying(100),
    req_qty numeric(10,2) DEFAULT 0,
    mng_ymd character varying(8),
    exp_ymd character varying(8),
    lot_no character varying(30),
    req_no character varying(30) NOT NULL,
    strng_asgn_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE wms_outwh_prod (
    outwh_prod_seq bigint DEFAULT nextval('wms_outwh_prod_seq'::regclass) NOT NULL,
    outwh_seq integer NOT NULL,
    prod_seq integer NOT NULL,
    outwh_prod_sts_cd character varying(50) NOT NULL,
    req_qty numeric(10,2) DEFAULT 0 NOT NULL,
    ex_qty numeric(10,2) DEFAULT 0 NOT NULL,
    est_mng_ymd character varying(8),
    est_exp_ymd character varying(8),
    est_lot_no character varying(30),
    est_cn character varying(1000),
    if_idx character varying(20),
    if_err_seq integer,
    if_send_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE wms_outwh_tran (
    outwh_tran_seq bigint DEFAULT nextval('wms_outwh_tran_seq'::regclass) NOT NULL,
    outwh_prod_seq bigint NOT NULL,
    outwh_seq integer NOT NULL,
    prod_seq integer NOT NULL,
    sku1 character varying(100) NOT NULL,
    sku2 character varying(100) NOT NULL,
    mng_ymd character varying(8),
    exp_ymd character varying(8),
    lot_no character varying(30),
    fr_wh_seq integer,
    fr_loc_seq bigint,
    proc_qty numeric(10,2) DEFAULT 0 NOT NULL,
    ex_qty numeric(10,2) DEFAULT 0 NOT NULL,
    to_wh_seq integer,
    to_loc_seq bigint,
    proc_bundle_no character varying(30),
    proc_ymd character varying(8),
    proc_hms character varying(6),
    proc_user_id character varying(20),
    if_err_seq integer,
    if_send_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE wms_return (
    return_seq integer DEFAULT nextval('wms_return_seq'::regclass) NOT NULL,
    biz_seq integer NOT NULL,
    return_no character varying(30) NOT NULL,
    center_seq integer NOT NULL,
    return_type_cd character varying(50) NOT NULL,
    return_sts_cd character varying(50) NOT NULL,
    req_ymd character varying(8) NOT NULL,
    req_hms character varying(6),
    req_user_nm character varying(100),
    cont_seq integer,
    cfm_ymd character varying(8),
    cfm_hms character varying(6),
    cfm_user_id character varying(20),
    req_no character varying(30),
    erp_wh_cd character varying(50),
    outbiz_seq integer,
    note character varying(1000),
    if_key character varying(50),
    if_err_seq integer,
    if_send_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE wms_return_prod (
    return_prod_seq bigint DEFAULT nextval('wms_return_prod_seq'::regclass) NOT NULL,
    return_seq integer NOT NULL,
    prod_seq integer NOT NULL,
    return_prod_sts_cd character varying(50) NOT NULL,
    req_qty numeric(10,2) DEFAULT 0 NOT NULL,
    ex_qty numeric(10,2) DEFAULT 0 NOT NULL,
    est_exp_ymd character varying(8),
    est_mng_ymd character varying(8),
    est_lot_no character varying(30),
    pub_sku1_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    pub_sku2_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    pltzing_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    if_send_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    if_idx character varying(20),
    if_err_seq integer,
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE wms_return_tran (
    return_tran_seq bigint DEFAULT nextval('wms_return_tran_seq'::regclass) NOT NULL,
    return_prod_seq bigint NOT NULL,
    return_seq integer NOT NULL,
    prod_seq integer NOT NULL,
    sku1 character varying(100) NOT NULL,
    sku2 character varying(100) NOT NULL,
    mng_ymd character varying(8),
    exp_ymd character varying(8),
    lot_no character varying(30),
    proc_qty numeric(10,2) DEFAULT 0 NOT NULL,
    ex_qty numeric(10,2) DEFAULT 0 NOT NULL,
    to_wh_seq integer NOT NULL,
    to_loc_seq bigint NOT NULL,
    proc_bundle_no character varying(30),
    proc_ymd character varying(8),
    proc_hms character varying(6),
    proc_user_id character varying(20),
    if_err_seq integer,
    if_send_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE wms_st_inven (
    st_inven_seq bigint DEFAULT nextval('wms_st_inven_seq'::regclass) NOT NULL,
    st_sch_seq integer NOT NULL,
    prod_seq integer NOT NULL,
    sku1 character varying(100) NOT NULL,
    sku2 character varying(100) NOT NULL,
    wh_seq integer NOT NULL,
    loc_seq bigint NOT NULL,
    inven_qty numeric(10,2) DEFAULT 0 NOT NULL,
    cfm_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE wms_st_sch (
    st_sch_seq integer DEFAULT nextval('wms_st_sch_seq'::regclass) NOT NULL,
    yyyy character varying(4) NOT NULL,
    biz_seq integer NOT NULL,
    center_seq integer NOT NULL,
    st_idx smallint DEFAULT 0 NOT NULL,
    st_target_cd character varying(50) NOT NULL,
    st_sch_sts_cd character varying(50) NOT NULL,
    st_exp_ymd character varying(8),
    st_end_ymd character varying(8),
    inven_fix_ymd character varying(8),
    inven_fix_hms character varying(6),
    note character varying(1000),
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE wms_st_target (
    st_target_seq integer DEFAULT nextval('wms_st_target_seq'::regclass) NOT NULL,
    st_sch_seq integer NOT NULL,
    target_seq integer NOT NULL,
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);

CREATE TABLE wms_st_tran (
    st_tran_seq bigint DEFAULT nextval('wms_st_tran_seq'::regclass) NOT NULL,
    st_sch_seq integer NOT NULL,
    prod_seq integer NOT NULL,
    sku1 character varying(100) NOT NULL,
    sku2 character varying(100) NOT NULL,
    wh_seq integer NOT NULL,
    loc_seq bigint NOT NULL,
    st_qty numeric(10,2) DEFAULT 0 NOT NULL,
    st_ymd character varying(8) NOT NULL,
    st_hms character varying(6) NOT NULL,
    st_user_id character varying(20) NOT NULL,
    del_yn character(1) DEFAULT 'N'::bpchar NOT NULL,
    reg_id character varying(20) NOT NULL,
    reg_dt timestamp without time zone DEFAULT now() NOT NULL,
    mod_id character varying(20),
    mod_dt timestamp without time zone
);


-- ============================================================
-- 3. PRIMARY KEY CONSTRAINTS
-- ============================================================

ALTER TABLE flyway_schema_history
    ADD CONSTRAINT flyway_schema_history_pk PRIMARY KEY (installed_rank);

ALTER TABLE mdm_biz
    ADD CONSTRAINT "mdm_biz_PK" PRIMARY KEY (biz_seq);

ALTER TABLE mdm_car
    ADD CONSTRAINT "mdm_car_PK" PRIMARY KEY (car_seq);

ALTER TABLE mdm_center
    ADD CONSTRAINT "mdm_center_PK" PRIMARY KEY (center_seq);

ALTER TABLE mdm_cont
    ADD CONSTRAINT "mdm_cont_PK" PRIMARY KEY (cont_seq);

ALTER TABLE mdm_cont_prod
    ADD CONSTRAINT "mdm_cont_prod_PK" PRIMARY KEY (cont_prod_seq);

ALTER TABLE mdm_doc_no
    ADD CONSTRAINT "mdm_doc_no_PK" PRIMARY KEY (biz_seq, inout_type_cd, base_ymd);

ALTER TABLE mdm_label_paper
    ADD CONSTRAINT "mdm_label_paper_PK" PRIMARY KEY (label_paper_seq);

ALTER TABLE mdm_loc
    ADD CONSTRAINT "mdm_loc_PK" PRIMARY KEY (loc_seq);

ALTER TABLE mdm_prod
    ADD CONSTRAINT "mdm_prod_PK" PRIMARY KEY (prod_seq);

ALTER TABLE mdm_rp_prod
    ADD CONSTRAINT "mdm_rp_prod_PK" PRIMARY KEY (rp_prod_seq);

ALTER TABLE mdm_st_config
    ADD CONSTRAINT "PK_mdm_st_config" PRIMARY KEY (st_config_seq);

ALTER TABLE mdm_st_config_dtl
    ADD CONSTRAINT "PK_mdm_st_config_dtl" PRIMARY KEY (st_config_dtl_seq);

ALTER TABLE mdm_st_prod
    ADD CONSTRAINT "mdm_st_prod_PK" PRIMARY KEY (st_prod_seq);

ALTER TABLE mdm_user
    ADD CONSTRAINT "mdm_user_PK" PRIMARY KEY (user_id);

ALTER TABLE mdm_wh
    ADD CONSTRAINT "mdm_wh_PK" PRIMARY KEY (wh_seq);

ALTER TABLE qrtz_blob_triggers
    ADD CONSTRAINT qrtz_blob_triggers_pkey PRIMARY KEY (sched_name, trigger_name, trigger_group);

ALTER TABLE qrtz_calendars
    ADD CONSTRAINT qrtz_calendars_pkey PRIMARY KEY (sched_name, calendar_name);

ALTER TABLE qrtz_cron_triggers
    ADD CONSTRAINT qrtz_cron_triggers_pkey PRIMARY KEY (sched_name, trigger_name, trigger_group);

ALTER TABLE qrtz_fired_triggers
    ADD CONSTRAINT qrtz_fired_triggers_pkey PRIMARY KEY (sched_name, entry_id);

ALTER TABLE qrtz_job_details
    ADD CONSTRAINT qrtz_job_details_pkey PRIMARY KEY (sched_name, job_name, job_group);

ALTER TABLE qrtz_locks
    ADD CONSTRAINT qrtz_locks_pkey PRIMARY KEY (sched_name, lock_name);

ALTER TABLE qrtz_paused_trigger_grps
    ADD CONSTRAINT qrtz_paused_trigger_grps_pkey PRIMARY KEY (sched_name, trigger_group);

ALTER TABLE qrtz_scheduler_state
    ADD CONSTRAINT qrtz_scheduler_state_pkey PRIMARY KEY (sched_name, instance_name);

ALTER TABLE qrtz_simple_triggers
    ADD CONSTRAINT qrtz_simple_triggers_pkey PRIMARY KEY (sched_name, trigger_name, trigger_group);

ALTER TABLE qrtz_simprop_triggers
    ADD CONSTRAINT qrtz_simprop_triggers_pkey PRIMARY KEY (sched_name, trigger_name, trigger_group);

ALTER TABLE qrtz_triggers
    ADD CONSTRAINT qrtz_triggers_pkey PRIMARY KEY (sched_name, trigger_name, trigger_group);

ALTER TABLE sif_batch_history
    ADD CONSTRAINT "sif_batch_history_PK" PRIMARY KEY (if_seq);

ALTER TABLE sm_alarm_history
    ADD CONSTRAINT "sm_alarm_history_PK" PRIMARY KEY (alarm_history_seq);

ALTER TABLE sm_alarm_unrcv
    ADD CONSTRAINT "sm_alarm_unrcv_PK" PRIMARY KEY (user_id, menu_cd);

ALTER TABLE sm_api_config
    ADD CONSTRAINT "sm_api_config_PK" PRIMARY KEY (biz_seq, if_id);

ALTER TABLE sm_biz_config
    ADD CONSTRAINT "sm_biz_config_PK" PRIMARY KEY (biz_seq);

ALTER TABLE sm_board
    ADD CONSTRAINT "sm_board_PK" PRIMARY KEY (board_seq);

ALTER TABLE sm_comm_d
    ADD CONSTRAINT "sm_comm_d_PK" PRIMARY KEY (biz_seq, comm_h_cd, comm_d_cd);

ALTER TABLE sm_comm_h
    ADD CONSTRAINT "sm_comm_h_PK" PRIMARY KEY (biz_seq, comm_h_cd);

ALTER TABLE sm_dlv_config
    ADD CONSTRAINT "sm_dlv_config_PK" PRIMARY KEY (dlv_config_seq);

ALTER TABLE sm_dlv_config_applied
    ADD CONSTRAINT "sm_dlv_config_applied_PK" PRIMARY KEY (dlv_config_applied_seq);

ALTER TABLE sm_file
    ADD CONSTRAINT "sm_file_PK" PRIMARY KEY (file_seq);

ALTER TABLE sm_file_req
    ADD CONSTRAINT "sm_file_req_PK" PRIMARY KEY (file_seq, req_type_cd, req_seq);

ALTER TABLE sm_group
    ADD CONSTRAINT "sm_group_PK" PRIMARY KEY (group_seq);

ALTER TABLE sm_log_api
    ADD CONSTRAINT "sm_log_api_PK" PRIMARY KEY (log_api_seq);

ALTER TABLE sm_log_conn
    ADD CONSTRAINT "sm_log_conn_PK" PRIMARY KEY (log_conn_seq);

ALTER TABLE sm_log_conn_dtl
    ADD CONSTRAINT "sm_log_conn_dtl_PK" PRIMARY KEY (log_conn_seq);

ALTER TABLE sm_log_error
    ADD CONSTRAINT "sm_log_error_PK" PRIMARY KEY (log_error_seq);

ALTER TABLE sm_log_menu
    ADD CONSTRAINT "sm_log_menu_PK" PRIMARY KEY (biz_seq, yyyymmdd, menu_cd);

ALTER TABLE sm_menu
    ADD CONSTRAINT "sm_menu_PK" PRIMARY KEY (menu_cd);

ALTER TABLE sm_menu_group
    ADD CONSTRAINT "sm_menu_group_PK" PRIMARY KEY (menu_cd, group_seq);

ALTER TABLE sm_menu_opt_config
    ADD CONSTRAINT "sm_menu_opt_config_PK" PRIMARY KEY (biz_seq, menu_cd);

ALTER TABLE sm_ob_proc_opt_config
    ADD CONSTRAINT "sm_ob_proc_opt_config_PK" PRIMARY KEY (biz_seq, outbiz_type_cd);

ALTER TABLE sm_opt_config
    ADD CONSTRAINT "sm_opt_config_PK" PRIMARY KEY (biz_seq);

ALTER TABLE sm_prod_opt_config
    ADD CONSTRAINT "sm_prod_opt_config_PK" PRIMARY KEY (biz_seq, prod_div_cd);

ALTER TABLE sm_push_cycle
    ADD CONSTRAINT "sm_push_cycle_PK" PRIMARY KEY (push_cycle_seq);

ALTER TABLE sm_push_history
    ADD CONSTRAINT "sm_push_history_PK" PRIMARY KEY (push_history_seq);

ALTER TABLE sm_push_unrcv
    ADD CONSTRAINT "sm_push_unrcv_PK" PRIMARY KEY (user_id, push_type_cd);

ALTER TABLE sm_qrtz_change_log
    ADD CONSTRAINT "sm_qrtz_change_log_PK" PRIMARY KEY (qrtz_change_log_seq);

ALTER TABLE sm_qrtz_exec_log
    ADD CONSTRAINT "sm_qrtz_exec_log_PK" PRIMARY KEY (qrtz_exec_log_seq);

ALTER TABLE sm_qrtz_job_state
    ADD CONSTRAINT "sm_qrtz_job_state_PK" PRIMARY KEY (job_cls_nm);

ALTER TABLE sm_user_pwd_history
    ADD CONSTRAINT "sm_user_pwd_history_PK" PRIMARY KEY (user_pwd_history_seq);

ALTER TABLE wes_process_history
    ADD CONSTRAINT "wes_process_history_PK" PRIMARY KEY (wes_proc_seq);

ALTER TABLE wms_inbiz
    ADD CONSTRAINT "wms_inbiz_PK" PRIMARY KEY (inbiz_seq);

ALTER TABLE wms_inbiz_prod
    ADD CONSTRAINT "wms_inbiz_prod_PK" PRIMARY KEY (inbiz_prod_seq, inbiz_seq);

ALTER TABLE wms_inven
    ADD CONSTRAINT "wms_inven_PK" PRIMARY KEY (biz_seq, center_seq, prod_seq, sku1, sku2, wh_seq, loc_seq);

ALTER TABLE wms_inven_ad
    ADD CONSTRAINT "wms_inven_ad_PK" PRIMARY KEY (ad_seq);

ALTER TABLE wms_inven_ad_prod
    ADD CONSTRAINT "wms_inven_ad_prod_PK" PRIMARY KEY (ad_prod_seq, ad_seq);

ALTER TABLE wms_inven_ad_tran
    ADD CONSTRAINT "wms_inven_ad_tran_PK" PRIMARY KEY (ad_tran_seq, ad_prod_seq, ad_seq);

ALTER TABLE wms_inven_etc
    ADD CONSTRAINT "wms_inven_etc_PK" PRIMARY KEY (etc_seq);

ALTER TABLE wms_inven_etc_prod
    ADD CONSTRAINT "wms_inven_etc_prod_PK" PRIMARY KEY (etc_prod_seq, etc_seq);

ALTER TABLE wms_inven_etc_tran
    ADD CONSTRAINT "wms_inven_etc_tran_PK" PRIMARY KEY (etc_tran_seq, etc_prod_seq, etc_seq);

ALTER TABLE wms_inven_holding
    ADD CONSTRAINT "wms_inven_holding_PK" PRIMARY KEY (inven_holding_seq);

ALTER TABLE wms_inven_inout
    ADD CONSTRAINT "wms_inven_inout_PK" PRIMARY KEY (inven_inout_seq);

ALTER TABLE wms_inven_month
    ADD CONSTRAINT "wms_inven_month_PK" PRIMARY KEY (inven_month_seq);

ALTER TABLE wms_inven_mv
    ADD CONSTRAINT "wms_inven_mv_PK" PRIMARY KEY (mv_seq);

ALTER TABLE wms_inven_mv_prod
    ADD CONSTRAINT "wms_inven_mv_prod_PK" PRIMARY KEY (mv_prod_seq, mv_seq);

ALTER TABLE wms_inven_mv_tran
    ADD CONSTRAINT "wms_inven_mv_tran_PK" PRIMARY KEY (mv_tran_seq, mv_prod_seq, mv_seq);

ALTER TABLE wms_inven_rp
    ADD CONSTRAINT "wms_inven_rp_PK" PRIMARY KEY (rp_seq);

ALTER TABLE wms_inven_rp_prod
    ADD CONSTRAINT "wms_inven_rp_prod_PK" PRIMARY KEY (rp_prod_seq, rp_seq);

ALTER TABLE wms_inven_rp_tran
    ADD CONSTRAINT "wms_inven_rp_tran_PK" PRIMARY KEY (rp_tran_seq, rp_prod_seq, rp_seq);

ALTER TABLE wms_inven_sku
    ADD CONSTRAINT "wms_inven_sku_PK" PRIMARY KEY (biz_seq, prod_seq, sku1, sku2);

ALTER TABLE wms_inven_st
    ADD CONSTRAINT "wms_inven_st_PK" PRIMARY KEY (st_seq);

ALTER TABLE wms_inven_st_prod
    ADD CONSTRAINT "wms_inven_st_prod_PK" PRIMARY KEY (st_prod_seq, st_seq);

ALTER TABLE wms_inven_st_tran
    ADD CONSTRAINT "wms_inven_st_tran_PK" PRIMARY KEY (st_tran_seq, st_prod_seq, st_seq);

ALTER TABLE wms_invoice
    ADD CONSTRAINT "wms_invoice_PK" PRIMARY KEY (invoice_seq);

ALTER TABLE wms_invoice_prod
    ADD CONSTRAINT "wms_invoice_prod_PK" PRIMARY KEY (invoice_prod_seq, invoice_seq);

ALTER TABLE wms_invoice_tran
    ADD CONSTRAINT "wms_invoice_tran_PK" PRIMARY KEY (invoice_tran_seq, invoice_prod_seq, invoice_seq);

ALTER TABLE wms_inwh
    ADD CONSTRAINT "wms_inwh_PK" PRIMARY KEY (inwh_seq);

ALTER TABLE wms_inwh_label
    ADD CONSTRAINT "wms_inwh_label_PK" PRIMARY KEY (inwh_label_seq);

ALTER TABLE wms_inwh_prod
    ADD CONSTRAINT "wms_inwh_prod_PK" PRIMARY KEY (inwh_prod_seq, inwh_seq);

ALTER TABLE wms_inwh_tran
    ADD CONSTRAINT "wms_inwh_tran_PK" PRIMARY KEY (inwh_tran_seq, inwh_prod_seq, inwh_seq);

ALTER TABLE wms_load
    ADD CONSTRAINT "wms_load_PK" PRIMARY KEY (load_seq);

ALTER TABLE wms_load_prod
    ADD CONSTRAINT "wms_load_prod_PK" PRIMARY KEY (load_prod_seq, load_seq);

ALTER TABLE wms_load_tran
    ADD CONSTRAINT "wms_load_tran_PK" PRIMARY KEY (load_tran_seq, load_prod_seq, load_seq);

ALTER TABLE wms_outbiz
    ADD CONSTRAINT "wms_outbiz_PK" PRIMARY KEY (outbiz_seq);

ALTER TABLE wms_outbiz_invoice
    ADD CONSTRAINT "wms_outbiz_invoice_PK" PRIMARY KEY (outbiz_seq, outbiz_prod_seq, invoice_seq, invoice_prod_seq);

ALTER TABLE wms_outbiz_load
    ADD CONSTRAINT "wms_outbiz_load_PK" PRIMARY KEY (load_seq, load_prod_seq, outbiz_seq, outbiz_prod_seq);

ALTER TABLE wms_outbiz_outwh
    ADD CONSTRAINT "wms_outbiz_outwh_PK" PRIMARY KEY (outbiz_seq, outbiz_prod_seq, outwh_seq, outwh_prod_seq);

ALTER TABLE wms_outbiz_prod
    ADD CONSTRAINT "wms_outbiz_prod_PK" PRIMARY KEY (outbiz_prod_seq, outbiz_seq);

ALTER TABLE wms_outbiz_tran
    ADD CONSTRAINT "wms_outbiz_tran_PK" PRIMARY KEY (outbiz_tran_seq, outbiz_prod_seq, outbiz_seq);

ALTER TABLE wms_outwh
    ADD CONSTRAINT "wms_outwh_PK" PRIMARY KEY (outwh_seq);

ALTER TABLE wms_outwh_assign
    ADD CONSTRAINT "wms_outwh_assign_PK" PRIMARY KEY (outwh_assign_seq);

ALTER TABLE wms_outwh_prod
    ADD CONSTRAINT "wms_outwh_prod_PK" PRIMARY KEY (outwh_prod_seq, outwh_seq);

ALTER TABLE wms_outwh_tran
    ADD CONSTRAINT "wms_outwh_tran_PK" PRIMARY KEY (outwh_tran_seq, outwh_prod_seq, outwh_seq);

ALTER TABLE wms_return
    ADD CONSTRAINT "wms_return_PK" PRIMARY KEY (return_seq);

ALTER TABLE wms_return_prod
    ADD CONSTRAINT "wms_return_prod_PK" PRIMARY KEY (return_prod_seq, return_seq);

ALTER TABLE wms_return_tran
    ADD CONSTRAINT "wms_return_tran_PK" PRIMARY KEY (return_tran_seq, return_prod_seq, return_seq);

ALTER TABLE wms_st_inven
    ADD CONSTRAINT "wms_st_inven_PK" PRIMARY KEY (st_inven_seq, st_sch_seq);

ALTER TABLE wms_st_sch
    ADD CONSTRAINT "wms_st_sch_PK" PRIMARY KEY (st_sch_seq);

ALTER TABLE wms_st_target
    ADD CONSTRAINT "wms_st_target_PK" PRIMARY KEY (st_target_seq, st_sch_seq);

ALTER TABLE wms_st_tran
    ADD CONSTRAINT "wms_st_tran_PK" PRIMARY KEY (st_tran_seq, st_sch_seq);


-- ============================================================
-- 4. UNIQUE CONSTRAINTS
-- ============================================================

ALTER TABLE mdm_biz_center
    ADD CONSTRAINT "UK_mdm_biz_center" UNIQUE (biz_seq, center_seq);

ALTER TABLE mdm_biz_wh
    ADD CONSTRAINT "UK_mdm_biz_wh" UNIQUE (biz_seq, wh_seq);

ALTER TABLE mdm_cont_prod
    ADD CONSTRAINT "UK_mdm_cont_prod" UNIQUE (cont_seq, prod_seq);

ALTER TABLE mdm_user_biz
    ADD CONSTRAINT "UK_mdm_user_biz" UNIQUE (biz_seq, user_id);

ALTER TABLE mdm_user_center
    ADD CONSTRAINT "UK_mdm_user_center" UNIQUE (center_seq, user_id);

ALTER TABLE sm_dlv_config_applied
    ADD CONSTRAINT "UK_sm_dlv_config_applied" UNIQUE (dlv_config_seq, center_seq, biz_seq);

ALTER TABLE sm_file
    ADD CONSTRAINT "UK_sm_file" UNIQUE (file_uuid);

ALTER TABLE wms_inven
    ADD CONSTRAINT "UK_wms_inven" UNIQUE (biz_seq, center_seq, prod_seq, sku1, sku2, wh_seq, loc_seq);

ALTER TABLE wms_inven_ad
    ADD CONSTRAINT "UK_wms_inven_ad" UNIQUE (biz_seq, ad_no);

ALTER TABLE wms_inven_etc
    ADD CONSTRAINT "UK_wms_inven_etc" UNIQUE (biz_seq, etc_no);

ALTER TABLE wms_inven_mv
    ADD CONSTRAINT "UK_wms_inven_mv" UNIQUE (biz_seq, mv_no);

ALTER TABLE wms_inven_st
    ADD CONSTRAINT "UK_wms_inven_st" UNIQUE (biz_seq, st_no);

ALTER TABLE wms_inwh
    ADD CONSTRAINT "UK_wms_inwh" UNIQUE (biz_seq, inwh_no);

ALTER TABLE wms_outbiz_tran
    ADD CONSTRAINT "UK_wms_outbiz_tran" UNIQUE (outbiz_tran_seq);

ALTER TABLE wms_return
    ADD CONSTRAINT "UK_wms_return" UNIQUE (biz_seq, return_no);

ALTER TABLE wms_st_sch
    ADD CONSTRAINT "UK_wms_st_sch" UNIQUE (yyyy, biz_seq, center_seq, st_idx);


-- ============================================================
-- 5. FOREIGN KEY CONSTRAINTS
-- ============================================================

ALTER TABLE mdm_biz_biz
    ADD CONSTRAINT "mdm_biz_TO_mdm_biz_biz" FOREIGN KEY (biz_seq) REFERENCES mdm_biz (biz_seq);

ALTER TABLE mdm_biz_biz
    ADD CONSTRAINT "mdm_biz_TO_mdm_biz_biz2" FOREIGN KEY (ref_biz_seq) REFERENCES mdm_biz (biz_seq);

ALTER TABLE mdm_biz_center
    ADD CONSTRAINT "mdm_biz_TO_mdm_biz_center" FOREIGN KEY (biz_seq) REFERENCES mdm_biz (biz_seq);

ALTER TABLE mdm_biz_center
    ADD CONSTRAINT "mdm_center_TO_mdm_biz_center" FOREIGN KEY (center_seq) REFERENCES mdm_center (center_seq);

ALTER TABLE mdm_biz_cont
    ADD CONSTRAINT "mdm_biz_TO_mdm_biz_cont" FOREIGN KEY (biz_seq) REFERENCES mdm_biz (biz_seq);

ALTER TABLE mdm_biz_cont
    ADD CONSTRAINT "mdm_cont_TO_mdm_biz_cont" FOREIGN KEY (cont_seq) REFERENCES mdm_cont (cont_seq);

ALTER TABLE mdm_biz_prod
    ADD CONSTRAINT "mdm_biz_TO_mdm_biz_prod" FOREIGN KEY (biz_seq) REFERENCES mdm_biz (biz_seq);

ALTER TABLE mdm_biz_prod
    ADD CONSTRAINT "mdm_prod_TO_mdm_biz_prod" FOREIGN KEY (prod_seq) REFERENCES mdm_prod (prod_seq);

ALTER TABLE mdm_biz_wh
    ADD CONSTRAINT "mdm_biz_TO_mdm_biz_wh" FOREIGN KEY (biz_seq) REFERENCES mdm_biz (biz_seq);

ALTER TABLE mdm_biz_wh
    ADD CONSTRAINT "mdm_wh_TO_mdm_biz_wh" FOREIGN KEY (wh_seq) REFERENCES mdm_wh (wh_seq);

ALTER TABLE mdm_car
    ADD CONSTRAINT "mdm_biz_TO_mdm_car" FOREIGN KEY (biz_seq) REFERENCES mdm_biz (biz_seq);

ALTER TABLE mdm_cont_prod
    ADD CONSTRAINT "mdm_biz_TO_mdm_cont_prod" FOREIGN KEY (biz_seq) REFERENCES mdm_biz (biz_seq);

ALTER TABLE mdm_cont_prod
    ADD CONSTRAINT "mdm_cont_TO_mdm_cont_prod" FOREIGN KEY (cont_seq) REFERENCES mdm_cont (cont_seq);

ALTER TABLE mdm_cont_prod
    ADD CONSTRAINT "mdm_prod_TO_mdm_cont_prod" FOREIGN KEY (prod_seq) REFERENCES mdm_prod (prod_seq);

ALTER TABLE mdm_doc_no
    ADD CONSTRAINT "mdm_biz_TO_mdm_doc_no" FOREIGN KEY (biz_seq) REFERENCES mdm_biz (biz_seq);

ALTER TABLE mdm_loc
    ADD CONSTRAINT "mdm_wh_TO_mdm_loc" FOREIGN KEY (wh_seq) REFERENCES mdm_wh (wh_seq);

ALTER TABLE mdm_prod
    ADD CONSTRAINT "mdm_label_paper_TO_mdm_prod" FOREIGN KEY (label_paper_seq) REFERENCES mdm_label_paper (label_paper_seq);

ALTER TABLE mdm_prod
    ADD CONSTRAINT "mdm_label_paper_TO_mdm_prod2" FOREIGN KEY (parent_label_paper_seq) REFERENCES mdm_label_paper (label_paper_seq);

ALTER TABLE mdm_rp_prod
    ADD CONSTRAINT "mdm_prod_TO_mdm_rp_prod" FOREIGN KEY (prod_seq) REFERENCES mdm_prod (prod_seq);

ALTER TABLE mdm_rp_prod
    ADD CONSTRAINT "mdm_rp_prod_TO_mdm_rp_prod" FOREIGN KEY (ref_rp_prod_seq) REFERENCES mdm_rp_prod (rp_prod_seq);

ALTER TABLE mdm_st_config_dtl
    ADD CONSTRAINT "FK_mdm_st_config_TO_mdm_st_config_dtl" FOREIGN KEY (st_config_seq) REFERENCES mdm_st_config (st_config_seq);

ALTER TABLE mdm_st_prod
    ADD CONSTRAINT "mdm_st_prod_TO_mdm_st_prod" FOREIGN KEY (ref_st_prod_seq) REFERENCES mdm_st_prod (st_prod_seq);

ALTER TABLE mdm_user
    ADD CONSTRAINT "sm_group_TO_mdm_user" FOREIGN KEY (group_seq) REFERENCES sm_group (group_seq);

ALTER TABLE mdm_user_biz
    ADD CONSTRAINT "mdm_biz_TO_mdm_user_biz" FOREIGN KEY (biz_seq) REFERENCES mdm_biz (biz_seq);

ALTER TABLE mdm_user_biz
    ADD CONSTRAINT "mdm_user_TO_mdm_user_biz" FOREIGN KEY (user_id) REFERENCES mdm_user (user_id);

ALTER TABLE mdm_user_center
    ADD CONSTRAINT "mdm_center_TO_mdm_user_center" FOREIGN KEY (center_seq) REFERENCES mdm_center (center_seq);

ALTER TABLE mdm_user_center
    ADD CONSTRAINT "mdm_user_TO_mdm_user_center" FOREIGN KEY (user_id) REFERENCES mdm_user (user_id);

ALTER TABLE mdm_wh
    ADD CONSTRAINT "mdm_center_TO_mdm_wh" FOREIGN KEY (center_seq) REFERENCES mdm_center (center_seq);

ALTER TABLE qrtz_blob_triggers
    ADD CONSTRAINT qrtz_blob_triggers_sched_name_trigger_name_trigger_group_fkey FOREIGN KEY (sched_name, trigger_name, trigger_group) REFERENCES qrtz_triggers (sched_name, trigger_name, trigger_group);

ALTER TABLE qrtz_cron_triggers
    ADD CONSTRAINT qrtz_cron_triggers_sched_name_trigger_name_trigger_group_fkey FOREIGN KEY (sched_name, trigger_name, trigger_group) REFERENCES qrtz_triggers (sched_name, trigger_name, trigger_group);

ALTER TABLE qrtz_simple_triggers
    ADD CONSTRAINT qrtz_simple_triggers_sched_name_trigger_name_trigger_group_fkey FOREIGN KEY (sched_name, trigger_name, trigger_group) REFERENCES qrtz_triggers (sched_name, trigger_name, trigger_group);

ALTER TABLE qrtz_simprop_triggers
    ADD CONSTRAINT qrtz_simprop_triggers_sched_name_trigger_name_trigger_grou_fkey FOREIGN KEY (sched_name, trigger_name, trigger_group) REFERENCES qrtz_triggers (sched_name, trigger_name, trigger_group);

ALTER TABLE qrtz_triggers
    ADD CONSTRAINT qrtz_triggers_sched_name_job_name_job_group_fkey FOREIGN KEY (sched_name, job_name, job_group) REFERENCES qrtz_job_details (sched_name, job_name, job_group);

ALTER TABLE sm_alarm_history
    ADD CONSTRAINT "mdm_biz_TO_sm_alarm_history" FOREIGN KEY (biz_seq) REFERENCES mdm_biz (biz_seq);

ALTER TABLE sm_comm_d
    ADD CONSTRAINT "sm_comm_h_TO_sm_comm_d" FOREIGN KEY (biz_seq, comm_h_cd) REFERENCES sm_comm_h (biz_seq, comm_h_cd);

ALTER TABLE sm_dlv_config_applied
    ADD CONSTRAINT "sm_dlv_config_TO_sm_dlv_config_applied" FOREIGN KEY (dlv_config_seq) REFERENCES sm_dlv_config (dlv_config_seq);

ALTER TABLE sm_file
    ADD CONSTRAINT "mdm_biz_TO_sm_file" FOREIGN KEY (biz_seq) REFERENCES mdm_biz (biz_seq);

ALTER TABLE sm_file_req
    ADD CONSTRAINT "sm_file_TO_sm_file_req" FOREIGN KEY (file_seq) REFERENCES sm_file (file_seq);

ALTER TABLE sm_group
    ADD CONSTRAINT "mdm_biz_TO_sm_group" FOREIGN KEY (biz_seq) REFERENCES mdm_biz (biz_seq);

ALTER TABLE sm_log_conn_dtl
    ADD CONSTRAINT "sm_log_conn_TO_sm_log_conn_dtl" FOREIGN KEY (log_conn_seq) REFERENCES sm_log_conn (log_conn_seq);

ALTER TABLE sm_menu_group
    ADD CONSTRAINT "sm_group_TO_sm_menu_group" FOREIGN KEY (group_seq) REFERENCES sm_group (group_seq);

ALTER TABLE sm_menu_group
    ADD CONSTRAINT "sm_menu_TO_sm_menu_group" FOREIGN KEY (menu_cd) REFERENCES sm_menu (menu_cd);

ALTER TABLE sm_menu_opt_config
    ADD CONSTRAINT "sm_menu_TO_sm_menu_opt_config" FOREIGN KEY (menu_cd) REFERENCES sm_menu (menu_cd);

ALTER TABLE wms_inbiz_inwh
    ADD CONSTRAINT "wms_inbiz_prod_TO_wms_inbiz_inwh" FOREIGN KEY (inbiz_prod_seq, inbiz_seq) REFERENCES wms_inbiz_prod (inbiz_prod_seq, inbiz_seq);

ALTER TABLE wms_inbiz_inwh
    ADD CONSTRAINT "wms_inwh_prod_TO_wms_inbiz_inwh" FOREIGN KEY (inwh_prod_seq, inwh_seq) REFERENCES wms_inwh_prod (inwh_prod_seq, inwh_seq);

ALTER TABLE wms_inbiz_prod
    ADD CONSTRAINT "wms_inbiz_TO_wms_inbiz_prod" FOREIGN KEY (inbiz_seq) REFERENCES wms_inbiz (inbiz_seq);

ALTER TABLE wms_inven_ad_prod
    ADD CONSTRAINT "wms_inven_ad_TO_wms_inven_ad_prod" FOREIGN KEY (ad_seq) REFERENCES wms_inven_ad (ad_seq);

ALTER TABLE wms_inven_ad_tran
    ADD CONSTRAINT "wms_inven_ad_prod_TO_wms_inven_ad_tran" FOREIGN KEY (ad_prod_seq, ad_seq) REFERENCES wms_inven_ad_prod (ad_prod_seq, ad_seq);

ALTER TABLE wms_inven_etc_prod
    ADD CONSTRAINT "wms_inven_etc_TO_wms_inven_etc_prod" FOREIGN KEY (etc_seq) REFERENCES wms_inven_etc (etc_seq);

ALTER TABLE wms_inven_etc_tran
    ADD CONSTRAINT "wms_inven_etc_prod_TO_wms_inven_etc_tran" FOREIGN KEY (etc_prod_seq, etc_seq) REFERENCES wms_inven_etc_prod (etc_prod_seq, etc_seq);

ALTER TABLE wms_inven_mv_prod
    ADD CONSTRAINT "wms_inven_mv_TO_wms_inven_mv_prod" FOREIGN KEY (mv_seq) REFERENCES wms_inven_mv (mv_seq);

ALTER TABLE wms_inven_mv_tran
    ADD CONSTRAINT "wms_inven_mv_prod_TO_wms_inven_mv_tran" FOREIGN KEY (mv_prod_seq, mv_seq) REFERENCES wms_inven_mv_prod (mv_prod_seq, mv_seq);

ALTER TABLE wms_inven_rp_prod
    ADD CONSTRAINT "wms_inven_rp_TO_wms_inven_rp_prod" FOREIGN KEY (rp_seq) REFERENCES wms_inven_rp (rp_seq);

ALTER TABLE wms_inven_rp_tran
    ADD CONSTRAINT "wms_inven_rp_prod_TO_wms_inven_rp_tran" FOREIGN KEY (rp_prod_seq, rp_seq) REFERENCES wms_inven_rp_prod (rp_prod_seq, rp_seq);

ALTER TABLE wms_inven_st_prod
    ADD CONSTRAINT "mdm_st_prod_TO_wms_inven_st_prod" FOREIGN KEY (mdm_st_prod_seq) REFERENCES mdm_st_prod (st_prod_seq);

ALTER TABLE wms_inven_st_prod
    ADD CONSTRAINT "wms_inven_st_TO_wms_inven_st_prod" FOREIGN KEY (st_seq) REFERENCES wms_inven_st (st_seq);

ALTER TABLE wms_inven_st_tran
    ADD CONSTRAINT "wms_inven_st_prod_TO_wms_inven_st_tran" FOREIGN KEY (st_prod_seq, st_seq) REFERENCES wms_inven_st_prod (st_prod_seq, st_seq);

ALTER TABLE wms_invoice_prod
    ADD CONSTRAINT "wms_invoice_TO_wms_invoice_prod" FOREIGN KEY (invoice_seq) REFERENCES wms_invoice (invoice_seq);

ALTER TABLE wms_invoice_tran
    ADD CONSTRAINT "wms_invoice_prod_TO_wms_invoice_tran" FOREIGN KEY (invoice_prod_seq, invoice_seq) REFERENCES wms_invoice_prod (invoice_prod_seq, invoice_seq);

ALTER TABLE wms_invoice_tran
    ADD CONSTRAINT "wms_outbiz_tran_TO_wms_invoice_tran" FOREIGN KEY (outbiz_tran_seq) REFERENCES wms_outbiz_tran (outbiz_tran_seq);

ALTER TABLE wms_inwh_prod
    ADD CONSTRAINT "wms_inwh_TO_wms_inwh_prod" FOREIGN KEY (inwh_seq) REFERENCES wms_inwh (inwh_seq);

ALTER TABLE wms_inwh_tran
    ADD CONSTRAINT "wms_inwh_prod_TO_wms_inwh_tran" FOREIGN KEY (inwh_prod_seq, inwh_seq) REFERENCES wms_inwh_prod (inwh_prod_seq, inwh_seq);

ALTER TABLE wms_load
    ADD CONSTRAINT "mdm_car_TO_wms_load" FOREIGN KEY (car_seq) REFERENCES mdm_car (car_seq);

ALTER TABLE wms_load_prod
    ADD CONSTRAINT "wms_load_TO_wms_load_prod" FOREIGN KEY (load_seq) REFERENCES wms_load (load_seq);

ALTER TABLE wms_load_tran
    ADD CONSTRAINT "wms_load_prod_TO_wms_load_tran" FOREIGN KEY (load_prod_seq, load_seq) REFERENCES wms_load_prod (load_prod_seq, load_seq);

ALTER TABLE wms_load_tran
    ADD CONSTRAINT "wms_outbiz_tran_TO_wms_load_tran" FOREIGN KEY (outbiz_tran_seq) REFERENCES wms_outbiz_tran (outbiz_tran_seq);

ALTER TABLE wms_outbiz_invoice
    ADD CONSTRAINT "wms_invoice_prod_TO_wms_outbiz_invoice" FOREIGN KEY (invoice_prod_seq, invoice_seq) REFERENCES wms_invoice_prod (invoice_prod_seq, invoice_seq);

ALTER TABLE wms_outbiz_invoice
    ADD CONSTRAINT "wms_outbiz_prod_TO_wms_outbiz_invoice" FOREIGN KEY (outbiz_prod_seq, outbiz_seq) REFERENCES wms_outbiz_prod (outbiz_prod_seq, outbiz_seq);

ALTER TABLE wms_outbiz_load
    ADD CONSTRAINT "wms_load_prod_TO_wms_outbiz_load" FOREIGN KEY (load_prod_seq, load_seq) REFERENCES wms_load_prod (load_prod_seq, load_seq);

ALTER TABLE wms_outbiz_load
    ADD CONSTRAINT "wms_outbiz_prod_TO_wms_outbiz_load" FOREIGN KEY (outbiz_prod_seq, outbiz_seq) REFERENCES wms_outbiz_prod (outbiz_prod_seq, outbiz_seq);

ALTER TABLE wms_outbiz_outwh
    ADD CONSTRAINT "wms_outbiz_prod_TO_wms_outbiz_outwh" FOREIGN KEY (outbiz_prod_seq, outbiz_seq) REFERENCES wms_outbiz_prod (outbiz_prod_seq, outbiz_seq);

ALTER TABLE wms_outbiz_outwh
    ADD CONSTRAINT "wms_outwh_prod_TO_wms_outbiz_outwh" FOREIGN KEY (outwh_prod_seq, outwh_seq) REFERENCES wms_outwh_prod (outwh_prod_seq, outwh_seq);

ALTER TABLE wms_outbiz_prod
    ADD CONSTRAINT "wms_outbiz_TO_wms_outbiz_prod" FOREIGN KEY (outbiz_seq) REFERENCES wms_outbiz (outbiz_seq);

ALTER TABLE wms_outbiz_tran
    ADD CONSTRAINT "wms_outbiz_prod_TO_wms_outbiz_tran" FOREIGN KEY (outbiz_prod_seq, outbiz_seq) REFERENCES wms_outbiz_prod (outbiz_prod_seq, outbiz_seq);

ALTER TABLE wms_outwh_prod
    ADD CONSTRAINT "wms_outwh_TO_wms_outwh_prod" FOREIGN KEY (outwh_seq) REFERENCES wms_outwh (outwh_seq);

ALTER TABLE wms_outwh_tran
    ADD CONSTRAINT "wms_outwh_prod_TO_wms_outwh_tran" FOREIGN KEY (outwh_prod_seq, outwh_seq) REFERENCES wms_outwh_prod (outwh_prod_seq, outwh_seq);

ALTER TABLE wms_return_prod
    ADD CONSTRAINT "wms_return_TO_wms_return_prod" FOREIGN KEY (return_seq) REFERENCES wms_return (return_seq);

ALTER TABLE wms_return_tran
    ADD CONSTRAINT "wms_return_prod_TO_wms_return_tran" FOREIGN KEY (return_prod_seq, return_seq) REFERENCES wms_return_prod (return_prod_seq, return_seq);

ALTER TABLE wms_st_inven
    ADD CONSTRAINT "wms_st_sch_TO_wms_st_inven" FOREIGN KEY (st_sch_seq) REFERENCES wms_st_sch (st_sch_seq);

ALTER TABLE wms_st_target
    ADD CONSTRAINT "wms_st_sch_TO_wms_st_target" FOREIGN KEY (st_sch_seq) REFERENCES wms_st_sch (st_sch_seq);

ALTER TABLE wms_st_tran
    ADD CONSTRAINT "wms_st_sch_TO_wms_st_tran" FOREIGN KEY (st_sch_seq) REFERENCES wms_st_sch (st_sch_seq);


-- ============================================================
-- 6. INDEXES
-- ============================================================

CREATE INDEX flyway_schema_history_s_idx ON public.flyway_schema_history USING btree (success);

CREATE INDEX "FK_mdm_st_config_dtl_st_config_seq" ON public.mdm_st_config_dtl USING btree (st_config_seq);

CREATE INDEX idx_qrtz_ft_inst_job_req_rcvry ON public.qrtz_fired_triggers USING btree (sched_name, instance_name, requests_recovery);

CREATE INDEX idx_qrtz_ft_j_g ON public.qrtz_fired_triggers USING btree (sched_name, job_name, job_group);

CREATE INDEX idx_qrtz_ft_jg ON public.qrtz_fired_triggers USING btree (sched_name, job_group);

CREATE INDEX idx_qrtz_ft_t_g ON public.qrtz_fired_triggers USING btree (sched_name, trigger_name, trigger_group);

CREATE INDEX idx_qrtz_ft_tg ON public.qrtz_fired_triggers USING btree (sched_name, trigger_group);

CREATE INDEX idx_qrtz_ft_trig_inst_name ON public.qrtz_fired_triggers USING btree (sched_name, instance_name);

CREATE INDEX idx_qrtz_j_grp ON public.qrtz_job_details USING btree (sched_name, job_group);

CREATE INDEX idx_qrtz_j_req_recovery ON public.qrtz_job_details USING btree (sched_name, requests_recovery);

CREATE INDEX idx_qrtz_t_c ON public.qrtz_triggers USING btree (sched_name, calendar_name);

CREATE INDEX idx_qrtz_t_g ON public.qrtz_triggers USING btree (sched_name, trigger_group);

CREATE INDEX idx_qrtz_t_j ON public.qrtz_triggers USING btree (sched_name, job_name, job_group);

CREATE INDEX idx_qrtz_t_jg ON public.qrtz_triggers USING btree (sched_name, job_group);

CREATE INDEX idx_qrtz_t_n_g_state ON public.qrtz_triggers USING btree (sched_name, trigger_group, trigger_state);

CREATE INDEX idx_qrtz_t_n_state ON public.qrtz_triggers USING btree (sched_name, trigger_name, trigger_group, trigger_state);

CREATE INDEX idx_qrtz_t_next_fire_time ON public.qrtz_triggers USING btree (sched_name, next_fire_time);

CREATE INDEX idx_qrtz_t_nft_misfire ON public.qrtz_triggers USING btree (sched_name, misfire_instr, next_fire_time);

CREATE INDEX idx_qrtz_t_nft_st ON public.qrtz_triggers USING btree (sched_name, trigger_state, next_fire_time);

CREATE INDEX idx_qrtz_t_nft_st_misfire ON public.qrtz_triggers USING btree (sched_name, misfire_instr, next_fire_time, trigger_state);

CREATE INDEX idx_qrtz_t_nft_st_misfire_grp ON public.qrtz_triggers USING btree (sched_name, misfire_instr, next_fire_time, trigger_group, trigger_state);

CREATE INDEX idx_qrtz_t_state ON public.qrtz_triggers USING btree (sched_name, trigger_state);

CREATE INDEX "IX_wms_inven_ad" ON public.wms_inven_ad USING btree (biz_seq, center_seq, req_ymd);

CREATE INDEX "IX_wms_inven_etc" ON public.wms_inven_etc USING btree (biz_seq, center_seq, req_ymd);

CREATE INDEX "IX_wms_inven_mv" ON public.wms_inven_mv USING btree (biz_seq, center_seq, req_ymd);

CREATE INDEX "IX_wms_inven_st" ON public.wms_inven_st USING btree (biz_seq, center_seq, req_ymd);

CREATE INDEX "IX_wms_invoice" ON public.wms_invoice USING btree (biz_seq, group_outwh_no);

CREATE INDEX "IX_wms_inwh2" ON public.wms_inwh USING btree (biz_seq, center_seq, req_ymd);

CREATE INDEX "IX_wms_outwh_assign" ON public.wms_outwh_assign USING btree (biz_seq, center_seq, prod_seq);

CREATE INDEX "IX_wms_outwh_assign2" ON public.wms_outwh_assign USING btree (req_seq, req_prod_seq);

CREATE INDEX "IX_wms_return" ON public.wms_return USING btree (biz_seq, center_seq, req_ymd);

CREATE INDEX "IX_wms_st_target" ON public.wms_st_target USING btree (st_sch_seq);

