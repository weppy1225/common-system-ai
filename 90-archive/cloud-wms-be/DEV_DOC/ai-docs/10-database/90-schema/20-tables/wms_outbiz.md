# wms_outbiz (WMS_출하)

## 1. 개요
고객/수신처에게 물품을 출고하는 **출하(出荷) 요청 헤더** 테이블.
출하 유형(`outbiz_type_cd`)에 따라 일반출하·송장출하·상차출하·즉시출하로 구분되며, 각 유형별로 연결되는 처리 테이블이 다르다.

### 1.1 출하 유형별 처리 흐름
```
wms_outbiz (출하 헤더)
└─ wms_outbiz_prod (출하 품목)
        ├─ wms_outbiz_tran   : 일반/즉시출하 처리 이력
        ├─ wms_outbiz_invoice: 송장출하 연결 (→ wms_invoice)
        ├─ wms_outbiz_load   : 상차출하 연결 (→ wms_load)
        └─ wms_outbiz_outwh  : 출고지시 연결 (→ wms_outwh)
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | outbiz_seq | integer | N | nextval('wms_outbiz_seq') | 출하 SEQ |
| | biz_seq | integer | N | | 사업장 SEQ → mdm_biz |
| | center_seq | integer | N | | 센터 SEQ → mdm_center |
| | cont_seq | integer | Y | | 거래처 SEQ → mdm_cont (주문처) |
| | outbiz_no | varchar(30) | N | | 출하 번호 (문서번호) |
| | outbiz_type_cd | varchar(50) | N | | 출하 유형 코드 |
| | outbiz_sts_cd | varchar(50) | N | '11' | 출하 상태 코드 |
| | outbiz_proc_type_cd | varchar(50) | N | | 출하 처리 타입 코드 |
| | trn_type_cd | varchar(50) | Y | | 운송 구분 코드 |
| | outwh_proc_yn | char(1) | N | 'Y' | 출고처리 유무 |
| | auto_outbiz_yn | char(1) | N | 'N' | 자동출하 유무 |
| | if_device_cd | varchar(50) | N | '-' | IF 장치 코드 |
| | outbiz_stop_yn | char(1) | N | 'N' | 출하중단 유무 |
| | sales_user_nm | varchar(100) | Y | | 영업 담당자명 |
| | sales_dept_nm | varchar(100) | Y | | 영업 부서명 |
| | req_ymd | varchar(8) | N | | 요청 일자 (YYYYMMDD) |
| | req_hms | varchar(6) | Y | | 요청 시간 (HHMMSS) |
| | req_user_nm | varchar(100) | N | | 요청자명 |
| | so_ymd | varchar(8) | Y | | 주문 일자 (YYYYMMDD) |
| | so_hms | varchar(6) | Y | | 주문 시간 (HHMMSS) |
| | so_no | varchar(30) | Y | | 주문 번호 |
| | req_no | varchar(30) | Y | | 문서 번호 (타시스템) |
| | erp_wh_cd | varchar(50) | Y | | ERP 창고 코드 |
| | delivery_nm | varchar(100) | Y | | 납품처명 |
| | delivery_ymd | varchar(8) | Y | | 납품 일자 (YYYYMMDD) |
| | delivery_hms | varchar(6) | Y | | 납품 시간 (HHMMSS) |
| | delivery_mng_nm | varchar(100) | Y | | 납품처 담당자명 |
| | delivery_tel | varchar(500) | Y | | 납품처 전화번호 |
| | delivery_addr | varchar(200) | Y | | 납품처 주소 |
| | delivery_addr_dtl | varchar(200) | Y | | 납품처 상세주소 |
| | ord_nm | varchar(100) | Y | | 주문자명 |
| | rcv_nm | varchar(100) | Y | | 받는자명 |
| | rcv_tel | varchar(500) | Y | | 받는자 전화번호 |
| | rcv_addr | varchar(200) | Y | | 받는자 주소 |
| | rcv_addr_dtl | varchar(200) | Y | | 받는자 상세주소 |
| | rcv_post_no | varchar(10) | Y | | 받는자 우편번호 |
| | send_nm | varchar(100) | Y | | 보내는자명 |
| | send_tel | varchar(500) | Y | | 보내는자 전화번호 |
| | invoice_info | varchar(1000) | Y | | 송장 설정 정보 |
| | cfm_ymd | varchar(8) | Y | | 확정 일자 (YYYYMMDD) |
| | cfm_hms | varchar(6) | Y | | 확정 시간 (HHMMSS) |
| | cfm_user_id | varchar(20) | Y | | 확정자 ID |
| | ship_msg | varchar(1000) | Y | | 배송 메시지 |
| | inwh_seq | integer | Y | | 입고 SEQ (반품 등) |
| | dlv_config_seq | integer | Y | | 택배사 설정 SEQ |
| | note | varchar(1000) | Y | | 비고 |
| | if_key | varchar(50) | Y | | IF 연동 키 |
| | if_err_seq | integer | Y | | IF 에러 SEQ |
| | if_send_yn | char(1) | N | 'N' | IF 송신 여부 |
| | del_yn | char(1) | N | 'N' | 삭제 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

> **outbiz_type_cd** (`OUTBIZ_TYPE_CD`)
>
> | 코드 | 코드명 | 비고 |
> |---|---|---|
> | OB01 | 일반출하 | 일반 출하 처리 |
> | OB03 | 송장출하 | wms_invoice 연결 |
> | OB05 | 상차출하 | wms_load 연결 |
> | OB07 | 즉시출하 | 즉시 출하 처리 |
> | OB71 | 송장출하(WES) | WES 연동 |

> **outbiz_sts_cd** (`OUTBIZ_STS_CD`)
>
> | 코드 | 코드명 |
> |---|---|
> | 11 | 예정 |
> | 13 | 주소오류 |
> | 15 | 재고부족 |
> | 17 | 준비 |
> | 55 | 처리중 |
> | 77 | 확정 |
> | 99 | 취소 |

> **outbiz_proc_type_cd** (`OUTBIZ_PROC_TYPE_CD`)
>
> | 코드 | 코드명 | 비고 |
> |---|---|---|
> | C | 차량 | 차량 배송 |
> | D | 택배 | 택배 배송 |
> | N | 지정안함 | |

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
| wms_outbiz_PK | outbiz_seq | Y | Y |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| outbiz_seq | wms_outbiz_seq |

---

## 5. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| cont_seq | mdm_cont | cont_seq | mdm_cont_TO_wms_outbiz |
| dlv_config_seq | sm_dlv_config | dlv_config_seq | sm_dlv_config_TO_wms_outbiz |
| inwh_seq | wms_inwh | inwh_seq | wms_inwh_TO_wms_outbiz |

---

## 6. 참조됨 (참조하는 테이블)

| 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|
| wms_outbiz_prod | outbiz_seq | wms_outbiz_TO_wms_outbiz_prod |
| wms_outbiz_invoice | outbiz_seq | wms_outbiz_TO_wms_outbiz_invoice |
| wms_outbiz_load | outbiz_seq | wms_outbiz_TO_wms_outbiz_load |
| wms_outbiz_outwh | outbiz_seq | wms_outbiz_TO_wms_outbiz_outwh |
| wms_outbiz_tran | outbiz_seq | wms_outbiz_TO_wms_outbiz_tran |

---

## 7. 업무 규칙

### 7.1 출하 등록
- `outbiz_no` : `mdm_doc_no` 기반으로 사업장별 채번 (수불유형 `OB`)
- 출하 등록 시 `outbiz_sts_cd = '11'(예정)` 으로 시작
- 주소 오류 감지 시 `'13'`, 재고 부족 시 `'15'`로 자동 전환
- `outbiz_proc_type_cd` : 택배(`D`) → 송장출하(OB03), 차량(`C`) → 상차출하(OB05) 연계

### 7.2 출하 유형별 처리

#### 7.2.1 OB01 (일반출하)
- `wms_outbiz_prod` → `wms_outbiz_tran` 직접 연결
- 재고 차감 및 출하 처리

#### 7.2.2 OB03 (송장출하)
- `wms_outbiz_prod` → `wms_outbiz_invoice` → `wms_invoice` 연결
- 송장 발행 후 출하 처리

#### 7.2.3 OB05 (상차출하)
- `wms_outbiz_prod` → `wms_outbiz_load` → `wms_load` 연결
- 상차 작업 후 출하 처리

#### 7.2.4 OB07 (즉시출하)
- 일반출하와 동일하나 즉시 처리
- `auto_outbiz_yn` = 'Y' 가능

### 7.3 출하 처리 단계
1. **출하지시** : 재고 할당 (`wms_outwh_assign` 참조)
2. **출고 처리** : 실제 창고에서 물품 출고 (`wms_outwh_tran`)
3. **출하 확정** : 출하 완료 처리 (`outbiz_sts_cd` = '77')

### 7.4 상태 변경
- 확정(`'77'`) 후에는 변경 불가 — 취소(`'99'`)만 가능
- 취소 시 할당된 재고는 복원 처리
- 출하중단(`outbiz_stop_yn` = 'Y') 설정 시 해당 출하는 처리 중단

### 7.5 IF 연동
- `if_send_yn` : 외부 시스템(ERP)으로 출하 정보 송신 여부 관리
- 최초 등록 시 'N', 송신 성공 시 'Y', 실패 시 'E'

### 7.6 물리삭제
- 물리삭제 금지 — `del_yn = 'Y'` 로 논리삭제 처리

---

## 8. 주요 조회 예시

```sql
-- 출하 유형별 현황
SELECT outbiz_type_cd, outbiz_sts_cd, COUNT(*) AS cnt
FROM wms_outbiz
WHERE biz_seq = 1
AND center_seq = 1
AND req_ymd = '20250225'
GROUP BY outbiz_type_cd, outbiz_sts_cd
ORDER BY outbiz_type_cd, outbiz_sts_cd;

