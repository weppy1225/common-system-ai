---
title: ERP 연동 API 목록
description: WMS ERP 연동 인터페이스 API 목록 및 엔드포인트 확인 시 참조
status: active
version: 1.0.1
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
> 인터페이스 코드에 링크가 걸린 것만 `detail/` 상세 문서가 작성돼 있다. 링크 없는 코드는 상세 미작성(작성 시 `detail/{코드_소문자}.md` 추가 후 링크).

### 1.1 ERP → WMS 수신 (e2w)

#### 1.1.1 품목 연동
| 인터페이스 코드 | URL | 설명 |
|----------------|-----|------|
| [`E2W_PROD_REG`](./detail/e2w-prod-reg.md) | `/{bizSeq}/sif/e2w/E2W_PROD_REG` | 품목 등록 수신 |
| `E2W_PROD_MOD` | `/{bizSeq}/sif/e2w/E2W_PROD_MOD` | 품목 변경 수신 |
| `E2W_PROD_DEL` | `/{bizSeq}/sif/e2w/E2W_PROD_DEL` | 품목 삭제 수신 |

#### 1.1.2 거래처 연동
| 인터페이스 코드 | URL | 설명 |
|----------------|-----|------|
| `E2W_CONT_REG` | `/{bizSeq}/sif/e2w/E2W_CONT_REG` | 거래처 등록 수신 |
| `E2W_CONT_MOD` | `/{bizSeq}/sif/e2w/E2W_CONT_MOD` | 거래처 변경 수신 |
| `E2W_CONT_DEL` | `/{bizSeq}/sif/e2w/E2W_CONT_DEL` | 거래처 삭제 수신 |

#### 1.1.3 입고 연동
| 인터페이스 코드 | URL | 설명 |
|----------------|-----|------|
| `E2W_IW_REG` | `/{bizSeq}/sif/e2w/E2W_IW_REG` | 입고예정 등록 수신 |
| `E2W_IW_DEL` | `/{bizSeq}/sif/e2w/E2W_IW_DEL` | 입고예정 삭제 수신 |

#### 1.1.4 출고 연동
| 인터페이스 코드 | URL | 설명 |
|----------------|-----|------|
| `E2W_OB_REG` | `/{bizSeq}/sif/e2w/E2W_OB_REG` | 출고요청 등록 수신 |
| `E2W_OB_DEL` | `/{bizSeq}/sif/e2w/E2W_OB_DEL` | 출고요청 삭제 수신 |
| `E2W_OB_STOP` | `/{bizSeq}/sif/e2w/E2W_OB_STOP` | 출고요청 중지 수신 |
| `E2W_OB_STS` | `/{bizSeq}/sif/e2w/E2W_OB_STS` | 출고 상태 수신 |

#### 1.1.5 반품 연동
| 인터페이스 코드 | URL | 설명 |
|----------------|-----|------|
| `E2W_RT_REG` | `/{bizSeq}/sif/e2w/E2W_RT_REG` | 반품예정 등록 수신 |
| `E2W_RT_DEL` | `/{bizSeq}/sif/e2w/E2W_RT_DEL` | 반품예정 삭제 수신 |

#### 1.1.6 세트 연동
| 인터페이스 코드 | URL | 설명 |
|----------------|-----|------|
| `E2W_ST_REG` | `/{bizSeq}/sif/e2w/E2W_ST_REG` | 세트작업 등록 수신 |
| `E2W_ST_DEL` | `/{bizSeq}/sif/e2w/E2W_ST_DEL` | 세트작업 삭제 수신 |

#### 1.1.7 재고실사 연동
| 인터페이스 코드 | URL | 설명 |
|----------------|-----|------|
| `E2W_AD_REG` | `/{bizSeq}/sif/e2w/E2W_AD_REG` | 재고조정 등록 수신 |
| `E2W_INVEN_SCH` | `/{bizSeq}/sif/e2w/E2W_INVEN_SCH` | 재고 조회 요청 수신 |

#### 1.1.8 예외출고 연동
| 인터페이스 코드 | URL | 설명 |
|----------------|-----|------|
| `E2W_EX_REG` | `/{bizSeq}/sif/e2w/E2W_EX_REG` | 예외출고 등록 수신 |
| `E2W_EX_DEL` | `/{bizSeq}/sif/e2w/E2W_EX_DEL` | 예외출고 삭제 수신 |
