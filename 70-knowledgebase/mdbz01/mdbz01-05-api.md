---
title: MDBZ01 API 명세 (FE·BE 공용)
description: mdbz01 사업장의 REST API 명세. FE/BE가 함께 참조하는 단일 계약 문서.
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: spec
menu_code: mdbz01
domain: master
depends_on:
  - "70-knowledgebase/mdbz01/mdbz01-02-screen.md"
  - "70-knowledgebase/mdbz01/mdbz01-03-data-model.md"
related:
  - "70-knowledgebase/mdbz01/mdbz01-06-be-flow.md"
  - "70-knowledgebase/mdbz01/mdbz01-07-fe-flow.md"
tags: [detail-design, api, master]
---

# MDBZ01 API 명세 (FE·BE 공용)

## 1. Base 경로

```
Controller @RequestMapping: /{bizSeq}/mdbz01/bizs
```

- `{bizSeq}`: 로그인 사용자가 소속된 사업장 SEQ (JWT 토큰에서 추출)
- FE(Vue)는 axios 인터셉터에서 `/{bizSeq}` prefix를 자동 삽입하므로, FE 소스 코드의 URL은 `/mdbz01/bizs/...` 형태로 표기됨

---

## 2. 엔드포인트 목록 (FE 호출 확인됨)

| 업무 | HTTP | URL (서버 기준, /{bizSeq} prefix 포함) | 호출 화면 | 요청·응답 비고 |
|---|---|---|---|---|
| 수정 가능 사업장 목록 조회 | GET | `/{bizSeq}/mdbz01/bizs/editable/bizs/{regBizSeq}` | 메인 (화면 진입 시) | 응답: `bizList` 목록 |
| 사업장 단건 조회 | GET | `/{bizSeq}/mdbz01/bizs/{selectedBizSeq}` | 메인 (사업장 선택 시) | 응답: `biz` 단건 객체 |
| 사업장 정보 수정 | POST | `/{bizSeq}/mdbz01/bizs` | 메인 (저장 버튼) | 요청: multipart/form-data (이미지 파일 포함 가능). 응답: `procCnt` |
| 사업장 센터 목록 조회 | GET | `/{bizSeq}/mdbz01/bizs/{selectedBizSeq}/centers` | 메인 (사업장 선택 시) | 응답: `bizCenter` 목록 |
| 물류센터 저장 (추가·수정·삭제) | PUT | `/{bizSeq}/mdbz01/bizs/centers` | 메인 (센터 저장 버튼) | 요청: `{insertList, updateList, deleteList}`. 응답: `succeed` 여부 |
| 자사 위탁 센터 조회 (팝업) | GET | `/{bizSeq}/mdbz01/bizs/tpl` | MDBZ01P01 (팝업 열기) | 응답: `bizCenter` 목록 |
| 위탁 센터 정보 수정 | PATCH | `/{bizSeq}/mdbz01/bizs/tpl` | MDBZ01P01 (저장 버튼) | 요청: `{updateList}`. 응답: `procCnt` |
| 물류대행업체 검색 | POST | `/{bizSeq}/mdbz01/bizs/tpl` | MDBZ01P02 (검색 버튼) | 요청: `{bizNm, centerNm, addr}`. 응답: `bizCenter` 목록 (reqSts 포함) |
| 위탁 의뢰 신청 | PUT | `/{bizSeq}/mdbz01/bizs/tpl` | MDBZ01P02 (위탁 요청 버튼) | 요청: `{checkedList, note}`. 응답: `procCnt` |

---

## 3. 🟠 FE 미호출 엔드포인트 (Controller에 존재하나 Vue에서 호출 없음)

| 업무 | HTTP | URL | 비고 |
|---|---|---|---|
| 대행의뢰신청업체 조회 | GET | `/{bizSeq}/mdbz01/bizs/{selCenterSeq}/tplReq` | FE에 호출 코드 없음 |
| 대행의뢰 수락/거절 | PATCH | `/{bizSeq}/mdbz01/bizs/{selBizSeq}/tplReq` | FE에 호출 코드 없음 |
| 의뢰 취소 (의뢰자) | PATCH | `/{bizSeq}/mdbz01/bizs/cancel` | FE에 호출 코드 없음 |

> 위 API는 삭제하지 말고, 사용 여부를 업무 담당자에게 확인 필요. 대행의뢰 수락·거절·취소 화면이 별도 구현되었을 가능성 있음.

---

## 4. 주요 요청/응답 필드

### 사업장 (MDBZ01Biz)