-- 미처리 출하 목록 (주소오류/재고부족 포함)
SELECT ob.outbiz_no, c.cont_nm, ob.outbiz_type_cd,
       ob.outbiz_sts_cd, ob.req_ymd,
       ob.rcv_nm, ob.rcv_addr
FROM wms_outbiz ob
    LEFT JOIN mdm_cont c ON ob.cont_seq = c.cont_seq
WHERE ob.biz_seq = 1
AND ob.center_seq = 1
AND ob.outbiz_sts_cd NOT IN ('77', '99')
AND ob.del_yn = 'N'
ORDER BY ob.req_ymd, ob.outbiz_no;

-- 출하 유형별 상세 조회 (송장출하)
SELECT ob.outbiz_no, ob.req_ymd, ob.rcv_nm,
       iv.invoice_no, iv.invoice_sts_cd
FROM wms_outbiz ob
    JOIN wms_outbiz_invoice obi ON ob.outbiz_seq = obi.outbiz_seq
    JOIN wms_invoice iv ON obi.invoice_seq = iv.invoice_seq
WHERE ob.biz_seq = 1
AND ob.outbiz_type_cd = 'OB03'
AND ob.req_ymd = '20250225'
AND ob.del_yn = 'N';

-- 출하 유형별 상세 조회 (상차출하)
SELECT ob.outbiz_no, ob.req_ymd, ob.rcv_nm,
       ld.load_no, ld.load_sts_cd, ld.car_seq
