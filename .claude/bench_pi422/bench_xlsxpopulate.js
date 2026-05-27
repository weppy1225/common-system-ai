'use strict';
const path = require('path');
const XlsxPopulate = require('xlsx-populate');

const TEMPLATE = path.resolve(__dirname, '../../template/04 구현(PI)/PI_214-통합테스트보고서.xlsx');
const OUT      = path.resolve(__dirname, 'out_xlsxpopulate.xlsx');
const ROWS     = 27;

(async () => {
  const t0 = Date.now();
  const wb = await XlsxPopulate.fromFileAsync(TEMPLATE);
  const ws = wb.sheet('통합테스트 수행보고서');

  // Clear rows 3..end existing values (keep styles)
  const usedRange = ws.usedRange();
  if (usedRange) {
    const endRow = usedRange.endCell().rowNumber();
    for (let r = 3; r <= endRow; r++) {
      for (let c = 1; c <= 12; c++) {
        ws.cell(r, c).value(undefined);
      }
    }
  }

  for (let i = 0; i < ROWS; i++) {
    const r = i + 3;
    const seq = String(i + 1).padStart(3, '0');
    const vals = [
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
    for (let c = 0; c < vals.length; c++) {
      ws.cell(r, c + 1).value(vals[c]);
    }
  }

  await wb.toFileAsync(OUT);
  const t1 = Date.now();
  console.log(JSON.stringify({ lib: 'xlsx-populate', ms: t1 - t0, out: OUT }));
})().catch(e => { console.error(e); process.exit(1); });
