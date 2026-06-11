
# sm_board (시스템_게시판)

## 1. 개요
시스템 내 **게시판** 기능을 제공하는 테이블.
공지사항, FAQ, 문의사항 등 다양한 게시판 유형의 게시글을 관리한다.

### 1.1 게시판 처리 흐름
```
게시글 작성 → sm_board 등록 → 사용자 조회/댓글 작성
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | board_seq | bigint | N | nextval('sm_board_seq') | 게시글 SEQ |
| | board_type_cd | varchar(50) | N | | 게시판 유형 코드 |
| | board_cat_cd | varchar(50) | Y | | 게시판 카테고리 코드 |
| | board_cat_dtl_cd | varchar(50) | Y | | 게시판 카테고리 상세 코드 |
| | title | varchar(100) | Y | | 제목 |
| | contents | text | Y | | 내용 |
| | board_yn | char(1) | Y | 'N' | 게시글 여부 |
| | top_board_seq | bigint | Y | | 부모 게시글 SEQ |
| | reply_cnt | integer | Y | 0 | 답글 수 |
| | view_cnt | integer | Y | 0 | 조회 수 |
| | file_seq | integer | Y | | 파일 SEQ |
| | disp_no | smallint | N | 1 | 표시 순서 |
| | board_pwd | varchar(500) | Y | | 비밀번호 |
| | disp_yn | char(1) | Y | 'N' | 공개 여부 |
| | start_ymd | varchar(8) | Y | | 게시 시작일 |
| | end_ymd | varchar(8) | Y | | 게시 종료일 |
| | del_yn | char(1) | N | 'N' | 삭제 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

> **board_type_cd** (`BOARD_TYPE_CD`)
>
> | 코드 | 코드명 |
> |---|---|
> | NOTICE | 공지사항 |
> | FAQ | FAQ |
> | QNA | 문의사항 |
> | FREE | 자유게시판 |

> **board_yn** (`USE_YN` 계열)
>
> | 코드 | 코드명 |
> |---|---|
> | Y | 게시글 |
> | N | 답글 |

> **disp_yn** (`USE_YN` 계열)
>
> | 코드 | 코드명 |
> |---|---|
> | Y | 공개 |
> | N | 비공개 |

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
| sm_board_PK | board_seq | Y | Y |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| board_seq | sm_board_seq |

---

## 5. 업무 규칙

### 5.1 게시글 등록
- `board_type_cd`로 게시판 구분
- `board_yn = 'Y'`는 게시글, 'N'은 답글
- `top_board_seq`로 부모 게시글 참조 (답글인 경우)

### 5.2 게시 기간 관리
- `start_ymd` ~ `end_ymd` 기간 동안만 게시글 표시
- 기간 외에는 표시되지 않음

### 5.3 공개 여부
- `disp_yn = 'N'`인 경우 비밀글
- 비밀글은 작성자와 관리자만 조회 가능
- `board_pwd`로 비밀번호 검증

### 5.4 파일 첨부
- `file_seq`로 `sm_file` 참조
- 여러 파일 첨부 시 `sm_file_req` 활용

### 5.5 조회수
- 게시글 조회 시 `view_cnt` 증가
- 동일 사용자 중복 조회는 카운트하지 않음

### 5.6 답글
- 답글 작성 시 `reply_cnt` 증가
- 답글은 부모 게시글과 동일한 `board_type_cd` 사용

### 5.7 삭제 처리
- 물리삭제 금지 — `del_yn = 'Y'`로 논리삭제
- 삭제된 게시글은 조회되지 않음

---

## 6. 주요 조회 예시

```sql
-- 게시판 유형별 게시글 목록
SELECT board_seq, title, reg_id, reg_dt, view_cnt
FROM sm_board
WHERE board_type_cd = 'NOTICE'
AND board_yn = 'Y'
AND del_yn = 'N'
AND start_ymd <= TO_CHAR(CURRENT_DATE, 'YYYYMMDD')
AND end_ymd >= TO_CHAR(CURRENT_DATE, 'YYYYMMDD')
ORDER BY disp_no, reg_dt DESC;

-- 게시글 상세 조회
SELECT b.*, f.file_nm, f.file_path
FROM sm_board b
    LEFT JOIN sm_file_req fr ON b.board_seq = fr.req_seq AND fr.req_type_cd = 'BOARD'
    LEFT JOIN sm_file f ON fr.file_seq = f.file_seq
WHERE b.board_seq = 1001
AND b.del_yn = 'N';

-- 답글 목록 조회
SELECT board_seq, title, reg_id, reg_dt
FROM sm_board
WHERE top_board_seq = 1001
AND board_yn = 'N'
AND del_yn = 'N'
ORDER BY reg_dt;

-- 카테고리별 게시글 현황
SELECT board_cat_cd, board_cat_dtl_cd,
       COUNT(*) AS post_cnt
FROM sm_board
WHERE board_type_cd = 'QNA'
AND del_yn = 'N'
GROUP BY board_cat_cd, board_cat_dtl_cd
ORDER BY board_cat_cd, board_cat_dtl_cd;

-- 인기 게시글 Top N
SELECT board_seq, title, view_cnt, reg_dt
FROM sm_board
WHERE board_type_cd = 'FREE'
AND del_yn = 'N'
AND reg_dt >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY view_cnt DESC
LIMIT 10;
```

---
