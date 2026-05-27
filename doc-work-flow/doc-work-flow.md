# 산출물자동화모듈 목록

> 총 32개 산출물 중 AI 자동화 대상: **15개** · 대상 아님: **17개**

## 전체 목록

| No | 단계 | 산출물번호 | 산출물명 | 형식 | 카테고리 | AI 적용 | 완료율 |
|---|---|---|---|---|---|---|---|
| 1 | 프로젝트시작 | PS_111 | 사업수행계획서 | .xlsx | 📋 관리 | ❌ | - |
| 2 | 프로젝트시작 | PS_112 | WBS | .xlsx | 📋 관리 | ❌ | - |
| 3 | 프로젝트시작 | PS_113 | 산출물내역서 | .xlsx | 📋 관리 | ❌ | - |
| 4 | 분석 | RA_211 | 회의록 | .xlsx | 📄 문서 | ❌ | - |
| 5 | 분석 | RA_221 | 메뉴현황 | .xlsx | 📄 문서 | ❌ | - |
| 6 | 분석 | RA_222 | 요구사항정의서 | .xlsx | 📄 문서 | ✅ | 50% |
| 7 | 분석 | RA_223 | 업무흐름도 | .drawio | 📄 문서 | ❌ | - |
| 8 | 분석 | RA_224 | 기준정보정의서 | .xlsx | 📄 문서 | ❌ | - |
| 9 | 분석 | RA_225 | 출력물목록 | .xlsx | 📄 문서 | ❌ | - |
| 10 | 설계 | SD_311 | WEB 화면설계서 | .html | 🖥 화면 | ✅ | 80% |
| 11 | 설계 | SD_312 | PDA 화면설계서 | .html | 🖥 화면 | ✅ | 60% |
| 12 | 설계 | SD_321 | 인터페이스설계서 | .xlsx | 📄 문서 | ❌ | - |
| 13 | 설계 | SD_331 | 테이블정의서 | .xlsx | 🗄 DB | ✅ | 50% |
| 14 | 설계 | SD_332 | 공통코드목록 | .xlsx | 🗄 DB | ✅ | 80% |
| 15 | 설계 | SD_333 | DB구축스크립트 | .sql | 🗄 DB | ✅ | 80% |
| 16 | 설계 | SD_334 | DB관계도 | .html | 🗄 DB | ✅ | 50% |
| 17 | 설계 | SD_341 | 시스템구성도 | .drawio | 📄 문서 | ❌ | - |
| 18 | 구현 | PI_411 | 프로그램소스 | .zip | 💻 코드 | ✅ | 70% |
| 19 | 구현 | PI_412 | 프로그램목록 | .xlsx | 💻 코드 | ✅ | 60% |
| 20 | 구현 | PI_421 | 단위테스트보고서 | .xlsx | 🧪 테스트 | ✅ | 60% |
| 21 | 구현 | PI_422 | 통합테스트보고서 | .xlsx | 🧪 테스트 | ✅ | 60% |
| 22 | 이행 | TT_511 | 설치확인서 | .xlsx | 🔧 운영 | ❌ | - |
| 23 | 이행 | TT_521 | 시스템설치매뉴얼 | .docx | 📖 매뉴얼 | ❌ | - |
| 24 | 이행 | TT_531 | 인수테스트결과보고서 | .xlsx | 🧪 테스트 | ❌ | - |
| 25 | 이행 | TT_541 | PC 사용자매뉴얼 | .pptx | 📖 매뉴얼 | ✅ | 70% |
| 26 | 이행 | TT_542 | PDA 사용자매뉴얼 | .pptx | 📖 매뉴얼 | ✅ | - |
| 27 | 이행 | TT_543 | 운영자매뉴얼 | .pptx | 📖 매뉴얼 | ✅ | 50% |
| 28 | 이행 | TT_551 | DB이관계획서 | .xlsx | 🗄 DB | ✅ | 50% |
| 29 | 프로젝트관리 | PM_611 | 착수보고서 | .pptx | 📋 관리 | ❌ | - |
| 30 | 프로젝트관리 | PM_612 | 중간보고서 | .pptx | 📋 관리 | ❌ | - |
| 31 | 프로젝트관리 | PM_621 | 주간보고서 | .xlsx | 📋 관리 | ❌ | - |
| 32 | 프로젝트관리 | PM_622 | 완료보고서 | .pptx | 📋 관리 | ❌ | - |

---

## AI 적용 대상 (15개)

