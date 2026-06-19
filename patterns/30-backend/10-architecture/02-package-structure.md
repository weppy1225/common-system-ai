---
title: 백엔드 패키지 구조
description: cloud-wms-be의 Java 소스 패키지 구조(be/bm/fw/sif/test/vm)와 파일 명명 규칙을 참조할 때 사용
status: active
version: 1.0.0
wms_meta: true
repo_role: ai-hub
agent_usage: reference
domain: backend
tags:
  - package-structure
  - java
  - naming-convention
  - mybatis
---

# 백엔드 패키지 구조 (Backend Package Structure)

## 문서 개요
- **프로젝트**: cloud-wms-be (Spring MVC 기반 WMS 시스템)
- **최종 업데이트**: 2026년 2월 23일
- **범위**: 전체 소스 구조, 패키지 구성, 파일 위치, 명명 규칙

---

## 1. 프로젝트 루트 구조

```
cloud-wms-be/
├── src/
│ ├── main/
│ │ ├── java/ # Java 소스 (be, bm, fw, sif, test, vm)
│ │ └── resources/ # 리소스 파일 (cache, messages, prop, mapper)
│ ├── build/ # 빌드 출력
│ └── lib-test/ # 테스트 라이브러리
├── DEV_DOC/ # 개발 문서
├── build.xml # Ant 빌드 스크립트
├── Jenkinsfile # CI/CD 파이프라인 (운영)
├── Jenkinsfile-test # CI/CD 파이프라인 (테스트)
└── .git/ # Git 저장소
```

---

## 2. src/main/java (Java 소스 패키지)

### 2.1 `be` 패키지 (백오피스 관리자 웹)

#### 개요
- 백오피스(관리자) 화면용 컨트롤러, 서비스, bean, mapper 인터페이스
- 메뉴 구조와 1:1 매핑 (메뉴코드 = 패키지명)
- `abc`는 공통(common) 패키지로 가시성을 위해 최상단 배치

#### 패키지 구조
```
be/
├── abc/ # 공통 관리자메뉴
│
├── cm9400/ # 소통관리
│ └── alst01/ # 알람설정
│     ├── ALST01Controller.java
│     ├── ALST01Comp.java
│     ├── ALST01TxComp.java
│     ├── ALST01Dao.java
│     ├── ALST01Mapper.java
│     ├── ALST01Mapper.xml
│     └── bean/
│
├── iw1000/ # 입고관리
│ ├── iwlb01/ # 라벨품목
│ ├── iwpc01/ # 입고처리
│ ├── iwrq01/ # 입고예정
│ └── iwsc01/ # 입고현황
│ 각 모듈은 메뉴 패키지 바로 아래에 Controller/Comp/TxComp/Dao/Mapper/XML/bean 이 평면 배치
│
├── rt2000/ # 반품관리
│ ├── rtpc01/ # 반품처리
│ └── rtrq01/ # 반품예정
│
├── iv3000/ # 재고관리
│ ├── ivad01/ # 재고조정
│ ├── ivexrq01/ # 예외출고
│ ├── ivmv01/ # 재고이동
│ ├── ivmvrq01/ # 재고이동요청
│ ├── ivsk01/ # SKU변경
│ ├── ivst01/ # 세트작업
│ ├── skmg01/ # 파렛트병합
│ └── sksp01/ # 파렛트분할
│
├── iv3100/ # 재고조회
│ ├── ivio01/ # 수불조회
│ ├── ivmc01/ # 재고마감
│ ├── ivpd01/ # 재고조회(품목별)
│ ├── ivpr01/ # 재고조회(기간별)
│ ├── ivwh01/ # 재고조회(창고별)
│ └── skht01/ # SKU이력조회
│
├── iv3200/ # 재고실사
│ ├── stcp01/ # 실사재고비교
│ ├── strg01/ # 실사재고등록
│ └── stsc01/ # 재고실사일정등록
│
├── ow5000/ # 출고관리
│ ├── dlcx01/ # 송장처리취소
│ ├── dlpb01/ # 송장발행
│ ├── dlpc01/ # 송장처리
│ ├── dlpc02/ # 송장처리(바코드)
│ ├── ldpc01/ # 상차처리
│ ├── obpc01/ # 출하처리
│ ├── obrq01/ # 출하예정
│ ├── obsc01/ # 출하현황
│ ├── owpc01/ # 출고처리
│ ├── owrq01/ # 출고지시
│ ├── owrb01/ # 출고지시
│ └── owrc01/ # 출고지시(송장)
│
├── md8000/ # 기준정보
│ ├── mdbz01/ # 사업장
│ ├── mdcp01/ # 업체품목
│ ├── mdcr01/ # 차량
│ ├── mdct01/ # 거래처
│ ├── mdlc01/ # 위치
│ ├── mdpd01/ # 품목 (상세)
│ ├── mdsp01/ # 화주
│ ├── mdst01/ # 세트구성
│ ├── mdus01/ # 사용자
│ └── mdwh01/ # 창고
│
├── sm9000/ # 시스템설정
│ ├── alsh01/ # 알람조회
│ ├── lpst01/ # 출력물설정
│ ├── mnst01/ # 메뉴별설정
│ ├── obst01/ # 출하설정
│ ├── pdst01/ # 품목설정
│ ├── scst01/ # 보안설정
│ ├── smmg01/ # 권한그룹
│ ├── smst01/ # SSE전송
│ └── uscd01/ # 사용자코드
│
├── if9100/ # IF관리
│ ├── dvst01/ # 택배사설정
│ ├── ifbh01/ # I/F처리이력
│ └── ifst01/ # I/F설정
│
├── mm9200/ # 운영관리
│ ├── mdlp01/ # 출력물관리
│ ├── scch01/ # 스케쥴러 변경이력
│ ├── scex01/ # 스케쥴러 실행이력
│ ├── scrg01/ # 스케쥴러
│ ├── smcc01/ # 공통코드
│ └── smmn01/ # 메뉴별설정
│
└── ss9300/ # 시스템현황
    ├── lgap01/          # 시스템API로그
    ├── lgco01/          # 시스템접근로그
    ├── lger01/          # 시스템에러로그
    ├── lgmn01/          # 시스템메뉴로그
    └── smbd01/          # 고객문의
```

