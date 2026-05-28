---
name: SD_331
description: "【테이블정의서 엑셀 생성 (실DB 접속, Windows/WSL/Linux/Mac 통합)】 사용자가 지정한 디렉토리의 DB 설정 파일을 자동 스캔해 실제 DB(PostgreSQL/MySQL/MariaDB/MSSQL/Oracle)에 직접 접속하고, 시스템 카탈로그에서 스키마를 추출하여 SD.212-테이블정의서 엑셀 파일을 자동 생성합니다. 실행 환경(Windows PowerShell vs WSL/Linux/macOS Bash)을 자동 감지하여 해당 OS 분기 블록만 실행합니다. /SD_331 {디렉토리경로} 형식으로 실행합니다. 기존 /SD_212(테이블 MD 파싱)와 /SD_212_DDL(DDL 파일 파싱)과 달리, 살아있는 DB에 직접 붙어 information_schema/pg_catalog/sys.*/user_* 등을 조회해 테이블·컬럼·인덱스·제약조건·FK를 뽑아낸다는 점이 다릅니다. 사용자가 \"DB에서 직접 테이블정의서 뽑아줘\", \"라이브 DB 스키마 엑셀로\", \"운영 DB 접속해서 테이블 명세서\", \"DB 카탈로그 추출\", \"SD_331 실행해줘\", \"WSL에서 테이블정의서 뽑아줘\", \"Linux에서 라이브 DB 스키마 엑셀로\" 라고 말하면 이 스킬을 사용합니다. 단, 사용자가 단순히 \"테이블정의서 만들어줘\"라고만 말하고 DB 접속을 원치 않는 정황(MD 파일이나 DDL 파일을 언급)이면 /SD_212나 /SD_212_DDL 쪽이 맞을 수 있으니, 입력 소스(MD/DDL/실DB)를 먼저 확인하여 분기합니다."
metadata:
  short-description: "Use .claude/skills/SD_331 as the source skill"
---

# SD_331

This is a thin Codex wrapper. Source of truth: [../../../.claude/skills/SD_331/SKILL.md](../../../.claude/skills/SD_331/SKILL.md).

When this skill is used:
- Read ../../../.claude/skills/SD_331/SKILL.md first and follow that workflow.
- Resolve relative paths such as scripts/, evals/, or referenced assets from ../../../.claude/skills/SD_331/.
- Keep implementation and generated helper scripts in the .claude skill directory unless the user explicitly asks to fork them for Codex.