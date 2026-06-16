# qrtz_cron_triggers (Quartz_크론_트리거)

## 1. 개요
CRON 표현식 기반 트리거 정보를 저장하는 테이블. `qrtz_triggers`의 `trigger_type = 'CRON'` 행과 1:1 대응.

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK/FK | sched_name | varchar(120) | N | | 스케줄러 인스턴스 이름 |
| PK/FK | trigger_name | varchar(200) | N | | 트리거 이름 |
| PK/FK | trigger_group | varchar(200) | N | | 트리거 그룹 |
| | cron_expression | varchar(120) | N | | Cron 표현식 (예: `0 0/30 * * * ?`) |
| | time_zone_id | varchar(80) | Y | | 시간대 (예: `Asia/Seoul`) |

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| qrtz_cron_triggers_pkey | sched_name, trigger_name, trigger_group | Y | Y |

## 4. 업무 규칙
- Quartz 프레임워크 내부 관리 테이블 — 직접 INSERT/UPDATE 금지
- WMS에서 스케줄 등록 시 `QuartzConfig.java`의 CronTrigger로 자동 삽입됨
- `time_zone_id` 미설정 시 JVM 기본 시간대 사용

## 5. 관계

| 구분 | 테이블 | 컬럼 |
|---|---|---|
| 참조 | qrtz_triggers | sched_name, trigger_name, trigger_group |
