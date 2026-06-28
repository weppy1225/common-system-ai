/* mdpr01 테스트 데이터 */
const MDPR01_DATA = {
  main: [
    { promoId:'PROMO-2024-001', promoNm:'봄맞이 사은품 이벤트',    promoType:'금액', giftType:'한번',  targetDiv:'금액', targetQty:30000, startYmd:'2024-03-01', endYmd:'2024-05-31', useYn:'Y', remark:'' },
    { promoId:'PROMO-2024-002', promoNm:'여름 시즌 증정 행사',      promoType:'금액', giftType:'여러번', targetDiv:'금액', targetQty:50000, startYmd:'2024-06-01', endYmd:'2024-08-31', useYn:'Y', remark:'복수구매 혜택' },
    { promoId:'PROMO-2024-003', promoNm:'추석 명절 사은품',         promoType:'품목', giftType:'한번',  targetDiv:'품목', targetQty:1,     startYmd:'2024-09-01', endYmd:'2024-09-30', useYn:'Y', remark:'특정 품목 구매 시' },
    { promoId:'PROMO-2024-004', promoNm:'연말 VIP 증정',            promoType:'금액', giftType:'한번',  targetDiv:'금액', targetQty:100000,startYmd:'2024-12-01', endYmd:'2024-12-31', useYn:'Y', remark:'' },
    { promoId:'PROMO-2024-005', promoNm:'신규거래처 환영 행사',     promoType:'품목', giftType:'한번',  targetDiv:'대분류', targetQty:3,   startYmd:'2024-01-01', endYmd:'2024-12-31', useYn:'Y', remark:'대분류 기준 3개 이상' },
    { promoId:'PROMO-2024-006', promoNm:'하반기 판촉 사은품',       promoType:'금액', giftType:'여러번', targetDiv:'금액', targetQty:20000, startYmd:'2024-07-01', endYmd:'2024-12-31', useYn:'N', remark:'일시 중단' },
    { promoId:'PROMO-2024-007', promoNm:'브랜드데이 특별 증정',     promoType:'품목', giftType:'한번',  targetDiv:'품목', targetQty:2,     startYmd:'2024-04-15', endYmd:'2024-04-15', useYn:'Y', remark:'당일 한정' },
    { promoId:'PROMO-2024-008', promoNm:'멤버십 등급 업 사은품',    promoType:'금액', giftType:'한번',  targetDiv:'금액', targetQty:200000,startYmd:'2024-01-01', endYmd:'2024-12-31', useYn:'Y', remark:'골드 이상' },
    { promoId:'PROMO-2024-009', promoNm:'생일 특별 사은품',         promoType:'품목', giftType:'한번',  targetDiv:'품목', targetQty:1,     startYmd:'2024-01-01', endYmd:'2024-12-31', useYn:'Y', remark:'생일 월 한정' },
    { promoId:'PROMO-2024-010', promoNm:'스프링 얼리버드 이벤트',   promoType:'금액', giftType:'여러번', targetDiv:'금액', targetQty:15000, startYmd:'2024-02-01', endYmd:'2024-03-31', useYn:'N', remark:'종료됨' },
    { promoId:'PROMO-2024-011', promoNm:'어버이날 선물 세트',       promoType:'품목', giftType:'한번',  targetDiv:'대분류', targetQty:2,   startYmd:'2024-05-01', endYmd:'2024-05-08', useYn:'Y', remark:'' },
    { promoId:'PROMO-2024-012', promoNm:'크리스마스 시즌 행사',     promoType:'금액', giftType:'한번',  targetDiv:'금액', targetQty:50000, startYmd:'2024-12-20', endYmd:'2024-12-25', useYn:'Y', remark:'시즌 한정' },
  ],
  d1: [
    { d1Id:1, promoId:'PROMO-2024-001', largeDiv:'',    targetProdNo:'',         targetProdNm:'' },
    { d1Id:2, promoId:'PROMO-2024-003', largeDiv:'',    targetProdNo:'PROD-0021', targetProdNm:'제주 감귤 주스 1L' },
    { d1Id:3, promoId:'PROMO-2024-005', largeDiv:'음료', targetProdNo:'',         targetProdNm:'' },
    { d1Id:4, promoId:'PROMO-2024-007', largeDiv:'',    targetProdNo:'PROD-0045', targetProdNm:'유기농 쌀 5kg' },
    { d1Id:5, promoId:'PROMO-2024-009', largeDiv:'',    targetProdNo:'PROD-0112', targetProdNm:'프리미엄 올리브오일 500ml' },
    { d1Id:6, promoId:'PROMO-2024-011', largeDiv:'건강식품', targetProdNo:'',    targetProdNm:'' },
  ],
  d2: [
    { d2Id:1, promoId:'PROMO-2024-001', applyAmt:30000,  giftProdNo:'PROD-G001', giftProdNm:'친환경 장바구니',        giftQty:1 },
    { d2Id:2, promoId:'PROMO-2024-001', applyAmt:60000,  giftProdNo:'PROD-G002', giftProdNm:'텀블러 350ml',           giftQty:1 },
    { d2Id:3, promoId:'PROMO-2024-001', applyAmt:90000,  giftProdNo:'PROD-G003', giftProdNm:'에코백 세트',            giftQty:1 },
    { d2Id:4, promoId:'PROMO-2024-003', applyAmt:0,      giftProdNo:'PROD-G010', giftProdNm:'감사 스티커팩',          giftQty:1 },
    { d2Id:5, promoId:'PROMO-2024-005', applyAmt:0,      giftProdNo:'PROD-G011', giftProdNm:'비타민C 30정',           giftQty:1 },
    { d2Id:6, promoId:'PROMO-2024-005', applyAmt:0,      giftProdNo:'PROD-G012', giftProdNm:'마스크팩 5매',           giftQty:2 },
  ]
};
