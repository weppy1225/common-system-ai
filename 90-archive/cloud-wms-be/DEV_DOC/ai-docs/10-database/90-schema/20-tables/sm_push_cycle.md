# sm_push_cycle (시스템_푸시_주기)

## 1. 개요
**푸시 알림 발송 주기 및 조건**을 관리하는 테이블.
사업장, 센터, 그룹별로 푸시 알림 유형에 따른 발송 주기, 요일, 시간 등을 설정하여 정기적인 푸시 알림을 자동으로 발송할 수 있도록 한다.

### 1.1 푸시 주기 설정 흐름
```
푸시 주기 설정 등록 → 스케줄러가 주기적으로 확인 → 조건 충족 시 푸시 발송 → sm_push_history 저장
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | push_cycle_seq | integer | N | nextval('sm_push_cycle_seq') | 푸시 주기 SEQ |
| | biz_seq | integer | N | | 사업장 SEQ |
| | center_seq_str | varchar(1000) | Y | | 센터 SEQ 문자열 (콤마 구분) |
| | group_seq_str | varchar(1000) | Y | | 그룹 SEQ 문자열 (콤마 구분) |
| | push_type_cd | varchar(50) | N | | 푸시 유형 코드 |
| | push_cycle_cd | varchar(50) | N | | 푸시 주기 코드 |
| | push_note | varchar(1000) | N | | 푸시 내용 |
| | mon | char(1) | Y | 'N' | 월요일 발송 여부 |
| | tue | char(1) | Y | 'N' | 화요일 발송 여부 |
| | wed | char(1) | Y | 'N' | 수요일 발송 여부 |
| | thu | char(1) | Y | 'N' | 목요일 발송 여부 |
| | fri | char(1) | Y | 'N' | 금요일 발송 여부 |
| | sat | char(1) | Y | 'N' | 토요일 발송 여부 |
| | sun | char(1) | Y | 'N' | 일요일 발송 여부 |
| | push_cycle_dd | char(2) | Y | | 푸시 반복 일 (월별) |
| | push_start_ymd | varchar(8) | Y | | 푸시 시작 연월일 |
| | push_end_ymd | varchar(8) | Y | | 푸시 종료 연월일 |
| | push_send_hms1 | varchar(6) | Y | | 푸시 발송 시분초1 |
| | push_send_hms2 | varchar(6) | Y | | 푸시 발송 시분초2 |
| | use_yn | char(1) | N | 'Y' | 사용 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

> **push_type_cd** (`PUSH_TYPE_CD`)
>
> | 코드 | 코드명 | 설명 |
> |---|---|---|
> | 1 | 알람 | 일반 알람 푸시 |

> **push_cycle_cd** (`PUSH_CYCLE_CD`)
>
> | 코드 | 코드명 | 설명 |
> |---|---|---|
> | P | 기간 | 특정 기간 동안 발송 |
> | D | 매일 | 매일 발송 |
> | W | 매주 | 주 단위 발송 (요일 지정) |
> | M | 매월 | 월 단위 발송 (일자 지정) |
> | N | 즉시 | 조건 충족 시 즉시 발송 |
> | R | 예약 | 특정 일시에 예약 발송 |

> **use_yn** (`USE_YN`)
>
> | 코드 | 코드명 |
> |---|---|
> | Y | 사용 |
> | N | 미사용 |

---

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| sm_push_cycle_PK | push_cycle_seq | Y | Y |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| push_cycle_seq | sm_push_cycle_seq |

---

## 5. 업무 규칙

### 5.1 대상자 지정

| 필드 | 설명 | 예시 |
|------|------|------|
| center_seq_str | 대상 센터 SEQ 목록 | '1,2,3' (전체: NULL 또는 'ALL') |
| group_seq_str | 대상 그룹 SEQ 목록 | '10,20,30' (전체: NULL 또는 'ALL') |

**대상자 선정 로직:**
- `center_seq_str`과 `group_seq_str`의 교집합
- 두 필드 모두 NULL이면 전체 사업장 대상

### 5.2 푸시 주기 유형

| 주기 | 코드 | 설정 방식 | 설명 |
|------|------|----------|------|
| 기간 | P | push_start_ymd, push_end_ymd | 특정 기간 동안 매일 발송 |
| 매일 | D | push_send_hms1, push_send_hms2 | 매일 지정 시간에 발송 |
| 매주 | W | 요일 필드(mon~sun), 발송시간 | 지정된 요일에 발송 |
| 매월 | M | push_cycle_dd, 발송시간 | 매월 지정된 일자에 발송 |
| 즉시 | N | - | 조건 충족 시 즉시 발송 |
| 예약 | R | push_start_ymd, push_send_hms1 | 특정 일시에 1회 발송 |

### 5.3 요일 설정
- `mon` ~ `sun`: 각 요일별 발송 여부 ('Y'/'N')
- 매주 주기(W)에서만 사용
- 복수 요일 선택 가능

### 5.4 월별 설정
- `push_cycle_dd`: 매월 발송할 일자 (01~31)
- 31일이 없는 달의 경우 말일로 자동 조정

### 5.5 발송 시간
- `push_send_hms1`: 1차 발송 시간
- `push_send_hms2`: 2차 발송 시간 (선택사항)
- 하루 2회 발송 필요한 경우 사용

### 5.6 기간 설정
- `push_start_ymd`: 발송 시작일
- `push_end_ymd`: 발송 종료일
- 기간 주기(P)에서 필수, 다른 주기에서는 선택

### 5.7 푸시 내용
- `push_note`: 발송할 푸시 메시지 내용
- 템플릿 변수 사용 가능 (예: {user_nm}, {req_no} 등)

### 5.8 사용 여부
- `use_yn = 'N'`인 설정은 스케줄러에서 제외
- 일시 중단 시 사용

---

## 6. 주요 조회 예시

```sql
-- 활성화된 푸시 주기 설정 목록
SELECT push_cycle_seq, push_type_cd, push_cycle_cd,
       push_note,
       push_start_ymd, push_end_ymd,
       push_send_hms1, push_send_hms2,
       mon, tue, wed, thu, fri, sat, sun,
       push_cycle_dd
