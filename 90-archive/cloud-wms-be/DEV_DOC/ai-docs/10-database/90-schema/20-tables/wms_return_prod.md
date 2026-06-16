# wms_return_prod (WMS_반품_품목)

## 1. 개요
반품 요청의 **품목 상세 정보**를 관리하는 테이블.
반품 헤더(`wms_return`)에 속한 각 품목별로 요청 수량, 처리 상태, 예상 속성(유통기한, LOT번호 등)을 저장한다.

### 1.1 반품 품목 처리 흐름
```
wms_return (반품 헤더)
└─ wms_return_prod (반품 품목)
        └─ wms_return_tran (반품 처리 이력)
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | return_prod_seq | bigint | N | nextval('wms_return_prod_seq') | 반품 품목 SEQ |
| PK/FK | return_seq | integer | N | | 반품 SEQ → wms_return |
| | prod_seq | integer | N | | 품목 SEQ → mdm_prod |
| | return_prod_sts_cd | varchar(50) | N | | 반품 품목 상태 코드 |
| | req_qty | decimal(10,2) | N | 0 | 요청 수량(반품) |
| | ex_qty | decimal(10,2) | N | 0 | 기처리 수량(반품) |
| | est_exp_ymd | varchar(8) | Y | | 예상 유통기한 (YYYYMMDD) |
| | est_mng_ymd | varchar(8) | Y | | 예상 입고/제조일자 (YYYYMMDD) |
| | est_lot_no | varchar(30) | Y | | 예상 LOT 번호 |
| | pub_sku1_yn | char(1) | N | 'N' | SKU1 발행 여부 |
| | pub_sku2_yn | char(1) | N | 'N' | SKU2 발행 여부 |
| | pltzing_yn | char(1) | N | 'N' | 파렛타이징 여부 |
| | if_send_yn | char(1) | N | 'N' | IF 송신 여부 |
| | if_idx | varchar(20) | Y | | IF 내부 순번 |
| | if_err_seq | integer | Y | | IF 에러 SEQ |
| | del_yn | char(1) | N | 'N' | 삭제 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

> **return_prod_sts_cd** (`RETURN_PROD_STS_CD`)
>
> | 코드 | 코드명 |
> |---|---|
> | 11 | 예정 |
> | 55 | 처리중 |
> | 77 | 확정 |

> **pub_sku1_yn**, **pub_sku2_yn**, **pltzing_yn** (`USE_YN` 계열)
>
> | 코드 | 코드명 |
> |---|---|
> | N | 미발행/미사용 |
> | Y | 발행/사용 |

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
| wms_return_prod_PK | return_prod_seq, return_seq | Y | Y |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| return_prod_seq | wms_return_prod_seq |

---

## 5. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| return_seq | wms_return | return_seq | wms_return_TO_wms_return_prod |

---

## 6. 참조됨 (참조하는 테이블)

| 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|
| wms_return_tran | return_prod_seq, return_seq | wms_return_prod_TO_wms_return_tran |

---

## 7. 업무 규칙

### 7.1 반품 품목 등록
- 반품 헤더(`wms_return`) 등록 시 함께 생성
- 하나의 반품 헤더에 여러 품목 등록 가능
- `req_qty` : 반품 요청 수량
- `ex_qty` : 실제 처리 완료된 수량 (기본값 0)

### 7.2 예상 속성 정보
- 반품 접수 단계에서 예상 정보 입력 가능
- `est_exp_ymd` : 예상 유통기한
- `est_mng_ymd` : 예상 제조일자/입고일자
- `est_lot_no` : 예상 LOT 번호
- 실제 처리 시(`wms_return_tran`)에는 확정된 값으로 대체

### 7.3 상태 코드 변경

| 상태 | 설명 | 비고 |
|------|------|------|
| 11 | 예정 | 최초 등록 상태 |
| 55 | 처리중 | 검수 진행 중 (일부 처리됨) |
| 77 | 확정 | 전체 수량 처리 완료 |

### 7.4 수량 관리
- `req_qty` ≥ `ex_qty` (요청 수량 이상 처리 불가)
- `ex_qty`는 `wms_return_tran`의 `proc_qty` 합계와 동일
- `req_qty` = `ex_qty` 시 해당 품목 상태 '77'(확정)으로 자동 변경 가능

### 7.5 SKU 발행 여부
- `pub_sku1_yn` : SKU1 라벨 발행 필요 여부
- `pub_sku2_yn` : SKU2 라벨 발행 필요 여부
- 반품 검수 시 라벨 발행 필요하면 'Y'로 설정
- 발행 완료 후 별도 관리

### 7.6 파렛타이징 여부
- `pltzing_yn` : 파렛트 단위 보관 필요 여부
- 'Y'인 경우 입고 시 파렛트 단위로 위치 지정 필요

### 7.7 IF 연동
- `if_send_yn` : 외부 시스템(ERP)으로 반품 품목 정보 송신 여부
- 품목별 송신 상태 관리 (헤더와 별도)
- `if_idx` : 외부 시스템에서의 순번/인덱스
- `if_err_seq` : 송신 실패 시 에러 SEQ 연결

### 7.8 삭제 처리
- 물리삭제 금지 — `del_yn = 'Y'` 로 논리삭제
- 헤더 삭제 시 하위 품목도 일괄 논리삭제 처리 필요
- 삭제된 품목은 처리 이력에서 제외

### 7.9 처리 이력 연동
- `wms_return_tran`에서 실제 처리 내역 관리
- `ex_qty`는 `wms_return_tran.proc_qty`의 합계로 유지/갱신
- `return_prod_sts_cd`는 `ex_qty`와 `req_qty` 비교하여 자동 갱신 가능

---

## 8. 주요 조회 예시

```sql
-- 반품별 품목 목록 조회
SELECT rp.return_prod_seq, rp.prod_seq, p.prod_nm, p.prod_no,
       rp.req_qty, rp.ex_qty,
       rp.return_prod_sts_cd,
       rp.est_exp_ymd, rp.est_lot_no,
       rp.pub_sku1_yn, rp.pub_sku2_yn, rp.pltzing_yn
