
/* dlvo01 배송차량등록 테스트 데이터 */
// const DLVO01_DATA = {
//   deliveries: [
//     { seq: 'DLV-001', dlvDt: '2026-03-24', dlvNo: 'CR2026032401', destinNm: '한강점, 강남점', remark: '오전 배송', ackYn: 'Y' },
//     { seq: 'DLV-002', dlvDt: '2026-03-24', dlvNo: 'CR2026032402', destinNm: '신촌점',           remark: '',         ackYn: 'N' },
//     { seq: 'DLV-003', dlvDt: '2026-03-24', dlvNo: 'CR2026032403', destinNm: '수원점, 안양점',   remark: '급배송',    ackYn: 'N' },
//     { seq: 'DLV-004', dlvDt: '2026-03-24', dlvNo: 'CR2026032404', destinNm: '분당점',           remark: '',         ackYn: 'N' },
//     { seq: 'DLV-005', dlvDt: '2026-03-24', dlvNo: 'CR2026032405', destinNm: '일산점, 파주점',   remark: '오후 배송', ackYn: 'N' },
//     { seq: 'DLV-006', dlvDt: '2026-03-23', dlvNo: 'CR2026032301', destinNm: '인천점',           remark: '',         ackYn: 'Y' },
//     { seq: 'DLV-007', dlvDt: '2026-03-23', dlvNo: 'CR2026032302', destinNm: '부천점, 광명점',   remark: '',         ackYn: 'Y' },
//     { seq: 'DLV-008', dlvDt: '2026-03-23', dlvNo: 'CR2026032303', destinNm: '안산점',           remark: '주의요망', ackYn: 'N' },
//     { seq: 'DLV-009', dlvDt: '2026-03-22', dlvNo: 'CR2026032201', destinNm: '용인점',           remark: '',         ackYn: 'Y' },
//     { seq: 'DLV-010', dlvDt: '2026-03-22', dlvNo: 'CR2026032202', destinNm: '성남점, 하남점',   remark: '',         ackYn: 'Y' }
//   ],
//   d1: {
//     'DLV-001': [
//       { carNo: '12가 3456', driverNm: '김철수', phone: '010-1234-5678', weight: '2,500', remark: '베테랑 기사', ackYn: 'Y', signYn: 'Y' },
//       { carNo: '34나 5678', driverNm: '이영희', phone: '010-2345-6789', weight: '1,800', remark: '',           ackYn: 'Y', signYn: 'Y' }
//     ],
//     'DLV-002': [
//       { carNo: '56다 7890', driverNm: '박민수', phone: '010-3456-7890', weight: '3,200', remark: '냉장차량', ackYn: 'N', signYn: 'N' }
//     ],
//     'DLV-003': [
//       { carNo: '78라 9012', driverNm: '최지현', phone: '010-4567-8901', weight: '1,500', remark: '',        ackYn: 'N', signYn: 'N' },
//       { carNo: '90마 1234', driverNm: '정수민', phone: '010-5678-9012', weight: '2,000', remark: '2톤 탑차', ackYn: 'N', signYn: 'N' }
//     ],
//     'DLV-004': [
//       { carNo: '23바 4567', driverNm: '강도훈', phone: '010-6789-0123', weight: '1,200', remark: '', ackYn: 'N', signYn: 'N' }
//     ],
//     'DLV-005': [
//       { carNo: '45사 6789', driverNm: '윤소영', phone: '010-7890-1234', weight: '2,800', remark: '경기북부 전담', ackYn: 'N', signYn: 'N' }
//     ],
//     'DLV-006': [
//       { carNo: '67아 8901', driverNm: '임재원', phone: '010-8901-2345', weight: '1,600', remark: '', ackYn: 'Y', signYn: 'Y' }
//     ],
//     'DLV-007': [
//       { carNo: '89자 0123', driverNm: '한미래', phone: '010-9012-3456', weight: '2,100', remark: '', ackYn: 'Y', signYn: 'Y' }
//     ],
//     'DLV-008': [
//       { carNo: '01차 2345', driverNm: '오세진', phone: '010-0123-4567', weight: '3,000', remark: '주의요망', ackYn: 'N', signYn: 'N' }
//     ],
//     'DLV-009': [
//       { carNo: '12가 3456', driverNm: '김철수', phone: '010-1234-5678', weight: '2,200', remark: '', ackYn: 'Y', signYn: 'Y' }
//     ],
//     'DLV-010': [
//       { carNo: '34나 5678', driverNm: '이영희', phone: '010-2345-6789', weight: '1,900', remark: '', ackYn: 'Y', signYn: 'Y' },
//       { carNo: '56다 7890', driverNm: '박민수', phone: '010-3456-7890', weight: '2,400', remark: '', ackYn: 'Y', signYn: 'Y' }
//     ]
//   },
//   d2: {
//     'DLV-001': [
//       { outTypNm: '일반출고', stsCd: '출하완료', outDt: '2026-03-24', outNo: 'OW2026032401', ordNo: 'ORD-2026-001234', cpTypNm: '대형마트', cpNm: '한강마트', destinNm: '한강점', prodCnt: 5 },
//       { outTypNm: '일반출고', stsCd: '출하완료', outDt: '2026-03-24', outNo: 'OW2026032402', ordNo: 'ORD-2026-001235', cpTypNm: '대형마트', cpNm: '강남유통', destinNm: '강남점', prodCnt: 3 }
//     ],
//     'DLV-002': [
//       { outTypNm: '긴급출고', stsCd: '출하완료', outDt: '2026-03-24', outNo: 'OW2026032403', ordNo: 'ORD-2026-001236', cpTypNm: '편의점',   cpNm: '신촌편의', destinNm: '신촌점', prodCnt: 8 }
//     ],
//     'DLV-003': [
//       { outTypNm: '일반출고', stsCd: '출하완료', outDt: '2026-03-24', outNo: 'OW2026032404', ordNo: 'ORD-2026-001237', cpTypNm: '슈퍼마켓', cpNm: '수원슈퍼', destinNm: '수원점', prodCnt: 12 },
//       { outTypNm: '일반출고', stsCd: '출하완료', outDt: '2026-03-24', outNo: 'OW2026032405', ordNo: 'ORD-2026-001238', cpTypNm: '슈퍼마켓', cpNm: '안양마트', destinNm: '안양점', prodCnt: 7  }
//     ],
//     'DLV-004': [
//       { outTypNm: '일반출고', stsCd: '출하완료', outDt: '2026-03-24', outNo: 'OW2026032406', ordNo: 'ORD-2026-001239', cpTypNm: '대형마트', cpNm: '분당마트', destinNm: '분당점', prodCnt: 9 }
//     ],
//     'DLV-005': [
//       { outTypNm: '일반출고', stsCd: '출하완료', outDt: '2026-03-24', outNo: 'OW2026032407', ordNo: 'ORD-2026-001240', cpTypNm: '편의점',   cpNm: '일산편의', destinNm: '일산점', prodCnt: 4 },
//       { outTypNm: '일반출고', stsCd: '출하완료', outDt: '2026-03-24', outNo: 'OW2026032408', ordNo: 'ORD-2026-001241', cpTypNm: '편의점',   cpNm: '파주편의', destinNm: '파주점', prodCnt: 6 }
//     ],
//     'DLV-006': [
//       { outTypNm: '일반출고', stsCd: '출하완료', outDt: '2026-03-23', outNo: 'OW2026032301', ordNo: 'ORD-2026-001220', cpTypNm: '대형마트', cpNm: '인천마트', destinNm: '인천점', prodCnt: 11 }
//     ],
//     'DLV-007': [
//       { outTypNm: '일반출고', stsCd: '출하완료', outDt: '2026-03-23', outNo: 'OW2026032302', ordNo: 'ORD-2026-001221', cpTypNm: '슈퍼마켓', cpNm: '부천슈퍼', destinNm: '부천점', prodCnt: 5 },
//       { outTypNm: '일반출고', stsCd: '출하완료', outDt: '2026-03-23', outNo: 'OW2026032303', ordNo: 'ORD-2026-001222', cpTypNm: '슈퍼마켓', cpNm: '광명마트', destinNm: '광명점', prodCnt: 8 }
//     ],
//     'DLV-008': [
//       { outTypNm: '긴급출고', stsCd: '출하완료', outDt: '2026-03-23', outNo: 'OW2026032304', ordNo: 'ORD-2026-001223', cpTypNm: '편의점',   cpNm: '안산편의', destinNm: '안산점', prodCnt: 3 }
//     ],
//     'DLV-009': [
//       { outTypNm: '일반출고', stsCd: '출하완료', outDt: '2026-03-22', outNo: 'OW2026032201', ordNo: 'ORD-2026-001210', cpTypNm: '대형마트', cpNm: '용인마트', destinNm: '용인점', prodCnt: 7 }
//     ],
//     'DLV-010': [
//       { outTypNm: '일반출고', stsCd: '출하완료', outDt: '2026-03-22', outNo: 'OW2026032202', ordNo: 'ORD-2026-001211', cpTypNm: '슈퍼마켓', cpNm: '성남슈퍼', destinNm: '성남점', prodCnt: 9 },
//       { outTypNm: '일반출고', stsCd: '출하완료', outDt: '2026-03-22', outNo: 'OW2026032203', ordNo: 'ORD-2026-001212', cpTypNm: '편의점',   cpNm: '하남편의', destinNm: '하남점', prodCnt: 4 }
//     ]
//   },
//   /* 차량 선택 팝업 – 기준정보 등록 차량 목록 */
//   cars: [
//     { carNo: '12가 3456', driverNm: '김철수', phone: '010-1234-5678', weight: '2,500' },
//     { carNo: '34나 5678', driverNm: '이영희', phone: '010-2345-6789', weight: '1,800' },
//     { carNo: '56다 7890', driverNm: '박민수', phone: '010-3456-7890', weight: '3,200' },
//     { carNo: '78라 9012', driverNm: '최지현', phone: '010-4567-8901', weight: '1,500' },
//     { carNo: '90마 1234', driverNm: '정수민', phone: '010-5678-9012', weight: '2,000' },
//     { carNo: '23바 4567', driverNm: '강도훈', phone: '010-6789-0123', weight: '1,200' },
//     { carNo: '45사 6789', driverNm: '윤소영', phone: '010-7890-1234', weight: '2,800' },
//     { carNo: '67아 8901', driverNm: '임재원', phone: '010-8901-2345', weight: '1,600' },
//     { carNo: '89자 0123', driverNm: '한미래', phone: '010-9012-3456', weight: '2,100' },
//     { carNo: '01차 2345', driverNm: '오세진', phone: '010-0123-4567', weight: '3,000' }
//   ],
//   /* 배송건 등록 팝업 – 출하완료된 미배정 주문건 */
//   orders: [
//     { outTypNm: '일반출고', stsCd: '출하완료', outDt: '2026-03-24', outNo: 'OW2026032410', ordNo: 'ORD-2026-001250', cpTypNm: '대형마트', cpNm: '강동마트',   destinNm: '강동점',   prodCnt: 5,  remark: ''       },
//     { outTypNm: '일반출고', stsCd: '출하완료', outDt: '2026-03-24', outNo: 'OW2026032411', ordNo: 'ORD-2026-001251', cpTypNm: '편의점',   cpNm: '노원편의',   destinNm: '노원점',   prodCnt: 3,  remark: ''       },
//     { outTypNm: '긴급출고', stsCd: '출하완료', outDt: '2026-03-24', outNo: 'OW2026032412', ordNo: 'ORD-2026-001252', cpTypNm: '슈퍼마켓', cpNm: '도봉마트',   destinNm: '도봉점',   prodCnt: 7,  remark: '우선처리' },
//     { outTypNm: '일반출고', stsCd: '출하완료', outDt: '2026-03-24', outNo: 'OW2026032413', ordNo: 'ORD-2026-001253', cpTypNm: '대형마트', cpNm: '은평마트',   destinNm: '은평점',   prodCnt: 4,  remark: ''       },
//     { outTypNm: '일반출고', stsCd: '출하완료', outDt: '2026-03-24', outNo: 'OW2026032414', ordNo: 'ORD-2026-001254', cpTypNm: '편의점',   cpNm: '마포편의',   destinNm: '마포점',   prodCnt: 6,  remark: ''       },
//     { outTypNm: '일반출고', stsCd: '출하완료', outDt: '2026-03-24', outNo: 'OW2026032415', ordNo: 'ORD-2026-001255', cpTypNm: '슈퍼마켓', cpNm: '서초슈퍼',   destinNm: '서초점',   prodCnt: 2,  remark: ''       },
//     { outTypNm: '긴급출고', stsCd: '출하완료', outDt: '2026-03-24', outNo: 'OW2026032416', ordNo: 'ORD-2026-001256', cpTypNm: '대형마트', cpNm: '송파마트',   destinNm: '송파점',   prodCnt: 8,  remark: '냉장보관' },
//     { outTypNm: '일반출고', stsCd: '출하완료', outDt: '2026-03-24', outNo: 'OW2026032417', ordNo: 'ORD-2026-001257', cpTypNm: '편의점',   cpNm: '관악편의',   destinNm: '관악점',   prodCnt: 5,  remark: ''       },
//     { outTypNm: '일반출고', stsCd: '출하완료', outDt: '2026-03-24', outNo: 'OW2026032418', ordNo: 'ORD-2026-001258', cpTypNm: '슈퍼마켓', cpNm: '동작마트',   destinNm: '동작점',   prodCnt: 3,  remark: ''       },
//     { outTypNm: '일반출고', stsCd: '출하완료', outDt: '2026-03-24', outNo: 'OW2026032419', ordNo: 'ORD-2026-001259', cpTypNm: '대형마트', cpNm: '영등포마트', destinNm: '영등포점', prodCnt: 9,  remark: ''       }

