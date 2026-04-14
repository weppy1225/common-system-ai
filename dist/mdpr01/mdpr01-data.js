/* mdpr01 테스트 데이터 */
const MDPR01_DATA = {
  main: [
    { id: 'PROMO-001', site: '본사',      nm: '봄맞이 사은품 이벤트',  type: '금액', giftType: '한번만', targetType: '품목',   targetQty: 50000,  stDt: '2026-03-01', edDt: '2026-03-31', useYn: '사용',  rmk: '3월 한정 프로모션' },
    { id: 'PROMO-002', site: '본사',      nm: '여름 시즌 대량구매',   type: '수량', giftType: '여러번', targetType: '대분류', targetQty: 20,    stDt: '2026-06-01', edDt: '2026-08-31', useYn: '사용',  rmk: '여름 대분류 프로모션' },
    { id: 'PROMO-003', site: '물류센터A', nm: '신규 회원 혜택',       type: '금액', giftType: '한번만', targetType: '품목',   targetQty: 30000,  stDt: '2026-01-01', edDt: '2026-12-31', useYn: '사용',  rmk: '신규 회원 대상' },
    { id: 'PROMO-004', site: '물류센터A', nm: 'VIP 고객 특별 증정',   type: '금액', giftType: '여러번', targetType: '품목',   targetQty: 100000, stDt: '2026-02-01', edDt: '2026-04-30', useYn: '사용',  rmk: 'VIP 전용' },
    { id: 'PROMO-005', site: '본사',      nm: '가을 감사 프로모션',   type: '수량', giftType: '한번만', targetType: '대분류', targetQty: 10,    stDt: '2026-09-01', edDt: '2026-10-31', useYn: '미사용', rmk: '가을 감사 이벤트' },
    { id: 'PROMO-006', site: '물류센터B', nm: '겨울 대박 행사',       type: '금액', giftType: '한번만', targetType: '품목',   targetQty: 80000,  stDt: '2026-11-15', edDt: '2026-12-31', useYn: '사용',  rmk: '연말 프로모션' },
    { id: 'PROMO-007', site: '본사',      nm: '특가 기획전',          type: '수량', giftType: '여러번', targetType: '품목',   targetQty: 5,     stDt: '2026-05-10', edDt: '2026-05-20', useYn: '사용',  rmk: '10일간 한정' },
    { id: 'PROMO-008', site: '물류센터A', nm: '가정의 달 이벤트',     type: '금액', giftType: '한번만', targetType: '대분류', targetQty: 40000,  stDt: '2026-05-01', edDt: '2026-05-31', useYn: '사용',  rmk: '5월 한정' },
    { id: 'PROMO-009', site: '물류센터B', nm: '재고 소진 프로모션',   type: '수량', giftType: '여러번', targetType: '품목',   targetQty: 3,     stDt: '2026-04-01', edDt: '2026-04-30', useYn: '미사용', rmk: '재고 소진 목적' },
    { id: 'PROMO-010', site: '본사',      nm: '블랙프라이데이 특가',  type: '금액', giftType: '한번만', targetType: '품목',   targetQty: 70000,  stDt: '2026-11-24', edDt: '2026-11-28', useYn: '사용',  rmk: '5일 한정' },
    { id: 'PROMO-011', site: '물류센터A', nm: '어린이날 이벤트',      type: '수량', giftType: '한번만', targetType: '대분류', targetQty: 15,    stDt: '2026-05-01', edDt: '2026-05-05', useYn: '사용',  rmk: '어린이날' },
    { id: 'PROMO-012', site: '본사',      nm: '추석 선물 증정',       type: '금액', giftType: '한번만', targetType: '품목',   targetQty: 60000,  stDt: '2026-09-15', edDt: '2026-09-25', useYn: '사용',  rmk: '추석 연휴' }
  ],
  d1: [
    /* PROMO-001: 품목 5건 */
    { promoId: 'PROMO-001', large: '',      prodNo: 'PD-A001', prodNm: '프리미엄 커피믹스 100T' },
    { promoId: 'PROMO-001', large: '',      prodNo: 'PD-A002', prodNm: '녹차 티백 50T' },
    { promoId: 'PROMO-001', large: '',      prodNo: 'PD-A003', prodNm: '핸드드립 커피 200g' },
    { promoId: 'PROMO-001', large: '',      prodNo: 'PD-A004', prodNm: '우롱차 100g' },
    { promoId: 'PROMO-001', large: '',      prodNo: 'PD-A005', prodNm: '캡슐커피 40개입' },
    /* PROMO-002: 대분류 1건 (여러번) */
    { promoId: 'PROMO-002', large: '식품', prodNo: '',         prodNm: '' },
    /* PROMO-003: 품목 6건 */
    { promoId: 'PROMO-003', large: '',      prodNo: 'PD-B001', prodNm: '유기농 시리얼 500g' },
    { promoId: 'PROMO-003', large: '',      prodNo: 'PD-B002', prodNm: '꿀 300g' },
    { promoId: 'PROMO-003', large: '',      prodNo: 'PD-B003', prodNm: '올리브오일 500ml' },
    { promoId: 'PROMO-003', large: '',      prodNo: 'PD-B004', prodNm: '발사믹식초 250ml' },
    { promoId: 'PROMO-003', large: '',      prodNo: 'PD-B005', prodNm: '아몬드 300g' },
    { promoId: 'PROMO-003', large: '',      prodNo: 'PD-B006', prodNm: '호두 300g' },
    /* PROMO-004: 품목 5건 (여러번 이지만 데이터 예시로 여러개 넣음) */
    { promoId: 'PROMO-004', large: '',      prodNo: 'PD-C001', prodNm: 'VIP 전용 와인 세트' },
    /* PROMO-005: 대분류 */
    { promoId: 'PROMO-005', large: '생활용품', prodNo: '',      prodNm: '' },
    /* PROMO-010: 품목 */
    { promoId: 'PROMO-010', large: '',      prodNo: 'PD-D001', prodNm: '블랙프라이데이 특가상품 A' },
    { promoId: 'PROMO-010', large: '',      prodNo: 'PD-D002', prodNm: '블랙프라이데이 특가상품 B' }
  ],
  d2: [
    /* PROMO-001 증정품 (5건) */
    { promoId: 'PROMO-001', amt: 30000,  giftNo: 'GT-001', giftNm: '고급 머그컵',       giftQty: 1 },
    { promoId: 'PROMO-001', amt: 60000,  giftNo: 'GT-002', giftNm: '스테인리스 보온병', giftQty: 1 },
    { promoId: 'PROMO-001', amt: 90000,  giftNo: 'GT-003', giftNm: '선물세트 (소)',     giftQty: 1 },
    { promoId: 'PROMO-001', amt: 120000, giftNo: 'GT-004', giftNm: '선물세트 (중)',     giftQty: 1 },
    { promoId: 'PROMO-001', amt: 150000, giftNo: 'GT-005', giftNm: '선물세트 (대)',     giftQty: 1 },
    /* PROMO-002 */
    { promoId: 'PROMO-002', amt: 10, giftNo: 'GT-010', giftNm: '기획 사은품 A', giftQty: 1 },
    { promoId: 'PROMO-002', amt: 20, giftNo: 'GT-011', giftNm: '기획 사은품 B', giftQty: 2 },
    /* PROMO-003 */
    { promoId: 'PROMO-003', amt: 30000, giftNo: 'GT-020', giftNm: '신규가입 머그컵', giftQty: 1 },
    { promoId: 'PROMO-003', amt: 60000, giftNo: 'GT-021', giftNm: '신규가입 세트',   giftQty: 1 },
    /* PROMO-004 VIP */
    { promoId: 'PROMO-004', amt: 100000, giftNo: 'GT-030', giftNm: 'VIP 한정 수첩',     giftQty: 1 },
    { promoId: 'PROMO-004', amt: 200000, giftNo: 'GT-031', giftNm: 'VIP 한정 백팩',     giftQty: 1 },
    /* PROMO-010 */
    { promoId: 'PROMO-010', amt: 70000,  giftNo: 'GT-040', giftNm: 'BF 한정 굿즈',      giftQty: 1 },
    { promoId: 'PROMO-010', amt: 140000, giftNo: 'GT-041', giftNm: 'BF 한정 프리미엄', giftQty: 1 }
  ],
  largeCategories: ['식품', '생활용품', '가전', '의류', '도서']
};
