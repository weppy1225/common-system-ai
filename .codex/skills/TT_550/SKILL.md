---
name: TT_550
description: "【DB 이관용 SQL 준비물 생성 (실DB 접속, Windows/WSL/Linux/Mac 통합)】 사용자가 지정한 백엔드 디렉토리의 DB 설정 파일을 자동 스캔해 인하우스 PostgreSQL DB에 접속하고, `COMMENT ON TABLE` 의 `@migrate:` 마커가 달린 테이블만 자동 수집하여 그룹별 INSERT SQL 파일과 메타데이터(manifest.json)를 생성합니다. 실행 환경(Windows PowerShell vs WSL/Linux/macOS Bash)을 자동 감지하여 해당 OS 분기 블록만 실행합니다. 산출물은 `output/05 이행(TT)/TT_550_DATA_{고객사명}_{YYMMDD}/` 폴더에 그룹별 `.sql` 파일 + `manifest.json` 으로 떨어지며, 이 폴더는 후속 스킬 /TT_551 의 입력이 됩니다. SQL 파일은 도구 중립적 plain SQL(Flyway 비의존)이라 고객사는 `psql -f` 한 줄로 적용 가능합니다. /TT_550 형식으로 실행하며 백엔드 경로·고객사명·dump 그룹은 실행 시 묻습니다. 실행 모드는 자동 감지: Python+psycopg2 가 있으면 PYTHON 모드(psycopg2로 wire protocol 접속, pg_dump 버전 충돌 무관), 없으면 POWERSHELL 모드(psql/pg_dump --inserts, Windows 한정), 둘 다 없으면 에러로 종료합니다. WSL/Linux/Mac은 Python(psycopg2) 모드만 지원합니다. 핵심 설계: (1) AI는 DB에 직접 INSERT/UPDATE 를 쏘지 않고 결정론적 SQL 텍스트만 생성, (2) 매핑은 DB 자체의 COMMENT 에 박혀 있어 외부 YAML/상수 동기화 불필요, (3) 고객사 대상 DB 적용은 옵션으로 마지막에 묻기. DB 이관용 SQL 준비물 생성, dump SQL 파일 만들기, 공통코드/마스터 데이터 INSERT 스크립트 만들기, 이관계획서 생성 전 SQL 패키지 만들기 요청 시 반드시 이 스킬을 사용합니다. 사용자가 \"DB 이관 SQL 만들어줘\", \"공통코드 데이터 dump 떠줘\", \"마스터 데이터 INSERT 스크립트\", \"TT_550 실행해줘\", \"이관계획서용 SQL 패키지\", \"WSL에서 DB 이관 SQL 만들어줘\", \"Linux에서 공통코드 dump 떠줘\" 라고 말해도 이 스킬을 사용합니다. 단, DDL(스키마) 만 필요하면 /SD_333, DB 이관계획서 엑셀이 필요하면 /TT_551(이 스킬 실행 후 호출)을 사용합니다."
metadata:
  short-description: "Use .claude/skills/TT_550 as the source skill"
---

# TT_550

This is a thin Codex wrapper. Source of truth: [../../../.claude/skills/TT_550/SKILL.md](../../../.claude/skills/TT_550/SKILL.md).

When this skill is used:
- Read ../../../.claude/skills/TT_550/SKILL.md first and follow that workflow.
- Resolve relative paths such as scripts/, evals/, or referenced assets from ../../../.claude/skills/TT_550/.
- Keep implementation and generated helper scripts in the .claude skill directory unless the user explicitly asks to fork them for Codex.