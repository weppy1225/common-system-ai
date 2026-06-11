# wms_inbiz_prod (WMS_입하품목)

## 1. 개요
`wms_inbiz`(입하)에 속한 **품목 단위 상세 정보**를 관리하는 테이블.
구매발주 품목별로 요청 수량, 처리 상태, LOT 정보 등을 저장하며, 실제 입고 처리(`wms_inwh_prod`)와 연결된다.

### 1.1 입하품목 처리 흐름
```
wms_inbiz (입하 헤더)
└─ wms_inbiz_prod (입하 품목) ← **현재 테이블**
        └─ wms_inbiz_inwh (입하-입고 연결)
              └─ wms_inwh_prod (입고 품목)
                    └─ wms_inwh_tran (입고 처리 이력) → 재고 증가
                          └─ wms_inwh_label (입고 라벨)
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | inbiz_prod_seq | bigint | N | nextval('wms_inbiz_prod_seq') | 입하품목 SEQ |
| FK | inbiz_seq | integer | N | | 입하 SEQ → wms_inbiz |
| FK | prod_seq | integer | N | | 품목 SEQ → mdm_prod |
| | inbiz_prod_sts_cd | varchar(50) | N | | 입하품목 상태 코드 |
| | req_qty | decimal(10,2) | N | 0 | 요청 수량 |
| | ex_qty | decimal(10,2) | N | 0 | 기처리 수량 |
| | lot_no | varchar(30) | Y | | LOT 번호 |
| | if_send_yn | char(1) | N | 'N' | IF 송신 여부 |
| | if_idx | varchar(20) | Y | | IF 내부순번 |
| | if_err_seq | integer | Y | | IF 에러 SEQ |
| | del_yn | char(1) | N | 'N' | 삭제 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

> **inbiz_prod_sts_cd** (`INWH_PROD_STS_CD`)
>
> | 코드 | 코드명 |
> |---|---|
> | 11 | 예정 |
> | 55 | 처리중 |
> | 77 | 확정 |

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
| wms_inbiz_prod_PK | inbiz_prod_seq, inbiz_seq | Y | Y |
| IX_wms_inbiz_prod_prod | prod_seq | N | |
| IX_wms_inbiz_prod_sts | inbiz_prod_sts_cd | N | |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| inbiz_prod_seq | wms_inbiz_prod_seq |

---

## 5. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| inbiz_seq | wms_inbiz | inbiz_seq | wms_inbiz_TO_wms_inbiz_prod |
| prod_seq | mdm_prod | prod_seq | mdm_prod_TO_wms_inbiz_prod |

---

## 6. 참조됨 (참조하는 테이블)

| 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|
| wms_inbiz_inwh | inbiz_prod_seq, inbiz_seq | wms_inbiz_prod_TO_wms_inbiz_inwh |

---

## 7. 업무 규칙

### 7.1 입하품목 생성
- 외부 시스템(ERP)에서 입하 정보 수신 시 생성
- `inbiz_prod_sts_cd = '11'(예정)` 으로 시작
- `req_qty` : 발주 요청 수량

### 7.2 수량 관리
- `req_qty` : 입하 요청 수량 (구매발주 수량)
- `ex_qty` : 실제 입고 처리(`wms_inwh_tran`)된 누적 수량
- 모든 수량이 처리되면(`ex_qty = req_qty`) 상태는 `'77'(확정)` 으로 자동 변경

### 7.3 상태 변화

| 상태 | 코드 | 설명 |
|---|---|---|
| 예정 | 11 | 입하 요청 등록 |
| 처리중 | 55 | 일부 입고 처리됨 |
| 확정 | 77 | 전량 입고 완료 |

### 7.4 LOT 정보
- `lot_no` : 입하 단계에서 예상 LOT 번호 입력 가능
- 실제 입고 시 `wms_inwh_tran`의 `lot_no`와 다를 수 있음

### 7.5 입고 연결
- `wms_inbiz_inwh`를 통해 실제 입고 품목과 연결
- 하나의 입하품목이 여러 입고품목으로 분할될 수 있음 (분할 입고)
- 입고 처리 시 `ex_qty` 누적 증가

### 7.6 IF 송신
- `if_send_yn` : 외부 시스템(ERP)으로 입하품목 정보 송신 여부 관리
- 최초 등록 시 'N', 송신 성공 시 'Y', 실패 시 'E'
- `if_idx` : 외부 시스템에서의 순번 정보 (발주 라인번호 등)

### 7.7 부분 입고
- 하나의 입하품목에 대해 여러 번에 나누어 입고 가능
- 각 입고 건마다 `ex_qty` 누적
- 잔여 수량 = `req_qty - ex_qty`

### 7.8 취소/삭제
- 입하 확정(`'77'`) 후에는 변경 불가
- 미확정 상태에서만 수정/삭제 가능
- 물리삭제 금지 — `del_yn = 'Y'` 로 논리삭제 처리

---

## 8. 주요 조회 예시

```sql
-- 입하별 품목 현황
SELECT i.inbiz_no, i.po_no,
       ip.inbiz_prod_seq, p.prod_nm,
       ip.req_qty, ip.ex_qty,
       ip.inbiz_prod_sts_cd, ip.lot_no
FROM wms_inbiz_prod ip
    JOIN wms_inbiz i ON ip.inbiz_seq = i.inbiz_seq
    JOIN mdm_prod p ON ip.prod_seq = p.prod_seq
WHERE i.biz_seq = 1
AND i.center_seq = 1
AND i.req_ymd = '20250226'
AND ip.del_yn = 'N'
ORDER BY i.inbiz_no, ip.inbiz_prod_seq;

