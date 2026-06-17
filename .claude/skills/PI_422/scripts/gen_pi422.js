/**
 * gen_pi422.js — 통합테스트보고서 자동 생성 [PI_422]
 *
 * Usage:
 *   node gen_pi422.js "{고객사명}" "{담당자}" "{시작일}" "{종료일}" "{SYSTEM}"
 *
 * 예:
 *   node gen_pi422.js "ABC물류" "홍길동" "2026-05-12" "2026-05-23" "WMS(WEB)"
 *
 * 핵심:
 *   - xlsx-populate 사용 (셀 스타일을 유지한 채 값만 채워 넣음).
 *   - 기존 'xlsx' (SheetJS Community)는 셀 스타일 쓰기를 지원하지 않아 양식이 깨지므로 사용하지 않음.
 *   - 템플릿 'PI_214-통합테스트보고서.xlsx' 의 '통합테스트 수행보고서' 시트
 *     3행~218행이 이미 서식이 적용된 상태이므로, 값만 덮어쓰고 남은 행은 값만 비움.
 */

'use strict';

const path = require('path');
const fs   = require('fs');

// ── 경로 ─────────────────────────────────────────────────────────────────────
const BASE_DIR        = path.resolve(__dirname, '..', '..', '..', '..');
const DIST_DIR        = path.join(BASE_DIR, 'spec');
const DIST_MOBILE_DIR = path.join(BASE_DIR, 'prototype', 'mobile');
const TEMPLATE        = path.join(BASE_DIR, 'deliverables', '10-templates', '04 구현(PI)', 'PI_214-통합테스트보고서.xlsx');
const OUTPUT_DIR      = path.join(BASE_DIR, 'deliverables', '30-output', '04 구현(PI)');
const LIB_DIR         = path.join(OUTPUT_DIR, 'node_modules', 'xlsx-populate');

// ── 인자 파싱 ────────────────────────────────────────────────────────────────
const [,, clientName = '고객사', tester = '담당자',
         startDate = '', endDate = '', system = 'WMS(WEB)'] = process.argv;

if (!clientName) { console.error('[ERROR] 고객사명을 첫 번째 인자로 전달하세요.'); process.exit(1); }

// ── xlsx-populate 로드 ───────────────────────────────────────────────────────
const XlsxPopulate = require(LIB_DIR);

