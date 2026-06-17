/* IVAD01 — 입고처리(적하) 테스트 데이터 */
const IVAD01_DATA = {
  header: {
    no:   'IV20241101001',
    cust: '(주)한국제약',
    date: '2024-11-01',
    type: '국내입고',
    site: '메가랩',
  },
  items: [
    { seq:1, code:'1000531', name:'르라보 상탈 50ml',        unit:'EA', prevQty:20, procQty:10, reqQty:30 },
    { seq:2, code:'1000532', name:'세이브워터 100ml',         unit:'EA', prevQty:0,  procQty:0,  reqQty:20 },
    { seq:3, code:'1000533', name:'에스떼 수분크림 50g',      unit:'EA', prevQty:10, procQty:5,  reqQty:15 },
    { seq:4, code:'1000534', name:'닥터자르트 더마클리어',    unit:'BOX', prevQty:0,  procQty:0,  reqQty:10 },
    { seq:5, code:'1000535', name:'이니스프리 그린티 세럼',   unit:'EA', prevQty:5,  procQty:5,  reqQty:10 },
  ]
};