FROM wms_outbiz ob
    JOIN wms_outbiz_load obl ON ob.outbiz_seq = obl.outbiz_seq
    JOIN wms_load ld ON obl.load_seq = ld.load_seq
WHERE ob.biz_seq = 1
AND ob.outbiz_type_cd = 'OB05'
AND ob.req_ymd = '20250225'
AND ob.del_yn = 'N';

-- 출하 처리 현황 (품목 포함)
SELECT ob.outbiz_no, ob.outbiz_type_cd, ob.outbiz_sts_cd,
       ob.req_ymd, ob.rcv_nm,
       COUNT(op.outbiz_prod_seq) AS prod_cnt,
       SUM(op.req_qty) AS total_qty
FROM wms_outbiz ob
    LEFT JOIN wms_outbiz_prod op ON ob.outbiz_seq = op.outbiz_seq
WHERE ob.biz_seq = 1
AND ob.req_ymd BETWEEN '20250201' AND '20250228'
AND ob.del_yn = 'N'
GROUP BY ob.outbiz_seq, ob.outbiz_no, ob.outbiz_type_cd,
         ob.outbiz_sts_cd, ob.req_ymd, ob.rcv_nm
ORDER BY ob.req_ymd;

-- IF 송신 대기 건 조회
SELECT outbiz_no, outbiz_type_cd, outbiz_sts_cd,
       req_ymd, rcv_nm
FROM wms_outbiz
WHERE biz_seq = 1
AND if_send_yn = 'N'
AND del_yn = 'N'
ORDER BY reg_dt;
```