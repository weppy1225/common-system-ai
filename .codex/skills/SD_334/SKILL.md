---
name: SD_334
description: "【DB 관계도(ERD) HTML 생성 (실DB, Windows/WSL/Linux/Mac 통합)】 사용자가 지정한 백엔드 디렉토리의 `application-test.properties` 를 자동 탐색하여 PostgreSQL DB 접속정보를 파싱하고, `psql`(또는 `psql.exe`) / `python3 + psycopg2` 로 `pg_catalog` 에 직접 접속해 테이블·컬럼·FK를 추출한 뒤, 기존 `output/03 설계(SD)/SD.211-ERD_*.html` 최신 파일을 템플릿으로 재사용하여 `const TABLES=[...]` 와 `const FKS=[...]` 두 섹션만 DB 최신 상태로 교체한 ERD 뷰어 HTML 파일을 생성합니다. 실행 환경(Windows PowerShell vs WSL/Linux/macOS Bash)을 자동 감지하여 해당 OS 분기 블록만 실행합니다. 뷰어 코드(CSS·JS 함수·SVG 마커·SUBGROUP_DEF·MAPPING_TBLS 등)는 템플릿에서 그대로 유지하므로 새 테이블 그룹이 추가될 때만 템플릿 파일을 직접 수정하면 됩니다. /SD_334 형식으로 실행하며 BE 경로·업체명은 실행 시 묻습니다. 산출물은 `output/03 설계(SD)/SD.211-ERD_{업체명}_{YYMMDD}.html` 단일 HTML 파일로 떨어지며 브라우저에서 바로 열어 노드 드래그·줌·검색·계층 레이아웃 토글이 가능합니다. DB 관계도 작성, ERD HTML 생성·갱신, 테이블 관계 시각화, 산출물용 ERD 뷰어 만들기 요청 시 반드시 이 스킬을 사용합니다. 사용자가 \"DB 관계도 만들어줘\", \"ERD 뽑아줘\", \"ERD 갱신해줘\", \"테이블 관계 시각화\", \"ERD 뷰어 만들어줘\", \"SD_334 실행해줘\", \"WSL에서 ERD 만들어줘\", \"Linux에서 DB 관계도 갱신해줘\" 라고 말해도 이 스킬을 사용합니다. 단, 엑셀 형태의 테이블정의서가 필요하면 /SD_331 을 사용합니다."
metadata:
  short-description: "Use .claude/skills/SD_334 as the source skill"
---

# SD_334

This is a thin Codex wrapper. Source of truth: [../../../.claude/skills/SD_334/SKILL.md](../../../.claude/skills/SD_334/SKILL.md).

When this skill is used:
- Read ../../../.claude/skills/SD_334/SKILL.md first and follow that workflow.
- Resolve relative paths such as scripts/, evals/, or referenced assets from ../../../.claude/skills/SD_334/.
- Keep implementation and generated helper scripts in the .claude skill directory unless the user explicitly asks to fork them for Codex.