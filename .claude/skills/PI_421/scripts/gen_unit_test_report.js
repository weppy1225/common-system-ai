/**
 * PI_212 단위테스트 보고서 생성 스크립트
 * class-checkin-be / class-checkin-fe 소스 기반
 */
const XLSX = require('../node_modules/xlsx');
const path = require('path');
const fs = require('fs');

// ───────────────────────────────────────────────────────────────────
// 상수
// ───────────────────────────────────────────────────────────────────
const PROJ_NM  = 'ClassCheckIn';
const TODAY    = '2026-05-06';
const TODAY_NUM = 46147; // Excel serial date for 2026-05-06
const MANAGER  = '신현규';
const TMPL = path.join(__dirname, '../template/04 구현(PI)/PI_212-단위테스트보고서.xlsx');
const OUTDIR = path.join(__dirname, '../output/04 구현(PI)');
const OUTFILE  = path.join(OUTDIR, `PI_212-단위테스트보고서_${PROJ_NM}_260506.xlsx`);

// ───────────────────────────────────────────────────────────────────
// 테스트 데이터 정의
// 컬럼: [플랫폼, 대메뉴, 테스트ID, 메뉴, 구분, 내용, 결과]
// 플랫폼: API(백엔드 단위) / MOBILE(앱 화면)
// ───────────────────────────────────────────────────────────────────
const PASS = 'O';

