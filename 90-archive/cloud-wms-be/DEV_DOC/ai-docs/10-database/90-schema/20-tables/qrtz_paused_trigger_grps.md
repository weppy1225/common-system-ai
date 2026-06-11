# qrtz_paused_trigger_grps (Quartz_일시중지_트리거그룹)

## 1. 개요
일시 중지된 트리거 그룹 목록을 저장. 그룹 단위로 트리거를 일괄 정지(pause)/재개(resume)할 때 사용.

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | sched_name | varchar(120) | N | | 스케줄러 인스턴스 이름 |
| PK | trigger_group | varchar(200) | N | | 일시 중지된 트리거 그룹명 |

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| qrtz_paused_trigger_grps_pkey | sched_name, trigger_group | Y | Y |

## 4. 업무 규칙
- Quartz 프레임워크 내부 관리 테이블 — 직접 INSERT/UPDATE 금지
- 행이 존재하는 그룹의 트리거는 실행되지 않음
- `scheduler.pauseTriggerGroup()` 호출 시 삽입, `resumeTriggerGroup()` 호출 시 삭제

## 5. 관계

없음 (독립 테이블)
