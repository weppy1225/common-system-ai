# sm_ob_proc_opt_config (시스템_출하_처리_옵션_설정)

## 1. 개요
**출하 처리 유형별 옵션 설정**을 관리하는 테이블.
출하 유형(`outbiz_type_cd`)별로 자동 출하 여부, 출고 처리 여부, 배송 유형, IF 장치 코드 등을 설정하여 출하 처리 방식을 정의한다.

### 1.1 출하 처리 옵션 설정 흐름
```
출하 유형별 옵션 정의 → sm_ob_proc_opt_config 등록 → 출하 등록/처리 시 옵션 적용
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | biz_seq | integer | N | | 사업장 SEQ |
| PK | outbiz_type_cd | varchar(50) | N | | 출하 유형 코드 |
| | outbiz_proc_type_cd | varchar(50) | N | 'N' | 배송 유형 코드 |
| | outbiz_auto_yn | char(1) | N | 'N' | 자동 출하 여부 |
| | outwh_proc_yn | char(1) | N | 'Y' | 출고 처리 여부 |
| | if_device_cd | varchar(50) | N | '-' | IF 장치 코드 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

> **outbiz_type_cd** (`OUTBIZ_TYPE_CD`)
>
> | 코드 | 코드명 | 설명 |
> |---|---|---|
> | OB01 | 일반출하 | 일반 출하 처리 |
> | OB03 | 송장출하 | 송장 연동 출하 |
> | OB05 | 상차출하 | 상차 작업 연동 출하 |
> | OB07 | 즉시출하 | 즉시 출하 처리 |
> | OB71 | 송장출하(WES) | WES 연동 송장출하 |

> **outbiz_proc_type_cd** (`OUTBIZ_PROC_TYPE_CD`)
>
> | 코드 | 코드명 | 설명 |
> |---|---|---|
> | C | 차량 | 차량 배송 |
> | D | 택배 | 택배 배송 |
> | N | 지정안함 | 배송 유형 미지정 |

> **outbiz_auto_yn**, **outwh_proc_yn** (`USE_YN` 계열)
>
> | 코드 | 코드명 |
> |---|---|
> | Y | 예 (사용/처리) |
> | N | 아니오 (미사용/미처리) |

> **if_device_cd** (`IF_DEVICE_CD`)
>
> | 코드 | 코드명 | 설명 |
> |---|---|---|
> | - | 사용안함 | IF 연동 없음 |
> | WES | WES 연동 | WES 시스템 연동 |
> | ERP | ERP 연동 | ERP 시스템 연동 |
> | ETC | 기타 | 기타 외부 시스템 |

---

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| sm_ob_proc_opt_config_PK | biz_seq, outbiz_type_cd | Y | Y |

---

## 4. 업무 규칙

### 4.1 출하 유형별 옵션
- 사업장별로 출하 유형에 따른 처리 옵션 정의
- 동일한 출하 유형이라도 사업장별로 다르게 설정 가능

### 4.2 배송 유형 코드
- 출하 처리 시 사용할 기본 배송 유형 지정
- 출하 등록 시 변경 가능 (기본값으로 활용)

| 코드 | 설명 | 적용 예 |
|------|------|---------|
| C | 차량 배송 | 자차 배송, 용차 배송 |
| D | 택배 배송 | CJ대한통운, 롯데택배 등 |
| N | 지정안함 | 배송 유형 미정, 후지정 |

### 4.3 자동 출하 여부

| 값 | 설명 | 처리 방식 |
|----|------|----------|
| Y | 자동 출하 | 출하 등록 시 자동으로 출하 처리 진행 |
| N | 수동 출하 | 승인/확정 후 출하 처리 |

**자동 출하 처리 흐름:**
```
출하 등록 → 재고 확인 → 출고지시 생성 → 출고 처리 → 출하 확정
```

**수동 출하 처리 흐름:**
```
출하 등록 → (대기) → 사용자 승인 → 출고지시 생성 → 출고 처리 → 출하 확정
```

### 4.4 출고 처리 여부

| 값 | 설명 | 적용场景 |
|----|------|---------|
| Y | 출고 처리 | 실제 창고 출고 수행 |
| N | 출고 생략 | 가상 출하, 재고 변동 없음 |

**출고 처리 생략 사례:**
- 재고 변동 없는 단순 명세서 발행
- 외부 시스템에서 이미 출고 처리된 건
- 테스트용 가상 출하

### 4.5 IF 장치 코드
- 외부 시스템 연동 시 사용할 장치 코드
- 출하 정보를 외부로 전송할 대상 지정

| 코드 | 대상 시스템 | 연동 데이터 |
|------|------------|------------|
| WES | WES 시스템 | 출하 정보, 피킹 지시 |
| ERP | ERP 시스템 | 출하 실적, 재고 변동 |
| - | 연동 없음 | 내부 처리만 수행 |

### 4.6 사업장 관리자 설정
- 별도 설정이 없는 출하 유형은 기본값 적용
- 기본값: `outbiz_proc_type_cd = 'N'`, `outbiz_auto_yn = 'N'`, `outwh_proc_yn = 'Y'`, `if_device_cd = '-'`

### 4.7 권한 관리
- 출하 처리 옵션 변경은 사업장 관리자 이상 권한 필요
- 일반 사용자는 조회만 가능

---

## 5. 주요 조회 예시

```sql
-- 특정 사업장의 출하 유형별 옵션
SELECT outbiz_type_cd,
       CASE outbiz_type_cd
           WHEN 'OB01' THEN '일반출하'
           WHEN 'OB03' THEN '송장출하'
           WHEN 'OB05' THEN '상차출하'
           WHEN 'OB07' THEN '즉시출하'
           WHEN 'OB71' THEN '송장출하(WES)'
       END AS outbiz_type_nm,
       outbiz_proc_type_cd,
       CASE outbiz_proc_type_cd
           WHEN 'C' THEN '차량'
           WHEN 'D' THEN '택배'
           WHEN 'N' THEN '지정안함'
       END AS proc_type_nm,
       outbiz_auto_yn,
       outwh_proc_yn,
       if_device_cd
