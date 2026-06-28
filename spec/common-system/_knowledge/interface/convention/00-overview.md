---
title: 인터페이스 패턴 개요
description: WMS ERP/OMS/WES/DLV 외부연동 SIF 코딩 컨벤션(E2W 수신·W2E 송신 골격)을 참조할 때 사용
status: active
version: 1.1.0
repo_role: ai-hub
agent_usage: reference
project: common-system
domain: wms
last_modified_by: ShinHyunKyu
last_verified: 2026-06-26
tags:
  - sif
  - erp
  - interface
---

# WMS 인터페이스 컨벤션 개요

WMS SIF(System Interface) 외부연동 **코딩 컨벤션 골격**. WMS 기준 프로젝트=common-system 으로 확정되어, WMS SIF 코딩 규약의 SSoT 로서 여기(③ 프로젝트 층)에 둔다. WMS 도메인 룰 `.claude/rules/wms-sif-convention.md` 이 이 폴더를 참조한다. 실제 API 목록·필드 명세는 상위 `spec/common-system/_knowledge/interface/`(api-list.md·detail/) 에 있다.

## 구조

| 파일 | 내용 |
|---|---|
| `01-erp-to-wms.md` | ERP→WMS 수신(E2W) 코딩 컨벤션 |
| `02-wms-to-erp.md` | WMS→ERP 송신(W2E) 코딩 컨벤션 |

## 코딩 컨벤션

- E2W(ERP→WMS 수신): `./01-erp-to-wms.md`
- W2E(WMS→ERP 송신): `./02-wms-to-erp.md`
