# wms_load (WMS_상차)

## 1. 개요
출하 물품을 **차량에 상차(積載)하는 작업**을 관리하는 테이블.
상차출하(OB05) 유형에서 사용되며, 차량 정보, 상차 상태, 상차 일자 등을 관리한다.

### 1.1 상차 처리 흐름
```
wms_outbiz (출하 헤더)
└─ wms_outbiz_prod (출하 품목)
        └─ wms_outbiz_load (출하-상차 연결)
              └─ wms_load (상차 헤더) ← **현재 테이블**
                    └─ wms_load_prod (상차 품목)
                          └─ wms_load_tran (상차 처리 이력)
                                ↑
                          wms_outbiz_tran (출하 처리 이력) - 상차 완료 시 연동
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | load_seq | integer | N | nextval('wms_load_seq') | 상차 SEQ |
| | biz_seq | integer | N | | 사업장 SEQ → mdm_biz |
| | center_seq | integer | N | | 센터 SEQ → mdm_center |
| | load_no | varchar(30) | N | | 상차 번호 (문서번호) |
| | load_sts_cd | varchar(50) | N | | 상차 상태 코드 |
| FK | car_seq | integer | Y | | 차량 SEQ → mdm_car |
| | driver_nm | varchar(100) | Y | | 운전자명 |
| | driver_tel | varchar(500) | Y | | 운전자 전화번호 |
| | load_idx | smallint | Y | 0 | 차수 (1차, 2차 등) |
| | proc_ymd | varchar(8) | Y | | 처리 일자 (YYYYMMDD) |
| | proc_hms | varchar(6) | Y | | 처리 시간 (HHMMSS) |
| | cfm_ymd | varchar(8) | Y | | 확정 일자 (YYYYMMDD) |
| | cfm_hms | varchar(6) | Y | | 확정 시간 (HHMMSS) |
| | note | varchar(1000) | Y | | 비고 |
| | del_yn | char(1) | N | 'N' | 삭제 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

> **load_sts_cd** (`LOAD_STS_CD`)
>
> | 코드 | 코드명 |
> |---|---|
> | 11 | 예정 |
> | 55 | 상차중 |
> | 77 | 확정 |

> **del_yn** (`DEL_YN`)
>
> | 코드 | 코드명 |
> |---|---|
> | N | 미삭제 |
> | Y | 삭제 |

---

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| wms_load_PK | load_seq | Y | Y |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| load_seq | wms_load_seq |

---

## 5. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| car_seq | mdm_car | car_seq | mdm_car_TO_wms_load |

---

## 6. 참조됨 (참조하는 테이블)

| 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|
| wms_load_prod | load_seq | wms_load_TO_wms_load_prod |
| wms_outbiz_load | load_seq | wms_outbiz_load |

---

## 7. 업무 규칙

### 7.1 상차 생성
- 상차출하(OB05) 등록 시 자동 생성 또는 별도 상차 계획으로 생성
- `load_sts_cd = '11'(예정)` 으로 시작
- `load_no` : `mdm_doc_no` 기반으로 사업장별 채번

### 7.2 차량 정보
- `car_seq` : `mdm_car` 테이블의 차량 정보 참조
- 차량 미지정 시 NULL 허용
- 운전자 정보는 차량 마스터의 기본 정보 활용 가능, 필요 시 직접 입력

### 7.3 차수 관리
- `load_idx` : 동일 차량의 여러 번 상차 시 차수 구분 (1차, 2차 등)
- 하루에 여러 번 상차하는 경우 차수로 구분

### 7.4 상차 상태 변화
- `11`(예정) → `55`(상차중) → `77`(확정)
- 상차 작업 시작 시 `'55'`로 변경
- 상차 완료 시 `'77'`로 변경

### 7.5 상차 처리 단계

#### 7.5.1 상차 예정
- 상차 계획 수립, 차량 배정
- `load_sts_cd = '11'`

#### 7.5.2 상차 진행
- 실제 상차 작업 시작
- `load_sts_cd = '55'`
- `proc_ymd`, `proc_hms`, `proc_user_id` 기록

#### 7.5.3 상차 확정
- 상차 작업 완료
- `load_sts_cd = '77'`
- `cfm_ymd`, `cfm_hms`, `cfm_user_id` 기록
- 연동된 출하처리(`wms_outbiz_tran`) 생성

### 7.6 출하 연동
- `wms_outbiz_load`를 통해 출하 정보와 연결
- 하나의 상차에 여러 출하가 연결될 수 있음 (통합 상차)
- 상차 확정 시 연결된 출하들의 출하처리 이력 생성

### 7.7 취소/삭제
- 확정(`'77'`)된 상차는 취소 불가
- 미확정 상태에서만 수정/삭제 가능
- 물리삭제 금지 — `del_yn = 'Y'` 로 논리삭제 처리

---

## 8. 주요 조회 예시

```sql
-- 상차 상태별 현황
SELECT load_sts_cd, COUNT(*) AS cnt
FROM wms_load
WHERE biz_seq = 1
AND center_seq = 1
AND reg_dt >= CURRENT_DATE - INTERVAL '7 days'
AND del_yn = 'N'
GROUP BY load_sts_cd
ORDER BY load_sts_cd;