#### MDPD01(품목관리) 상세 구조
```
be/md8000/mdpd01/
├── bean/ # VO/DTO
│ ├── MDPD01Prod.java
│ ├── MDPD01Search.java
│ ├── MDPD01Label.java
│ └── MDPD01PrintLabel.java
│
├── excel/ # 엑셀 업로드/다운로드
│ ├── bean/
│ │ └── MDPD01ExcelBean.java
│ ├── MDPD01ExcelComp.java
│ ├── MDPD01ExcelCompUtil.java
│ ├── MDPD01ExcelController.java
│ ├── MDPD01ExcelDao.java
│ ├── MDPD01ExcelMapper.java # 매퍼 인터페이스
│ ├── MDPD01ExcelTxComp.java
│ └── MDPD01ExcelMapper.xml # XML 매퍼 (주의: Java 소스에 위치)
│
├── test/ # 단위 테스트 (모듈 내)
│ ├── ZTEST_MDPD01Comp.java
│ ├── ZTEST_MDPD01Controller.java
│ ├── ZTEST_MDPD01Dao.java
│ ├── ZTEST_MDPD01Mapper.java
│ ├── ZTEST_MDPD01Prod.java
│ └── ZTEST_SUITE_MDPD01.java
│
├── vm/ # Velocity 출력물 템플릿
│ ├── 거래명세표.vm
│ ├── 입고지시서.vm
│ ├── 출고지시서.vm
│ ├── 위치라벨.vm
│ └── 품목라벨.vm
│
├── MDPD01Comp.java
├── MDPD01CompUtil.java
├── MDPD01Controller.java
├── MDPD01Dao.java
├── MDPD01Mapper.java # 메인 매퍼 인터페이스
├── MDPD01TxComp.java
├── MDPDLaberPaperType.java
├── MDPDP01Controller.java
└── MDPDP01Mapper.xml # XML 매퍼 (주의: Java 소스에 위치)
```

---

### 2.2 `bm` 패키지 (모바일 웹)

#### 개요
- 모바일 화면용 컨트롤러, 서비스, bean, 매퍼
- 메뉴코드 뒤에 'm' 접미사 (예: iw1000m)

