/* OWPC01 — 출고처리 테스트 데이터 */
const OWPC01_DATA = {
  header: {
    no:   'OW20241101001',
    cust: '(주)CJ대한통운',
    dest: '서울 강남구 테헤란로 123',
    date: '2024-11-02',
    type: '일반배송',
  },
  items: [
    { seq:1, code:'1000531', name:'르라보 상탈 50ml',        unit:'EA',  prevQty:0,  procQty:30, reqQty:30 },
    { seq:2, code:'1000532', name:'세이브워터 100ml',         unit:'EA',  prevQty:10, procQty:10, reqQty:20 },
    { seq:3, code:'1000533', name:'에스떼 수분크림 50g',      unit:'EA',  prevQty:0,  procQty:15, reqQty:15 },
    { seq:4, code:'1000534', name:'닥터자르트 더마클리어',    unit:'BOX', prevQty:5,  procQty:5,  reqQty:10 },
    { seq:5, code:'1000535', name:'이니스프리 그린티 세럼',   unit:'EA',  prevQty:0,  procQty:8,  reqQty:8  },
    { seq:6, code:'1000536', name:'헤라 블랙 쿠션 21호',      unit:'EA',  prevQty:2,  procQty:4,  reqQty:6  },
  ]
};