const tests = [
  // ─── 공통코드 (fw/sys/comm) ───
  ['API','공통','SYS-001','공통코드(SysComm)','기능','BANK_CD 그룹 단일 조회 — 17건·순서·명칭 정상 반환', PASS],
  ['API','공통','SYS-002','공통코드(SysComm)','기능','미존재 코드 그룹 조회 — list=[], procCnt=0 정상 반환', PASS],
  ['API','공통','SYS-003','공통코드(SysComm)','기능','전체 그룹 일괄 조회 — groups 21개 이상 반환', PASS],
  ['API','공통','SYS-004','공통코드(SysComm)','보안','인증 없이 호출 시 401 Unauthorized 반환', PASS],

  // ─── LOIN01M 로그인 ───
  ['API','인증','LOIN-001','로그인(LOIN01M)','데이터','학원코드(AB0001)로 학원 조회 정상 반환', PASS],
  ['API','인증','LOIN-002','로그인(LOIN01M)','데이터','사용자ID(manymoa@naver.com)로 사용자 조회 정상 반환', PASS],
  ['API','인증','LOIN-003','로그인(LOIN01M)','데이터','사용자 역할 목록 조회 — 비어있지 않음', PASS],
  ['API','인증','LOIN-004','로그인(LOIN01M)','기능','비밀번호 실패횟수 증가 처리 정상', PASS],
  ['API','인증','LOIN-005','로그인(LOIN01M)','기능','실패횟수 초기화 및 로그인 기록 정상', PASS],
  ['API','인증','LOIN-006','로그인(LOIN01M)','기능','접속 로그 기록(insertLogConn) 정상 저장', PASS],
  ['API','인증','LOIN-007','로그인(LOIN01M)','데이터','사용자 정보(selectUserInfo) 조회 정상 반환', PASS],

  // ─── SIGN01M 회원가입 ───
  ['API','인증','SIGN-001','회원가입(SIGN01M)','데이터','추천인코드로 추천인 조회 정상', PASS],
  ['API','인증','SIGN-002','회원가입(SIGN01M)','기능','학원코드 중복 확인(selectAcadCdExists) 정상', PASS],
  ['API','인증','SIGN-003','회원가입(SIGN01M)','기능','사용자 존재 확인(selectUserExists) 정상', PASS],
  ['API','인증','SIGN-004','회원가입(SIGN01M)','기능','사용자ID 중복 확인(selectUserIdExists) 정상', PASS],
  ['API','인증','SIGN-005','회원가입(SIGN01M)','기능','학원 등록(insertAcadWithSeq) — acadSeq 자동 채번 정상', PASS],
  ['API','인증','SIGN-006','회원가입(SIGN01M)','기능','사용자 등록(insertUser) — userSeq 자동 채번 정상', PASS],
  ['API','인증','SIGN-007','회원가입(SIGN01M)','기능','사용자 역할 등록(insertUserRole) 정상', PASS],
  ['API','인증','SIGN-008','회원가입(SIGN01M)','데이터','추천인코드 시퀀스 다음값 조회 정상', PASS],
  ['API','인증','SIGN-009','회원가입(SIGN01M)','데이터','학원코드로 학원 조회(selectAcadByAcadCd) 정상 반환', PASS],
  ['API','인증','SIGN-010','회원가입(SIGN01M)','기능','선생님 상세 등록(insertUserTchr) 정상', PASS],
  ['API','인증','SIGN-011','회원가입(SIGN01M)','데이터','역할 존재 확인(selectUserRoleExists) 정상', PASS],

  // ─── SESE01M 세션/보안 ───
  ['API','인증','SESE-001','세션관리(SESE01M)','기능','로그아웃 — succeed=true 정상 반환', PASS],
  ['API','인증','SESE-002','세션관리(SESE01M)','기능','비밀번호 변경 — 현재 비밀번호 불일치 시 succeed=false 반환', PASS],

  // ─── ACRE01M 학원 관리 ───
  ['API','학원관리','ACRE-001','학원관리(ACRE01M)','데이터','학원 등록 — Mapper SQL 정상 실행', PASS],
  ['API','학원관리','ACRE-002','학원관리(ACRE01M)','데이터','학원 목록 조회 — Mapper SQL 정상 실행', PASS],
  ['API','학원관리','ACRE-003','학원관리(ACRE01M)','데이터','학원 수정 — Mapper SQL 정상 실행', PASS],
  ['API','학원관리','ACRE-004','학원관리(ACRE01M)','데이터','학원 삭제 — Mapper SQL 정상 실행', PASS],
  ['API','학원관리','ACRE-005','학원관리(ACRE01M)','기능','학원 등록(Dao) — retCnt=1 정상', PASS],
  ['API','학원관리','ACRE-006','학원관리(ACRE01M)','기능','학원 목록 조회(Dao) — 이름 검색 정상', PASS],
  ['API','학원관리','ACRE-007','학원관리(ACRE01M)','기능','학원 단건 조회(Dao) — acadSeq 기준 1건 정상', PASS],
  ['API','학원관리','ACRE-008','학원관리(ACRE01M)','기능','학원 수정(Dao) — retCnt>=0 정상', PASS],
  ['API','학원관리','ACRE-009','학원관리(ACRE01M)','기능','학원 삭제(Dao) — 신규 등록 후 삭제, retCnt=1 정상', PASS],
  ['API','학원관리','ACRE-010','학원관리(ACRE01M)','기능','학원 등록(Comp) — procCnt=1, tran(acadSeq·acadCd·acadNm) 반환 정상', PASS],
  ['API','학원관리','ACRE-011','학원관리(ACRE01M)','기능','학원 조회(Comp) — 이름 기준 tranList 반환 정상', PASS],
  ['API','학원관리','ACRE-012','학원관리(ACRE01M)','기능','학원 단건 조회(Comp) — acadSeq 기준 tran 세팅 정상', PASS],
  ['API','학원관리','ACRE-013','학원관리(ACRE01M)','기능','학원 수정(Comp) — procCnt=1, 수정된 acadNm 반환 정상', PASS],
  ['API','학원관리','ACRE-014','학원관리(ACRE01M)','기능','학원 삭제(Comp) — 정상 삭제, procCnt=1', PASS],
  ['API','학원관리','ACRE-015','학원관리(ACRE01M)','기능','학원 삭제(Comp) — 없는 학원, procCnt=0 정상', PASS],
  ['API','학원관리','ACRE-016','학원관리(ACRE01M)','기능','POST /acad/insert — HTTP 201, procCnt=1, tran 반환', PASS],
  ['API','학원관리','ACRE-017','학원관리(ACRE01M)','기능','POST /acads — HTTP 200 목록 조회', PASS],
  ['API','학원관리','ACRE-018','학원관리(ACRE01M)','기능','POST /acads(acadSeq) — HTTP 200, tranList 1건, tran 세팅', PASS],
  ['API','학원관리','ACRE-019','학원관리(ACRE01M)','기능','POST /acad/update — HTTP 200, procCnt=1, 수정된 acadNm 반환', PASS],
  ['API','학원관리','ACRE-020','학원관리(ACRE01M)','기능','DELETE /acads — HTTP 200', PASS],

  // ─── ACLO01M 내 학원 목록 ───
  ['API','학원관리','ACLO-001','내 학원 목록(ACLO01M)','기능','POST /acads — 내 학원 목록, acadSeq=1 정상 반환', PASS],

  // ─── CLLO01M 수강반 목록 ───
  ['API','수강반관리','CLLO-001','수강반 목록(CLLO01M)','기능','수강반 목록 조회(Comp) — 스케줄 포함, 3건 이상 반환 정상', PASS],
  ['API','수강반관리','CLLO-002','수강반 목록(CLLO01M)','기능','POST /classes — HTTP 200, succeed=true, list 배열 반환', PASS],

  // ─── CLRE01M 수강반 등록 ───
  ['API','수강반관리','CLRE-001','수강반 등록(CLRE01M)','기능','선생님 목록 조회(Comp) — 2명 이상 반환, succeed=true', PASS],
  ['API','수강반관리','CLRE-002','수강반 등록(CLRE01M)','기능','수강반 상세 조회(Comp) — 전과목, schedules·studCnt 포함', PASS],
  ['API','수강반관리','CLRE-003','수강반 등록(CLRE01M)','기능','수강반 등록(Comp) — 스케줄 2개, procCnt=1 정상', PASS],
  ['API','수강반관리','CLRE-004','수강반 등록(CLRE01M)','기능','수강반 등록 — 이름 누락 시 ResponseWarnException 발생', PASS],
  ['API','수강반관리','CLRE-005','수강반 등록(CLRE01M)','기능','수강반 삭제 — 수강생 있는 반 삭제 불가(WarnException)', PASS],
  ['API','수강반관리','CLRE-006','수강반 등록(CLRE01M)','기능','POST /teachers — HTTP 200, succeed=true, list 배열', PASS],
  ['API','수강반관리','CLRE-007','수강반 등록(CLRE01M)','기능','GET /class/{seq} — HTTP 200, classNm=전과목 정상', PASS],
  ['API','수강반관리','CLRE-008','수강반 등록(CLRE01M)','기능','POST /class/insert — HTTP 200, succeed=true', PASS],

  // ─── CLSE01M 학생 수강 상세 ───
  ['API','수강반관리','CLSE-001','수강 상세(CLSE01M)','기능','POST /student — userNm=신우영 정상 조회', PASS],
  ['API','수강반관리','CLSE-002','수강 상세(CLSE01M)','기능','POST /classes — 수강반 목록 배열 반환', PASS],
  ['API','수강반관리','CLSE-003','수강 상세(CLSE01M)','기능','POST /teachers — 선생님 목록 배열 반환', PASS],
  ['API','수강반관리','CLSE-004','수강 상세(CLSE01M)','기능','POST /enrolls(studUserSeq=3) — 수강 정보 배열 반환', PASS],

  // ─── STLO01M 학생 목록 ───
  ['API','학생관리','STLO-001','학생 목록(STLO01M)','기능','학생 목록(Comp) — 전체 2명 이상, succeed=true 정상', PASS],
  ['API','학생관리','STLO-002','학생 목록(STLO01M)','기능','POST /studs — HTTP 200, succeed=true, list 배열', PASS],

  // ─── TERE01M 선생님 등록 ───
  ['API','선생님관리','TERE-001','선생님 등록(TERE01M)','기능','선생님 상세 조회(Comp) — 배숙희, succeed=true', PASS],
  ['API','선생님관리','TERE-002','선생님 등록(TERE01M)','기능','선생님 상세 — 존재하지 않는 userSeq WarnException 발생', PASS],
  ['API','선생님관리','TERE-003','선생님 등록(TERE01M)','기능','선생님 신규 등록 — procCnt=1, 이름·전화번호 정상 저장', PASS],
  ['API','선생님관리','TERE-004','선생님 등록(TERE01M)','기능','선생님 등록 — 이름 누락 WarnException 발생', PASS],
  ['API','선생님관리','TERE-005','선생님 등록(TERE01M)','기능','선생님 등록 — 전화번호 누락 WarnException 발생', PASS],
  ['API','선생님관리','TERE-006','선생님 등록(TERE01M)','기능','선생님 수정 — LEAVE 전환 시 담당반 자동 해제', PASS],
  ['API','선생님관리','TERE-007','선생님 등록(TERE01M)','기능','GET /tchr/{userSeq} — userNm=배숙희 정상 조회', PASS],
  ['API','선생님관리','TERE-008','선생님 등록(TERE01M)','기능','POST /tchr/insert — succeed=true, tchr 존재', PASS],
  ['API','선생님관리','TERE-009','선생님 등록(TERE01M)','기능','POST /tchr/update — 동일값 UPDATE, succeed=true', PASS],

  // ─── TELI01M 선생님 목록 ───
  ['API','선생님관리','TELI-001','선생님 목록(TELI01M)','기능','선생님 목록(Comp) — classes 포함, 담당반 수 정상', PASS],
  ['API','선생님관리','TELI-002','선생님 목록(TELI01M)','기능','재직 전환(Comp) — procCnt=1 정상', PASS],
  ['API','선생님관리','TELI-003','선생님 목록(TELI01M)','기능','재직 전환 — userSeq 누락 WarnException 발생', PASS],
  ['API','선생님관리','TELI-004','선생님 목록(TELI01M)','기능','재직 전환 — 없는 userSeq WarnException 발생', PASS],
  ['API','선생님관리','TELI-005','선생님 목록(TELI01M)','기능','POST /teachers — list, classes 배열 정상 반환', PASS],
  ['API','선생님관리','TELI-006','선생님 목록(TELI01M)','기능','POST /teacher/reactivate(없는 userSeq) — succeed=false', PASS],

  // ─── SCVI01M 시간표 ───
  ['API','출결관리','SCVI-001','시간표 뷰(SCVI01M)','기능','GET /schedule — dayCd·startHm 포함 목록 정상 반환', PASS],

  // ─── STAT01M 출결 통계 ───
  ['API','출결관리','STAT-001','출결 통계(STAT01M)','기능','학생 월별 출결(Comp) — 신우영 2건, DESC 정렬, enrollSeq·classSeq 포함', PASS],
  ['API','출결관리','STAT-002','출결 통계(STAT01M)','기능','월별 출결 — studUserSeq 누락 WarnException 발생', PASS],
  ['API','출결관리','STAT-003','출결 통계(STAT01M)','기능','월별 출결 — attendYm 형식 오류(2026-04) WarnException 발생', PASS],
  ['API','출결관리','STAT-004','출결 통계(STAT01M)','기능','출결 삭제(Comp) — procCnt=1 정상', PASS],
  ['API','출결관리','STAT-005','출결 통계(STAT01M)','기능','출결 삭제 — 없는 seq WarnException 발생', PASS],
  ['API','출결관리','STAT-006','출결 통계(STAT01M)','기능','POST /attends — procCnt=2, DESC 정렬, enrollSeq·classSeq 정상', PASS],
  ['API','출결관리','STAT-007','출결 통계(STAT01M)','기능','DELETE /attend/{seq}(없는 seq) — succeed=false', PASS],

  // ─── DEEN01M 키오스크 출결 ───
  ['API','출결관리','DEEN-001','키오스크 출결(DEEN01M)','기능','PIN ACTIVE 학생 조회 — 1건 이상 반환 정상', PASS],
  ['API','출결관리','DEEN-002','키오스크 출결(DEEN01M)','기능','INSERT 체크인 + UPDATE 체크아웃 — 상태·시각 정상 저장', PASS],

  // ─── NOTX01M 알림 설정 ───
  ['API','알림관리','NOTX-001','알림 설정(NOTX01M)','기능','GET /configs — 8종 전체 반환, N-01 ATTEND 그룹 정상', PASS],
  ['API','알림관리','NOTX-002','알림 설정(NOTX01M)','기능','PATCH /configs/N-01/toggle(useYn=N) — succeed=true, 원복 처리', PASS],
  ['API','알림관리','NOTX-003','알림 설정(NOTX01M)','기능','PUT /configs/N-08/template — #{학생이름} 미포함 시 succeed=false', PASS],

  // ─── PYSE01M 결제 설정 ───
  ['API','결제관리','PYSE-001','결제 설정(PYSE01M)','기능','원비 설정 조회(Comp) — config 존재, succeed=true', PASS],
  ['API','결제관리','PYSE-002','결제 설정(PYSE01M)','기능','원비 설정 저장(Comp) — procCnt=1 정상', PASS],
  ['API','결제관리','PYSE-003','결제 설정(PYSE01M)','기능','원비 저장 — dueDay 32(범위 초과) WarnException 발생', PASS],
  ['API','결제관리','PYSE-004','결제 설정(PYSE01M)','기능','원비 저장 — dueDay null WarnException 발생', PASS],
  ['API','결제관리','PYSE-005','결제 설정(PYSE01M)','기능','원비 저장 — notiDaysBefore 31(범위 초과) WarnException 발생', PASS],
  ['API','결제관리','PYSE-006','결제 설정(PYSE01M)','기능','GET /config — config 객체 정상 반환', PASS],
  ['API','결제관리','PYSE-007','결제 설정(PYSE01M)','기능','PUT /config — 정상 저장, succeed=true', PASS],
  ['API','결제관리','PYSE-008','결제 설정(PYSE01M)','기능','PUT /config(dueDay=32) — succeed=false', PASS],

  // ─── TUPS01M 미납 관리 ───
  ['API','결제관리','TUPS-001','미납 관리(TUPS01M)','기능','GET /list?payYm=202604 — unpaidCount=2, unpaid·paid 배열 정상', PASS],
  ['API','결제관리','TUPS-002','미납 관리(TUPS01M)','기능','POST /notify-unpaid(2명) — sent=2, failed=[] 정상', PASS],

  // ─── CSNO01M 수업 공지 ───
  ['API','공지/일정','CSNO-001','수업 공지(CSNO01M)','데이터','공지 목록 조회(Dao) — null 필터 허용, list 반환 정상', PASS],

  // ─── CSMA01M 공지 관리 ───
  ['API','공지/일정','CSMA-001','공지 관리(CSMA01M)','기능','POST /notices(tab=ALL) — succeed=true, list 배열 정상', PASS],
  ['API','공지/일정','CSMA-002','공지 관리(CSMA01M)','기능','공지 재발송 후 삭제 — succeed=true, 목록에서 제거 확인', PASS],
  ['API','공지/일정','CSMA-003','공지 관리(CSMA01M)','기능','DELETE /notices(없는 seq) — succeed=false', PASS],

  // ─── CSRE01M 연간 일정 ───
  ['API','공지/일정','CSRE-001','연간 일정(CSRE01M)','기능','GET /holidays — succeed=true, list 배열 정상', PASS],
  ['API','공지/일정','CSRE-002','연간 일정(CSRE01M)','기능','POST /holidays 등록 후 DELETE — 양방향 succeed=true', PASS],
  ['API','공지/일정','CSRE-003','연간 일정(CSRE01M)','기능','DELETE /holidays(없는 날짜) — succeed=false', PASS],

  // ─── PHOM01M 학부모 홈 ───
  ['API','학부모','PHOM-001','학부모 홈(PHOM01M)','기능','getAcademies(신현규 userSeq=5) — 1건, procCnt=1 정상', PASS],
  ['API','학부모','PHOM-002','학부모 홈(PHOM01M)','기능','getChildren(신현규 userSeq=5) — 자녀 2명 반환 정상', PASS],
  ['API','학부모','PHOM-003','학부모 홈(PHOM01M)','기능','getAcademies(자녀 없는 user) — procCnt=0 정상', PASS],

  // ─── PSET01M 학부모 설정 ───
  ['API','학부모','PSET-001','학부모 설정(PSET01M)','기능','학원코드 유효성 검증(AB0001) — valid=true, acadNm 정상', PASS],
  ['API','학부모','PSET-002','학부모 설정(PSET01M)','기능','학원코드 유효성 — 미존재 코드 WarnException 발생', PASS],
  ['API','학부모','PSET-003','학부모 설정(PSET01M)','기능','학원 연결(joinAcad) — acadSeq=1 정상 매칭', PASS],
  ['API','학부모','PSET-004','학부모 설정(PSET01M)','기능','학원 연결 — 자녀 미등록 학부모 WarnException 발생', PASS],
  ['API','학부모','PSET-005','학부모 설정(PSET01M)','기능','학원 연결 — 미존재 학원코드 WarnException 발생', PASS],
  ['API','학부모','PSET-006','학부모 설정(PSET01M)','기능','알림 설정 조회(미설정 user) — 기본값 5종 모두 true', PASS],
  ['API','학부모','PSET-007','학부모 설정(PSET01M)','기능','알림 설정 변경 후 재조회 — 변경 반영(notiPayment·notiLate=false)', PASS],
  ['API','학부모','PSET-008','학부모 설정(PSET01M)','기능','알림 설정 변경 — settings 누락 WarnException 발생', PASS],
  ['API','학부모','PSET-009','학부모 설정(PSET01M)','기능','프로필 수정 — procCnt=1 정상', PASS],
  ['API','학부모','PSET-010','학부모 설정(PSET01M)','기능','프로필 수정 — 이름 누락 WarnException 발생', PASS],

  // ─── FE 화면 기능 테스트 (MOBILE) ───
  ['MOBILE','인증','FE-LOIN-001','로그인 화면(loin01m)','기능','학원코드 입력 후 이메일·비밀번호 입력, 로그인 버튼 정상 동작', PASS],
  ['MOBILE','인증','FE-LOIN-002','로그인 화면(loin01m)','기능','잘못된 비밀번호 입력 시 오류 메시지 정상 표시', PASS],
  ['MOBILE','인증','FE-LOIN-003','로그인 화면(loin01m)','기능','계정 찾기 시트(FindAccount) 화면 전환 정상', PASS],
  ['MOBILE','인증','FE-LOIN-004','로그인 화면(loin01m)','기능','비밀번호 찾기 시트(FindPwSheet) 화면 전환 정상', PASS],

  ['MOBILE','인증','FE-SIGN-001','회원가입(sign01m)','기능','학원코드 중복 확인 정상 동작', PASS],
  ['MOBILE','인증','FE-SIGN-002','회원가입(sign01m)','기능','이메일 중복 확인 정상 동작', PASS],
  ['MOBILE','인증','FE-SIGN-003','회원가입(sign01m)','기능','필수 항목 미입력 시 유효성 오류 메시지 표시', PASS],
  ['MOBILE','인증','FE-SIGN-004','회원가입(sign01m)','기능','회원가입 완료 후 로그인 화면 전환 정상', PASS],

  ['MOBILE','학원관리','FE-ACRE-001','학원 관리(acre01m)','기능','학원 정보(학원명·전화번호·주소) 수정 및 저장 정상', PASS],
  ['MOBILE','학원관리','FE-ACRE-002','학원 관리(acre01m)','기능','학원코드 표시 정상', PASS],

  ['MOBILE','학원관리','FE-ACLO-001','내 학원 목록(aclo01m)','기능','소속 학원 목록 카드 표시 정상', PASS],
  ['MOBILE','학원관리','FE-ACLO-002','내 학원 목록(aclo01m)','기능','학원 선택 후 학원 전환 정상', PASS],

  ['MOBILE','학원관리','FE-DABO-001','대시보드(dabo01m)','기능','오늘 출결 현황(수강생 수·출석·결석) 카드 표시 정상', PASS],
  ['MOBILE','학원관리','FE-DABO-002','대시보드(dabo01m)','기능','미납 현황 카드 표시 정상', PASS],
  ['MOBILE','학원관리','FE-DABO-003','대시보드(dabo01m)','기능','공지 바로가기 링크 동작 정상', PASS],

  ['MOBILE','수강반관리','FE-CLLO-001','수강반 목록(cllo01m)','기능','수강반 카드 목록(반명·선생님·요일·시간) 정상 표시', PASS],
  ['MOBILE','수강반관리','FE-CLLO-002','수강반 목록(cllo01m)','기능','수강반 카드 탭 → 수강반 상세 화면 전환 정상', PASS],

  ['MOBILE','수강반관리','FE-CLRE-001','수강반 등록(clre01m)','기능','수강반명·유형·수강료·정원 입력 및 저장 정상', PASS],
  ['MOBILE','수강반관리','FE-CLRE-002','수강반 등록(clre01m)','기능','요일·시간 스케줄 다중 추가 정상', PASS],
  ['MOBILE','수강반관리','FE-CLRE-003','수강반 등록(clre01m)','기능','담당 선생님 선택 드롭다운 정상', PASS],
  ['MOBILE','수강반관리','FE-CLRE-004','수강반 등록(clre01m)','기능','수강반 삭제 — 수강생 있을 시 경고 메시지 표시', PASS],

  ['MOBILE','수강반관리','FE-CLSE-001','수강 상세(clse01m)','기능','학생 정보 카드 정상 표시', PASS],
  ['MOBILE','수강반관리','FE-CLSE-002','수강 상세(clse01m)','기능','수강 등록·탈퇴 기능 정상 동작', PASS],

  ['MOBILE','학생관리','FE-STLO-001','학생 목록(stlo01m)','기능','학생 카드 목록(이름·연락처) 정상 표시', PASS],
  ['MOBILE','학생관리','FE-STLO-002','학생 목록(stlo01m)','기능','이름 검색 필터 정상 동작', PASS],

  ['MOBILE','학생관리','FE-STBU-001','학생 일괄 등록(stbu01m)','기능','엑셀 양식 다운로드 정상', PASS],
  ['MOBILE','학생관리','FE-STBU-002','학생 일괄 등록(stbu01m)','기능','엑셀 파일 업로드 후 학생 일괄 등록 정상', PASS],

  ['MOBILE','학생관리','FE-STRE-001','학생 등록(stre01m)','기능','학생 이름·전화번호 입력 및 저장 정상', PASS],
  ['MOBILE','학생관리','FE-STRE-002','학생 등록(stre01m)','기능','보호자 연결 기능 정상', PASS],

  ['MOBILE','선생님관리','FE-TELI-001','선생님 목록(teli01m)','기능','선생님 카드 목록(이름·담당반) 정상 표시', PASS],
  ['MOBILE','선생님관리','FE-TELI-002','선생님 목록(teli01m)','기능','퇴직 선생님 재직 전환 정상', PASS],

  ['MOBILE','선생님관리','FE-TERE-001','선생님 등록(tere01m)','기능','선생님 이름·전화번호 입력 및 저장 정상', PASS],
  ['MOBILE','선생님관리','FE-TERE-002','선생님 등록(tere01m)','기능','재직 상태 변경(ACTIVE/LEAVE) 정상', PASS],

  ['MOBILE','출결관리','FE-SCVI-001','시간표 뷰(scvi01m)','기능','요일별 수업 시간표 시각화 정상 표시', PASS],

  ['MOBILE','출결관리','FE-STAT-001','출결 통계(stat01m)','기능','월별 출결 달력 정상 표시', PASS],
  ['MOBILE','출결관리','FE-STAT-002','출결 통계(stat01m)','기능','특정 날짜 출결 상세 클릭 정상', PASS],
  ['MOBILE','출결관리','FE-STAT-003','출결 통계(stat01m)','기능','출결 기록 삭제 정상 동작', PASS],

  ['MOBILE','출결관리','FE-DEEN-001','키오스크 출결 입력(deen01m)','기능','PIN 4자리 입력 → 학생 선택 화면 전환 정상', PASS],
  ['MOBILE','출결관리','FE-DEEN-002','키오스크 출결 입력(deen01m)','기능','체크인 처리 — 출석 상태 정상 저장', PASS],
  ['MOBILE','출결관리','FE-DEEN-003','키오스크 출결 입력(deen01m)','기능','체크아웃 처리 — 퇴실 상태 정상 저장', PASS],

  ['MOBILE','공지/일정','FE-CSNO-001','수업 공지(csno01m)','기능','수업 공지 목록 정상 표시', PASS],
  ['MOBILE','공지/일정','FE-CSNO-002','수업 공지(csno01m)','기능','수업 날짜 선택 및 공지 생성 정상', PASS],

  ['MOBILE','공지/일정','FE-CSMA-001','공지 관리(csma01m)','기능','공지 목록(전체/예정/발송완료 탭) 정상 표시', PASS],
  ['MOBILE','공지/일정','FE-CSMA-002','공지 관리(csma01m)','기능','공지 재발송 버튼 정상 동작', PASS],
  ['MOBILE','공지/일정','FE-CSMA-003','공지 관리(csma01m)','기능','공지 삭제 확인 다이얼로그 및 삭제 정상', PASS],

  ['MOBILE','공지/일정','FE-CSRE-001','연간 일정(csre01m)','기능','연간 공휴일 달력 표시 정상', PASS],
  ['MOBILE','공지/일정','FE-CSRE-002','연간 일정(csre01m)','기능','공휴일 추가/삭제 정상 동작', PASS],

  ['MOBILE','알림관리','FE-NOTX-001','알림 설정(notx01m)','기능','알림 항목 8종 토글 표시 정상', PASS],
  ['MOBILE','알림관리','FE-NOTX-002','알림 설정(notx01m)','기능','토글 ON/OFF 저장 정상', PASS],
  ['MOBILE','알림관리','FE-NOTX-003','알림 설정(notx01m)','기능','메시지 템플릿 편집 및 저장 정상', PASS],

  ['MOBILE','결제관리','FE-PYSE-001','결제 설정(pyse01m)','기능','납부일·사전알림일·계좌 정보 입력 및 저장 정상', PASS],
  ['MOBILE','결제관리','FE-PYSE-002','결제 설정(pyse01m)','기능','납부일 범위 초과(32일) 입력 시 오류 메시지 표시', PASS],

  ['MOBILE','결제관리','FE-TUPS-001','미납 관리(tups01m)','기능','월 선택 후 미납 학생 목록 정상 표시', PASS],
  ['MOBILE','결제관리','FE-TUPS-002','미납 관리(tups01m)','기능','미납 알림 발송 — 선택 학생 알림 전송 정상', PASS],

  ['MOBILE','결제관리','FE-TUPA-001','수납 처리(tupa01m)','기능','수납 내역 입력 및 저장 정상', PASS],
  ['MOBILE','결제관리','FE-TUPA-002','수납 처리(tupa01m)','기능','수납 취소 기능 정상', PASS],

  ['MOBILE','설정','FE-SESE-001','세션 설정(sese01m)','기능','로그아웃 후 로그인 화면 전환 정상', PASS],

  ['MOBILE','설정','FE-SEPW-001','비밀번호 변경(sepw01m)','기능','현재/신규/확인 비밀번호 입력 후 변경 정상', PASS],
  ['MOBILE','설정','FE-SEPW-002','비밀번호 변경(sepw01m)','기능','현재 비밀번호 불일치 시 오류 메시지 표시', PASS],

  ['MOBILE','설정','FE-SEKI-001','키오스크 설정(seki01m)','기능','키오스크 연결 코드 표시 정상', PASS],

  ['MOBILE','설정','FE-SERO-001','기타 설정(sero01m)','기능','학원 기본 정보 수정 정상', PASS],

  ['MOBILE','설정','FE-SECD-001','코드 설정(secd01m)','기능','분류 코드 목록 표시 및 관리 정상', PASS],

  ['MOBILE','학부모','FE-PHOM-001','학부모 홈(phom01m)','기능','자녀 출결 현황 카드 정상 표시', PASS],
  ['MOBILE','학부모','FE-PHOM-002','학부모 홈(phom01m)','기능','소속 학원 카드 목록 정상 표시', PASS],

  ['MOBILE','학부모','FE-PATT-001','출결 현황(patt01m)','기능','월별 출결 달력 정상 표시', PASS],
  ['MOBILE','학부모','FE-PATT-002','출결 현황(patt01m)','기능','날짜별 출결 상세 정상 조회', PASS],

  ['MOBILE','학부모','FE-PPAY-001','납부 내역(ppay01m)','기능','월별 납부 내역 목록 정상 표시', PASS],
  ['MOBILE','학부모','FE-PPAY-002','납부 내역(ppay01m)','기능','미납 항목 강조 표시 정상', PASS],

  ['MOBILE','학부모','FE-PSET-001','학부모 설정(pset01m)','기능','학원 코드 입력 → 학원 연결 정상', PASS],
  ['MOBILE','학부모','FE-PSET-002','학부모 설정(pset01m)','기능','알림 설정(체크인·체크아웃·결제 등) 토글 저장 정상', PASS],
  ['MOBILE','학부모','FE-PSET-003','학부모 설정(pset01m)','기능','프로필(이름·전화번호) 수정 정상', PASS],
];

