/**
 * gen_pi422.js — 통합테스트보고서 자동 생성 [PI_422]
 *
 * Usage:
 *   node gen_pi422.js "{고객사명}" "{담당자}" "{시작일}" "{종료일}" "{SYSTEM}"
 *
 * 예:
 *   node gen_pi422.js "ABC물류" "홍길동" "2026-05-12" "2026-05-23" "WMS(WEB)"
 */

'use strict';

const path = require('path');
const fs   = require('fs');

// ── 경로 기준: 이 스크립트가 있는 위치에서 프로젝트 루트를 계산 ──────────────
const BASE_DIR     = path.resolve(__dirname, '..', '..', '..', '..');
const DIST_DIR     = path.join(BASE_DIR, 'dist');
const TEMPLATE     = path.join(BASE_DIR, 'template', '04 구현(PI)', 'PI.214-통합테스트보고서.xlsx');
const OUTPUT_DIR   = path.join(BASE_DIR, 'output', '04 구현(PI)');
const XLSX_LIB     = path.join(OUTPUT_DIR, 'node_modules', 'xlsx');

// ── 인자 파싱 ────────────────────────────────────────────────────────────────
const [,, clientName = '고객사', tester = '담당자',
         startDate = '', endDate = '', system = 'WMS(WEB)'] = process.argv;

if (!clientName) { console.error('[ERROR] 고객사명을 첫 번째 인자로 전달하세요.'); process.exit(1); }

// ── xlsx 로드 ────────────────────────────────────────────────────────────────
const XLSX = require(XLSX_LIB);

// ── 유틸 ─────────────────────────────────────────────────────────────────────