-- 특정 입하의 품목 상세
SELECT ip.inbiz_prod_seq, p.prod_no, p.prod_nm,
       ip.req_qty, ip.ex_qty,
       ip.inbiz_prod_sts_cd,
       ip.lot_no,
       (SELECT COUNT(*) FROM wms_inbiz_inwh 
        WHERE inbiz_prod_seq = ip.inbiz_prod_seq) AS inwh_link_cnt
FROM wms_inbiz_prod ip
    JOIN mdm_prod p ON ip.prod_seq = p.prod_seq
WHERE ip.inbiz_seq = 100
AND ip.del_yn = 'N'
ORDER BY ip.inbiz_prod_seq;

-- 미완료 입하품목 목록 (예정/처리중)
SELECT ip.inbiz_prod_seq, i.inbiz_no,
       p.prod_nm, ip.req_qty, ip.ex_qty,
       (ip.req_qty - ip.ex_qty) AS remain_qty,
       ip.inbiz_prod_sts_cd,
       ip.lot_no
FROM wms_inbiz_prod ip
    JOIN wms_inbiz i ON ip.inbiz_seq = i.inbiz_seq
    JOIN mdm_prod p ON ip.prod_seq = p.prod_seq
WHERE i.biz_seq = 1
AND ip.inbiz_prod_sts_cd IN ('11', '55')
AND ip.del_yn = 'N'
ORDER BY i.req_ymd, i.inbiz_no;

-- 입하품목과 입고품목 연결 조회
SELECT ip.inbiz_prod_seq, i.inbiz_no,
       iwp.inwh_prod_seq, iw.inwh_no,
       ip.req_qty AS inbiz_qty,
       iwp.req_qty AS inwh_qty,
       iwp.ex_qty AS inwh_ex_qty
FROM wms_inbiz_prod ip
    JOIN wms_inbiz i ON ip.inbiz_seq = i.inbiz_seq
    LEFT JOIN wms_inbiz_inwh ibi ON ip.inbiz_prod_seq = ibi.inbiz_prod_seq
    LEFT JOIN wms_inwh_prod iwp ON ibi.inwh_prod_seq = iwp.inwh_prod_seq
    LEFT JOIN wms_inwh iw ON iwp.inwh_seq = iw.inwh_seq
WHERE i.biz_seq = 1
AND i.inbiz_no = 'IB2502260001'
AND ip.del_yn = 'N'
ORDER BY ip.inbiz_prod_seq;

-- 품목별 입하 현황
SELECT p.prod_nm,
       COUNT(DISTINCT ip.inbiz_prod_seq) AS inbiz_prod_cnt,
       COUNT(DISTINCT ip.inbiz_seq) AS inbiz_cnt,
       SUM(ip.req_qty) AS total_req_qty,
       SUM(ip.ex_qty) AS total_ex_qty,
       ROUND(SUM(ip.ex_qty) * 100.0 / NULLIF(SUM(ip.req_qty), 0), 2) AS completion_rate
FROM wms_inbiz_prod ip
    JOIN mdm_prod p ON ip.prod_seq = p.prod_seq
WHERE ip.biz_seq = 1
AND ip.reg_dt >= CURRENT_DATE - INTERVAL '30 days'
AND ip.del_yn = 'N'
GROUP BY p.prod_nm
ORDER BY total_req_qty DESC;

-- 상태별 입하품목 현황
SELECT
    ip.inbiz_prod_sts_cd,
    COUNT(*) AS prod_cnt,
    SUM(ip.req_qty) AS total_qty,
    SUM(ip.ex_qty) AS processed_qty
FROM wms_inbiz_prod ip
    JOIN wms_inbiz i ON ip.inbiz_seq = i.inbiz_seq
WHERE i.biz_seq = 1
AND i.req_ymd = '20250226'
AND ip.del_yn = 'N'
GROUP BY ip.inbiz_prod_sts_cd
ORDER BY ip.inbiz_prod_sts_cd;

-- LOT별 입하 현황
SELECT
    ip.lot_no,
    p.prod_nm,
    COUNT(ip.inbiz_prod_seq) AS prod_cnt,
    SUM(ip.req_qty) AS total_qty
FROM wms_inbiz_prod ip
    JOIN mdm_prod p ON ip.prod_seq = p.prod_seq
WHERE ip.biz_seq = 1
AND ip.lot_no IS NOT NULL
AND ip.reg_dt >= CURRENT_DATE - INTERVAL '30 days'
AND ip.del_yn = 'N'
GROUP BY ip.lot_no, p.prod_nm
ORDER BY ip.lot_no;

-- IF 송신 대기 건 조회
SELECT ip.inbiz_prod_seq, i.inbiz_no, p.prod_nm,
       ip.req_qty, ip.ex_qty,
       ip.inbiz_prod_sts_cd, ip.if_idx
FROM wms_inbiz_prod ip
    JOIN wms_inbiz i ON ip.inbiz_seq = i.inbiz_seq
    JOIN mdm_prod p ON ip.prod_seq = p.prod_seq
WHERE i.biz_seq = 1
AND ip.if_send_yn = 'N'
AND ip.del_yn = 'N'
ORDER BY ip.reg_dt;

-- 잔여 수량이 많은 입하품목 (미입고)
SELECT ip.inbiz_prod_seq, i.inbiz_no,
       p.prod_nm, ip.req_qty, ip.ex_qty,
       (ip.req_qty - ip.ex_qty) AS remain_qty,
       ip.inbiz_prod_sts_cd
FROM wms_inbiz_prod ip
    JOIN wms_inbiz i ON ip.inbiz_seq = i.inbiz_seq
    JOIN mdm_prod p ON ip.prod_seq = p.prod_seq
WHERE i.biz_seq = 1
AND ip.ex_qty < ip.req_qty
AND ip.del_yn = 'N'
ORDER BY remain_qty DESC
LIMIT 20;
```