# wms_invoice (WMS_송장)

## 1. 개요
출하 시 생성되는 **송장(Invoice) 정보**를 관리하는 테이블.
송장출하(OB03) 유형에서 사용되며, 택배사 연동, 송장번호 발급, 송장 상태 관리 등의 기능을 수행한다.

### 1.1 송장 처리 흐름
```
wms_outbiz (출하 헤더)
└─ wms_outbiz_prod (출하 품목)
        └─ wms_outbiz_invoice (출하-송장 연결)
              └─ wms_invoice (송장 헤더) ← **현재 테이블**
                    └─ wms_invoice_prod (송장 품목)
                          └─ wms_invoice_tran (송장 처리 이력)
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | invoice_seq | integer | N | nextval('wms_invoice_seq') | 송장 SEQ |
| | parent_invoice_seq | integer | Y | | 부모 송장 SEQ (합포장 시) |
| | biz_seq | integer | N | | 사업장 SEQ → mdm_biz |
| | invoice_no | varchar(30) | Y | | 송장 번호 |
| | invoice_sts_cd | varchar(50) | N | | 송장 상태 코드 |
| | rcpt_div_cd | varchar(50) | N | | 접수 구분 코드 |
| | invoice_pack_cd | varchar(50) | N | | 송장 포장 코드 |
| | proc_ymd | varchar(8) | Y | | 처리 일자 (YYYYMMDD) |
| | proc_hms | varchar(6) | Y | | 처리 시간 (HHMMSS) |
| | proc_user_id | varchar(20) | Y | | 처리자 ID |
| | re_print_cnt | smallint | N | 0 | 재출력 횟수 |
| | group_outwh_no | varchar(30) | Y | | 그룹 출고 번호 |
| | note | varchar(1000) | Y | | 비고 |
| | if_send_yn | char(1) | N | 'N' | IF 송신 여부 |
| | if_err_seq | integer | Y | | IF 에러 SEQ |
| | wes_if_err_seq | integer | Y | | WES IF 에러 SEQ |
| | wes_if_send_yn | char(1) | N | 'N' | WES IF 송신 여부 |
| | del_yn | char(1) | N | 'N' | 삭제 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |
| | check_yn | char(1) | N | 'N' | 확인 여부 |

> **invoice_sts_cd** (`INVOICE_STS_CD`)
>
> | 코드 | 코드명 |
> |---|---|
> | 11 | 발행 |
> | 55 | 처리중 |
> | 77 | 확정 |
> | 99 | 취소 |

> **rcpt_div_cd** (접수 구분)
>
> | 코드 | 코드명 | 비고 |
> |---|---|---|
> | 일반 | 일반접수 | |
> | 긴급 | 긴급접수 | |

> **invoice_pack_cd** (`INVOICE_PACK_CD`)
>
> | 코드 | 코드명 | 비고 |
> |---|---|---|
> | S | 단포장 | 단품 포장 |
> | M | 합포장 | 여러 상품 합포장 |

> **if_send_yn**, **wes_if_send_yn** (`IF_SEND_YN`)
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
| wms_invoice_PK | invoice_seq | Y | Y |
| IX_wms_invoice | biz_seq, group_outwh_no | N | |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| invoice_seq | wms_invoice_seq |

---

## 5. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| parent_invoice_seq | wms_invoice | invoice_seq | wms_invoice_TO_wms_invoice |

---

## 6. 참조됨 (참조하는 테이블)

| 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|
| wms_invoice_prod | invoice_seq | wms_invoice_TO_wms_invoice_prod |
| wms_invoice_tran | invoice_seq | wms_invoice_TO_wms_invoice_tran |
| wms_outbiz_invoice | invoice_seq | wms_outbiz_invoice |
| wms_outbiz_tran | invoice_seq | wms_outbiz_tran |

---

## 7. 업무 규칙

### 7.1 송장 생성
- 송장출하(OB03) 등록 시 자동 생성 또는 별도 송장 발행 프로세스로 생성
- `invoice_sts_cd = '11'(발행)` 으로 시작
- `invoice_no` : 송장 번호 발급 방식에 따라 채번
- API 연동: 택배사 API로 송장번호 발급
- 수기등록(MANUAL): 수동 입력
- 대역대(RANGE): 설정된 범위 내에서 자동 채번

### 7.2 송장 유형

#### 7.2.1 단포장(S) vs 합포장(M)
- **단포장(S)** : 하나의 출하품목이 하나의 송장으로 발행
- **합포장(M)** : 여러 출하품목이 하나의 송장으로 통합 발행
- `parent_invoice_seq`에 부모 송장 SEQ 저장
- 자식 송장들은 부모 송장으로 합포장 처리

### 7.3 송장 상태 변화
- `11`(발행) → `55`(처리중) → `77`(확정) → `99`(취소)
- 확정(`77`) 후에는 송장 번호 변경 불가
- 취소(`99`) 시 송장 무효 처리

### 7.4 송장 발급 방식 (`sm_dlv_config.invoice_assign_type_cd`)

| 코드 | 발급 방식 | 설명 |
|---|---|---|
| MANUAL | 수기등록 | 사용자가 직접 송장번호 입력 |
| API | API 연동 | 택배사 API로 실시간 발급 |
| RANGE | 대역대 | 설정된 번호 범위 내에서 순차 발급 |

### 7.5 택배사 연동
- `sm_dlv_config` 테이블에서 택배사 설정 관리
- 택배사별 API 연동으로 송장번호 발급 및 추적

### 7.6 재출력
- `re_print_cnt` : 송장 재출력 시 증가
- 라벨 용지 설정(`mdm_label_paper`)에 따라 출력 형식 지정

### 7.7 IF 송신
- `if_send_yn` : 외부 시스템(ERP)으로 송장 정보 송신 여부
- `wes_if_send_yn` : WES 시스템으로 송장 정보 송신 여부 (물류 자동화 장비 연동)

### 7.8 그룹 출고
- `group_outwh_no` : 여러 출하를 묶어서 일괄 처리할 때 사용
- 동일 그룹 내 송장들은 함께 처리/출력 가능

### 7.9 취소/삭제
- 확정(`77`)된 송장은 취소(`99`)만 가능
- 물리삭제 금지 — `del_yn = 'Y'` 로 논리삭제 처리

---

## 8. 주요 조회 예시

```sql
-- 송장 상태별 현황
SELECT invoice_sts_cd, COUNT(*) AS cnt
FROM wms_invoice
WHERE biz_seq = 1
AND reg_dt >= CURRENT_DATE - INTERVAL '7 days'
AND del_yn = 'N'
GROUP BY invoice_sts_cd
ORDER BY invoice_sts_cd;

