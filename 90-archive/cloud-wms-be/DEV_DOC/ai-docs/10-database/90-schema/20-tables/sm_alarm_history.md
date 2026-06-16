# sm_alarm_history (시스템_알람_이력)

## 1. 개요
시스템에서 발생한 **알람(Alarm)의 이력**을 관리하는 테이블.
사용자에게 전송된 알람 메시지와 관련 정보를 저장하여 알람 발송 내역을 추적한다.

### 1.1 알람 이력 처리 흐름
```
알람 발생 조건 감지 → sm_alarm_history 저장 → 사용자 알람 수신
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | alarm_history_seq | bigint | N | nextval('sm_alarm_history_seq') | 알람 이력 SEQ |
| | biz_seq | integer | N | | 사업장 SEQ |
| | biz_nm | varchar(100) | N | | 사업장명 |
| | center_seq | integer | N | | 센터 SEQ |
| | center_nm | varchar(100) | N | | 센터명 |
| | menu_cd | varchar(50) | N | | 메뉴 코드 |
| | menu_nm | varchar(100) | N | | 메뉴명 |
| | req_seq | integer | Y | | 업무 SEQ |
| | req_no | varchar(30) | N | | 업무 번호 |
| | alarm_message | varchar(1000) | N | | 알람 내용 |
| | group_seq | integer | Y | | 그룹 SEQ |
| | proc_user_id | varchar(20) | N | | 처리자 ID |
| | proc_user_nm | varchar(100) | N | | 처리자명 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |

---

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| sm_alarm_history_PK | alarm_history_seq | Y | Y |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| alarm_history_seq | sm_alarm_history_seq |

---

## 5. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| biz_seq | mdm_biz | biz_seq | mdm_biz_TO_sm_alarm_history |

---

## 6. 업무 규칙

### 6.1 알람 이력 등록
- 알람 발생 시 자동으로 이력 저장
- 알람 메시지는 사전 정의된 템플릿 또는 동적 생성

### 6.2 알람 유형
- 업무 알람: 재고 부족, 유통기한 임박 등
- 시스템 알람: 에러, 장애 등
- 사용자 지정 알람

### 6.3 알람 수신자
- `group_seq`로 그룹 단위 수신자 지정
- `proc_user_id`로 개별 사용자 지정
- 알람 미수신 설정(`sm_alarm_unrcv`)과 연동

### 6.4 관련 업무 정보
- `menu_cd`, `menu_nm`: 알람과 관련된 메뉴
- `req_seq`, `req_no`: 알람과 관련된 업무 문서
- 관련 화면으로 바로 이동할 수 있는 링크 제공

### 6.5 조회 및 통계
- 사용자별 알람 수신 이력 조회
- 일자별 알람 발생 현황 분석
- 업무 유형별 알람 빈도 분석

---

## 7. 주요 조회 예시

```sql
-- 사용자별 알람 이력 조회
SELECT alarm_history_seq, biz_nm, center_nm,
       menu_nm, req_no, alarm_message,
       proc_user_id, proc_user_nm, reg_dt
FROM sm_alarm_history
WHERE proc_user_id = 'user01'
ORDER BY reg_dt DESC;

-- 일자별 알람 발생 현황
SELECT DATE(reg_dt) AS alarm_date,
       COUNT(*) AS alarm_cnt,
       COUNT(DISTINCT proc_user_id) AS user_cnt
FROM sm_alarm_history
WHERE reg_dt >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(reg_dt)
ORDER BY alarm_date DESC;

-- 메뉴별 알람 발생 현황
SELECT menu_cd, menu_nm,
       COUNT(*) AS alarm_cnt
FROM sm_alarm_history
GROUP BY menu_cd, menu_nm
ORDER BY alarm_cnt DESC;

-- 미확인 알람 조회 (알람 수신 확인 기능이 있는 경우)
SELECT ah.*
FROM sm_alarm_history ah
    LEFT JOIN sm_alarm_confirm ac ON ah.alarm_history_seq = ac.alarm_history_seq
WHERE ah.proc_user_id = 'user01'
AND ac.confirm_ymd IS NULL
ORDER BY ah.reg_dt DESC;
```

---
