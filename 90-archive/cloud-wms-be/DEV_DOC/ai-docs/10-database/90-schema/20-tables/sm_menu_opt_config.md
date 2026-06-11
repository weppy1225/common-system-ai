# sm_menu_opt_config (시스템_메뉴_옵션_설정)

## 1. 개요
메뉴별 **옵션 설정**을 관리하는 테이블.
조회 기간 기본값, 처리일자 수정 가능 여부 등을 메뉴 단위로 설정하여 사용자 편의성과 업무 일관성을 제공한다.

### 1.1 메뉴 옵션 설정 흐름
```
메뉴별 옵션 정의 → sm_menu_opt_config 등록 → 메뉴 실행 시 옵션 적용
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | biz_seq | integer | N | | 사업장 SEQ |
| PK | menu_cd | varchar(50) | N | | 메뉴 코드 |
| | search_start_ymd | smallint | N | 0 | 검색 시작일 (기준일로부터 이전 일수) |
| | search_end_ymd | smallint | N | 0 | 검색 종료일 (기준일로부터 이후 일수) |
| | proc_ymd_edit_yn | char(1) | N | 'N' | 처리일자 수정 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

> **proc_ymd_edit_yn** (`USE_YN` 계열)
>
> | 코드 | 코드명 | 설명 |
> |---|---|---|
> | Y | 수정 가능 | 사용자가 처리일자 변경 가능 |
> | N | 수정 불가 | 처리일자 고정 (변경 불가) |

> **search_start_ymd**, **search_end_ymd**: 기준일(보통 현재일)로부터의 일수
> - 양수: 이후 날짜
> - 음수: 이전 날짜
> - 0: 기준일 당일

---

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| sm_menu_opt_config_PK | biz_seq, menu_cd | Y | Y |

---

## 4. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| menu_cd | sm_menu | menu_cd | sm_menu_TO_sm_menu_opt_config |

---

## 5. 업무 규칙

### 5.1 검색 기간 설정

**search_start_ymd**: 검색 시작일 오프셋
- `-7`: 오늘 기준 7일 전부터 검색
- `0`: 오늘부터 검색
- 양수 사용은 일반적이지 않음 (미래 검색)

**search_end_ymd**: 검색 종료일 오프셋
- `0`: 오늘까지 검색
- `7`: 오늘 기준 7일 후까지 검색 (미래 일정 조회)

**적용 예시:**
| search_start_ymd | search_end_ymd | 검색 범위 |
|-----------------|---------------|----------|
| -7 | 0 | 최근 7일간 |
| -30 | 0 | 최근 30일간 |
| -7 | 7 | 전후 7일 (14일간) |
| 0 | 30 | 향후 30일간 |

### 5.2 처리일자 수정 여부

| 값 | 설명 | 적용场景 |
|----|------|---------|
| Y | 수정 가능 | 사용자가 업무 처리일자 변경 허용 |
| N | 수정 불가 | 처리일자 고정 (시스템 일자 기준) |

**proc_ymd_edit_yn = 'N'인 경우:**
- 입력/수정 시 처리일자를 현재 일자로 강제 설정
- 과거/미래 일자 입력 불가
- 회계/감사 추적이 중요한 메뉴에 적용

### 5.3 사업장별 설정
- 동일 메뉴라도 사업장별로 다른 옵션 적용 가능
- 본사/지점별 업무 방식 차이 반영

### 5.4 기본값
| 필드 | 기본값 | 설명 |
|------|--------|------|
| search_start_ymd | 0 | 당일부터 검색 |
| search_end_ymd | 0 | 당일까지 검색 |
| proc_ymd_edit_yn | 'N' | 처리일자 수정 불가 |

---

## 6. 주요 조회 예시

```sql
-- 특정 사업장의 메뉴별 옵션 설정
SELECT m.menu_cd, m.menu_nm, m.menu_type_cd,
       o.search_start_ymd, o.search_end_ymd,
       CASE 
           WHEN o.search_start_ymd < 0 THEN CONCAT(o.search_start_ymd, '일 전부터')
           WHEN o.search_start_ymd = 0 THEN '당일부터'
           ELSE CONCAT(o.search_start_ymd, '일 후부터')
       END AS start_range_desc,
       CASE 
           WHEN o.search_end_ymd < 0 THEN CONCAT('최대 ', ABS(o.search_end_ymd), '일 전까지')
           WHEN o.search_end_ymd = 0 THEN '당일까지'
           ELSE CONCAT('최대 ', o.search_end_ymd, '일 후까지')
       END AS end_range_desc,
       o.proc_ymd_edit_yn,
       CASE o.proc_ymd_edit_yn WHEN 'Y' THEN '수정가능' ELSE '수정불가' END AS edit_desc
