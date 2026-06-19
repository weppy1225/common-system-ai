---
title: ERP 연동 API 목록
description: WMS ERP 연동 인터페이스 API 목록 및 엔드포인트 확인 시 참조
status: active
version: 1.0.0
wms_meta: true
repo_role: ai-hub
agent_usage: reference
domain: interface
tags:
  - sif
  - erp
  - api
  - e2w
---

# ERP 연동 API 목록 (ERP Interface API List)

## 1. ERP 시스템 인터페이스

> Base Path: `/{bizSeq}/sif/e2w/{인터페이스코드}`
> 모든 엔드포인트는 `POST` 단일 메서드 사용

### 1.1 ERP → WMS 수신 (e2w)

# API 목록

## 2. ERP 시스템 인터페이스

> Base Path: `/{bizSeq}/sif/e2w/{인터페이스코드}`
> 모든 엔드포인트는 `POST` 단일 메서드 사용

### 2.1 ERP → WMS 수신 (e2w)

#### 2.1.1 품목 연동
| 인터페이스 코드 | URL | 설명 |
|----------------|-----|------|
| [`E2W_PROD_REG`](./20-detail/e2w-prod-reg.md) | `/{bizSeq}/sif/e2w/E2W_PROD_REG` | 품목 등록 수신 |
| [`E2W_PROD_MOD`](E2W_PROD_MOD.md) | `/{bizSeq}/sif/e2w/E2W_PROD_MOD` | 품목 변경 수신 |
| [`E2W_PROD_DEL`](E2W_PROD_DEL.md) | `/{bizSeq}/sif/e2w/E2W_PROD_DEL` | 품목 삭제 수신 |

#### 2.1.2 거래처 연동
| 인터페이스 코드 | URL | 설명 |
|----------------|-----|------|
| [`E2W_CONT_REG`](E2W_CONT_REG.md) | `/{bizSeq}/sif/e2w/E2W_CONT_REG` | 거래처 등록 수신 |
| [`E2W_CONT_MOD`](E2W_CONT_MOD.md) | `/{bizSeq}/sif/e2w/E2W_CONT_MOD` | 거래처 변경 수신 |
| [`E2W_CONT_DEL`](E2W_CONT_DEL.md) | `/{bizSeq}/sif/e2w/E2W_CONT_DEL` | 거래처 삭제 수신 |

#### 2.1.3 입고 연동
| 인터페이스 코드 | URL | 설명 |
|----------------|-----|------|
| [`E2W_IW_REG`](E2W_IW_REG.md) | `/{bizSeq}/sif/e2w/E2W_IW_REG` | 입고예정 등록 수신 |
| [`E2W_IW_DEL`](E2W_IW_DEL.md) | `/{bizSeq}/sif/e2w/E2W_IW_DEL` | 입고예정 삭제 수신 |

#### 2.1.4 출고 연동
| 인터페이스 코드 | URL | 설명 |
|----------------|-----|------|
| [`E2W_OB_REG`](E2W_OB_REG.md) | `/{bizSeq}/sif/e2w/E2W_OB_REG` | 출고요청 등록 수신 |
| [`E2W_OB_DEL`](E2W_OB_DEL.md) | `/{bizSeq}/sif/e2w/E2W_OB_DEL` | 출고요청 삭제 수신 |
| [`E2W_OB_STOP`](E2W_OB_STOP.md) | `/{bizSeq}/sif/e2w/E2W_OB_STOP` | 출고요청 중지 수신 |
| [`E2W_OB_STS`](E2W_OB_STS.md) | `/{bizSeq}/sif/e2w/E2W_OB_STS` | 출고 상태 수신 |

#### 2.1.5 반품 연동
| 인터페이스 코드 | URL | 설명 |
|----------------|-----|------|
| [`E2W_RT_REG`](E2W_RT_REG.md) | `/{bizSeq}/sif/e2w/E2W_RT_REG` | 반품예정 등록 수신 |
| [`E2W_RT_DEL`](E2W_RT_DEL.md) | `/{bizSeq}/sif/e2w/E2W_RT_DEL` | 반품예정 삭제 수신 |

#### 2.1.6 세트 연동
| 인터페이스 코드 | URL | 설명 |
|----------------|-----|------|
| [`E2W_ST_REG`](E2W_ST_REG.md) | `/{bizSeq}/sif/e2w/E2W_ST_REG` | 세트작업 등록 수신 |
| [`E2W_ST_DEL`](E2W_ST_DEL.md) | `/{bizSeq}/sif/e2w/E2W_ST_DEL` | 세트작업 삭제 수신 |

#### 2.1.7 재고실사 연동
| 인터페이스 코드 | URL | 설명 |
|----------------|-----|------|
| [`E2W_AD_REG`](E2W_AD_REG.md) | `/{bizSeq}/sif/e2w/E2W_AD_REG` | 재고조정 등록 수신 |
| [`E2W_INVEN_SCH`](E2W_INVEN_SCH.md) | `/{bizSeq}/sif/e2w/E2W_INVEN_SCH` | 재고 조회 요청 수신 |

#### 2.1.8 예외출고 연동
| 인터페이스 코드 | URL | 설명 |
|----------------|-----|------|
| [`E2W_EX_REG`](E2W_EX_REG.md) | `/{bizSeq}/sif/e2w/E2W_EX_REG` | 예외출고 등록 수신 |
| [`E2W_EX_DEL`](E2W_EX_DEL.md) | `/{bizSeq}/sif/e2w/E2W_EX_DEL` | 예외출고 삭제 수신 |
---
