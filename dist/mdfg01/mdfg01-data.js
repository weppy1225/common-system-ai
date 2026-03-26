/* MDFG01 테스트 데이터 */
const MDFG01_DATA = {
  promo: [
    { id: 'PROMO-001', name: '봄맞이 사은품 이벤트', type: '수량', giftCnt: '한번', targetType: '품목', targetQty: 5, startDate: '2026-03-01', endDate: '2026-03-31', applyYn: '적용' },
    { id: 'PROMO-002', name: '신규고객 감사 프로모션', type: '금액', giftCnt: '한번', targetType: '대분류', targetQty: 3, startDate: '2026-03-15', endDate: '2026-04-15', applyYn: '적용' },
    { id: 'PROMO-003', name: '여름 시즌 사은품', type: '수량', giftCnt: '여러번', targetType: '품목', targetQty: 10, startDate: '2026-06-01', endDate: '2026-08-31', applyYn: '미적용' },
    { id: 'PROMO-004', name: 'VIP 고객 전용 증정', type: '금액', giftCnt: '한번', targetType: '품목', targetQty: 1, startDate: '2026-04-01', endDate: '2026-04-30', applyYn: '적용' },
    { id: 'PROMO-005', name: '추석맞이 사은품', type: '수량', giftCnt: '한번', targetType: '대분류', targetQty: 7, startDate: '2026-09-01', endDate: '2026-09-30', applyYn: '미적용' },
    { id: 'PROMO-006', name: '연말 감사 이벤트', type: '금액', giftCnt: '한번', targetType: '품목', targetQty: 2, startDate: '2026-12-01', endDate: '2026-12-31', applyYn: '적용' },
    { id: 'PROMO-007', name: '신상품 출시 기념', type: '수량', giftCnt: '여러번', targetType: '품목', targetQty: 15, startDate: '2026-05-01', endDate: '2026-05-31', applyYn: '적용' },
    { id: 'PROMO-008', name: '대량구매 보너스', type: '수량', giftCnt: '한번', targetType: '품목', targetQty: 20, startDate: '2026-07-01', endDate: '2026-07-31', applyYn: '미적용' },
    { id: 'PROMO-009', name: '창립기념 프로모션', type: '금액', giftCnt: '한번', targetType: '대분류', targetQty: 8, startDate: '2026-10-15', endDate: '2026-11-15', applyYn: '적용' },
    { id: 'PROMO-010', name: '겨울 시즌 이벤트', type: '수량', giftCnt: '한번', targetType: '품목', targetQty: 4, startDate: '2026-11-01', endDate: '2027-01-31', applyYn: '적용' },
    { id: 'PROMO-011', name: '온라인 전용 사은품', type: '수량', giftCnt: '여러번', targetType: '품목', targetQty: 6, startDate: '2026-04-15', endDate: '2026-05-15', applyYn: '미적용' },
    { id: 'PROMO-012', name: '첫 구매 감사 증정', type: '금액', giftCnt: '한번', targetType: '품목', targetQty: 1, startDate: '2026-03-01', endDate: '2026-12-31', applyYn: '적용' }
  ],
  d1: [
    { promoId: 'PROMO-001', seq: 1, prodNo: 'PD-10001', prodNm: '스킨케어 세트 A' },
    { promoId: 'PROMO-001', seq: 2, prodNo: 'PD-10002', prodNm: '클렌징 폼 B' },
    { promoId: 'PROMO-001', seq: 3, prodNo: 'PD-10003', prodNm: '선크림 SPF50' },
    { promoId: 'PROMO-002', seq: 1, prodNo: 'PD-20001', prodNm: '비타민C 세럼' },
    { promoId: 'PROMO-002', seq: 2, prodNo: 'PD-20002', prodNm: '수분크림 50ml' },
    { promoId: 'PROMO-003', seq: 1, prodNo: 'PD-30001', prodNm: '여름용 쿨링미스트' },
    { promoId: 'PROMO-004', seq: 1, prodNo: 'PD-40001', prodNm: '프리미엄 에센스' },
    { promoId: 'PROMO-004', seq: 2, prodNo: 'PD-40002', prodNm: '아이크림 30ml' },
    { promoId: 'PROMO-006', seq: 1, prodNo: 'PD-60001', prodNm: '연말 한정 기프트박스' },
    { promoId: 'PROMO-007', seq: 1, prodNo: 'PD-70001', prodNm: '신상 토너 200ml' },
    { promoId: 'PROMO-010', seq: 1, prodNo: 'PD-10004', prodNm: '겨울용 보습크림' }
  ],
  d2: [
    { promoId: 'PROMO-001', seq: 1, amount: 30000, cnt: 1, giftProdNo: 'GF-50001', giftProdNm: '미니 립밤', giftQty: 1 },
    { promoId: 'PROMO-001', seq: 2, amount: 60000, cnt: 2, giftProdNo: 'GF-50002', giftProdNm: '미니 핸드크림', giftQty: 2 },
    { promoId: 'PROMO-001', seq: 3, amount: 90000, cnt: 3, giftProdNo: 'GF-50003', giftProdNm: '트래블 키트', giftQty: 1 },
    { promoId: 'PROMO-002', seq: 1, amount: 50000, cnt: 1, giftProdNo: 'GF-60001', giftProdNm: '샘플 파우치 세트', giftQty: 1 },
    { promoId: 'PROMO-002', seq: 2, amount: 100000, cnt: 2, giftProdNo: 'GF-60002', giftProdNm: '마스크팩 5매입', giftQty: 1 },
    { promoId: 'PROMO-003', seq: 1, amount: 20000, cnt: 1, giftProdNo: 'GF-70001', giftProdNm: '쿨링 패치', giftQty: 3 },
    { promoId: 'PROMO-004', seq: 1, amount: 150000, cnt: 1, giftProdNo: 'GF-80001', giftProdNm: 'VIP 전용 파우치', giftQty: 1 },
    { promoId: 'PROMO-006', seq: 1, amount: 70000, cnt: 1, giftProdNo: 'GF-90001', giftProdNm: '연말 캘린더', giftQty: 1 },
    { promoId: 'PROMO-007', seq: 1, amount: 40000, cnt: 1, giftProdNo: 'GF-10001', giftProdNm: '미니 토너 30ml', giftQty: 2 },
    { promoId: 'PROMO-010', seq: 1, amount: 80000, cnt: 1, giftProdNo: 'GF-11001', giftProdNm: '보습 립밤 세트', giftQty: 1 }
  ]
};
