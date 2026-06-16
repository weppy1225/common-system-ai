# 프롬프트: 신규 CRUD 메뉴 생성

거래처(`mdct01`) 같은 표준 리스트+팝업 메뉴를 새로 만들 때 사용.

## 복사용 프롬프트

```
[메뉴코드] [메뉴명] 화면을 만들어줘.

위치:
- views/be/[업무군코드]/[메뉴코드]/
  - [메뉴코드].vue      (리스트)
  - [메뉴코드]Edt.vue   (등록/수정 팝업)

검색 조건:
- [필드1] ([ZText|ZSelect|ZCodeSelect|ZCalendar|ZCalendarRange])
- [필드2] ...

그리드 컬럼:
- [dataField] | [헤더명] | [style: l|c|r] | [width%]
- ...

등록/수정 폼 필드:
- [필드명] (required 여부) (ZText|ZCodeSelect|...)
- ...

복합키: (bizSeq, [메뉴]Seq)

공통코드 변환:
- commHCd=[XXX_CD], commDCd=[xxxCd], commDNm=[xxxNm]
- ...

참고 기준 파일: views/be/md8000/mdct01/mdct01.vue, mdct01Edt.vue
참고 규약: DEV_DOC/ai-docs/20-conventions/21-file-template.md,
         DEV_DOC/ai-docs/50-patterns/50-crud-list-page.md
```

## 작업 시 AI 체크리스트

- [ ] `21-file-template.md` 스켈레톤으로 시작
- [ ] `initSearchXxxObj` / `initEditXxxObj` 분리
- [ ] `searchRef` 사용
- [ ] `onActivated` 에서 bizSeq 변경 감지
- [ ] `Promise.all([convertCommDNms, convertBizCenterNms])`
- [ ] try/catch + `clearGridData` + `errorSwal`
- [ ] 수정 팝업 `openPopup(bizSeq, seq)` 시그니처
- [ ] `emit('vfn_searchXx')` + `closeCallback` 리셋
- [ ] 라우터 등록은 `/new-menu` 범위 밖 — 별도 수행 (`router/modules/be/[업무군].js`)
- [ ] `60-menus/[업무군]-[메뉴코드].md` 문서 추가
