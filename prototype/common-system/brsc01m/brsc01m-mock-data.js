/* BRSC01 재고조회 테스트 데이터 */
const BRSC01_DATA = {
  products: [
    { code:'P001', sku:'4573102713148_1', name:'-나루토 72 series- 03 우즈마키 나루토&하타케 카카시 (A:우즈마키 나루토)', spec:'4573102713148 1 의 비고', stockBox:11034, stockEa:0, total:11034 },
    { code:'P002', sku:'4573102713155_1', name:'-나루토 72 series- 04 우치하 이타치 (B:우치하 이타치)', spec:'4573102713155 1 의 비고', stockBox:8500, stockEa:0, total:8500 },
    { code:'P003', sku:'4573102713162_1', name:'-나루토 72 series- 05 우치하 마다라', spec:'4573102713162 1 의 비고', stockBox:6200, stockEa:0, total:6200 },
    { code:'P004', sku:'4573102713179_1', name:'-귀멸의 칼날- 탄지로 (001)', spec:'4573102713179 1 의 비고', stockBox:15000, stockEa:0, total:15000 },
    { code:'P005', sku:'4573102713186_1', name:'-귀멸의 칼날- 네즈코 (002)', spec:'4573102713186 1 의 비고', stockBox:12000, stockEa:0, total:12000 },
  ],
  locations: [
    { prodCode:'P001', loc:'[입고창고] 00-00-00', expDate:null,         stockBox:30, stockEa:0, total:30 },
    { prodCode:'P001', loc:'[상품창고] AC-00-00', expDate:'2096-12-31', stockBox:10, stockEa:0, total:10 },
    { prodCode:'P001', loc:'[상품창고] AE-00-00', expDate:'2097-12-31', stockBox:10, stockEa:0, total:10 },
    { prodCode:'P001', loc:'[상품창고] AF-00-00', expDate:'2098-12-31', stockBox:5,  stockEa:0, total:5  },
    { prodCode:'P002', loc:'[입고창고] 00-00-00', expDate:null,         stockBox:20, stockEa:0, total:20 },
    { prodCode:'P002', loc:'[상품창고] BA-00-00', expDate:'2096-12-31', stockBox:15, stockEa:0, total:15 },
    { prodCode:'P003', loc:'[상품창고] CA-00-00', expDate:'2096-12-31', stockBox:12, stockEa:0, total:12 },
    { prodCode:'P004', loc:'[입고창고] 00-00-00', expDate:null,         stockBox:50, stockEa:0, total:50 },
    { prodCode:'P005', loc:'[상품창고] DA-00-00', expDate:'2096-12-31', stockBox:30, stockEa:0, total:30 },
  ],
  locView: [
    { loc:'[입고창고] 00-00-00', sku:'4573102713148_1', prodName:'-나루토 72 series- 03 우즈마키 나루토', stockBox:30, stockEa:0, total:30 },
    { loc:'[상품창고] AC-00-00', sku:'4573102713148_1', prodName:'-나루토 72 series- 03 우즈마키 나루토', stockBox:10, stockEa:0, total:10 },
    { loc:'[상품창고] AE-00-00', sku:'4573102713155_1', prodName:'-나루토 72 series- 04 우치하 이타치',   stockBox:10, stockEa:0, total:10 },
    { loc:'[상품창고] AF-00-00', sku:'4573102713162_1', prodName:'-나루토 72 series- 05 우치하 마다라',   stockBox:5,  stockEa:0, total:5  },
    { loc:'[작업장A] W-01-00',   sku:'4573102713179_1', prodName:'-귀멸의 칼날- 탄지로 (001)',              stockBox:8,  stockEa:0, total:8  },
  ],
};
