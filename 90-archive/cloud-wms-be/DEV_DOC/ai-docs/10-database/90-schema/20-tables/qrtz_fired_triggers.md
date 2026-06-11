# qrtz_fired_triggers (Quartz_실행중_트리거)

## 1. 개요
현재 실행 중이거나 획득(ACQUIRED)된 트리거의 실행 상태를 추적하는 테이블. 클러스터 환경에서 노드 간 실행 충돌 방지에 사용.

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | sched_name | varchar(120) | N | | 스케줄러 인스턴스 이름 |
| PK | entry_id | varchar(95) | N | | 실행 항목 고유 ID |
| | trigger_name | varchar(200) | N | | 트리거 이름 |
| | trigger_group | varchar(200) | N | | 트리거 그룹 |
| | instance_name | varchar(200) | N | | 실행 중인 스케줄러 인스턴스명 |
| | fired_time | bigint | N | | 실행 시작 시각 (Unix ms) |
| | sched_time | bigint | N | | 예정 실행 시각 (Unix ms) |
| | priority | integer | N | | 우선순위 |
| | state | varchar(16) | N | | 실행 상태 (ACQUIRED/EXECUTING/BLOCKED 등) |
| | job_name | varchar(200) | Y | | 잡 이름 |
| | job_group | varchar(200) | Y | | 잡 그룹 |
| | is_nonconcurrent | boolean | Y | | 동시 실행 금지 여부 |
| | requests_recovery | boolean | Y | | 복구 요청 여부 |

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| qrtz_fired_triggers_pkey | sched_name, entry_id | Y | Y |
| idx_qrtz_ft_inst_job_req_rcvry | sched_name, instance_name, requests_recovery | N | N |
| idx_qrtz_ft_j_g | sched_name, job_name, job_group | N | N |
| idx_qrtz_ft_jg | sched_name, job_group | N | N |
| idx_qrtz_ft_t_g | sched_name, trigger_name, trigger_group | N | N |
| idx_qrtz_ft_tg | sched_name, trigger_group | N | N |
| idx_qrtz_ft_trig_inst_name | sched_name, instance_name | N | N |

## 4. 업무 규칙
- Quartz 프레임워크 내부 관리 테이블 — 직접 INSERT/UPDATE 금지
- 정상 종료 시 실행 완료된 행은 자동 삭제됨
- 비정상 종료(서버 크래시) 후 행이 남아있으면 Quartz가 복구 처리
- `requests_recovery = true`인 Job은 복구 시 재실행됨

## 5. 관계

| 구분 | 테이블 | 컬럼 |
|---|---|---|
| 논리적 참조 | qrtz_triggers | sched_name, trigger_name, trigger_group |
| 논리적 참조 | qrtz_job_details | sched_name, job_name, job_group |
