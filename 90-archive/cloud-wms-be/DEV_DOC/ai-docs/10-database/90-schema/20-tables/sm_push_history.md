# sm_push_history (시스템_푸시_이력)

## 1. 개요
**푸시 알림 발송 이력**을 관리하는 테이블.
발송된 푸시 메시지의 내용, 발송 시간, 수신자, 확인 여부 등을 저장하여 푸시 알림 모니터링 및 추적에 활용한다.

### 1.1 푸시 이력 흐름
```
푸시 발송 조건 충족 → sm_push_history 저장 → 사용자 디바이스로 푸시 전송 → 사용자 확인 시 확인 시간 업데이트
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | push_history_seq | bigint | N | nextval('sm_push_history_seq') | 푸시 이력 SEQ |
| | push_cycle_seq | integer | Y | nextval('mdm_prod_seq') | 푸시 주기 SEQ |
| | biz_seq | integer | N | | 사업장 SEQ |
| | center_seq | integer | N | | 센터 SEQ |
| | group_seq | integer | N | | 그룹 SEQ |
| | push_type_cd | varchar(50) | N | | 푸시 유형 코드 |
| | push_message | varchar(1000) | N | | 푸시 내용 |
| | send_dt | timestamp | N | | 보낸 일시 |
| | prod_seq | integer | Y | nextval('mdm_prod_seq') | 품목 SEQ |
| | req_no | varchar(30) | Y | | 업무 번호 |
| | cfm_dt | timestamp | Y | | 확인 일시 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

> **push_type_cd** (`PUSH_TYPE_CD`)
>
> | 코드 | 코드명 | 설명 |
> |---|---|---|
> | 1 | 알람 | 일반 알람 푸시 |

> **push_cycle_seq** - sm_push_cycle 참조 (자동 발송인 경우)
> **prod_seq** - mdm_prod 참조 (품목 관련 푸시인 경우)

---

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| sm_push_history_PK | push_history_seq | Y | Y |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| push_history_seq | sm_push_history_seq |
| push_cycle_seq | sm_push_cycle_seq (기본값은 mdm_prod_seq 사용) |
| prod_seq | mdm_prod_seq (기본값) |

---

## 5. 업무 규칙

### 5.1 푸시 이력 기록
- 푸시 알림 발송 시 자동으로 이력 저장
- 수동 발송, 자동 발송 모두 기록

### 5.2 발송 정보

| 필드 | 설명 | 비고 |
|------|------|------|
| push_cycle_seq | 자동 발송인 경우 주기 설정 참조 | 수동 발송 시 NULL |
| push_type_cd | 푸시 유형 | '1': 알람 |
| push_message | 실제 발송된 메시지 내용 | 템플릿 변환 후 저장 |
| send_dt | 발송 일시 | 푸시 전송 시간 |

### 5.3 수신자 정보

| 필드 | 설명 | 비고 |
|------|------|------|
| biz_seq | 사업장 | 수신자 소속 사업장 |
| center_seq | 센터 | 수신자 소속 센터 |
| group_seq | 그룹 | 수신자 소속 그룹 |

### 5.4 관련 업무 정보

| 필드 | 설명 | 예시 |
|------|------|------|
| prod_seq | 관련 품목 | 재고 부족 알림 시 품목 |
| req_no | 관련 업무 번호 | 출하번호, 입고번호 등 |

### 5.5 확인 여부
- `cfm_dt`: 사용자가 푸시를 확인(클릭)한 시간
- NULL인 경우 미확인
- 푸시 수신 확인율 분석에 활용

### 5.6 보존 기간
- 푸시 이력은 일정 기간 보관 (로그 정책에 따라)
- 오래된 이력은 별도 백업 후 삭제 가능

---

## 6. 주요 조회 예시

```sql
-- 최근 푸시 발송 이력
SELECT push_history_seq, biz_seq, center_seq, group_seq,
       push_type_cd, push_message, send_dt, cfm_dt,
       prod_seq, req_no
FROM sm_push_history
ORDER BY send_dt DESC
LIMIT 100;

-- 특정 사용자 그룹의 푸시 이력
SELECT ph.*
FROM sm_push_history ph
WHERE ph.biz_seq = 1
AND ph.group_seq = 10
ORDER BY ph.send_dt DESC;

-- 특정 센터의 푸시 이력
SELECT ph.*
FROM sm_push_history ph
WHERE ph.biz_seq = 1
AND ph.center_seq = 1
ORDER BY ph.send_dt DESC;

