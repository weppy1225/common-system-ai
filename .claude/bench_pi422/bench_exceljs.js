'use strict';
const path = require('path');
const ExcelJS = require('exceljs');

const TEMPLATE = path.resolve(__dirname, '../../template/04 구현(PI)/PI_214-통합테스트보고서.xlsx');
const OUT      = path.resolve(__dirname, 'out_exceljs.xlsx');
const ROWS     = 27;

(async () => {
  const t0 = Date.now();
  const wb = new ExcelJS.Workbook();
  await wb.xlsx.readFile(TEMPLATE);
  const ws = wb.getWorksheet('통합테스트 수행보고서');

  // remove existing data rows (3..end) without touching header styles
  const lastRow = ws.rowCount;
  for (let r = lastRow; r >= 3; r--) {
    ws.spliceRows(r, 1);
  }

  // Write 27 sample rows
  for (let i = 0; i < ROWS; i++) {
    const r = i + 3;
    const seq = String(i + 1).padStart(3, '0');
    const row = ws.getRow(r);
    row.values = [
      '기준정보',
      `MDCT01-${seq}`,
      '거래처관리',
      '거래처관리 조회',
      'WMS(WEB)',
      '검색 조건은 정상 구현 되는지?',
      '',
      '홍길동',
      '',
      '',
      '',
      ''
    ];
    row.commit();
  }

  await wb.xlsx.writeFile(OUT);
  const t1 = Date.now();
  console.log(JSON.stringify({ lib: 'exceljs', ms: t1 - t0, out: OUT }));
})().catch(e => { console.error(e); process.exit(1); });
