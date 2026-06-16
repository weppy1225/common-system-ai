# qrtz_triggers (Quartz_트리거)

## 1. 개요
Quartz 스케줄러의 모든 트리거 기본 정보를 저장하는 테이블. 트리거 유형(CRON, SIMPLE 등)에 따라 각 서브 테이블과 조합된다.

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | sched_name | varchar(120) | N | | 스케줄러 인스턴스 이름 |
| PK | trigger_name | varchar(200) | N | | 트리거 이름 |
| PK | trigger_group | varchar(200) | N | | 트리거 그룹 |
| FK | job_name | varchar(200) | N | | 잡 이름 (→ qrtz_job_details) |
| FK | job_group | varchar(200) | N | | 잡 그룹 (→ qrtz_job_details) |
| | description | varchar(250) | Y | | 설명 |
| | next_fire_time | bigint | Y | | 다음 실행 시각 (Unix ms) |
| | prev_fire_time | bigint | Y | | 이전 실행 시각 (Unix ms) |
| | priority | integer | Y | | 우선순위 |
| | trigger_state | varchar(16) | N | | 상태 (WAITING/ACQUIRED/EXECUTING/BLOCKED/PAUSED/COMPLETE/ERROR) |
| | trigger_type | varchar(8) | N | | 유형 (CRON/SIMPLE/BLOB/CAL_INT 등) |
| | start_time | bigint | N | | 시작 시각 (Unix ms) |
| | end_time | bigint | Y | | 종료 시각 (Unix ms) |
| | calendar_name | varchar(200) | Y | | 캘린더 이름 |
| | misfire_instr | smallint | Y | | Misfire 처리 정책 |
| | job_data | bytea | Y | | 트리거별 JobDataMap |

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| qrtz_triggers_pkey | sched_name, trigger_name, trigger_group | Y | Y |
| idx_qrtz_t_c | sched_name, calendar_name | N | N |
| idx_qrtz_t_g | sched_name, trigger_group | N | N |
| idx_qrtz_t_j | sched_name, job_name, job_group | N | N |
| idx_qrtz_t_jg | sched_name, job_group | N | N |

## 4. 업무 규칙
- Quartz 프레임워크 내부 관리 테이블 — 직접 INSERT/UPDATE 금지
- `trigger_type`에 따라 서브 테이블과 조인: `CRON`→qrtz_cron_triggers, `SIMPLE`→qrtz_simple_triggers, `BLOB`→qrtz_blob_triggers
- `next_fire_time`이 null이면 더 이상 실행 예정 없음

## 5. 관계

| 구분 | 테이블 | 컬럼 |
|---|---|---|
| 참조 | qrtz_job_details | sched_name, job_name, job_group |
| 참조됨 | qrtz_cron_triggers | sched_name, trigger_name, trigger_group |
| 참조됨 | qrtz_simple_triggers | sched_name, trigger_name, trigger_group |
| 참조됨 | qrtz_simprop_triggers | sched_name, trigger_name, trigger_group |
| 참조됨 | qrtz_blob_triggers | sched_name, trigger_name, trigger_group |
| 참조됨 | qrtz_fired_triggers | sched_name, trigger_name, trigger_group |
