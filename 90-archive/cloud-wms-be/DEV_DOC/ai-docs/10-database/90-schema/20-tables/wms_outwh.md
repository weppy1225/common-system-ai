# wms_outwh (WMS_출고)

## 1. 개요
실제 창고에서 물품을 **출고(出庫) 처리**하는 요청 헤더 테이블.
출하(`wms_outbiz`) 정보를 기반으로 생성되며, 피킹 및 출고 확정을 통해 실재고(`wms_inven`)가 감소한다.

### 1.1 출고 처리 흐름
```
wms_outbiz (출하) → wms_outwh (출고 헤더)
                    └─ wms_outwh_prod (출고 품목)
                          └─ wms_outwh_tran (출고 처리 이력) → wms_inven 감소
                                ↑
                          wms_outwh_assign (출고지시) - 피킹 위치 지정
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | outwh_seq | integer | N | nextval('wms_outwh_seq') | 출고 SEQ |
| | biz_seq | integer | N | | 사업장 SEQ → mdm_biz |
| | center_seq | integer | N | | 센터 SEQ → mdm_center |
| | outwh_no | varchar(30) | N | | 출고 번호 (문서번호) |
| | outwh_type_cd | varchar(50) | N | | 출고 유형 코드 |
| | outwh_sts_cd | varchar(50) | N | '11' | 출고 상태 코드 |
| | outwh_proc_type_cd | varchar(50) | N | 'B2B' | 출고 처리 유형 코드 |
| | outwh_div_cd | varchar(50) | N | | 출고 지시 유형 코드 |
| | outwh_div_key | varchar(50) | Y | | 출고 지시 분류키 |
| | outwh_div_id | varchar(50) | Y | | 출고 지시 분류값 |
| | strng_asgn_yn | char(1) | N | 'N' | 출고 강지정 여부 |
| | group_outwh_no | varchar(30) | N | | 그룹 출고 번호 |
| | req_ymd | varchar(8) | N | | 요청 일자 (YYYYMMDD) |
| | req_hms | varchar(6) | Y | | 요청 시간 (HHMMSS) |
| | req_user_nm | varchar(100) | N | | 요청자명 |
| | req_dept_nm | varchar(100) | Y | | 요청 부서명 |
| | cfm_ymd | varchar(8) | Y | | 확정 일자 (YYYYMMDD) |
| | cfm_hms | varchar(6) | Y | | 확정 시간 (HHMMSS) |
| | cfm_user_id | varchar(20) | Y | | 확정자 ID |
| | note | varchar(1000) | Y | | 비고 |
| | if_key | varchar(50) | Y | | IF 연동 키 |
| | if_err_seq | integer | Y | | IF 에러 SEQ |
| | if_send_yn | char(1) | N | 'N' | IF 송신 여부 |
| | del_yn | char(1) | N | 'N' | 삭제 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

> **outwh_type_cd** (`OUTWH_TYPE_CD`)
>
> | 코드 | 코드명 | 비고 |
> |---|---|---|
> | OW01 | 출고이동 | 일반 출고 |

> **outwh_sts_cd** (`OUTWH_STS_CD`)
>
> | 코드 | 코드명 |
> |---|---|
> | 11 | 예정 |
> | 55 | 처리중 |
> | 77 | 확정 |

> **outwh_proc_type_cd** (`OUTWH_PROC_TYPE_CD`)
>
> | 코드 | 코드명 | 비고 |
> |---|---|---|
> | B2B | B2B | 기업간 거래 |
> | B2C | B2C | 소비자 거래 |

> **outwh_div_cd** (`OUTWH_DIV_CD`)
>
> | 코드 | 코드명 | 비고 |
> |---|---|---|
> | - | 총괄 | 전체 피킹 |
> | wh | 창고별 | 창고 단위 피킹 |
> | locMng | 담당자별 | 담당자별 피킹 |
> | outbizNo | 출하번호 | 출하 단위 피킹 |

> **strng_asgn_yn** (`STRNG_ASGN_YN`)
>
> | 코드 | 코드명 |
> |---|---|
> | N | 약지정 |
> | Y | 강지정 |

> **if_send_yn** (`IF_SEND_YN`)
>
> | 코드 | 코드명 |
> |---|---|
> | N | 대기 |
> | Y | 성공 |
> | E | 실패 |

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
| wms_outwh_PK | outwh_seq | Y | Y |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| outwh_seq | wms_outwh_seq |

---

## 5. 참조됨 (참조하는 테이블)

| 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|
| wms_outwh_prod | outwh_seq | wms_outwh_TO_wms_outwh_prod |
| wms_outbiz_outwh | outwh_seq | wms_outbiz_outwh |

---

## 6. 업무 규칙

### 6.1 출고 등록
- `outwh_no` : `mdm_doc_no` 기반으로 사업장별 채번 (수불유형 `OW`)
- 출하(`wms_outbiz`) 정보를 기반으로 생성
- 출고 등록 시 `outwh_sts_cd = '11'(예정)` 으로 시작

### 6.2 그룹 출고 번호
- `group_outwh_no` : 여러 출하를 묶어서 일괄 출고할 때 사용
- 동일 그룹 내 출고들은 함께 피킹 및 출고 처리 가능
- `wms_outbiz`의 `group_outwh_no`와 연동

### 6.3 출고 지시 유형 (`outwh_div_cd`)

| 코드 | 설명 | 사용처 |
|---|---|---|
| - | 총괄 | 전체 피킹 일괄 지시 |
| wh | 창고별 | 창고 단위로 피킹 지시 분할 |
| locMng | 담당자별 | 담당자별로 피킹 지시 분할 |
| outbizNo | 출하번호 | 출하 단위로 피킹 지시 분할 |

### 6.4 출고 강지정 여부
- **약지정(N)** : 시스템이 자동으로 재고 위치 지정
- **강지정(Y)** : 사용자가 직접 재고 위치 지정 (`wms_outwh_assign` 활용)

### 6.5 출고 처리 단계

#### 6.5.1 출고 예정
- 출고 요청 등록
- `outwh_sts_cd = '11'`

#### 6.5.2 출고 지시
- 피킹 위치 지정 (`wms_outwh_assign`)
- `outwh_sts_cd`는 '11' 유지 또는 별도 관리

#### 6.5.3 출고 처리중
- 실제 피킹 작업 시작
- `outwh_sts_cd = '55'`

#### 6.5.4 출고 확정
- 출고 작업 완료
- `outwh_sts_cd = '77'`
- `cfm_ymd`, `cfm_hms`, `cfm_user_id` 기록
- 재고 차감 및 출하 처리 연동

### 6.6 출하 연동
- `wms_outbiz_outwh`를 통해 출하 정보와 연결
- 출고 확정 시 연결된 출하의 출하처리(`wms_outbiz_tran`) 생성

### 6.7 IF 송신
- `if_send_yn` : 외부 시스템(ERP/WMS)으로 출고 정보 송신 여부 관리
- 최초 등록 시 'N', 송신 성공 시 'Y', 실패 시 'E'

### 6.8 취소/삭제
- 확정(`'77'`)된 출고는 취소 불가 (재고 변동 발생)
- 미확정 상태에서만 수정/삭제 가능
- 물리삭제 금지 — `del_yn = 'Y'` 로 논리삭제 처리

---

## 7. 주요 조회 예시

```sql
-- 출고 상태별 현황
SELECT outwh_sts_cd, COUNT(*) AS cnt
FROM wms_outwh
WHERE biz_seq = 1
AND center_seq = 1
AND req_ymd = '20250226'
AND del_yn = 'N'
GROUP BY outwh_sts_cd
ORDER BY outwh_sts_cd;

