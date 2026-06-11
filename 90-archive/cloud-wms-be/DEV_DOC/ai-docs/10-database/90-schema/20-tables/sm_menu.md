
# sm_menu (시스템_메뉴)

## 1. 개요
시스템의 **메뉴 구조**를 정의하는 테이블.
메뉴 코드, 메뉴명, 상위 메뉴, URL, UI 타입, 표시 순서 등을 관리한다.

### 1.1 메뉴 구조 흐름
```
메뉴 정의 → sm_menu 등록 → 메뉴 그룹 권한 부여(sm_menu_group) → 사용자 메뉴 표시
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | menu_cd | varchar(50) | N | | 메뉴 코드 |
| | menu_nm | varchar(100) | N | | 메뉴명 |
| | h_menu_cd | varchar(50) | N | | 상위 메뉴 코드 |
| | menu_idx | smallint | N | 0 | 메뉴 순서 |
| | menu_type_cd | varchar(50) | N | | 메뉴 유형 코드 |
| | menu_url | varchar(512) | Y | | 메뉴 URL |
| | ui_type_cd | varchar(50) | Y | | UI 유형 코드 |
| | alarm_use_yn | char(1) | N | 'N' | 알람 사용 여부 |
| | proc_ymd_chng_yn | char(1) | N | 'N' | 처리일자 변경 여부 |
| | sch_ymd_set_yn | char(1) | N | 'N' | 조회일자 설정 여부 |
| | menu_icon | varchar(512) | Y | | 메뉴 아이콘 |
| | pda_disp_no | smallint | Y | 0 | PDA 표시 순서 |
| | login_acc_yn | char(1) | Y | 'Y' | 로그인 접근 여부 |
| | login_disp_yn | char(1) | Y | 'Y' | 로그인 표시 여부 |
| | def_menu_yn | char(1) | N | 'Y' | 기본메뉴 여부 |
| | use_yn | char(1) | N | 'Y' | 사용 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

> **menu_type_cd** (`MENU_TYPE_CD`)
>
> | 코드 | 코드명 |
> |---|---|
> | MG | 메뉴그룹 (폴더) |
> | MN | 메뉴 (실행 메뉴) |

> **ui_type_cd** (`UI_TYPE_CD`)
>
> | 코드 | 코드명 |
> |---|---|
> | P | 웹 (PC) |
> | M | 모바일 |

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
| sm_menu_PK | menu_cd | Y | Y |

---

## 4. 업무 규칙

### 4.1 메뉴 구조
- `h_menu_cd`로 트리 구조 형성
- 최상위 메뉴는 `h_menu_cd`가 'TOP' 또는 자기 참조

### 4.2 메뉴 유형
- `MG`: 메뉴 그룹(폴더) - 하위 메뉴를 가지는 노드
- `MN`: 실제 실행 가능한 메뉴 - URL 존재

### 4.3 UI 유형
- `P`: PC 웹 화면용 메뉴
- `M`: 모바일(PDA) 화면용 메뉴

### 4.4 메뉴 순서
- `menu_idx`: 동일 레벨 내 표시 순서
- `pda_disp_no`: 모바일에서의 표시 순서

### 4.5 접근/표시 설정
- `login_acc_yn`: 로그인 없이 접근 가능 여부
- `login_disp_yn`: 로그인 화면에 표시 여부
- `def_menu_yn`: 기본 제공 메뉴 여부 (삭제 불가)

### 4.6 메뉴 옵션
- `alarm_use_yn`: 해당 메뉴에서 알람 사용 여부
- `proc_ymd_chng_yn`: 처리일자 변경 가능 여부
- `sch_ymd_set_yn`: 조회일자 설정 가능 여부

### 4.7 사용 여부
- `use_yn = 'N'`인 메뉴는 표시되지 않음
- 하위 메뉴도 함께 숨김 처리

---

## 5. 주요 조회 예시

```sql
-- 전체 메뉴 트리 조회
SELECT menu_cd, menu_nm, h_menu_cd, menu_idx, menu_type_cd
FROM sm_menu
WHERE use_yn = 'Y'
ORDER BY
    CASE WHEN h_menu_cd = 'TOP' THEN 0 ELSE 1 END,
    h_menu_cd, menu_idx;

-- 특정 상위 메뉴의 하위 메뉴 목록
SELECT menu_cd, menu_nm, menu_type_cd, menu_url, menu_idx
FROM sm_menu
WHERE h_menu_cd = 'MENU001'
AND use_yn = 'Y'
ORDER BY menu_idx;

-- PC 웹 메뉴 목록
SELECT menu_cd, menu_nm, h_menu_cd, menu_url, menu_idx
FROM sm_menu
WHERE ui_type_cd = 'P'
AND use_yn = 'Y'
ORDER BY
    CASE WHEN h_menu_cd = 'TOP' THEN 0 ELSE 1 END,
    h_menu_cd, menu_idx;

-- 모바일(PDA) 메뉴 목록
SELECT menu_cd, menu_nm, h_menu_cd, menu_url, pda_disp_no
FROM sm_menu
WHERE ui_type_cd = 'M'
AND use_yn = 'Y'
ORDER BY pda_disp_no;

-- 로그인 없이 접근 가능한 메뉴
SELECT menu_cd, menu_nm, menu_url
FROM sm_menu
WHERE login_acc_yn = 'Y'
AND use_yn = 'Y';
```

---
