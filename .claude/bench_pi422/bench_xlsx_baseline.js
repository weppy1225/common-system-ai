'use strict';
// Baseline: current PI_422 approach using SheetJS Community xlsx
const path = require('path');
const XLSX = require(path.resolve(__dirname, '../../output/04 구현(PI)/node_modules/xlsx'));

const TEMPLATE = path.resolve(__dirname, '../../template/04 구현(PI)/PI_214-통합테스트보고서.xlsx');
const OUT      = path.resolve(__dirname, 'out_xlsx.xlsx');
const ROWS     = 27;

const t0 = Date.now();
const wb = XLSX.readFile(TEMPLATE, { cellStyles: true });
const ws = wb.Sheets['통합테스트 수행보고서'];
const range = XLSX.utils.decode_range(ws['!ref']);
for (let r = 2; r <= range.e.r; r++) {
  for (let c = range.s.c; c <= range.e.c; c++) {
    delete ws[XLSX.utils.encode_cell({ r, c })];
  }
}
for (let i = 0; i < ROWS; i++) {
  const r = i + 2;
  const seq = String(i + 1).padStart(3, '0');
  const vals = ['기준정보', `MDCT01-${seq}`, '거래처관리', '거래처관리 조회', 'WMS(WEB)',
                '검색 조건은 정상 구현 되는지?', '', '홍길동', '', '', '', ''];
  for (let c = 0; c < vals.length; c++) {
    ws[XLSX.utils.encode_cell({ r, c })] = { v: vals[c], t: 's' };
  }
}
ws['!ref'] = XLSX.utils.encode_range({ s: { r: 0, c: 0 }, e: { r: ROWS + 1, c: 11 } });
XLSX.writeFile(wb, OUT);
const t1 = Date.now();
console.log(JSON.stringify({ lib: 'xlsx (SheetJS CE)', ms: t1 - t0, out: OUT }));
