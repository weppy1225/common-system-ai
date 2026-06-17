---
title: 인터페이스 패턴 개요
description: WMS ERP/OMS/WES/DLV 외부연동 SIF 개발 패턴과 API 명세를 참조할 때 사용
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: reference
domain: interface
tags:
  - sif
  - erp
  - interface
---

# 인터페이스 패턴 개요

WMS SIF(System Interface) 외부연동 개발 패턴 및 API 명세 모음.

## 구조

| 디렉토리 | 내용 |
|---|---|
| `10-convention/` | ERP→WMS, WMS→ERP 연동 코딩 컨벤션 |
| `10-api/` | 인터페이스 API 목록 및 상세 명세 |
| `90-history/` | 명세·API 변경 이력 |

## 관련 규칙

- 개발 시 반드시 `.claude/rules/sif-convention.md` 참조
