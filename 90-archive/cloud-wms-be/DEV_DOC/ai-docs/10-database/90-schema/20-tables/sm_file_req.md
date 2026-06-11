

# sm_file_req (시스템_파일_업무)

## 1. 개요
파일(`sm_file`)과 **업무 데이터 간의 연결 관계**를 관리하는 테이블.
하나의 파일이 어떤 업무(게시글, 품목, 사용자 등)에 속하는지 정의한다.

### 1.1 파일 업무 연결 흐름
```
파일 업로드 → sm_file 등록 → sm_file_req로 업무 연결 → 업무에서 파일 참조
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | file_seq | integer | N | | 파일 SEQ |
| PK | req_type_cd | varchar(50) | N | | 업무 유형 코드 |
| PK | req_seq | integer | N | | 업무 SEQ |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

> **req_type_cd** (`REQ_TYPE_CD`)
>
> | 코드 | 코드명 |
> |---|---|
> | BOARD | 게시판 |
> | PROD | 품목 |
> | USER | 사용자 |
> | BIZ | 사업장 |
> | LABEL | 라벨용지 |
> | ETC | 기타 |

---

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| sm_file_req_PK | file_seq, req_type_cd, req_seq | Y | Y |

---

## 4. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| file_seq | sm_file | file_seq | sm_file_TO_sm_file_req |

---

## 5. 업무 규칙

### 5.1 파일 연결
- 하나의 파일은 여러 업무에 연결될 수 있음
- 하나의 업무는 여러 파일을 가질 수 있음

### 5.2 업무 유형
- `req_type_cd`로 연결된 업무 종류 구분
- `req_seq`로 해당 업무의 고유키 참조

### 5.3 파일과 업무의 라이프사이클
- 업무 삭제 시 연결된 파일 참조도 함께 삭제 고려
- 파일 자체는 `sm_file`에서 별도 관리

### 5.4 대표 이미지
- 여러 파일 중 `disp_no`가 가장 낮은 파일을 대표 이미지로 활용 가능

---

## 6. 주요 조회 예시

```sql
-- 특정 업무에 연결된 파일 목록
SELECT f.file_seq, f.file_nm, f.file_path, f.file_size,
       fr.req_type_cd, fr.req_seq
FROM sm_file_req fr
    JOIN sm_file f ON fr.file_seq = f.file_seq
WHERE fr.req_type_cd = 'BOARD'
AND fr.req_seq = 1001
AND f.use_yn = 'Y'
ORDER BY f.disp_no;

-- 특정 파일이 연결된 업무 목록
SELECT req_type_cd, req_seq
FROM sm_file_req
WHERE file_seq = 1001;

-- 업무 유형별 파일 통계
SELECT req_type_cd,
       COUNT(DISTINCT req_seq) AS req_cnt,
       COUNT(*) AS file_cnt
FROM sm_file_req
GROUP BY req_type_cd
ORDER BY req_type_cd;

-- 최근 등록된 파일-업무 연결
SELECT fr.*, f.file_nm
FROM sm_file_req fr
    JOIN sm_file f ON fr.file_seq = f.file_seq
ORDER BY fr.reg_dt DESC
LIMIT 50;
```

---