| 필드 | 설명 | 비고 |
|---|---|---|
| bizSeq | 사업장 고유 번호 | PK |
| bizNm | 사업장명 | 필수 |
| bizNmShort | 사업장명 약칭 | |
| ceoNm | 대표자명 | |
| bizNo | 사업자등록번호 | |
| subBizNo | 종사업자번호 | |
| bizType | 업태 | |
| bizItem | 종목 | |
| bizDivCd | 사업장구분 코드 | OWN / TPL / SHIPPER |
| email | 이메일 | |
| tel | 전화번호 | |
| fax | 팩스 | |
| postNo | 우편번호 | |
| addr | 주소 | |
| addrDtl | 주소상세 | |
| logoFileSeq | 로고 파일 번호 | 파일 서버 참조 키 |
| bizColor | 사업장 테마색 | 기본값 #00afec |
| note | 비고 | |
| useYn | 사용여부 | Y / N |
| filePath | 로고 이미지 URL | 응답 시 URL로 변환하여 전달 |
| fileNm | 로고 파일명 | 응답 전용 |
| fileExtension | 로고 파일 확장자 | 응답 전용 |
| refBizSeq | 상위 사업장 번호 | 위탁 의뢰 처리 시 사용 |
| modId | 수정자 ID | JWT 토큰에서 자동 설정 |

### 물류센터 (MDBZ01Center)

| 필드 | 설명 | 비고 |
|---|---|---|
| centerSeq | 센터 고유 번호 | PK |
| bizSeq | 사업장 번호 | FK |
| regBizSeq | 등록 사업장 번호 | 센터를 등록한 사업장 |
| centerNm | 센터명 | 필수 |
| tel | 전화번호 | 물류대행 시 필수 |
| email | 이메일 | |
| postNo | 우편번호 | |
| addr | 주소 | |
| addrDtl | 주소상세 | 물류대행 시 필수 |
| note | 비고 | |
| useYn | 사용여부 | Y / N |
| tplYn | 물류대행 여부 | Y / N |
| tplCenterYn | 위탁 센터 여부 | Y=타사 위탁, N=자사 |
| cfmYn | 승인여부 | Y / N |
| editableYn | 수정 가능 여부 | 응답 전용. 본인 사업장 등록 센터면 Y |
| authCnt | 승인된 위탁 계약 수 | 응답 전용 |
| unauthCnt | 미승인 위탁 계약 수 | 응답 전용 |
| reqSts | 의뢰 상태 | 검색 결과에서만 사용. 신청 가능/신청중/승인/거절 |
| mineYn | 자사 센터 여부 | 대행의뢰신청업체 조회 응답 전용 |

### 검색 조건 (MDBZ01Search)

| 필드 | 설명 | 비고 |
|---|---|---|
| bizNm | 사업장명 (부분 검색) | 물류대행업체 검색 팝업 |
| centerNm | 센터명 (부분 검색) | 물류대행업체 검색 팝업 |
| addr | 주소 (부분 검색) | 물류대행업체 검색 팝업 |
| userId | 사용자 ID | 서버에서 자동 설정 (FE 미전송) |

### 센터 저장 요청 (MDBZ01SaveCenter)

| 필드 | 설명 | 비고 |
|---|---|---|
| insertList | 추가할 센터 목록 | |
| updateList | 수정할 센터 목록 | |
| deleteList | 삭제할 센터 목록 | |
| checkedList | 선택된 센터 목록 | 위탁 의뢰 신청 시 사용 |
| note | 요청 내용 | 위탁 의뢰 신청 메시지 |

---

## 5. 설계 포인트

- **사업장 수정 API가 POST인 이유**: multipart/form-data (파일 업로드)를 처리하기 위해 POST 방식 사용. RESTful 관점에서는 PUT/PATCH가 맞으나, 파일 전송 편의를 위해 POST 채택.
- **GET /tpl과 POST /tpl, PUT /tpl, PATCH /tpl의 같은 경로 공유**: 같은 `/tpl` 경로에 HTTP 메서드로 기능을 구분. GET=자사 위탁 센터 조회, POST=업체 검색, PUT=의뢰 신청, PATCH=위탁 센터 정보 수정.
- **수정 가능 사업장 목록 조회 시 권한 분기**: 권한 유형(슈퍼/사업장/센터)에 따라 서버에서 필터링하여 반환. FE는 반환된 목록을 드롭다운으로 표시.
- **센터 저장은 추가·수정·삭제를 단일 API로 처리**: 그리드에서 변경된 행을 분류하여 하나의 PUT 요청으로 일괄 전송.
