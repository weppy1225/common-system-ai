---
title: 시스템 관리 테이블 정의서
description: WMS 시스템 관리(sm_*) 테이블 목록과 공통 컬럼 규칙을 확인할 때 읽는다
status: active
version: 1.0.0
repo_role: ai-hub
agent_usage: instruction
domain: database
tags:
  - database
  - table
  - system
  - sm
  - schema
---

# 시스템 관리 테이블 정의서 (System Management Table Definition)

> - DB: PostgreSQL / Schema: public
> - 테이블 prefix: `sm_`
> - 공통 규칙: 삭제는 `use_yn = 'N'` 처리 (물리삭제 없음), 등록/수정 이력 컬럼 모든 테이블 공통 포함

---

## 1. 테이블 목록

| 테이블명 | 설명 |
|---|---|
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
| sm_push_cycle | 시스템_푸시_주기 |
| sm_push_history | 시스템_푸시_이력 |
| sm_push_unrcv | 시스템_푸시_미수신(NEW) |
| sm_qrtz_change_log | 시스템_쿼츠_변경_이력 |
| sm_qrtz_exec_log | 시스템_쿼츠_실행_이력 |
| sm_qrtz_job_state | 시스템_쿼츠_작업_현황(NEW) |
| sm_user_pwd_history | 시스템_비밀번호_변경_이력(NEW) |

---

## 2. 공통 컬럼 (모든 테이블 포함)

| 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|
| use_yn | char(1) | N | 'Y' | 사용 여부 ('N'이면 삭제된 데이터) |
| reg_id | varchar(20) | N | | 등록 ID |
| reg_dt | timestamp | N | now() | 등록 일시 |
| mod_id | varchar(20) | Y | | 수정 ID |
| mod_dt | timestamp | Y | | 수정 일시 |
