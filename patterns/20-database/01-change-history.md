---
title: 데이터베이스 변경 이력
description: WMS DB 스키마 변경 이력을 확인하거나 새로운 변경사항을 기록할 때 읽는다
status: active
version: 1.0.0
repo_role: ai-hub
agent_usage: reference
domain: database
tags:
  - database
  - change-history
  - schema
  - ddl
---

# 데이터베이스 변경 이력 (Database Change History)

## 1. 작성규칙
작성시 날짜 변경내용을 {테이블}{컬럼}{변경내용}{추가/수정/삭제}의 형식으로 넣어주세요.<br>
ex) 품목테이블(MDM_PROD)에 prod_id varchar(30) null 허용`<br>` 컬럼 추가<br>
ex) 품목테이블(MDM_PROD)에 prod_id not null로 수정<br>
ex) 품목테이블(MDM_PROD)에 prod_id 컬럼 삭제<br>
ex) [mdm_test](#mdm_test) 테이블 추가<br>

변경내용이 길어질 경우 `<br>`를 넣어주세요.

## 2. DB 변경 이력

| 날짜 | 변경내용 | 담당자 | 테스트반영일 | 리얼반영일 |
|------------|--------------------------------------------------|--------|--------------|--------------|
| 2026-02-23 | 초기 설계 | 신현규 | - | - |
| 2026-03-04 | 품목테이블(MDM_PROD)에 prod_id varchar(30) null 허용<br> 컬럼 추가 | 신현규 | 2026-03-04 | |
| 2026-03-04 | 품목테이블(MDM_PROD)에 prod_id not null 디폴트 '-' 로<br> 수정 | 신현규 | 2026-03-04 | |
| 2026-03-04 | 품목테이블(MDM_PROD)에 prod_id 컬럼 삭제 | 신현규 | 2026-03-04 | |
| 2026-03-04 | [mdm_test](#mdm_test) 테이블 추가 | 신현규 | 2026-03-04 | |
---


### mdm_test
```sql
CREATE TABLE public.mdm_test (
	test_seq int4 NULL,
	test_no varchar(30) NULL
);
```
