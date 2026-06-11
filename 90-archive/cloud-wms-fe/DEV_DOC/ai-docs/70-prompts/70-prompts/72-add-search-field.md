# 프롬프트: 검색 조건 추가

## 복사용

```
[메뉴코드] 검색 영역에 [필드명] 검색 조건을 추가해줘.

- 라벨: [라벨명]
- 타입: [ZText | ZSelect | ZCodeSelect | ZCodeMulti | ZCalendar | ZCalendarRange]
- 필드명(searchXxxObj): [camelCase]
- 초기값: [null | 'Y' | ...]
- 공통코드(해당시): commCd=[XXX_CD]
- 위치: [기존필드] 다음 / 마지막
- cols: [3|5] (기존 ZCellBox 의 cols 와 맞춤)

BE 요청:
- [메뉴코드]Mapper.xml 의 검색 WHERE 절에 [조건] 추가 필요
```

## 주의

- `initSearchXxxObj` 에 새 필드 추가 (null 또는 기본값)
- BE 에 전달되는 body 는 `searchXxxObj.value` 전체이므로 Mapper 에 `<if test="xxx != null">` 분기 추가 필요
- `ZCodeMulti` 는 복수형 필드명(`xxxCds`) 으로 배열 사용