| No | 단계 | 산출물번호 | 산출물명 | 형식 | 입력 | 출력 | 완료율 |
|---|---|---|---|---|---|---|---|
| 6 | 분석 | RA_222 | 요구사항정의서 | .xlsx | 회의록 Excel (input/RA.212/*) | RA_222_요구사항정의서_{업체명}.xlsx | 50% |
| 10 | 설계 | SD_311 | WEB 화면설계서 | .html | ui.md + 공통 템플릿 | SD_311_WEB화면설계서_{업체명}.html | 80% |
| 11 | 설계 | SD_312 | PDA 화면설계서 | .html | ui.md + PDA 템플릿 | SD_312_PDA화면설계서_{업체명}.html | 60% |
| 13 | 설계 | SD_331 | 테이블정의서 | .xlsx | application-test.properties | SD_331_테이블정의서_{업체명}.xlsx | 50% |
| 14 | 설계 | SD_332 | 공통코드목록 | .xlsx | application-test.properties | SD_332_공통코드목록_{업체명}.xlsx | 80% |
| 15 | 설계 | SD_333 | DB구축스크립트 | .sql | application-test.properties | SD_333_DB구축스크립트_{업체명}.sql | 80% |
| 16 | 설계 | SD_334 | DB관계도 | .html | application-test.properties + ERD 템플릿 | SD_334_DB관계도_{업체명}.html | 50% |
| 18 | 구현 | PI_411 | 프로그램소스 | .zip | BE/FE GitHub 저장소 | PI_411_프로그램소스_{업체명}.zip | 70% |
| 19 | 구현 | PI_412 | 프로그램목록 | .xlsx | BE 소스코드 경로 | PI_412_프로그램목록_{업체명}.xlsx | 60% |
| 20 | 구현 | PI_421 | 단위테스트보고서 | .xlsx | BE 소스코드 + 테스트 코드 | PI_421_단위테스트보고서_{업체명}.xlsx | 60% |
| 21 | 구현 | PI_422 | 통합테스트보고서 | .xlsx | ui.md + FE/PDA 화면 | PI_422_통합테스트보고서_{업체명}.xlsx | 60% |
| 25 | 이행 | TT_541 | PC 사용자매뉴얼 | .pptx | FE 소스 + Playwright 캡처 | TT_541_PC사용자매뉴얼_{업체명}.pptx | 70% |
| 26 | 이행 | TT_542 | PDA 사용자매뉴얼 | .pptx | FE 소스 + Playwright 캡처 (PDA) | TT_542_PDA사용자매뉴얼_{업체명}.pptx | - |
| 27 | 이행 | TT_543 | 운영자매뉴얼 | .pptx | FE+BE 소스 + 운영자메뉴리스트 | TT_543_운영자매뉴얼_{업체명}.pptx | 50% |
| 28 | 이행 | TT_551 | DB이관계획서 | .xlsx | migrate_*.ps1 스크립트 | TT_551_DB이관계획서_{업체명}.xlsx | 50% |

---

## 단계별 요약

| 단계 | 전체 | AI 대상 | 대상 아님 |
|---|---|---|---|
| 프로젝트시작 (PS) | 3 | 0 | 3 |
| 분석 (RA) | 5 | 1 | 4 |
| 설계 (SD) | 8 | 7 | 1 |
| 구현 (PI) | 4 | 4 | 0 |
| 이행 (TT) | 7 | 4 | 3 |
| 프로젝트관리 (PM) | 4 | 0 | 4 |
| **합계** | **32** | **15** | **17** |

---

## 기술 스택 (AI 대상 산출물)

| 산출물번호 | 실행 방식 | 주요 기술 |
|---|---|---|
| RA_222 | Python 스크립트 | openpyxl, 회의록 파싱 |
| SD_311 | Claude Code 슬래시 커맨드 | HTML 템플릿, ui.md |
| SD_312 | Claude Code 슬래시 커맨드 | HTML 템플릿, PDA ui.md |
| SD_331 | Python 스크립트 | psycopg2, INFORMATION_SCHEMA, openpyxl |
| SD_332 | Python 스크립트 | psycopg2, 공통코드 테이블 조회, openpyxl |
| SD_333 | Python 스크립트 | psycopg2, DDL 추출 |
| SD_334 | Claude Code 슬래시 커맨드 | HTML ERD 템플릿, psycopg2 |
| PI_411 | Claude Code 슬래시 커맨드 | GitHub API, ZIP 다운로드 |
| PI_412 | Python 스크립트 | 소스코드 스캔, openpyxl |
| PI_421 | Python 스크립트 | JUnit 테스트 추출, openpyxl |
| PI_422 | Node.js 스크립트 | xlsx-populate, Playwright |
| TT_541 | Node.js + Python | Playwright 캡처, python-pptx |
| TT_542 | Node.js + Python | Playwright 모바일 캡처, python-pptx |
| TT_543 | Node.js + Python | Playwright 캡처, Vue 소스 파서, python-pptx |
| TT_551 | PowerShell 스크립트 | migrate_V*.ps1, DB 이관 |
