# 프롬프트: 결과 그리드에 공통코드 컬럼 표시

`DEV_DOC/fe-ai-prompt/mdct01-prompt.md` 에서 이관·일반화한 버전.

## 케이스 1. API 응답에 코드값 필드가 이미 있을 때

```
[메뉴코드] 결과 그리드에서 [컬럼헤더명] 필드를 공통코드로 표시하고 싶어.

조건:
- API 응답 객체에 코드값 필드: [코드값 필드명]      (예: repCoCd)
- 공통코드 헤더코드(commHCd):   [HCD값]              (예: REP_CO_CD)
- 변환 후 표시할 필드명(commDNm): [표시 필드명]      (예: repCoNm)
- 그리드 dataField:             [dataField값]        (예: repCoNm)
- bizSeq: 각 row의 bizSeq 사용 / [N] 고정 중 선택
- [코드값]은 그리드에 빈값으로 표시 (해당 없으면 생략)

수정 범위:
1. vfn_searchCt()의 commCdList에 변환 항목 추가
2. 그리드 컬럼 dataField 확인 및 필요 시 labelFunction 추가
```

## 케이스 2. API 응답에 코드값 필드가 없을 때 (BE 수정 포함)

```
[메뉴코드] 결과 그리드에서 [컬럼헤더명] 필드를 공통코드로 표시하고 싶어.
API 응답에 [코드값 필드명] 없음, 백엔드도 같이 수정 필요.

백엔드:
- Mapper XML: [파일명] - [쿼리 ID] 쿼리에 [테이블명].[db_column_cd] AS [camelCase 필드명] 추가
- 결과 빈: [파일명]에 private String [camelCase 필드명] 추가

프론트:
- API 응답 코드값 필드: [camelCase 필드명]           (예: repCoCd)
- 공통코드 헤더코드(commHCd):   [HCD값]             (예: REP_CO_CD)
- 변환 후 표시할 필드명(commDNm): [표시 필드명]      (예: repCoNm)
- 그리드 dataField:             [dataField값]        (예: repCoNm)
- bizSeq: 각 row의 bizSeq 사용 / [N] 고정 중 선택
- [코드값]은 그리드에 빈값으로 표시 (해당 없으면 생략)
```

## 참조

- `40-stores/40-commCdStore.md` — convertCommDNms 규약
- `30-components/32-zauigrid.md` — labelFunction
- `60-menus/md8000-mdct01.md` — 실제 적용 예시