#### 패키지 구조
```
bm/
├── iw1000m/ # 입고관리 모바일
│ └── iwpc01m/ # 입고
│ ├── controller/
│ ├── service/
│ ├── bean/
│ └── mapper/
│
├── rt2000m/ # 반품관리 모바일
│ └── rtpc01m/ # 반품
│
├── iv3000m/ # 재고관리 모바일
│ ├── ivad01m/ # 재고조정
│ ├── ivmv01m/ # 재고이동
│ ├── ivmvrq01m/ # 재고이동요청
│ ├── skmg01m/ # 파렛트병합
│ └── sksp01m/ # 파렛트분할
│
├── iv3100m/ # 재고조회 모바일
│ └── brsc01m/ # 재고조회
│
├── iv3200m/ # 재고실사 모바일
│ ├── strg01m/ # 실사재고등록
│ └── stsc01m/ # 재고실사일정
│
├── ow5000m/ # 출고관리 모바일
│ ├── dlpc01m/ # 송장처리
│ ├── ldpc01m/ # 상차
│ ├── obpc01m/ # 출하처리
│ ├── obrq01m/ # 출하목록
│ └── owpc01m/ # 출고처리
│
├── md8000m/ # 기준정보 모바일
│ └── mdbz01m/ # 사업장
│
└── sm9000m/ # 시스템설정 모바일
    ├── alsh01m/         # 알람조회
    ├── alst01m/         # 알람설정
    └── smst01m/         # 설정
```

---

### 2.3 `fw` 패키지 (프레임워크/공통)

#### 개요
- 프로젝트 전반에서 사용하는 공통 유틸리티, 설정, 상수

#### 패키지 구조
```
fw/
├── advice/ # AOP 어드바이스
├── annotation/ # 커스텀 어노테이션
├── aop/ # AOP 설정
├── auth/ # 인증
│ ├── apikey/ # API Key 인증
│ └── token/ # JWT 토큰
├── bean/ # 공통 빈
│ ├── BaseParam.java # 페이징/정렬 기본 파라미터
│ └── ValidError.java # 유효성 검증 에러
├── common/ # 공통 기능
├── config/ # 설정 클래스
│ ├── AppConfig.java
│ ├── DBConfig.java # DB 함수 prefix 등
│ ├── EhCacheConfig.java
│ ├── FtpConfig.java
│ ├── JwtConfig.java
│ ├── QuartzConfig.java
│ └── SecurityConfig.java
├── constant/ # 상수
│ ├── StringPool.java
│ └── WMSPool.java # 시스템 전체 상수
├── controller/ # 공통 컨트롤러
├── exception/ # 예외 처리
├── filter/ # 필터
├── interceptor/ # 인터셉터
├── listener/ # 리스너
├── login/ # 로그인/사용자
│ └── UserDetails.java
├── mybatis/ # MyBatis 커스텀 설정
├── scheduler/ # 스케줄러
├── tool/ # 유틸리티 도구
│ ├── CryptoTool.java # 암호화
│ ├── DateTool.java # 날짜 처리
│ ├── EmptyTool.java # Null/공백 체크
│ └── StringTool.java # 문자열 처리
└── websocket/ # 웹소켓 (SSE)
```

---

### 2.4 `sif` 패키지 (레거시 시스템 인터페이스)

#### 개요
- 레거시 시스템 연동 (ERP, 택배사, OMS 등)
- `e2w`: ERP → WMS (ERP에서 WMS API 호출)
- `w2e`: WMS → ERP (WMS에서 ERP로 결과 전송)

