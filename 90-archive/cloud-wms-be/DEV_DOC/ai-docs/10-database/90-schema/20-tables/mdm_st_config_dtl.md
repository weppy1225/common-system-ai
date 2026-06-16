# mdm_st_config_dtl (MDM_세트_구성_상세)

## 1. 개요
세트 구성의 상세 테이블. 세트 품목 1개를 만들기 위해 필요한 구성품 목록과 각 수량을 정의한다.
헤더는 `mdm_st_config`에서 관리.

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | st_config_dtl_seq | bigint | N | nextval('mdm_st_config_dtl_seq') | 세트 구성 상세 SEQ |
| FK | st_config_seq | integer | N | | 세트 구성 SEQ → mdm_st_config.st_config_seq |
| FK | prod_seq | integer | N | | 구성품 품목 SEQ → mdm_prod.prod_seq |
| | config_qty | numeric(10,2) | N | 1.00 | 구성 수량 |
| | reg_id | varchar(20) | N | | 등록자 |
| | reg_dt | timestamp | N | now() | 등록일 |
| | mod_id | varchar(20) | Y | | 수정자 |
| | mod_dt | timestamp | Y | | 수정일 |

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| PK_mdm_st_config_dtl | st_config_dtl_seq | Y | Y |
| FK_mdm_st_config_dtl_st_config_seq | st_config_seq | N | N |

## 4. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| st_config_seq | mdm_st_config | st_config_seq | FK_mdm_st_config_dtl_st_config_seq |

## 5. 업무 규칙
- `config_qty` : 세트 품목 1개 생산에 필요한 해당 구성품의 수량
- 공통 컬럼 `use_yn` 없음 — 헤더(`mdm_st_config`)의 `use_yn`으로 활성화 여부 제어
- 세트 작업 처리 시 이 테이블을 기준으로 구성품 재고 차감
- PK가 bigint — 구성품 수가 많은 경우를 고려

## 6. 주요 조회 예시

```sql
-- 특정 세트 구성의 구성품 목록
SELECT d.st_config_dtl_seq, d.st_config_seq,
       p.prod_seq, p.prod_no, p.prod_nm, d.config_qty, p.unit_cd
FROM mdm_st_config_dtl d
    INNER JOIN mdm_prod p ON d.prod_seq = p.prod_seq
WHERE d.st_config_seq = 10
ORDER BY d.st_config_dtl_seq;
```
