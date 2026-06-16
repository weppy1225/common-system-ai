# mdm_biz_wh (MDM_사업장_창고)

## 1. 개요
사업장별 사용 가능한 창고를 관리하는 매핑 테이블.
창고는 센터 소속이나, 어느 사업장이 해당 창고를 사용하는지를 이 테이블로 제어한다.

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| FK | biz_seq | integer | N | | 사업장 SEQ → mdm_biz.biz_seq |
| FK | wh_seq | integer | N | | 창고 SEQ → mdm_wh.wh_seq |
| | if_wh_id | varchar(50) | Y | | IF 창고 ID (외부 연동용) |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| UK_mdm_biz_wh | biz_seq, wh_seq | Y | N |

## 4. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| biz_seq | mdm_biz | biz_seq | mdm_biz_TO_mdm_biz_wh |
| wh_seq | mdm_wh | wh_seq | mdm_wh_TO_mdm_biz_wh |

## 5. 업무 규칙
- 동일 `(biz_seq, wh_seq)` 조합 중복 불가 (UNIQUE)
- ⚠️ `use_yn` 컬럼 없음 — 소프트 삭제 정책 예외 테이블. 다른 매핑 테이블(mdm_biz_center, mdm_user_biz 등)과 달리 논리삭제 컬럼 미존재. 매핑 해제 시 애플리케이션 정책으로 관리 필요 (DB 설계 개선 검토 권장)
- `if_wh_id`: ERP 등 외부 시스템과 창고 코드 연동 시 사용

## 6. 주요 조회 예시

```sql
-- 특정 사업장의 사용 창고 목록
SELECT bw.biz_seq, b.biz_nm, bw.wh_seq, w.wh_nm, w.wh_group_cd
FROM mdm_biz_wh bw
    INNER JOIN mdm_biz b ON bw.biz_seq = b.biz_seq
    INNER JOIN mdm_wh w ON bw.wh_seq = w.wh_seq
WHERE bw.biz_seq = 1
AND w.use_yn = 'Y'
ORDER BY w.wh_nm;
```