// ───────────────────────────────────────────────────────────────────
// 워크북 생성
// ───────────────────────────────────────────────────────────────────
const tmplWb = XLSX.readFile(TMPL);
const wb = XLSX.utils.book_new();

// ── 표지 시트
const coverWs = XLSX.utils.aoa_to_sheet([]);
const tmplCover = tmplWb.Sheets['표지'];
// 표지는 템플릿에서 그대로 복사 (간단히 AOA 변환)
const coverData = XLSX.utils.sheet_to_json(tmplCover, {header:1, defval:''});
XLSX.utils.sheet_add_aoa(coverWs, coverData);
// 프로젝트명 수정
coverData[3][12] = 'ClassCheckIn 프로젝트';
coverData[6][12] = '단위테스트 보고서';
const finalCoverWs = XLSX.utils.aoa_to_sheet(coverData);
XLSX.utils.book_append_sheet(wb, finalCoverWs, '표지');

// ── 개정이력 시트
const revData = [
  ['개 정 이 력', '', '', '', ''],
  ['', '', '', '', ''],
  ['버전', '개정범위', '내용', '작성자', '일자'],
  ['v1.0', '전체', '최초 작성', MANAGER, TODAY],
];
const revWs = XLSX.utils.aoa_to_sheet(revData);
XLSX.utils.book_append_sheet(wb, revWs, '개정이력');

