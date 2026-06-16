# {메뉴코드} {메뉴명}

> `60-menus/` 에 새 메뉴 문서 추가 시 이 템플릿을 복사.

## 1. 업무 개요

- **역할**: (업무 담당자 관점 1-3줄)
- **주요 사용자**: (창고 관리자 / 입출고 담당자 등)
- **빈도**: (일 N회 / 마감시 / 상시)

## 2. 화면 구성

| 파일 | 역할 |
| --- | --- |
| `views/be/{업무군}/{메뉴}/{메뉴}.vue` | 리스트 |
| `views/be/{업무군}/{메뉴}/{메뉴}Edt.vue` | 등록/수정 팝업 |
| `views/be/{업무군}/{메뉴}/{메뉴}Lbs.vue` | 라벨 (있다면) |

## 3. API 매핑

> BE 원본: `../cloud-wms-be/DEV_DOC/ai-docs/20-backend/80-spec/{메뉴}/` — `70-prompts/74-sync-be-spec.md` 로 §3/§9 동기화.

| 기능 | FE 호출 | BE Controller | Mapper XML |
| --- | --- | --- | --- |
| 리스트 | `POST /{메뉴}/{리소스}` | `XxxController.search` | `XxxMapper.xml / selectXxxList` |
| 단건 | `GET /{메뉴}/{리소스}/{리소스Seq}/{bizSeq}` | `.detail` | `.selectXxx` |
| 등록 | `PUT /{메뉴}/{리소스}` | `.insert` | `.insertXxx` |
| 수정 | `PATCH /{메뉴}/{리소스}` | `.update` | `.updateXxx` |
| 삭제 | `DELETE /{메뉴}/{리소스}` | `.delete` | `.deleteXxx` |

BE 경로는 `C:\zinide\cloud-wms-be\src\...` 기준. FE 표준은 `../10-architecture/13-be-fe-contract.md` §1 참조.

## 4. 사용 공통코드

| commHCd | 의미 | 사용 위치 |
| --- | --- | --- |
| `USE_YN` | 사용여부 | 검색/편집 |
| `XXX_CD` | - | - |

## 5. 데이터 변환 목록

`vfn_searchXx` 내 `commCdList`:
```js
const commCdList = [
    { commHCd: 'XXX_CD', commDCd: 'xxxCd', commDNm: 'xxxNm' },
];
```

## 6. 특수 로직 / 주의사항

- (이 메뉴만의 제약이나 숨은 규칙을 기록)
- (예: 특정 권한에서만 삭제 가능, 마감일 이후엔 수정 불가 등)

## 7. 관련 메뉴 / 연동

- 상위: -
- 하위: -
- 연동: -

## 8. 알려진 이슈 / TODO

- 

## 9. BE 동기화

- 최근 동기화: `{YYYY-MM-DD}`
- BE 원본: `../cloud-wms-be/DEV_DOC/ai-docs/20-backend/80-spec/{메뉴}/{YYYYMMDD}_output.md`
- 재동기화 시 `70-prompts/74-sync-be-spec.md` 실행