-- 확인되지 않은 푸시 조회
SELECT push_history_seq, push_message, send_dt,
       EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - send_dt)) / 3600 AS hours_ago
FROM sm_push_history
WHERE cfm_dt IS NULL
AND send_dt >= CURRENT_DATE - INTERVAL '7 days'
ORDER BY send_dt DESC;

-- 일자별 푸시 발송 현황
SELECT DATE(send_dt) AS push_date,
       COUNT(*) AS push_cnt,
       SUM(CASE WHEN cfm_dt IS NOT NULL THEN 1 ELSE 0 END) AS confirm_cnt,
       ROUND(SUM(CASE WHEN cfm_dt IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS confirm_rate
FROM sm_push_history
WHERE send_dt >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(send_dt)
ORDER BY push_date DESC;

-- 푸시 유형별 통계
SELECT push_type_cd,
       COUNT(*) AS total_cnt,
       COUNT(DISTINCT biz_seq || '-' || center_seq || '-' || group_seq) AS target_cnt,
       AVG(EXTRACT(EPOCH FROM (cfm_dt - send_dt))) AS avg_confirm_sec
FROM sm_push_history
WHERE send_dt >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY push_type_cd
ORDER BY push_type_cd;

-- 시간대별 푸시 발송 집계
SELECT EXTRACT(HOUR FROM send_dt) AS hour,
       COUNT(*) AS push_cnt
FROM sm_push_history
WHERE send_dt >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY EXTRACT(HOUR FROM send_dt)
ORDER BY hour;

-- 품목 관련 푸시 이력
SELECT ph.push_history_seq, ph.push_message, ph.send_dt,
       p.prod_nm, p.prod_no
FROM sm_push_history ph
    LEFT JOIN mdm_prod p ON ph.prod_seq = p.prod_seq
WHERE ph.prod_seq IS NOT NULL
AND ph.send_dt >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY ph.send_dt DESC;

-- 업무 번호별 푸시 이력
SELECT req_no,
       COUNT(*) AS push_cnt,
       MIN(send_dt) AS first_push,
       MAX(send_dt) AS last_push
FROM sm_push_history
WHERE req_no IS NOT NULL
AND send_dt >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY req_no
ORDER BY push_cnt DESC;

-- 주기 설정별 발송 이력
SELECT pc.push_cycle_seq, pc.push_note AS setting_note,
       COUNT(ph.push_history_seq) AS push_cnt,
       MIN(ph.send_dt) AS first_send,
       MAX(ph.send_dt) AS last_send
FROM sm_push_cycle pc
    LEFT JOIN sm_push_history ph ON pc.push_cycle_seq = ph.push_cycle_seq
WHERE pc.biz_seq = 1
AND ph.send_dt >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY pc.push_cycle_seq, pc.push_note
ORDER BY pc.push_cycle_seq;

-- 사업장별 푸시 발송 현황
SELECT ph.biz_seq, b.biz_nm,
       COUNT(*) AS push_cnt,
       COUNT(DISTINCT ph.center_seq) AS center_cnt,
       COUNT(DISTINCT ph.group_seq) AS group_cnt
FROM sm_push_history ph
    JOIN mdm_biz b ON ph.biz_seq = b.biz_seq
WHERE ph.send_dt >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY ph.biz_seq, b.biz_nm
ORDER BY push_cnt DESC;

-- 그룹별 확인율 분석
SELECT ph.group_seq, g.group_nm,
       COUNT(*) AS push_cnt,
       SUM(CASE WHEN ph.cfm_dt IS NOT NULL THEN 1 ELSE 0 END) AS confirm_cnt,
       ROUND(SUM(CASE WHEN ph.cfm_dt IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS confirm_rate
FROM sm_push_history ph
    JOIN sm_group g ON ph.group_seq = g.group_seq
WHERE ph.send_dt >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY ph.group_seq, g.group_nm
ORDER BY confirm_rate DESC;

-- 특정 메시지 내용 검색
SELECT push_history_seq, push_message, send_dt, cfm_dt
FROM sm_push_history
WHERE push_message LIKE '%재고부족%'
ORDER BY send_dt DESC;

-- 미확인 푸시 많은 사용자 Top N
SELECT ph.group_seq, g.group_nm,
       COUNT(*) AS unconfirm_cnt
FROM sm_push_history ph
    JOIN sm_group g ON ph.group_seq = g.group_seq
WHERE ph.cfm_dt IS NULL
AND ph.send_dt >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY ph.group_seq, g.group_nm
ORDER BY unconfirm_cnt DESC
LIMIT 10;
```