#### 패키지 구조
```
sif/
├── abc/ # 인터페이스 전체 공통
│
├── erp/ # ERP 연동 (중심)
│ ├── abc/ # ERP 전체 공통
│ │
│ ├── e2w/ # ERP → WMS
│ │ ├── abc/ # e2w 공통
│ │ │ ├── E2WAbcAspect.java
│ │ │ ├── E2WAbcComp.java
│ │ │ ├── E2WAbcCompUtil.java
│ │ │ ├── E2WAbcDao.java
│ │ │ ├── E2WAbcMapper.java
│ │ │ ├── E2WAbcPool.java
│ │ │ ├── E2WAbcProd.java
│ │ │ ├── E2WAbcReq.java
│ │ │ ├── E2WAbcRequestBody.java
│ │ │ ├── E2WAbcRes.java
│ │ │ ├── E2WAbcResponseBody.java
│ │ │ ├── E2WAbcTable.java
│ │ │ ├── E2WAbcValidCont.java
│ │ │ ├── E2WAbcValidProd.java
│ │ │ └── E2WAbcMapper.xml # XML 매퍼 (Java 소스)
│ │ │
│ │ ├── cont_del/ # 거래처 삭제
│ │ ├── cont_mod/ # 거래처 수정
│ │ ├── cont_reg/ # 거래처 등록
│ │ ├── ex_reg/ # 예외 등록
│ │ ├── ob_del/ # 출고 삭제
│ │ ├── ob_reg/ # 출고 등록
│ │ ├── prod_del/ # 품목 삭제 (ERP → WMS)
│ │ │ ├── bean/
│ │ │ ├── test/
│ │ │ ├── E2WProdDelComp.java
│ │ │ ├── E2WProdDelController.java
│ │ │ ├── E2WProdDelDao.java
│ │ │ ├── E2WProdDelMapper.java
│ │ │ ├── E2WProdDelTxComp.java
│ │ │ └── E2WProdDelMapper.xml
│ │ │
│ │ ├── prod_mod/ # 품목 수정
│ │ │ ├── bean/
│ │ │ ├── test/
│ │ │ ├── E2WProdModComp.java
│ │ │ ├── E2WProdModController.java
│ │ │ ├── E2WProdModDao.java
│ │ │ ├── E2WProdModMapper.java
│ │ │ ├── E2WProdModTxComp.java
│ │ │ └── E2WProdModMapper.xml
│ │ │
│ │ ├── prod_reg/ # 품목 등록
│ │ │ ├── bean/
│ │ │ ├── test/
│ │ │ ├── E2WProdRegComp.java
│ │ │ ├── E2WProdRegController.java
│ │ │ ├── E2WProdRegDao.java
│ │ │ ├── E2WProdRegMapper.java
│ │ │ ├── E2WProdRegTxComp.java
│ │ │ └── E2WProdRegMapper.xml
│ │ │
│ │ └── rt_reg/ # 반품 등록
│ │
│ └── w2e/ # WMS → ERP
│ ├── abc/ # w2e 공통
│ │ ├── W2EAbcAspect.java
│ │ ├── W2EAbcComp.java
│ │ ├── W2EAbcCompUtil.java
│ │ ├── W2EAbcDao.java
│ │ ├── W2EAbcMapper.java
│ │ ├── W2EAbcPool.java
│ │ ├── W2EAbcProd.java
│ │ ├── W2EAbcReq.java
│ │ ├── W2EAbcRequestBody.java
│ │ ├── W2EAbcRes.java
│ │ ├── W2EAbcResponseBody.java
│ │ ├── W2EAbcTable.java
│ │ ├── W2EApiServiceUtil.java
│ │ ├── W2EErpProd.java
│ │ ├── W2EErpWh.java
│ │ └── W2EAbcMapper.xml
│ │
│ ├── iw_proc/ # 입고처리 결과 전송
│ │ ├── bean/
│ │ ├── test/
│ │ ├── W2EIwProcApi.java
│ │ ├── W2EIwProcComp.java
│ │ └── W2EIwProcCompUtil.java
│ │
│ ├── iw_proc_cxl/ # 입고처리 취소 전송
│ │ ├── bean/
│ │ ├── test/
│ │ ├── W2EIwProcCxlApi.java
│ │ ├── W2EIwProcCxlComp.java
│ │ └── W2EIwProcCxlCompUtil.java
│ │
│ ├── ob_proc/ # 출고처리 결과 전송
│ │ ├── bean/
│ │ ├── test/
│ │ ├── W2EObProcApi.java
│ │ ├── W2EObProcComp.java
│ │ └── W2EObProcCompUtil.java
│ │
│ └── ob_proc_cxl/ # 출고처리 취소 전송
│ ├── bean/
│ ├── test/
│ ├── W2EObProcCxlApi.java
│ ├── W2EObProcCxlComp.java
│ └── W2EObProcCxlCompUtil.java
│
├── dlv/ # 배송/택배사 연동
├── oms/ # OMS 연동
├── wes/ # WES 연동
└── wms/ # WMS 연동
```

