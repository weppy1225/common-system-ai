---
title: kyochon-oms 시스템·스케줄러 테이블 정의서
description: kyochon-oms 시스템 관리(sm_*) 및 스케줄러(qrtz_*) 테이블 목록과 공통 컬럼을 확인할 때 읽는다
status: active
version: 1.0.0
repo_role: ai-hub
agent_usage: instruction
project: kyochon-oms
domain: database
tags:
  - database
  - table
  - system
  - sm
  - quartz
  - schema
last_verified: 2026-06-23
---

# kyochon-oms 시스템·스케줄러 테이블 정의서

> - DB: PostgreSQL / Schema: public
> - 테이블 prefix: `sm_`(시스템 관리) · `qrtz_`(Quartz 스케줄러 엔진 표준)
> - 출처: 실 OMS dev DB `pg_class` 조회 (2026-06-23). 설명은 DB comment 원본.
> - 공통코드 값(sm_comm_h/sm_comm_d)은 별도 문서 → [90-common-code.md](./90-common-code.md).

---

## 1. 시스템 관리 테이블 (sm_*)

| 테이블명 | 설명 |
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
| sm_log_alarm | (DB comment 미설정) |
| sm_qrtz_change_log | 시스템_쿼츠_변경_이력 |
| sm_qrtz_exec_log | 시스템_쿼츠_실행_이력 |
| sm_qrtz_job_state | 시스템_쿼츠_작업_현황 |

## 2. 스케줄러 테이블 (qrtz_*)

> Quartz Scheduler 엔진 표준 테이블. DB comment 미설정, 감사 컬럼 비적용.

| 테이블명 |
|---|
| qrtz_job_details |
| qrtz_triggers |
| qrtz_simple_triggers |
| qrtz_cron_triggers |
| qrtz_simprop_triggers |
| qrtz_blob_triggers |
| qrtz_calendars |
| qrtz_paused_trigger_grps |
| qrtz_fired_triggers |
| qrtz_scheduler_state |
| qrtz_locks |

---

## 3. 공통 컬럼 (sm_* 감사 컬럼)

> soft-delete 플래그(`use_yn`/`del_yn`)는 테이블마다 존재 여부가 다르다. 로그(`sm_log_*`) 테이블은 감사 컬럼 일부만 보유할 수 있다. 컬럼 단위 상세는 실 스키마(`\d sm_*`)를 우선 확인한다.

| 컬럼명 | 타입 | NULL | 설명 |
|---|---|---|---|
| reg_id | varchar(20) | N | 등록 ID |
| reg_dt | timestamp | N | 등록 일시 |
| mod_id | varchar(20) | Y | 수정 ID |
| mod_dt | timestamp | Y | 수정 일시 |
