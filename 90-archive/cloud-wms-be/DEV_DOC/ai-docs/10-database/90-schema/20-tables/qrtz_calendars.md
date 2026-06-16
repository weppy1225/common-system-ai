# qrtz_calendars (Quartz_캘린더)

## 1. 개요
트리거 실행에서 제외할 날짜/시간 구간을 정의하는 캘린더 정보를 저장. 공휴일 제외 스케줄 등에 활용.

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | sched_name | varchar(120) | N | | 스케줄러 인스턴스 이름 |
| PK | calendar_name | varchar(200) | N | | 캘린더 이름 |
| | calendar | bytea | N | | 직렬화된 Calendar 객체 |

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| qrtz_calendars_pkey | sched_name, calendar_name | Y | Y |

## 4. 업무 규칙
- Quartz 프레임워크 내부 관리 테이블 — 직접 INSERT/UPDATE 금지
- WMS에서 캘린더를 별도 설정하지 않는 경우 이 테이블은 비어 있음
- `qrtz_triggers.calendar_name`에서 참조됨

## 5. 관계

| 구분 | 테이블 | 컬럼 |
|---|---|---|
| 참조됨 | qrtz_triggers | calendar_name |