---

### 2.5 `test` 패키지 (공통 테스트)

#### 개요
- **루트 레벨 `test` 패키지**에 모든 공통 테스트 클래스 위치
- 각 모듈별 테스트는 해당 모듈 하위 `test` 패키지에 위치 (예: `be/md8000/mdpd01/test/`)

#### 패키지 구조
```
test/
├── annotation/ # 테스트 전용 어노테이션
│ ├── WithMockCustomUser.java
│ ├── WithMockCustomUserSecurityContextFactory.java
│ ├── WithMockIfUser.java
│ └── WithMockIfUserSecurityContextFactory.java
│
├── ZTEST_Abstract.java # 최상위 추상 테스트
│ ├── 프로파일/상수 정의
│ ├── JSON 유틸리티
│ └── 공통 테스트 설정
│
├── ZTEST_ALL.java # 전체 테스트 스위트
│ └── MDPD01, OBRQ01, OBPC01, 공통코드 테스트 묶음
│
├── ZTEST_ApikeyProvider.java # API Key 발급/검증 테스트
├── ZTEST_Comp.java # 컴포넌트 테스트 부모
├── ZTEST_Controller.java # 컨트롤러 테스트 부모
├── ZTEST_Crypto.java # 암호화(AES256) 테스트
├── ZTEST_Dao.java # DAO 테스트 부모
├── ZTEST_E2WComp.java # ERP 연동 컴포넌트 테스트
├── ZTEST_E2WController.java # ERP 연동 컨트롤러 테스트
├── ZTEST_Jasypt.java # Jasypt 설정값 암호화 테스트
├── ZTEST_Mapper.java # 매퍼 테스트 부모 (MyBatis)
├── ZTEST_ProfileResolver.java # 프로파일 동적 설정
├── ZTEST_ValidConfig.java # 유효성 검증 설정
├── ZTEST_W2EComp.java # WMS→ERP 컴포넌트 테스트
├── ZTEST_WebMvConfig.java # Web MVC 설정 테스트
└── ZTEST_Mapper_mybatis.xml # MyBatis 테스트 설정
```

#### 테스트 클래스 상속 관계
```
ZTEST_Abstract
├── ZTEST_Comp
│ ├── ZTEST_ApikeyProvider
│ ├── ZTEST_Crypto
│ └── ZTEST_E2WComp
├── ZTEST_Controller
│ └── ZTEST_E2WController
├── ZTEST_Dao
├── ZTEST_Mapper
├── ZTEST_W2EComp
└── (기타 독립 테스트)
```

---

### 2.6 `vm` 패키지 (Velocity 템플릿 - 이메일)

#### 개요
- 이메일 발송용 Velocity 템플릿
- 다국어 지원 (en, ja, ko)

#### 패키지 구조
```
vm/
├── errMail.vm # 시스템 에러 발생시 관리자 알림
├── newPasswordMail-en.vm # 비밀번호 재설정 안내 (영문)
├── newPasswordMail-ja.vm # 비밀번호 재설정 안내 (일문)
├── newPasswordMail-ko.vm # 비밀번호 재설정 안내 (국문)
├── reqAuth.vm # 인증번호 요청 메일
├── testMail.vm # 메일 발송 테스트용
├── userReg-en.vm # 회원가입 완료 안내 (영문)
├── userReg-ja.vm # 회원가입 완료 안내 (일문)
└── userReg-ko.vm # 회원가입 완료 안내 (국문)
```

---

## 3. src/main/resources (리소스 파일)

### 3.1 `cache` 패키지
```
cache/
├── ehcache.xml # EhCache 설정
└── (기타 캐시 관련 설정)
```

### 3.2 `messages` 패키지 (다국어 메시지)
```
messages/
├── message_en.properties # 영문 메시지
├── message_ko.properties # 국문 메시지
└── (기타 다국어 properties)
```