FROM sm_ob_proc_opt_config
WHERE biz_seq = 1
ORDER BY outbiz_type_cd;

-- 자동 출하 설정된 유형 조회
SELECT outbiz_type_cd, outbiz_proc_type_cd
FROM sm_ob_proc_opt_config
WHERE biz_seq = 1
AND outbiz_auto_yn = 'Y'
ORDER BY outbiz_type_cd;

-- 출고 처리 생략 유형 조회
SELECT outbiz_type_cd, outbiz_proc_type_cd
FROM sm_ob_proc_opt_config
WHERE biz_seq = 1
AND outwh_proc_yn = 'N'
ORDER BY outbiz_type_cd;

-- IF 장치별 설정 현황
SELECT if_device_cd,
       COUNT(*) AS config_cnt,
       COUNT(DISTINCT outbiz_type_cd) AS type_cnt,
       SUM(CASE WHEN outbiz_auto_yn = 'Y' THEN 1 ELSE 0 END) AS auto_cnt
FROM sm_ob_proc_opt_config
WHERE biz_seq = 1
GROUP BY if_device_cd
ORDER BY if_device_cd;

-- 배송 유형별 설정 현황
SELECT outbiz_proc_type_cd,
       COUNT(*) AS config_cnt,
       LISTAGG(outbiz_type_cd, ', ') WITHIN GROUP (ORDER BY outbiz_type_cd) AS type_list
FROM sm_ob_proc_opt_config
WHERE biz_seq = 1
GROUP BY outbiz_proc_type_cd
ORDER BY outbiz_proc_type_cd;

-- 특정 출하 유형의 상세 옵션 조회
SELECT *
FROM sm_ob_proc_opt_config
WHERE biz_seq = 1
AND outbiz_type_cd = 'OB03';

-- 옵션별 사업장 비교
SELECT o1.biz_seq, b1.biz_nm AS biz_nm_1,
       o2.biz_seq, b2.biz_nm AS biz_nm_2,
       o1.outbiz_auto_yn, o2.outbiz_auto_yn,
       o1.outwh_proc_yn, o2.outwh_proc_yn
FROM sm_ob_proc_opt_config o1
    JOIN sm_ob_proc_opt_config o2 ON o1.outbiz_type_cd = o2.outbiz_type_cd
    JOIN mdm_biz b1 ON o1.biz_seq = b1.biz_seq
    JOIN mdm_biz b2 ON o2.biz_seq = b2.biz_seq
WHERE o1.biz_seq = 1
AND o2.biz_seq = 2
AND o1.outbiz_type_cd = 'OB01';

-- 기본값과 다른 설정 조회
SELECT biz_seq, outbiz_type_cd,
       outbiz_proc_type_cd,
       outbiz_auto_yn,
       outwh_proc_yn,
       if_device_cd
FROM sm_ob_proc_opt_config
WHERE biz_seq = 1
AND (outbiz_proc_type_cd != 'N'
       OR outbiz_auto_yn != 'N'
       OR outwh_proc_yn != 'Y'
       OR if_device_cd != '-')
ORDER BY outbiz_type_cd;

-- 최근 수정된 설정 내역
SELECT o.mod_dt, o.mod_id,
       b.biz_nm,
       o.outbiz_type_cd,
       o.outbiz_proc_type_cd,
       o.outbiz_auto_yn,
       o.outwh_proc_yn,
       o.if_device_cd
FROM sm_ob_proc_opt_config o
    JOIN mdm_biz b ON o.biz_seq = b.biz_seq
WHERE o.mod_dt >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY o.mod_dt DESC;

-- 사업장별 미설정 출하 유형 체크
SELECT b.biz_seq, b.biz_nm,
       cd.comm_d_cd AS outbiz_type_cd,
       cd.comm_d_nm AS type_nm
FROM mdm_biz b
    CROSS JOIN (
        SELECT comm_d_cd, comm_d_nm
        FROM sm_comm_d
        WHERE biz_seq = 0  -- 공통코드
          AND comm_h_cd = 'OUTBIZ_TYPE_CD'
          AND use_yn = 'Y'
    ) cd
    LEFT JOIN sm_ob_proc_opt_config o ON b.biz_seq = o.biz_seq 
        AND cd.comm_d_cd = o.outbiz_type_cd
WHERE b.use_yn = 'Y'
AND o.biz_seq IS NULL
ORDER BY b.biz_seq, cd.comm_d_cd;
```