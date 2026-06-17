---
title: PostgreSQL 함수 목록
description: WMS DB에서 사용하는 PostgreSQL 커스텀 함수 목록과 사용법을 확인할 때 읽는다
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: reference
domain: database
tags:
  - database
  - postgresql
  - function
  - fn_concat
  - fn_length
---

# PostgreSQL 함수 (PostgreSQL Function)

| 함수명 | 설명 | 반환타입 | 주요 파라미터 |
|--------|------|----------|--------------|
| **fn_length** | 문자열 길이 반환 | integer | a_string text |
| **fn_now_dt** | 현재 날짜/시간 반환 | timestamp | 없음 |
| **fn_concat** | 세 문자열 연결 | text | str1 text, str2 text, str3 text |
| **fn_add_dt** | 날짜에 일/월 추가 | text | a_string text, a_type text, a_num integer |
| **fn_get_yyyymmdd** | timestamp → YYYYMMDD 변환 | text | a_string timestamp |
| **fn_currval** | 시퀀스 현재값 조회 | bigint | str1 varchar |
| **fn_get_dt** | 문자열 → timestamp 변환 | timestamp | pregdt varchar |
| **fn_get_dt_diff** | 두 날짜의 차이 계산 | integer | a_time timestamp, b_time timestamp, diff_type varchar |
| **fn_get_ymd** | 현재 날짜(YYYYMMDD) 반환 | text | 없음 |

---

## 1. fn_length

문자열의 길이를 반환하는 함수

**구문**

```sql
fn_length(a_string text) RETURNS integer
```

**파라미터**
- `a_string`: 길이를 구할 문자열

**반환값**
- 문자열 길이 (NULL인 경우 0 반환)

**예제**
```sql
SELECT fn_length('Hello'); -- 결과: 5
SELECT fn_length(null); -- 결과: 0
```

---

## 2. fn_now_dt
현재 날짜와 시간을 반환하는 함수

**구문**
```sql
fn_now_dt() RETURNS timestamp without time zone
```

**반환값**
- 현재 타임스탬프 (YYYY-MM-DD HH:MI:SS)

**예제**
```sql
SELECT fn_now_dt(); -- 결과: 2024-01-01 14:30:45
```

---

## 3. fn_concat
세 개의 문자열을 연결하는 함수

**구문**
```sql
fn_concat(str1 text, str2 text, str3 text) RETURNS text
```

**파라미터**
- `str1`: 첫 번째 문자열
- `str2`: 두 번째 문자열
- `str3`: 세 번째 문자열

**반환값**
- 연결된 문자열

**예제**
```sql
SELECT fn_concat('A', 'B', 'C'); -- 결과: ABC
```

---

## 4. fn_add_dt
날짜에 일수 또는 개월수를 더하는 함수

**구문**
```sql
fn_add_dt(a_string text, a_type text, a_num integer) RETURNS text
```

**파라미터**
- `a_string`: 기준 날짜 (YYYYMMDD 형식)
- `a_type`: 'D' (일수), 그 외 (개월수)
- `a_num`: 더할 수치 (양수/음수 가능)

**반환값**
- 계산된 날짜 (YYYYMMDD 형식)

**예제**
```sql
SELECT fn_add_dt('20240101', 'D', 1); -- 결과: 20240102 (1일 후)
SELECT fn_add_dt('20240101', 'M', 1); -- 결과: 20240201 (1개월 후)
SELECT fn_add_dt('20240101', 'M', -1); -- 결과: 20231201 (1개월 전)
```

---

## 5. fn_get_yyyymmdd
타임스탬프를 YYYYMMDD 형식의 문자열로 변환하는 함수

**구문**
```sql
fn_get_yyyymmdd(a_string timestamp without time zone) RETURNS text
```

**파라미터**
- `a_string`: 변환할 타임스탬프

**반환값**
- YYYYMMDD 형식의 문자열

**예제**
```sql
SELECT fn_get_yyyymmdd(now()::timestamp); -- 결과: 20240101
```

---

## 6. fn_currval
시퀀스의 현재 값을 반환하는 함수

**구문**
```sql
fn_currval(str1 character varying) RETURNS bigint
```

**파라미터**
- `str1`: 테이블명 (자동으로 '_seq' 접미사 추가됨)

**반환값**
- 시퀀스의 현재 값

**예제**
```sql
SELECT fn_currval('mdm_prod_seq'); -- mdm_prod_seq의 현재값 조회
```

---

## 7. fn_get_dt
문자열을 타임스탬프로 변환하는 함수

**구문**
```sql
fn_get_dt(pregdt character varying) RETURNS timestamp without time zone
```

**파라미터**
- `pregdt`: 변환할 날짜 문자열

**반환값**
- 타임스탬프 값

**예제**
```sql
SELECT fn_get_dt('2024-01-01 12:30:45'); -- 결과: 2024-01-01 12:30:45
```

---

## 8. fn_get_dt_diff
두 타임스탬프 간의 차이를 계산하는 함수

**구문**
```sql
fn_get_dt_diff(a_time timestamp, b_time timestamp, diff_type varchar) RETURNS integer
```

**파라미터**
- `a_time`: 시작 시간
- `b_time`: 종료 시간
- `diff_type`: 차이 단위 ('day', 'hour', 'minute', 'second')

**반환값**
- 지정된 단위의 시간 차이 (정수)

**예제**
```sql
SELECT fn_get_dt_diff('2024-01-01', '2024-01-02', 'day'); -- 결과: 1
SELECT fn_get_dt_diff('2024-01-01 10:00', '2024-01-01 12:30', 'hour'); -- 결과: 2
SELECT fn_get_dt_diff('2024-01-01 10:00', '2024-01-01 10:05', 'minute'); -- 결과: 5
```

---

## 9. fn_get_ymd
현재 날짜를 YYYYMMDD 형식으로 반환하는 함수

**구문**
```sql
fn_get_ymd() RETURNS text
```

**반환값**
- 현재 날짜 (YYYYMMDD 형식)

**예제**
```sql
SELECT fn_get_ymd(); -- 결과: 20240101
```