-- 특정 출하건의 송장 정보
SELECT iv.invoice_no, iv.invoice_sts_cd,
       iv.rcpt_div_cd, iv.invoice_pack_cd,
       iv.proc_ymd, iv.proc_user_id,
       ob.outbiz_no, ob.rcv_nm, ob.rcv_addr
FROM wms_invoice iv
    JOIN wms_outbiz_invoice obi ON iv.invoice_seq = obi.invoice_seq
    JOIN wms_outbiz ob ON obi.outbiz_seq = ob.outbiz_seq
WHERE ob.biz_seq = 1
AND ob.outbiz_no = 'OB2502260001'
AND iv.del_yn = 'N';

-- 합포장 관계 조회 (부모-자식)
SELECT p.invoice_no AS parent_invoice_no,
       c.invoice_no AS child_invoice_no,
       c.invoice_sts_cd
FROM wms_invoice p
    JOIN wms_invoice c ON p.invoice_seq = c.parent_invoice_seq
WHERE p.biz_seq = 1
AND p.invoice_pack_cd = 'M'
AND p.del_yn = 'N'
ORDER BY p.invoice_no, c.invoice_no;

-- 송장별 품목 현황
SELECT iv.invoice_no, iv.invoice_sts_cd,
       COUNT(ivp.invoice_prod_seq) AS prod_cnt,
       SUM(ivp.req_qty) AS total_qty
FROM wms_invoice iv
    LEFT JOIN wms_invoice_prod ivp ON iv.invoice_seq = ivp.invoice_seq
WHERE iv.biz_seq = 1
AND iv.reg_dt >= CURRENT_DATE - INTERVAL '7 days'
AND iv.del_yn = 'N'
GROUP BY iv.invoice_no, iv.invoice_sts_cd
ORDER BY iv.reg_dt DESC;

-- 택배사별 송장 현황
SELECT dlv.dlv_co_cd,
       COUNT(iv.invoice_seq) AS invoice_cnt,
       SUM(CASE WHEN iv.invoice_sts_cd = '77' THEN 1 ELSE 0 END) AS completed_cnt
FROM wms_invoice iv
    JOIN wms_outbiz ob ON iv.group_outwh_no = ob.group_outwh_no
    JOIN sm_dlv_config dlv ON ob.dlv_config_seq = dlv.dlv_config_seq
WHERE iv.biz_seq = 1
AND iv.reg_dt >= CURRENT_DATE - INTERVAL '30 days'
AND iv.del_yn = 'N'
GROUP BY dlv.dlv_co_cd
ORDER BY invoice_cnt DESC;

-- IF 송신 대기 건 조회
SELECT invoice_no, invoice_sts_cd,
       rcpt_div_cd, invoice_pack_cd,
       reg_dt
FROM wms_invoice
WHERE biz_seq = 1
AND if_send_yn = 'N'
AND del_yn = 'N'
ORDER BY reg_dt;

-- WES 연동 대기 건 조회
SELECT invoice_no, invoice_sts_cd,
       rcpt_div_cd, invoice_pack_cd,
       group_outwh_no
FROM wms_invoice
WHERE biz_seq = 1
AND wes_if_send_yn = 'N'
AND invoice_sts_cd IN ('11', '55')
AND del_yn = 'N'
ORDER BY reg_dt;

-- 일자별 송장 발행 현황
SELECT DATE(reg_dt) AS invoice_date,
       COUNT(*) AS invoice_cnt,
       SUM(CASE WHEN invoice_sts_cd = '77' THEN 1 ELSE 0 END) AS completed_cnt
FROM wms_invoice
WHERE biz_seq = 1
AND reg_dt >= CURRENT_DATE - INTERVAL '30 days'
AND del_yn = 'N'
GROUP BY DATE(reg_dt)
ORDER BY invoice_date DESC;
```