# 프롬프트: 그리드에 컬럼 추가

## 복사용

```
[메뉴코드] 결과 그리드에 [헤더명] 컬럼을 추가해줘.

- dataField: [필드명]
- style: [gridTxt-l | gridTxt-c | gridTxt-r]
- width: [N%]
- 위치: [기존컬럼] 뒤에 / 맨 끝
- filter: [있음|없음]
- 공통코드 변환 필요: [Y/N, Y면 commHCd=XXX, commDCd=xxxCd, commDNm=xxxNm]

API 응답에 해당 필드 존재 여부: [Y|N, N이면 BE Mapper XML 수정 필요]
```

## 주의

- 공통코드 변환이 필요하면 `vfn_searchXx` 의 `commCdList` 에 **반드시** 항목 추가
- BE 응답에 필드가 없으면 BE Mapper `SELECT` 에 `AS camelCaseField` 추가 요청
- `labelFunction` 은 색상/아이콘 등 HTML 렌더링이 필요할 때만 사용