FROM sm_push_cycle
WHERE biz_seq = 1
AND use_yn = 'Y'
ORDER BY push_cycle_seq;

-- 주기 유형별 설정 현황
SELECT push_cycle_cd,
       COUNT(*) AS config_cnt,
       MIN(push_start_ymd) AS earliest_start,
       MAX(push_end_ymd) AS latest_end
FROM sm_push_cycle
WHERE biz_seq = 1
AND use_yn = 'Y'
GROUP BY push_cycle_cd
ORDER BY push_cycle_cd;

-- 특정 요일에 발송되는 설정 조회 (월요일)
SELECT push_cycle_seq, push_type_cd, push_cycle_cd,
       push_note, push_send_hms1, push_send_hms2
FROM sm_push_cycle
WHERE biz_seq = 1
AND use_yn = 'Y'
AND push_cycle_cd = 'W'
AND mon = 'Y'
ORDER BY push_send_hms1;

-- 매월 특정 일에 발송되는 설정
SELECT push_cycle_seq, push_type_cd,
       push_note, push_cycle_dd, push_send_hms1
FROM sm_push_cycle
WHERE biz_seq = 1
AND use_yn = 'Y'
AND push_cycle_cd = 'M'
AND push_cycle_dd = '15' -- 매월 15일
ORDER BY push_send_hms1;

-- 오늘 발송 예정인 설정 조회
SELECT pc.*,
       CASE 
           WHEN pc.push_cycle_cd = 'D' THEN '매일'
           WHEN pc.push_cycle_cd = 'W' AND 
                (pc.mon = 'Y' AND TO_CHAR(CURRENT_DATE, 'D') = '2' OR
                 pc.tue = 'Y' AND TO_CHAR(CURRENT_DATE, 'D') = '3' OR
                 pc.wed = 'Y' AND TO_CHAR(CURRENT_DATE, 'D') = '4' OR
                 pc.thu = 'Y' AND TO_CHAR(CURRENT_DATE, 'D') = '5' OR
                 pc.fri = 'Y' AND TO_CHAR(CURRENT_DATE, 'D') = '6' OR
                 pc.sat = 'Y' AND TO_CHAR(CURRENT_DATE, 'D') = '7' OR
                 pc.sun = 'Y' AND TO_CHAR(CURRENT_DATE, 'D') = '1') THEN '오늘발송'
           WHEN pc.push_cycle_cd = 'M' AND 
                pc.push_cycle_dd = TO_CHAR(CURRENT_DATE, 'DD') THEN '오늘발송'
           WHEN pc.push_cycle_cd = 'P' AND 
                pc.push_start_ymd <= TO_CHAR(CURRENT_DATE, 'YYYYMMDD') AND
                pc.push_end_ymd >= TO_CHAR(CURRENT_DATE, 'YYYYMMDD') THEN '기간중'
           ELSE '해당없음'
       END AS today_status
