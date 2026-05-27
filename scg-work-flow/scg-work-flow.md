# 개발자동화모듈 워크플로우 목록

| No | 단계 | 명령어 | 역할 |
|---|---|---|---|
| 1 | 프로젝트시작 | PS-doc-copy | 프로젝트 산출물 폴더 생성 |
| 2 | 프로젝트시작 | PS-git-copy | Git 저장소 생성 (doc/be/fe) |
| 3 | 프로젝트시작 | PS-redmine-batch | 개발자별 레드마인 일감 일괄 등록 |
| 4 | 설계 | SD-dict (예정) | 개발 용어 DB화 (데이터 사전) |
| 5 | 설계 | SD-ui | 화면요건 → wireframe.html + mock-data.js |
| 6 | 설계 | SD-db | 화면·DB 정보 → DB 설계서 + Flyway SQL |
| 7 | 설계 | SD-db-apply | Flyway SQL → 로컬 개발 DB 자동 반영 |
| 8 | 설계 | SD-api | DB·화면 설계 → API 명세서 + Mockoon |
| 9 | 구현 BE | PI-be-all | BE 전체 레이어 소스 생성 + Bruno 파일 |
| 10 | 구현 BE | PI-be-mapper | Mapper 레이어 소스 생성 |
| 11 | 구현 BE | PI-be-dao | Dao 레이어 소스 생성 |
| 12 | 구현 BE | PI-be-comp | Comp·Controller 전체 소스 생성 (TxComp 포함) |
| 13 | 구현 BE | PI-be-excel | Excel 업로드 컨트롤러 소스 생성 |
| 14 | 구현 BE | PI-be-inven | 재고 모듈 (TxComp) 소스 생성 |
| 15 | 테스트 BE | PI-test-be | Bruno 활용 API 자동 테스트 실행 |
| 16 | 구현 FE | PI-fe-all | FE 전체 Vue 소스 생성 + router |
| 17 | 구현 FE | PI-fe-list | 검색조건 + 그리드 목록 화면 생성 |
| 18 | 구현 FE | PI-fe-edit | 등록·수정 팝업 (LayerPopup + 폼) 생성 |
| 19 | 테스트 FE | PI-test-fe | Mockoon 활용 FE 단독 테스트 |
| 20 | 테스트 통합 | PI-test-all | Playwright 활용 FE+BE 연동 테스트 |
| 21 | 이력관리 | PI-issue-mod | 커밋 타이밍에 레드마인 이슈 자동 수정 |
| 22 | 이력관리 | PI-time-reg | 커밋 타이밍에 레드마인 작업시간 자동 등록 |
| 23 | 배포 | TT-deploy-test | Jenkins 활용 테스트·운영 서버 배포 |
| 24 | 보안 | (민감정보 마스킹) | Claude 입력 전 개인정보·인증키 마스킹 |
| 25 | 보안 | (클로드기록 삭제) | Claude 대화 이력 보안 삭제 |