-- 특정 출하건의 상차 정보
SELECT ld.load_no, ld.load_sts_cd, ld.load_idx,
       ld.proc_ymd, ld.proc_hms, ld.proc_user_id,
       ld.cfm_ymd, ld.cfm_hms, ld.cfm_user_id,
       c.car_no, c.driver_nm, c.driver_tel,
       ob.outbiz_no, ob.rcv_nm
FROM wms_load ld
    JOIN wms_outbiz_load obl ON ld.load_seq = obl.load_seq
    JOIN wms_outbiz ob ON obl.outbiz_seq = ob.outbiz_seq
    LEFT JOIN mdm_car c ON ld.car_seq = c.car_seq
WHERE ob.biz_seq = 1
AND ob.outbiz_no = 'OB2502260001'
AND ld.del_yn = 'N';

-- 차량별 상차 현황
SELECT c.car_no, c.driver_nm,
       COUNT(ld.load_seq) AS load_cnt,
       SUM(CASE WHEN ld.load_sts_cd = '77' THEN 1 ELSE 0 END) AS completed_cnt
FROM wms_load ld
    JOIN mdm_car c ON ld.car_seq = c.car_seq
WHERE ld.biz_seq = 1
AND ld.reg_dt >= CURRENT_DATE - INTERVAL '30 days'
AND ld.del_yn = 'N'
GROUP BY c.car_no, c.driver_nm
ORDER BY load_cnt DESC;

-- 일자별 상차 현황
SELECT DATE(reg_dt) AS load_date,
       COUNT(*) AS load_cnt,
       SUM(CASE WHEN load_sts_cd = '77' THEN 1 ELSE 0 END) AS completed_cnt
FROM wms_load
WHERE biz_seq = 1
AND reg_dt >= CURRENT_DATE - INTERVAL '30 days'
AND del_yn = 'N'
GROUP BY DATE(reg_dt)
ORDER BY load_date DESC;

-- 미완료 상차 목록 (예정/상차중)
SELECT load_no, load_sts_cd, load_idx,
       proc_ymd, proc_hms,
       car_seq, driver_nm, driver_tel,
       (SELECT COUNT(*) FROM wms_load_prod WHERE load_seq = ld.load_seq) AS prod_cnt
FROM wms_load ld
WHERE biz_seq = 1
AND center_seq = 1
AND load_sts_cd IN ('11', '55')
AND del_yn = 'N'
ORDER BY
    CASE load_sts_cd 
        WHEN '11' THEN 1 
        WHEN '55' THEN 2 
        ELSE 3 
    END,
    reg_dt;

-- 차수별 상차 이력
SELECT load_no, load_idx, load_sts_cd,
       proc_ymd, proc_hms,
       cfm_ymd, cfm_hms,
       car_seq, driver_nm
FROM wms_load
WHERE biz_seq = 1
AND center_seq = 1
AND load_no LIKE 'LOAD202502%'
AND del_yn = 'N'
ORDER BY load_no, load_idx;

-- 상차 소요 시간 분석
SELECT load_no,
       proc_ymd || proc_hms AS start_dtm,
       cfm_ymd || cfm_hms AS end_dtm,
       (TO_TIMESTAMP(cfm_ymd || cfm_hms, 'YYYYMMDDHH24MISS') - 
        TO_TIMESTAMP(proc_ymd || proc_hms, 'YYYYMMDDHH24MISS')) AS elapsed_time,
       (SELECT COUNT(*) FROM wms_load_prod WHERE load_seq = ld.load_seq) AS prod_cnt
FROM wms_load ld
WHERE biz_seq = 1
AND load_sts_cd = '77'
AND proc_ymd = '20250226'
AND del_yn = 'N'
ORDER BY elapsed_time;

-- 차량별 상차 상세 현황 (품목 수량 포함)
SELECT c.car_no, c.driver_nm,
       ld.load_no, ld.load_sts_cd,
       lp.prod_seq, p.prod_nm,
       lp.req_qty, lp.ex_qty
FROM wms_load ld
    JOIN mdm_car c ON ld.car_seq = c.car_seq
    JOIN wms_load_prod lp ON ld.load_seq = lp.load_seq
    JOIN mdm_prod p ON lp.prod_seq = p.prod_seq
WHERE ld.biz_seq = 1
AND ld.proc_ymd = '20250226'
AND ld.del_yn = 'N'
ORDER BY c.car_no, ld.load_no, lp.load_prod_seq;
```