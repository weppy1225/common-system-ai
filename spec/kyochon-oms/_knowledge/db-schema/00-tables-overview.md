---
title: kyochon-oms 테이블 목록 및 설명
description: kyochon-oms 전체 테이블 목록과 도메인별 그룹을 확인할 때 읽는다
status: active
version: 1.0.0
repo_role: ai-hub
agent_usage: instruction
project: kyochon-oms
domain: database
tags:
  - database
  - table
  - schema
  - oms
last_verified: 2026-06-23
---

# kyochon-oms 테이블 목록 및 설명

> 숨은 전제: OMS=PostgreSQL, ERP=SQL Server 멀티 DB (근거: `spec/kyochon-oms/_knowledge/install-guide/01-startup-guide.md`).
> 출처: 실 OMS(PostgreSQL) dev DB `public` 스키마 `pg_class` 조회 (2026-06-23, 총 126개 테이블). 테이블 설명은 **DB comment 원본**이다. comment 미설정 테이블은 설명을 빈칸으로 둔다(추정 금지).
> 그룹별 테이블 정의서는 `01-*.md` ~ `05-*.md` 로 분리한다. 공통코드 값은 `90-common-code.md` 참조. 컬럼 단위 상세는 실 스키마(`\d <테이블>`)를 우선 확인한다(본 문서는 테이블 목록·설명 수준).
> DB 변경·반영 이력은 [00-database-deploy-history.md](./00-database-deploy-history.md) 참조.

## 1. 테이블 그룹 (도메인별)

| 그룹 | 접두어/규칙 | 테이블 수 | 상세 문서 |
|---|---|---|---|
| 기준정보(MDM) | `mdm_*` | 19 | [01-mdm-tables.md](./01-mdm-tables.md) |
| OMS 업무(주문·단가·배정·배송·거래) | `oms_*` | 32 | [02-oms-tables.md](./02-oms-tables.md) |
| 쇼핑몰 | `shop_*` | 13 | [03-shop-tables.md](./03-shop-tables.md) |
| 시스템·로그·메뉴·공통코드 | `sm_*` | 22 | [04-system-tables.md](./04-system-tables.md) |
| 스케줄러(Quartz) | `qrtz_*` | 11 | [04-system-tables.md](./04-system-tables.md) |
| 인터페이스·가상계좌·기타 | `sif_*`·`vacs_*`·`ideatec_*` | 6 | [05-interface-tables.md](./05-interface-tables.md) |
| 공통코드 값 | `sm_comm_h`/`sm_comm_d` | 89 헤더 | [90-common-code.md](./90-common-code.md) |
| 작업·임시·백업 테이블 | `*_temp`·`*_tmp`·`*_bak`·`delete_*`·`prod_*` | 23 | (정본 아님) |

## 2. 기준정보 테이블 (mdm_*)

| 테이블명 | 테이블 설명 |
|---|---|
| mdm_biz | MDM_사업장 |
| mdm_biz_biz | MDM_사업장_사업장 |
| mdm_biz_center | MDM_사업장_센터 |
| mdm_biz_cont | MDM_사업장_거래처 |
| mdm_biz_prod | MDM_사업장_품목 |
| mdm_biz_wh | MDM_사업장_창고 |
| mdm_center | MDM_센터 |
| mdm_cont | MDM_거래처 |
| mdm_cont_account | MDM_거래처_가상계좌 |
| mdm_cont_logi | MDM_거래처_물류 |
| mdm_cont_prod | MDM_거래처_품목 |
| mdm_area_prod | MDM_권역_품목(비노출) |
| mdm_prod | MDM_품목 |
| mdm_wh | MDM_창고 |
| mdm_loc | MDM_위치 |
| mdm_doc_no | MDM_문서번호 |
| mdm_user | MDM_사용자 |
| mdm_user_biz | MDM_권한사업장 |
| mdm_user_center | MDM_권한센터 |

## 3. OMS 업무 테이블 (oms_*)

| 테이블명 | 테이블 설명 |
|---|---|
| oms_order | OMS_주문 |
| oms_order_prod | OMS_주문_품목 |
| oms_order_prod_hist | OMS_주문_품목_이력 |
| oms_order_return | OMS_반품 |
| oms_price_base | OMS_단가_기준 |
| oms_price_prod | OMS_단가_품목 |
| oms_price_history | OMS_단가_이력 |
| oms_allocate_area | OMS_배정_권역 |
| oms_allocate_center | OMS_배정_센터 |
| oms_allocate_cont_avg | OMS_배정_가맹점_평균 |
| oms_delivery_area | OMS_배송요일_권역 |
| oms_delivery_area_period | OMS_배송요일_권역_기간 |
| oms_delivery_cont | OMS_배송요일_거래처 |
| oms_leadtime | OMS_리드타임 |
| oms_leadtime_area | OMS_리드타임_권역별 |
| oms_leadtime_cont | OMS_리드타임_거래처 |
| oms_cont_credit | OMS_가맹점_여신 |
| oms_cont_day_tran | OMS_가맹점_거래내역 |
| oms_cont_month_tran | OMS_가맹점_월간_거래내역 |
| oms_cont_holiday | OMS_가맹점_휴일 |
| oms_manual_tran | OMS_수기_거래내역 |
| oms_manual_tran_history | OMS_수기_거래내역_이력 |
| oms_deadline_edit | OMS_마감일시_변경 |
| oms_deadline_edit_cont | OMS_마감일시_변경_거래처 |
| oms_st_prod | OMS_세트_품목 |
| oms_st_prod_dtl | OMS_세트_품목_상세 |
| oms_replace_prod | OMS_대체_품목 |
| oms_replace_prod_cont | |
| oms_favorite | OMS_즐겨찾기 |
| oms_favorite_prod | OMS_즐겨찾기_품목 |
| oms_ad_price_settle | OMS_광고_비용_정산 |
| oms_ad_price_settle_cont | OMS_광고_비용_정산_거래처 |