FROM wms_return_prod rp
    JOIN mdm_prod p ON rp.prod_seq = p.prod_seq
WHERE rp.return_seq = 1001
AND rp.del_yn = 'N'
ORDER BY rp.return_prod_seq;

-- 미처리 품목 조회 (예정/처리중)
SELECT r.return_no, r.req_ymd,
       rp.prod_seq, p.prod_nm,
       rp.req_qty, rp.ex_qty,
       (rp.req_qty - rp.ex_qty) AS pending_qty,
       rp.est_exp_ymd, rp.est_lot_no
FROM wms_return_prod rp
    JOIN wms_return r ON rp.return_seq = r.return_seq
    JOIN mdm_prod p ON rp.prod_seq = p.prod_seq
WHERE r.biz_seq = 1
AND rp.return_prod_sts_cd IN ('11', '55')
AND rp.req_qty > rp.ex_qty
AND rp.del_yn = 'N'
AND r.del_yn = 'N'
ORDER BY r.req_ymd, r.return_no;

-- SKU 발행 필요 품목 조회
SELECT r.return_no, r.req_ymd,
       rp.prod_seq, p.prod_nm,
       rp.req_qty,
       CASE WHEN rp.pub_sku1_yn = 'Y' THEN 'SKU1' ELSE '' END AS sku1_req,
       CASE WHEN rp.pub_sku2_yn = 'Y' THEN 'SKU2' ELSE '' END AS sku2_req
FROM wms_return_prod rp
    JOIN wms_return r ON rp.return_seq = r.return_seq
    JOIN mdm_prod p ON rp.prod_seq = p.prod_seq
WHERE r.biz_seq = 1
AND (rp.pub_sku1_yn = 'Y' OR rp.pub_sku2_yn = 'Y')
AND rp.return_prod_sts_cd != '77'
AND rp.del_yn = 'N'
ORDER BY r.req_ymd, r.return_no;

-- 파렛타이징 필요 품목 조회
SELECT r.return_no, r.req_ymd,
       rp.prod_seq, p.prod_nm,
       rp.req_qty, rp.ex_qty
FROM wms_return_prod rp
    JOIN wms_return r ON rp.return_seq = r.return_seq
    JOIN mdm_prod p ON rp.prod_seq = p.prod_seq
WHERE r.biz_seq = 1
AND rp.pltzing_yn = 'Y'
AND rp.return_prod_sts_cd != '77'
AND rp.del_yn = 'N'
ORDER BY r.req_ymd, r.return_no;

-- IF 송신 대기 품목 조회
SELECT r.return_no, r.req_ymd,
       rp.prod_seq, p.prod_nm,
       rp.req_qty, rp.if_idx
FROM wms_return_prod rp
    JOIN wms_return r ON rp.return_seq = r.return_seq
    JOIN mdm_prod p ON rp.prod_seq = p.prod_seq
WHERE r.biz_seq = 1
AND rp.if_send_yn = 'N'
AND rp.del_yn = 'N'
AND r.del_yn = 'N'
ORDER BY rp.reg_dt;

-- 품목별 처리 이력 요약
SELECT rp.return_prod_seq, p.prod_nm,
       rp.req_qty, rp.ex_qty,
       COUNT(rt.return_tran_seq) AS tran_count,
       SUM(rt.proc_qty) AS total_proc_qty
FROM wms_return_prod rp
    JOIN mdm_prod p ON rp.prod_seq = p.prod_seq
    LEFT JOIN wms_return_tran rt ON rp.return_prod_seq = rt.return_prod_seq
        AND rt.del_yn = 'N'
WHERE rp.return_seq = 1001
AND rp.del_yn = 'N'
GROUP BY rp.return_prod_seq, p.prod_nm, rp.req_qty, rp.ex_qty
ORDER BY rp.return_prod_seq;

-- 예상 유통기한 임박 품목 조회
SELECT r.return_no, r.req_ymd,
       rp.prod_seq, p.prod_nm,
       rp.est_exp_ymd,
       CURRENT_DATE - TO_DATE(rp.est_exp_ymd, 'YYYYMMDD') AS exp_d_day
FROM wms_return_prod rp
    JOIN wms_return r ON rp.return_seq = r.return_seq
    JOIN mdm_prod p ON rp.prod_seq = p.prod_seq
WHERE r.biz_seq = 1
AND rp.est_exp_ymd IS NOT NULL
AND TO_DATE(rp.est_exp_ymd, 'YYYYMMDD') <= CURRENT_DATE + INTERVAL '30 days'
AND rp.return_prod_sts_cd != '77'
AND rp.del_yn = 'N'
ORDER BY rp.est_exp_ymd;
```