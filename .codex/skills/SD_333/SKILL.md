---
name: SD_333
description: "【DB Schema DDL SQL 생성 (실DB 접속, Windows/WSL/Linux/Mac 통합)】 사용자가 지정한 디렉토리의 DB 설정 파일을 자동 스캔해 실제 PostgreSQL DB에 직접 접속하고, pg_catalog 기반 쿼리로 SEQUENCE / TABLE / PRIMARY KEY / UNIQUE / FOREIGN KEY / INDEX 의 DDL(CREATE/ALTER 문)을 추출하여 `output/03 설계(SD)/SD_333_DB_Schema(DDL)_{고객사명}_{YYMMDD}.sql` 단일 SQL 파일로 자동 저장합니다. 실행 환경(Windows PowerShell vs WSL/Linux/macOS Bash)을 자동 감지하여 해당 OS 분기 블록만 실행합니다. /SD_333 형식으로 실행하며 디렉토리·고객사명은 실행 시 묻습니다. psql.exe·pg_dump 등 OS 클라이언트가 설치되지 않아도 동작하며, Python + psycopg2-binary 만 있으면 됩니다. (PG10 클라이언트 ↔ PG15 서버처럼 버전이 안 맞는 환경에서도 사용 가능.) DDL 추출, DB Schema SQL 생성, CREATE TABLE/INDEX/FK 스크립트 만들기, DB 스냅샷 SQL 산출물 요청 시 반드시 이 스킬을 사용합니다. 사용자가 \"DDL 뽑아줘\", \"DB 스키마 SQL로 추출\", \"CREATE TABLE 스크립트 만들어줘\", \"PostgreSQL DDL 산출물\", \"SD_333 실행해줘\", \"윈도우에서 DB Schema DDL 뽑아줘\", \"WSL에서 DDL 추출해줘\", \"Linux에서 PostgreSQL DDL 산출물\" 라고 말해도 이 스킬을 사용합니다. 단, 엑셀 형태의 테이블정의서가 필요하면 /SD_331, 인터랙티브 ERD HTML이 필요하면 /SD_334 쪽이 맞으니 산출물 형식(SQL/Excel/HTML)을 먼저 확인해 분기합니다."
metadata:
  short-description: "Use .claude/skills/SD_333 as the source skill"
---

# SD_333

This is a thin Codex wrapper. Source of truth: [../../../.claude/skills/SD_333/SKILL.md](../../../.claude/skills/SD_333/SKILL.md).

When this skill is used:
- Read ../../../.claude/skills/SD_333/SKILL.md first and follow that workflow.
- Resolve relative paths such as scripts/, evals/, or referenced assets from ../../../.claude/skills/SD_333/.
- Keep implementation and generated helper scripts in the .claude skill directory unless the user explicitly asks to fork them for Codex.