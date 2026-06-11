# qrtz_scheduler_state (Quartz_스케줄러_상태)

## 1. 개요
클러스터 내 각 스케줄러 인스턴스의 생존 상태(heartbeat)를 추적하는 테이블. 노드 장애 감지 및 고아 트리거 복구에 사용.

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | sched_name | varchar(120) | N | | 스케줄러 인스턴스 이름 |
| PK | instance_name | varchar(200) | N | | 노드 인스턴스 ID |
| | last_checkin_time | bigint | N | | 마지막 heartbeat 시각 (Unix ms) |
| | checkin_interval | bigint | N | | heartbeat 주기 (ms) |

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| qrtz_scheduler_state_pkey | sched_name, instance_name | Y | Y |

## 4. 업무 규칙
- Quartz 프레임워크 내부 관리 테이블 — 직접 INSERT/UPDATE 금지
- `quartz.scheduler.rdbms = true` 설정 시에만 활성화됨
- `last_checkin_time`이 `checkin_interval × 2` 이상 경과한 인스턴스는 장애로 간주
- WMS는 현재 `quartz.scheduler.rdbms = false`이므로 비어 있음

## 5. 관계

없음 (독립 테이블)
