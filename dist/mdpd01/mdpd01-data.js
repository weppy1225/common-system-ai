/* MDPD01 테스트 데이터 */
const MDPD01_DATA = {
  products: [
    {
      bizNm: '본사', prodNo: 'PD-2025-0001', prodNm: '아메리카노 원두 1kg', spec: '1kg/봉', unit: 'EA', prodClsCd: '원자재',
      lrgClsNm: '식품', midClsNm: '음료', smlClsNm: '커피', imminentDays: 30, validDays: 365, weight: 1.0, packQty: 10,
      prodIdentCd: '8801234567890', logisIdentCd: 'LOG-0001', origin: '콜롬비아', brand: '하이브루',
      useYn: '사용', bundleQty: 5, bundleUnitNm: '박스', singleQty: 20, palFace: 4, palTier: 5,
      width: 20, length: 30, height: 15, prodSku: 'SKU-PD-001', prodLabel: 'LBL-001',
      pltSku: 'PLT-SKU-001', pltLabel: 'PLT-LBL-001', remark: '인기 상품', modDt: '2025-03-20 14:30'
    },
    {
      bizNm: '본사', prodNo: 'PD-2025-0002', prodNm: '카페라떼 파우더 500g', spec: '500g/봉', unit: 'EA', prodClsCd: '원자재',
      lrgClsNm: '식품', midClsNm: '음료', smlClsNm: '커피', imminentDays: 60, validDays: 180, weight: 0.5, packQty: 20,
      prodIdentCd: '8801234567891', logisIdentCd: 'LOG-0002', origin: '브라질', brand: '하이브루',
      useYn: '사용', bundleQty: 10, bundleUnitNm: '박스', singleQty: 40, palFace: 6, palTier: 4,
      width: 15, length: 25, height: 10, prodSku: 'SKU-PD-002', prodLabel: 'LBL-002',
      pltSku: 'PLT-SKU-002', pltLabel: 'PLT-LBL-002', remark: '', modDt: '2025-03-19 10:15'
    },
    {
      bizNm: '본사', prodNo: 'PD-2025-0003', prodNm: '종이컵 6.5oz', spec: '6.5oz/1000개입', unit: 'BOX', prodClsCd: '부자재',
      lrgClsNm: '포장재', midClsNm: '컵류', smlClsNm: '종이컵', imminentDays: 0, validDays: 0, weight: 3.2, packQty: 50,
      prodIdentCd: '8801234567892', logisIdentCd: 'LOG-0003', origin: '한국', brand: '그린컵',
      useYn: '사용', bundleQty: 1, bundleUnitNm: '박스', singleQty: 1000, palFace: 8, palTier: 6,
      width: 40, length: 40, height: 35, prodSku: 'SKU-PD-003', prodLabel: 'LBL-003',
      pltSku: 'PLT-SKU-003', pltLabel: 'PLT-LBL-003', remark: '대량 소모품', modDt: '2025-03-18 09:00'
    },
    {
      bizNm: '본사', prodNo: 'PD-2025-0004', prodNm: '바닐라 시럽 750ml', spec: '750ml/병', unit: 'EA', prodClsCd: '원자재',
      lrgClsNm: '식품', midClsNm: '음료', smlClsNm: '시럽', imminentDays: 90, validDays: 720, weight: 0.8, packQty: 12,
      prodIdentCd: '8801234567893', logisIdentCd: 'LOG-0004', origin: '프랑스', brand: '모닌',
      useYn: '사용', bundleQty: 6, bundleUnitNm: '박스', singleQty: 12, palFace: 5, palTier: 4,
      width: 8, length: 8, height: 30, prodSku: 'SKU-PD-004', prodLabel: 'LBL-004',
      pltSku: 'PLT-SKU-004', pltLabel: 'PLT-LBL-004', remark: '', modDt: '2025-03-17 16:45'
    },
    {
      bizNm: '본사', prodNo: 'PD-2025-0005', prodNm: '헤이즐넛 시럽 750ml', spec: '750ml/병', unit: 'EA', prodClsCd: '원자재',
      lrgClsNm: '식품', midClsNm: '음료', smlClsNm: '시럽', imminentDays: 90, validDays: 720, weight: 0.8, packQty: 12,
      prodIdentCd: '8801234567894', logisIdentCd: 'LOG-0005', origin: '프랑스', brand: '모닌',
      useYn: '미사용', bundleQty: 6, bundleUnitNm: '박스', singleQty: 12, palFace: 5, palTier: 4,
      width: 8, length: 8, height: 30, prodSku: 'SKU-PD-005', prodLabel: 'LBL-005',
      pltSku: 'PLT-SKU-005', pltLabel: 'PLT-LBL-005', remark: '단종 예정', modDt: '2025-03-16 11:20'
    },
    {
      bizNm: '본사', prodNo: 'PD-2025-0006', prodNm: '우유 1L 멸균팩', spec: '1L/팩', unit: 'EA', prodClsCd: '원자재',
      lrgClsNm: '식품', midClsNm: '유제품', smlClsNm: '우유', imminentDays: 7, validDays: 14, weight: 1.0, packQty: 12,
      prodIdentCd: '8801234567895', logisIdentCd: 'LOG-0006', origin: '한국', brand: '서울우유',
      useYn: '사용', bundleQty: 12, bundleUnitNm: '박스', singleQty: 12, palFace: 6, palTier: 3,
      width: 10, length: 7, height: 25, prodSku: 'SKU-PD-006', prodLabel: 'LBL-006',
      pltSku: 'PLT-SKU-006', pltLabel: 'PLT-LBL-006', remark: '냉장보관', modDt: '2025-03-15 08:30'
    },
    {
      bizNm: '본사', prodNo: 'PD-2025-0007', prodNm: '텀블러 350ml 스텐', spec: '350ml', unit: 'EA', prodClsCd: '상품',
      lrgClsNm: '잡화', midClsNm: '용기', smlClsNm: '텀블러', imminentDays: 0, validDays: 0, weight: 0.3, packQty: 24,
      prodIdentCd: '8801234567896', logisIdentCd: 'LOG-0007', origin: '중국', brand: '카페메이트',
      useYn: '사용', bundleQty: 6, bundleUnitNm: '박스', singleQty: 24, palFace: 8, palTier: 5,
      width: 8, length: 8, height: 18, prodSku: 'SKU-PD-007', prodLabel: 'LBL-007',
      pltSku: 'PLT-SKU-007', pltLabel: 'PLT-LBL-007', remark: '', modDt: '2025-03-14 13:10'
    },
    {
      bizNm: '본사', prodNo: 'PD-2025-0008', prodNm: '디카페인 원두 500g', spec: '500g/봉', unit: 'EA', prodClsCd: '원자재',
      lrgClsNm: '식품', midClsNm: '음료', smlClsNm: '커피', imminentDays: 30, validDays: 365, weight: 0.5, packQty: 20,
      prodIdentCd: '8801234567897', logisIdentCd: 'LOG-0008', origin: '에티오피아', brand: '하이브루',
      useYn: '사용', bundleQty: 10, bundleUnitNm: '박스', singleQty: 20, palFace: 6, palTier: 5,
      width: 15, length: 20, height: 10, prodSku: 'SKU-PD-008', prodLabel: 'LBL-008',
      pltSku: 'PLT-SKU-008', pltLabel: 'PLT-LBL-008', remark: '프리미엄', modDt: '2025-03-13 15:00'
    },
    {
      bizNm: '본사', prodNo: 'PD-2025-0009', prodNm: '초콜릿 파우더 1kg', spec: '1kg/봉', unit: 'EA', prodClsCd: '원자재',
      lrgClsNm: '식품', midClsNm: '음료', smlClsNm: '초콜릿', imminentDays: 60, validDays: 540, weight: 1.0, packQty: 10,
      prodIdentCd: '8801234567898', logisIdentCd: 'LOG-0009', origin: '벨기에', brand: '칼리바우트',
      useYn: '사용', bundleQty: 5, bundleUnitNm: '박스', singleQty: 10, palFace: 4, palTier: 5,
      width: 20, length: 30, height: 15, prodSku: 'SKU-PD-009', prodLabel: 'LBL-009',
      pltSku: 'PLT-SKU-009', pltLabel: 'PLT-LBL-009', remark: '', modDt: '2025-03-12 10:40'
    },
    {
      bizNm: '본사', prodNo: 'PD-2025-0010', prodNm: '빨대 일회용 500개입', spec: '500개/봉', unit: 'BOX', prodClsCd: '부자재',
      lrgClsNm: '포장재', midClsNm: '소모품', smlClsNm: '빨대', imminentDays: 0, validDays: 0, weight: 0.8, packQty: 100,
      prodIdentCd: '8801234567899', logisIdentCd: 'LOG-0010', origin: '한국', brand: '그린팩',
      useYn: '사용', bundleQty: 10, bundleUnitNm: '박스', singleQty: 500, palFace: 10, palTier: 6,
      width: 25, length: 10, height: 5, prodSku: 'SKU-PD-010', prodLabel: 'LBL-010',
      pltSku: 'PLT-SKU-010', pltLabel: 'PLT-LBL-010', remark: '', modDt: '2025-03-11 09:20'
    },
    {
      bizNm: '본사', prodNo: 'PD-2025-0011', prodNm: '캐러멜 소스 500ml', spec: '500ml/병', unit: 'EA', prodClsCd: '원자재',
      lrgClsNm: '식품', midClsNm: '음료', smlClsNm: '소스', imminentDays: 90, validDays: 540, weight: 0.6, packQty: 12,
      prodIdentCd: '8801234567900', logisIdentCd: 'LOG-0011', origin: '미국', brand: '토라니',
      useYn: '사용', bundleQty: 6, bundleUnitNm: '박스', singleQty: 12, palFace: 6, palTier: 4,
      width: 7, length: 7, height: 25, prodSku: 'SKU-PD-011', prodLabel: 'LBL-011',
      pltSku: 'PLT-SKU-011', pltLabel: 'PLT-LBL-011', remark: '', modDt: '2025-03-10 14:55'
    },
    {
      bizNm: '본사', prodNo: 'PD-2025-0012', prodNm: '테이크아웃 컵 리드', spec: '1000개입', unit: 'BOX', prodClsCd: '부자재',
      lrgClsNm: '포장재', midClsNm: '컵류', smlClsNm: '리드', imminentDays: 0, validDays: 0, weight: 2.5, packQty: 50,
      prodIdentCd: '8801234567901', logisIdentCd: 'LOG-0012', origin: '한국', brand: '그린컵',
      useYn: '미사용', bundleQty: 1, bundleUnitNm: '박스', singleQty: 1000, palFace: 8, palTier: 5,
      width: 35, length: 35, height: 20, prodSku: 'SKU-PD-012', prodLabel: 'LBL-012',
      pltSku: 'PLT-SKU-012', pltLabel: 'PLT-LBL-012', remark: '규격 변경 예정', modDt: '2025-03-09 17:30'
    }
  ]
};
