/* FLSC01 고정위치조회 테스트 데이터 */
const FLSC01_DATA = {
  products: [
    { code:'P001', sku:'4573102713148_1', name:'-나루토 72 series- 03 우즈마키 나루토&하타케 카카시' },
    { code:'P002', sku:'4573102713155_1', name:'-나루토 72 series- 04 우치하 이타치' },
    { code:'P003', sku:'4573102713162_1', name:'-나루토 72 series- 05 우치하 마다라' },
    { code:'P004', sku:'4573102713179_1', name:'-귀멸의 칼날- 탄지로 (001)' },
    { code:'P005', sku:'4573102713186_1', name:'-귀멸의 칼날- 네즈코 (002)' },
  ],
  fixedLocs: [
    { prodCode:'P001', loc:'[상품창고] AC-01-01', wh:'상품창고', rack:'AC', lv:'01', col:'01', fixQty:30, curQty:28 },
    { prodCode:'P001', loc:'[상품창고] AC-01-02', wh:'상품창고', rack:'AC', lv:'01', col:'02', fixQty:30, curQty:15 },
    { prodCode:'P002', loc:'[상품창고] BA-01-01', wh:'상품창고', rack:'BA', lv:'01', col:'01', fixQty:20, curQty:20 },
    { prodCode:'P003', loc:'[상품창고] CA-02-01', wh:'상품창고', rack:'CA', lv:'02', col:'01', fixQty:15, curQty:12 },
    { prodCode:'P004', loc:'[상품창고] DA-01-01', wh:'상품창고', rack:'DA', lv:'01', col:'01', fixQty:50, curQty:45 },
    { prodCode:'P005', loc:'[상품창고] EA-01-01', wh:'상품창고', rack:'EA', lv:'01', col:'01', fixQty:40, curQty:30 },
  ],
  locView: [
    { loc:'[상품창고] AC-01-01', sku:'4573102713148_1', prodName:'-나루토 72 series- 03 우즈마키 나루토', fixQty:30, curQty:28 },
    { loc:'[상품창고] AC-01-02', sku:'4573102713148_1', prodName:'-나루토 72 series- 03 우즈마키 나루토', fixQty:30, curQty:15 },
    { loc:'[상품창고] BA-01-01', sku:'4573102713155_1', prodName:'-나루토 72 series- 04 우치하 이타치',   fixQty:20, curQty:20 },
    { loc:'[상품창고] CA-02-01', sku:'4573102713162_1', prodName:'-나루토 72 series- 05 우치하 마다라',   fixQty:15, curQty:12 },
    { loc:'[상품창고] DA-01-01', sku:'4573102713179_1', prodName:'-귀멸의 칼날- 탄지로 (001)',              fixQty:50, curQty:45 },
  ],
};
