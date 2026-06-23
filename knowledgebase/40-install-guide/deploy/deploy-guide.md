---
title: BE 빌드·배포 가이드 (Gradle / Spring Boot)
description: Gradle/Spring Boot 기반 BE의 빌드·기동·배포 준비 절차. BE를 띄우거나 배포 준비 시 참조. (Ant/WAR 스택인 OMS는 knowledgebase/domains/oms/install-guide/ 참조)
status: active
version: 1.0.0
repo_role: ai-hub
agent_usage: reference
domain: system
---

# BE 빌드·배포 가이드 (Gradle / Spring Boot)

> 이 가이드는 **Gradle + Spring Boot(`bootWar`)** 스택 기준이다. 경로 변수(`$BE_DIR` = 워크스페이스 형제 BE 레포, `{프로젝트}` = 프로젝트명)는 `.claude/rules/repo-paths.md` 도출 규칙을 따른다. 아래 Tomcat/JDK 절대경로는 **예시 환경 값**이므로 실제 환경에 맞게 치환한다.

## 환경 정보

| 항목        | 경로 / 값                                                                                                                 |
| --------- | ---------------------------------------------------------------------------------------------------------------------- |
| BE 소스     | `$BE_DIR` (워크스페이스 형제 `{프로젝트}-be`, → `.claude/rules/repo-paths.md`)                                                       |
| Tomcat    | `C:\zinide\apache-tomcat-9.0.91`                                                                                       |
| JAVA_HOME | `C:\zinide\java\jdk11.0.17`                                                                                            |
| 포트        | 8080                                                                                                                   |
| 빌드 도구     | Gradle (`./gradlew bootWar`)                                                                                           |
| WAR 결과물   | `build/libs/{프로젝트}-be.war`                                                                                                |
| 배포 경로     | `C:\zinide\apache-tomcat-9.0.91\webapps\{프로젝트}-be.war`                                                                    |
| 활성 프로파일   | 기동 옵션 `-Dspring.profiles.active`(또는 환경변수 `SPRING_PROFILES_ACTIVE`)로 지정. **미지정 시 기동 실패** (`{프로젝트}Application.configure()`) |

> **셸 환경**: 아래 명령어는 모두 **Git Bash** 기준이다. PowerShell에서는 `gradlew.bat` 실행 시 문제가 있으므로 Git Bash를 사용한다.

---

## 배포 절차

### 1. Gradle 빌드

```bash
cd "$BE_DIR"   # 워크스페이스 형제 BE 레포 (→ .claude/rules/repo-paths.md)
export JAVA_HOME=/c/zinide/java/jdk11.0.17   # 예시 — 실제 JDK 경로로 치환
export PATH="$JAVA_HOME/bin:$PATH"
./gradlew bootWar --no-daemon
```

성공 시 `BUILD SUCCESSFUL` 출력, `build/libs/{프로젝트}-be.war` (약 133MB) 생성.

### 2. Tomcat 실행 여부 확인 및 중지

```bash
# 8080 포트 점유 여부 확인
netstat -ano | grep ':8080'

# 실행 중이면 중지
cd /c/zinide/apache-tomcat-9.0.91
./bin/shutdown.sh
sleep 5
```

### 3. WAR 복사

```bash
cp "$BE_DIR/build/libs/{프로젝트}-be.war" \
   /c/zinide/apache-tomcat-9.0.91/webapps/{프로젝트}-be.war   # Tomcat 경로는 예시
```

### 4. Tomcat 기동

```bash
export JAVA_HOME=/c/zinide/java/jdk11.0.17
export PATH="$JAVA_HOME/bin:$PATH"
cd /c/zinide/apache-tomcat-9.0.91
./bin/startup.sh
```

### 5. 기동 로그 확인

```bash
tail -f /c/zinide/apache-tomcat-9.0.91/logs/catalina.out
```

| 키워드 | 의미 |
|---|---|
| `Server startup in` | 기동 성공 |
| `DispatcherServlet ... initialized` | 기동 성공 |
| `SEVERE` / `Exception` / `FAILED` | 기동 실패 |

### 6. HTTP 동작 확인

```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/{프로젝트}-be/
```

HTTP 200·302·401·403 응답이면 정상 배포 완료.

---

## Tomcat setenv.bat 설정

`C:\zinide\apache-tomcat-9.0.91\bin\setenv.bat` 설정 예:

