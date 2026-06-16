# wms_return (WMS_반품)

## 1. 개요
거래처로부터 반품된 물품을 입고 처리하는 **반품 요청 헤더** 테이블.
반품 유형(`return_type_cd`)에 따라 일반반품·클레임반품·교환반품·기타반품으로 구분되며, 검수 절차를 통해 양품/불량 판정 후 창고에 입고된다.

### 1.1 반품 처리 흐름
```
wms_return (반품 헤더)
└─ wms_return_prod (반품 품목)
        └─ wms_return_tran (반품 처리 이력 → 재고 증가)
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | return_seq | integer | N | nextval('wms_return_seq') | 반품 SEQ |
| | biz_seq | integer | N | | 사업장 SEQ → mdm_biz |
| | center_seq | integer | N | | 센터 SEQ → mdm_center |
| | cont_seq | integer | Y | | 거래처 SEQ → mdm_cont (반품처) |
| | return_no | varchar(30) | N | | 반품 번호 (문서번호) |
| | return_type_cd | varchar(50) | N | | 반품 유형 코드 |
| | return_sts_cd | varchar(50) | N | '11' | 반품 상태 코드 |
| | req_ymd | varchar(8) | N | | 요청 일자 (YYYYMMDD) |
| | req_hms | varchar(6) | Y | | 요청 시간 (HHMMSS) |
| | req_user_nm | varchar(100) | Y | | 요청자명 |
| | cfm_ymd | varchar(8) | Y | | 확정 일자 (YYYYMMDD) |
| | cfm_hms | varchar(6) | Y | | 확정 시간 (HHMMSS) |
| | cfm_user_id | varchar(20) | Y | | 확정자 ID |
| | req_no | varchar(30) | Y | | 문서 번호 (타시스템) |
| | erp_wh_cd | varchar(50) | Y | | 반품처 코드 (타시스템) |
| | outbiz_seq | integer | Y | | 출하 SEQ (원출하 연결) |
| | note | varchar(1000) | Y | | 비고 |
| | if_key | varchar(50) | Y | | IF 연동 키 |
| | if_err_seq | integer | Y | | IF 에러 SEQ |
| | if_send_yn | char(1) | N | 'N' | IF 송신 여부 |
| | del_yn | char(1) | N | 'N' | 삭제 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

> **return_type_cd** (`RETURN_TYPE_CD` - [공통코드](#return_type_cd))
>
> | 코드 | 코드명 | 비고 |
> |---|---|---|
> | RT01 | 일반반품 | 일반 반품 입고 |
> | RT03 | 클레임반품 | 클레임에 의한 반품 |
> | RT31 | 교환반품 | 교환 처리 반품 |
> | RT91 | 기타반품 | 기타 반품 |

> **return_sts_cd** (`RETURN_STS_CD`)
>
> | 코드 | 코드명 |
> |---|---|
> | 11 | 예정 |
> | 55 | 처리중 |
> | 77 | 확정 |
> | 78 | 강제확정 |

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
| wms_return_PK | return_seq | Y | Y |
| UIX_wms_return | biz_seq, return_no | Y | |
| IX_wms_return | biz_seq, center_seq, req_ymd | N | |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| return_seq | wms_return_seq |

---

## 5. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| cont_seq | mdm_cont | cont_seq | mdm_cont_TO_wms_return |
| outbiz_seq | wms_outbiz | outbiz_seq | wms_outbiz_TO_wms_return |

---

## 6. 참조됨 (참조하는 테이블)

| 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|
| wms_return_prod | return_seq | wms_return_TO_wms_return_prod |
| wms_return_tran | return_seq | wms_return_TO_wms_return_tran |

---

## 7. 업무 규칙

### 7.1 반품 등록
- `return_no` : `mdm_doc_no` 기반으로 사업장별 채번 (수불유형 `RT`)
- 반품 등록 시 `return_sts_cd = '11'(예정)` 으로 시작
- `outbiz_seq` 연결 시 원출하 정보 참조 가능

### 7.2 반품 유형별 처리

#### 7.2.1 RT01 (일반반품)
- 검수 후 양품/불량 판정하여 창고 입고
- 일반적인 반품 처리 프로세스

#### 7.2.2 RT03 (클레임반품)
- 클레임(불량/하자 등)에 의한 반품
- 검수 시 불량 판정 확률 높음
- 불량품은 별도 불량창고로 입고 처리

#### 7.2.3 RT31 (교환반품)
- 교환을 위한 반품
- 교환 처리 시 신규 출하(`wms_outbiz`) 연계 가능

#### 7.2.4 RT91 (기타반품)
- 위 유형에 해당하지 않는 반품

### 7.3 반품 처리 단계

#### 7.3.1 반품 예정
- 반품 정보 등록 (`return_sts_cd = '11'`)
- 예상 유통기한(`est_exp_ymd`), 제조일자(`est_mng_ymd`), LOT번호(`est_lot_no`) 입력 가능

#### 7.3.2 반품 검수
- 검수 진행 (`return_sts_cd = '55'`)
- 실제 유통기한/제조일자/LOT번호 확인 및 입력
- 양품/불량 판정 (`return_prod_sts_cd` 관리)
- 수량 확인 (`req_qty` 대비 실제 입고 수량)

#### 7.3.3 반품 확정
- 반품 완료 처리 (`return_sts_cd = '77'`)
- `cfm_ymd`, `cfm_hms`, `cfm_user_id` 기록
- `wms_return_tran` 생성하여 실제 창고 입고 처리
- 재고(`wms_inven`) 증가

### 7.4 강제확정
- `return_sts_cd = '78'` : 강제 확정
- 검수 절차 없이 반품 확정 처리 (긴급 상황 등)
- 재고는 증가하나 검수 이력 미비

### 7.5 원출하 연동
- `outbiz_seq`를 통해 원출하 정보 연결
- 반품 사유 확인 및 재고 이력 추적에 활용

### 7.6 입고 처리
- `wms_return_tran` : 실제 창고 입고 이력
- 입고 처리 시 재고 증가 (`wms_inven`)
- `proc_qty`만큼 입고 처리, `ex_qty`는 누적 처리량
- `to_wh_seq`, `to_loc_seq` 지정하여 입고 위치 결정

### 7.7 품목별 속성
- `pub_sku1_yn`, `pub_sku2_yn` : 라벨 발행 여부
- `pltzing_yn` : 파렛타이징 여부 (파렛트 단위 보관)
- `est_exp_ymd`, `est_mng_ymd`, `est_lot_no` : 예상 유통기한/제조일자/LOT번호 (접수 단계)
- 실제 값은 `wms_return_tran`에서 관리

### 7.8 상태 코드 변경
- `return_prod_sts_cd` : 품목별 상태 관리
- `return_sts_cd` : 헤더 전체 상태 관리
- 확정(`'77'`) 후에는 변경 불가 — 취소는 삭제 처리(`del_yn`)로 대체
- 취소 시 입고된 재고는 차감 처리 필요

### 7.9 IF 연동
- `if_send_yn` : 외부 시스템(ERP)으로 반품 정보 송신 여부 관리
- 최초 등록 시 'N', 송신 성공 시 'Y', 실패 시 'E'

### 7.10 물리삭제
- 물리삭제 금지 — `del_yn = 'Y'` 로 논리삭제 처리
- 삭제 시 관련 하위 데이터(`wms_return_prod`, `wms_return_tran`)도 논리삭제 처리

---

## 8. 주요 조회 예시

```sql
-- 반품 유형별 현황
SELECT return_type_cd, return_sts_cd, COUNT(*) AS cnt
FROM wms_return
WHERE biz_seq = 1
AND center_seq = 1
AND req_ymd = '20250225'
AND del_yn = 'N'
GROUP BY return_type_cd, return_sts_cd
ORDER BY return_type_cd, return_sts_cd;