-- 미처리 출고 목록 (예정/처리중)
SELECT outwh_no, outwh_sts_cd, outwh_proc_type_cd,
       outwh_div_cd, strng_asgn_yn,
       req_ymd, req_user_nm,
       group_outwh_no
FROM wms_outwh
WHERE biz_seq = 1
AND center_seq = 1
AND outwh_sts_cd IN ('11', '55')
AND del_yn = 'N'
ORDER BY req_ymd, outwh_no;

-- 출하 연동 출고 조회
SELECT ow.outwh_no, ow.outwh_sts_cd,
       ob.outbiz_no, ob.rcv_nm,
       obo.outwh_req_qty
FROM wms_outwh ow
    JOIN wms_outbiz_outwh obo ON ow.outwh_seq = obo.outwh_seq
    JOIN wms_outbiz ob ON obo.outbiz_seq = ob.outbiz_seq
WHERE ow.biz_seq = 1
AND ob.outbiz_no = 'OB2502260001'
AND ow.del_yn = 'N';

-- 그룹 출고 번호별 현황
SELECT group_outwh_no,
       COUNT(*) AS outwh_cnt,
       SUM(CASE WHEN outwh_sts_cd = '77' THEN 1 ELSE 0 END) AS completed_cnt
FROM wms_outwh
WHERE biz_seq = 1
AND group_outwh_no IS NOT NULL
AND req_ymd = '20250226'
AND del_yn = 'N'
GROUP BY group_outwh_no
ORDER BY group_outwh_no;

-- 출고 지시 유형별 현황
SELECT outwh_div_cd,
       COUNT(*) AS outwh_cnt,
       SUM(CASE WHEN outwh_sts_cd = '77' THEN 1 ELSE 0 END) AS completed_cnt
FROM wms_outwh
WHERE biz_seq = 1
AND req_ymd BETWEEN '20250201' AND '20250228'
AND del_yn = 'N'
GROUP BY outwh_div_cd
ORDER BY outwh_div_cd;

-- 강지정 출고 현황
SELECT outwh_no, outwh_sts_cd,
       req_ymd, req_user_nm
FROM wms_outwh
WHERE biz_seq = 1
AND strng_asgn_yn = 'Y'
AND outwh_sts_cd != '77'
AND del_yn = 'N'
ORDER BY req_ymd;

-- IF 송신 대기 건 조회
SELECT outwh_no, outwh_sts_cd,
       req_ymd, group_outwh_no
FROM wms_outwh
WHERE biz_seq = 1
AND if_send_yn = 'N'
AND del_yn = 'N'
ORDER BY reg_dt;

-- 일자별 출고 처리 현황
SELECT req_ymd,
       COUNT(*) AS total_cnt,
       SUM(CASE WHEN outwh_sts_cd = '77' THEN 1 ELSE 0 END) AS completed_cnt,
       ROUND(SUM(CASE WHEN outwh_sts_cd = '77' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS completion_rate
FROM wms_outwh
WHERE biz_seq = 1
AND req_ymd BETWEEN '20250201' AND '20250228'
AND del_yn = 'N'
GROUP BY req_ymd
ORDER BY req_ymd;
```