/** ui.md 파일에서 필요한 메타 정보를 파싱 */
function parseUiMd(content) {
  const meta = {
    menuGroupName: '',
    menuGroupCode: '',
    menuName: '',
    menuCode: '',
    uiType: '',
    purpose: '',
    bizRules: [],
    hasAdd: false,
    hasEdit: false,
    hasDelete: false,
    hasSave: false,
  };

  // 화면구성 테이블 파싱 (Markdown 테이블)
  const lines = content.split('\n');
  let inTable = false;
  for (const line of lines) {
    const clean = line.replace(/\|/g, '|').trim();
    if (!clean.startsWith('|')) { if (inTable) inTable = false; continue; }
    inTable = true;
    const cells = clean.split('|').map(s => s.trim()).filter(Boolean);
    if (cells.length < 2) continue;
    for (let i = 0; i < cells.length - 1; i += 2) {
      const key = cells[i];
      const val = cells[i + 1] || '';
      if (key === '메뉴그룹명') meta.menuGroupName = val;
      if (key === '메뉴그룹코드') meta.menuGroupCode = val;
      if (key === '메뉴명') meta.menuName = val;
      if (key === '메뉴코드') meta.menuCode = val;
      if (key === 'UI유형') meta.uiType = val;
      if (key === '목적') meta.purpose = val;
    }
  }

  // 버튼 기능 감지 (기능 버튼 섹션 또는 툴바 섹션)
  const lower = content.toLowerCase();
  if (/추가|등록/.test(content)) meta.hasAdd   = true;
  if (/수정/.test(content))       meta.hasEdit  = true;
  if (/삭제/.test(content))       meta.hasDelete = true;
  if (/저장/.test(content))       meta.hasSave  = true;

  // 업무규칙 추출 (## 공통 업무규칙 섹션)
  const bizMatch = content.match(/##\s*(?:공통\s*)?업무규칙([\s\S]*?)(?=\n##|\n---|\s*$)/i);
  if (bizMatch) {
    const bizSection = bizMatch[1];
    const ruleLines = bizSection.split('\n')
      .map(l => l.replace(/^[\s\-\d.]+/, '').trim())
      .filter(l => l.length > 5 && !/^[\|#]/.test(l));
    meta.bizRules = ruleLines.slice(0, 10); // 최대 10개
  }

  return meta;
}

/** dist/ 하위 모든 ui.md 파일을 수집 */
function collectUiMds() {
  if (!fs.existsSync(DIST_DIR)) {
    console.error('[ERROR] dist/ 폴더가 없습니다:', DIST_DIR);
    process.exit(1);
  }
  const results = [];
  const dirs = fs.readdirSync(DIST_DIR).sort();
  for (const dir of dirs) {
    const mdPath = path.join(DIST_DIR, dir, 'ui.md');
    if (fs.existsSync(mdPath)) {
      const content = fs.readFileSync(mdPath, 'utf8');
      const meta = parseUiMd(content);
      if (meta.menuCode) {
        results.push({ dir, meta, mdPath });
      }
    }
  }
  return results;
}

/** 메뉴 하나에 대한 테스트 케이스 목록 생성 */
function genCases(meta, startNo) {
  const cases = [];
  const mn = meta.menuName;
  const mc = meta.menuCode;
  let no = startNo;

  const add = (처리내용, 확인내용) => {
    const seq = String(no).padStart(3, '0');
    cases.push({
      업무영역: meta.menuGroupName,
      테스트ID: `${mc}-${seq}`,
      항목: mn,
      처리내용,
      확인내용,
    });
    no++;
  };

  // ── 공통 조회 시나리오
  add(`${mn} 조회`, '검색 조건(날짜, 코드, 명칭 등)은 정상 구현 되는지?');
  add(`${mn} 조회`, '검색 결과 목록은 정상 표시 되는지?');
  add(`${mn} 조회`, '페이징(페이지 이동, 건수 표시)은 정상 구현 되는지?');
  add(`${mn} 조회`, '검색 초기화는 정상 동작하는지?');

  // ── 등록 시나리오
  if (meta.hasAdd) {
    add(`${mn} 등록`, '신규 데이터 등록은 정상 구현 되는지?');
    add(`${mn} 등록`, '필수 항목 미입력 시 유효성 검사는 정상 구현 되는지?');
    add(`${mn} 등록`, '등록 후 목록에 반영되는지?');
  }

  // ── 수정 시나리오
  if (meta.hasEdit) {
    add(`${mn} 수정`, '기존 데이터 수정은 정상 구현 되는지?');
    add(`${mn} 수정`, '수정 후 목록에 정상 반영되는지?');
  }

  // ── 삭제 시나리오
  if (meta.hasDelete) {
    add(`${mn} 삭제`, '데이터 삭제는 정상 구현 되는지?');
    add(`${mn} 삭제`, '삭제 후 목록 갱신은 정상 구현 되는지?');
    add(`${mn} 삭제`, '참조 중인 데이터 삭제 시 오류 처리는 정상 구현 되는지?');
  }

  // ── 저장 시나리오 (삭제 없이 저장만 있는 경우)
  if (meta.hasSave && !meta.hasAdd) {
    add(`${mn} 저장`, '다중 행 일괄 저장은 정상 구현 되는지?');
    add(`${mn} 저장`, '저장 후 데이터 반영은 정상 구현 되는지?');
  }

  // ── 업무규칙별 시나리오
  for (const rule of meta.bizRules) {
    if (rule.length < 8) continue;
    // 이미 질문 형식이면 그대로, 아니면 "~는 정상 구현 되는지?" 추가
    const q = rule.endsWith('?') || rule.endsWith('인지?') || rule.endsWith('는지?')
      ? rule
      : rule + ' 처리는 정상 구현 되는지?';
    add(`${mn} 업무규칙`, q);
  }

  return cases;
}

// ── 메인 ─────────────────────────────────────────────────────────────────────

function main() {
  console.log('[PI_422] 통합테스트보고서 생성 시작');
  console.log('  고객사:', clientName);
  console.log('  담당자:', tester);
  console.log('  기간:  ', startDate, '~', endDate);
  console.log('  SYSTEM:', system);
  console.log('');

  // 템플릿 확인
  if (!fs.existsSync(TEMPLATE)) {
    console.error('[ERROR] 템플릿 파일 없음:', TEMPLATE);
    process.exit(1);
  }

  // dist/ 스캔
  const menus = collectUiMds();
  if (menus.length === 0) {
    console.error('[ERROR] dist/ 폴더에서 ui.md 파일을 찾지 못했습니다.');
    process.exit(1);
  }
  console.log(`[1/3] 메뉴 스캔 완료: ${menus.length}개`);

  // 테스트 케이스 생성
  const allCases = [];
  for (const { meta } of menus) {
    const startNo = allCases.length + 1;
    const cases = genCases(meta, startNo);
    allCases.push(...cases);
    console.log(`  [${meta.menuCode}] ${meta.menuName}: ${cases.length}건`);
  }
  console.log(`[2/3] 테스트 케이스 생성 완료: 총 ${allCases.length}건`);

  // 템플릿 읽기
  const wb = XLSX.readFile(TEMPLATE, { cellStyles: true });
  const TARGET_SHEET = '통합테스트 수행보고서';
  const ws = wb.Sheets[TARGET_SHEET];
  if (!ws) {
    console.error('[ERROR] 시트를 찾을 수 없습니다:', TARGET_SHEET);
    console.error('  존재하는 시트:', wb.SheetNames.join(', '));
    process.exit(1);
  }

  // 헤더 행(2행)까지 보존하고 3행 이후 데이터 행 삭제
  // 기존 ref 파싱
  const origRange = XLSX.utils.decode_range(ws['!ref'] || 'A1:L218');
  // 3행(row index=2) 이후 기존 셀 삭제
  for (let r = 2; r <= origRange.e.r; r++) {
    for (let c = origRange.s.c; c <= origRange.e.c; c++) {
      const addr = XLSX.utils.encode_cell({ r, c });
      delete ws[addr];
    }
  }

  // 컬럼 정의 (A~L = 0~11)
  // A: 업무영역, B: 테스트ID, C: 항목, D: 처리내용, E: SYSTEM,
  // F: 확인내용, G: 확인일자, H: 확인자, I: 확인결과, J: 오류내용, K: 오류조치일자, L: 조치결과확인

  const COLS = 12; // A~L
  let rowIdx = 2;  // 0-indexed: row 3 = index 2

  for (const tc of allCases) {
    const row = [
      tc.업무영역,   // A
      tc.테스트ID,   // B
      tc.항목,       // C
      tc.처리내용,   // D
      system,        // E
      tc.확인내용,   // F
      '',            // G 확인일자
      tester,        // H 확인자
      '',            // I 확인결과
      '',            // J 오류내용
      '',            // K 오류조치일자
      '',            // L 조치결과확인
    ];
    for (let c = 0; c < row.length; c++) {
      const addr = XLSX.utils.encode_cell({ r: rowIdx, c });
      ws[addr] = { v: row[c], t: 's' };
    }
    rowIdx++;
  }

  // ref 범위 갱신
  ws['!ref'] = XLSX.utils.encode_range({
    s: { r: 0, c: 0 },
    e: { r: rowIdx - 1, c: COLS - 1 },
  });

  // 출력 파일 저장
  if (!fs.existsSync(OUTPUT_DIR)) fs.mkdirSync(OUTPUT_DIR, { recursive: true });
  const safeClient = clientName.replace(/[<>:"|?*\\/]/g, '_');
  const outFile = path.join(OUTPUT_DIR, `PI.422_통합테스트보고서_${safeClient}.xlsx`);
  XLSX.writeFile(wb, outFile);

  console.log(`[3/3] 파일 저장 완료`);
  console.log('');
  console.log('✓ 통합테스트보고서 생성 완료 [PI_422]');
  console.log('');
  console.log('  출력 파일:', outFile);
  console.log('  담당자:  ', tester);
  console.log('  기간:    ', startDate, '~', endDate);
  console.log('');
  console.log(`  수집 메뉴: ${menus.length}개`);
  console.log(`  총 케이스: ${allCases.length}건`);
  console.log('');
  console.log('  메뉴별 케이스:');
  for (const { meta } of menus) {
    const cnt = allCases.filter(c => c.항목 === meta.menuName).length;
    console.log(`    [${meta.menuGroupName}] ${meta.menuName} [${meta.menuCode}]: ${cnt}건`);
  }
}

main();