-- 미처리 반품 목록 (예정/처리중)
SELECT r.return_no, c.cont_nm, r.return_type_cd,
       r.return_sts_cd, r.req_ymd, r.req_user_nm
FROM wms_return r
    LEFT JOIN mdm_cont c ON r.cont_seq = c.cont_seq
WHERE r.biz_seq = 1
AND r.center_seq = 1
AND r.return_sts_cd NOT IN ('77', '78')
AND r.del_yn = 'N'
ORDER BY r.req_ymd, r.return_no;

-- 반품 상세 조회 (품목 포함)
SELECT r.return_no, r.req_ymd, r.req_user_nm,
       rp.prod_seq, p.prod_nm, p.prod_no,
       rp.req_qty, rp.ex_qty,
       rp.return_prod_sts_cd,
       rp.est_exp_ymd, rp.est_lot_no,
       rp.pub_sku1_yn, rp.pub_sku2_yn, rp.pltzing_yn
FROM wms_return r
    JOIN wms_return_prod rp ON r.return_seq = rp.return_seq
    JOIN mdm_prod p ON rp.prod_seq = p.prod_seq
WHERE r.biz_seq = 1
AND r.return_no = 'RT2502250001'
AND r.del_yn = 'N'
ORDER BY rp.return_prod_seq;

