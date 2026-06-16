# qrtz_simple_triggers (Quartz_단순_트리거)

## 1. 개요
고정 횟수 또는 고정 간격으로 실행되는 SimpleSchedule 트리거 정보를 저장. `qrtz_triggers`의 `trigger_type = 'SIMPLE'` 행과 1:1 대응.

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK/FK | sched_name | varchar(120) | N | | 스케줄러 인스턴스 이름 |
| PK/FK | trigger_name | varchar(200) | N | | 트리거 이름 |
| PK/FK | trigger_group | varchar(200) | N | | 트리거 그룹 |
| | repeat_count | bigint | N | | 반복 횟수 (-1 = 무한) |
| | repeat_interval | bigint | N | | 반복 간격 (밀리초) |
| | times_triggered | bigint | N | | 누적 실행 횟수 |

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| qrtz_simple_triggers_pkey | sched_name, trigger_name, trigger_group | Y | Y |

## 4. 업무 규칙
- Quartz 프레임워크 내부 관리 테이블 — 직접 INSERT/UPDATE 금지
- `repeat_count = -1`: 무한 반복
- `repeat_interval`: ms 단위 (예: 60000 = 1분 간격)

## 5. 관계

| 구분 | 테이블 | 컬럼 |
|---|---|---|
| 참조 | qrtz_triggers | sched_name, trigger_name, trigger_group |