## 4. 쇼핑몰 테이블 (shop_*)

| 테이블명 | 테이블 설명 |
|---|---|
| shop_prod | 쇼핑몰_상품 |
| shop_prod_opt | 쇼핑몰_상품_옵션 |
| shop_prod_price_hist | 쇼핑몰_상품_단가_이력 |
| shop_cart | 쇼핑몰_장바구니 |
| shop_cart_opt | 쇼핑몰_장바구니_옵션 |
| shop_order | 쇼핑몰_주문 |
| shop_order_prod | 쇼핑몰_주문_상품 |
| shop_order_prod_opt | 쇼핑몰_주문_상품_옵션 |
| shop_order_prod_sts_hist | 쇼핑몰_주문_상품_상태_이력 |
| shop_cont | 쇼핑몰_제작업체 |
| shop_draft | 쇼핑몰_시안 |
| shop_draft_file | 쇼핑몰_시안_파일 |
| shop_agree | 쇼핑몰_동의서 |

## 5. 시스템 테이블 (sm_*)

| 테이블명 | 테이블 설명 |
|---|---|
| sm_menu | 시스템_메뉴 |
| sm_menu_group | 시스템_메뉴_그룹 |
| sm_menu_opt_config | 시스템_메뉴_옵션_설정 |
| sm_group | 시스템_그룹 |
| sm_comm_h | 시스템_공통코드 |
| sm_comm_d | 시스템_공통코드_상세 |
| sm_biz_config | 시스템_사업장_설정 |
| sm_board | 시스템_게시판 |
| sm_file | 시스템_파일 |
| sm_file_req | 시스템_파일_업무 |
| sm_alarm_cycle | 시스템_알람_주기 |
| sm_alarm_unrcv | 시스템_알람_미수신 |
| sm_user_pwd_history | 시스템_비밀번호_변경_이력 |
| sm_log_api | 시스템_로그_API |
| sm_log_conn | 시스템_로그_접근 |
| sm_log_conn_dtl | 시스템_로그_접근_상세 |
| sm_log_error | 시스템_로그_에러 |
| sm_log_menu | 시스템_로그_메뉴접근 |
| sm_log_alarm | |
| sm_qrtz_change_log | 시스템_쿼츠_변경_이력 |
| sm_qrtz_exec_log | 시스템_쿼츠_실행_이력 |
| sm_qrtz_job_state | 시스템_쿼츠_작업_현황 |

## 6. 스케줄러 테이블 (qrtz_*)

> Quartz Scheduler 엔진 표준 테이블. comment 미설정.

| 테이블명 | 테이블 설명 |
|---|---|
| qrtz_job_details | |
| qrtz_triggers | |
| qrtz_simple_triggers | |
| qrtz_cron_triggers | |
| qrtz_simprop_triggers | |
| qrtz_blob_triggers | |
| qrtz_calendars | |
| qrtz_paused_trigger_grps | |
| qrtz_fired_triggers | |
| qrtz_scheduler_state | |
| qrtz_locks | |

## 7. 인터페이스·가상계좌·기타 테이블 (sif_*·vacs_*·ideatec_*)

| 테이블명 | 테이블 설명 |
|---|---|
| sif_batch_history | SIF_배치_이력 |
| vacs_ahst | 가상계좌_거래내역_원장 |
| vacs_vact | |
| vacs_totl | |
| vacs_errlog | |
| ideatec_history | 이데아텍_이력 |

## 8. 작업·임시·백업 테이블 (정본 아님)

> comment 미설정 작업/임시/백업 테이블. 업무 정본이 아니므로 설계 참조 대상에서 제외한다.

| 테이블명 | 비고 |
|---|---|
| delete_logi_temp | 임시 |
| prod_price_temp | 임시 |
| mdm_cont_temp | 임시 |
| mdm_cont_bak | 백업 |
| mdm_cont_account_bak | 백업 |
| mdm_cont_logi_temp | 임시 |
| mdm_cont_prod_temp | 임시 |
| mdm_prod_temp | 임시 |
| mdm_user_temp | 임시 |
| oms_order_temp | 임시 |
| oms_order_tmp | 임시 |
| oms_order_tmp1 | 임시 |
| oms_order_tmp2 | 임시 |
| oms_order_tmp3 | 임시 |
| oms_order_prod_temp | 임시 |
| oms_order_prod_tmp | 임시 |
| oms_allocate_cont_avg_temp | 임시 |
| oms_delivery_cont_temp | 임시 |
| oms_price_base_temp | 임시 |
| oms_price_base_bak | 백업 |
| oms_price_prod_temp | 임시 |
| oms_price_prod_bak | 백업 |
| sm_comm_d_temp | 임시 |
