---
title: knowledgebase/40-install-guide 시스템 운영·인프라 가이드
description: cloud-wms 시스템의 빌드·배포·설치·운영에 관한 가이드 문서 모음
status: active
version: 1.0.0
wms_meta: true
repo_role: ai-hub
agent_usage: reference
---

# knowledgebase/40-install-guide

cloud-wms 시스템의 빌드·배포·설치·운영 가이드를 관리한다.

## 디렉토리 구조

```
knowledgebase/40-install-guide/
└── deploy/
    └── local-deploy-guide.md   # 로컬 Tomcat 빌드·배포·검증 절차
```

## 문서 목록

| 문서 | 경로 | 설명 |
|---|---|---|
| 로컬 빌드·배포 가이드 | `deploy/local-deploy-guide.md` | Gradle 빌드 → Tomcat 배포 → 동작 검증 절차. 알려진 이슈(Flyway) 포함 |