FROM sm_menu m
    LEFT JOIN sm_menu_opt_config o ON m.menu_cd = o.menu_cd AND o.biz_seq = 1
WHERE m.use_yn = 'Y'
ORDER BY m.menu_cd;

-- 검색 기간이 설정된 메뉴 목록
SELECT menu_cd, search_start_ymd, search_end_ymd
FROM sm_menu_opt_config
WHERE biz_seq = 1
AND (search_start_ymd != 0 OR search_end_ymd != 0)
ORDER BY menu_cd;

-- 처리일자 수정 불가 메뉴 목록
SELECT m.menu_cd, m.menu_nm
FROM sm_menu m
    JOIN sm_menu_opt_config o ON m.menu_cd = o.menu_cd
WHERE o.biz_seq = 1
AND o.proc_ymd_edit_yn = 'N'
ORDER BY m.menu_cd;

-- 특정 메뉴의 옵션 상세 조회
SELECT *
FROM sm_menu_opt_config
WHERE biz_seq = 1
AND menu_cd = 'MENU001';

-- 최근 수정된 옵션 내역
SELECT o.mod_dt, o.mod_id,
       m.menu_nm,
       o.search_start_ymd, o.search_end_ymd,
       o.proc_ymd_edit_yn
FROM sm_menu_opt_config o
    JOIN sm_menu m ON o.menu_cd = m.menu_cd
WHERE o.biz_seq = 1
AND o.mod_dt >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY o.mod_dt DESC;

-- 옵션별 메뉴 통계
SELECT
    proc_ymd_edit_yn,
    COUNT(*) AS menu_cnt,
    AVG(search_start_ymd) AS avg_start,
    AVG(search_end_ymd) AS avg_end
FROM sm_menu_opt_config
WHERE biz_seq = 1
GROUP BY proc_ymd_edit_yn;

-- 기본값과 다른 설정을 가진 메뉴
SELECT menu_cd, search_start_ymd, search_end_ymd, proc_ymd_edit_yn
FROM sm_menu_opt_config
WHERE biz_seq = 1
AND (search_start_ymd != 0 OR search_end_ymd != 0 OR proc_ymd_edit_yn != 'N')
ORDER BY menu_cd;

-- 메뉴 유형별 옵션 설정 현황
SELECT m.menu_type_cd,
       CASE m.menu_type_cd WHEN 'MG' THEN '그룹' ELSE '메뉴' END AS type_nm,
       COUNT(o.menu_cd) AS config_cnt,
       AVG(o.search_start_ymd) AS avg_start,
       AVG(o.search_end_ymd) AS avg_end
FROM sm_menu m
    LEFT JOIN sm_menu_opt_config o ON m.menu_cd = o.menu_cd AND o.biz_seq = 1
WHERE m.use_yn = 'Y'
GROUP BY m.menu_type_cd
ORDER BY m.menu_type_cd;

-- 설정이 없는 메뉴 목록 (기본값 적용)
SELECT m.menu_cd, m.menu_nm
FROM sm_menu m
    LEFT JOIN sm_menu_opt_config o ON m.menu_cd = o.menu_cd AND o.biz_seq = 1
WHERE m.use_yn = 'Y'
AND o.menu_cd IS NULL
ORDER BY m.menu_cd;

-- 사업장별 설정 비교
SELECT o1.menu_cd, m.menu_nm,
       o1.search_start_ymd AS biz1_start,
       o2.search_start_ymd AS biz2_start,
       o1.search_end_ymd AS biz1_end,
       o2.search_end_ymd AS biz2_end,
       o1.proc_ymd_edit_yn AS biz1_edit,
       o2.proc_ymd_edit_yn AS biz2_edit
FROM sm_menu_opt_config o1
    JOIN sm_menu_opt_config o2 ON o1.menu_cd = o2.menu_cd
    JOIN sm_menu m ON o1.menu_cd = m.menu_cd
WHERE o1.biz_seq = 1
AND o2.biz_seq = 2
AND (o1.search_start_ymd != o2.search_start_ymd
       OR o1.search_end_ymd != o2.search_end_ymd
       OR o1.proc_ymd_edit_yn != o2.proc_ymd_edit_yn)
ORDER BY o1.menu_cd;

-- 검색 범위가 넓은 메뉴 Top N (30일 이상)
SELECT menu_cd,
       search_start_ymd, search_end_ymd,
       (search_end_ymd - search_start_ymd) AS range_days
FROM sm_menu_opt_config
WHERE biz_seq = 1
AND (search_end_ymd - search_start_ymd) >= 30
ORDER BY range_days DESC;
```