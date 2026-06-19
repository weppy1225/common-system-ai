---
title: 신규 메뉴 등록 절차
description: 신규 화면 개발 후 FE 라우터 등록, DB sm_menu 등록, 권한 부여까지 전체 절차. 메뉴 추가 시 반드시 참조.
status: active
version: 1.0.0
wms_meta: true
repo_role: ai-hub
agent_usage: instruction
domain: frontend
tags:
  - router
  - menu
  - sm_menu
  - 메뉴등록
---

# 신규 메뉴 등록 절차

신규 화면(`.vue`)을 개발한 뒤 사용자가 접근할 수 있으려면 아래 3단계를 모두 완료해야 한다.

```
[1] FE 라우터 등록  →  [2] DB sm_menu 등록  →  [3] 권한 부여
```

---

## [1] FE 라우터 등록

### 파일 위치

```
cloud-wms-fe/src/router/modules/be/{업무군코드}.js
```

업무군 코드별 파일 예시: `iv3000.js`, `iw1000.js`, `md8000.js`

### 등록 패턴

```js
// src/router/modules/be/iv3000.js
export default {
    path: 'iv3000',
    meta: { title: '재고관리', img: 'icon-iv.png' },
    children: [
        // 기존 메뉴들...

        // ✅ 신규 메뉴 추가
        {
            path: 'ivnw01',                  // URL 경로 (소문자 메뉴코드)
            name: 'ivnw01',                  // 라우터 이름 (소문자 메뉴코드, 고유값)
            component: () => import('@/views/be/iv3000/ivnw01/ivnw01.vue')
                .catch(() => routerErrorHandler()),
            meta: {
                title: '신규화면명',          // 탭 타이틀
                img: 'icon_guide.png',
                menuCd: 'IVNW01',            // ← DB의 menu_cd 와 반드시 일치
                authMenuCd: 'IVNW01'         // ← 권한 체크용 (보통 menuCd와 동일)
            }
        },
    ]
}
```

### 업무군 파일이 없는 경우

새 업무군이면 `modules/be/` 아래 파일을 신규 생성하고 `router/index.js`에 import 추가:

```js
// router/index.js
import iv3000 from './modules/be/iv3000.js'
// ...
const routes = [
    {
        path: '/be',
        children: [
            iv3000,
            // ...
        ]
    }
]
```

---

## [2] DB sm_menu 등록

운영/개발 DB에 직접 INSERT하거나, WMS 관리 화면(SMMN01)에서 등록한다.

### INSERT SQL

```sql
INSERT INTO sm_menu (
    menu_cd,            -- 메뉴코드         예) 'IVNW01'
    menu_nm,            -- 메뉴명           예) '신규화면'
    h_menu_cd,          -- 상위메뉴코드     예) 'IV3000'  (메뉴그룹 코드)
    menu_idx,           -- 메뉴순서         예) 3090      (그룹 내 표시 순서)
    menu_type_cd,       -- 메뉴유형         'MN'=일반, 'MG'=그룹, 'MM'=모바일
    menu_url,           -- URL              예) '/be/iv3000/ivnw01'
    ui_type_cd,         -- UI타입           'P'=PC, 'M'=모바일
    alarm_use_yn,       -- 알람사용여부     'N' (기본)
    proc_ymd_chng_yn,   -- 처리일자변경     'N' (기본)
    sch_ymd_set_yn,     -- 검색기간설정     'N' (기본)
    menu_icon,          -- 메뉴아이콘       NULL (기본)
    pda_disp_no,        -- PDA표시순서      0
    login_acc_yn,       -- 로그인접근여부   'Y'
    login_disp_yn,      -- 로그인표시여부   'Y'
    def_menu_yn,        -- 기본메뉴여부     'N' (기본)
    use_yn,             -- 사용여부         'Y'
    reg_id,
    reg_dt
) VALUES (
    'IVNW01', '신규화면', 'IV3000', 3090,
    'MN', '/be/iv3000/ivnw01', 'P',
    'N', 'N', 'N', NULL, 0,
    'Y', 'Y', 'N', 'Y',
    'SYSTEM', NOW()
);
```

### menu_type_cd 기준

| 값 | 의미 | 용도 |
|---|---|---|
| `MG` | 메뉴그룹 | 사이드바 1단계 (폴더) |
| `MN` | 일반메뉴 | 실제 화면 (leaf) |
| `MM` | 모바일메뉴 | PDA 화면 |

### menu_url 규칙

```
/be/{업무군코드}/{메뉴코드소문자}

예시:
/be/iv3000/ivnw01
/be/iw1000/iwrq01
/be/md8000/mdct01
```

라우터의 `path` 조합과 반드시 일치해야 한다.

---

## [3] 권한 부여

등록된 메뉴에 사용자 그룹이 접근할 수 있도록 `sm_menu_group` 에 권한을 추가한다.

### 특정 그룹에 권한 부여

```sql
INSERT INTO sm_menu_group (
    menu_cd, group_seq, ui_type_cd,
    read_auth_yn, create_auth_yn, alarm_auth_yn,
    reg_id, reg_dt
) VALUES (
    'IVNW01',            -- 메뉴코드
    {group_seq},         -- 그룹 SEQ (sm_group 테이블 확인)
    'P',                 -- UI타입
    'Y', 'Y', 'N',
    'SYSTEM', NOW()
);
```

### 모든 관리자 그룹에 일괄 부여

```sql
INSERT INTO sm_menu_group (
    menu_cd, group_seq, ui_type_cd,
    read_auth_yn, create_auth_yn, alarm_auth_yn,
    reg_id, reg_dt
)
SELECT
    'IVNW01',
    g.group_seq,
    'P',
    'Y', 'Y', 'N',
    'SYSTEM', NOW()
FROM sm_group g
WHERE g.biz_seq = {biz_seq}
  AND g.biz_admin_yn = 'Y';
```

---

## 등록 후 확인 체크리스트

- [ ] FE: `router/modules/be/{업무군}.js` 에 path/name/menuCd 추가
- [ ] DB: `sm_menu` INSERT 완료 (`menu_cd`, `menu_url` 이중 확인)
- [ ] DB: `sm_menu_group` 권한 부여
- [ ] 브라우저: 사이드바에 메뉴 노출 확인
- [ ] 브라우저: 클릭 시 화면 정상 로드 확인
- [ ] 브라우저: 권한 없는 계정으로 직접 URL 접근 시 차단 확인

---

## 관련 화면 (관리 UI)

| 화면 | 메뉴코드 | 경로 |
|---|---|---|
| 메뉴관리 | SMMN01 | `/be/mm9200/smmn01` |
| 그룹관리 | SMGP01 | `/be/mm9200/smgp01` |
| 권한관리 | SMGPMN01 | `/be/mm9200/smgpmn01` |
