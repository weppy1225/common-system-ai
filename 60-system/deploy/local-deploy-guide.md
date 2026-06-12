# cloud-wms-be 로컬 빌드·배포 가이드

## 환경 정보

| 항목 | 경로 / 값 |
|---|---|
| BE 소스 | `C:\zinide\workspace\cloud-wms-be` |
| Tomcat | `C:\zinide\apache-tomcat-9.0.91` |
| JAVA_HOME | `C:\zinide\java\jdk11.0.17` |
| 포트 | 8080 |
| 빌드 도구 | Gradle (`./gradlew bootWar`) |
| WAR 결과물 | `build/libs/wms-be.war` |
| 배포 경로 | `C:\zinide\apache-tomcat-9.0.91\webapps\wms-be.war` |
| 활성 프로파일 | 기동 옵션 `-Dspring.profiles.active`(또는 환경변수 `SPRING_PROFILES_ACTIVE`)로 지정. **미지정 시 기동 실패** (`WmsApplication.configure()`) |

> **셸 환경**: 아래 명령어는 모두 **Git Bash** 기준이다. PowerShell에서는 `gradlew.bat` 실행 시 문제가 있으므로 Git Bash를 사용한다.

---

## 배포 절차

### 1. Gradle 빌드

```bash
cd /c/zinide/workspace/cloud-wms-be
export JAVA_HOME=/c/zinide/java/jdk11.0.17
export PATH="$JAVA_HOME/bin:$PATH"
./gradlew bootWar --no-daemon
```

성공 시 `BUILD SUCCESSFUL` 출력, `build/libs/wms-be.war` (약 133MB) 생성.

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
cp /c/zinide/workspace/cloud-wms-be/build/libs/wms-be.war \
   /c/zinide/apache-tomcat-9.0.91/webapps/wms-be.war
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
curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/wms-be/
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

> `WmsApplication.configure()`는 `-Dspring.profiles.active`(없으면 환경변수 `SPRING_PROFILES_ACTIVE`)를 그대로 활성 프로파일로 사용한다.
> 둘 다 미지정이면 `IllegalStateException`으로 기동이 실패하므로 반드시 명시해야 한다.

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

Tomcat `webapps/`에 `wms-bnk-be`가 이미 배포되어 있다. 배포·중지 작업 시 건드리지 않는다.
