/* RTPC01 — 반품처리 테스트 데이터 */
const RTPC01_DATA = {
  header: {
    no:   'RT20241101001',
    cust: '(주)강남마트',
    dest: '서울 강남구 테헤란로 456',
    date: '2024-11-03',
    reason: '단순변심',
  },
  items: [
    { seq:1, code:'1000531', name:'르라보 상탈 50ml',       unit:'EA',  prevQty:0, procQty:5,  reqQty:5,  state:'정상' },
    { seq:2, code:'1000532', name:'세이브워터 100ml',        unit:'EA',  prevQty:0, procQty:3,  reqQty:5,  state:'손상' },
    { seq:3, code:'1000533', name:'에스떼 수분크림 50g',     unit:'EA',  prevQty:0, procQty:10, reqQty:10, state:'정상' },
    { seq:4, code:'1000535', name:'이니스프리 그린티 세럼',  unit:'EA',  prevQty:0, procQty:2,  reqQty:4,  state:'정상' },
    { seq:5, code:'1000536', name:'헤라 블랙 쿠션 21호',     unit:'EA',  prevQty:0, procQty:0,  reqQty:2,  state:'손상' },
  ]
};