-- 반품 처리 현황 (품목별 처리율)
SELECT r.return_no, r.return_type_cd, r.return_sts_cd,
       r.req_ymd,
       COUNT(rp.return_prod_seq) AS prod_cnt,
       SUM(rp.req_qty) AS total_req_qty,
       SUM(rp.ex_qty) AS total_proc_qty,
       ROUND(SUM(rp.ex_qty) * 100.0 / NULLIF(SUM(rp.req_qty), 0), 2) AS proc_rate
FROM wms_return r
    LEFT JOIN wms_return_prod rp ON r.return_seq = rp.return_seq
WHERE r.biz_seq = 1
AND r.req_ymd BETWEEN '20250201' AND '20250228'
AND r.del_yn = 'N'
GROUP BY r.return_seq, r.return_no, r.return_type_cd,
         r.return_sts_cd, r.req_ymd
ORDER BY r.req_ymd;

-- 반품 입고 처리 이력 조회
SELECT r.return_no, r.req_ymd,
       rt.return_tran_seq, rt.prod_seq, p.prod_nm,
       rt.proc_qty, rt.proc_ymd, rt.proc_hms, rt.proc_user_id,
       rt.to_wh_seq, w.wh_nm AS to_wh_nm,
       rt.to_loc_seq, l.loc_nm AS to_loc_seq,
       rt.mng_ymd, rt.exp_ymd, rt.lot_no
FROM wms_return_tran rt
    JOIN wms_return r ON rt.return_seq = r.return_seq
    JOIN mdm_prod p ON rt.prod_seq = p.prod_seq
    LEFT JOIN mdm_wh w ON rt.to_wh_seq = w.wh_seq
    LEFT JOIN mdm_loc l ON rt.to_loc_seq = l.loc_seq
WHERE r.biz_seq = 1
AND r.return_no = 'RT2502250001'
AND rt.del_yn = 'N'
ORDER BY rt.proc_ymd, rt.proc_hms;

-- IF 송신 대기 건 조회
SELECT return_no, return_type_cd, return_sts_cd,
       req_ymd, req_user_nm
FROM wms_return
WHERE biz_seq = 1
AND if_send_yn = 'N'
AND del_yn = 'N'
ORDER BY reg_dt;

-- 원출하별 반품 현황
SELECT ob.outbiz_no, ob.rcv_nm,
       r.return_no, r.return_type_cd, r.return_sts_cd,
       r.req_ymd
FROM wms_outbiz ob
    JOIN wms_return r ON ob.outbiz_seq = r.outbiz_seq
WHERE ob.biz_seq = 1
AND ob.outbiz_no = 'OB2502250001'
AND r.del_yn = 'N';

-- 센터별 반품 현황 (일자별)
SELECT center_seq, req_ymd,
       COUNT(*) AS return_cnt,
       SUM(CASE WHEN return_sts_cd = '77' THEN 1 ELSE 0 END) AS completed_cnt,
       SUM(CASE WHEN return_sts_cd = '55' THEN 1 ELSE 0 END) AS processing_cnt
FROM wms_return
WHERE biz_seq = 1
AND req_ymd BETWEEN '20250201' AND '20250228'
AND del_yn = 'N'
GROUP BY center_seq, req_ymd
ORDER BY center_seq, req_ymd;

-- 미확정 반품 중 입고 가능 상태 조회 (예정/처리중)
SELECT r.return_no, r.req_ymd,
       rp.prod_seq, p.prod_nm,
       rp.req_qty - rp.ex_qty AS pending_qty,
       rp.est_exp_ymd, rp.est_lot_no
FROM wms_return r
    JOIN wms_return_prod rp ON r.return_seq = rp.return_seq
    JOIN mdm_prod p ON rp.prod_seq = p.prod_seq
WHERE r.biz_seq = 1
AND r.return_sts_cd IN ('11', '55')
AND rp.req_qty > rp.ex_qty
AND r.del_yn = 'N'
AND rp.del_yn = 'N'
ORDER BY r.req_ymd, r.return_no;
```