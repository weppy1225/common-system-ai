
# sm_dlv_config_applied (시스템_택배_적용)

## 1. 개요
택배 설정(`sm_dlv_config`)을 **특정 센터와 사업장에 적용**하는 관계 테이블.
우선순위(`disp_no`)를 통해 여러 택배 설정 중 적용 순서를 지정한다.

### 1.1 택배 적용 흐름
```
택배 설정 등록 → sm_dlv_config_applied로 센터/사업장에 적용 → 출하 시 우선순위에 따라 선택
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | dlv_config_applied_seq | integer | N | nextval('sm_dlv_config_applied_seq') | 택배 적용 SEQ |
| | dlv_config_seq | integer | N | | 택배 설정 SEQ |
| | center_seq | integer | N | | 센터 SEQ |
| | biz_seq | integer | N | | 사업장 SEQ |
| | disp_no | smallint | N | 0 | 우선순위 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

---

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| sm_dlv_config_applied_PK | dlv_config_applied_seq | Y | Y |
| UIX_sm_dlv_config_applied | dlv_config_seq, center_seq, biz_seq | Y | |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| dlv_config_applied_seq | sm_dlv_config_applied_seq |

---

## 5. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| dlv_config_seq | sm_dlv_config | dlv_config_seq | sm_dlv_config_TO_sm_dlv_config_applied |

---

## 6. 업무 규칙

### 6.1 택배 설정 적용
- 하나의 택배 설정을 여러 센터/사업장에 적용 가능
- 하나의 센터/사업장에 여러 택배 설정 적용 가능

### 6.2 우선순위
- `disp_no`가 낮을수록 높은 우선순위
- 출하 시 우선순위 높은 설정부터 적용 시도
- 실패 시 다음 우선순위 설정 적용

### 6.3 중복 방지
- 동일한 `dlv_config_seq`, `center_seq`, `biz_seq` 조합은 유니크
- 중복 적용 불가

---

## 7. 주요 조회 예시

```sql
-- 특정 센터/사업장의 적용된 택배 설정 (우선순위 순)
SELECT a.disp_no, d.dlv_co_cd, d.invoice_assign_type_cd,
       d.cust_id, d.biz_no
FROM sm_dlv_config_applied a
    JOIN sm_dlv_config d ON a.dlv_config_seq = d.dlv_config_seq
WHERE a.center_seq = 1
AND a.biz_seq = 1
AND d.use_yn = 'Y'
ORDER BY a.disp_no;

-- 특정 택배 설정이 적용된 센터/사업장 목록
SELECT a.center_seq, c.center_nm,
       a.biz_seq, b.biz_nm,
       a.disp_no
FROM sm_dlv_config_applied a
    JOIN mdm_center c ON a.center_seq = c.center_seq
    JOIN mdm_biz b ON a.biz_seq = b.biz_seq
WHERE a.dlv_config_seq = 1001
ORDER BY a.disp_no;

-- 센터별 적용된 택배 설정 수
SELECT center_seq,
       COUNT(*) AS config_cnt,
       MIN(disp_no) AS min_priority
FROM sm_dlv_config_applied
GROUP BY center_seq
ORDER BY center_seq;
```

---
