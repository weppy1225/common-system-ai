/* mdct01 테스트 데이터 */
const MDCT01_DATA = {
  main: [
    { site: '본사', cpctNo: 'CPCT-0001', cpctNm: '㈜삼성전자유통', ifCpctId: 'IF-SE001', cpctDiv: '1', cpctDivNm: '매입', repCont: 'RC001', repContNm: '미설정', ceoNm: '김철수', bizNo: '123-45-67890', bizType: '도소매', bizItem: '전자제품', tel: '02-1234-5678', fax: '02-1234-5679', email: 'se@samsung.com', addr: '서울시 강남구 삼성로 1234', addrDetail: '5층', useYn: 'Y', remark: '' },
    { site: '본사', cpctNo: 'CPCT-0002', cpctNm: '㈜신세계이마트', ifCpctId: 'IF-EM002', cpctDiv: '2', cpctDivNm: '직영점', repCont: 'RC002', repContNm: '㈜신세계이마트', ceoNm: '이영희', bizNo: '234-56-78901', bizType: '소매', bizItem: '종합소매', tel: '02-2345-6789', fax: '02-2345-6790', email: 'info@emart.com', addr: '서울시 종로구 새문안로 55', addrDetail: '', useYn: 'Y', remark: '' },
    { site: '본사', cpctNo: 'CPCT-0003', cpctNm: '롯데쇼핑㈜', ifCpctId: 'IF-LS003', cpctDiv: '3', cpctDivNm: '할인점', repCont: 'RC004', repContNm: '롯데쇼핑㈜', ceoNm: '박민수', bizNo: '345-67-89012', bizType: '소매', bizItem: '종합소매', tel: '02-3456-7890', fax: '02-3456-7891', email: 'lotte@lotte.com', addr: '서울시 송파구 올림픽로 300', addrDetail: '', useYn: 'Y', remark: '' },
    { site: '본사', cpctNo: 'CPCT-0004', cpctNm: '쿠팡㈜', ifCpctId: 'IF-CP004', cpctDiv: '5', cpctDivNm: '쿠팡', repCont: 'RC001', repContNm: '미설정', ceoNm: '강대중', bizNo: '456-78-90123', bizType: '통신판매', bizItem: '온라인유통', tel: '1577-7011', fax: '', email: 'biz@coupang.com', addr: '서울시 송파구 올림픽로 35길 123', addrDetail: '쿠팡빌딩', useYn: 'Y', remark: '온라인 채널' },
    { site: '본사', cpctNo: 'CPCT-0005', cpctNm: '홈플러스㈜', ifCpctId: 'IF-HP005', cpctDiv: '3', cpctDivNm: '할인점', repCont: 'RC005', repContNm: '홈플러스', ceoNm: '최윤호', bizNo: '567-89-01234', bizType: '소매', bizItem: '대형마트', tel: '02-5678-9012', fax: '02-5678-9013', email: 'vend@homeplus.co.kr', addr: '서울시 영등포구 양평로 240', addrDetail: '', useYn: 'Y', remark: '' },
    { site: '본사', cpctNo: 'CPCT-0006', cpctNm: '㈜GS리테일', ifCpctId: 'IF-GS006', cpctDiv: '2', cpctDivNm: '직영점', repCont: 'RC006', repContNm: 'GS', ceoNm: '정미래', bizNo: '678-90-12345', bizType: '소매', bizItem: '편의점', tel: '02-6789-0123', fax: '02-6789-0124', email: 'vend@gsretail.com', addr: '서울시 강남구 논현로 508', addrDetail: '', useYn: 'Y', remark: '' },
    { site: '본사', cpctNo: 'CPCT-0007', cpctNm: '건담존㈜', ifCpctId: 'IF-GZ007', cpctDiv: '4', cpctDivNm: '온라인', repCont: 'RC003', repContNm: '건담존', ceoNm: '임우진', bizNo: '789-01-23456', bizType: '소매', bizItem: '완구모형', tel: '02-7890-1234', fax: '', email: 'b2b@gundamzone.co.kr', addr: '경기도 고양시 덕양구 화정로 100', addrDetail: '2층', useYn: 'Y', remark: '' },
    { site: '본사', cpctNo: 'CPCT-0008', cpctNm: '㈜텐바이텐', ifCpctId: 'IF-TB008', cpctDiv: '4', cpctDivNm: '온라인', repCont: 'RC001', repContNm: '미설정', ceoNm: '한소영', bizNo: '890-12-34567', bizType: '통신판매', bizItem: '잡화류', tel: '02-8901-2345', fax: '02-8901-2346', email: 'cs@10x10.co.kr', addr: '서울시 마포구 양화로 45', addrDetail: '', useYn: 'Y', remark: '' },
    { site: '본사', cpctNo: 'CPCT-0009', cpctNm: '㈜글로벌유통', ifCpctId: 'IF-GL009', cpctDiv: '6', cpctDivNm: '총판', repCont: 'RC001', repContNm: '미설정', ceoNm: '서민준', bizNo: '901-23-45678', bizType: '도매', bizItem: '종합유통', tel: '031-9012-3456', fax: '031-9012-3457', email: 'global@globalco.kr', addr: '경기도 성남시 분당구 판교역로 100', addrDetail: '10층', useYn: 'Y', remark: '총판 거래처' },
    { site: '본사', cpctNo: 'CPCT-0010', cpctNm: '㈜미래무역', ifCpctId: 'IF-MR010', cpctDiv: '9', cpctDivNm: '기타', repCont: 'RC001', repContNm: '미설정', ceoNm: '오진형', bizNo: '012-34-56789', bizType: '무역', bizItem: '수출입', tel: '02-0123-4567', fax: '02-0123-4568', email: 'trade@mirae.com', addr: '서울시 중구 을지로 200', addrDetail: '', useYn: 'N', remark: '미사용 처리' },
    { site: '창고1', cpctNo: 'CPCT-0011', cpctNm: '㈜케이마트', ifCpctId: 'IF-KM011', cpctDiv: '3', cpctDivNm: '할인점', repCont: 'RC001', repContNm: '미설정', ceoNm: '윤재영', bizNo: '123-45-11111', bizType: '소매', bizItem: '대형마트', tel: '051-1111-2222', fax: '051-1111-2223', email: 'kmart@kmart.co.kr', addr: '부산시 해운대구 해운대로 500', addrDetail: '', useYn: 'Y', remark: '' },
    { site: '창고1', cpctNo: 'CPCT-0012', cpctNm: '㈜아이마켓', ifCpctId: 'IF-IM012', cpctDiv: '4', cpctDivNm: '온라인', repCont: 'RC001', repContNm: '미설정', ceoNm: '방선애', bizNo: '234-56-22222', bizType: '통신판매', bizItem: '종합유통', tel: '051-2222-3333', fax: '', email: 'imarket@imarket.co.kr', addr: '부산시 부산진구 중앙대로 200', addrDetail: '3층', useYn: 'Y', remark: '' }
  ],
  labelPaper: [
    { no: 1, nm: 'A4 일반용지' },
    { no: 2, nm: 'A4 라벨지 (21칸)' },
    { no: 3, nm: 'A4 라벨지 (24칸)' },
    { no: 4, nm: '바코드 라벨 (50×30mm)' },
    { no: 5, nm: '바코드 라벨 (70×40mm)' },
    { no: 6, nm: '송장 라벨 (100×150mm)' }
  ]
};
