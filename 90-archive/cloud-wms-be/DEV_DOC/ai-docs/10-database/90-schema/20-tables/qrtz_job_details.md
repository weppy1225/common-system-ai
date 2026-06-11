# qrtz_job_details (Quartz_잡_상세)

## 1. 개요
Quartz 스케줄러가 실행할 Job의 메타정보를 저장하는 핵심 테이블. Job 클래스명, 직렬화된 JobDataMap 등을 보관한다.

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | sched_name | varchar(120) | N | | 스케줄러 인스턴스 이름 |
| PK | job_name | varchar(200) | N | | 잡 이름 |
| PK | job_group | varchar(200) | N | | 잡 그룹 |
| | description | varchar(250) | Y | | 설명 |
| | job_class_name | varchar(250) | N | | 잡 구현 클래스명 |
| | is_durable | boolean | N | | 트리거 없어도 유지 여부 |
| | is_nonconcurrent | boolean | N | | 동시 실행 금지 여부 |
| | is_update_data | boolean | N | | 실행 후 JobDataMap 갱신 여부 |
| | requests_recovery | boolean | N | | 복구 실행 요청 여부 |
| | job_data | bytea | Y | | 직렬화된 JobDataMap |

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| qrtz_job_details_pkey | sched_name, job_name, job_group | Y | Y |
| idx_qrtz_j_grp | sched_name, job_group | N | N |
| idx_qrtz_j_req_recovery | sched_name, requests_recovery | N | N |

## 4. 업무 규칙
- Quartz 프레임워크 내부 관리 테이블 — 직접 INSERT/UPDATE 금지
- `is_durable = true`: 연결된 트리거가 없어도 Job이 삭제되지 않음
- `is_nonconcurrent = true`: 같은 Job이 동시에 실행되지 않음 (`@DisallowConcurrentExecution`)
- `job_data`는 Java 직렬화(bytea) 형태로 저장됨
- WMS에서는 `QuartzConfig.java`를 통해 Job 등록

## 5. 관계

| 구분 | 테이블 | 컬럼 |
|---|---|---|
| 참조됨 | qrtz_triggers | sched_name, job_name, job_group |
