
# sm_log_menu (시스템_로그_메뉴접근)

## 1. 개요
**메뉴별 접근 횟수**를 집계한 로그 테이블.
일자별로 메뉴 접근 통계를 저장하여 메뉴 사용 빈도 분석에 활용한다.

### 1.1 메뉴 접근 로그 흐름
```
사용자 메뉴 접근 → 일자별/메뉴별 접근 횟수 집계 → sm_log_menu 저장/업데이트
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | biz_seq | integer | N | | 사업장 SEQ |
| PK | yyyymmdd | varchar(8) | N | | 연월일 |
| PK | menu_cd | varchar(50) | N | | 메뉴 코드 |
| | view_cnt | smallint | N | 0 | 조회 수 |
| | yyyy | varchar(4) | N | | 연 |
| | mm | char(2) | N | | 월 |
| | dd | char(2) | N | | 일 |

---

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| sm_log_menu_PK | biz_seq, yyyymmdd, menu_cd | Y | Y |

---

## 4. 업무 규칙

### 4.1 접근 통계 집계
- 사용자가 메뉴에 접근할 때마다 카운트 증가
- 동일 사용자의 중복 접근도 모두 카운트
- 일자별로 집계하여 저장

### 4.2 집계 방식
- 실시간 증가 또는 배치 집계
- `view_cnt`를 1씩 증가

### 4.3 분석 활용
- 인기 메뉴 파악
- 사용자별 메뉴 사용 패턴 분석
- 메뉴 개선/폐기 의사결정 자료

### 4.4 파티셔닝
- 대용량 로그 관리를 위해 `yyyymmdd` 기준 파티셔닝 고려

---

## 5. 주요 조회 예시

```sql
-- 일자별 전체 메뉴 접근 현황
SELECT yyyymmdd,
       SUM(view_cnt) AS total_views,
       COUNT(DISTINCT menu_cd) AS menu_cnt
FROM sm_log_menu
WHERE biz_seq = 1
AND yyyymmdd BETWEEN '20250201' AND '20250228'
GROUP BY yyyymmdd
ORDER BY yyyymmdd;

-- 인기 메뉴 Top N (기간별)
SELECT m.menu_cd, m.menu_nm,
       SUM(l.view_cnt) AS total_views
FROM sm_log_menu l
    JOIN sm_menu m ON l.menu_cd = m.menu_cd
WHERE l.biz_seq = 1
AND l.yyyymmdd BETWEEN '20250201' AND '20250228'
GROUP BY m.menu_cd, m.menu_nm
ORDER BY total_views DESC
LIMIT 10;

-- 메뉴별 일별 접근 추이
SELECT yyyymmdd, view_cnt
FROM sm_log_menu
WHERE biz_seq = 1
AND menu_cd = 'MENU001'
AND yyyymmdd BETWEEN '20250201' AND '20250228'
ORDER BY yyyymmdd;

-- 월별 메뉴 접근 통계
SELECT SUBSTRING(yyyymmdd, 1, 6) AS yyyymm,
       menu_cd,
       SUM(view_cnt) AS monthly_views
FROM sm_log_menu
WHERE biz_seq = 1
AND yyyymmdd LIKE '2025%'
GROUP BY SUBSTRING(yyyymmdd, 1, 6), menu_cd
ORDER BY yyyymm, monthly_views DESC;
```

---
