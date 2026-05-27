'use strict';
const path = require('path');
const ExcelJS = require('exceljs');

const TARGETS = [
  ['template', path.resolve(__dirname, '../../template/04 구현(PI)/PI_214-통합테스트보고서.xlsx')],
  ['exceljs',  path.resolve(__dirname, 'out_exceljs.xlsx')],
  ['xlsx-pop', path.resolve(__dirname, 'out_xlsxpopulate.xlsx')],
  ['xlsx-CE',  path.resolve(__dirname, 'out_xlsx.xlsx')],
];

function summary(cell) {
  if (!cell || !cell.style) return 'NO-STYLE';
  const s = cell.style;
  const b = s.border || {};
  const f = s.fill;
  const a = s.alignment;
  const fnt = s.font;
  const hasBorder = ['top','bottom','left','right'].some(k => b[k] && b[k].style);
  const hasFill = f && f.type === 'pattern' && f.pattern && f.pattern !== 'none';
  return [
    hasBorder ? 'B' : '-',
    hasFill   ? 'F' : '-',
    a && a.horizontal ? `h:${a.horizontal[0]}` : '-',
    a && a.vertical   ? `v:${a.vertical[0]}` : '-',
    fnt && fnt.bold ? 'BOLD' : '-',
    fnt && fnt.size ? `sz${fnt.size}` : '-',
  ].join('|');
}

(async () => {
  for (const [label, file] of TARGETS) {
    try {
      const wb = new ExcelJS.Workbook();
      await wb.xlsx.readFile(file);
      const ws = wb.getWorksheet('통합테스트 수행보고서');
      if (!ws) { console.log(label, 'SHEET MISSING'); continue; }
      console.log(`\n=== ${label} (sheets: ${wb.worksheets.length}, dataRows: ${Math.max(0, ws.rowCount - 2)}) ===`);
      console.log('rowCount:', ws.rowCount, 'colCount:', ws.columnCount, 'merges:', Object.keys(ws._merges || {}).length);
      // Sample: header row 2 + first data row 3 + middle row 10
      for (const r of [2, 3, 5, 10]) {
        const row = ws.getRow(r);
        const cells = [];
        for (let c = 1; c <= 6; c++) {
          cells.push(`${String.fromCharCode(64 + c)}${r}=[${summary(row.getCell(c))}]`);
        }
        console.log(`  row${r}: ${cells.join(' ')}`);
      }
      // verify other sheets untouched
      console.log('  other sheet names:', wb.worksheets.map(w => w.name).join(', '));
    } catch (e) {
      console.log(label, 'ERROR:', e.message);
    }
  }
})();