FROM sm_push_cycle pc
WHERE pc.biz_seq = 1
AND pc.use_yn = 'Y'
AND (pc.push_cycle_cd = 'D'
       OR (pc.push_cycle_cd = 'W' AND 
           ((pc.mon = 'Y' AND TO_CHAR(CURRENT_DATE, 'D') = '2') OR
            (pc.tue = 'Y' AND TO_CHAR(CURRENT_DATE, 'D') = '3') OR
            (pc.wed = 'Y' AND TO_CHAR(CURRENT_DATE, 'D') = '4') OR
            (pc.thu = 'Y' AND TO_CHAR(CURRENT_DATE, 'D') = '5') OR
            (pc.fri = 'Y' AND TO_CHAR(CURRENT_DATE, 'D') = '6') OR
            (pc.sat = 'Y' AND TO_CHAR(CURRENT_DATE, 'D') = '7') OR
            (pc.sun = 'Y' AND TO_CHAR(CURRENT_DATE, 'D') = '1')))
       OR (pc.push_cycle_cd = 'M' AND pc.push_cycle_dd = TO_CHAR(CURRENT_DATE, 'DD'))
       OR (pc.push_cycle_cd = 'P' AND 
           pc.push_start_ymd <= TO_CHAR(CURRENT_DATE, 'YYYYMMDD') AND
           pc.push_end_ymd >= TO_CHAR(CURRENT_DATE, 'YYYYMMDD')));

-- 특정 그룹 대상 설정 조회
SELECT pc.push_cycle_seq, pc.push_type_cd, pc.push_cycle_cd,
       pc.push_note, pc.push_send_hms1,
       g.group_seq, g.group_nm
FROM sm_push_cycle pc
    CROSS JOIN LATERAL unnest(string_to_array(pc.group_seq_str, ',')) AS gid
    JOIN sm_group g ON gid::integer = g.group_seq
WHERE pc.biz_seq = 1
AND pc.use_yn = 'Y'
AND pc.group_seq_str IS NOT NULL
ORDER BY pc.push_cycle_seq, g.group_seq;

-- 특정 센터 대상 설정 조회
SELECT pc.push_cycle_seq, pc.push_type_cd, pc.push_cycle_cd,
       pc.push_note, pc.push_send_hms1,
       c.center_seq, c.center_nm
FROM sm_push_cycle pc
    CROSS JOIN LATERAL unnest(string_to_array(pc.center_seq_str, ',')) AS cid
    JOIN mdm_center c ON cid::integer = c.center_seq
WHERE pc.biz_seq = 1
AND pc.use_yn = 'Y'
AND pc.center_seq_str IS NOT NULL
ORDER BY pc.push_cycle_seq, c.center_seq;

-- 기간이 만료된 설정 조회
SELECT push_cycle_seq, push_note, push_start_ymd, push_end_ymd
FROM sm_push_cycle
WHERE biz_seq = 1
AND use_yn = 'Y'
AND push_end_ymd IS NOT NULL
AND push_end_ymd < TO_CHAR(CURRENT_DATE, 'YYYYMMDD')
ORDER BY push_end_ymd;

-- 하루 2회 발송 설정 조회
SELECT push_cycle_seq, push_type_cd, push_cycle_cd,
       push_note, push_send_hms1, push_send_hms2
FROM sm_push_cycle
WHERE biz_seq = 1
AND use_yn = 'Y'
AND push_send_hms1 IS NOT NULL
AND push_send_hms2 IS NOT NULL
ORDER BY push_send_hms1;

-- 센터/그룹 미지정 (전체 대상) 설정
SELECT push_cycle_seq, push_type_cd, push_cycle_cd, push_note
FROM sm_push_cycle
WHERE biz_seq = 1
AND use_yn = 'Y'
AND (center_seq_str IS NULL OR center_seq_str = '')
AND (group_seq_str IS NULL OR group_seq_str = '')
ORDER BY push_cycle_seq;

-- 시간대별 발송 설정 집계
SELECT SUBSTR(push_send_hms1, 1, 2) AS hour,
       COUNT(*) AS config_cnt
FROM sm_push_cycle
WHERE biz_seq = 1
AND use_yn = 'Y'
AND push_send_hms1 IS NOT NULL
GROUP BY SUBSTR(push_send_hms1, 1, 2)
ORDER BY hour;

-- 특정 시간에 발송 예정인 설정 (현재 시간 기준)
SELECT push_cycle_seq, push_note, push_cycle_cd,
       push_send_hms1, push_send_hms2
FROM sm_push_cycle
WHERE biz_seq = 1
AND use_yn = 'Y'
AND (push_send_hms1 LIKE '14%' OR push_send_hms2 LIKE '14%') -- 오후 2시대
ORDER BY push_send_hms1;
```