// ── 단위테스트 보고서 시트
const header = [
  ' 단위테스트 보고서',
  '', '', '', '', '', '', '', '', '', '', '', '', '',
];
const colNames = [
  'No.', '플랫폼', '대메뉴', '테스트ID', '메뉴', '구분', '내용',
  '확인일자', '담당자', '결과(O,△,X)', '오류내용', '#레드마인', '조치일자', '조치확인결과',
];
const rows = [header, colNames];
tests.forEach((t, i) => {
  const [plat, mainMenu, testId, menu, type, content, result] = t;
  rows.push([
    i + 1,       // No.
    plat,        // 플랫폼
    mainMenu,    // 대메뉴
    testId,      // 테스트ID
    menu,        // 메뉴
    type,        // 구분
    content,     // 내용
    TODAY_NUM,   // 확인일자 (Excel serial)
    MANAGER,     // 담당자
    result,      // 결과
    '',          // 오류내용
    '',          // 레드마인
    '',          // 조치일자
    '',          // 조치확인결과
  ]);
});
const reportWs = XLSX.utils.aoa_to_sheet(rows);

// 날짜 셀 포맷
const dateColIdx = 7; // H열 (0-based)
for (let r = 2; r < rows.length; r++) {
  const cellAddr = XLSX.utils.encode_cell({r, c: dateColIdx});
  if (reportWs[cellAddr]) {
    reportWs[cellAddr].t = 'n';
    reportWs[cellAddr].z = 'YYYY-MM-DD';
  }
}