### 3.3 `prop` 패키지 (프로퍼티 파일)
```
prop/
├── application-dev.properties # 개발 환경 설정
├── application-test.properties # 테스트 환경 설정
├── application-prod.properties # 운영 환경 설정
├── db.properties # 데이터베이스 설정
├── file.properties # 파일 업로드 설정
└── (기타 properties)
```

### 3.4 기타 루트 리소스 파일
```
src/main/resources/
├── log4jdbc.log4j2.properties # log4jdbc 설정
├── logback.xml # Logback 설정 (운영)
├── logback-test.xml # Logback 설정 (테스트)
├── spring.properties # Spring 프로퍼티
└── sqlmap-config.xml # MyBatis 설정 파일 (매퍼 스캔)
```

### 3.5 `mapper` 패키지 (MyBatis XML 매퍼)

#### 중요: XML 매퍼 위치 규칙
- **Java 인터페이스**: `src/main/java/{모듈}/{메뉴}/mapper/` 또는 모듈 루트
- **XML 매퍼**: `src/main/resources/mapper/{모듈}/{메뉴}/` (일반적)
- **단, 일부 모듈은 Java 소스와 동일한 위치에 XML 배치** (예: MDPD01, E2W 모듈)

#### 표준 구조 (권장)
```
mapper/
├── be/ # 백오피스 매퍼
│ ├── cm9400/
│ │ └── alst01/
│ │ └── ALST01Mapper.xml
│ ├── iw1000/
│ │ ├── iwpc01/
│ │ │ └── IWPC01Mapper.xml
│ │ └── ...
│ └── md8000/
│ └── mdpd01/
│ └── MDPDP01Mapper.xml
│
├── bm/ # 모바일 매퍼
│ ├── iw1000m/
│ │ └── iwpc01m/
│ │ └── IWPC01MMapper.xml
│ └── ...
│
└── sif/ # 인터페이스 매퍼
    └── erp/
        ├── e2w/
        │   └── E2WAbcMapper.xml
        └── w2e/
            └── abc/
                └── W2EAbcMapper.xml
```

#### 실제 배치 사례 (Java 소스에 XML이 있는 경우)
```
# MDPD01 예시 - Java 소스에 XML 위치
src/main/java/be/md8000/mdpd01/
├── MDPDP01Mapper.xml # XML 매퍼 (Java 소스와 동일 위치)
└── excel/
    └── MDPD01ExcelMapper.xml      # XML 매퍼

# E2W 예시 - Java 소스에 XML 위치
src/main/java/sif/erp/e2w/
├── abc/
│ └── E2WAbcMapper.xml # XML 매퍼
├── prod_reg/
│ └── E2WProdRegMapper.xml # XML 매퍼
└── ...
```

---

## 4. 명명 규칙 총정리

### 4.1 패키지 명명 규칙

| 구분 | 패턴 | 예시 |
|------|------|------|
| 백오피스 | `be.{메뉴코드}.{하위메뉴}` | `be.iw1000.iwpc01` |
| 모바일 | `bm.{메뉴코드}m.{하위메뉴}m` | `bm.iw1000m.iwpc01m` |
| 공통(백오피스) | `be.abc` | `be.abc` |
| 프레임워크 | `fw.{기능}` | `fw.tool`, `fw.constant` |
| 인터페이스 | `sif.{시스템}.{방향}` | `sif.erp.e2w`, `sif.erp.w2e` |
| 테스트(공통) | `test` | `test` |
| 테스트(모듈) | `{모듈}.test` | `be.md8000.mdpd01.test` |
| 템플릿(이메일) | `vm` | `vm` |
| 템플릿(출력물) | `{모듈}.vm` | `be.md8000.mdpd01.vm` |

### 4.2 파일 명명 규칙

| 계층 | 접미사 | 예시 |
|------|--------|------|
| Controller | `*Controller` | `MDPD01Controller` |
| Component | `*Comp` | `MDPD01Comp` |
| Transaction Component | `*TxComp` | `MDPD01TxComp` |
| DAO | `*Dao` | `MDPD01Dao` |
| Mapper Interface | `*Mapper` | `MDPD01Mapper` |
| Mapper XML | `*Mapper.xml` | `MDPD01Mapper.xml` |
| Bean | 도메인명 | `MDPD01Prod` |
| Test | `ZTEST_*` | `ZTEST_MDPD01Mapper` |
| Enum | 타입명 | `MDPDLaberPaperType` |
| API Interface | `*Api` | `W2EIwProcApi` |
| Utility | `*Util` | `MDPD01CompUtil` |

