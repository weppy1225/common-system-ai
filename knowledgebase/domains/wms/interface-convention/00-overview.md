---
title: 인터페이스 패턴 개요
description: WMS ERP/OMS/WES/DLV 외부연동 SIF 코딩 컨벤션(E2W 수신·W2E 송신 골격)을 참조할 때 사용
status: active
version: 1.0.0
repo_role: ai-hub
agent_usage: reference
domain: interface
tags:
  - sif
  - erp
  - interface
---

# WMS 인터페이스 컨벤션 개요

WMS SIF(System Interface) 외부연동 **코딩 컨벤션 골격**(도메인 표준). 실제 API 목록·필드 명세는 프로젝트마다 다른 확정 데이터라 `spec/{프로젝트}/_knowledge/interface/` 에 둔다.

## 구조

| 파일 | 내용 |
|---|---|
| `01-erp-to-wms.md` | ERP→WMS 수신(E2W) 코딩 컨벤션 |
| `02-wms-to-erp.md` | WMS→ERP 송신(W2E) 코딩 컨벤션 |

## 코딩 컨벤션

- E2W(ERP→WMS 수신): `./01-erp-to-wms.md`
- W2E(WMS→ERP 송신): `./02-wms-to-erp.md`
