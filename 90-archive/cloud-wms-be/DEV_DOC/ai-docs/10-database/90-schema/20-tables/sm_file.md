
# sm_file (시스템_파일)

## 1. 개요
시스템에서 사용하는 **파일(첨부파일)의 메타 정보**를 관리하는 테이블.
파일의 실제 저장 경로, 파일명, 크기, 확장자 등을 저장한다.

### 1.1 파일 처리 흐름
```
파일 업로드 → sm_file 등록 → 파일 UUID 생성 → 실제 파일 저장 → sm_file_req로 업무 연동
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | file_seq | integer | N | nextval('sm_file_seq') | 파일 SEQ |
| | biz_seq | integer | N | | 사업장 SEQ |
| | file_div_cd | varchar(50) | Y | | 파일 구분 코드 |
| | file_uuid | varchar(300) | N | | 파일 고유 ID |
| | file_nm | varchar(100) | Y | | 파일명 |
| | file_path | varchar(512) | Y | | 파일 경로 |
| | disp_no | smallint | N | 0 | 표시 순서 |
| | file_size | integer | Y | | 파일 크기(KB) |
| | file_extension | varchar(100) | Y | | 파일 확장자 |
| | use_yn | char(1) | N | 'Y' | 사용 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

> **file_div_cd** (`FILE_DIV_CD`)
>
> | 코드 | 코드명 |
> |---|---|
> | BOARD | 게시판 첨부 |
> | PROD | 품목 이미지 |
> | USER | 사용자 프로필 |
> | BIZ | 사업장 로고/직인 |
> | LABEL | 라벨 양식 |
> | ETC | 기타 |

> **use_yn** (`USE_YN`)
>
> | 코드 | 코드명 |
> |---|---|
> | Y | 사용 |
> | N | 미사용 |

---

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| sm_file_PK | file_seq | Y | Y |
| UIX_sm_file | file_uuid | Y | |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| file_seq | sm_file_seq |

---

## 5. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| biz_seq | mdm_biz | biz_seq | mdm_biz_TO_sm_file |

---

## 6. 업무 규칙

### 6.1 파일 업로드
- 파일 업로드 시 고유한 UUID 생성
- 실제 파일은 `file_path`에 저장 (파일 시스템 또는 Object Storage)
- 파일 메타데이터는 DB에 저장

### 6.2 파일 구분
- `file_div_cd`로 파일 용도 구분
- 게시판 첨부, 품목 이미지, 사용자 프로필 등

### 6.3 파일명 관리
- 저장 시 중복 방지를 위해 UUID 기반 저장
- 원본 파일명은 `file_nm`에 보관
- 다운로드 시 원본 파일명으로 제공

### 6.4 표시 순서
- 여러 파일이 연관된 경우 `disp_no`로 순서 지정
- 이미지 갤러리 등에서 활용

### 6.5 사용 여부
- `use_yn = 'N'`인 파일은 실제로 사용되지 않음
- 파일 삭제 시 물리적 파일은 즉시 삭제하지 않고, 필요 시 배치로 정리

---

## 7. 주요 조회 예시

```sql
-- 파일 기본 정보 조회
SELECT file_seq, file_uuid, file_nm, file_path, file_size, file_extension
FROM sm_file
WHERE file_seq = 1001
AND use_yn = 'Y';

-- 구분별 파일 목록
SELECT file_div_cd, COUNT(*) AS file_cnt,
       SUM(file_size) AS total_size_kb
FROM sm_file
WHERE use_yn = 'Y'
GROUP BY file_div_cd
ORDER BY file_div_cd;

-- 특정 파일명 검색
SELECT file_seq, file_nm, file_div_cd, reg_dt
FROM sm_file
WHERE file_nm LIKE '%계약서%'
AND use_yn = 'Y'
ORDER BY reg_dt DESC;

-- 오래된 미사용 파일 조회 (삭제 대상)
SELECT file_seq, file_uuid, file_nm, reg_dt
FROM sm_file
WHERE use_yn = 'N'
AND reg_dt < CURRENT_DATE - INTERVAL '30 days';
```

---