### 4.3 인터페이스 방향성 접두사

| 접두사 | 의미 | 예시 |
|--------|------|------|
| `E2W` | ERP → WMS | `E2WProdRegController` |
| `W2E` | WMS → ERP | `W2EIwProcComp` |

### 4.4 CRUD 행위 접미사 (e2w)

| 접미사 | 의미 | 예시 |
|--------|------|------|
| `Reg` | 등록(Register) | `E2WProdRegController` |
| `Mod` | 수정(Modify) | `E2WProdModController` |
| `Del` | 삭제(Delete) | `E2WProdDelController` |

### 4.5 처리유형 접미사 (w2e)

| 접미사 | 의미 | 예시 |
|--------|------|------|
| `Proc` | 처리(Process) | `W2EIwProcComp` |
| `ProcCxl` | 처리취소(Process Cancel) | `W2EIwProcCxlComp` |

---

## 5. 주요 특징 요약

### 5.1 패키지 구조 특징
1. **메뉴 구조와 패키지 1:1 매핑**: 메뉴코드 = 패키지명
2. **abc 패키지**: 공통(common) 패키지로 가시성 향상을 위해 최상단 배치
3. **계층별 분리**: controller/service/bean/mapper 명확히 구분

### 5.2 테스트 구조 특징
1. **루트 레벨 `test` 패키지**: 공통 테스트 부모 클래스 위치
2. **모듈 내 `test` 패키지**: 각 모듈별 단위 테스트 위치
3. **계층별 부모 클래스**: `ZTEST_Comp`, `ZTEST_Controller`, `ZTEST_Dao`, `ZTEST_Mapper`

### 5.3 인터페이스 구조 특징
1. **방향성 기반 분리**: `e2w`(ERP→WMS) vs `w2e`(WMS→ERP)
2. **공통 모듈 계층화**: `sif/erp/abc`(전체공통) → `e2w/abc`(e2w공통) → 개별모듈
3. **기능별 모듈화**: `prod_reg`, `prod_mod`, `prod_del` (CRUD 단위)
4. **처리유형 모듈화**: `iw_proc`, `iw_proc_cxl` (처리/취소 단위)

### 5.4 XML 매퍼 위치 특징
1. **표준 위치**: `src/main/resources/mapper/{모듈}/{메뉴}/`
2. **예외 케이스**: 일부 모듈은 Java 소스와 동일 위치에 XML 배치
- MDPD01: `be/md8000/mdpd01/MDPDP01Mapper.xml`
- E2W: `sif/erp/e2w/abc/E2WAbcMapper.xml`

### 5.5 템플릿 구조 특징
1. **이메일 템플릿**: 루트 `vm/`에 다국어별 파일
2. **출력물 템플릿**: 각 모듈 하위 `vm/` 패키지에 위치

---

## 6. 메뉴 코드 체계

| 코드 범위 | 업무 영역 | 예시 |
|-----------|----------|------|
| 1000번대 | 입고관리 | iw1000, iwpc01 |
| 2000번대 | 반품관리 | rt2000, rtpc01 |
| 3000번대 | 재고관리 | iv3000, ivad01 |
| 3100번대 | 재고조회 | iv3100, ivpd01 |
| 3200번대 | 재고실사 | iv3200, strg01 |
| 5000번대 | 출고관리 | ow5000, obpc01 |
| 8000번대 | 기준정보 | md8000, mdpd01 |
| 9000번대 | 시스템설정 | sm9000, smmg01 |
| 9100번대 | IF관리 | if9100, ifst01 |
| 9200번대 | 운영관리 | mm9200, smcc01 |
| 9300번대 | 시스템현황 | ss9300, lgap01 |
| 11000번대 | 모바일 입고관리 | iw1000m, iwpc01m |
| 12000번대 | 모바일 반품관리 | rt2000m, rtpc01m |
| 13000번대 | 모바일 재고관리 | iv3000m, ivad01m |
| 15000번대 | 모바일 출고관리 | ow5000m, obpc01m |
