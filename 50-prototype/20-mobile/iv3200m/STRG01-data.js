/* STRG01 — 재고이동 테스트 데이터 */
const STRG01_DATA = {
  products: [
    { code:'1000531', name:'르라보 상탈 50ml',       unit:'EA',  stock:150, fromLoc:'A-01-01-01', toLoc:'' },
    { code:'1000532', name:'세이브워터 100ml',        unit:'EA',  stock:80,  fromLoc:'A-01-02-01', toLoc:'' },
    { code:'1000533', name:'에스떼 수분크림 50g',     unit:'EA',  stock:200, fromLoc:'A-02-01-01', toLoc:'' },
    { code:'1000534', name:'닥터자르트 더마클리어',   unit:'BOX', stock:45,  fromLoc:'B-01-01-01', toLoc:'' },
    { code:'1000535', name:'이니스프리 그린티 세럼',  unit:'EA',  stock:120, fromLoc:'B-01-02-01', toLoc:'' },
    { code:'1000536', name:'헤라 블랙 쿠션 21호',     unit:'EA',  stock:60,  fromLoc:'B-02-01-01', toLoc:'' },
  ],
  locations: [
    { code:'A-01-01-01', wh:'제1창고', rack:'A-01', lv:'01', col:'01', stock:150 },
    { code:'A-01-02-01', wh:'제1창고', rack:'A-01', lv:'02', col:'01', stock:80  },
    { code:'A-02-01-01', wh:'제1창고', rack:'A-02', lv:'01', col:'01', stock:200 },
    { code:'B-01-01-01', wh:'제2창고', rack:'B-01', lv:'01', col:'01', stock:45  },
    { code:'B-01-02-01', wh:'제2창고', rack:'B-01', lv:'02', col:'01', stock:120 },
    { code:'B-02-01-01', wh:'제2창고', rack:'B-02', lv:'01', col:'01', stock:60  },
    { code:'C-01-01-01', wh:'제3창고', rack:'C-01', lv:'01', col:'01', stock:0   },
    { code:'C-01-02-01', wh:'제3창고', rack:'C-01', lv:'02', col:'01', stock:0   },
  ]
};