// ── 유틸: ui.md 파싱 ─────────────────────────────────────────────────────────
function parseUiMd(content) {
  const meta = {
    menuGroupName: '', menuGroupCode: '',
    menuName: '',      menuCode: '',
    uiType: '',        purpose: '',
    bizRules: [],
    hasAdd: false, hasEdit: false, hasDelete: false, hasSave: false,
  };

  const lines = content.split('\n');
  let inTable = false;
  for (const line of lines) {
    const clean = line.trim();
    if (!clean.startsWith('|')) { if (inTable) inTable = false; continue; }
    inTable = true;
    const cells = clean.split('|').map(s => s.trim()).filter(Boolean);
    if (cells.length < 2) continue;
    for (let i = 0; i < cells.length - 1; i += 2) {
      const key = cells[i];
      const val = cells[i + 1] || '';
      if (key === '메뉴그룹명')  meta.menuGroupName = val;
      if (key === '메뉴그룹코드') meta.menuGroupCode = val;
      if (key === '메뉴명')      meta.menuName = val;
      if (key === '메뉴코드')    meta.menuCode = val;
      if (key === 'UI유형')      meta.uiType = val;
      if (key === '목적')        meta.purpose = val;
    }
  }

  if (/추가|등록/.test(content)) meta.hasAdd    = true;
  if (/수정/.test(content))       meta.hasEdit   = true;
  if (/삭제/.test(content))       meta.hasDelete = true;
  if (/저장/.test(content))       meta.hasSave   = true;

  // ## 공통 업무규칙 / ## 업무규칙 섹션 추출
  const bizMatch = content.match(/##\s*(?:공통\s*)?업무규칙([\s\S]*?)(?=\n##|\n---|\s*$)/i);
  if (bizMatch) {
    const ruleLines = bizMatch[1].split('\n')
      .map(l => l.replace(/^[\s\-\d.]+/, '').trim())
      .filter(l => l.length > 5 && !/^[\|#]/.test(l));
    meta.bizRules = ruleLines.slice(0, 10);
  }

  return meta;
}

// ── spec/ 스캔 (WEB) ─────────────────────────────────────────
function collectUiMds() {
  if (!fs.existsSync(DIST_DIR)) {
    console.error('[ERROR] spec/ 폴더가 없습니다:', DIST_DIR);
    process.exit(1);
  }
  const results = [];
  const dirs = fs.readdirSync(DIST_DIR).sort();
  for (const dir of dirs) {
    const mdPath = path.join(DIST_DIR, dir, `${dir}-02-ui.md`);
    if (!fs.existsSync(mdPath)) continue;
    const meta = parseUiMd(fs.readFileSync(mdPath, 'utf8'));
    if (meta.menuCode) results.push({ dir, meta, mdPath, systemVal: system });
  }
  return results;
}

// ── prototype/_common-m/menu.html 파싱 (PDA) ─────────────────────────────────────────
function collectPdaMenus() {
  const menuHtml = path.join(DIST_MOBILE_DIR, 'menu.html');
  if (!fs.existsSync(menuHtml)) {
    console.warn('[WARN] prototype/_common-m/menu.html 없음 — PDA 메뉴 건너뜀');
    return [];
  }
  const html = fs.readFileSync(menuHtml, 'utf8');

  // onclick="location.href='./iv3000m/IVMV01.html'" ... alt="입고예정"
  const cellRe = /menu-cell[^>]*onclick="location\.href='\.\/([^/]+)\/([^.]+)\.html'"[\s\S]*?alt="([^"]+)"/g;
  const pdaMenus = [];
  let m;
  while ((m = cellRe.exec(html)) !== null) {
    const groupFolder = m[1];   // iv3000m
    const menuCode    = m[2];   // IVMV01
    const menuName    = m[3];   // 입고예정

    // spec/{menuCode.toLowerCase()}/{menuCode.toLowerCase()}-02-ui.md 매칭 시도
    const lowerCode = menuCode.toLowerCase();
    const mdPath = path.join(DIST_DIR, lowerCode, `${lowerCode}-02-ui.md`);
    let meta;
    if (fs.existsSync(mdPath)) {
      meta = parseUiMd(fs.readFileSync(mdPath, 'utf8'));
      meta.menuCode = meta.menuCode || menuCode;
      meta.menuName = meta.menuName || menuName;
    } else {
      meta = {
        menuGroupName: groupFolder, menuGroupCode: '',
        menuName, menuCode,
        uiType: '', purpose: '',
        bizRules: [],
        hasAdd: false, hasEdit: false, hasDelete: false, hasSave: false,
      };
    }
    pdaMenus.push({ dir: groupFolder, meta, mdPath: mdPath || null, systemVal: 'WMS(PDA)' });
  }
  return pdaMenus;
}

// ── 케이스 생성 ──────────────────────────────────────────────────────────────
function genCases(meta, startNo, systemVal) {
  const cases = [];
  const mn = meta.menuName;
  const mc = meta.menuCode;
  let no = startNo;

  const add = (proc, check) => {
    const seq = String(no).padStart(3, '0');
    cases.push({
      업무영역: meta.menuGroupName,
      테스트ID: `${mc}-${seq}`,
      항목: mn,
      처리내용: proc,
      확인내용: check,
      systemVal: systemVal || system,
    });
    no++;
  };

  add(`${mn} 조회`, '검색 조건(날짜, 코드, 명칭 등)은 정상 구현 되는지?');
  add(`${mn} 조회`, '검색 결과 목록은 정상 표시 되는지?');
  add(`${mn} 조회`, '페이징(페이지 이동, 건수 표시)은 정상 구현 되는지?');
  add(`${mn} 조회`, '검색 초기화는 정상 동작하는지?');

  if (meta.hasAdd) {
    add(`${mn} 등록`, '신규 데이터 등록은 정상 구현 되는지?');
    add(`${mn} 등록`, '필수 항목 미입력 시 유효성 검사는 정상 구현 되는지?');
    add(`${mn} 등록`, '등록 후 목록에 반영되는지?');
  }
  if (meta.hasEdit) {
    add(`${mn} 수정`, '기존 데이터 수정은 정상 구현 되는지?');
    add(`${mn} 수정`, '수정 후 목록에 정상 반영되는지?');
  }
  if (meta.hasDelete) {
    add(`${mn} 삭제`, '데이터 삭제는 정상 구현 되는지?');
    add(`${mn} 삭제`, '삭제 후 목록 갱신은 정상 구현 되는지?');
    add(`${mn} 삭제`, '참조 중인 데이터 삭제 시 오류 처리는 정상 구현 되는지?');
  }
  if (meta.hasSave && !meta.hasAdd) {
    add(`${mn} 저장`, '다중 행 일괄 저장은 정상 구현 되는지?');
    add(`${mn} 저장`, '저장 후 데이터 반영은 정상 구현 되는지?');
  }
  for (const rule of meta.bizRules) {
    if (rule.length < 8) continue;
    const q = rule.endsWith('?') ? rule : rule + ' 처리는 정상 구현 되는지?';
    add(`${mn} 업무규칙`, q);
  }
  return cases;
}

// ── 시트 쓰기 ────────────────────────────────────────────────────────────────
const SHEET_NAME = '통합테스트 수행보고서';
const DATA_START_ROW = 3;       // 1행: 제목, 2행: 헤더, 3행부터 데이터
const TEMPLATE_LAST_STYLED_ROW = 218; // 템플릿에서 서식이 부여된 마지막 행

/**
 * 데이터 행 쓰기. 기존 셀 스타일은 그대로 두고 값만 갱신.
 * 남는 서식 행(N+1 ~ 218)은 값만 비운다.
 */
function writeCases(sheet, cases) {
  // 1) N건 데이터 쓰기
  for (let i = 0; i < cases.length; i++) {
    const r = DATA_START_ROW + i;
    const tc = cases[i];
    const row = [
      tc.업무영역,              // A
      tc.테스트ID,              // B
      tc.항목,                  // C
      tc.처리내용,              // D
      tc.systemVal || system,   // E
      tc.확인내용,   // F
      '',            // G 확인일자
      tester,        // H 확인자
      '',            // I 확인결과
      '',            // J 오류내용
      '',            // K 오류조치일자
      '',            // L 조치결과확인
    ];
    for (let c = 0; c < row.length; c++) {
      sheet.cell(r, c + 1).value(row[c]);
    }
  }

  // 2) N+1 ~ 218 행: 템플릿에 남아있던 샘플 데이터 값 비우기 (스타일 유지)
  const firstClear = DATA_START_ROW + cases.length;
  for (let r = firstClear; r <= TEMPLATE_LAST_STYLED_ROW; r++) {
    for (let c = 1; c <= 12; c++) {
      sheet.cell(r, c).value(undefined);
    }
  }
}

// ── 메인 ─────────────────────────────────────────────────────────────────────
(async function main() {
  console.log('[PI_422] 통합테스트보고서 생성 시작');
  console.log('  고객사:', clientName);
  console.log('  담당자:', tester);
  console.log('  기간:  ', startDate, '~', endDate);
  console.log('  SYSTEM:', system);
  console.log('');

  if (!fs.existsSync(TEMPLATE)) {
    console.error('[ERROR] 템플릿 파일 없음:', TEMPLATE);
    process.exit(1);
  }

  const webMenus = collectUiMds();
  const pdaMenus = collectPdaMenus();
  const menus = [...webMenus, ...pdaMenus];
  if (menus.length === 0) {
    console.error('[ERROR] 메뉴를 찾지 못했습니다. spec/*/*-02-ui.md 또는 prototype/_common-m/menu.html 확인.');
    process.exit(1);
  }
  console.log(`[1/3] 메뉴 스캔 완료: WEB ${webMenus.length}개 / PDA ${pdaMenus.length}개`);

  const allCases = [];
  for (const { meta, systemVal } of menus) {
    const startNo = (allCases.filter(c => c.테스트ID.startsWith(meta.menuCode + '-')).length) + 1;
    const cases = genCases(meta, startNo, systemVal);
    allCases.push(...cases);
    console.log(`  [${systemVal}] [${meta.menuCode}] ${meta.menuName}: ${cases.length}건`);
  }
  console.log(`[2/3] 테스트 케이스 생성 완료: 총 ${allCases.length}건`);

  if (allCases.length > (TEMPLATE_LAST_STYLED_ROW - DATA_START_ROW + 1)) {
    console.warn(`[WARN] 케이스 ${allCases.length}건이 템플릿 서식 행 수(${TEMPLATE_LAST_STYLED_ROW - DATA_START_ROW + 1})를 초과합니다. 초과 행은 무서식으로 출력될 수 있습니다.`);
  }

  const wb = await XlsxPopulate.fromFileAsync(TEMPLATE);
  const sheet = wb.sheet(SHEET_NAME);
  if (!sheet) {
    console.error('[ERROR] 시트를 찾을 수 없습니다:', SHEET_NAME);
    console.error('  존재하는 시트:', wb.sheets().map(s => s.name()).join(', '));
    process.exit(1);
  }

  writeCases(sheet, allCases);

  if (!fs.existsSync(OUTPUT_DIR)) fs.mkdirSync(OUTPUT_DIR, { recursive: true });
  const safeClient = clientName.replace(/[<>:"|?*\\/]/g, '_');
  const outFile = path.join(OUTPUT_DIR, `PI.422_통합테스트보고서_${safeClient}.xlsx`);
  await wb.toFileAsync(outFile);

  console.log(`[3/3] 파일 저장 완료`);
  console.log('');
  console.log('✓ 통합테스트보고서 생성 완료 [PI_422]');
  console.log('');
  console.log('  출력 파일:', outFile);
  console.log('  담당자:  ', tester);
  console.log('  기간:    ', startDate, '~', endDate);
  console.log('');
  console.log(`  수집 메뉴: WEB ${webMenus.length}개 / PDA ${pdaMenus.length}개 (합계 ${menus.length}개)`);
  console.log(`  총 케이스: ${allCases.length}건`);
  console.log('');
  console.log('  메뉴별 케이스:');
  for (const { meta, systemVal } of menus) {
    const cnt = allCases.filter(c => c.테스트ID.startsWith(meta.menuCode + '-')).length;
    console.log(`    [${systemVal}] [${meta.menuGroupName}] ${meta.menuName} [${meta.menuCode}]: ${cnt}건`);
  }
})().catch(e => { console.error('[FATAL]', e); process.exit(1); });
