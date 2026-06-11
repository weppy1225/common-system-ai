# wms_inven_ad (WMS_재고조정)

## 1. 개요
**재고 수량을 조정(Adjustment)하는 요청 헤더** 테이블.
재고실사, 파손, 변질, 오류 정정 등 다양한 사유로 실제 재고와 장부 재고 간의 차이를 조정할 때 사용된다.

### 1.1 재고조정 처리 흐름
```
재고조정 요청 (수동/자동)
└─ wms_inven_ad (재고조정 헤더) ← **현재 테이블**
        └─ wms_inven_ad_prod (재고조정 품목)
              └─ wms_inven_ad_tran (재고조정 처리 이력) → 재고 증감
                    ↓
              재고모듈
              ├─ wms_inven 재고 증감
              ├─ wms_inven_sku 이력 등록
              └─ wms_inven_inout 수불이력 등록
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | ad_seq | integer | N | nextval('wms_inven_ad_seq') | 재고조정 SEQ |
| | biz_seq | integer | N | | 사업장 SEQ → mdm_biz |
| | center_seq | integer | N | | 센터 SEQ → mdm_center |
| | ad_no | varchar(30) | N | | 재고조정 번호 (문서번호) |
| | ad_type_cd | varchar(50) | N | | 재고조정 유형 코드 |
| | ad_sts_cd | varchar(50) | N | '11' | 재고조정 상태 코드 |
| | req_ymd | varchar(8) | N | | 요청 일자 (YYYYMMDD) |
| | req_hms | varchar(6) | Y | | 요청 시간 (HHMMSS) |
| | req_user_nm | varchar(100) | Y | | 요청자명 |
| | req_dept_nm | varchar(100) | Y | | 요청 부서명 |
| | req_no | varchar(30) | Y | | 문서 번호 (타시스템) |
| FK | st_seq | integer | Y | | 재고실사 SEQ → wms_st_sch |
| | note | varchar(1000) | Y | | 비고 |
| | if_send_yn | char(1) | N | 'N' | IF 송신 여부 |
| | if_key | varchar(50) | Y | | IF 연동 키 |
| | if_err_seq | integer | Y | | IF 에러 SEQ |
| | del_yn | char(1) | N | 'N' | 삭제 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

> **ad_type_cd** (`AD_TYPE_CD`)
>
> | 코드 | 코드명 | 비고 |
> |---|---|---|
> | AD01 | 실사조정 | 재고실사 결과 조정 |
> | AD91 | 기타조정 | 기타 사유 조정 |
> | AD99 | 기초조정 | 기초재고 설정 |

> **ad_sts_cd** (`AD_STS_CD`)
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
| wms_inven_ad_PK | ad_seq | Y | Y |
| UIX_wms_inven_ad | biz_seq, ad_no | Y | |
| IX_wms_inven_ad | biz_seq, center_seq, req_ymd | N | |
| IX_wms_inven_ad_st | st_seq | N | |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| ad_seq | wms_inven_ad_seq |

---

## 5. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| st_seq | wms_st_sch | st_sch_seq | wms_st_sch_TO_wms_inven_ad |

---

## 6. 참조됨 (참조하는 테이블)

| 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|
| wms_inven_ad_prod | ad_seq | wms_inven_ad_TO_wms_inven_ad_prod |

---

## 7. 업무 규칙

### 7.1 재고조정 생성
- `ad_no` : `mdm_doc_no` 기반으로 사업장별 채번 (수불유형 `AD`)
- 재고실사 결과 연동 시 자동 생성 또는 수동 생성
- `ad_sts_cd = '11'(예정)` 으로 시작

### 7.2 재고조정 유형

| 유형 | 설명 | 사용처 |
|---|---|---|
| 실사조정(AD01) | 재고실사 결과에 따른 조정 | 실사 후 차이 보정 |
| 기타조정(AD91) | 파손, 변질, 오류 등 | 예외 상황 |
| 기초조정(AD99) | 기초재고 설정 | 시스템 도입 시 |

### 7.3 재고실사 연동
- `st_seq` : 연동된 재고실사 일정 SEQ
- 실사 결과를 기반으로 조정 수량 자동 계산
- 실사 완료 후 조정 일괄 생성 가능

### 7.4 조정 방향
- **증가 조정** : 실제 재고 > 장부 재고 (양수 수량)
- **감소 조정** : 실제 재고 < 장부 재고 (음수 수량)
- 품목별로 증감 수량 지정

### 7.5 상태 변화

| 상태 | 코드 | 설명 |
|---|---|---|
| 예정 | 11 | 조정 요청 등록 |
| 처리중 | 55 | 일부 조정 처리됨 |
| 확정 | 77 | 조정 완료 (전량 처리) |

### 7.6 처리 단계

#### 7.6.1 조정 요청 등록
- 조정 대상 품목 및 수량 지정
- `ad_sts_cd = '11'`

#### 7.6.2 조정 처리
- `wms_inven_ad_tran` 생성
- 재고 증감 처리
- `ad_prod_sts_cd` 및 `ad_sts_cd` 갱신

#### 7.6.3 조정 확정
- 모든 품목 처리 완료 시 `ad_sts_cd = '77'`
- 이후 수정 불가

### 7.7 IF 송신
- `if_send_yn` : 외부 시스템(ERP/회계)으로 재고조정 정보 송신 여부 관리
- 최초 등록 시 'N', 송신 성공 시 'Y', 실패 시 'E'

### 7.8 취소/삭제
- 확정(`'77'`)된 조정은 취소 불가 (재고 변동 발생)
- 오류 시 별도의 역조정 프로세스로 처리
- 물리삭제 금지 — `del_yn = 'Y'` 로 논리삭제 처리

---

## 8. 주요 조회 예시

```sql
-- 재고조정 유형별 현황
SELECT ad_type_cd, ad_sts_cd, COUNT(*) AS cnt
FROM wms_inven_ad
WHERE biz_seq = 1
AND center_seq = 1
AND req_ymd = '20250226'
AND del_yn = 'N'
GROUP BY ad_type_cd, ad_sts_cd
ORDER BY ad_type_cd, ad_sts_cd;

