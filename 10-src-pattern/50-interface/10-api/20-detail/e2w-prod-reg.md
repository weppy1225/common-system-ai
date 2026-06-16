---
title: ERP 품목 등록 인터페이스 정의
description: ERP→WMS 품목 등록(E2W_PROD_REG) API Request/Response 필드 및 처리 흐름 참조
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: reference
domain: interface
tags:
  - sif
  - erp
  - e2w
  - prod
  - api-spec
---

# ERP 품목 등록 인터페이스 정의 (ERP Product Registration Interface Definition)

## 1. 품목 등록

| 항목 | 내용 |
|------|------|
| 송신 시스템 | ERP |
| 수신 시스템 | WMS |
| IF 코드 | PROD_REG |
| WMS IF ID | E2W_PROD_REG |
| IF 처리내용 | 품목 신규 등록 및 품목 데이터 수정 |
| IF명 | 품목 등록 |
| HTTP Method | POST |
| Data Type | JSON |
| URI (테스트) | http://192.168.100.51:9090/wms-macro/1/sif/wms/prods/reqs |
| URI (운영) | https://wms.imacro.co.kr:6260/wms-macro/1/sif/wms/prods/reqs |

---

## 2. Request Body

```json
{
"bizSeq": 0,
"reqList": [
    {
      "ifProdId": "string",
      "prodNo": "string",
      "prodNm": "string",
      "prodSize": "string",
      "prodDivCd": "string",
      "prodDivNm": "string",
      "largeCd": "string",
      "largeNm": "string",
      "middleCd": "string",
      "middleNm": "string",
      "smallCd": "string",
      "smallNm": "string",
      "effBaseUnitCd": "string",
      "effBase": 0,
      "unitCd": "string",
      "parentUnitNm": "string",
      "inQtyBox": 0,
      "inQty": 0,
      "prodBarcode": "string",
      "brand1Cd": "string",
      "brand1Nm": "string",
      "brandMng": "string",
      "netWeight": 0,
      "inboxSize": "string",
      "outboxSize": "string",
      "originNm": "string",
      "stndMth": 0,
      "note": "string",
      "useYn": "string"
    }
]
}
```

### 2.1 Request Fields 상세

| LV | 항목 | 항목명 | Type | SIZE | KEY | Null | 설명 | SAP 매핑 |
|----|------|--------|------|------|-----|------|------|----------|
| 1 | bizSeq | 사업장SEQ | number | 10 | | NN | 1: 매크로통상, 2: 성준코퍼레이션 | 1: 매크로통상, 2: 성준코퍼레이션 |
| 1 | reqList | 품목리스트 | | | | | | OITM 테이블 |
| 2 | ifProdId | IF_품목_ID | varchar | 50 | O | NN | | ItemCode |
| 2 | prodNo | 품목번호 | varchar | 30 | | NN | 사업장 내에서 유니크한 값 | ItemCode |
| 2 | prodNm | 품목명 | varchar | 100 | | NN | | ItemName |
| 2 | prodSize | 품목_규격 | varchar | 100(200) | | NN | | U_Spec |
| 2 | prodDivCd | 품목_분류_코드 | varchar | 50 | | NN | 코드 | U_ItemGB |
| 2 | prodDivNm | 품목_분류_명 | varchar | 100 | | NN | 코드명 | |
| 2 | largeCd | 대분류_코드 | varchar | 50 | | NN | 코드 | U_ItemCodeL |
| 2 | largeNm | 대분류_명 | varchar | 100 | | NN | 코드명 | |
| 2 | middleCd | 중분류_코드 | varchar | 50 | | NN | 코드 | U_ItemCodeM |
| 2 | middleNm | 중분류_명 | varchar | 100 | | NN | 코드명 | |
| 2 | smallCd | 소분류_코드 | varchar | 50 | | NN | 코드 | U_ItemCodeS |
| 2 | smallNm | 소분류_명 | varchar | 100 | | NN | 코드명 | |
| 2 | effBaseUnitCd | 유효기준_기준단위 | varchar | 50 | | NN | 코드<br>연: 'Y'<br>월: 'M'<br>일: 'D'(기본값) | U_DayType |
| 2 | effBase | 유효기준 | number | 10 | | NN | 기본(365) | U_MatlPrid |
| 2 | unitCd | 단위_코드 | varchar | 50 | | NN | 코드 | EA |
| 2 | parentUnitNm | 상위_단위_명 | varchar | 100 | | | 텍스트 값 (기본 'OBOX') | OBOX |
| 2 | inQtyBox | 입수량(BOX) | number | 10 | | NN | 1 | NumInSale, NumInBuy |
| 2 | inQty | 입수량 | number | 10 | | NN | 1 | 이너박스 수량 |
| 2 | prodBarcode | 품목_바코드 | varchar | 100(254) | | | | CodeBars |
| 2 | brand1Cd | 브랜드1_코드 | varchar | 50 | | NN | 코드 | U_BRAND01 |
| 2 | brand1Nm | 브랜드1_명 | varchar | 100 | | | 코드명 | |
| 2 | brandMng | 브랜드 담당자 | varchar | 100 | | | 브랜드 담당자의 사원명 | U_StockCod (Name으로 표시) |
| 2 | netWeight | 순중량 | number | 10 | | | | U_NetWeight |
| 2 | inboxSize | 인박스_사이즈 | varchar | 100 | | NN | | OITM / 사용자필드 |
| 2 | outboxSize | 아웃박스_사이즈 | varchar | 100 | | NN | | OITM / 사용자필드 |
| 2 | originNm | 원산지_명 | varchar | 100 | | | 코드명 | U_ITMORIGIN |
| 2 | stndMth | 기준월수 | number | 10 | | NN | default: 0.00<br>WMS에서 소수점 1자리에서 내림 처리 | U_STNDMTH (소수점2자리) |
| 2 | note | 비고 | varchar | 1000 | | | | UserText |
| 2 | useYn | 사용여부 | char | 1 | | NN | 코드화: 'N' / 'Y' (기본 'Y') | 활성(Y) / 비활성(N) |

---

## 3. Response Body

```json
{
"httpResult": "string",
"httpMessage": "string",
"resultList": [
    {
      "ifProdId": "string",
      "result": "string",
      "message": "string"
    }
]
}
```

### 3.1 Response Fields 상세

| LV | 항목 | 항목명 | Type | SIZE | KEY | Null | 설명 |
|----|------|--------|------|------|-----|------|------|
| 1 | httpResult | HTTP 응답 상태 코드 | varchar | 20 | | NN | S: 성공, E: 실패 |
| 1 | httpMessage | 메세지 | varchar | 4000 | | NN | 에러메세지 |
| 1 | resultList | 요청리스트 | | | | | |
| 2 | ifProdId | IF_품목_ID | varchar | 20 | O | NN | WMS와 외부 프로그램의 유니크 키 |
| 2 | result | 처리 여부 | varchar | 1 | | NN | S: 성공, E: 실패 |
| 2 | message | 처리 메시지 | varchar | 100 | | | 처리 실패시 실패 사유 |

---

## 4. 비고

- **stndMth**: ERP에서 소수점 2자리로 전송, WMS에서 수신 시 소수점 1자리로 변경(내림처리)
