# qrtz_blob_triggers (Quartz_Blob_트리거)

## 1. 개요
Java 직렬화(bytea)로 저장된 사용자 정의 트리거 데이터를 보관. 표준 CRON/SIMPLE 외의 커스텀 트리거 구현 시 사용.

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK/FK | sched_name | varchar(120) | N | | 스케줄러 인스턴스 이름 |
| PK/FK | trigger_name | varchar(200) | N | | 트리거 이름 |
| PK/FK | trigger_group | varchar(200) | N | | 트리거 그룹 |
| | blob_data | bytea | Y | | 직렬화된 트리거 객체 |

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| qrtz_blob_triggers_pkey | sched_name, trigger_name, trigger_group | Y | Y |

## 4. 업무 규칙
- Quartz 프레임워크 내부 관리 테이블 — 직접 INSERT/UPDATE 금지
- WMS에서는 커스텀 트리거를 사용하지 않으므로 이 테이블은 항상 비어 있음

## 5. 관계

| 구분 | 테이블 | 컬럼 |
|---|---|---|
| 참조 | qrtz_triggers | sched_name, trigger_name, trigger_group |