-- 특정 재고조정 상세
SELECT ad_seq, ad_no, ad_type_cd, ad_sts_cd,
       req_ymd, req_user_nm, req_dept_nm,
       note, st_seq
FROM wms_inven_ad
WHERE biz_seq = 1
AND ad_no = 'AD2502260001'
AND del_yn = 'N';

-- 미처리 재고조정 목록 (예정/처리중)
SELECT ad_no, ad_type_cd, ad_sts_cd,
       req_ymd, req_user_nm,
       note
FROM wms_inven_ad
WHERE biz_seq = 1
AND center_seq = 1
AND ad_sts_cd IN ('11', '55')
AND del_yn = 'N'
ORDER BY req_ymd, ad_no;

-- 재고실사 연동 조정 조회
SELECT ad.ad_no, ad.ad_type_cd, ad.ad_sts_cd,
       ss.st_sch_seq, ss.yyyy, ss.st_idx,
       ss.st_target_cd, ss.st_sch_sts_cd
FROM wms_inven_ad ad
    JOIN wms_st_sch ss ON ad.st_seq = ss.st_sch_seq
WHERE ad.biz_seq = 1
AND ad.st_seq IS NOT NULL
AND ad.reg_dt >= CURRENT_DATE - INTERVAL '30 days'
AND ad.del_yn = 'N'
ORDER BY ad.reg_dt DESC;

-- 일자별 재고조정 현황
SELECT req_ymd,
       COUNT(*) AS total_cnt,
       SUM(CASE WHEN ad_type_cd = 'AD01' THEN 1 ELSE 0 END) AS physical_cnt,
       SUM(CASE WHEN ad_type_cd = 'AD91' THEN 1 ELSE 0 END) AS etc_cnt,
       SUM(CASE WHEN ad_sts_cd = '77' THEN 1 ELSE 0 END) AS completed_cnt
FROM wms_inven_ad
WHERE biz_seq = 1
AND req_ymd BETWEEN '20250201' AND '20250228'
AND del_yn = 'N'
GROUP BY req_ymd
ORDER BY req_ymd;

-- 유형별 조정 건수 통계
SELECT
    ad_type_cd,
    COUNT(*) AS total_cnt,
    SUM(CASE WHEN ad_sts_cd = '77' THEN 1 ELSE 0 END) AS completed_cnt,
    ROUND(SUM(CASE WHEN ad_sts_cd = '77' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS completion_rate
FROM wms_inven_ad
WHERE biz_seq = 1
AND reg_dt >= CURRENT_DATE - INTERVAL '30 days'
AND del_yn = 'N'
GROUP BY ad_type_cd
ORDER BY ad_type_cd;

-- IF 송신 대기 건 조회
SELECT ad_no, ad_type_cd, ad_sts_cd,
       req_ymd, req_user_nm
FROM wms_inven_ad
WHERE biz_seq = 1
AND if_send_yn = 'N'
AND del_yn = 'N'
ORDER BY reg_dt;

-- 부서별 재고조정 현황
SELECT req_dept_nm,
       COUNT(*) AS req_cnt,
       SUM(CASE WHEN ad_sts_cd = '77' THEN 1 ELSE 0 END) AS completed_cnt
FROM wms_inven_ad
WHERE biz_seq = 1
AND req_dept_nm IS NOT NULL
AND reg_dt >= CURRENT_DATE - INTERVAL '30 days'
AND del_yn = 'N'
GROUP BY req_dept_nm
ORDER BY req_cnt DESC;

-- 월별 재고조정 추이
SELECT TO_CHAR(reg_dt, 'YYYY-MM') AS month,
       COUNT(*) AS total_cnt,
       SUM(CASE WHEN ad_type_cd = 'AD01' THEN 1 ELSE 0 END) AS physical_adjust_cnt
FROM wms_inven_ad
WHERE biz_seq = 1
AND reg_dt >= CURRENT_DATE - INTERVAL '6 months'
AND del_yn = 'N'
GROUP BY TO_CHAR(reg_dt, 'YYYY-MM')
ORDER BY month;
```