```bat
set "CATALINA_OPTS=-Dspring.profiles.active=prod -Dspring.profiles.solution=service -Xms512m -Xmx1024m -Dfile.encoding=UTF-8"
set "JAVA_HOME=C:\zinide\java\jdk11.0.17"
```

MUST: 외부 Tomcat 배포 시 `-Dspring.profiles.active` 값을 서버 용도에 맞게 지정한다.

| 서버 용도 | 설정 값 |
|---|---|
| 운영 | `-Dspring.profiles.active=prod` |
| 테스트 서버 | `-Dspring.profiles.active=test` |

> `{프로젝트}Application.configure()`는 `-Dspring.profiles.active`(없으면 환경변수 `SPRING_PROFILES_ACTIVE`)를 그대로 활성 프로파일로 사용한다.
> 둘 다 미지정이면 `IllegalStateException`으로 기동이 실패하므로 반드시 명시해야 한다.

---

## 프로파일별 외부 배포 (prod / test)

동일한 `{프로젝트}-be.war` 한 개를 기동 옵션만 바꿔 운영·테스트 서버에 배포한다. WAR 빌드 시 프로파일을 선택하지 않으며, `application-{dev,test,prod}.properties`가 모두 WAR에 포함된다(`build.gradle`의 `sourceSets.main.resources = src/main/resource`).

| 항목 | prod 배포 | test 배포 |
|---|---|---|
| WAR 파일 | `{프로젝트}-be.war` (동일) | `{프로젝트}-be.war` (동일) |
| 프로파일 옵션 | `-Dspring.profiles.active=prod` | `-Dspring.profiles.active=test` |
| DB 접속정보 | `application-prod.properties` — `ENC(...)` 암호화 | `application-test.properties` — 평문 (`{프로젝트}-test`) |
| Jasypt 키 | `-Djasypt.encryptor.password=키값` **필수** | **불필요** (평문이므로) |
| Flyway | `flyway.url=` 빈 값 → 기동 실패 이슈 주의 (아래 참고) | `flyway.url` 채워짐 + `flyway.enabled=false` → 이슈 없음 |

MUST: test 서버 배포 시 `setenv.bat`의 `-Dspring.profiles.active` 값만 `test`로 바꾼다. 그 외 추가 설정 변경은 없다.

```bat
set "CATALINA_OPTS=-Dspring.profiles.active=test -Dspring.profiles.solution=service -Xms512m -Xmx1024m -Dfile.encoding=UTF-8"
```

> 미확인(표준 동작 기준): 외부 Tomcat WAR 배포에서 컨텍스트 경로는 WAR 파일명(`{프로젝트}-be.war` → `/{프로젝트}-be`)으로 결정되며, `application-test.properties`의 `server.servlet.context-path=/{프로젝트}-be`는 내장 Tomcat 전용이라 무시된다. 두 값이 `/{프로젝트}-be`로 동일해 충돌은 없으나, test 서버 첫 배포 시 접속 경로(`/{프로젝트}-be/`)를 확인한다.

### 안전 가드: 외부 DB Flyway 차단

`FlywayConfig.java`는 `flyway.url`이 `localhost`/`127.0.0.1`이 아니면 `flyway.enabled=true`여도 마이그레이션을 강제 차단한다. 따라서 test/prod DB를 향한 실수 마이그레이션은 발생하지 않는다.

---

## 알려진 이슈

### Flyway 초기화 실패

**증상**: 기동 시 아래 오류 발생

```
org.flywaydb.core.api.FlywayException: Missing required JDBC URL. Unable to create DataSource!
```

**원인**:
1. 외부 Tomcat 배포 시 `-Dspring.profiles.active=prod`로 기동 → `prod` 프로파일 활성화
2. `application-prod.properties`의 `flyway.url=` 값이 비어 있음
3. `FlywayConfig.java`가 `flyway.enabled=false`여도 `dataSource()` 호출

**해결 방법**:

| 방법 | 내용 |
|---|---|
| A. Jasypt 키 추가 | `setenv.bat`에 `-Djasypt.encryptor.password=키값` 추가 → `ENC(...)` 값 자동 복호화 |
| B. FlywayConfig 수정 | `flyway.url` 빈 값이면 초기화 건너뛰도록 guard 추가 |

---

## 참고: 기존 배포 앱

같은 Tomcat `webapps/`에 다른 프로젝트 앱이 이미 배포되어 있을 수 있다. 배포·중지 작업 시 대상 `{프로젝트}-be` 외의 앱은 건드리지 않는다.
