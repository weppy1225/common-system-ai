---
title: knowledgebase/40-install-guide 시스템 운영·인프라 가이드
description: 시스템 무관 빌드·배포·설치·운영 가이드 문서 모음. 스택별 차이는 도메인(knowledgebase/domains/{도메인}/install-guide/)에서 보완한다.
status: active
version: 1.0.0
repo_role: ai-hub
agent_usage: reference
---

# knowledgebase/40-install-guide

빌드·배포·설치·운영 가이드를 관리한다. 여기에는 **스택 공통 절차**(Gradle/Spring Boot 기준)를 두고, 스택이 다른 시스템(예: OMS=Ant/WAR)은 `knowledgebase/domains/{도메인}/install-guide/`에서 차이만 보완한다.

## 디렉토리 구조

```
knowledgebase/40-install-guide/
└── deploy/
    ├── deploy-guide.md            # BE 빌드·배포·검증 절차 (Gradle/Spring Boot)
    └── context-name-rename-map.md # 배포 컨텍스트·앱 이름 리네임 시 변경 위치 맵 (BE/FE/외부)
```

## 문서 목록

| 문서 | 경로 | 설명 |
|---|---|---|
| 빌드·배포 가이드 | `deploy/deploy-guide.md` | Gradle 빌드 → Tomcat 배포 → 동작 검증 절차. 알려진 이슈(Flyway) 포함 |
| 컨텍스트·이름 리네임 맵 | `deploy/context-name-rename-map.md` | 앱 이름·배포 컨텍스트(WAR명·context-path·FTP·로그) 변경 시 BE/FE/외부 변경 위치 체크리스트 |
