# qrtz_simprop_triggers (Quartz_속성_트리거)

## 1. 개요
CalendarInterval, DailyTimeInterval 등 확장 트리거 유형의 추가 속성값을 저장. `qrtz_triggers`의 `trigger_type = 'CAL_INT'` 등과 1:1 대응.

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK/FK | sched_name | varchar(120) | N | | 스케줄러 인스턴스 이름 |
| PK/FK | trigger_name | varchar(200) | N | | 트리거 이름 |
| PK/FK | trigger_group | varchar(200) | N | | 트리거 그룹 |
| | str_prop_1 | varchar(512) | Y | | 문자열 속성 1 |
| | str_prop_2 | varchar(512) | Y | | 문자열 속성 2 |
| | str_prop_3 | varchar(512) | Y | | 문자열 속성 3 |
| | int_prop_1 | integer | Y | | 정수 속성 1 |
| | int_prop_2 | integer | Y | | 정수 속성 2 |
| | long_prop_1 | bigint | Y | | Long 속성 1 |
| | long_prop_2 | bigint | Y | | Long 속성 2 |
| | dec_prop_1 | numeric(13,4) | Y | | Decimal 속성 1 |
| | dec_prop_2 | numeric(13,4) | Y | | Decimal 속성 2 |
| | bool_prop_1 | boolean | Y | | Boolean 속성 1 |
| | bool_prop_2 | boolean | Y | | Boolean 속성 2 |

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| qrtz_simprop_triggers_pkey | sched_name, trigger_name, trigger_group | Y | Y |

## 4. 업무 규칙
- Quartz 프레임워크 내부 관리 테이블 — 직접 INSERT/UPDATE 금지
- 속성 컬럼은 트리거 유형에 따라 의미가 달라짐 (Quartz 내부 매핑)
- WMS에서는 주로 CRON/SIMPLE 트리거를 사용하므로 이 테이블은 거의 사용되지 않음

## 5. 관계

| 구분 | 테이블 | 컬럼 |
|---|---|---|
| 참조 | qrtz_triggers | sched_name, trigger_name, trigger_group |
