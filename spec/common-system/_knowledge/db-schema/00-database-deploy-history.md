---
title: DB 변경·반영 이력
description: 이 프로젝트(WMS)의 DB 스키마 변경(시퀀스·테이블·컬럼·공통코드)을 test/운영 DB에 실제 반영한 이력을 기록한다. /SD_db_apply 가 DDL 반영 성공 시 자동으로 행을 추가한다.
status: active
version: 1.0.0
author: ShinHyunKyu
repo_role: ai-hub
domain: database
agent_usage: output
tags:
  - database
  - change-history
  - deploy
---

# DB 변경·반영 이력 (Database Deploy History)

> 실제 DB(test/dev/운영)에 반영한 스키마 변경을 시간순으로 기록한다. **`/SD_db_apply` 가 DDL 반영 성공 후 자동으로 행을 추가**한다.
> 반영 **전**(설계 단계)의 DDL 정본은 `spec/common-system/{메뉴코드}/{메뉴코드}-03-data-model.md` 다. 이 파일은 **반영 결과 로그**다(설계가 아니라 "언제 무엇을 DB에 넣었나").
> 운영반영일은 운영 반영 후 수동 기입한다(`/SD_db_apply` 는 test/dev 만 자동 반영).

## 변경 이력

| 반영일시 | 메뉴코드 | 테이블/시퀀스 | 변경 내용 | 테스트반영일 | 운영반영일 |
|---|---|---|---|---|---|
| | | | | | - |