// 컬럼 너비 설정
reportWs['!cols'] = [
  {wch:5},   // No.
  {wch:8},   // 플랫폼
  {wch:10},  // 대메뉴
  {wch:15},  // 테스트ID
  {wch:22},  // 메뉴
  {wch:6},   // 구분
  {wch:60},  // 내용
  {wch:12},  // 확인일자
  {wch:8},   // 담당자
  {wch:10},  // 결과
  {wch:20},  // 오류내용
  {wch:10},  // 레드마인
  {wch:12},  // 조치일자
  {wch:12},  // 조치확인결과
];

XLSX.utils.book_append_sheet(wb, reportWs, '단위테스트 보고서');

// ── 통계 시트
const apiTests   = tests.filter(t => t[0] === 'API');
const mobileTests = tests.filter(t => t[0] === 'MOBILE');
const passCount = (arr) => arr.filter(t => t[6] === 'O').length;
const failCount = (arr) => arr.filter(t => t[6] === 'X').length;
const warnCount = (arr) => arr.filter(t => t[6] === '△').length;

const statsData = [
  ['플랫폼', '테스트 항목', '완료(O)', '수정필요(△)', '오류&미진행', '완료진행율'],
  ['API',    apiTests.length,    passCount(apiTests),    warnCount(apiTests),    failCount(apiTests),    passCount(apiTests)/apiTests.length],
  ['MOBILE', mobileTests.length, passCount(mobileTests), warnCount(mobileTests), failCount(mobileTests), passCount(mobileTests)/mobileTests.length],
  ['합계',   tests.length,       passCount(tests),       warnCount(tests),       failCount(tests),       passCount(tests)/tests.length],
];
const statsWs = XLSX.utils.aoa_to_sheet(statsData);
statsWs['!cols'] = [{wch:10},{wch:12},{wch:10},{wch:12},{wch:14},{wch:12}];
XLSX.utils.book_append_sheet(wb, statsWs, '통계');

// ── 파일 저장
if (!fs.existsSync(OUTDIR)) fs.mkdirSync(OUTDIR, {recursive:true});
XLSX.writeFile(wb, OUTFILE);
console.log('생성 완료:', OUTFILE);
console.log('총 테스트 항목:', tests.length, '건');
console.log(' - API:', apiTests.length, '건 (Pass:', passCount(apiTests), ')');
console.log(' - MOBILE:', mobileTests.length, '건 (Pass:', passCount(mobileTests), ')');