/* DLVO01 테스트 데이터 */
const DLVO01_DATA = {
  headers: [
    { seq: 1, dlvDate: '2026-03-25', dlvNo: 'CR20260325001', destNm: '(주)한국유통, 서울물산', remark: '오전배송', receipt: false /* D1 차량 3대 중 1대 미수신 → 동적 계산으로 비활성 */ },
    { seq: 2, dlvDate: '2026-03-25', dlvNo: 'CR20260325002', destNm: '대한상사', remark: '', receipt: false },
    { seq: 3, dlvDate: '2026-03-25', dlvNo: 'CR20260325003', destNm: '(주)신세계, 이마트 성수점', remark: '냉장차량 필수', receipt: true },
    { seq: 4, dlvDate: '2026-03-24', dlvNo: 'CR20260324001', destNm: '롯데마트 강남점', remark: '', receipt: false },
    { seq: 5, dlvDate: '2026-03-24', dlvNo: 'CR20260324002', destNm: '코스트코 양재점, GS리테일', remark: '하차 도움 필요', receipt: true },
    { seq: 6, dlvDate: '2026-03-24', dlvNo: 'CR20260324003', destNm: '홈플러스 잠실점', remark: '', receipt: false },
    { seq: 7, dlvDate: '2026-03-23', dlvNo: 'CR20260323001', destNm: '(주)한진물류', remark: '야간배송', receipt: true },
    { seq: 8, dlvDate: '2026-03-23', dlvNo: 'CR20260323002', destNm: 'CJ대한통운, (주)한국유통', remark: '', receipt: false },
    { seq: 9, dlvDate: '2026-03-23', dlvNo: 'CR20260323003', destNm: '현대백화점 판교점', remark: '주차장 진입', receipt: true },
    { seq: 10, dlvDate: '2026-03-22', dlvNo: 'CR20260322001', destNm: '이마트 용산점, 쿠팡 물류센터', remark: '', receipt: false }
  ],
  d1: [
    { seq: 1, headerSeq: 1, carNo: '서울12가3456', driverNm: '김기사', phone: '010-1234-5678', weight: '1,500', driverRemark: '1층 하차', receipt: true, sign: true },
    { seq: 2, headerSeq: 1, carNo: '경기34나7890', driverNm: '이운전', phone: '010-2345-6789', weight: '2,000', driverRemark: '', receipt: true, sign: false },
    { seq: 3, headerSeq: 1, carNo: '인천56다1234', driverNm: '박배송', phone: '010-3456-7890', weight: '1,200', driverRemark: '지하주차장', receipt: false, sign: false },
    { seq: 4, headerSeq: 2, carNo: '서울78라5678', driverNm: '최기사', phone: '010-4567-8901', weight: '3,000', driverRemark: '', receipt: false, sign: false },
    { seq: 5, headerSeq: 3, carNo: '경기90마9012', driverNm: '정운송', phone: '010-5678-9012', weight: '800', driverRemark: '냉장차량', receipt: true, sign: true },
    { seq: 6, headerSeq: 3, carNo: '서울11바3456', driverNm: '한배달', phone: '010-6789-0123', weight: '1,800', driverRemark: '', receipt: true, sign: true },
    { seq: 7, headerSeq: 5, carNo: '인천22사7890', driverNm: '오기사', phone: '010-7890-1234', weight: '2,500', driverRemark: '대형차량', receipt: true, sign: false },
    { seq: 8, headerSeq: 7, carNo: '경기33아1234', driverNm: '유배송', phone: '010-8901-2345', weight: '1,000', driverRemark: '', receipt: true, sign: true }
  ],
  d2: [
    { seq: 1, headerSeq: 1, outType: '일반출하', status: '출하완료', outDate: '2026-03-24', outNo: 'OW20260324001', orderNo: 'ORD-20260324-001', custType: 'B2B', custNm: '(주)한국유통', destNm: '(주)한국유통 본사', itemCnt: 5 },
    { seq: 2, headerSeq: 1, outType: '일반출하', status: '출하완료', outDate: '2026-03-24', outNo: 'OW20260324002', orderNo: 'ORD-20260324-002', custType: 'B2B', custNm: '서울물산', destNm: '서울물산 강남', itemCnt: 3 },
    { seq: 3, headerSeq: 1, outType: '긴급출하', status: '출하완료', outDate: '2026-03-24', outNo: 'OW20260324003', orderNo: 'ORD-20260324-003', custType: 'B2C', custNm: '(주)한국유통', destNm: '(주)한국유통 분당', itemCnt: 8 },
    { seq: 4, headerSeq: 2, outType: '일반출하', status: '출하완료', outDate: '2026-03-24', outNo: 'OW20260324004', orderNo: 'ORD-20260324-004', custType: 'B2B', custNm: '대한상사', destNm: '대한상사', itemCnt: 12 },
    { seq: 5, headerSeq: 3, outType: '일반출하', status: '출하완료', outDate: '2026-03-24', outNo: 'OW20260324005', orderNo: 'ORD-20260324-005', custType: 'B2B', custNm: '(주)신세계', destNm: '(주)신세계 물류', itemCnt: 7 },
    { seq: 6, headerSeq: 3, outType: '긴급출하', status: '출하완료', outDate: '2026-03-24', outNo: 'OW20260324006', orderNo: 'ORD-20260324-006', custType: 'B2C', custNm: '이마트', destNm: '이마트 성수점', itemCnt: 4 },
    { seq: 7, headerSeq: 5, outType: '일반출하', status: '출하완료', outDate: '2026-03-23', outNo: 'OW20260323001', orderNo: 'ORD-20260323-001', custType: 'B2B', custNm: '코스트코', destNm: '코스트코 양재점', itemCnt: 15 },
    { seq: 8, headerSeq: 5, outType: '일반출하', status: '출하완료', outDate: '2026-03-23', outNo: 'OW20260323002', orderNo: 'ORD-20260323-002', custType: 'B2B', custNm: 'GS리테일', destNm: 'GS리테일', itemCnt: 6 },
    { seq: 9, headerSeq: 7, outType: '긴급출하', status: '출하완료', outDate: '2026-03-22', outNo: 'OW20260322001', orderNo: 'ORD-20260322-001', custType: 'B2C', custNm: '(주)한진물류', destNm: '(주)한진물류', itemCnt: 9 },
    { seq: 10, headerSeq: 9, outType: '일반출하', status: '출하완료', outDate: '2026-03-22', outNo: 'OW20260322002', orderNo: 'ORD-20260322-002', custType: 'B2B', custNm: '현대백화점', destNm: '현대백화점 판교점', itemCnt: 2 }
  ],
  orders: [
    { seq: 1, outType: '일반출하', status: '출하완료', outDate: '2026-03-25', outNo: 'OW20260325001', orderNo: 'ORD-20260325-001', custType: 'B2B', custNm: '(주)삼성전자', destNm: '삼성전자 수원', itemCnt: 10, remark: '' },
    { seq: 2, outType: '일반출하', status: '출하완료', outDate: '2026-03-25', outNo: 'OW20260325002', orderNo: 'ORD-20260325-002', custType: 'B2C', custNm: 'LG전자', destNm: 'LG전자 평택', itemCnt: 5, remark: '포장주의' },
    { seq: 3, outType: '긴급출하', status: '출하완료', outDate: '2026-03-25', outNo: 'OW20260325003', orderNo: 'ORD-20260325-003', custType: 'B2B', custNm: 'SK하이닉스', destNm: 'SK하이닉스 이천', itemCnt: 3, remark: '' },
    { seq: 4, outType: '일반출하', status: '출하완료', outDate: '2026-03-25', outNo: 'OW20260325004', orderNo: 'ORD-20260325-004', custType: 'B2B', custNm: '현대자동차', destNm: '현대차 울산', itemCnt: 8, remark: '' },
    { seq: 5, outType: '일반출하', status: '출하완료', outDate: '2026-03-25', outNo: 'OW20260325005', orderNo: 'ORD-20260325-005', custType: 'B2C', custNm: '기아자동차', destNm: '기아 광명', itemCnt: 12, remark: '대형부품' },
    { seq: 6, outType: '긴급출하', status: '출하완료', outDate: '2026-03-25', outNo: 'OW20260325006', orderNo: 'ORD-20260325-006', custType: 'B2B', custNm: '포스코', destNm: '포스코 포항', itemCnt: 4, remark: '' },
    { seq: 7, outType: '일반출하', status: '출하완료', outDate: '2026-03-25', outNo: 'OW20260325007', orderNo: 'ORD-20260325-007', custType: 'B2B', custNm: '한화솔루션', destNm: '한화 여수', itemCnt: 7, remark: '' },
    { seq: 8, outType: '일반출하', status: '출하완료', outDate: '2026-03-25', outNo: 'OW20260325008', orderNo: 'ORD-20260325-008', custType: 'B2C', custNm: '넥센타이어', destNm: '넥센 양산', itemCnt: 6, remark: '취급주의' },
    { seq: 9, outType: '긴급출하', status: '출하완료', outDate: '2026-03-25', outNo: 'OW20260325009', orderNo: 'ORD-20260325-009', custType: 'B2B', custNm: '두산중공업', destNm: '두산 창원', itemCnt: 2, remark: '' },
    { seq: 10, outType: '일반출하', status: '출하완료', outDate: '2026-03-25', outNo: 'OW20260325010', orderNo: 'ORD-20260325-010', custType: 'B2B', custNm: '효성그룹', destNm: '효성 울산', itemCnt: 9, remark: '' },
    { seq: 11, outType: '일반출하', status: '출하완료', outDate: '2026-03-25', outNo: 'OW20260325011', orderNo: 'ORD-20260325-011', custType: 'B2C', custNm: 'CJ제일제당', destNm: 'CJ 인천', itemCnt: 11, remark: '' },
    { seq: 12, outType: '긴급출하', status: '출하완료', outDate: '2026-03-25', outNo: 'OW20260325012', orderNo: 'ORD-20260325-012', custType: 'B2B', custNm: '농심', destNm: '농심 안양', itemCnt: 15, remark: '식품류' },
    { seq: 13, outType: '일반출하', status: '출하완료', outDate: '2026-03-25', outNo: 'OW20260325013', orderNo: 'ORD-20260325-013', custType: 'B2B', custNm: '오뚜기', destNm: '오뚜기 안양', itemCnt: 3, remark: '' },
    { seq: 14, outType: '일반출하', status: '출하완료', outDate: '2026-03-25', outNo: 'OW20260325014', orderNo: 'ORD-20260325-014', custType: 'B2C', custNm: '풀무원', destNm: '풀무원 음성', itemCnt: 7, remark: '냉장' },
    { seq: 15, outType: '긴급출하', status: '출하완료', outDate: '2026-03-25', outNo: 'OW20260325015', orderNo: 'ORD-20260325-015', custType: 'B2B', custNm: '매일유업', destNm: '매일유업 평택', itemCnt: 5, remark: '' }
  ]
};
