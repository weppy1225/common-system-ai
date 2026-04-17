/* stdc01 테스트 데이터 */
const STDC01_DATA = {
  main: [
    {
      prodNo: '8809482995451_12', prodNm: 'DX 아머소울 세트 01', unit: 'EA', category: 'TOY',
      stockQty: 100, inQty: 1, boxQty: 100, pieceQty: 0, bundleQty: 12, totalQty: 1200,
      waitQty: 0, procQty: 100, stockStatus: '정상', warehouse: '상품창고', location: 'AA-01-41',
      expDate: '2099-12-31', toProdNo: '8809482995451_1', toProdNm: 'DX 아머소울 세트 01'
    },
    {
      prodNo: '4573102685803_6', prodNm: '30MF 리베르 랜서', unit: 'EA', category: 'HOBBY',
      stockQty: 30, inQty: 1, boxQty: 30, pieceQty: 0, bundleQty: 6, totalQty: 180,
      waitQty: 10, procQty: 30, stockStatus: '정상', warehouse: '상품창고', location: 'BA-03-34',
      expDate: '2099-12-31', toProdNo: '4573102685803_1', toProdNm: '30MF 리베르 랜서'
    },
    {
      prodNo: '4570118105653_20', prodNm: '[BOX] 기동전사 건담 모빌슈트 앙상블 26', unit: 'EA', category: 'CAPSULE',
      stockQty: 2000, inQty: 1, boxQty: 2000, pieceQty: 0, bundleQty: 20, totalQty: 40000,
      waitQty: 500, procQty: 1500, stockStatus: '정상', warehouse: '상품창고', location: 'CA-03-34',
      expDate: '2099-12-31', toProdNo: '4570118105653_1', toProdNm: '[BOX] 기동전사 건담 모빌슈트 앙상블 26'
    },
    {
      prodNo: '4549660756507_10', prodNm: '하이퍼 기가 미사일 세트', unit: 'EA', category: 'TOY',
      stockQty: 50, inQty: 1, boxQty: 50, pieceQty: 0, bundleQty: 10, totalQty: 500,
      waitQty: 5, procQty: 50, stockStatus: '정상', warehouse: '상품창고', location: 'AA-02-11',
      expDate: '2099-12-31', toProdNo: '4549660756507_1', toProdNm: '하이퍼 기가 미사일'
    },
    {
      prodNo: '4905083083122_4', prodNm: '포켓몬스터 컬렉션 세트 A', unit: 'EA', category: 'HOBBY',
      stockQty: 120, inQty: 1, boxQty: 120, pieceQty: 0, bundleQty: 4, totalQty: 480,
      waitQty: 20, procQty: 120, stockStatus: '정상', warehouse: '상품창고', location: 'BB-01-22',
      expDate: '2099-12-31', toProdNo: '4905083083122_1', toProdNm: '포켓몬스터 컬렉션 A'
    },
    {
      prodNo: '4901777339446_6', prodNm: '반다이 드래곤볼 피규어 세트', unit: 'EA', category: 'FIGURE',
      stockQty: 60, inQty: 1, boxQty: 60, pieceQty: 0, bundleQty: 6, totalQty: 360,
      waitQty: 0, procQty: 60, stockStatus: '정상', warehouse: '상품창고', location: 'CC-02-31',
      expDate: '2099-12-31', toProdNo: '4901777339446_1', toProdNm: '반다이 드래곤볼 피규어'
    },
    {
      prodNo: '4543112990044_12', prodNm: '건담 HGBF 시즌 12 세트', unit: 'EA', category: 'HOBBY',
      stockQty: 240, inQty: 1, boxQty: 240, pieceQty: 0, bundleQty: 12, totalQty: 2880,
      waitQty: 30, procQty: 240, stockStatus: '정상', warehouse: '상품창고', location: 'DA-01-12',
      expDate: '2099-12-31', toProdNo: '4543112990044_1', toProdNm: '건담 HGBF 시즌 12'
    },
    {
      prodNo: '4970381130058_8', prodNm: '원피스 DX 피규어 세트', unit: 'EA', category: 'FIGURE',
      stockQty: 80, inQty: 1, boxQty: 80, pieceQty: 0, bundleQty: 8, totalQty: 640,
      waitQty: 15, procQty: 80, stockStatus: '정상', warehouse: '상품창고', location: 'EA-03-21',
      expDate: '2026-06-30', toProdNo: '4970381130058_1', toProdNm: '원피스 DX 피규어'
    },
    {
      prodNo: '4904810910565_5', prodNm: '에반게리온 소형피규어 세트 5', unit: 'EA', category: 'FIGURE',
      stockQty: 150, inQty: 1, boxQty: 150, pieceQty: 0, bundleQty: 5, totalQty: 750,
      waitQty: 25, procQty: 150, stockStatus: '정상', warehouse: '상품창고', location: 'FA-02-33',
      expDate: '2099-12-31', toProdNo: '4904810910565_1', toProdNm: '에반게리온 소형피규어'
    },
    {
      prodNo: '4543112750006_6', prodNm: '[HG] 자쿠 II 세트 6개입', unit: 'EA', category: 'HOBBY',
      stockQty: 180, inQty: 1, boxQty: 180, pieceQty: 0, bundleQty: 6, totalQty: 1080,
      waitQty: 0, procQty: 180, stockStatus: '정상', warehouse: '상품창고', location: 'GA-01-44',
      expDate: '2099-12-31', toProdNo: '4543112750006_1', toProdNm: '[HG] 자쿠 II'
    },
    {
      prodNo: '4970381241112_10', prodNm: '나루토 나뭇잎 닌자 세트', unit: 'EA', category: 'FIGURE',
      stockQty: 70, inQty: 1, boxQty: 70, pieceQty: 0, bundleQty: 10, totalQty: 700,
      waitQty: 10, procQty: 70, stockStatus: '정상', warehouse: '상품창고', location: 'HA-03-12',
      expDate: '2026-12-31', toProdNo: '4970381241112_1', toProdNm: '나루토 나뭇잎 닌자'
    },
    {
      prodNo: '4550218051223_24', prodNm: '미니카 컬렉션 세트 24개입', unit: 'EA', category: 'TOY',
      stockQty: 24, inQty: 1, boxQty: 24, pieceQty: 0, bundleQty: 24, totalQty: 576,
      waitQty: 0, procQty: 24, stockStatus: '정상', warehouse: '상품창고', location: 'IA-01-05',
      expDate: '2099-12-31', toProdNo: '4550218051223_1', toProdNm: '미니카 컬렉션'
    }
  ]
};
