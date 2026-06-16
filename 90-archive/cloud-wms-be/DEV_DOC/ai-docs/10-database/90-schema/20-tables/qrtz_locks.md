# qrtz_locks (Quartz_락)

## 1. 개요
클러스터 환경에서 스케줄러 노드 간 비관적 락(pessimistic lock)을 관리하는 테이블. DB 행 수준 잠금(`SELECT FOR UPDATE`)으로 동시성을 제어.

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | sched_name | varchar(120) | N | | 스케줄러 인스턴스 이름 |
| PK | lock_name | varchar(40) | N | | 락 이름 (TRIGGER_ACCESS / STATE_ACCESS) |

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| qrtz_locks_pkey | sched_name, lock_name | Y | Y |

## 4. 업무 규칙
- Quartz 프레임워크 내부 관리 테이블 — 직접 INSERT/UPDATE 금지
- 초기 데이터: `TRIGGER_ACCESS`, `STATE_ACCESS` 두 행이 미리 삽입되어 있어야 함
- `quartz.scheduler.rdbms = true` 설정 시에만 이 테이블이 활성화됨
- WMS는 현재 `quartz.scheduler.rdbms = false` (메모리 기반)이므로 비어 있음

## 5. 관계

없음 (독립 테이블)
