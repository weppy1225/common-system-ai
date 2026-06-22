-- MDM_거래처
CREATE TABLE "mdm_cont"
(
	"cont_seq"         int4          NOT NULL DEFAULT nextval('mdm_cont_seq'), -- 거래처_SEQ
	"if_cont_id"       varchar(50)   NULL,     -- IF_거래처_ID
	"cont_no"          varchar(30)   NOT NULL, -- 거래처_번호
	"cont_nm"          varchar(100)  NOT NULL, -- 거래처_명
	"cont_nm_short"    varchar(100)  NULL,     -- 거래처_명_약칭
	"cont_div_cd"      varchar(50)   NULL     DEFAULT '3', -- 거래처_구분_코드
	"ceo_nm"           varchar(100)  NULL,     -- 대표자_명
	"biz_no"           varchar(20)   NULL,     -- 사업자_번호
	"sub_biz_no"       char(4)       NULL,     -- 종_사업자_번호
	"cont_type"        varchar(100)  NULL,     -- 거래처_업태
	"cont_item"        varchar(100)  NULL,     -- 거래처_종목
	"email"            varchar(100)  NULL,     -- 이메일
	"tel"              varchar(500)  NULL,     -- 전화번호
	"fax"              varchar(500)  NULL,     -- 팩스
	"post_no"          varchar(10)   NULL,     -- 우편_번호
	"addr"             varchar(200)  NULL,     -- 주소
	"addr_dtl"         varchar(200)  NULL,     -- 주소_상세
	"manager_nm"       varchar(100)  NULL,     -- 담당자
	"rep_cont_seq"     int4          NULL,     -- 대표업체_SEQ
	"label_paper_seq"  int4          NULL,     -- 라벨용지_SEQ
	"barcode_type_cd1" varchar(50)   NOT NULL DEFAULT '16', -- 1D_바코드_유형_코드
	"barcode_type_cd2" varchar(50)   NOT NULL DEFAULT '32', -- 2D_바코드_유형_코드
	"note"             varchar(1000) NULL,     -- 비고
	"reg_id"           varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"           timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"           varchar(20)   NULL,     -- 수정_ID
	"mod_dt"           timestamp     NULL      -- 수정_일시
);

-- MDM_거래처
COMMENT ON TABLE "mdm_cont" IS 'MDM_거래처';

-- 거래처_SEQ
COMMENT ON COLUMN "mdm_cont"."cont_seq" IS '거래처_ID';

-- IF_거래처_ID
COMMENT ON COLUMN "mdm_cont"."if_cont_id" IS '거래처_IF_ID';

-- 거래처_번호
COMMENT ON COLUMN "mdm_cont"."cont_no" IS '거래처_번호';

-- 거래처_명
COMMENT ON COLUMN "mdm_cont"."cont_nm" IS '거래처_명';

-- 거래처_명_약칭
COMMENT ON COLUMN "mdm_cont"."cont_nm_short" IS '거래처_명_(약칭)';

-- 거래처_구분_코드
COMMENT ON COLUMN "mdm_cont"."cont_div_cd" IS '거래처_구분_코드';

-- 대표자_명
COMMENT ON COLUMN "mdm_cont"."ceo_nm" IS '대표자_명';

-- 사업자_번호
COMMENT ON COLUMN "mdm_cont"."biz_no" IS '사업자_번호';

-- 종_사업자_번호
COMMENT ON COLUMN "mdm_cont"."sub_biz_no" IS '종사업자_번호';

-- 거래처_업태
COMMENT ON COLUMN "mdm_cont"."cont_type" IS '업태';

-- 거래처_종목
COMMENT ON COLUMN "mdm_cont"."cont_item" IS '종목';

-- 이메일
COMMENT ON COLUMN "mdm_cont"."email" IS '이메일';

-- 전화번호
COMMENT ON COLUMN "mdm_cont"."tel" IS '전화';

-- 팩스
COMMENT ON COLUMN "mdm_cont"."fax" IS '팩스';

-- 우편_번호
COMMENT ON COLUMN "mdm_cont"."post_no" IS '우편_번호';

-- 주소
COMMENT ON COLUMN "mdm_cont"."addr" IS '주소';

-- 주소_상세
COMMENT ON COLUMN "mdm_cont"."addr_dtl" IS '주소_상세';

-- 담당자
COMMENT ON COLUMN "mdm_cont"."manager_nm" IS '담당자';

-- 대표업체_SEQ
COMMENT ON COLUMN "mdm_cont"."rep_cont_seq" IS '대표업체_SEQ';

-- 라벨용지_SEQ
COMMENT ON COLUMN "mdm_cont"."label_paper_seq" IS '품목ID';

-- 1D_바코드_유형_코드
COMMENT ON COLUMN "mdm_cont"."barcode_type_cd1" IS '1D_바코드_유형_코드';

-- 2D_바코드_유형_코드
COMMENT ON COLUMN "mdm_cont"."barcode_type_cd2" IS '2D_바코드_유형_코드';

-- 비고
COMMENT ON COLUMN "mdm_cont"."note" IS '비고';

-- 등록_ID
COMMENT ON COLUMN "mdm_cont"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "mdm_cont"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "mdm_cont"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "mdm_cont"."mod_dt" IS '수정일';

-- MDM_거래처_PK
CREATE UNIQUE INDEX "mdm_cont_PK"
	ON "mdm_cont"
	( -- MDM_거래처
		"cont_seq" ASC -- 거래처_SEQ
	)
;
-- MDM_거래처
ALTER TABLE "mdm_cont"
	ADD CONSTRAINT "mdm_cont_PK"
		 -- MDM_거래처_PK
	PRIMARY KEY 
	USING INDEX "mdm_cont_PK";

-- MDM_거래처_PK
COMMENT ON CONSTRAINT "mdm_cont_PK" ON "mdm_cont" IS 'MDM_거래처_PK';

-- MDM_거래처_품목
CREATE TABLE "mdm_cont_prod"
(
	"cont_prod_seq"     int4          NOT NULL DEFAULT nextval('mdm_cont_prod_seq'), -- 거래처_품목_SEQ
	"biz_seq"           int4          NOT NULL, -- 사업장_SEQ
	"cont_seq"          int4          NOT NULL, -- 거래처_SEQ
	"prod_seq"          int4          NOT NULL, -- 품목_SEQ
	"label_prod_nm"     varchar(100)  NOT NULL, -- 라벨_품목_명
	"disp_prod_barcode" varchar(100)  NULL,     -- 표시_상품_BARCODE
	"cont_prod_code"    varchar(100)  NULL,     -- 거래처_품목_CODE
	"in_qty"            int2          NOT NULL DEFAULT 1, -- 입수
	"exp_date_disp_yn"  char(1)       NOT NULL DEFAULT 'Y', -- 유통_기한_표시_여부
	"print_cnt"         int2          NOT NULL DEFAULT 1, -- 출력_매수
	"note"              varchar(1000) NULL,     -- 비고
	"reg_id"            varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"            timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"            varchar(20)   NULL,     -- 수정_ID
	"mod_dt"            timestamp     NULL      -- 수정_일시
);

-- MDM_거래처_품목
COMMENT ON TABLE "mdm_cont_prod" IS 'MDM_거래처_품목';

-- 거래처_품목_SEQ
COMMENT ON COLUMN "mdm_cont_prod"."cont_prod_seq" IS '거래처_품목_SEQ';

-- 사업장_SEQ
COMMENT ON COLUMN "mdm_cont_prod"."biz_seq" IS '사업장_ID';

-- 거래처_SEQ
COMMENT ON COLUMN "mdm_cont_prod"."cont_seq" IS '거래처_SEQ';

-- 품목_SEQ
COMMENT ON COLUMN "mdm_cont_prod"."prod_seq" IS '품목_SEQ';

-- 라벨_품목_명
COMMENT ON COLUMN "mdm_cont_prod"."label_prod_nm" IS '품목_명';

-- 표시_상품_BARCODE
COMMENT ON COLUMN "mdm_cont_prod"."disp_prod_barcode" IS '표시_상품_BARCODE';

-- 거래처_품목_CODE
COMMENT ON COLUMN "mdm_cont_prod"."cont_prod_code" IS '거래처_품목_CODE';

-- 입수
COMMENT ON COLUMN "mdm_cont_prod"."in_qty" IS '입수';

-- 유통_기한_표시_여부
COMMENT ON COLUMN "mdm_cont_prod"."exp_date_disp_yn" IS '유효기준일수';

-- 출력_매수
COMMENT ON COLUMN "mdm_cont_prod"."print_cnt" IS '출력_매수';

-- 비고
COMMENT ON COLUMN "mdm_cont_prod"."note" IS '비고';

-- 등록_ID
COMMENT ON COLUMN "mdm_cont_prod"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "mdm_cont_prod"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "mdm_cont_prod"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "mdm_cont_prod"."mod_dt" IS '수정일';

-- MDM_거래처_품목 유니크 인덱스
CREATE UNIQUE INDEX "UIX_mdm_cont_prod"
	ON "mdm_cont_prod"
	( -- MDM_거래처_품목
		"cont_seq" ASC, -- 거래처_SEQ
		"prod_seq" ASC -- 품목_SEQ
	);

-- MDM_거래처_품목 유니크 인덱스
COMMENT ON INDEX "UIX_mdm_cont_prod" IS 'MDM_거래처_품목 유니크 인덱스';

-- MDM_거래처_품목_PK
CREATE UNIQUE INDEX "mdm_cont_prod_PK"
	ON "mdm_cont_prod"
	( -- MDM_거래처_품목
		"cont_prod_seq" ASC -- 거래처_품목_SEQ
	)
;
-- MDM_거래처_품목
ALTER TABLE "mdm_cont_prod"
	ADD CONSTRAINT "mdm_cont_prod_PK"
		 -- MDM_거래처_품목_PK
	PRIMARY KEY 
	USING INDEX "mdm_cont_prod_PK";

-- MDM_거래처_품목_PK
COMMENT ON CONSTRAINT "mdm_cont_prod_PK" ON "mdm_cont_prod" IS 'MDM_거래처_품목_PK';

-- MDM_거래처_품목
ALTER TABLE "mdm_cont_prod"
	ADD CONSTRAINT "UK_mdm_cont_prod" -- MDM_거래처_품목 유니크 제약
	UNIQUE 
	USING INDEX "UIX_mdm_cont_prod";

-- MDM_거래처_품목 유니크 제약
COMMENT ON CONSTRAINT "UK_mdm_cont_prod" ON "mdm_cont_prod" IS 'MDM_거래처_품목 유니크 제약';

-- MDM_권한사업장
CREATE TABLE "mdm_user_biz"
(
	"biz_seq" int4        NOT NULL, -- 사업장_SEQ
	"user_id" varchar(20) NOT NULL, -- 사용자_ID
	"reg_id"  varchar(20) NOT NULL, -- 등록_ID
	"reg_dt"  timestamp   NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"  varchar(20) NULL,     -- 수정_ID
	"mod_dt"  timestamp   NULL      -- 수정_일시
);

-- MDM_권한사업장
COMMENT ON TABLE "mdm_user_biz" IS 'MDM_권한사업장';

-- 사업장_SEQ
COMMENT ON COLUMN "mdm_user_biz"."biz_seq" IS '사업장_SEQ';

-- 사용자_ID
COMMENT ON COLUMN "mdm_user_biz"."user_id" IS '사용자_ID';

-- 등록_ID
COMMENT ON COLUMN "mdm_user_biz"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "mdm_user_biz"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "mdm_user_biz"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "mdm_user_biz"."mod_dt" IS '수정일';

-- MDM_권한사업장 유니크 인덱스
CREATE UNIQUE INDEX "UIX_mdm_user_biz"
	ON "mdm_user_biz"
	( -- MDM_권한사업장
		"biz_seq" ASC, -- 사업장_SEQ
		"user_id" ASC -- 사용자_ID
	);

-- MDM_권한사업장 유니크 인덱스
COMMENT ON INDEX "UIX_mdm_user_biz" IS 'MDM_권한사업장 유니크 인덱스';

-- MDM_권한사업장
ALTER TABLE "mdm_user_biz"
	ADD CONSTRAINT "UK_mdm_user_biz" -- MDM_권한사업장 유니크 제약
	UNIQUE 
	USING INDEX "UIX_mdm_user_biz";

-- MDM_권한사업장 유니크 제약
COMMENT ON CONSTRAINT "UK_mdm_user_biz" ON "mdm_user_biz" IS 'MDM_권한사업장 유니크 제약';

-- MDM_권한센터
CREATE TABLE "mdm_user_center"
(
	"center_seq" int4        NOT NULL, -- 센터_SEQ
	"user_id"    varchar(20) NOT NULL, -- 사용자_ID
	"reg_id"     varchar(20) NOT NULL, -- 등록_ID
	"reg_dt"     timestamp   NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"     varchar(20) NULL,     -- 수정_ID
	"mod_dt"     timestamp   NULL      -- 수정_일시
);

-- MDM_권한센터
COMMENT ON TABLE "mdm_user_center" IS 'MDM_권한센터';

-- 센터_SEQ
COMMENT ON COLUMN "mdm_user_center"."center_seq" IS '센터_SEQ';

-- 사용자_ID
COMMENT ON COLUMN "mdm_user_center"."user_id" IS '사용자_ID';

-- 등록_ID
COMMENT ON COLUMN "mdm_user_center"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "mdm_user_center"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "mdm_user_center"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "mdm_user_center"."mod_dt" IS '수정일';

-- MDM_권한센터 유니크 인덱스
CREATE UNIQUE INDEX "UIX_mdm_user_center"
	ON "mdm_user_center"
	( -- MDM_권한센터
		"center_seq" ASC, -- 센터_SEQ
		"user_id" ASC -- 사용자_ID
	);

-- MDM_권한센터 유니크 인덱스
COMMENT ON INDEX "UIX_mdm_user_center" IS 'MDM_권한센터 유니크 인덱스';

-- MDM_권한센터
ALTER TABLE "mdm_user_center"
	ADD CONSTRAINT "UK_mdm_user_center" -- MDM_권한센터 유니크 제약
	UNIQUE 
	USING INDEX "UIX_mdm_user_center";

-- MDM_권한센터 유니크 제약
COMMENT ON CONSTRAINT "UK_mdm_user_center" ON "mdm_user_center" IS 'MDM_권한센터 유니크 제약';

-- MDM_라벨_용지
CREATE TABLE "mdm_label_paper"
(
	"label_paper_seq"     int4          NOT NULL DEFAULT nextval('mdm_label_paper_seq'), -- 라벨용지_SEQ
	"label_paper_nm"      varchar(100)  NOT NULL, -- 라벨용지_명
	"label_paper_div_cd"  varchar(50)   NOT NULL, -- 용지_구분_코드
	"label_paper_type_cd" varchar(50)   NOT NULL, -- 용지_유형_코드
	"barcode_dim_cd"      varchar(50)   NULL,     -- 바코드_차원_코드
	"manufacturer_nm"     varchar(100)  NULL,     -- 제조사_명칭
	"product_code"        varchar(100)  NULL,     -- 제품_CODE
	"product_nm"          varchar(100)  NULL,     -- 제품_명칭
	"paper_type"          varchar(100)  NULL,     -- 용지_종류
	"name_tag_cnt"        varchar(100)  NULL,     -- 이름표_개수
	"name_tag_size"       varchar(100)  NULL,     -- 이름표_크기
	"file_seq"            int4          NOT NULL, -- 출력_양식_파일_SEQ
	"def_label_yn"        char(1)       NOT NULL DEFAULT 'N', -- 기본라벨_유무
	"note"                varchar(1000) NULL,     -- 비고
	"reg_id"              varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"              timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"              varchar(20)   NULL,     -- 수정_ID
	"mod_dt"              timestamp     NULL      -- 수정_일시
);

-- MDM_라벨_용지
COMMENT ON TABLE "mdm_label_paper" IS 'MDM_라벨_용지';

-- 라벨용지_SEQ
COMMENT ON COLUMN "mdm_label_paper"."label_paper_seq" IS '라벨용지_SEQ';

-- 라벨용지_명
COMMENT ON COLUMN "mdm_label_paper"."label_paper_nm" IS '라벨용지_명';

-- 용지_구분_코드
COMMENT ON COLUMN "mdm_label_paper"."label_paper_div_cd" IS '용지_구분_코드';

-- 용지_유형_코드
COMMENT ON COLUMN "mdm_label_paper"."label_paper_type_cd" IS '용지_유형_코드';

-- 바코드_차원_코드
COMMENT ON COLUMN "mdm_label_paper"."barcode_dim_cd" IS '바코드_차원_코드';

-- 제조사_명칭
COMMENT ON COLUMN "mdm_label_paper"."manufacturer_nm" IS '제조사_명칭';

-- 제품_CODE
COMMENT ON COLUMN "mdm_label_paper"."product_code" IS '제품_CODE';

-- 제품_명칭
COMMENT ON COLUMN "mdm_label_paper"."product_nm" IS '제품_명칭';

-- 용지_종류
COMMENT ON COLUMN "mdm_label_paper"."paper_type" IS '용지_종류';

-- 이름표_개수
COMMENT ON COLUMN "mdm_label_paper"."name_tag_cnt" IS '이름표_개수';

-- 이름표_크기
COMMENT ON COLUMN "mdm_label_paper"."name_tag_size" IS '이름표_크기';

-- 출력_양식_파일_SEQ
COMMENT ON COLUMN "mdm_label_paper"."file_seq" IS '출력_양식_파일_SEQ';

-- 기본라벨_유무
COMMENT ON COLUMN "mdm_label_paper"."def_label_yn" IS '기본라벨_유무';

-- 비고
COMMENT ON COLUMN "mdm_label_paper"."note" IS '비고';

-- 등록_ID
COMMENT ON COLUMN "mdm_label_paper"."reg_id" IS '등록_ID';

-- 등록_일시
COMMENT ON COLUMN "mdm_label_paper"."reg_dt" IS '등록_일시';

-- 수정_ID
COMMENT ON COLUMN "mdm_label_paper"."mod_id" IS '수정_ID';

-- 수정_일시
COMMENT ON COLUMN "mdm_label_paper"."mod_dt" IS '수정_일시';

-- MDM_라벨_용지_PK
CREATE UNIQUE INDEX "mdm_label_paper_PK"
	ON "mdm_label_paper"
	( -- MDM_라벨_용지
		"label_paper_seq" ASC -- 라벨용지_SEQ
	)
;
-- MDM_라벨_용지
ALTER TABLE "mdm_label_paper"
	ADD CONSTRAINT "mdm_label_paper_PK"
		 -- MDM_라벨_용지_PK
	PRIMARY KEY 
	USING INDEX "mdm_label_paper_PK";

-- MDM_라벨_용지_PK
COMMENT ON CONSTRAINT "mdm_label_paper_PK" ON "mdm_label_paper" IS 'MDM_라벨_용지_PK';

-- MDM_문서번호
CREATE TABLE "mdm_doc_no"
(
	"biz_seq"       int4        NOT NULL, -- 사업장_SEQ
	"inout_type_cd" varchar(50) NOT NULL, -- 수불_유형_코드
	"base_ymd"      varchar(8)  NOT NULL, -- 기준일자
	"next_seq"      int4        NOT NULL DEFAULT 1 -- 다음순번
);

-- MDM_문서번호
COMMENT ON TABLE "mdm_doc_no" IS 'MDM_문서번호';

-- 사업장_SEQ
COMMENT ON COLUMN "mdm_doc_no"."biz_seq" IS '사업장_SEQ';

-- 수불_유형_코드
COMMENT ON COLUMN "mdm_doc_no"."inout_type_cd" IS '수불_유형_코드';

-- 기준일자
COMMENT ON COLUMN "mdm_doc_no"."base_ymd" IS '기준일자';

-- 다음순번
COMMENT ON COLUMN "mdm_doc_no"."next_seq" IS '다음순번';

-- MDM_문서번호_PK
CREATE UNIQUE INDEX "mdm_doc_no_PK"
	ON "mdm_doc_no"
	( -- MDM_문서번호
		"biz_seq" ASC, -- 사업장_SEQ
		"inout_type_cd" ASC, -- 수불_유형_코드
		"base_ymd" ASC -- 기준일자
	)
;
-- MDM_문서번호
ALTER TABLE "mdm_doc_no"
	ADD CONSTRAINT "mdm_doc_no_PK"
		 -- MDM_문서번호_PK
	PRIMARY KEY 
	USING INDEX "mdm_doc_no_PK";

-- MDM_문서번호_PK
COMMENT ON CONSTRAINT "mdm_doc_no_PK" ON "mdm_doc_no" IS 'MDM_문서번호_PK';

-- MDM_사업장
CREATE TABLE "mdm_biz"
(
	"biz_seq"        int4          NOT NULL DEFAULT nextval('mdm_biz_seq'), -- 사업장_SEQ
	"biz_nm"         varchar(100)  NOT NULL, -- 사업장_명
	"biz_nm_short"   varchar(100)  NULL,     -- 사업장_명_약칭
	"ceo_nm"         varchar(100)  NULL,     -- 대표자_명
	"biz_no"         varchar(20)   NULL,     -- 사업자_번호
	"sub_biz_no"     char(4)       NULL,     -- 종_사업자_번호
	"biz_type"       varchar(100)  NULL,     -- 사업장_업태
	"biz_item"       varchar(100)  NULL,     -- 사업장_종목
	"biz_div_cd"     varchar(50)   NOT NULL DEFAULT 'OWN', -- 사업장_구분_코드
	"contract_ymd"   varchar(8)    NULL,     -- 계약일
	"hq_yn"          char(1)       NOT NULL DEFAULT 'N', -- 본사_여부
	"email"          varchar(100)  NULL,     -- 이메일
	"tel"            varchar(500)  NULL,     -- 전화번호
	"fax"            varchar(500)  NULL,     -- 팩스
	"post_no"        varchar(10)   NULL,     -- 우편_번호
	"addr"           varchar(200)  NULL,     -- 주소
	"addr_dtl"       varchar(200)  NULL,     -- 주소_상세
	"stamp_file_seq" int4          NULL,     -- 직인_파일_SEQ
	"logo_file_seq"  int4          NULL,     -- 로고_파일_SEQ
	"if_biz_id"      varchar(50)   NULL,     -- IF_사업장_ID
	"biz_color"      varchar(50)   NULL     DEFAULT '#00afec', -- 사업장_색
	"note"           varchar(1000) NULL,     -- 비고
	"use_yn"         char(1)       NOT NULL DEFAULT 'Y', -- 사용_여부
	"reg_id"         varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"         timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"         varchar(20)   NULL,     -- 수정_ID
	"mod_dt"         timestamp     NULL      -- 수정_일시
);

-- MDM_사업장
COMMENT ON TABLE "mdm_biz" IS 'MDM_사업장';

-- 사업장_SEQ
COMMENT ON COLUMN "mdm_biz"."biz_seq" IS '사업장_SEQ';

-- 사업장_명
COMMENT ON COLUMN "mdm_biz"."biz_nm" IS '사업장_명';

-- 사업장_명_약칭
COMMENT ON COLUMN "mdm_biz"."biz_nm_short" IS '사업장_명_(약칭)';

-- 대표자_명
COMMENT ON COLUMN "mdm_biz"."ceo_nm" IS '대표자_명';

-- 사업자_번호
COMMENT ON COLUMN "mdm_biz"."biz_no" IS '사업자_번호';

-- 종_사업자_번호
COMMENT ON COLUMN "mdm_biz"."sub_biz_no" IS '종사업자_번호';

-- 사업장_업태
COMMENT ON COLUMN "mdm_biz"."biz_type" IS '업태';

-- 사업장_종목
COMMENT ON COLUMN "mdm_biz"."biz_item" IS '종목';

-- 사업장_구분_코드
COMMENT ON COLUMN "mdm_biz"."biz_div_cd" IS '사업장_구분';

-- 계약일
COMMENT ON COLUMN "mdm_biz"."contract_ymd" IS '계약일';

-- 본사_여부
COMMENT ON COLUMN "mdm_biz"."hq_yn" IS '본사_여부';

-- 이메일
COMMENT ON COLUMN "mdm_biz"."email" IS '이메일';

-- 전화번호
COMMENT ON COLUMN "mdm_biz"."tel" IS '전화';

-- 팩스
COMMENT ON COLUMN "mdm_biz"."fax" IS '팩스';

-- 우편_번호
COMMENT ON COLUMN "mdm_biz"."post_no" IS '우편_번호';

-- 주소
COMMENT ON COLUMN "mdm_biz"."addr" IS '주소';

-- 주소_상세
COMMENT ON COLUMN "mdm_biz"."addr_dtl" IS '주소_상세';

-- 직인_파일_SEQ
COMMENT ON COLUMN "mdm_biz"."stamp_file_seq" IS '직인_파일';

-- 로고_파일_SEQ
COMMENT ON COLUMN "mdm_biz"."logo_file_seq" IS '로고_파일';

-- IF_사업장_ID
COMMENT ON COLUMN "mdm_biz"."if_biz_id" IS 'IF_사업장_ID';

-- 사업장_색
COMMENT ON COLUMN "mdm_biz"."biz_color" IS '사업장_색';

-- 비고
COMMENT ON COLUMN "mdm_biz"."note" IS '비고';

-- 사용_여부
COMMENT ON COLUMN "mdm_biz"."use_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "mdm_biz"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "mdm_biz"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "mdm_biz"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "mdm_biz"."mod_dt" IS '수정일';

-- MDM_사업장_PK
CREATE UNIQUE INDEX "mdm_biz_PK"
	ON "mdm_biz"
	( -- MDM_사업장
		"biz_seq" ASC -- 사업장_SEQ
	)
;
-- MDM_사업장
ALTER TABLE "mdm_biz"
	ADD CONSTRAINT "mdm_biz_PK"
		 -- MDM_사업장_PK
	PRIMARY KEY 
	USING INDEX "mdm_biz_PK";

-- MDM_사업장_PK
COMMENT ON CONSTRAINT "mdm_biz_PK" ON "mdm_biz" IS 'MDM_사업장_PK';

-- MDM_사업장_거래처
CREATE TABLE "mdm_biz_cont"
(
	"biz_seq"  int4        NOT NULL, -- 사업장_SEQ
	"cont_seq" int4        NOT NULL, -- 거래처_SEQ
	"use_yn"   char(1)     NOT NULL DEFAULT 'Y', -- 사용_여부
	"reg_id"   varchar(20) NOT NULL, -- 등록_ID
	"reg_dt"   timestamp   NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"   varchar(20) NULL,     -- 수정_ID
	"mod_dt"   timestamp   NULL      -- 수정_일시
);

-- MDM_사업장_거래처
COMMENT ON TABLE "mdm_biz_cont" IS 'MDM_사업장_거래처';

-- 사업장_SEQ
COMMENT ON COLUMN "mdm_biz_cont"."biz_seq" IS '사업장_ID';

-- 거래처_SEQ
COMMENT ON COLUMN "mdm_biz_cont"."cont_seq" IS '거래처_ID';

-- 사용_여부
COMMENT ON COLUMN "mdm_biz_cont"."use_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "mdm_biz_cont"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "mdm_biz_cont"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "mdm_biz_cont"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "mdm_biz_cont"."mod_dt" IS '수정일';

-- MDM_사업장_사업장
CREATE TABLE "mdm_biz_biz"
(
	"biz_seq"     int4        NOT NULL, -- 사업장_SEQ
	"ref_biz_seq" int4        NOT NULL, -- 상위_사업장_SEQ
	"use_yn"      char(1)     NOT NULL DEFAULT 'Y', -- 사용_여부
	"reg_id"      varchar(20) NOT NULL, -- 등록_ID
	"reg_dt"      timestamp   NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"      varchar(20) NULL,     -- 수정_ID
	"mod_dt"      timestamp   NULL      -- 수정_일시
);

-- MDM_사업장_사업장
COMMENT ON TABLE "mdm_biz_biz" IS 'MDM_사업장_사업장';

-- 사업장_SEQ
COMMENT ON COLUMN "mdm_biz_biz"."biz_seq" IS '사업장_SEQ';

-- 상위_사업장_SEQ
COMMENT ON COLUMN "mdm_biz_biz"."ref_biz_seq" IS '상위_사업장_SEQ';

-- 사용_여부
COMMENT ON COLUMN "mdm_biz_biz"."use_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "mdm_biz_biz"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "mdm_biz_biz"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "mdm_biz_biz"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "mdm_biz_biz"."mod_dt" IS '수정일';

-- MDM_사업장_센터
CREATE TABLE "mdm_biz_center"
(
	"biz_seq"     int4          NOT NULL, -- 사업장_SEQ
	"center_seq"  int4          NOT NULL, -- 센터_SEQ
	"reg_biz_seq" int4          NOT NULL, -- 가입_사업장_SEQ
	"note"        varchar(1000) NULL,     -- 요청_내용
	"cfm_yn"      char(1)       NOT NULL DEFAULT 'Y', -- 승인_여부
	"use_yn"      char(1)       NOT NULL DEFAULT 'N', -- 사용_여부
	"reg_id"      varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"      timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"      varchar(20)   NULL,     -- 수정_ID
	"mod_dt"      timestamp     NULL      -- 수정_일시
);

-- MDM_사업장_센터
COMMENT ON TABLE "mdm_biz_center" IS 'MDM_사업장_센터';

-- 사업장_SEQ
COMMENT ON COLUMN "mdm_biz_center"."biz_seq" IS '사업장_SEQ';

-- 센터_SEQ
COMMENT ON COLUMN "mdm_biz_center"."center_seq" IS '센터_SEQ';

-- 가입_사업장_SEQ
COMMENT ON COLUMN "mdm_biz_center"."reg_biz_seq" IS '가입_사업장_SEQ';

-- 요청_내용
COMMENT ON COLUMN "mdm_biz_center"."note" IS '비고';

-- 승인_여부
COMMENT ON COLUMN "mdm_biz_center"."cfm_yn" IS '승인_여부';

-- 사용_여부
COMMENT ON COLUMN "mdm_biz_center"."use_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "mdm_biz_center"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "mdm_biz_center"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "mdm_biz_center"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "mdm_biz_center"."mod_dt" IS '수정일';

-- MDM_사업장_센터 유니크 인덱스
CREATE UNIQUE INDEX "UIX_mdm_biz_center"
	ON "mdm_biz_center"
	( -- MDM_사업장_센터
		"biz_seq" ASC, -- 사업장_SEQ
		"center_seq" ASC -- 센터_SEQ
	);

-- MDM_사업장_센터 유니크 인덱스
COMMENT ON INDEX "UIX_mdm_biz_center" IS 'MDM_사업장_센터 유니크 인덱스';

-- MDM_사업장_센터
ALTER TABLE "mdm_biz_center"
	ADD CONSTRAINT "UK_mdm_biz_center" -- MDM_사업장_센터 유니크 제약
	UNIQUE 
	USING INDEX "UIX_mdm_biz_center";

-- MDM_사업장_센터 유니크 제약
COMMENT ON CONSTRAINT "UK_mdm_biz_center" ON "mdm_biz_center" IS 'MDM_사업장_센터 유니크 제약';

-- MDM_사업장_창고
CREATE TABLE "mdm_biz_wh"
(
	"biz_seq"  int4        NOT NULL, -- 사업장_SEQ
	"wh_seq"   int4        NOT NULL, -- 창고_SEQ
	"if_wh_id" varchar(50) NULL,     -- IF_창고_ID
	"reg_id"   varchar(20) NOT NULL, -- 등록_ID
	"reg_dt"   timestamp   NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"   varchar(20) NULL,     -- 수정_ID
	"mod_dt"   timestamp   NULL      -- 수정_일시
);

-- MDM_사업장_창고
COMMENT ON TABLE "mdm_biz_wh" IS 'MDM_사업장_창고';

-- 사업장_SEQ
COMMENT ON COLUMN "mdm_biz_wh"."biz_seq" IS '사업장_ID';

-- 창고_SEQ
COMMENT ON COLUMN "mdm_biz_wh"."wh_seq" IS '창고_ID';

-- IF_창고_ID
COMMENT ON COLUMN "mdm_biz_wh"."if_wh_id" IS '거래처_IF_ID';

-- 등록_ID
COMMENT ON COLUMN "mdm_biz_wh"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "mdm_biz_wh"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "mdm_biz_wh"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "mdm_biz_wh"."mod_dt" IS '수정일';

-- MDM_사업장_창고 유니크 인덱스
CREATE UNIQUE INDEX "UIX_mdm_biz_wh"
	ON "mdm_biz_wh"
	( -- MDM_사업장_창고
		"biz_seq" ASC, -- 사업장_SEQ
		"wh_seq" ASC -- 창고_SEQ
	);

-- MDM_사업장_창고 유니크 인덱스
COMMENT ON INDEX "UIX_mdm_biz_wh" IS 'MDM_사업장_창고 유니크 인덱스';

-- MDM_사업장_창고
ALTER TABLE "mdm_biz_wh"
	ADD CONSTRAINT "UK_mdm_biz_wh" -- MDM_사업장_창고 유니크 제약
	UNIQUE 
	USING INDEX "UIX_mdm_biz_wh";

-- MDM_사업장_창고 유니크 제약
COMMENT ON CONSTRAINT "UK_mdm_biz_wh" ON "mdm_biz_wh" IS 'MDM_사업장_창고 유니크 제약';

-- MDM_사업장_품목
CREATE TABLE "mdm_biz_prod"
(
	"biz_seq"  int4        NOT NULL, -- 사업장_SEQ
	"prod_seq" int4        NOT NULL, -- 품목_SEQ
	"use_yn"   char(1)     NOT NULL DEFAULT 'Y', -- 사용_여부
	"reg_id"   varchar(20) NOT NULL, -- 등록_ID
	"reg_dt"   timestamp   NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"   varchar(20) NULL,     -- 수정_ID
	"mod_dt"   timestamp   NULL      -- 수정_일시
);

-- MDM_사업장_품목
COMMENT ON TABLE "mdm_biz_prod" IS 'MDM_사업장_품목';

-- 사업장_SEQ
COMMENT ON COLUMN "mdm_biz_prod"."biz_seq" IS '사업장_SEQ';

-- 품목_SEQ
COMMENT ON COLUMN "mdm_biz_prod"."prod_seq" IS '품목_SEQ';

-- 사용_여부
COMMENT ON COLUMN "mdm_biz_prod"."use_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "mdm_biz_prod"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "mdm_biz_prod"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "mdm_biz_prod"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "mdm_biz_prod"."mod_dt" IS '수정일';

-- MDM_사용자
CREATE TABLE "mdm_user"
(
	"user_id"        varchar(20)   NOT NULL, -- 사용자_ID
	"if_emp_no"      varchar(50)   NULL,     -- IF_사원_번호
	"password"       varchar(500)  NOT NULL, -- 패스워드
	"user_nm"        varchar(100)  NOT NULL, -- 사용자_명
	"dvsn_nm"        varchar(100)  NULL,     -- 부서_명
	"email"          varchar(100)  NULL,     -- 이메일
	"tel"            bytea         NULL,     -- 전화번호
	"group_seq"      int4          NOT NULL, -- 그룹_SEQ
	"reg_biz_seq"    int4          NOT NULL, -- 가입_사업장_SEQ
	"reg_center_seq" int4          NULL,     -- 가입_센터_SEQ
	"auth_type_cd"   varchar(50)   NOT NULL, -- 권한_유형_코드
	"pwd_fail_cnt"   int4          NOT NULL DEFAULT 0, -- 비밀번호_실패_횟수
	"lock_yn"        char(1)       NOT NULL DEFAULT 'N', -- 잠금_여부
	"pwd_upd_date"   timestamp     NOT NULL DEFAULT now(), -- 비밀번호_수정_일시
	"admin_yn"       char(1)       NOT NULL DEFAULT 'N', -- ADMIN_여부
	"disp_qty_cd"    varchar(50)   NOT NULL DEFAULT 'ALL', -- 표시_수량_코드
	"lpa_port"       char(5)       NOT NULL DEFAULT '8888', -- LPA_사용포트
	"auth_no"        varchar(50)   NULL,     -- 인증번호
	"auth_time"      timestamp     NULL,     -- 인증시간
	"mobile_token"   varchar(1000) NULL,     -- 모바일_토큰
	"dormancy_yn"    char(1)       NOT NULL DEFAULT 'N', -- 휴면회원_여부
	"last_login_dt"  timestamp     NOT NULL DEFAULT now(), -- 마지막_로그인_일시
	"user_file_seq"  int4          NULL,     -- 사용자_파일_SEQ
	"use_yn"         char(1)       NOT NULL DEFAULT 'Y', -- 사용_여부
	"reg_id"         varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"         timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"         varchar(20)   NULL,     -- 수정_ID
	"mod_dt"         timestamp     NULL      -- 수정_일시
);

-- MDM_사용자
COMMENT ON TABLE "mdm_user" IS 'MDM_사용자';

-- 사용자_ID
COMMENT ON COLUMN "mdm_user"."user_id" IS '사용자ID';

-- IF_사원_번호
COMMENT ON COLUMN "mdm_user"."if_emp_no" IS 'IF_사원_번호';

-- 패스워드
COMMENT ON COLUMN "mdm_user"."password" IS '패스워드';

-- 사용자_명
COMMENT ON COLUMN "mdm_user"."user_nm" IS '사용자명';

-- 부서_명
COMMENT ON COLUMN "mdm_user"."dvsn_nm" IS '부서_코드';

-- 이메일
COMMENT ON COLUMN "mdm_user"."email" IS '메일주소';

-- 전화번호
COMMENT ON COLUMN "mdm_user"."tel" IS '전화번호';

-- 그룹_SEQ
COMMENT ON COLUMN "mdm_user"."group_seq" IS '그룹_SEQ';

-- 가입_사업장_SEQ
COMMENT ON COLUMN "mdm_user"."reg_biz_seq" IS '가입_사업장_SEQ';

-- 가입_센터_SEQ
COMMENT ON COLUMN "mdm_user"."reg_center_seq" IS '가입_센터_SEQ';

-- 권한_유형_코드
COMMENT ON COLUMN "mdm_user"."auth_type_cd" IS '권한_유형_코드';

-- 비밀번호_실패_횟수
COMMENT ON COLUMN "mdm_user"."pwd_fail_cnt" IS '비밀번호_실패_횟수';

-- 잠금_여부
COMMENT ON COLUMN "mdm_user"."lock_yn" IS '삭제 여부';

-- 비밀번호_수정_일시
COMMENT ON COLUMN "mdm_user"."pwd_upd_date" IS '비밀번호_수정_일시';

-- ADMIN_여부
COMMENT ON COLUMN "mdm_user"."admin_yn" IS 'ADMIN_여부';

-- 표시_수량_코드
COMMENT ON COLUMN "mdm_user"."disp_qty_cd" IS '표시_수량_코드';

-- LPA_사용포트
COMMENT ON COLUMN "mdm_user"."lpa_port" IS 'LPA_사용포트';

-- 인증번호
COMMENT ON COLUMN "mdm_user"."auth_no" IS '인증번호';

-- 인증시간
COMMENT ON COLUMN "mdm_user"."auth_time" IS '인증시간';

-- 모바일_토큰
COMMENT ON COLUMN "mdm_user"."mobile_token" IS '모바일_토큰';

-- 휴면회원_여부
COMMENT ON COLUMN "mdm_user"."dormancy_yn" IS '휴면회원_여부';

-- 마지막_로그인_일시
COMMENT ON COLUMN "mdm_user"."last_login_dt" IS '마지막_로그인_일시';

-- 사용자_파일_SEQ
COMMENT ON COLUMN "mdm_user"."user_file_seq" IS '사용자_파일_SEQ';

-- 사용_여부
COMMENT ON COLUMN "mdm_user"."use_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "mdm_user"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "mdm_user"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "mdm_user"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "mdm_user"."mod_dt" IS '수정일';

-- MDM_사용자(NEW)_PK
CREATE UNIQUE INDEX "mdm_user_PK"
	ON "mdm_user"
	( -- MDM_사용자
		"user_id" ASC -- 사용자_ID
	)
;
-- MDM_사용자
ALTER TABLE "mdm_user"
	ADD CONSTRAINT "mdm_user_PK"
		 -- MDM_사용자(NEW)_PK
	PRIMARY KEY 
	USING INDEX "mdm_user_PK";

-- MDM_사용자(NEW)_PK
COMMENT ON CONSTRAINT "mdm_user_PK" ON "mdm_user" IS 'MDM_사용자(NEW)_PK';

-- MDM_세트구성
CREATE TABLE "mdm_st_prod"
(
	"st_prod_seq"     int4          NOT NULL DEFAULT nextval('mdm_st_prod_seq'), -- 세트구성_SEQ
	"biz_seq"         int4          NOT NULL, -- 사업장_SEQ
	"st_yn"           char(1)       NOT NULL DEFAULT 'N', -- 세트품목_여부
	"ref_st_prod_seq" int4          NULL,     -- 상위_세트구성_SEQ
	"prod_seq"        int4          NOT NULL, -- 품목_SEQ
	"qty"             decimal(10,2) NOT NULL DEFAULT 1.00, -- 수량
	"note"            varchar(1000) NULL,     -- 비고
	"del_yn"          char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"          varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"          timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"          varchar(20)   NULL,     -- 수정_ID
	"mod_dt"          timestamp     NULL      -- 수정_일시
);

-- MDM_세트구성
COMMENT ON TABLE "mdm_st_prod" IS 'MDM_세트구성';

-- 세트구성_SEQ
COMMENT ON COLUMN "mdm_st_prod"."st_prod_seq" IS '세트구성_SEQ';

-- 사업장_SEQ
COMMENT ON COLUMN "mdm_st_prod"."biz_seq" IS '사업장_SEQ';

-- 세트품목_여부
COMMENT ON COLUMN "mdm_st_prod"."st_yn" IS '세트품목_여부';

-- 상위_세트구성_SEQ
COMMENT ON COLUMN "mdm_st_prod"."ref_st_prod_seq" IS '상위_세트구성_SEQ';

-- 품목_SEQ
COMMENT ON COLUMN "mdm_st_prod"."prod_seq" IS '품목_SEQ';

-- 수량
COMMENT ON COLUMN "mdm_st_prod"."qty" IS '수량';

-- 비고
COMMENT ON COLUMN "mdm_st_prod"."note" IS '비고';

-- 삭제_여부
COMMENT ON COLUMN "mdm_st_prod"."del_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "mdm_st_prod"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "mdm_st_prod"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "mdm_st_prod"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "mdm_st_prod"."mod_dt" IS '수정일';

-- MDM_세트구성_PK
CREATE UNIQUE INDEX "mdm_st_prod_PK"
	ON "mdm_st_prod"
	( -- MDM_세트구성
		"st_prod_seq" ASC -- 세트구성_SEQ
	)
;
-- MDM_세트구성
ALTER TABLE "mdm_st_prod"
	ADD CONSTRAINT "mdm_st_prod_PK"
		 -- MDM_세트구성_PK
	PRIMARY KEY 
	USING INDEX "mdm_st_prod_PK";

-- MDM_세트구성_PK
COMMENT ON CONSTRAINT "mdm_st_prod_PK" ON "mdm_st_prod" IS 'MDM_세트구성_PK';

-- MDM_센터
CREATE TABLE "mdm_center"
(
	"center_seq"      int4          NOT NULL DEFAULT nextval('mdm_center_seq'), -- 센터_SEQ
	"center_nm"       varchar(100)  NOT NULL, -- 센터_명
	"tel"             varchar(100)  NULL,     -- 전화번호
	"email"           varchar(100)  NULL,     -- 이메일
	"post_no"         varchar(10)   NULL,     -- 우편_번호
	"addr"            varchar(200)  NULL,     -- 주소
	"addr_dtl"        varchar(200)  NULL,     -- 주소_상세
	"center_file_seq" int4          NULL,     -- 센터_사진_SEQ
	"tpl_yn"          char(1)       NOT NULL DEFAULT 'N', -- 물류대행_여부
	"note"            varchar(1000) NULL,     -- 비고
	"use_yn"          char(1)       NOT NULL DEFAULT 'Y', -- 사용_여부
	"reg_id"          varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"          timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"          varchar(20)   NULL,     -- 수정_ID
	"mod_dt"          timestamp     NULL      -- 수정_일시
);

-- MDM_센터
COMMENT ON TABLE "mdm_center" IS 'MDM_센터';

-- 센터_SEQ
COMMENT ON COLUMN "mdm_center"."center_seq" IS '센터_SEQ';

-- 센터_명
COMMENT ON COLUMN "mdm_center"."center_nm" IS '센터_명';

-- 전화번호
COMMENT ON COLUMN "mdm_center"."tel" IS '전화';

-- 이메일
COMMENT ON COLUMN "mdm_center"."email" IS '이메일';

-- 우편_번호
COMMENT ON COLUMN "mdm_center"."post_no" IS '우편_번호';

-- 주소
COMMENT ON COLUMN "mdm_center"."addr" IS '주소';

-- 주소_상세
COMMENT ON COLUMN "mdm_center"."addr_dtl" IS '주소_상세';

-- 센터_사진_SEQ
COMMENT ON COLUMN "mdm_center"."center_file_seq" IS '비고';

-- 물류대행_여부
COMMENT ON COLUMN "mdm_center"."tpl_yn" IS '본사_여부';

-- 비고
COMMENT ON COLUMN "mdm_center"."note" IS '비고';

-- 사용_여부
COMMENT ON COLUMN "mdm_center"."use_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "mdm_center"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "mdm_center"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "mdm_center"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "mdm_center"."mod_dt" IS '수정일';

-- MDM_센터_PK
CREATE UNIQUE INDEX "mdm_center_PK"
	ON "mdm_center"
	( -- MDM_센터
		"center_seq" ASC -- 센터_SEQ
	)
;
-- MDM_센터
ALTER TABLE "mdm_center"
	ADD CONSTRAINT "mdm_center_PK"
		 -- MDM_센터_PK
	PRIMARY KEY 
	USING INDEX "mdm_center_PK";

-- MDM_센터_PK
COMMENT ON CONSTRAINT "mdm_center_PK" ON "mdm_center" IS 'MDM_센터_PK';

-- MDM_위치
CREATE TABLE "mdm_loc"
(
	"loc_seq"     bigint       NOT NULL DEFAULT nextval('mdm_loc_seq'), -- 위치_SEQ
	"wh_seq"      int4         NOT NULL, -- 창고_SEQ
	"rack_no"     varchar(100) NOT NULL DEFAULT '-', -- 랙_번호
	"row_no"      varchar(100) NULL,     -- 단_번호
	"column_no"   varchar(100) NULL,     -- 열_번호
	"loc_nm"      varchar(100) NOT NULL, -- 위치_명
	"loc_barcode" varchar(100) NULL,     -- 위치_BARCODE
	"def_loc_yn"  char(1)      NOT NULL DEFAULT 'N', -- 기본위치_여부
	"loc_mng_nm"  varchar(100) NULL,     -- 지정담당자
	"use_yn"      char(1)      NOT NULL DEFAULT 'Y', -- 사용_여부
	"reg_id"      varchar(20)  NOT NULL, -- 등록_ID
	"reg_dt"      timestamp    NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"      varchar(20)  NULL,     -- 수정_ID
	"mod_dt"      timestamp    NULL      -- 수정_일시
);

-- MDM_위치
COMMENT ON TABLE "mdm_loc" IS 'MDM_위치';

-- 위치_SEQ
COMMENT ON COLUMN "mdm_loc"."loc_seq" IS '위치_ID';

-- 창고_SEQ
COMMENT ON COLUMN "mdm_loc"."wh_seq" IS '창고_ID';

-- 랙_번호
COMMENT ON COLUMN "mdm_loc"."rack_no" IS '레벨내순서';

-- 단_번호
COMMENT ON COLUMN "mdm_loc"."row_no" IS '레벨내순서';

-- 열_번호
COMMENT ON COLUMN "mdm_loc"."column_no" IS '레벨내순서';

-- 위치_명
COMMENT ON COLUMN "mdm_loc"."loc_nm" IS '위치명';

-- 위치_BARCODE
COMMENT ON COLUMN "mdm_loc"."loc_barcode" IS '위치명';

-- 기본위치_여부
COMMENT ON COLUMN "mdm_loc"."def_loc_yn" IS '기본위치_여부';

-- 지정담당자
COMMENT ON COLUMN "mdm_loc"."loc_mng_nm" IS '지정담당자';

-- 사용_여부
COMMENT ON COLUMN "mdm_loc"."use_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "mdm_loc"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "mdm_loc"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "mdm_loc"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "mdm_loc"."mod_dt" IS '수정일';

-- MDM_위치_PK
CREATE UNIQUE INDEX "mdm_loc_PK"
	ON "mdm_loc"
	( -- MDM_위치
		"loc_seq" ASC -- 위치_SEQ
	)
;
-- MDM_위치
ALTER TABLE "mdm_loc"
	ADD CONSTRAINT "mdm_loc_PK"
		 -- MDM_위치_PK
	PRIMARY KEY 
	USING INDEX "mdm_loc_PK";

-- MDM_위치_PK
COMMENT ON CONSTRAINT "mdm_loc_PK" ON "mdm_loc" IS 'MDM_위치_PK';

-- MDM_전환품목
CREATE TABLE "mdm_rp_prod"
(
	"rp_prod_seq"     int4          NOT NULL DEFAULT nextval('mdm_rp_prod_seq'), -- 전환품목_SEQ
	"biz_seq"         int4          NOT NULL, -- 사업장_SEQ
	"st_yn"           char(1)       NOT NULL DEFAULT 'N', -- 기준품목_여부
	"ref_rp_prod_seq" int4          NULL,     -- 상위_전환품목_SEQ
	"prod_seq"        int4          NULL,     -- 품목_SEQ
	"qty"             decimal(10,2) NOT NULL DEFAULT 1.00, -- 수량
	"note"            varchar(1000) NOT NULL, -- 비고
	"del_yn"          char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"          varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"          timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"          varchar(20)   NULL,     -- 수정_ID
	"mod_dt"          timestamp     NULL      -- 수정_일시
);

-- MDM_전환품목
COMMENT ON TABLE "mdm_rp_prod" IS 'MDM_전환품목';

-- 전환품목_SEQ
COMMENT ON COLUMN "mdm_rp_prod"."rp_prod_seq" IS '전환품목_SEQ';

-- 사업장_SEQ
COMMENT ON COLUMN "mdm_rp_prod"."biz_seq" IS '사업장_SEQ';

-- 기준품목_여부
COMMENT ON COLUMN "mdm_rp_prod"."st_yn" IS '기준품목_여부';

-- 상위_전환품목_SEQ
COMMENT ON COLUMN "mdm_rp_prod"."ref_rp_prod_seq" IS '상위_전환품목_SEQ';

-- 품목_SEQ
COMMENT ON COLUMN "mdm_rp_prod"."prod_seq" IS '품목_SEQ';

-- 수량
COMMENT ON COLUMN "mdm_rp_prod"."qty" IS '수량';

-- 비고
COMMENT ON COLUMN "mdm_rp_prod"."note" IS '비고';

-- 삭제_여부
COMMENT ON COLUMN "mdm_rp_prod"."del_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "mdm_rp_prod"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "mdm_rp_prod"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "mdm_rp_prod"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "mdm_rp_prod"."mod_dt" IS '수정일';

-- MDM_전환품목_PK
CREATE UNIQUE INDEX "mdm_rp_prod_PK"
	ON "mdm_rp_prod"
	( -- MDM_전환품목
		"rp_prod_seq" ASC -- 전환품목_SEQ
	)
;
-- MDM_전환품목
ALTER TABLE "mdm_rp_prod"
	ADD CONSTRAINT "mdm_rp_prod_PK"
		 -- MDM_전환품목_PK
	PRIMARY KEY 
	USING INDEX "mdm_rp_prod_PK";

-- MDM_전환품목_PK
COMMENT ON CONSTRAINT "mdm_rp_prod_PK" ON "mdm_rp_prod" IS 'MDM_전환품목_PK';

-- MDM_차량
CREATE TABLE "mdm_car"
(
	"car_seq"     int4          NOT NULL DEFAULT nextval('mdm_car_seq'), -- 차량_SEQ
	"biz_seq"     int4          NOT NULL, -- 사업장_SEQ
	"car_no"      varchar(100)  NOT NULL, -- 차량_번호
	"car_div_cd"  varchar(50)   NOT NULL DEFAULT 'DIRECT', -- 차량_구분_코드
	"car_type_cd" varchar(50)   NOT NULL DEFAULT 'BOX', -- 차량_유형_코드
	"driver_nm"   varchar(100)  NULL,     -- 운전자_명
	"driver_tel"  varchar(500)  NULL,     -- 운전자_전화번호
	"cfd_cd"      varchar(50)   NOT NULL DEFAULT 'D', -- 냉장냉동상온_코드
	"cbm"         decimal(10,2) NULL     DEFAULT 0, -- CBM
	"length"      decimal(10,2) NULL     DEFAULT 0, -- 가로
	"width"       decimal(10,2) NULL     DEFAULT 0, -- 세로
	"height"      decimal(10,2) NULL     DEFAULT 0, -- 높이
	"wgt"         decimal(10,2) NULL     DEFAULT 0, -- 중량
	"self_yn"     char(1)       NOT NULL DEFAULT 'N', -- 자차_여부
	"use_yn"      char(1)       NOT NULL DEFAULT 'Y', -- 운행가능_여부
	"note"        varchar(1000) NULL,     -- 비고
	"del_yn"      char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"      varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"      timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"      varchar(20)   NULL,     -- 수정_ID
	"mod_dt"      timestamp     NULL      -- 수정_일시
);

-- MDM_차량
COMMENT ON TABLE "mdm_car" IS 'MDM_차량';

-- 차량_SEQ
COMMENT ON COLUMN "mdm_car"."car_seq" IS '차량번호';

-- 사업장_SEQ
COMMENT ON COLUMN "mdm_car"."biz_seq" IS '사업장_SEQ';

-- 차량_번호
COMMENT ON COLUMN "mdm_car"."car_no" IS '차량_번호';

-- 차량_구분_코드
COMMENT ON COLUMN "mdm_car"."car_div_cd" IS '차량_구분_코드';

-- 차량_유형_코드
COMMENT ON COLUMN "mdm_car"."car_type_cd" IS '차종_코드';

-- 운전자_명
COMMENT ON COLUMN "mdm_car"."driver_nm" IS '기본_운전자_아이디';

-- 운전자_전화번호
COMMENT ON COLUMN "mdm_car"."driver_tel" IS '전화';

-- 냉장냉동상온_코드
COMMENT ON COLUMN "mdm_car"."cfd_cd" IS '냉장냉동상온_코드';

-- CBM
COMMENT ON COLUMN "mdm_car"."cbm" IS 'CBM';

-- 가로
COMMENT ON COLUMN "mdm_car"."length" IS '가로';

-- 세로
COMMENT ON COLUMN "mdm_car"."width" IS '세로';

-- 높이
COMMENT ON COLUMN "mdm_car"."height" IS '높이';

-- 중량
COMMENT ON COLUMN "mdm_car"."wgt" IS '중량';

-- 자차_여부
COMMENT ON COLUMN "mdm_car"."self_yn" IS '자차_여부';

-- 운행가능_여부
COMMENT ON COLUMN "mdm_car"."use_yn" IS '운행가능_여부';

-- 비고
COMMENT ON COLUMN "mdm_car"."note" IS '비고';

-- 삭제_여부
COMMENT ON COLUMN "mdm_car"."del_yn" IS '삭제_여부';

-- 등록_ID
COMMENT ON COLUMN "mdm_car"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "mdm_car"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "mdm_car"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "mdm_car"."mod_dt" IS '수정일';

-- MDM_차량_PK
CREATE UNIQUE INDEX "mdm_car_PK"
	ON "mdm_car"
	( -- MDM_차량
		"car_seq" ASC -- 차량_SEQ
	)
;
-- MDM_차량
ALTER TABLE "mdm_car"
	ADD CONSTRAINT "mdm_car_PK"
		 -- MDM_차량_PK
	PRIMARY KEY 
	USING INDEX "mdm_car_PK";

-- MDM_차량_PK
COMMENT ON CONSTRAINT "mdm_car_PK" ON "mdm_car" IS 'MDM_차량_PK';

-- MDM_창고
CREATE TABLE "mdm_wh"
(
	"wh_seq"             int4         NOT NULL DEFAULT nextval('mdm_wh_seq'), -- 창고_SEQ
	"center_seq"         int4         NOT NULL, -- 센터_SEQ
	"wh_nm"              varchar(100) NOT NULL, -- 창고_명
	"wh_group_cd"        varchar(50)  NOT NULL, -- 창고_그룹_코드
	"in_yn"              char(1)      NOT NULL DEFAULT 'N', -- 입고처리_여부
	"return_yn"          char(1)      NOT NULL DEFAULT 'N', -- 반품처리_여부
	"pick_yn"            char(1)      NOT NULL DEFAULT 'N', -- 출고처리_여부
	"st_yn"              char(1)      NOT NULL DEFAULT 'N', -- 세트작업_여부
	"rp_yn"              char(1)      NOT NULL DEFAULT 'N', -- 전환처리_여부
	"out_yn"             char(1)      NOT NULL DEFAULT 'N', -- 출하처리_여부
	"etc_yn"             char(1)      NOT NULL DEFAULT 'N', -- 예외출고_여부
	"def_wh_yn"          char(1)      NOT NULL DEFAULT 'N', -- 기본창고_여부
	"available_inven_yn" char(1)      NOT NULL DEFAULT 'N', -- 가용재고_유무
	"cfd_cd"             varchar(50)  NOT NULL DEFAULT 'D', -- 냉장냉동상온_코드
	"use_yn"             char(1)      NOT NULL DEFAULT 'Y', -- 사용_여부
	"reg_id"             varchar(20)  NOT NULL, -- 등록_ID
	"reg_dt"             timestamp    NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"             varchar(20)  NULL,     -- 수정_ID
	"mod_dt"             timestamp    NULL      -- 수정_일시
);

-- MDM_창고
COMMENT ON TABLE "mdm_wh" IS 'MDM_창고';

-- 창고_SEQ
COMMENT ON COLUMN "mdm_wh"."wh_seq" IS '창고_ID';

-- 센터_SEQ
COMMENT ON COLUMN "mdm_wh"."center_seq" IS '센터_SEQ';

-- 창고_명
COMMENT ON COLUMN "mdm_wh"."wh_nm" IS '창고_명';

-- 창고_그룹_코드
COMMENT ON COLUMN "mdm_wh"."wh_group_cd" IS '창고그룹_코드';

-- 입고처리_여부
COMMENT ON COLUMN "mdm_wh"."in_yn" IS '입하창고_여부';

-- 반품처리_여부
COMMENT ON COLUMN "mdm_wh"."return_yn" IS '반입창고_여부';

-- 출고처리_여부
COMMENT ON COLUMN "mdm_wh"."pick_yn" IS '자재창고_여부';

-- 세트작업_여부
COMMENT ON COLUMN "mdm_wh"."st_yn" IS '출하창고_여부';

-- 전환처리_여부
COMMENT ON COLUMN "mdm_wh"."rp_yn" IS '출하창고_여부';

-- 출하처리_여부
COMMENT ON COLUMN "mdm_wh"."out_yn" IS '출하창고_여부';

-- 예외출고_여부
COMMENT ON COLUMN "mdm_wh"."etc_yn" IS '반입창고_여부';

-- 기본창고_여부
COMMENT ON COLUMN "mdm_wh"."def_wh_yn" IS '기본창고_여부';

-- 가용재고_유무
COMMENT ON COLUMN "mdm_wh"."available_inven_yn" IS '가용재고_유무';

-- 냉장냉동상온_코드
COMMENT ON COLUMN "mdm_wh"."cfd_cd" IS '냉장냉동상온_코드';

-- 사용_여부
COMMENT ON COLUMN "mdm_wh"."use_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "mdm_wh"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "mdm_wh"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "mdm_wh"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "mdm_wh"."mod_dt" IS '수정일';

-- MDM_창고_PK
CREATE UNIQUE INDEX "mdm_wh_PK"
	ON "mdm_wh"
	( -- MDM_창고
		"wh_seq" ASC -- 창고_SEQ
	)
;
-- MDM_창고
ALTER TABLE "mdm_wh"
	ADD CONSTRAINT "mdm_wh_PK"
		 -- MDM_창고_PK
	PRIMARY KEY 
	USING INDEX "mdm_wh_PK";

-- MDM_창고_PK
COMMENT ON CONSTRAINT "mdm_wh_PK" ON "mdm_wh" IS 'MDM_창고_PK';

-- MDM_품목
CREATE TABLE "mdm_prod"
(
	"prod_seq"               int4          NOT NULL DEFAULT nextval('mdm_prod_seq'), -- 품목_SEQ
	"if_prod_id"             varchar(50)   NULL,     -- IF_품목_ID
	"prod_no"                varchar(30)   NOT NULL, -- 품목_번호
	"prod_nm"                varchar(100)  NOT NULL, -- 품목_명
	"prod_nm_short"          varchar(100)  NULL,     -- 품목_명_약칭
	"prod_size"              varchar(100)  NULL,     -- 품목_규격
	"prod_div_cd"            varchar(50)   NULL,     -- 품목_분류_코드
	"large_cd"               varchar(50)   NULL,     -- 대분류_코드
	"middle_cd"              varchar(50)   NULL,     -- 중분류_코드
	"small_cd"               varchar(50)   NULL,     -- 소분류_코드
	"sku_mng_cd"             varchar(50)   NOT NULL DEFAULT 'N', -- SKU_관리_유형_코드
	"mng_ymd_mng_yn"         char(1)       NOT NULL DEFAULT 'N', -- 제조일자_관리_여부
	"eff_mng_yn"             char(1)       NOT NULL DEFAULT 'Y', -- 유통기한_관리_여부
	"eff_base"               smallint      NULL     DEFAULT 60, -- 유효기준
	"eff_base_unit_cd"       varchar(50)   NULL     DEFAULT 'DAYS', -- 유효기준_단위
	"lot_no_mng_yn"          char(1)       NOT NULL DEFAULT 'N', -- LOT번호_관리_여부
	"cn_mng_yn"              char(1)       NOT NULL DEFAULT 'N', -- CN_관리_여부
	"sku2_mng_yn"            char(1)       NOT NULL DEFAULT 'N', -- 파렛트_관리_여부
	"unit_cd"                varchar(50)   NOT NULL DEFAULT 'EA', -- 단위_코드
	"parent_unit_nm"         varchar(100)  NULL,     -- 상위_단위_명
	"in_qty"                 int2          NOT NULL DEFAULT 1, -- 입수량
	"imm_days"               smallint      NOT NULL DEFAULT 90, -- 임박기준_일수
	"prod_barcode"           varchar(100)  NULL,     -- 품목_BARCODE
	"parent_barcode"         varchar(100)  NULL,     -- 상위_품목_BARCODE
	"pallet_stack_qty"       int2          NOT NULL DEFAULT 1, -- 파렛트_배단_수
	"pallet_bottom_qty"      int2          NOT NULL DEFAULT 1, -- 파렛트_배면_수
	"file_seq"               int4          NULL,     -- 품목_파일_SEQ
	"label_paper_seq"        int4          NULL,     -- 라벨용지_SEQ
	"parent_label_paper_seq" int4          NULL,     -- 상위_라벨용지_SEQ
	"qc_yn"                  char(1)       NOT NULL DEFAULT 'N', -- 검사_여부
	"cfd_cd"                 varchar(50)   NULL     DEFAULT 'D', -- 냉장냉동상온_코드
	"hs_code"                varchar(50)   NULL,     -- HS_CODE
	"abc_cd"                 varchar(50)   NULL     DEFAULT 'D', -- ABC_코드
	"net_weight"             decimal(10,2) NULL     DEFAULT 0, -- 순중량
	"unit_pack_qty"          int2          NULL     DEFAULT 1, -- 단포수량
	"origin_cd"              varchar(50)   NULL,     -- 원산지_코드
	"inqty_pack"             int2          NULL     DEFAULT 0, -- 상품내_입수량
	"brand_cd"               varchar(50)   NULL,     -- 브랜드_코드
	"len_x"                  decimal(10,2) NULL     DEFAULT 1, -- 가로
	"len_y"                  decimal(10,2) NULL     DEFAULT 1, -- 세로
	"len_z"                  decimal(10,2) NULL     DEFAULT 1, -- 높이
	"wes_if_send_yn"         char(1)       NOT NULL DEFAULT 'N', -- WES_IF_송신_여부
	"wes_if_err_seq"         int4          NULL,     -- WES_IF_에러_일련번호
	"note"                   varchar(1000) NULL,     -- 비고
	"reg_id"                 varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"                 timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"                 varchar(20)   NULL,     -- 수정_ID
	"mod_dt"                 timestamp     NULL,     -- 수정_일시
	"barcode_type_cd"        varchar(50)   NULL,     -- 바코드_유형_코드
	"parent_barcode_type_cd" varchar(50)   NULL      -- 상위_바코드_유형_코드
);

-- MDM_품목
COMMENT ON TABLE "mdm_prod" IS 'MDM_품목';

-- 품목_SEQ
COMMENT ON COLUMN "mdm_prod"."prod_seq" IS '품목ID';

-- IF_품목_ID
COMMENT ON COLUMN "mdm_prod"."if_prod_id" IS '품목_IF_ID';

-- 품목_번호
COMMENT ON COLUMN "mdm_prod"."prod_no" IS '품목_번호';

-- 품목_명
COMMENT ON COLUMN "mdm_prod"."prod_nm" IS '품목_명';

-- 품목_명_약칭
COMMENT ON COLUMN "mdm_prod"."prod_nm_short" IS '품목_명_약칭';

-- 품목_규격
COMMENT ON COLUMN "mdm_prod"."prod_size" IS '품목_규격';

-- 품목_분류_코드
COMMENT ON COLUMN "mdm_prod"."prod_div_cd" IS '품목_분류CD';

-- 대분류_코드
COMMENT ON COLUMN "mdm_prod"."large_cd" IS '대분류_코드';

-- 중분류_코드
COMMENT ON COLUMN "mdm_prod"."middle_cd" IS '중분류_코드';

-- 소분류_코드
COMMENT ON COLUMN "mdm_prod"."small_cd" IS '소분류_코드';

-- SKU_관리_유형_코드
COMMENT ON COLUMN "mdm_prod"."sku_mng_cd" IS 'SKU_관리_유형_코드';

-- 제조일자_관리_여부
COMMENT ON COLUMN "mdm_prod"."mng_ymd_mng_yn" IS '제조일자_관리_여부';

-- 유통기한_관리_여부
COMMENT ON COLUMN "mdm_prod"."eff_mng_yn" IS '박스_여부';

-- 유효기준
COMMENT ON COLUMN "mdm_prod"."eff_base" IS '유효기준일수';

-- 유효기준_단위
COMMENT ON COLUMN "mdm_prod"."eff_base_unit_cd" IS '유효기준_단위';

-- LOT번호_관리_여부
COMMENT ON COLUMN "mdm_prod"."lot_no_mng_yn" IS 'LOT번호_관리_여부';

-- CN_관리_여부
COMMENT ON COLUMN "mdm_prod"."cn_mng_yn" IS 'CN_관리_여부';

-- 파렛트_관리_여부
COMMENT ON COLUMN "mdm_prod"."sku2_mng_yn" IS '파렛트_관리_여부';

-- 단위_코드
COMMENT ON COLUMN "mdm_prod"."unit_cd" IS '단위CD';

-- 상위_단위_명
COMMENT ON COLUMN "mdm_prod"."parent_unit_nm" IS '상위_단위_명';

-- 입수량
COMMENT ON COLUMN "mdm_prod"."in_qty" IS '입수량';

-- 임박기준_일수
COMMENT ON COLUMN "mdm_prod"."imm_days" IS '임박기준일수';

-- 품목_BARCODE
COMMENT ON COLUMN "mdm_prod"."prod_barcode" IS '품목_BARCODE';

-- 상위_품목_BARCODE
COMMENT ON COLUMN "mdm_prod"."parent_barcode" IS '상위_품목_BARCODE';

-- 파렛트_배단_수
COMMENT ON COLUMN "mdm_prod"."pallet_stack_qty" IS '파렛트_배단_수';

-- 파렛트_배면_수
COMMENT ON COLUMN "mdm_prod"."pallet_bottom_qty" IS '파렛트_배면_수';

-- 품목_파일_SEQ
COMMENT ON COLUMN "mdm_prod"."file_seq" IS '품목_파일_SEQ';

-- 라벨용지_SEQ
COMMENT ON COLUMN "mdm_prod"."label_paper_seq" IS '품목ID';

-- 상위_라벨용지_SEQ
COMMENT ON COLUMN "mdm_prod"."parent_label_paper_seq" IS '상위_라벨용지_SEQ';

-- 검사_여부
COMMENT ON COLUMN "mdm_prod"."qc_yn" IS '검사품_여부';

-- 냉장냉동상온_코드
COMMENT ON COLUMN "mdm_prod"."cfd_cd" IS '공급_구분_코드';

-- HS_CODE
COMMENT ON COLUMN "mdm_prod"."hs_code" IS '공급_구분_코드';

-- ABC_코드
COMMENT ON COLUMN "mdm_prod"."abc_cd" IS 'ABC_코드';

-- 순중량
COMMENT ON COLUMN "mdm_prod"."net_weight" IS '순중량';

-- 단포수량
COMMENT ON COLUMN "mdm_prod"."unit_pack_qty" IS '단포수량';

-- 원산지_코드
COMMENT ON COLUMN "mdm_prod"."origin_cd" IS '원산지_코드';

-- 상품내_입수량
COMMENT ON COLUMN "mdm_prod"."inqty_pack" IS '상품내_입수량';

-- 브랜드_코드
COMMENT ON COLUMN "mdm_prod"."brand_cd" IS '브랜드_코드';

-- 가로
COMMENT ON COLUMN "mdm_prod"."len_x" IS '가로';

-- 세로
COMMENT ON COLUMN "mdm_prod"."len_y" IS '세로';

-- 높이
COMMENT ON COLUMN "mdm_prod"."len_z" IS '높이';

-- WES_IF_송신_여부
COMMENT ON COLUMN "mdm_prod"."wes_if_send_yn" IS 'ERP_송신_여부';

-- WES_IF_에러_일련번호
COMMENT ON COLUMN "mdm_prod"."wes_if_err_seq" IS 'IF_에러_일련번호';

-- 비고
COMMENT ON COLUMN "mdm_prod"."note" IS '備考';

-- 등록_ID
COMMENT ON COLUMN "mdm_prod"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "mdm_prod"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "mdm_prod"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "mdm_prod"."mod_dt" IS '수정일';

-- 바코드_유형_코드
COMMENT ON COLUMN "mdm_prod"."barcode_type_cd" IS '바코드_유형_코드';

-- 상위_바코드_유형_코드
COMMENT ON COLUMN "mdm_prod"."parent_barcode_type_cd" IS '상위_바코드_유형_코드';

-- MDM_품목_PK
CREATE UNIQUE INDEX "mdm_prod_PK"
	ON "mdm_prod"
	( -- MDM_품목
		"prod_seq" ASC -- 품목_SEQ
	)
;
-- MDM_품목
ALTER TABLE "mdm_prod"
	ADD CONSTRAINT "mdm_prod_PK"
		 -- MDM_품목_PK
	PRIMARY KEY 
	USING INDEX "mdm_prod_PK";

-- MDM_품목_PK
COMMENT ON CONSTRAINT "mdm_prod_PK" ON "mdm_prod" IS 'MDM_품목_PK';

-- SIF_배치_이력
CREATE TABLE "sif_batch_history"
(
	"if_seq"        int4         NOT NULL DEFAULT nextval('sif_batch_history_seq'::regclass), -- IF_SEQ
	"biz_seq"       int4         NULL,     -- 사업장_SEQ
	"if_id"         varchar(50)  NOT NULL, -- IF_ID
	"if_nm"         varchar(100) NOT NULL, -- IF_명
	"if_system_cd"  varchar(50)  NOT NULL DEFAULT 'WMS', -- IF_시스템_코드
	"if_type_cd"    varchar(50)  NOT NULL DEFAULT 'N', -- 배치_유형_코드
	"if_status_cd"  varchar(50)  NOT NULL, -- 배치_상태_코드
	"req_ymd"       varchar(8)   NULL,     -- 요청_연월일
	"req_hms"       varchar(6)   NULL,     -- 요청_시분초
	"req_json_data" text         NULL,     -- 요청_데이터
	"res_ymd"       varchar(8)   NULL,     -- 수신_연월일
	"res_hms"       varchar(6)   NULL,     -- 수신_시분초
	"res_json_data" text         NULL,     -- 수신_데이터
	"res_cnt"       int2         NULL     DEFAULT 0, -- 수신_카운터
	"sif_cnt"       int2         NULL     DEFAULT 0, -- CIF_카운터
	"wms_cnt"       int2         NULL     DEFAULT 0, -- WMS_카운터
	"err_key"       text         NULL,     -- 에러_키(수신시)
	"err_msg"       text         NULL,     -- 에러_메세지
	"end_ymd"       varchar(8)   NULL,     -- 종료_연월일
	"end_hms"       varchar(6)   NULL,     -- 종료_시분초
	"re_send_yn"    char(1)      NOT NULL DEFAULT 'N', -- 재전송_유무
	"org_if_seq"    int4         NULL,     -- 원_IF_SEQ
	"reg_id"        varchar(20)  NOT NULL, -- 등록_ID
	"reg_dt"        timestamp    NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"        varchar(20)  NULL,     -- 수정_ID
	"mod_dt"        timestamp    NULL      -- 수정_일시
);

-- SIF_배치_이력
COMMENT ON TABLE "sif_batch_history" IS 'SIF_배치_이력';

-- IF_SEQ
COMMENT ON COLUMN "sif_batch_history"."if_seq" IS 'IF_SEQ';

-- 사업장_SEQ
COMMENT ON COLUMN "sif_batch_history"."biz_seq" IS '사업장_SEQ';

-- IF_ID
COMMENT ON COLUMN "sif_batch_history"."if_id" IS 'IF_ID';

-- IF_명
COMMENT ON COLUMN "sif_batch_history"."if_nm" IS 'IF_명';

-- IF_시스템_코드
COMMENT ON COLUMN "sif_batch_history"."if_system_cd" IS 'IF_시스템_코드';

-- 배치_유형_코드
COMMENT ON COLUMN "sif_batch_history"."if_type_cd" IS '배치_유형_코드';

-- 배치_상태_코드
COMMENT ON COLUMN "sif_batch_history"."if_status_cd" IS '배치_상태_코드';

-- 요청_연월일
COMMENT ON COLUMN "sif_batch_history"."req_ymd" IS '요청_일자';

-- 요청_시분초
COMMENT ON COLUMN "sif_batch_history"."req_hms" IS '요청_시간';

-- 요청_데이터
COMMENT ON COLUMN "sif_batch_history"."req_json_data" IS '요청_데이터';

-- 수신_연월일
COMMENT ON COLUMN "sif_batch_history"."res_ymd" IS '수신_일자';

-- 수신_시분초
COMMENT ON COLUMN "sif_batch_history"."res_hms" IS '수신_시간';

-- 수신_데이터
COMMENT ON COLUMN "sif_batch_history"."res_json_data" IS '수신_데이터';

-- 수신_카운터
COMMENT ON COLUMN "sif_batch_history"."res_cnt" IS '수신_카운터';

-- CIF_카운터
COMMENT ON COLUMN "sif_batch_history"."sif_cnt" IS 'CIF_카운터';

-- WMS_카운터
COMMENT ON COLUMN "sif_batch_history"."wms_cnt" IS 'WMS_카운터';

-- 에러_키(수신시)
COMMENT ON COLUMN "sif_batch_history"."err_key" IS '에러_키(수신시)';

-- 에러_메세지
COMMENT ON COLUMN "sif_batch_history"."err_msg" IS '에러_메세지';

-- 종료_연월일
COMMENT ON COLUMN "sif_batch_history"."end_ymd" IS '종료_일자';

-- 종료_시분초
COMMENT ON COLUMN "sif_batch_history"."end_hms" IS '종료_시간';

-- 재전송_유무
COMMENT ON COLUMN "sif_batch_history"."re_send_yn" IS '재전송_유무';

-- 원_IF_SEQ
COMMENT ON COLUMN "sif_batch_history"."org_if_seq" IS 'IF_SEQ';

-- 등록_ID
COMMENT ON COLUMN "sif_batch_history"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "sif_batch_history"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "sif_batch_history"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "sif_batch_history"."mod_dt" IS '수정일';

-- SIF_배치_이력_PK
CREATE UNIQUE INDEX "sif_batch_history_PK"
	ON "sif_batch_history"
	( -- SIF_배치_이력
		"if_seq" ASC -- IF_SEQ
	)
;
-- SIF_배치_이력
ALTER TABLE "sif_batch_history"
	ADD CONSTRAINT "sif_batch_history_PK"
		 -- SIF_배치_이력_PK
	PRIMARY KEY 
	USING INDEX "sif_batch_history_PK";

-- SIF_배치_이력_PK
COMMENT ON CONSTRAINT "sif_batch_history_PK" ON "sif_batch_history" IS 'SIF_배치_이력_PK';

-- WES_처리_이력
CREATE TABLE "wes_process_history"
(
	"wes_proc_seq"       int4          NOT NULL DEFAULT nextval('wes_proc_seq'), -- WES_처리_SEQ
	"biz_seq"            int4          NOT NULL, -- 사업장_SEQ
	"if_seq"             int4          NULL,     -- IF_SEQ
	"wes_proc_no"        int4          NOT NULL DEFAULT 0, -- WES_처리_묶음
	"invoice_seq"        int4          NOT NULL, -- 송장_SEQ
	"parent_invoice_seq" int4          NULL,     -- 부모_송장_SEQ
	"invoice_no"         varchar(30)   NULL,     -- 송장_번호
	"add_invoice_yn"     char(1)       NOT NULL DEFAULT 'N', -- 추가_송장_여부
	"proc_ymd"           varchar(8)    NULL,     -- 처리_연월일(WES)
	"proc_hms"           varchar(6)    NULL,     -- 처리_시분초(WES)
	"proc_user_id"       varchar(20)   NULL,     -- 처리_자_ID(WES)
	"invoice_prod_seq"   bigint        NULL,     -- 송장_품목_SEQ
	"prod_seq"           int4          NOT NULL, -- 품목_SEQ
	"proc_qty"           decimal(10,2) NOT NULL DEFAULT 0, -- 처리_수량(송장)
	"proc_yn"            char(1)       NOT NULL DEFAULT 'N', -- 처리_여부
	"err_msg"            text          NULL,     -- 에러_메세지
	"wms_proc_ymd"       varchar(8)    NULL,     -- 처리_연월일(WMS)
	"wms_proc_hms"       varchar(6)    NULL      -- 처리_시분초(WMS)
);

-- WES_처리_이력
COMMENT ON TABLE "wes_process_history" IS 'WES_처리_이력';

-- WES_처리_SEQ
COMMENT ON COLUMN "wes_process_history"."wes_proc_seq" IS 'WES_처리_시퀀스';

-- 사업장_SEQ
COMMENT ON COLUMN "wes_process_history"."biz_seq" IS '사업장_ID';

-- IF_SEQ
COMMENT ON COLUMN "wes_process_history"."if_seq" IS 'IF_SEQ';

-- WES_처리_묶음
COMMENT ON COLUMN "wes_process_history"."wes_proc_no" IS 'WES_처리_묶음';

-- 송장_SEQ
COMMENT ON COLUMN "wes_process_history"."invoice_seq" IS '송장_시퀀스';

-- 부모_송장_SEQ
COMMENT ON COLUMN "wes_process_history"."parent_invoice_seq" IS '부모_송장_시퀀스';

-- 송장_번호
COMMENT ON COLUMN "wes_process_history"."invoice_no" IS '송장_번호';

-- 추가_송장_여부
COMMENT ON COLUMN "wes_process_history"."add_invoice_yn" IS '추가_송장_여부';

-- 처리_연월일(WES)
COMMENT ON COLUMN "wes_process_history"."proc_ymd" IS '처리_일자';

-- 처리_시분초(WES)
COMMENT ON COLUMN "wes_process_history"."proc_hms" IS '처리_시분초';

-- 처리_자_ID(WES)
COMMENT ON COLUMN "wes_process_history"."proc_user_id" IS '처리_자';

-- 송장_품목_SEQ
COMMENT ON COLUMN "wes_process_history"."invoice_prod_seq" IS '송장_품목_시퀀스';

-- 품목_SEQ
COMMENT ON COLUMN "wes_process_history"."prod_seq" IS '품목_시퀀스';

-- 처리_수량(송장)
COMMENT ON COLUMN "wes_process_history"."proc_qty" IS '처리_수량';

-- 처리_여부
COMMENT ON COLUMN "wes_process_history"."proc_yn" IS '처리_여부';

-- 에러_메세지
COMMENT ON COLUMN "wes_process_history"."err_msg" IS '에러_메세지';

-- 처리_연월일(WMS)
COMMENT ON COLUMN "wes_process_history"."wms_proc_ymd" IS '처리_일자';

-- 처리_시분초(WMS)
COMMENT ON COLUMN "wes_process_history"."wms_proc_hms" IS '처리_시분초';

-- WES_처리_이력_PK
CREATE UNIQUE INDEX "wes_process_history_PK"
	ON "wes_process_history"
	( -- WES_처리_이력
		"wes_proc_seq" ASC -- WES_처리_SEQ
	)
;
-- WES_처리_이력
ALTER TABLE "wes_process_history"
	ADD CONSTRAINT "wes_process_history_PK"
		 -- WES_처리_이력_PK
	PRIMARY KEY 
	USING INDEX "wes_process_history_PK";

-- WES_처리_이력_PK
COMMENT ON CONSTRAINT "wes_process_history_PK" ON "wes_process_history" IS 'WES_처리_이력_PK';

-- WMS_반품
CREATE TABLE "wms_return"
(
	"return_seq"     int4          NOT NULL DEFAULT nextval('wms_return_seq'), -- 반품_SEQ
	"biz_seq"        int4          NOT NULL, -- 사업장_SEQ
	"return_no"      varchar(30)   NOT NULL, -- 반품_번호
	"center_seq"     int4          NOT NULL, -- 센터_SEQ
	"return_type_cd" varchar(50)   NOT NULL, -- 반품_유형_코드
	"return_sts_cd"  varchar(50)   NOT NULL, -- 반품_상태_코드
	"req_ymd"        varchar(8)    NOT NULL, -- 예정_연월일(반품)
	"req_hms"        varchar(6)    NULL,     -- 예정_시분초(반품)
	"req_user_nm"    varchar(100)  NULL,     -- 요청_사용자_명(반품)
	"cont_seq"       int4          NULL,     -- 거래처_SEQ
	"cfm_ymd"        varchar(8)    NULL,     -- 확정_연월일(반품)
	"cfm_hms"        varchar(6)    NULL,     -- 확정_시분초(반품)
	"cfm_user_id"    varchar(20)   NULL,     -- 확정_자_ID(반품)
	"req_no"         varchar(30)   NULL,     -- 문서_번호(타시스템)
	"erp_wh_cd"      varchar(50)   NULL,     -- 반품처_CODE(타시스템)
	"outbiz_seq"     int4          NULL,     -- 출하번호
	"note"           varchar(1000) NULL,     -- 비고
	"if_key"         varchar(50)   NULL,     -- IF_KEY
	"if_err_seq"     int4          NULL,     -- IF_에러_일련번호
	"if_send_yn"     char(1)       NOT NULL DEFAULT 'N', -- IF_송신_여부
	"del_yn"         char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"         varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"         timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"         varchar(20)   NULL,     -- 수정_ID
	"mod_dt"         timestamp     NULL      -- 수정_일시
);

-- WMS_반품
COMMENT ON TABLE "wms_return" IS 'WMS_반품';

-- 반품_SEQ
COMMENT ON COLUMN "wms_return"."return_seq" IS '반품_SEQ';

-- 사업장_SEQ
COMMENT ON COLUMN "wms_return"."biz_seq" IS '사업장_ID';

-- 반품_번호
COMMENT ON COLUMN "wms_return"."return_no" IS '입고_요청_번호';

-- 센터_SEQ
COMMENT ON COLUMN "wms_return"."center_seq" IS '센터_SEQ';

-- 반품_유형_코드
COMMENT ON COLUMN "wms_return"."return_type_cd" IS '입고_유형_코드';

-- 반품_상태_코드
COMMENT ON COLUMN "wms_return"."return_sts_cd" IS '입고_요청_상태_코드';

-- 예정_연월일(반품)
COMMENT ON COLUMN "wms_return"."req_ymd" IS '입고_요청_일자';

-- 예정_시분초(반품)
COMMENT ON COLUMN "wms_return"."req_hms" IS '입고_요청_시간';

-- 요청_사용자_명(반품)
COMMENT ON COLUMN "wms_return"."req_user_nm" IS '입고_요청자_아이디';

-- 거래처_SEQ
COMMENT ON COLUMN "wms_return"."cont_seq" IS '거래처_ID';

-- 확정_연월일(반품)
COMMENT ON COLUMN "wms_return"."cfm_ymd" IS '입고_확정_일자';

-- 확정_시분초(반품)
COMMENT ON COLUMN "wms_return"."cfm_hms" IS '입고_확정_시간';

-- 확정_자_ID(반품)
COMMENT ON COLUMN "wms_return"."cfm_user_id" IS '입고_확인자_아이디';

-- 문서_번호(타시스템)
COMMENT ON COLUMN "wms_return"."req_no" IS '증빙번호';

-- 반품처_CODE(타시스템)
COMMENT ON COLUMN "wms_return"."erp_wh_cd" IS '반품처_CODE(타시스템)';

-- 출하번호
COMMENT ON COLUMN "wms_return"."outbiz_seq" IS '출하번호';

-- 비고
COMMENT ON COLUMN "wms_return"."note" IS '비고';

-- IF_KEY
COMMENT ON COLUMN "wms_return"."if_key" IS '발주내부_코드(ERP)';

-- IF_에러_일련번호
COMMENT ON COLUMN "wms_return"."if_err_seq" IS 'IF_에러_일련번호';

-- IF_송신_여부
COMMENT ON COLUMN "wms_return"."if_send_yn" IS 'ERP_송신_여부';

-- 삭제_여부
COMMENT ON COLUMN "wms_return"."del_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "wms_return"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_return"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_return"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_return"."mod_dt" IS '수정일';

-- WMS_RETURN_IDX01
CREATE UNIQUE INDEX "UIX_wms_return"
	ON "wms_return"
	( -- WMS_반품
		"biz_seq" ASC, -- 사업장_SEQ
		"return_no" ASC -- 반품_번호
	);

-- WMS_RETURN_IDX01
COMMENT ON INDEX "UIX_wms_return" IS 'WMS_RETURN_IDX01';

-- WMS_반품 인덱스
CREATE INDEX "IX_wms_return"
	ON "wms_return"	( -- WMS_반품
		"biz_seq" ASC, -- 사업장_SEQ
		"center_seq" ASC, -- 센터_SEQ
		"req_ymd" ASC -- 예정_연월일(반품)
	);

-- WMS_반품 인덱스
COMMENT ON INDEX "IX_wms_return" IS 'WMS_반품 인덱스';

-- WMS_반품_PK
CREATE UNIQUE INDEX "wms_return_PK"
	ON "wms_return"
	( -- WMS_반품
		"return_seq" ASC -- 반품_SEQ
	)
;
-- WMS_반품
ALTER TABLE "wms_return"
	ADD CONSTRAINT "wms_return_PK"
		 -- WMS_반품_PK
	PRIMARY KEY 
	USING INDEX "wms_return_PK";

-- WMS_반품_PK
COMMENT ON CONSTRAINT "wms_return_PK" ON "wms_return" IS 'WMS_반품_PK';

-- WMS_반품
ALTER TABLE "wms_return"
	ADD CONSTRAINT "UK_wms_return" -- WMS_반품 유니크 제약
	UNIQUE 
	USING INDEX "UIX_wms_return";

-- WMS_반품 유니크 제약
COMMENT ON CONSTRAINT "UK_wms_return" ON "wms_return" IS 'WMS_반품 유니크 제약';

-- WMS_반품_처리
CREATE TABLE "wms_return_tran"
(
	"return_tran_seq" bigint        NOT NULL DEFAULT nextval('wms_return_tran_seq'), -- 반품_처리_SEQ
	"return_prod_seq" bigint        NOT NULL, -- 반품_품목_SEQ
	"return_seq"      int4          NOT NULL, -- 반품_SEQ
	"prod_seq"        int4          NOT NULL, -- 품목_SEQ
	"sku1"            varchar(100)  NOT NULL, -- SKU1
	"sku2"            varchar(100)  NOT NULL, -- SKU2 
	"mng_ymd"         varchar(8)    NULL,     -- 입고/제조일자
	"exp_ymd"         varchar(8)    NULL,     -- 유통기한_연월일
	"lot_no"          varchar(30)   NULL,     -- LOT_NO
	"proc_qty"        decimal(10,2) NOT NULL DEFAULT 0, -- 처리_수량(반품)
	"ex_qty"          decimal(10,2) NOT NULL DEFAULT 0, -- 기처리_수량(반품)
	"to_wh_seq"       int4          NOT NULL, -- TO_창고_SEQ
	"to_loc_seq"      bigint        NOT NULL, -- TO_위치_SEQ
	"proc_bundle_no"  varchar(30)   NULL,     -- 처리_묶음_번호
	"proc_ymd"        varchar(8)    NULL,     -- 처리_연월일(반품)
	"proc_hms"        varchar(6)    NULL,     -- 처리_시분초(반품)
	"proc_user_id"    varchar(20)   NULL,     -- 처리_자_ID(반품)
	"if_err_seq"      int4          NULL,     -- IF_에러_일련번호
	"if_send_yn"      char(1)       NOT NULL DEFAULT 'N', -- IF_송신_여부
	"del_yn"          char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"          varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"          timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"          varchar(20)   NULL,     -- 수정_ID
	"mod_dt"          timestamp     NULL      -- 수정_일시
);

-- WMS_반품_처리
COMMENT ON TABLE "wms_return_tran" IS 'WMS_반품_처리';

-- 반품_처리_SEQ
COMMENT ON COLUMN "wms_return_tran"."return_tran_seq" IS '반품_처리_SEQ';

-- 반품_품목_SEQ
COMMENT ON COLUMN "wms_return_tran"."return_prod_seq" IS '반품_품목_SEQ';

-- 반품_SEQ
COMMENT ON COLUMN "wms_return_tran"."return_seq" IS '반품_SEQ';

-- 품목_SEQ
COMMENT ON COLUMN "wms_return_tran"."prod_seq" IS '품목ID';

-- SKU1
COMMENT ON COLUMN "wms_return_tran"."sku1" IS 'SKU1(FR)';

-- SKU2 
COMMENT ON COLUMN "wms_return_tran"."sku2" IS 'SKU2(FR)';

-- 입고/제조일자
COMMENT ON COLUMN "wms_return_tran"."mng_ymd" IS '입고/제조일자';

-- 유통기한_연월일
COMMENT ON COLUMN "wms_return_tran"."exp_ymd" IS '유통기한_연월일';

-- LOT_NO
COMMENT ON COLUMN "wms_return_tran"."lot_no" IS 'LOT_NO';

-- 처리_수량(반품)
COMMENT ON COLUMN "wms_return_tran"."proc_qty" IS '입고_수량';

-- 기처리_수량(반품)
COMMENT ON COLUMN "wms_return_tran"."ex_qty" IS '기입고_처리량';

-- TO_창고_SEQ
COMMENT ON COLUMN "wms_return_tran"."to_wh_seq" IS '창고(TO)';

-- TO_위치_SEQ
COMMENT ON COLUMN "wms_return_tran"."to_loc_seq" IS '위치(TO)';

-- 처리_묶음_번호
COMMENT ON COLUMN "wms_return_tran"."proc_bundle_no" IS '처리_묶음_번호';

-- 처리_연월일(반품)
COMMENT ON COLUMN "wms_return_tran"."proc_ymd" IS '입고_일자';

-- 처리_시분초(반품)
COMMENT ON COLUMN "wms_return_tran"."proc_hms" IS '입고_시간';

-- 처리_자_ID(반품)
COMMENT ON COLUMN "wms_return_tran"."proc_user_id" IS '입고_작업자_아이디';

-- IF_에러_일련번호
COMMENT ON COLUMN "wms_return_tran"."if_err_seq" IS 'IF_에러_일련번호';

-- IF_송신_여부
COMMENT ON COLUMN "wms_return_tran"."if_send_yn" IS 'ERP_송신_여부';

-- 삭제_여부
COMMENT ON COLUMN "wms_return_tran"."del_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "wms_return_tran"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_return_tran"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_return_tran"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_return_tran"."mod_dt" IS '수정일';

-- WMS_반품_처리_PK
CREATE UNIQUE INDEX "wms_return_tran_PK"
	ON "wms_return_tran"
	( -- WMS_반품_처리
		"return_tran_seq" ASC, -- 반품_처리_SEQ
		"return_prod_seq" ASC, -- 반품_품목_SEQ
		"return_seq" ASC -- 반품_SEQ
	)
;
-- WMS_반품_처리
ALTER TABLE "wms_return_tran"
	ADD CONSTRAINT "wms_return_tran_PK"
		 -- WMS_반품_처리_PK
	PRIMARY KEY 
	USING INDEX "wms_return_tran_PK";

-- WMS_반품_처리_PK
COMMENT ON CONSTRAINT "wms_return_tran_PK" ON "wms_return_tran" IS 'WMS_반품_처리_PK';

-- WMS_반품_품목
CREATE TABLE "wms_return_prod"
(
	"return_prod_seq"    bigint        NOT NULL DEFAULT nextval('wms_return_prod_seq'), -- 반품_품목_SEQ
	"return_seq"         int4          NOT NULL, -- 반품_SEQ
	"prod_seq"           int4          NOT NULL, -- 품목_SEQ
	"return_prod_sts_cd" varchar(50)   NOT NULL, -- 반품_품목_상태_코드
	"req_qty"            decimal(10,2) NOT NULL DEFAULT 0, -- 요청_수량(반품)
	"ex_qty"             decimal(10,2) NOT NULL DEFAULT 0, -- 기처리_수량(반품)
	"est_exp_ymd"        varchar(8)    NULL,     -- 예상_유통기한
	"est_mng_ymd"        varchar(8)    NULL,     -- 예상_입고/제조일자
	"est_lot_no"         varchar(30)   NULL,     -- 예상_LOT_NO
	"pub_sku1_yn"        char(1)       NOT NULL DEFAULT 'N', -- SKU1_발행여부
	"pub_sku2_yn"        char(1)       NOT NULL DEFAULT 'N', -- SKU2_발행여부
	"pltzing_yn"         char(1)       NOT NULL DEFAULT 'N', -- 파렛타이징_여부
	"if_send_yn"         char(1)       NOT NULL DEFAULT 'N', -- IF_송신_여부
	"if_idx"             varchar(20)   NULL,     -- IF_내부순번
	"if_err_seq"         int4          NULL,     -- IF_에러_일련번호
	"del_yn"             char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"             varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"             timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"             varchar(20)   NULL,     -- 수정_ID
	"mod_dt"             timestamp     NULL      -- 수정_일시
);

-- WMS_반품_품목
COMMENT ON TABLE "wms_return_prod" IS 'WMS_반품_품목';

-- 반품_품목_SEQ
COMMENT ON COLUMN "wms_return_prod"."return_prod_seq" IS '반품_품목_SEQ';

-- 반품_SEQ
COMMENT ON COLUMN "wms_return_prod"."return_seq" IS '반품_SEQ';

-- 품목_SEQ
COMMENT ON COLUMN "wms_return_prod"."prod_seq" IS '품목ID';

-- 반품_품목_상태_코드
COMMENT ON COLUMN "wms_return_prod"."return_prod_sts_cd" IS '입고_상태_코드';

-- 요청_수량(반품)
COMMENT ON COLUMN "wms_return_prod"."req_qty" IS '입고_요청_수량';

-- 기처리_수량(반품)
COMMENT ON COLUMN "wms_return_prod"."ex_qty" IS '기입고_처리량';

-- 예상_유통기한
COMMENT ON COLUMN "wms_return_prod"."est_exp_ymd" IS '예상_유통기한';

-- 예상_입고/제조일자
COMMENT ON COLUMN "wms_return_prod"."est_mng_ymd" IS '예상_입고/제조일자';

-- 예상_LOT_NO
COMMENT ON COLUMN "wms_return_prod"."est_lot_no" IS '예상_LOT_NO';

-- SKU1_발행여부
COMMENT ON COLUMN "wms_return_prod"."pub_sku1_yn" IS 'SKU1_발행여부';

-- SKU2_발행여부
COMMENT ON COLUMN "wms_return_prod"."pub_sku2_yn" IS 'SKU2_발행여부';

-- 파렛타이징_여부
COMMENT ON COLUMN "wms_return_prod"."pltzing_yn" IS '파렛타이징_여부';

-- IF_송신_여부
COMMENT ON COLUMN "wms_return_prod"."if_send_yn" IS 'ERP_송신_여부';

-- IF_내부순번
COMMENT ON COLUMN "wms_return_prod"."if_idx" IS '순번 --';

-- IF_에러_일련번호
COMMENT ON COLUMN "wms_return_prod"."if_err_seq" IS 'IF_에러_일련번호';

-- 삭제_여부
COMMENT ON COLUMN "wms_return_prod"."del_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "wms_return_prod"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_return_prod"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_return_prod"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_return_prod"."mod_dt" IS '수정일';

-- WMS_반품_품목_PK
CREATE UNIQUE INDEX "wms_return_prod_PK"
	ON "wms_return_prod"
	( -- WMS_반품_품목
		"return_prod_seq" ASC, -- 반품_품목_SEQ
		"return_seq" ASC -- 반품_SEQ
	)
;
-- WMS_반품_품목
ALTER TABLE "wms_return_prod"
	ADD CONSTRAINT "wms_return_prod_PK"
		 -- WMS_반품_품목_PK
	PRIMARY KEY 
	USING INDEX "wms_return_prod_PK";

-- WMS_반품_품목_PK
COMMENT ON CONSTRAINT "wms_return_prod_PK" ON "wms_return_prod" IS 'WMS_반품_품목_PK';

-- WMS_상차
CREATE TABLE "wms_load"
(
	"load_seq"    int4          NOT NULL DEFAULT nextval('wms_load_seq'), -- 상차_SEQ
	"biz_seq"     int4          NOT NULL, -- 사업장_SEQ
	"load_no"     varchar(30)   NOT NULL, -- 상차_번호
	"center_seq"  int4          NOT NULL, -- 센터_SEQ
	"load_sts_cd" varchar(50)   NOT NULL, -- 상차_상태_코드
	"car_seq"     int4          NULL,     -- 차량_SEQ
	"driver_nm"   varchar(100)  NULL,     -- 운전자_성명
	"driver_tel"  varchar(500)  NULL,     -- 운전자_전화번호
	"load_idx"    int2          NULL     DEFAULT 0, -- 차수
	"proc_ymd"    varchar(8)    NULL,     -- 처리_연월일(상차)
	"proc_hms"    varchar(6)    NULL,     -- 처리_시분초(상차)
	"cfm_ymd"     varchar(8)    NULL,     -- 확정_연월일(상차)
	"cfm_hms"     varchar(6)    NULL,     -- 확정_시분초(상차)
	"note"        varchar(1000) NULL,     -- 비고
	"del_yn"      char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"      varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"      timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"      varchar(20)   NULL,     -- 수정_ID
	"mod_dt"      timestamp     NULL      -- 수정_일시
);

-- WMS_상차
COMMENT ON TABLE "wms_load" IS 'WMS_상차';

-- 상차_SEQ
COMMENT ON COLUMN "wms_load"."load_seq" IS '상차_SEQ';

-- 사업장_SEQ
COMMENT ON COLUMN "wms_load"."biz_seq" IS '사업장_ID';

-- 상차_번호
COMMENT ON COLUMN "wms_load"."load_no" IS '출하_예정_번호';

-- 센터_SEQ
COMMENT ON COLUMN "wms_load"."center_seq" IS '센터_SEQ';

-- 상차_상태_코드
COMMENT ON COLUMN "wms_load"."load_sts_cd" IS '출하_상태_코드';

-- 차량_SEQ
COMMENT ON COLUMN "wms_load"."car_seq" IS '차량_SEQ';

-- 운전자_성명
COMMENT ON COLUMN "wms_load"."driver_nm" IS '운전자_성명';

-- 운전자_전화번호
COMMENT ON COLUMN "wms_load"."driver_tel" IS '운전자_전화번호';

-- 차수
COMMENT ON COLUMN "wms_load"."load_idx" IS '차수';

-- 처리_연월일(상차)
COMMENT ON COLUMN "wms_load"."proc_ymd" IS '입고_일자';

-- 처리_시분초(상차)
COMMENT ON COLUMN "wms_load"."proc_hms" IS '입고_시간';

-- 확정_연월일(상차)
COMMENT ON COLUMN "wms_load"."cfm_ymd" IS '확정_연월일(상차)';

-- 확정_시분초(상차)
COMMENT ON COLUMN "wms_load"."cfm_hms" IS '확정_시분초(상차)';

-- 비고
COMMENT ON COLUMN "wms_load"."note" IS '비고';

-- 삭제_여부
COMMENT ON COLUMN "wms_load"."del_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "wms_load"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_load"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_load"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_load"."mod_dt" IS '수정일';

-- WMS_상차_PK
CREATE UNIQUE INDEX "wms_load_PK"
	ON "wms_load"
	( -- WMS_상차
		"load_seq" ASC -- 상차_SEQ
	)
;
-- WMS_상차
ALTER TABLE "wms_load"
	ADD CONSTRAINT "wms_load_PK"
		 -- WMS_상차_PK
	PRIMARY KEY 
	USING INDEX "wms_load_PK";

-- WMS_상차_PK
COMMENT ON CONSTRAINT "wms_load_PK" ON "wms_load" IS 'WMS_상차_PK';

-- WMS_상차_처리
CREATE TABLE "wms_load_tran"
(
	"load_tran_seq"   bigint        NOT NULL DEFAULT nextval('wms_load_tran_seq'), -- 상처_처리_SEQ
	"load_prod_seq"   bigint        NOT NULL, -- 상차_품목_SEQ
	"load_seq"        int4          NOT NULL, -- 상차_SEQ
	"prod_seq"        int4          NOT NULL, -- 품목_SEQ
	"sku1"            varchar(100)  NOT NULL, -- SKU1
	"sku2"            varchar(100)  NOT NULL, -- SKU2
	"lot_no"          varchar(30)   NULL,     -- LOT_번호
	"mng_ymd"         varchar(8)    NULL,     -- 입고/제조일자
	"exp_ymd"         varchar(8)    NULL,     -- 유통기한_연월일
	"fr_wh_seq"       int4          NULL,     -- FR_창고_SEQ
	"fr_loc_seq"      bigint        NULL,     -- FR_위치_SEQ
	"proc_qty"        decimal(10,2) NOT NULL DEFAULT 0, -- 처리_수량(상차)
	"ex_qty"          decimal(10,2) NOT NULL DEFAULT 0, -- 기처리_수량(상차)
	"to_wh_seq"       int4          NULL,     -- TO_창고_SEQ
	"to_loc_seq"      bigint        NULL,     -- TO_위치_SEQ
	"proc_bundle_no"  varchar(30)   NULL,     -- 처리_묶음_번호
	"proc_ymd"        varchar(8)    NULL,     -- 처리_연월일(상차)
	"proc_hms"        varchar(6)    NULL,     -- 처리_시분초(상차)
	"proc_user_id"    varchar(20)   NULL,     -- 처리_자_ID(상차)
	"outbiz_tran_seq" bigint        NULL,     -- 출하_처리_SEQ
	"if_err_seq"      int4          NULL,     -- IF_에러_일련번호
	"if_send_yn"      char(1)       NOT NULL DEFAULT 'N', -- IF_송신_여부
	"del_yn"          char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"          varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"          timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"          varchar(20)   NULL,     -- 수정_ID
	"mod_dt"          timestamp     NULL      -- 수정_일시
);

-- WMS_상차_처리
COMMENT ON TABLE "wms_load_tran" IS 'WMS_상차_처리';

-- 상처_처리_SEQ
COMMENT ON COLUMN "wms_load_tran"."load_tran_seq" IS '상처_처리_SEQ';

-- 상차_품목_SEQ
COMMENT ON COLUMN "wms_load_tran"."load_prod_seq" IS '상차_품목_SEQ';

-- 상차_SEQ
COMMENT ON COLUMN "wms_load_tran"."load_seq" IS '상차_SEQ';

-- 품목_SEQ
COMMENT ON COLUMN "wms_load_tran"."prod_seq" IS '품목_SEQ';

-- SKU1
COMMENT ON COLUMN "wms_load_tran"."sku1" IS 'SKU1';

-- SKU2
COMMENT ON COLUMN "wms_load_tran"."sku2" IS 'SKU2';

-- LOT_번호
COMMENT ON COLUMN "wms_load_tran"."lot_no" IS 'LOT_번호';

-- 입고/제조일자
COMMENT ON COLUMN "wms_load_tran"."mng_ymd" IS '입고/제조일자';

-- 유통기한_연월일
COMMENT ON COLUMN "wms_load_tran"."exp_ymd" IS '유통기한_연월일';

-- FR_창고_SEQ
COMMENT ON COLUMN "wms_load_tran"."fr_wh_seq" IS '창고(FR)';

-- FR_위치_SEQ
COMMENT ON COLUMN "wms_load_tran"."fr_loc_seq" IS '위치(FR)';

-- 처리_수량(상차)
COMMENT ON COLUMN "wms_load_tran"."proc_qty" IS '출고_수량';

-- 기처리_수량(상차)
COMMENT ON COLUMN "wms_load_tran"."ex_qty" IS '출고_수량';

-- TO_창고_SEQ
COMMENT ON COLUMN "wms_load_tran"."to_wh_seq" IS '창고(TO)';

-- TO_위치_SEQ
COMMENT ON COLUMN "wms_load_tran"."to_loc_seq" IS '위치(TO)';

-- 처리_묶음_번호
COMMENT ON COLUMN "wms_load_tran"."proc_bundle_no" IS '처리_묶음_번호';

-- 처리_연월일(상차)
COMMENT ON COLUMN "wms_load_tran"."proc_ymd" IS '입고_일자';

-- 처리_시분초(상차)
COMMENT ON COLUMN "wms_load_tran"."proc_hms" IS '입고_시간';

-- 처리_자_ID(상차)
COMMENT ON COLUMN "wms_load_tran"."proc_user_id" IS '입고_작업자_아이디';

-- 출하_처리_SEQ
COMMENT ON COLUMN "wms_load_tran"."outbiz_tran_seq" IS '출하_처리_SEQ';

-- IF_에러_일련번호
COMMENT ON COLUMN "wms_load_tran"."if_err_seq" IS 'IF_에러_일련번호';

-- IF_송신_여부
COMMENT ON COLUMN "wms_load_tran"."if_send_yn" IS 'ERP_송신_여부';

-- 삭제_여부
COMMENT ON COLUMN "wms_load_tran"."del_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "wms_load_tran"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_load_tran"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_load_tran"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_load_tran"."mod_dt" IS '수정일';

-- WMS_상차_처리_PK
CREATE UNIQUE INDEX "wms_load_tran_PK"
	ON "wms_load_tran"
	( -- WMS_상차_처리
		"load_tran_seq" ASC, -- 상처_처리_SEQ
		"load_prod_seq" ASC, -- 상차_품목_SEQ
		"load_seq" ASC -- 상차_SEQ
	)
;
-- WMS_상차_처리
ALTER TABLE "wms_load_tran"
	ADD CONSTRAINT "wms_load_tran_PK"
		 -- WMS_상차_처리_PK
	PRIMARY KEY 
	USING INDEX "wms_load_tran_PK";

-- WMS_상차_처리_PK
COMMENT ON CONSTRAINT "wms_load_tran_PK" ON "wms_load_tran" IS 'WMS_상차_처리_PK';

-- WMS_상차_품목
CREATE TABLE "wms_load_prod"
(
	"load_prod_seq"    bigint        NOT NULL DEFAULT nextval('wms_load_prod_seq'), -- 상차_품목_SEQ
	"load_seq"         int4          NOT NULL, -- 상차_SEQ
	"prod_seq"         int4          NOT NULL, -- 품목_seq
	"load_prod_sts_cd" varchar(50)   NOT NULL, -- 상차_품목_상태_코드
	"req_qty"          decimal(10,2) NOT NULL DEFAULT 0, -- 요청_수량(상차)
	"ex_qty"           decimal(10,2) NOT NULL DEFAULT 0, -- 기처리_수량(상차)
	"est_mng_ymd"      varchar(8)    NULL,     -- 예상_입고/제조일자
	"est_exp_ymd"      varchar(8)    NULL,     -- 예상_유통기한
	"est_lot_no"       varchar(30)   NULL,     -- 예상_LOT_NO
	"group_outwh_no"   varchar(30)   NOT NULL, -- 그룹_출고_번호
	"del_yn"           char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"           varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"           timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"           varchar(20)   NULL,     -- 수정_ID
	"mod_dt"           timestamp     NULL      -- 수정_일시
);

-- WMS_상차_품목
COMMENT ON TABLE "wms_load_prod" IS 'WMS_상차_품목';

-- 상차_품목_SEQ
COMMENT ON COLUMN "wms_load_prod"."load_prod_seq" IS '상차_품목_SEQ';

-- 상차_SEQ
COMMENT ON COLUMN "wms_load_prod"."load_seq" IS '상차_SEQ';

-- 품목_seq
COMMENT ON COLUMN "wms_load_prod"."prod_seq" IS '품목_seq';

-- 상차_품목_상태_코드
COMMENT ON COLUMN "wms_load_prod"."load_prod_sts_cd" IS '출하_상태_코드';

-- 요청_수량(상차)
COMMENT ON COLUMN "wms_load_prod"."req_qty" IS '출하_요청_수량';

-- 기처리_수량(상차)
COMMENT ON COLUMN "wms_load_prod"."ex_qty" IS '기_출하_수량';

-- 예상_입고/제조일자
COMMENT ON COLUMN "wms_load_prod"."est_mng_ymd" IS '예상_입고/제조일자';

-- 예상_유통기한
COMMENT ON COLUMN "wms_load_prod"."est_exp_ymd" IS '예상_유통기한';

-- 예상_LOT_NO
COMMENT ON COLUMN "wms_load_prod"."est_lot_no" IS '예상_LOT_NO';

-- 그룹_출고_번호
COMMENT ON COLUMN "wms_load_prod"."group_outwh_no" IS '그룹_출고_번호';

-- 삭제_여부
COMMENT ON COLUMN "wms_load_prod"."del_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "wms_load_prod"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_load_prod"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_load_prod"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_load_prod"."mod_dt" IS '수정일';

-- WMS_상차_품목_PK
CREATE UNIQUE INDEX "wms_load_prod_PK"
	ON "wms_load_prod"
	( -- WMS_상차_품목
		"load_prod_seq" ASC, -- 상차_품목_SEQ
		"load_seq" ASC -- 상차_SEQ
	)
;
-- WMS_상차_품목
ALTER TABLE "wms_load_prod"
	ADD CONSTRAINT "wms_load_prod_PK"
		 -- WMS_상차_품목_PK
	PRIMARY KEY 
	USING INDEX "wms_load_prod_PK";

-- WMS_상차_품목_PK
COMMENT ON CONSTRAINT "wms_load_prod_PK" ON "wms_load_prod" IS 'WMS_상차_품목_PK';

-- WMS_세트작업
CREATE TABLE "wms_inven_st"
(
	"st_seq"      int4          NOT NULL DEFAULT nextval('wms_inven_st_seq'), -- 세트작업_SEQ
	"biz_seq"     int4          NOT NULL, -- 사업장_SEQ
	"st_no"       varchar(30)   NOT NULL, -- 세트작업_번호
	"center_seq"  int4          NOT NULL, -- 센터_SEQ
	"wh_seq"      int4          NOT NULL, -- 작업창고_SEQ
	"assembly_yn" char(1)       NOT NULL DEFAULT 'N', -- 세트구성_여부
	"st_type_cd"  varchar(50)   NOT NULL, -- 세트작업_유형_코드
	"st_sts_cd"   varchar(50)   NOT NULL, -- 세트작업_상태_코드
	"req_ymd"     varchar(8)    NOT NULL, -- 예정_연월일(세트작업)
	"req_hms"     varchar(6)    NULL,     -- 예정_시분초(세트작업)
	"req_user_nm" varchar(100)  NULL,     -- 요청_사용자_명(세트작업)
	"req_dept_nm" varchar(100)  NULL,     -- 요청_부서_명
	"req_no"      varchar(30)   NULL,     -- 문서_번호(타시스템)
	"note"        varchar(1000) NULL,     -- 비고
	"if_key"      varchar(50)   NULL,     -- IF_KEY
	"if_err_seq"  int4          NULL,     -- IF_에러_일련번호
	"if_send_yn"  char(1)       NOT NULL DEFAULT 'N', -- IF_송신_여부
	"del_yn"      char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"      varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"      timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"      varchar(20)   NULL,     -- 수정_ID
	"mod_dt"      timestamp     NULL      -- 수정_일시
);

-- WMS_세트작업
COMMENT ON TABLE "wms_inven_st" IS 'WMS_세트작업';

-- 세트작업_SEQ
COMMENT ON COLUMN "wms_inven_st"."st_seq" IS '재고이동요청번호';

-- 사업장_SEQ
COMMENT ON COLUMN "wms_inven_st"."biz_seq" IS '사업장_ID';

-- 세트작업_번호
COMMENT ON COLUMN "wms_inven_st"."st_no" IS '재고이동요청번호';

-- 센터_SEQ
COMMENT ON COLUMN "wms_inven_st"."center_seq" IS '센터_SEQ';

-- 작업창고_SEQ
COMMENT ON COLUMN "wms_inven_st"."wh_seq" IS '작업창고_SEQ';

-- 세트구성_여부
COMMENT ON COLUMN "wms_inven_st"."assembly_yn" IS '세트구성_여부';

-- 세트작업_유형_코드
COMMENT ON COLUMN "wms_inven_st"."st_type_cd" IS '재고_이동_유형_코드';

-- 세트작업_상태_코드
COMMENT ON COLUMN "wms_inven_st"."st_sts_cd" IS '처리_상태_코드';

-- 예정_연월일(세트작업)
COMMENT ON COLUMN "wms_inven_st"."req_ymd" IS '입고_요청_일자';

-- 예정_시분초(세트작업)
COMMENT ON COLUMN "wms_inven_st"."req_hms" IS '입고_요청_시간';

-- 요청_사용자_명(세트작업)
COMMENT ON COLUMN "wms_inven_st"."req_user_nm" IS '입고_요청자_아이디';

-- 요청_부서_명
COMMENT ON COLUMN "wms_inven_st"."req_dept_nm" IS '요청_부서_명';

-- 문서_번호(타시스템)
COMMENT ON COLUMN "wms_inven_st"."req_no" IS '증빙번호';

-- 비고
COMMENT ON COLUMN "wms_inven_st"."note" IS '비고';

-- IF_KEY
COMMENT ON COLUMN "wms_inven_st"."if_key" IS '발주내부_코드(ERP)';

-- IF_에러_일련번호
COMMENT ON COLUMN "wms_inven_st"."if_err_seq" IS 'IF_에러_일련번호';

-- IF_송신_여부
COMMENT ON COLUMN "wms_inven_st"."if_send_yn" IS 'ERP_송신_여부';

-- 삭제_여부
COMMENT ON COLUMN "wms_inven_st"."del_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "wms_inven_st"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_inven_st"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_inven_st"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_inven_st"."mod_dt" IS '수정일';

-- WMS_ST_IDX01
CREATE UNIQUE INDEX "UIX_wms_inven_st"
	ON "wms_inven_st"
	( -- WMS_세트작업
		"biz_seq" ASC, -- 사업장_SEQ
		"st_no" ASC -- 세트작업_번호
	);

-- WMS_ST_IDX01
COMMENT ON INDEX "UIX_wms_inven_st" IS 'WMS_ST_IDX01';

-- WMS_ST_IDX02
CREATE INDEX "IX_wms_inven_st"
	ON "wms_inven_st"	( -- WMS_세트작업
		"biz_seq" ASC, -- 사업장_SEQ
		"center_seq" ASC, -- 센터_SEQ
		"req_ymd" ASC -- 예정_연월일(세트작업)
	);

-- WMS_ST_IDX02
COMMENT ON INDEX "IX_wms_inven_st" IS 'WMS_ST_IDX02';

-- WMS_세트작업_PK
CREATE UNIQUE INDEX "wms_inven_st_PK"
	ON "wms_inven_st"
	( -- WMS_세트작업
		"st_seq" ASC -- 세트작업_SEQ
	)
;
-- WMS_세트작업
ALTER TABLE "wms_inven_st"
	ADD CONSTRAINT "wms_inven_st_PK"
		 -- WMS_세트작업_PK
	PRIMARY KEY 
	USING INDEX "wms_inven_st_PK";

-- WMS_세트작업_PK
COMMENT ON CONSTRAINT "wms_inven_st_PK" ON "wms_inven_st" IS 'WMS_세트작업_PK';

-- WMS_세트작업
ALTER TABLE "wms_inven_st"
	ADD CONSTRAINT "UK_wms_inven_st" -- WMS_세트작업 유니크 제약
	UNIQUE 
	USING INDEX "UIX_wms_inven_st";

-- WMS_세트작업 유니크 제약
COMMENT ON CONSTRAINT "UK_wms_inven_st" ON "wms_inven_st" IS 'WMS_세트작업 유니크 제약';

-- WMS_세트작업_처리
CREATE TABLE "wms_inven_st_tran"
(
	"st_tran_seq"    bigint        NOT NULL DEFAULT nextval('wms_inven_st_tran_seq'), -- 세트작업_처리_SEQ
	"st_prod_seq"    bigint        NOT NULL, -- 세트작업_품목_SEQ
	"st_seq"         int4          NOT NULL, -- 세트작업_SEQ
	"prod_seq"       int4          NOT NULL, -- 품목_SEQ
	"wh_seq"         int4          NOT NULL, -- 창고_SEQ
	"loc_seq"        bigint        NOT NULL, -- 위치_SEQ
	"sku1"           varchar(100)  NOT NULL, -- SKU1
	"sku2"           varchar(100)  NOT NULL, -- SKU2
	"proc_qty"       decimal(10,2) NOT NULL DEFAULT 0, -- 처리_수량
	"disassy_qty"    decimal(10,2) NOT NULL DEFAULT 0, -- 해체_수량
	"proc_bundle_no" varchar(30)   NULL,     -- 처리_묶음_번호
	"proc_ymd"       varchar(8)    NOT NULL, -- 처리_연월일(세트작업)
	"proc_hms"       varchar(6)    NOT NULL, -- 처리_시분초(세트작업)
	"proc_user_id"   varchar(20)   NOT NULL, -- 처리_자_ID(세트작업)
	"if_send_yn"     char(1)       NOT NULL DEFAULT 'N', -- IF_송신_여부
	"if_err_seq"     int4          NULL,     -- IF_에러_일련번호
	"del_yn"         char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"         varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"         timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"         varchar(20)   NULL,     -- 수정_ID
	"mod_dt"         timestamp     NULL      -- 수정_일시
);

-- WMS_세트작업_처리
COMMENT ON TABLE "wms_inven_st_tran" IS 'WMS_세트작업_처리';

-- 세트작업_처리_SEQ
COMMENT ON COLUMN "wms_inven_st_tran"."st_tran_seq" IS '세트작업_처리_SEQ';

-- 세트작업_품목_SEQ
COMMENT ON COLUMN "wms_inven_st_tran"."st_prod_seq" IS '세트작업_품목_SEQ';

-- 세트작업_SEQ
COMMENT ON COLUMN "wms_inven_st_tran"."st_seq" IS '세트작업_SEQ';

-- 품목_SEQ
COMMENT ON COLUMN "wms_inven_st_tran"."prod_seq" IS '예외출고_요청_수량';

-- 창고_SEQ
COMMENT ON COLUMN "wms_inven_st_tran"."wh_seq" IS '창고(FR)';

-- 위치_SEQ
COMMENT ON COLUMN "wms_inven_st_tran"."loc_seq" IS '위치(FR)';

-- SKU1
COMMENT ON COLUMN "wms_inven_st_tran"."sku1" IS 'SKU1(FR)';

-- SKU2
COMMENT ON COLUMN "wms_inven_st_tran"."sku2" IS 'SKU2(FR)';

-- 처리_수량
COMMENT ON COLUMN "wms_inven_st_tran"."proc_qty" IS '요청수량';

-- 해체_수량
COMMENT ON COLUMN "wms_inven_st_tran"."disassy_qty" IS '해체_수량';

-- 처리_묶음_번호
COMMENT ON COLUMN "wms_inven_st_tran"."proc_bundle_no" IS '문서번호';

-- 처리_연월일(세트작업)
COMMENT ON COLUMN "wms_inven_st_tran"."proc_ymd" IS '입고_일자';

-- 처리_시분초(세트작업)
COMMENT ON COLUMN "wms_inven_st_tran"."proc_hms" IS '입고_시간';

-- 처리_자_ID(세트작업)
COMMENT ON COLUMN "wms_inven_st_tran"."proc_user_id" IS '입고_작업자_아이디';

-- IF_송신_여부
COMMENT ON COLUMN "wms_inven_st_tran"."if_send_yn" IS 'ERP_송신_여부';

-- IF_에러_일련번호
COMMENT ON COLUMN "wms_inven_st_tran"."if_err_seq" IS 'IF_에러_일련번호';

-- 삭제_여부
COMMENT ON COLUMN "wms_inven_st_tran"."del_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "wms_inven_st_tran"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_inven_st_tran"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_inven_st_tran"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_inven_st_tran"."mod_dt" IS '수정일';

-- WMS_세트작업_처리_PK
CREATE UNIQUE INDEX "wms_inven_st_tran_PK"
	ON "wms_inven_st_tran"
	( -- WMS_세트작업_처리
		"st_tran_seq" ASC, -- 세트작업_처리_SEQ
		"st_prod_seq" ASC, -- 세트작업_품목_SEQ
		"st_seq" ASC -- 세트작업_SEQ
	)
;
-- WMS_세트작업_처리
ALTER TABLE "wms_inven_st_tran"
	ADD CONSTRAINT "wms_inven_st_tran_PK"
		 -- WMS_세트작업_처리_PK
	PRIMARY KEY 
	USING INDEX "wms_inven_st_tran_PK";

-- WMS_세트작업_처리_PK
COMMENT ON CONSTRAINT "wms_inven_st_tran_PK" ON "wms_inven_st_tran" IS 'WMS_세트작업_처리_PK';

-- WMS_세트작업_품목
CREATE TABLE "wms_inven_st_prod"
(
	"st_prod_seq"     bigint        NOT NULL DEFAULT nextval('wms_inven_st_prod_seq'), -- 세트작업_품목_SEQ
	"st_seq"          int4          NOT NULL, -- 세트작업_SEQ
	"st_prod_sts_cd"  varchar(50)   NOT NULL, -- 세트작업_품목_상태_코드
	"mdm_st_prod_seq" int4          NULL,     -- 세트구성_SEQ
	"prod_seq"        int4          NOT NULL, -- 품목_SEQ
	"req_qty"         decimal(10,2) NOT NULL DEFAULT 0, -- 요청_수량(세트작업)
	"est_exp_ymd"     varchar(8)    NULL,     -- 예상_유통기한
	"est_mng_ymd"     varchar(8)    NULL,     -- 예상_입고/제조일자
	"est_lot_no"      varchar(30)   NULL,     -- 예상_LOT_NO
	"mv_seq"          int4          NULL,     -- 재고이동_SEQ
	"if_idx"          varchar(20)   NULL,     -- IF_내부순번
	"if_err_seq"      int4          NULL,     -- IF_에러_일련번호
	"if_send_yn"      char(1)       NOT NULL DEFAULT 'N', -- IF_송신_여부
	"del_yn"          char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"          varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"          timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"          varchar(20)   NULL,     -- 수정_ID
	"mod_dt"          timestamp     NULL      -- 수정_일시
);

-- WMS_세트작업_품목
COMMENT ON TABLE "wms_inven_st_prod" IS 'WMS_세트작업_품목';

-- 세트작업_품목_SEQ
COMMENT ON COLUMN "wms_inven_st_prod"."st_prod_seq" IS '세트작업_품목_SEQ';

-- 세트작업_SEQ
COMMENT ON COLUMN "wms_inven_st_prod"."st_seq" IS '세트작업_SEQ';

-- 세트작업_품목_상태_코드
COMMENT ON COLUMN "wms_inven_st_prod"."st_prod_sts_cd" IS '처리_상태_코드';

-- 세트구성_SEQ
COMMENT ON COLUMN "wms_inven_st_prod"."mdm_st_prod_seq" IS '세트구성_SEQ';

-- 품목_SEQ
COMMENT ON COLUMN "wms_inven_st_prod"."prod_seq" IS '예외출고_요청_수량';

-- 요청_수량(세트작업)
COMMENT ON COLUMN "wms_inven_st_prod"."req_qty" IS '품목ID';

-- 예상_유통기한
COMMENT ON COLUMN "wms_inven_st_prod"."est_exp_ymd" IS '예상_유통기한';

-- 예상_입고/제조일자
COMMENT ON COLUMN "wms_inven_st_prod"."est_mng_ymd" IS '예상_입고/제조일자';

-- 예상_LOT_NO
COMMENT ON COLUMN "wms_inven_st_prod"."est_lot_no" IS '예상_LOT_NO';

-- 재고이동_SEQ
COMMENT ON COLUMN "wms_inven_st_prod"."mv_seq" IS '재고이동_SEQ';

-- IF_내부순번
COMMENT ON COLUMN "wms_inven_st_prod"."if_idx" IS '순번 --';

-- IF_에러_일련번호
COMMENT ON COLUMN "wms_inven_st_prod"."if_err_seq" IS 'IF_에러_일련번호';

-- IF_송신_여부
COMMENT ON COLUMN "wms_inven_st_prod"."if_send_yn" IS 'ERP_송신_여부';

-- 삭제_여부
COMMENT ON COLUMN "wms_inven_st_prod"."del_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "wms_inven_st_prod"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_inven_st_prod"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_inven_st_prod"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_inven_st_prod"."mod_dt" IS '수정일';

-- WMS_세트작업_품목_PK
CREATE UNIQUE INDEX "wms_inven_st_prod_PK"
	ON "wms_inven_st_prod"
	( -- WMS_세트작업_품목
		"st_prod_seq" ASC, -- 세트작업_품목_SEQ
		"st_seq" ASC -- 세트작업_SEQ
	)
;
-- WMS_세트작업_품목
ALTER TABLE "wms_inven_st_prod"
	ADD CONSTRAINT "wms_inven_st_prod_PK"
		 -- WMS_세트작업_품목_PK
	PRIMARY KEY 
	USING INDEX "wms_inven_st_prod_PK";

-- WMS_세트작업_품목_PK
COMMENT ON CONSTRAINT "wms_inven_st_prod_PK" ON "wms_inven_st_prod" IS 'WMS_세트작업_품목_PK';

-- WMS_송장
CREATE TABLE "wms_invoice"
(
	"invoice_seq"        int4          NOT NULL DEFAULT nextval('wms_invoice_seq'), -- 송장_SEQ
	"parent_invoice_seq" int4          NULL,     -- 부모_송장_SEQ
	"biz_seq"            int4          NOT NULL, -- 사업장_SEQ
	"invoice_no"         varchar(30)   NULL,     -- 송장_번호
	"invoice_sts_cd"     varchar(50)   NOT NULL, -- 송장_상태_코드
	"rcpt_div_cd"        varchar(50)   NOT NULL, -- 접수_구분_코드
	"invoice_pack_cd"    varchar(50)   NOT NULL, -- 송장_포장_코드
	"proc_ymd"           varchar(8)    NULL,     -- 처리_연월일(송장)
	"proc_hms"           varchar(6)    NULL,     -- 처리_시분초(송장)
	"proc_user_id"       varchar(20)   NULL,     -- 처리_자_ID(송장)
	"re_print_cnt"       int2          NOT NULL DEFAULT 0, -- 재출력횟수
	"group_outwh_no"     varchar(30)   NULL,     -- 그룹_출고_번호
	"check_yn"           char(1)       NOT NULL DEFAULT 'N', -- 검수_여부
	"note"               varchar(1000) NULL,     -- 비고
	"if_send_yn"         char(1)       NOT NULL DEFAULT 'N', -- IF_송신_여부
	"if_err_seq"         int4          NULL,     -- IF_에러_일련번호
	"wes_if_err_seq"     int4          NULL,     -- WES_IF_에러_일련번호
	"wes_if_send_yn"     char(1)       NOT NULL DEFAULT 'N', -- WES_IF_송신_여부
	"del_yn"             char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"             varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"             timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"             varchar(20)   NULL,     -- 수정_ID
	"mod_dt"             timestamp     NULL      -- 수정_일시
);

-- WMS_송장
COMMENT ON TABLE "wms_invoice" IS 'WMS_송장';

-- 송장_SEQ
COMMENT ON COLUMN "wms_invoice"."invoice_seq" IS '송장_SEQ';

-- 부모_송장_SEQ
COMMENT ON COLUMN "wms_invoice"."parent_invoice_seq" IS '부모_송장_SEQ';

-- 사업장_SEQ
COMMENT ON COLUMN "wms_invoice"."biz_seq" IS '사업장_ID';

-- 송장_번호
COMMENT ON COLUMN "wms_invoice"."invoice_no" IS '출하_예정_번호';

-- 송장_상태_코드
COMMENT ON COLUMN "wms_invoice"."invoice_sts_cd" IS '출하_상태_코드';

-- 접수_구분_코드
COMMENT ON COLUMN "wms_invoice"."rcpt_div_cd" IS '접수_구분_코드';

-- 송장_포장_코드
COMMENT ON COLUMN "wms_invoice"."invoice_pack_cd" IS '출하_상태_코드';

-- 처리_연월일(송장)
COMMENT ON COLUMN "wms_invoice"."proc_ymd" IS '입고_일자';

-- 처리_시분초(송장)
COMMENT ON COLUMN "wms_invoice"."proc_hms" IS '입고_시간';

-- 처리_자_ID(송장)
COMMENT ON COLUMN "wms_invoice"."proc_user_id" IS '입고_작업자_아이디';

-- 재출력횟수
COMMENT ON COLUMN "wms_invoice"."re_print_cnt" IS '재출력횟수';

-- 그룹_출고_번호
COMMENT ON COLUMN "wms_invoice"."group_outwh_no" IS '그룹_출고_번호';

-- 검수_여부
COMMENT ON COLUMN "wms_invoice"."check_yn" IS 'IF_에러_일련번호';

-- 비고
COMMENT ON COLUMN "wms_invoice"."note" IS '비고';

-- IF_송신_여부
COMMENT ON COLUMN "wms_invoice"."if_send_yn" IS 'ERP_송신_여부';

-- IF_에러_일련번호
COMMENT ON COLUMN "wms_invoice"."if_err_seq" IS 'IF_에러_일련번호';

-- WES_IF_에러_일련번호
COMMENT ON COLUMN "wms_invoice"."wes_if_err_seq" IS 'IF_에러_일련번호';

-- WES_IF_송신_여부
COMMENT ON COLUMN "wms_invoice"."wes_if_send_yn" IS 'ERP_송신_여부';

-- 삭제_여부
COMMENT ON COLUMN "wms_invoice"."del_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "wms_invoice"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_invoice"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_invoice"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_invoice"."mod_dt" IS '수정일';

-- WMS_송장 인덱스
CREATE INDEX "IX_wms_invoice"
	ON "wms_invoice"	( -- WMS_송장
		"biz_seq" ASC, -- 사업장_SEQ
		"group_outwh_no" ASC -- 그룹_출고_번호
	);

-- WMS_송장 인덱스
COMMENT ON INDEX "IX_wms_invoice" IS 'WMS_송장 인덱스';

-- WMS_송장_PK
CREATE UNIQUE INDEX "wms_invoice_PK"
	ON "wms_invoice"
	( -- WMS_송장
		"invoice_seq" ASC -- 송장_SEQ
	)
;
-- WMS_송장
ALTER TABLE "wms_invoice"
	ADD CONSTRAINT "wms_invoice_PK"
		 -- WMS_송장_PK
	PRIMARY KEY 
	USING INDEX "wms_invoice_PK";

-- WMS_송장_PK
COMMENT ON CONSTRAINT "wms_invoice_PK" ON "wms_invoice" IS 'WMS_송장_PK';

-- WMS_송장_처리
CREATE TABLE "wms_invoice_tran"
(
	"invoice_tran_seq" bigint        NOT NULL DEFAULT nextval('wms_invoice_tran_seq'), -- 송장_처리_SEQ
	"invoice_prod_seq" bigint        NOT NULL, -- 송장_품목_SEQ
	"invoice_seq"      int4          NOT NULL, -- 송장_SEQ
	"prod_seq"         int4          NOT NULL, -- 품목_SEQ
	"sku1"             varchar(100)  NOT NULL, -- SKU1
	"sku2"             varchar(100)  NOT NULL, -- SKU2
	"exp_ymd"          varchar(8)    NULL,     -- 유통기한_연월일
	"lot_no"           varchar(30)   NULL,     -- LOT_번호
	"mng_ymd"          varchar(8)    NULL,     -- 입고/제조일자
	"fr_wh_seq"        int4          NULL,     -- FR_창고_SEQ
	"fr_loc_seq"       bigint        NULL,     -- FR_위치_SEQ
	"proc_qty"         decimal(10,2) NOT NULL DEFAULT 0, -- 처리_수량(상차)
	"ex_qty"           decimal(10,2) NOT NULL DEFAULT 0, -- 기처리_수량(상차)
	"to_wh_seq"        int4          NULL,     -- TO_창고_SEQ
	"to_loc_seq"       bigint        NULL,     -- TO_위치_SEQ
	"proc_bundle_no"   varchar(30)   NULL,     -- 처리_묶음_번호
	"proc_ymd"         varchar(8)    NULL,     -- 처리_연월일(상차)
	"proc_hms"         varchar(6)    NULL,     -- 처리_시분초(상차)
	"proc_user_id"     varchar(20)   NULL,     -- 처리_자_ID(상차)
	"outbiz_tran_seq"  bigint        NULL,     -- 출하_처리_SEQ
	"if_err_seq"       int4          NULL,     -- IF_에러_일련번호
	"if_send_yn"       char(1)       NOT NULL DEFAULT 'N', -- IF_송신_여부
	"del_yn"           char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"           varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"           timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"           varchar(20)   NULL,     -- 수정_ID
	"mod_dt"           timestamp     NULL      -- 수정_일시
);

-- WMS_송장_처리
COMMENT ON TABLE "wms_invoice_tran" IS 'WMS_송장_처리';

-- 송장_처리_SEQ
COMMENT ON COLUMN "wms_invoice_tran"."invoice_tran_seq" IS '송장_처리_SEQ';

-- 송장_품목_SEQ
COMMENT ON COLUMN "wms_invoice_tran"."invoice_prod_seq" IS '송장_품목_SEQ';

-- 송장_SEQ
COMMENT ON COLUMN "wms_invoice_tran"."invoice_seq" IS '송장_SEQ';

-- 품목_SEQ
COMMENT ON COLUMN "wms_invoice_tran"."prod_seq" IS '품목_SEQ';

-- SKU1
COMMENT ON COLUMN "wms_invoice_tran"."sku1" IS 'SKU1';

-- SKU2
COMMENT ON COLUMN "wms_invoice_tran"."sku2" IS 'SKU2';

-- 유통기한_연월일
COMMENT ON COLUMN "wms_invoice_tran"."exp_ymd" IS '유통기한_연월일';

-- LOT_번호
COMMENT ON COLUMN "wms_invoice_tran"."lot_no" IS 'LOT_번호';

-- 입고/제조일자
COMMENT ON COLUMN "wms_invoice_tran"."mng_ymd" IS '입고/제조일자';

-- FR_창고_SEQ
COMMENT ON COLUMN "wms_invoice_tran"."fr_wh_seq" IS '창고(FR)';

-- FR_위치_SEQ
COMMENT ON COLUMN "wms_invoice_tran"."fr_loc_seq" IS '위치(FR)';

-- 처리_수량(상차)
COMMENT ON COLUMN "wms_invoice_tran"."proc_qty" IS '출고_수량';

-- 기처리_수량(상차)
COMMENT ON COLUMN "wms_invoice_tran"."ex_qty" IS '출고_수량';

-- TO_창고_SEQ
COMMENT ON COLUMN "wms_invoice_tran"."to_wh_seq" IS '창고(TO)';

-- TO_위치_SEQ
COMMENT ON COLUMN "wms_invoice_tran"."to_loc_seq" IS '위치(TO)';

-- 처리_묶음_번호
COMMENT ON COLUMN "wms_invoice_tran"."proc_bundle_no" IS '처리_묶음_번호';

-- 처리_연월일(상차)
COMMENT ON COLUMN "wms_invoice_tran"."proc_ymd" IS '입고_일자';

-- 처리_시분초(상차)
COMMENT ON COLUMN "wms_invoice_tran"."proc_hms" IS '입고_시간';

-- 처리_자_ID(상차)
COMMENT ON COLUMN "wms_invoice_tran"."proc_user_id" IS '입고_작업자_아이디';

-- 출하_처리_SEQ
COMMENT ON COLUMN "wms_invoice_tran"."outbiz_tran_seq" IS '출하_처리_SEQ';

-- IF_에러_일련번호
COMMENT ON COLUMN "wms_invoice_tran"."if_err_seq" IS 'IF_에러_일련번호';

-- IF_송신_여부
COMMENT ON COLUMN "wms_invoice_tran"."if_send_yn" IS 'ERP_송신_여부';

-- 삭제_여부
COMMENT ON COLUMN "wms_invoice_tran"."del_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "wms_invoice_tran"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_invoice_tran"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_invoice_tran"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_invoice_tran"."mod_dt" IS '수정일';

-- WMS_송장_처리_PK
CREATE UNIQUE INDEX "wms_invoice_tran_PK"
	ON "wms_invoice_tran"
	( -- WMS_송장_처리
		"invoice_tran_seq" ASC, -- 송장_처리_SEQ
		"invoice_prod_seq" ASC, -- 송장_품목_SEQ
		"invoice_seq" ASC -- 송장_SEQ
	)
;
-- WMS_송장_처리
ALTER TABLE "wms_invoice_tran"
	ADD CONSTRAINT "wms_invoice_tran_PK"
		 -- WMS_송장_처리_PK
	PRIMARY KEY 
	USING INDEX "wms_invoice_tran_PK";

-- WMS_송장_처리_PK
COMMENT ON CONSTRAINT "wms_invoice_tran_PK" ON "wms_invoice_tran" IS 'WMS_송장_처리_PK';

-- WMS_송장_품목
CREATE TABLE "wms_invoice_prod"
(
	"invoice_prod_seq"        bigint        NOT NULL DEFAULT nextval('wms_invoice_prod_seq'), -- 송장_품목_SEQ
	"invoice_seq"             int4          NOT NULL, -- 송장_SEQ
	"parent_invoice_prod_seq" bigint        NULL,     -- 부모_송장_품목_seq
	"prod_seq"                int4          NOT NULL, -- 품목_SEQ
	"req_qty"                 decimal(10,2) NOT NULL DEFAULT 0, -- 요청_수량(송장)
	"ex_qty"                  decimal(10,2) NOT NULL DEFAULT 0, -- 기처리_수량(송장)
	"invoice_prod_nm"         varchar(100)  NULL,     -- 송장_품목_명
	"del_yn"                  char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"                  varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"                  timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"                  varchar(20)   NULL,     -- 수정_ID
	"mod_dt"                  timestamp     NULL      -- 수정_일시
);

-- WMS_송장_품목
COMMENT ON TABLE "wms_invoice_prod" IS 'WMS_송장_품목';

-- 송장_품목_SEQ
COMMENT ON COLUMN "wms_invoice_prod"."invoice_prod_seq" IS '송장_품목_SEQ';

-- 송장_SEQ
COMMENT ON COLUMN "wms_invoice_prod"."invoice_seq" IS '송장_SEQ';

-- 부모_송장_품목_seq
COMMENT ON COLUMN "wms_invoice_prod"."parent_invoice_prod_seq" IS '부모_송장_품목_seq';

-- 품목_SEQ
COMMENT ON COLUMN "wms_invoice_prod"."prod_seq" IS '품목ID';

-- 요청_수량(송장)
COMMENT ON COLUMN "wms_invoice_prod"."req_qty" IS '출하_요청_수량';

-- 기처리_수량(송장)
COMMENT ON COLUMN "wms_invoice_prod"."ex_qty" IS '기_출하_수량';

-- 송장_품목_명
COMMENT ON COLUMN "wms_invoice_prod"."invoice_prod_nm" IS '품목_명';

-- 삭제_여부
COMMENT ON COLUMN "wms_invoice_prod"."del_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "wms_invoice_prod"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_invoice_prod"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_invoice_prod"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_invoice_prod"."mod_dt" IS '수정일';

-- WMS_송장_품목_PK
CREATE UNIQUE INDEX "wms_invoice_prod_PK"
	ON "wms_invoice_prod"
	( -- WMS_송장_품목
		"invoice_prod_seq" ASC, -- 송장_품목_SEQ
		"invoice_seq" ASC -- 송장_SEQ
	)
;
-- WMS_송장_품목
ALTER TABLE "wms_invoice_prod"
	ADD CONSTRAINT "wms_invoice_prod_PK"
		 -- WMS_송장_품목_PK
	PRIMARY KEY 
	USING INDEX "wms_invoice_prod_PK";

-- WMS_송장_품목_PK
COMMENT ON CONSTRAINT "wms_invoice_prod_PK" ON "wms_invoice_prod" IS 'WMS_송장_품목_PK';

-- WMS_예외출고
CREATE TABLE "wms_inven_etc"
(
	"etc_seq"     int4          NOT NULL DEFAULT nextval('wms_inven_etc_seq'), -- 예외출고_SEQ
	"biz_seq"     int4          NOT NULL, -- 사업장_SEQ
	"etc_no"      varchar(30)   NOT NULL, -- 예외출고_번호
	"center_seq"  int4          NOT NULL, -- 센터_SEQ
	"etc_type_cd" varchar(50)   NOT NULL, -- 예외출고_유형_코드
	"etc_sts_cd"  varchar(50)   NOT NULL, -- 예외출고_상태_코드
	"req_ymd"     varchar(8)    NOT NULL, -- 예정_연월일(예외출고)
	"req_hms"     varchar(6)    NULL,     -- 예정_시분초(예외출고)
	"req_user_nm" varchar(100)  NULL,     -- 요청_사용자_명(예외출고)
	"req_dept_nm" varchar(100)  NULL,     -- 요청_부서_명
	"req_no"      varchar(30)   NULL,     -- 문서_번호(타시스템)
	"erp_wh_cd"   varchar(50)   NULL,     -- 출고처_CODE(타시스템)
	"note"        varchar(1000) NULL,     -- 비고
	"if_send_yn"  char(1)       NOT NULL DEFAULT 'N', -- IF_송신_여부
	"if_key"      varchar(50)   NULL,     -- IF_KEY
	"if_err_seq"  int4          NULL,     -- IF_에러_일련번호
	"del_yn"      char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"      varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"      timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"      varchar(20)   NULL,     -- 수정_ID
	"mod_dt"      timestamp     NULL      -- 수정_일시
);

-- WMS_예외출고
COMMENT ON TABLE "wms_inven_etc" IS 'WMS_예외출고';

-- 예외출고_SEQ
COMMENT ON COLUMN "wms_inven_etc"."etc_seq" IS '예외적요청번호';

-- 사업장_SEQ
COMMENT ON COLUMN "wms_inven_etc"."biz_seq" IS '사업장_ID';

-- 예외출고_번호
COMMENT ON COLUMN "wms_inven_etc"."etc_no" IS '예외적요청번호';

-- 센터_SEQ
COMMENT ON COLUMN "wms_inven_etc"."center_seq" IS '센터_SEQ';

-- 예외출고_유형_코드
COMMENT ON COLUMN "wms_inven_etc"."etc_type_cd" IS '처리형태_코드';

-- 예외출고_상태_코드
COMMENT ON COLUMN "wms_inven_etc"."etc_sts_cd" IS '처리_상태_코드';

-- 예정_연월일(예외출고)
COMMENT ON COLUMN "wms_inven_etc"."req_ymd" IS '요청일자';

-- 예정_시분초(예외출고)
COMMENT ON COLUMN "wms_inven_etc"."req_hms" IS '요청일시';

-- 요청_사용자_명(예외출고)
COMMENT ON COLUMN "wms_inven_etc"."req_user_nm" IS '요청자_아이디';

-- 요청_부서_명
COMMENT ON COLUMN "wms_inven_etc"."req_dept_nm" IS '요청_부서_명';

-- 문서_번호(타시스템)
COMMENT ON COLUMN "wms_inven_etc"."req_no" IS '증빙번호';

-- 출고처_CODE(타시스템)
COMMENT ON COLUMN "wms_inven_etc"."erp_wh_cd" IS '출고처_CODE(타시스템)';

-- 비고
COMMENT ON COLUMN "wms_inven_etc"."note" IS '비고';

-- IF_송신_여부
COMMENT ON COLUMN "wms_inven_etc"."if_send_yn" IS 'ERP_송신_여부';

-- IF_KEY
COMMENT ON COLUMN "wms_inven_etc"."if_key" IS '발주내부_코드(ERP)';

-- IF_에러_일련번호
COMMENT ON COLUMN "wms_inven_etc"."if_err_seq" IS 'IF_에러_일련번호';

-- 삭제_여부
COMMENT ON COLUMN "wms_inven_etc"."del_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "wms_inven_etc"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_inven_etc"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_inven_etc"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_inven_etc"."mod_dt" IS '수정일';

-- WMS_ETC_IDX01
CREATE UNIQUE INDEX "UIX_wms_inven_etc"
	ON "wms_inven_etc"
	( -- WMS_예외출고
		"biz_seq" ASC, -- 사업장_SEQ
		"etc_no" ASC -- 예외출고_번호
	);

-- WMS_ETC_IDX01
COMMENT ON INDEX "UIX_wms_inven_etc" IS 'WMS_ETC_IDX01';

-- WMS_ETC_IDX02
CREATE INDEX "IX_wms_inven_etc"
	ON "wms_inven_etc"	( -- WMS_예외출고
		"biz_seq" ASC, -- 사업장_SEQ
		"center_seq" ASC, -- 센터_SEQ
		"req_ymd" ASC -- 예정_연월일(예외출고)
	);

-- WMS_ETC_IDX02
COMMENT ON INDEX "IX_wms_inven_etc" IS 'WMS_ETC_IDX02';

-- WMS_예외출고_PK
CREATE UNIQUE INDEX "wms_inven_etc_PK"
	ON "wms_inven_etc"
	( -- WMS_예외출고
		"etc_seq" ASC -- 예외출고_SEQ
	)
;
-- WMS_예외출고
ALTER TABLE "wms_inven_etc"
	ADD CONSTRAINT "wms_inven_etc_PK"
		 -- WMS_예외출고_PK
	PRIMARY KEY 
	USING INDEX "wms_inven_etc_PK";

-- WMS_예외출고_PK
COMMENT ON CONSTRAINT "wms_inven_etc_PK" ON "wms_inven_etc" IS 'WMS_예외출고_PK';

-- WMS_예외출고
ALTER TABLE "wms_inven_etc"
	ADD CONSTRAINT "UK_wms_inven_etc" -- WMS_예외출고 유니크 제약
	UNIQUE 
	USING INDEX "UIX_wms_inven_etc";

-- WMS_예외출고 유니크 제약
COMMENT ON CONSTRAINT "UK_wms_inven_etc" ON "wms_inven_etc" IS 'WMS_예외출고 유니크 제약';

-- WMS_예외출고_처리
CREATE TABLE "wms_inven_etc_tran"
(
	"etc_tran_seq"   bigint        NOT NULL DEFAULT nextval('wms_inven_etc_tran_seq'), -- 예외출고_처리_SEQ
	"etc_prod_seq"   bigint        NOT NULL, -- 예외출고_품목_SEQ
	"etc_seq"        int4          NOT NULL, -- 예외출고_SEQ
	"prod_seq"       int4          NOT NULL, -- 품목_SEQ
	"wh_seq"         int4          NOT NULL, -- 창고_SEQ
	"loc_seq"        bigint        NOT NULL, -- 위치_SEQ
	"sku1"           varchar(100)  NOT NULL, -- SKU1
	"sku2"           varchar(100)  NOT NULL, -- SKU2
	"proc_qty"       decimal(10,2) NOT NULL DEFAULT 0, -- 처리_수량(예외출고)
	"ex_qty"         decimal(10,2) NOT NULL DEFAULT 0, -- 기처리_수량(예외출고)
	"proc_bundle_no" varchar(30)   NULL,     -- 처리_묶음_번호
	"proc_ymd"       varchar(8)    NULL,     -- 처리_연월일(예외출고)
	"proc_hms"       varchar(6)    NULL,     -- 처리_시분초(예외출고)
	"proc_user_id"   varchar(20)   NULL,     -- 처리_자_ID(예외출고)
	"lot_no"         varchar(30)   NULL,     -- LOT_번호
	"if_send_yn"     char(1)       NOT NULL DEFAULT 'N', -- IF_송신_여부
	"if_err_seq"     int4          NULL,     -- IF_에러_일련번호
	"del_yn"         char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"         varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"         timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"         varchar(20)   NULL,     -- 수정_ID
	"mod_dt"         timestamp     NULL      -- 수정_일시
);

-- WMS_예외출고_처리
COMMENT ON TABLE "wms_inven_etc_tran" IS 'WMS_예외출고_처리';

-- 예외출고_처리_SEQ
COMMENT ON COLUMN "wms_inven_etc_tran"."etc_tran_seq" IS '예외출고_처리_SEQ';

-- 예외출고_품목_SEQ
COMMENT ON COLUMN "wms_inven_etc_tran"."etc_prod_seq" IS '예외출고_품목_SEQ';

-- 예외출고_SEQ
COMMENT ON COLUMN "wms_inven_etc_tran"."etc_seq" IS '예외출고_SEQ';

-- 품목_SEQ
COMMENT ON COLUMN "wms_inven_etc_tran"."prod_seq" IS '품목ID';

-- 창고_SEQ
COMMENT ON COLUMN "wms_inven_etc_tran"."wh_seq" IS '창고_ID';

-- 위치_SEQ
COMMENT ON COLUMN "wms_inven_etc_tran"."loc_seq" IS '위치_ID';

-- SKU1
COMMENT ON COLUMN "wms_inven_etc_tran"."sku1" IS 'SKU1(FR)';

-- SKU2
COMMENT ON COLUMN "wms_inven_etc_tran"."sku2" IS 'SKU2(FR)';

-- 처리_수량(예외출고)
COMMENT ON COLUMN "wms_inven_etc_tran"."proc_qty" IS '처리_수량';

-- 기처리_수량(예외출고)
COMMENT ON COLUMN "wms_inven_etc_tran"."ex_qty" IS '기_출하_수량';

-- 처리_묶음_번호
COMMENT ON COLUMN "wms_inven_etc_tran"."proc_bundle_no" IS '문서번호';

-- 처리_연월일(예외출고)
COMMENT ON COLUMN "wms_inven_etc_tran"."proc_ymd" IS '입고_일자';

-- 처리_시분초(예외출고)
COMMENT ON COLUMN "wms_inven_etc_tran"."proc_hms" IS '입고_시간';

-- 처리_자_ID(예외출고)
COMMENT ON COLUMN "wms_inven_etc_tran"."proc_user_id" IS '입고_작업자_아이디';

-- LOT_번호
COMMENT ON COLUMN "wms_inven_etc_tran"."lot_no" IS 'LOT_번호';

-- IF_송신_여부
COMMENT ON COLUMN "wms_inven_etc_tran"."if_send_yn" IS 'ERP_송신_여부';

-- IF_에러_일련번호
COMMENT ON COLUMN "wms_inven_etc_tran"."if_err_seq" IS 'IF_에러_일련번호';

-- 삭제_여부
COMMENT ON COLUMN "wms_inven_etc_tran"."del_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "wms_inven_etc_tran"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_inven_etc_tran"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_inven_etc_tran"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_inven_etc_tran"."mod_dt" IS '수정일';

-- WMS_예외출고_처리_PK
CREATE UNIQUE INDEX "wms_inven_etc_tran_PK"
	ON "wms_inven_etc_tran"
	( -- WMS_예외출고_처리
		"etc_tran_seq" ASC, -- 예외출고_처리_SEQ
		"etc_prod_seq" ASC, -- 예외출고_품목_SEQ
		"etc_seq" ASC -- 예외출고_SEQ
	)
;
-- WMS_예외출고_처리
ALTER TABLE "wms_inven_etc_tran"
	ADD CONSTRAINT "wms_inven_etc_tran_PK"
		 -- WMS_예외출고_처리_PK
	PRIMARY KEY 
	USING INDEX "wms_inven_etc_tran_PK";

-- WMS_예외출고_처리_PK
COMMENT ON CONSTRAINT "wms_inven_etc_tran_PK" ON "wms_inven_etc_tran" IS 'WMS_예외출고_처리_PK';

-- WMS_예외출고_품목
CREATE TABLE "wms_inven_etc_prod"
(
	"etc_prod_seq"    bigint        NOT NULL DEFAULT nextval('wms_inven_etc_prod_seq'), -- 예외출고_품목_SEQ
	"etc_seq"         int4          NOT NULL, -- 예외출고_SEQ
	"prod_seq"        int4          NOT NULL, -- 품목_SEQ
	"etc_prod_sts_cd" varchar(50)   NOT NULL, -- 예외출고_품목_상태_코드
	"req_qty"         decimal(10,2) NOT NULL DEFAULT 0, -- 요청_수량(예외출고)
	"ex_qty"          decimal(10,2) NOT NULL DEFAULT 0, -- 기처리_수량(예외출고)
	"est_exp_ymd"     varchar(8)    NULL,     -- 예상_유통기한
	"est_mng_ymd"     varchar(8)    NULL,     -- 예상_입고/제조일자
	"est_lot_no"      varchar(30)   NULL,     -- 예상_LOT_NO
	"if_idx"          varchar(20)   NULL,     -- IF_내부순번
	"if_send_yn"      char(1)       NOT NULL DEFAULT 'N', -- IF_송신_여부
	"if_err_seq"      int4          NULL,     -- IF_에러_일련번호
	"del_yn"          char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"          varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"          timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"          varchar(20)   NULL,     -- 수정_ID
	"mod_dt"          timestamp     NULL      -- 수정_일시
);

-- WMS_예외출고_품목
COMMENT ON TABLE "wms_inven_etc_prod" IS 'WMS_예외출고_품목';

-- 예외출고_품목_SEQ
COMMENT ON COLUMN "wms_inven_etc_prod"."etc_prod_seq" IS '예외출고_품목_SEQ';

-- 예외출고_SEQ
COMMENT ON COLUMN "wms_inven_etc_prod"."etc_seq" IS '예외출고_SEQ';

-- 품목_SEQ
COMMENT ON COLUMN "wms_inven_etc_prod"."prod_seq" IS '품목ID';

-- 예외출고_품목_상태_코드
COMMENT ON COLUMN "wms_inven_etc_prod"."etc_prod_sts_cd" IS '처리_상태_코드';

-- 요청_수량(예외출고)
COMMENT ON COLUMN "wms_inven_etc_prod"."req_qty" IS '예외출고_요청_수량';

-- 기처리_수량(예외출고)
COMMENT ON COLUMN "wms_inven_etc_prod"."ex_qty" IS '기_출하_수량';

-- 예상_유통기한
COMMENT ON COLUMN "wms_inven_etc_prod"."est_exp_ymd" IS '예상_유통기한';

-- 예상_입고/제조일자
COMMENT ON COLUMN "wms_inven_etc_prod"."est_mng_ymd" IS '예상_입고/제조일자';

-- 예상_LOT_NO
COMMENT ON COLUMN "wms_inven_etc_prod"."est_lot_no" IS '예상_LOT_NO';

-- IF_내부순번
COMMENT ON COLUMN "wms_inven_etc_prod"."if_idx" IS '순번 --';

-- IF_송신_여부
COMMENT ON COLUMN "wms_inven_etc_prod"."if_send_yn" IS 'ERP_송신_여부';

-- IF_에러_일련번호
COMMENT ON COLUMN "wms_inven_etc_prod"."if_err_seq" IS 'IF_에러_일련번호';

-- 삭제_여부
COMMENT ON COLUMN "wms_inven_etc_prod"."del_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "wms_inven_etc_prod"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_inven_etc_prod"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_inven_etc_prod"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_inven_etc_prod"."mod_dt" IS '수정일';

-- WMS_예외출고_품목_PK
CREATE UNIQUE INDEX "wms_inven_etc_prod_PK"
	ON "wms_inven_etc_prod"
	( -- WMS_예외출고_품목
		"etc_prod_seq" ASC, -- 예외출고_품목_SEQ
		"etc_seq" ASC -- 예외출고_SEQ
	)
;
-- WMS_예외출고_품목
ALTER TABLE "wms_inven_etc_prod"
	ADD CONSTRAINT "wms_inven_etc_prod_PK"
		 -- WMS_예외출고_품목_PK
	PRIMARY KEY 
	USING INDEX "wms_inven_etc_prod_PK";

-- WMS_예외출고_품목_PK
COMMENT ON CONSTRAINT "wms_inven_etc_prod_PK" ON "wms_inven_etc_prod" IS 'WMS_예외출고_품목_PK';

-- WMS_입고
CREATE TABLE "wms_inwh"
(
	"inwh_seq"     int4          NOT NULL DEFAULT nextval('wms_inwh_seq'), -- 입고_SEQ
	"biz_seq"      int4          NOT NULL, -- 사업장_SEQ
	"inwh_no"      varchar(30)   NOT NULL, -- 입고_번호
	"center_seq"   int4          NOT NULL, -- 센터_SEQ
	"inwh_type_cd" varchar(50)   NOT NULL, -- 입고_유형_코드
	"inwh_sts_cd"  varchar(50)   NOT NULL, -- 입고_상태_코드
	"req_ymd"      varchar(8)    NOT NULL, -- 예정_연월일(입고)
	"req_hms"      varchar(6)    NULL,     -- 예정_시분초(입고)
	"req_user_nm"  varchar(100)  NULL,     -- 요청_사용자_명(입고)
	"cont_seq"     int4          NULL,     -- 거래처_SEQ
	"cfm_ymd"      varchar(8)    NULL,     -- 확정_연월일(입고)
	"cfm_hms"      varchar(6)    NULL,     -- 확정_시분초(입고)
	"cfm_user_id"  varchar(20)   NULL,     -- 확정_자_ID(입고)
	"req_no"       varchar(30)   NULL,     -- 문서_번호(타시스템)
	"erp_wh_cd"    varchar(50)   NULL,     -- 입고처_CODE(타시스템)
	"note"         varchar(1000) NULL,     -- 비고
	"if_key"       varchar(50)   NULL,     -- IF_KEY
	"if_err_seq"   int4          NULL,     -- IF_에러_일련번호
	"if_send_yn"   char(1)       NOT NULL DEFAULT 'N', -- IF_송신_여부
	"del_yn"       char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"       varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"       timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"       varchar(20)   NULL,     -- 수정_ID
	"mod_dt"       timestamp     NULL      -- 수정_일시
);

-- WMS_입고
COMMENT ON TABLE "wms_inwh" IS 'WMS_입고';

-- 입고_SEQ
COMMENT ON COLUMN "wms_inwh"."inwh_seq" IS '입고_요청_번호';

-- 사업장_SEQ
COMMENT ON COLUMN "wms_inwh"."biz_seq" IS '사업장_ID';

-- 입고_번호
COMMENT ON COLUMN "wms_inwh"."inwh_no" IS '입고_요청_번호';

-- 센터_SEQ
COMMENT ON COLUMN "wms_inwh"."center_seq" IS '센터_SEQ';

-- 입고_유형_코드
COMMENT ON COLUMN "wms_inwh"."inwh_type_cd" IS '입고_유형_코드';

-- 입고_상태_코드
COMMENT ON COLUMN "wms_inwh"."inwh_sts_cd" IS '입고_요청_상태_코드';

-- 예정_연월일(입고)
COMMENT ON COLUMN "wms_inwh"."req_ymd" IS '입고_요청_일자';

-- 예정_시분초(입고)
COMMENT ON COLUMN "wms_inwh"."req_hms" IS '입고_요청_시간';

-- 요청_사용자_명(입고)
COMMENT ON COLUMN "wms_inwh"."req_user_nm" IS '입고_요청자_아이디';

-- 거래처_SEQ
COMMENT ON COLUMN "wms_inwh"."cont_seq" IS '거래처_ID';

-- 확정_연월일(입고)
COMMENT ON COLUMN "wms_inwh"."cfm_ymd" IS '입고_확정_일자';

-- 확정_시분초(입고)
COMMENT ON COLUMN "wms_inwh"."cfm_hms" IS '입고_확정_시간';

-- 확정_자_ID(입고)
COMMENT ON COLUMN "wms_inwh"."cfm_user_id" IS '입고_확인자_아이디';

-- 문서_번호(타시스템)
COMMENT ON COLUMN "wms_inwh"."req_no" IS '증빙번호';

-- 입고처_CODE(타시스템)
COMMENT ON COLUMN "wms_inwh"."erp_wh_cd" IS '입고처_CODE(타시스템)';

-- 비고
COMMENT ON COLUMN "wms_inwh"."note" IS '비고';

-- IF_KEY
COMMENT ON COLUMN "wms_inwh"."if_key" IS '발주내부_코드(ERP)';

-- IF_에러_일련번호
COMMENT ON COLUMN "wms_inwh"."if_err_seq" IS 'IF_에러_일련번호';

-- IF_송신_여부
COMMENT ON COLUMN "wms_inwh"."if_send_yn" IS 'ERP_송신_여부';

-- 삭제_여부
COMMENT ON COLUMN "wms_inwh"."del_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "wms_inwh"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_inwh"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_inwh"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_inwh"."mod_dt" IS '수정일';

-- WMS_INWH_IDX01
CREATE UNIQUE INDEX "UIX_wms_inwh"
	ON "wms_inwh"
	( -- WMS_입고
		"biz_seq" ASC, -- 사업장_SEQ
		"inwh_no" ASC -- 입고_번호
	);

-- WMS_INWH_IDX01
COMMENT ON INDEX "UIX_wms_inwh" IS 'WMS_INWH_IDX01';

-- WMS_INWH_IDX02
CREATE INDEX "IX_wms_inwh2"
	ON "wms_inwh"	( -- WMS_입고
		"biz_seq" ASC, -- 사업장_SEQ
		"center_seq" ASC, -- 센터_SEQ
		"req_ymd" ASC -- 예정_연월일(입고)
	);

-- WMS_INWH_IDX02
COMMENT ON INDEX "IX_wms_inwh2" IS 'WMS_INWH_IDX02';

-- WMS_입고_PK
CREATE UNIQUE INDEX "wms_inwh_PK"
	ON "wms_inwh"
	( -- WMS_입고
		"inwh_seq" ASC -- 입고_SEQ
	)
;
-- WMS_입고
ALTER TABLE "wms_inwh"
	ADD CONSTRAINT "wms_inwh_PK"
		 -- WMS_입고_PK
	PRIMARY KEY 
	USING INDEX "wms_inwh_PK";

-- WMS_입고_PK
COMMENT ON CONSTRAINT "wms_inwh_PK" ON "wms_inwh" IS 'WMS_입고_PK';

-- WMS_입고
ALTER TABLE "wms_inwh"
	ADD CONSTRAINT "UK_wms_inwh" -- WMS_입고 유니크 제약
	UNIQUE 
	USING INDEX "UIX_wms_inwh";

-- WMS_입고 유니크 제약
COMMENT ON CONSTRAINT "UK_wms_inwh" ON "wms_inwh" IS 'WMS_입고 유니크 제약';

-- WMS_입고_라벨
CREATE TABLE "wms_inwh_label"
(
	"inwh_label_seq" bigint        NOT NULL DEFAULT nextval('wms_inwh_label_seq'), -- 입고_라벨_SEQ
	"req_seq"        int4          NOT NULL, -- 요청_SEQ
	"req_prod_seq"   bigint        NOT NULL, -- 요청_품목_SEQ
	"inout_type_cd"  varchar(50)   NOT NULL, -- 수불_유형_코드
	"biz_seq"        int4          NOT NULL, -- 사업장_SEQ
	"center_seq"     int4          NOT NULL, -- 센터_SEQ
	"prod_seq"       int4          NOT NULL, -- 품목_SEQ
	"sku1_seq"       int4          NULL,     -- SKU1_일련번호
	"sku2_seq"       int4          NULL,     -- SKU2_일련번호
	"sku_base"       varchar(100)  NOT NULL, -- SKU_기준
	"mng_ymd"        varchar(8)    NULL,     -- 입고/제조일자
	"exp_ymd"        varchar(8)    NULL,     -- 유통기한
	"lot_no"         varchar(30)   NULL,     -- LOT_번호
	"sku1"           varchar(100)  NOT NULL, -- SKU1
	"sku2"           varchar(100)  NOT NULL, -- SKU2
	"load_qty"       decimal(10,2) NOT NULL DEFAULT 1, -- 적재_수량
	"create_ymd"     varchar(8)    NOT NULL, -- 생성_연월일
	"create_hms"     varchar(6)    NOT NULL, -- 생성_시분초
	"create_user_id" varchar(20)   NOT NULL, -- 생성_자_ID
	"note"           varchar(1000) NULL,     -- 비고
	"del_yn"         char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"         varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"         timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"         varchar(20)   NULL,     -- 수정_ID
	"mod_dt"         timestamp     NULL      -- 수정_일시
);

-- WMS_입고_라벨
COMMENT ON TABLE "wms_inwh_label" IS 'WMS_입고_라벨';

-- 입고_라벨_SEQ
COMMENT ON COLUMN "wms_inwh_label"."inwh_label_seq" IS '입고_라벨_SEQ';

-- 요청_SEQ
COMMENT ON COLUMN "wms_inwh_label"."req_seq" IS '요청_SEQ';

-- 요청_품목_SEQ
COMMENT ON COLUMN "wms_inwh_label"."req_prod_seq" IS '요청_품목_SEQ';

-- 수불_유형_코드
COMMENT ON COLUMN "wms_inwh_label"."inout_type_cd" IS '수불유형_코드';

-- 사업장_SEQ
COMMENT ON COLUMN "wms_inwh_label"."biz_seq" IS '사업장_SEQ';

-- 센터_SEQ
COMMENT ON COLUMN "wms_inwh_label"."center_seq" IS '센터_SEQ';

-- 품목_SEQ
COMMENT ON COLUMN "wms_inwh_label"."prod_seq" IS '품목_SEQ';

-- SKU1_일련번호
COMMENT ON COLUMN "wms_inwh_label"."sku1_seq" IS 'SKU1_일련번호';

-- SKU2_일련번호
COMMENT ON COLUMN "wms_inwh_label"."sku2_seq" IS 'SKU2_일련번호';

-- SKU_기준
COMMENT ON COLUMN "wms_inwh_label"."sku_base" IS 'SKU_기준';

-- 입고/제조일자
COMMENT ON COLUMN "wms_inwh_label"."mng_ymd" IS '제조일자';

-- 유통기한
COMMENT ON COLUMN "wms_inwh_label"."exp_ymd" IS '유통기한';

-- LOT_번호
COMMENT ON COLUMN "wms_inwh_label"."lot_no" IS 'LOT_번호';

-- SKU1
COMMENT ON COLUMN "wms_inwh_label"."sku1" IS 'SKU1';

-- SKU2
COMMENT ON COLUMN "wms_inwh_label"."sku2" IS 'SKU2';

-- 적재_수량
COMMENT ON COLUMN "wms_inwh_label"."load_qty" IS '적재_수량';

-- 생성_연월일
COMMENT ON COLUMN "wms_inwh_label"."create_ymd" IS '생성_연월일';

-- 생성_시분초
COMMENT ON COLUMN "wms_inwh_label"."create_hms" IS '생성_시분초';

-- 생성_자_ID
COMMENT ON COLUMN "wms_inwh_label"."create_user_id" IS '생성_자_ID';

-- 비고
COMMENT ON COLUMN "wms_inwh_label"."note" IS '비고';

-- 삭제_여부
COMMENT ON COLUMN "wms_inwh_label"."del_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "wms_inwh_label"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_inwh_label"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_inwh_label"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_inwh_label"."mod_dt" IS '수정일';

-- WMS_입고_라벨_PK
CREATE UNIQUE INDEX "wms_inwh_label_PK"
	ON "wms_inwh_label"
	( -- WMS_입고_라벨
		"inwh_label_seq" ASC -- 입고_라벨_SEQ
	)
;
-- WMS_입고_라벨
ALTER TABLE "wms_inwh_label"
	ADD CONSTRAINT "wms_inwh_label_PK"
		 -- WMS_입고_라벨_PK
	PRIMARY KEY 
	USING INDEX "wms_inwh_label_PK";

-- WMS_입고_라벨_PK
COMMENT ON CONSTRAINT "wms_inwh_label_PK" ON "wms_inwh_label" IS 'WMS_입고_라벨_PK';

-- WMS_입고_처리
CREATE TABLE "wms_inwh_tran"
(
	"inwh_tran_seq"  bigint        NOT NULL DEFAULT nextval('wms_inwh_tran_seq'), -- 입고_처리_SEQ
	"inwh_prod_seq"  bigint        NOT NULL, -- 입고_품목_SEQ
	"inwh_seq"       int4          NOT NULL, -- 입고_SEQ
	"prod_seq"       int4          NOT NULL, -- 품목_SEQ
	"sku1"           varchar(100)  NOT NULL, -- SKU1
	"sku2"           varchar(100)  NOT NULL, -- SKU2 
	"mng_ymd"        varchar(8)    NULL,     -- 입고/제조일자
	"exp_ymd"        varchar(8)    NULL,     -- 유통기한_연월일
	"lot_no"         varchar(30)   NULL,     -- LOT_NO
	"proc_qty"       decimal(10,2) NOT NULL DEFAULT 0, -- 처리_수량(입고)
	"ex_qty"         decimal(10,2) NOT NULL DEFAULT 0, -- 기처리_수량(입고)
	"to_wh_seq"      int4          NOT NULL, -- TO_창고_SEQ
	"to_loc_seq"     bigint        NOT NULL, -- TO_위치_SEQ
	"proc_bundle_no" varchar(30)   NULL,     -- 처리_묶음_번호
	"proc_ymd"       varchar(8)    NULL,     -- 처리_연월일(입고)
	"proc_hms"       varchar(6)    NULL,     -- 처리_시분초(입고)
	"proc_user_id"   varchar(20)   NULL,     -- 처리_자_ID(입고)
	"if_err_seq"     int4          NULL,     -- IF_에러_일련번호
	"if_send_yn"     char(1)       NOT NULL DEFAULT 'N', -- IF_송신_여부
	"del_yn"         char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"         varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"         timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"         varchar(20)   NULL,     -- 수정_ID
	"mod_dt"         timestamp     NULL      -- 수정_일시
);

-- WMS_입고_처리
COMMENT ON TABLE "wms_inwh_tran" IS 'WMS_입고_처리';

-- 입고_처리_SEQ
COMMENT ON COLUMN "wms_inwh_tran"."inwh_tran_seq" IS '입고_처리_SEQ';

-- 입고_품목_SEQ
COMMENT ON COLUMN "wms_inwh_tran"."inwh_prod_seq" IS '입고_품목_SEQ';

-- 입고_SEQ
COMMENT ON COLUMN "wms_inwh_tran"."inwh_seq" IS '입고_SEQ';

-- 품목_SEQ
COMMENT ON COLUMN "wms_inwh_tran"."prod_seq" IS '품목ID';

-- SKU1
COMMENT ON COLUMN "wms_inwh_tran"."sku1" IS 'SKU1(FR)';

-- SKU2 
COMMENT ON COLUMN "wms_inwh_tran"."sku2" IS 'SKU2(FR)';

-- 입고/제조일자
COMMENT ON COLUMN "wms_inwh_tran"."mng_ymd" IS '입고/제조일자';

-- 유통기한_연월일
COMMENT ON COLUMN "wms_inwh_tran"."exp_ymd" IS '유통기한_연월일';

-- LOT_NO
COMMENT ON COLUMN "wms_inwh_tran"."lot_no" IS 'LOT_NO';

-- 처리_수량(입고)
COMMENT ON COLUMN "wms_inwh_tran"."proc_qty" IS '입고_수량';

-- 기처리_수량(입고)
COMMENT ON COLUMN "wms_inwh_tran"."ex_qty" IS '기입고_처리량';

-- TO_창고_SEQ
COMMENT ON COLUMN "wms_inwh_tran"."to_wh_seq" IS '창고(TO)';

-- TO_위치_SEQ
COMMENT ON COLUMN "wms_inwh_tran"."to_loc_seq" IS '위치(TO)';

-- 처리_묶음_번호
COMMENT ON COLUMN "wms_inwh_tran"."proc_bundle_no" IS '처리_묶음_번호';

-- 처리_연월일(입고)
COMMENT ON COLUMN "wms_inwh_tran"."proc_ymd" IS '입고_일자';

-- 처리_시분초(입고)
COMMENT ON COLUMN "wms_inwh_tran"."proc_hms" IS '입고_시간';

-- 처리_자_ID(입고)
COMMENT ON COLUMN "wms_inwh_tran"."proc_user_id" IS '입고_작업자_아이디';

-- IF_에러_일련번호
COMMENT ON COLUMN "wms_inwh_tran"."if_err_seq" IS 'IF_에러_일련번호';

-- IF_송신_여부
COMMENT ON COLUMN "wms_inwh_tran"."if_send_yn" IS 'ERP_송신_여부';

-- 삭제_여부
COMMENT ON COLUMN "wms_inwh_tran"."del_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "wms_inwh_tran"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_inwh_tran"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_inwh_tran"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_inwh_tran"."mod_dt" IS '수정일';

-- WMS_입고_처리_PK
CREATE UNIQUE INDEX "wms_inwh_tran_PK"
	ON "wms_inwh_tran"
	( -- WMS_입고_처리
		"inwh_tran_seq" ASC, -- 입고_처리_SEQ
		"inwh_prod_seq" ASC, -- 입고_품목_SEQ
		"inwh_seq" ASC -- 입고_SEQ
	)
;
-- WMS_입고_처리
ALTER TABLE "wms_inwh_tran"
	ADD CONSTRAINT "wms_inwh_tran_PK"
		 -- WMS_입고_처리_PK
	PRIMARY KEY 
	USING INDEX "wms_inwh_tran_PK";

-- WMS_입고_처리_PK
COMMENT ON CONSTRAINT "wms_inwh_tran_PK" ON "wms_inwh_tran" IS 'WMS_입고_처리_PK';

-- WMS_입고_품목
CREATE TABLE "wms_inwh_prod"
(
	"inwh_prod_seq"    bigint        NOT NULL DEFAULT nextval('wms_inwh_prod_seq'), -- 입고_품목_SEQ
	"inwh_seq"         int4          NOT NULL, -- 입고_SEQ
	"prod_seq"         int4          NOT NULL, -- 품목_SEQ
	"inwh_prod_sts_cd" varchar(50)   NOT NULL, -- 입고_품목_상태_코드
	"req_qty"          decimal(10,2) NOT NULL DEFAULT 0, -- 요청_수량(입고)
	"ex_qty"           decimal(10,2) NOT NULL DEFAULT 0, -- 기처리_수량(입고)
	"est_exp_ymd"      varchar(8)    NULL,     -- 예상_유통기한
	"est_mng_ymd"      varchar(8)    NULL,     -- 예상_입고/제조일자
	"est_lot_no"       varchar(30)   NULL,     -- 예상_LOT_NO
	"pub_sku1_yn"      char(1)       NOT NULL DEFAULT 'N', -- SKU1_발행여부
	"pub_sku2_yn"      char(1)       NOT NULL DEFAULT 'N', -- SKU2_발행여부
	"pltzing_yn"       char(1)       NOT NULL DEFAULT 'N', -- 파렛타이징_여부
	"if_send_yn"       char(1)       NOT NULL DEFAULT 'N', -- IF_송신_여부
	"if_idx"           varchar(20)   NULL,     -- IF_내부순번
	"if_err_seq"       int4          NULL,     -- IF_에러_일련번호
	"del_yn"           char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"           varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"           timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"           varchar(20)   NULL,     -- 수정_ID
	"mod_dt"           timestamp     NULL      -- 수정_일시
);

-- WMS_입고_품목
COMMENT ON TABLE "wms_inwh_prod" IS 'WMS_입고_품목';

-- 입고_품목_SEQ
COMMENT ON COLUMN "wms_inwh_prod"."inwh_prod_seq" IS '입고_품목_SEQ';

-- 입고_SEQ
COMMENT ON COLUMN "wms_inwh_prod"."inwh_seq" IS '입고_SEQ';

-- 품목_SEQ
COMMENT ON COLUMN "wms_inwh_prod"."prod_seq" IS '품목ID';

-- 입고_품목_상태_코드
COMMENT ON COLUMN "wms_inwh_prod"."inwh_prod_sts_cd" IS '입고_상태_코드';

-- 요청_수량(입고)
COMMENT ON COLUMN "wms_inwh_prod"."req_qty" IS '입고_요청_수량';

-- 기처리_수량(입고)
COMMENT ON COLUMN "wms_inwh_prod"."ex_qty" IS '기입고_처리량';

-- 예상_유통기한
COMMENT ON COLUMN "wms_inwh_prod"."est_exp_ymd" IS '예상_유통기한';

-- 예상_입고/제조일자
COMMENT ON COLUMN "wms_inwh_prod"."est_mng_ymd" IS '예상_입고/제조일자';

-- 예상_LOT_NO
COMMENT ON COLUMN "wms_inwh_prod"."est_lot_no" IS '예상_LOT_NO';

-- SKU1_발행여부
COMMENT ON COLUMN "wms_inwh_prod"."pub_sku1_yn" IS 'SKU1_발행여부';

-- SKU2_발행여부
COMMENT ON COLUMN "wms_inwh_prod"."pub_sku2_yn" IS 'SKU2_발행여부';

-- 파렛타이징_여부
COMMENT ON COLUMN "wms_inwh_prod"."pltzing_yn" IS '파렛타이징_여부';

-- IF_송신_여부
COMMENT ON COLUMN "wms_inwh_prod"."if_send_yn" IS 'ERP_송신_여부';

-- IF_내부순번
COMMENT ON COLUMN "wms_inwh_prod"."if_idx" IS '순번 --';

-- IF_에러_일련번호
COMMENT ON COLUMN "wms_inwh_prod"."if_err_seq" IS 'IF_에러_일련번호';

-- 삭제_여부
COMMENT ON COLUMN "wms_inwh_prod"."del_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "wms_inwh_prod"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_inwh_prod"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_inwh_prod"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_inwh_prod"."mod_dt" IS '수정일';

-- WMS_입고_품목_PK
CREATE UNIQUE INDEX "wms_inwh_prod_PK"
	ON "wms_inwh_prod"
	( -- WMS_입고_품목
		"inwh_prod_seq" ASC, -- 입고_품목_SEQ
		"inwh_seq" ASC -- 입고_SEQ
	)
;
-- WMS_입고_품목
ALTER TABLE "wms_inwh_prod"
	ADD CONSTRAINT "wms_inwh_prod_PK"
		 -- WMS_입고_품목_PK
	PRIMARY KEY 
	USING INDEX "wms_inwh_prod_PK";

-- WMS_입고_품목_PK
COMMENT ON CONSTRAINT "wms_inwh_prod_PK" ON "wms_inwh_prod" IS 'WMS_입고_품목_PK';

-- WMS_입하
CREATE TABLE "wms_inbiz"
(
	"inbiz_seq"     int4          NOT NULL DEFAULT nextval('wms_inbiz_seq'), -- 입하_SEQ
	"biz_seq"       int4          NOT NULL, -- 사업장_SEQ
	"inbiz_no"      varchar(30)   NOT NULL, -- 입하_번호
	"center_seq"    int4          NOT NULL, -- 센터_SEQ
	"inbiz_type_cd" varchar(50)   NOT NULL, -- 입하_유형_코드
	"inbiz_sts_cd"  varchar(50)   NULL,     -- 입하_상태_코드
	"po_no"         varchar(100)  NOT NULL, -- 구매발주_번호
	"po_ymd"        varchar(8)    NULL,     -- 발주_년월일
	"po_user_nm"    varchar(100)  NULL,     -- 발주_담당자_명
	"bl_no"         varchar(100)  NULL,     -- B/L_번호
	"cc_no"         varchar(100)  NULL,     -- 수입통관_번호
	"req_ymd"       varchar(8)    NOT NULL, -- 예정_연월일(입하)
	"req_hms"       varchar(6)    NULL,     -- 예정_시분초(입하)
	"req_user_nm"   varchar(100)  NULL,     -- 요청_사용자_명(입하)
	"cont_seq"      int4          NULL,     -- 거래처_SEQ
	"cfm_ymd"       varchar(8)    NULL,     -- 확정_연월일(입하)
	"cfm_hms"       varchar(6)    NULL,     -- 확정_시분초(입하)
	"cfm_user_id"   varchar(20)   NULL,     -- 확정_자_ID(입하)
	"note"          varchar(1000) NULL,     -- 비고
	"req_no"        varchar(30)   NULL,     -- 문서_번호(타시스템)
	"erp_wh_cd"     varchar(50)   NULL,     -- 입고처_CODE(타시스템)
	"if_key"        varchar(50)   NULL,     -- IF_KEY
	"if_err_seq"    int4          NULL,     -- IF_에러_일련번호
	"if_send_yn"    char(1)       NOT NULL DEFAULT 'N', -- IF_송신_여부
	"del_yn"        char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"        varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"        timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"        varchar(20)   NULL,     -- 수정_ID
	"mod_dt"        timestamp     NULL      -- 수정_일시
);

-- WMS_입하
COMMENT ON TABLE "wms_inbiz" IS 'WMS_입하';

-- 입하_SEQ
COMMENT ON COLUMN "wms_inbiz"."inbiz_seq" IS '입하_SEQ';

-- 사업장_SEQ
COMMENT ON COLUMN "wms_inbiz"."biz_seq" IS '사업장_SEQ';

-- 입하_번호
COMMENT ON COLUMN "wms_inbiz"."inbiz_no" IS '입하_번호';

-- 센터_SEQ
COMMENT ON COLUMN "wms_inbiz"."center_seq" IS '센터_SEQ';

-- 입하_유형_코드
COMMENT ON COLUMN "wms_inbiz"."inbiz_type_cd" IS '입하_유형_코드';

-- 입하_상태_코드
COMMENT ON COLUMN "wms_inbiz"."inbiz_sts_cd" IS '입하_상태_코드';

-- 구매발주_번호
COMMENT ON COLUMN "wms_inbiz"."po_no" IS '구매번호(ERP)';

-- 발주_년월일
COMMENT ON COLUMN "wms_inbiz"."po_ymd" IS '발주_년월일';

-- 발주_담당자_명
COMMENT ON COLUMN "wms_inbiz"."po_user_nm" IS '발주_담당자_명';

-- B/L_번호
COMMENT ON COLUMN "wms_inbiz"."bl_no" IS 'B/L_번호';

-- 수입통관_번호
COMMENT ON COLUMN "wms_inbiz"."cc_no" IS '수입통관_번호';

-- 예정_연월일(입하)
COMMENT ON COLUMN "wms_inbiz"."req_ymd" IS '입고_요청_일자';

-- 예정_시분초(입하)
COMMENT ON COLUMN "wms_inbiz"."req_hms" IS '입고_요청_시간';

-- 요청_사용자_명(입하)
COMMENT ON COLUMN "wms_inbiz"."req_user_nm" IS '입고_요청자_아이디';

-- 거래처_SEQ
COMMENT ON COLUMN "wms_inbiz"."cont_seq" IS '거래처_ID';

-- 확정_연월일(입하)
COMMENT ON COLUMN "wms_inbiz"."cfm_ymd" IS '입고_확정_일자';

-- 확정_시분초(입하)
COMMENT ON COLUMN "wms_inbiz"."cfm_hms" IS '입고_확정_시간';

-- 확정_자_ID(입하)
COMMENT ON COLUMN "wms_inbiz"."cfm_user_id" IS '입고_확인자_아이디';

-- 비고
COMMENT ON COLUMN "wms_inbiz"."note" IS '비고';

-- 문서_번호(타시스템)
COMMENT ON COLUMN "wms_inbiz"."req_no" IS '증빙번호';

-- 입고처_CODE(타시스템)
COMMENT ON COLUMN "wms_inbiz"."erp_wh_cd" IS '입고처_CODE(타시스템)';

-- IF_KEY
COMMENT ON COLUMN "wms_inbiz"."if_key" IS '발주내부_코드(ERP)';

-- IF_에러_일련번호
COMMENT ON COLUMN "wms_inbiz"."if_err_seq" IS 'IF_에러_일련번호';

-- IF_송신_여부
COMMENT ON COLUMN "wms_inbiz"."if_send_yn" IS 'ERP_송신_여부';

-- 삭제_여부
COMMENT ON COLUMN "wms_inbiz"."del_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "wms_inbiz"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_inbiz"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_inbiz"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_inbiz"."mod_dt" IS '수정일';

-- WMS_입하_PK
CREATE UNIQUE INDEX "wms_inbiz_PK"
	ON "wms_inbiz"
	( -- WMS_입하
		"inbiz_seq" ASC -- 입하_SEQ
	)
;
-- WMS_입하
ALTER TABLE "wms_inbiz"
	ADD CONSTRAINT "wms_inbiz_PK"
		 -- WMS_입하_PK
	PRIMARY KEY 
	USING INDEX "wms_inbiz_PK";

-- WMS_입하_PK
COMMENT ON CONSTRAINT "wms_inbiz_PK" ON "wms_inbiz" IS 'WMS_입하_PK';

-- WMS_입하_입고
CREATE TABLE "wms_inbiz_inwh"
(
	"inbiz_seq"      int4          NULL,     -- 입하_SEQ
	"inbiz_prod_seq" bigint        NULL,     -- 입하_품목_SEQ
	"inwh_seq"       int4          NULL,     -- 입고_SEQ
	"inwh_prod_seq"  bigint        NULL,     -- 입고_품목_SEQ
	"req_qty"        decimal(10,2) NULL     DEFAULT 0, -- 요청_수량
	"del_yn"         char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"         varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"         timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"         varchar(20)   NULL,     -- 수정_ID
	"mod_dt"         timestamp     NULL      -- 수정_일시
);

-- WMS_입하_입고
COMMENT ON TABLE "wms_inbiz_inwh" IS 'WMS_입하_입고';

-- 입하_SEQ
COMMENT ON COLUMN "wms_inbiz_inwh"."inbiz_seq" IS '입하_SEQ';

-- 입하_품목_SEQ
COMMENT ON COLUMN "wms_inbiz_inwh"."inbiz_prod_seq" IS '입하_품목_SEQ';

-- 입고_SEQ
COMMENT ON COLUMN "wms_inbiz_inwh"."inwh_seq" IS '입고_SEQ';

-- 입고_품목_SEQ
COMMENT ON COLUMN "wms_inbiz_inwh"."inwh_prod_seq" IS '입고_품목_SEQ';

-- 요청_수량
COMMENT ON COLUMN "wms_inbiz_inwh"."req_qty" IS '요청_수량';

-- 삭제_여부
COMMENT ON COLUMN "wms_inbiz_inwh"."del_yn" IS '삭제_여부';

-- 등록_ID
COMMENT ON COLUMN "wms_inbiz_inwh"."reg_id" IS '등록_ID';

-- 등록_일시
COMMENT ON COLUMN "wms_inbiz_inwh"."reg_dt" IS '등록_일시';

-- 수정_ID
COMMENT ON COLUMN "wms_inbiz_inwh"."mod_id" IS '수정_ID';

-- 수정_일시
COMMENT ON COLUMN "wms_inbiz_inwh"."mod_dt" IS '수정_일시';

-- WMS_입하_품목
CREATE TABLE "wms_inbiz_prod"
(
	"inbiz_prod_seq"    bigint        NOT NULL DEFAULT nextval('wms_inbiz_prod_seq'), -- 입하_품목_SEQ
	"inbiz_seq"         int4          NOT NULL, -- 입하_SEQ
	"prod_seq"          int4          NOT NULL, -- 품목_SEQ
	"inbiz_prod_sts_cd" varchar(50)   NOT NULL, -- 입하_품목_상태_코드
	"req_qty"           decimal(10,2) NOT NULL DEFAULT 0, -- 요청_수량(입하)
	"ex_qty"            decimal(10,2) NOT NULL DEFAULT 0, -- 기처리_수량(입하)
	"lot_no"            varchar(30)   NULL,     -- LOT_번호
	"if_send_yn"        char(1)       NOT NULL DEFAULT 'N', -- IF_송신_여부
	"if_idx"            varchar(20)   NULL,     -- IF_내부순번
	"if_err_seq"        int4          NULL,     -- IF_에러_일련번호
	"del_yn"            char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"            varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"            timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"            varchar(20)   NULL,     -- 수정_ID
	"mod_dt"            timestamp     NULL      -- 수정_일시
);

-- WMS_입하_품목
COMMENT ON TABLE "wms_inbiz_prod" IS 'WMS_입하_품목';

-- 입하_품목_SEQ
COMMENT ON COLUMN "wms_inbiz_prod"."inbiz_prod_seq" IS '입하_품목_SEQ';

-- 입하_SEQ
COMMENT ON COLUMN "wms_inbiz_prod"."inbiz_seq" IS '입하_SEQ';

-- 품목_SEQ
COMMENT ON COLUMN "wms_inbiz_prod"."prod_seq" IS '품목ID';

-- 입하_품목_상태_코드
COMMENT ON COLUMN "wms_inbiz_prod"."inbiz_prod_sts_cd" IS '입고_상태_코드';

-- 요청_수량(입하)
COMMENT ON COLUMN "wms_inbiz_prod"."req_qty" IS '입고_요청_수량';

-- 기처리_수량(입하)
COMMENT ON COLUMN "wms_inbiz_prod"."ex_qty" IS '기입고_처리량';

-- LOT_번호
COMMENT ON COLUMN "wms_inbiz_prod"."lot_no" IS 'LOT_번호';

-- IF_송신_여부
COMMENT ON COLUMN "wms_inbiz_prod"."if_send_yn" IS 'ERP_송신_여부';

-- IF_내부순번
COMMENT ON COLUMN "wms_inbiz_prod"."if_idx" IS '순번 --';

-- IF_에러_일련번호
COMMENT ON COLUMN "wms_inbiz_prod"."if_err_seq" IS 'IF_에러_일련번호';

-- 삭제_여부
COMMENT ON COLUMN "wms_inbiz_prod"."del_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "wms_inbiz_prod"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_inbiz_prod"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_inbiz_prod"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_inbiz_prod"."mod_dt" IS '수정일';

-- WMS_입하_품목_PK
CREATE UNIQUE INDEX "wms_inbiz_prod_PK"
	ON "wms_inbiz_prod"
	( -- WMS_입하_품목
		"inbiz_prod_seq" ASC, -- 입하_품목_SEQ
		"inbiz_seq" ASC -- 입하_SEQ
	)
;
-- WMS_입하_품목
ALTER TABLE "wms_inbiz_prod"
	ADD CONSTRAINT "wms_inbiz_prod_PK"
		 -- WMS_입하_품목_PK
	PRIMARY KEY 
	USING INDEX "wms_inbiz_prod_PK";

-- WMS_입하_품목_PK
COMMENT ON CONSTRAINT "wms_inbiz_prod_PK" ON "wms_inbiz_prod" IS 'WMS_입하_품목_PK';

-- WMS_재고
CREATE TABLE "wms_inven"
(
	"biz_seq"    int4          NOT NULL, -- 사업장_SEQ
	"center_seq" int4          NOT NULL, -- 센터_SEQ
	"prod_seq"   int4          NOT NULL, -- 품목_SEQ
	"sku1"       varchar(100)  NOT NULL, -- SKU1
	"sku2"       varchar(100)  NOT NULL, -- SKU2
	"wh_seq"     int4          NOT NULL, -- 창고_SEQ
	"loc_seq"    bigint        NOT NULL, -- 위치_SEQ
	"inven_qty"  decimal(10,2) NOT NULL DEFAULT 0, -- 재고_수량
	"wt_qty"     decimal(10,2) NOT NULL DEFAULT 0, -- 대기재고_수량
	"qc_yn"      char(1)       NOT NULL DEFAULT 'N', -- 검사_여부
	"del_yn"     char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"     varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"     timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"     varchar(20)   NULL,     -- 수정_ID
	"mod_dt"     timestamp     NULL      -- 수정_일시
);

-- WMS_재고
COMMENT ON TABLE "wms_inven" IS 'WMS_재고';

-- 사업장_SEQ
COMMENT ON COLUMN "wms_inven"."biz_seq" IS '사업장_ID';

-- 센터_SEQ
COMMENT ON COLUMN "wms_inven"."center_seq" IS '센터_SEQ';

-- 품목_SEQ
COMMENT ON COLUMN "wms_inven"."prod_seq" IS '품목ID';

-- SKU1
COMMENT ON COLUMN "wms_inven"."sku1" IS 'SKU1';

-- SKU2
COMMENT ON COLUMN "wms_inven"."sku2" IS 'SKU2';

-- 창고_SEQ
COMMENT ON COLUMN "wms_inven"."wh_seq" IS '창고_ID';

-- 위치_SEQ
COMMENT ON COLUMN "wms_inven"."loc_seq" IS '위치_ID';

-- 재고_수량
COMMENT ON COLUMN "wms_inven"."inven_qty" IS '재고_수량';

-- 대기재고_수량
COMMENT ON COLUMN "wms_inven"."wt_qty" IS '대기재고_수량';

-- 검사_여부
COMMENT ON COLUMN "wms_inven"."qc_yn" IS '확정_여부';

-- 삭제_여부
COMMENT ON COLUMN "wms_inven"."del_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "wms_inven"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_inven"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_inven"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_inven"."mod_dt" IS '수정일';

-- WMS_재고 유니크 인덱스
CREATE UNIQUE INDEX "UIX_wms_inven"
	ON "wms_inven"
	( -- WMS_재고
		"biz_seq" ASC, -- 사업장_SEQ
		"center_seq" ASC, -- 센터_SEQ
		"prod_seq" ASC, -- 품목_SEQ
		"sku1" ASC, -- SKU1
		"sku2" ASC, -- SKU2
		"wh_seq" ASC, -- 창고_SEQ
		"loc_seq" ASC -- 위치_SEQ
	);

-- WMS_재고 유니크 인덱스
COMMENT ON INDEX "UIX_wms_inven" IS 'WMS_재고 유니크 인덱스';

-- WMS_재고_PK
CREATE UNIQUE INDEX "wms_inven_PK"
	ON "wms_inven"
	( -- WMS_재고
		"biz_seq" ASC, -- 사업장_SEQ
		"center_seq" ASC, -- 센터_SEQ
		"prod_seq" ASC, -- 품목_SEQ
		"sku1" ASC, -- SKU1
		"sku2" ASC, -- SKU2
		"wh_seq" ASC, -- 창고_SEQ
		"loc_seq" ASC -- 위치_SEQ
	)
;
-- WMS_재고
ALTER TABLE "wms_inven"
	ADD CONSTRAINT "wms_inven_PK"
		 -- WMS_재고_PK
	PRIMARY KEY 
	USING INDEX "wms_inven_PK";

-- WMS_재고_PK
COMMENT ON CONSTRAINT "wms_inven_PK" ON "wms_inven" IS 'WMS_재고_PK';

-- WMS_재고
ALTER TABLE "wms_inven"
	ADD CONSTRAINT "UK_wms_inven" -- WMS_재고 유니크 제약
	UNIQUE 
	USING INDEX "UIX_wms_inven";

-- WMS_재고 유니크 제약
COMMENT ON CONSTRAINT "UK_wms_inven" ON "wms_inven" IS 'WMS_재고 유니크 제약';

-- WMS_재고_SKU이력
CREATE TABLE "wms_inven_sku"
(
	"biz_seq"        int4          NOT NULL, -- 사업장_SEQ
	"prod_seq"       int4          NOT NULL, -- 품목_SEQ
	"sku1"           varchar(100)  NOT NULL, -- SKU1
	"sku2"           varchar(100)  NOT NULL, -- SKU2
	"center_seq"     int4          NOT NULL, -- 센터_SEQ
	"sku1_seq"       int4          NULL,     -- SKU1_일련번호
	"sku2_seq"       int4          NULL,     -- SKU2_일련번호
	"load_qty"       decimal(10,2) NOT NULL DEFAULT 0, -- 적재_수량
	"create_ymd"     varchar(8)    NOT NULL, -- 생성_연월일
	"create_hms"     varchar(6)    NOT NULL, -- 생성_시분초
	"create_user_id" varchar(20)   NOT NULL, -- 생성_자_ID
	"mng_ymd"        varchar(8)    NULL,     -- 입고/제조일자
	"exp_ymd"        varchar(8)    NULL,     -- 유통기한_연월일
	"lot_no"         varchar(30)   NULL,     -- LOT_번호
	"bl_no"          varchar(30)   NULL,     -- BL_번호
	"inout_type_cd"  varchar(50)   NOT NULL, -- 수불_유형_코드
	"inout_dtl_cd"   varchar(50)   NOT NULL, -- 수불_상세_코드
	"del_yn"         char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"         varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"         timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"         varchar(20)   NULL,     -- 수정_ID
	"mod_dt"         timestamp     NULL      -- 수정_일시
);

-- WMS_재고_SKU이력
COMMENT ON TABLE "wms_inven_sku" IS 'WMS_재고_SKU이력';

-- 사업장_SEQ
COMMENT ON COLUMN "wms_inven_sku"."biz_seq" IS '사업장_ID';

-- 품목_SEQ
COMMENT ON COLUMN "wms_inven_sku"."prod_seq" IS '품목ID';

-- SKU1
COMMENT ON COLUMN "wms_inven_sku"."sku1" IS 'SKU1(자)';

-- SKU2
COMMENT ON COLUMN "wms_inven_sku"."sku2" IS 'SKU2(모)';

-- 센터_SEQ
COMMENT ON COLUMN "wms_inven_sku"."center_seq" IS '센터_SEQ';

-- SKU1_일련번호
COMMENT ON COLUMN "wms_inven_sku"."sku1_seq" IS '일련번호';

-- SKU2_일련번호
COMMENT ON COLUMN "wms_inven_sku"."sku2_seq" IS '일련번호';

-- 적재_수량
COMMENT ON COLUMN "wms_inven_sku"."load_qty" IS 'SKU생성갯수';

-- 생성_연월일
COMMENT ON COLUMN "wms_inven_sku"."create_ymd" IS '생성일자';

-- 생성_시분초
COMMENT ON COLUMN "wms_inven_sku"."create_hms" IS '생성시간';

-- 생성_자_ID
COMMENT ON COLUMN "wms_inven_sku"."create_user_id" IS '생성자_아이디';

-- 입고/제조일자
COMMENT ON COLUMN "wms_inven_sku"."mng_ymd" IS '입고/제조일자';

-- 유통기한_연월일
COMMENT ON COLUMN "wms_inven_sku"."exp_ymd" IS '유통기한';

-- LOT_번호
COMMENT ON COLUMN "wms_inven_sku"."lot_no" IS 'LOT_번호';

-- BL_번호
COMMENT ON COLUMN "wms_inven_sku"."bl_no" IS 'BL_번호';

-- 수불_유형_코드
COMMENT ON COLUMN "wms_inven_sku"."inout_type_cd" IS '수불유형_코드';

-- 수불_상세_코드
COMMENT ON COLUMN "wms_inven_sku"."inout_dtl_cd" IS '처리_유형_코드';

-- 삭제_여부
COMMENT ON COLUMN "wms_inven_sku"."del_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "wms_inven_sku"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_inven_sku"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_inven_sku"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_inven_sku"."mod_dt" IS '수정일';

-- WMS_재고_SKU이력_PK
CREATE UNIQUE INDEX "wms_inven_sku_PK"
	ON "wms_inven_sku"
	( -- WMS_재고_SKU이력
		"biz_seq" ASC, -- 사업장_SEQ
		"prod_seq" ASC, -- 품목_SEQ
		"sku1" ASC, -- SKU1
		"sku2" ASC -- SKU2
	)
;
-- WMS_재고_SKU이력
ALTER TABLE "wms_inven_sku"
	ADD CONSTRAINT "wms_inven_sku_PK"
		 -- WMS_재고_SKU이력_PK
	PRIMARY KEY 
	USING INDEX "wms_inven_sku_PK";

-- WMS_재고_SKU이력_PK
COMMENT ON CONSTRAINT "wms_inven_sku_PK" ON "wms_inven_sku" IS 'WMS_재고_SKU이력_PK';

-- WMS_재고_수불
CREATE TABLE "wms_inven_inout"
(
	"inven_inout_seq" bigint        NOT NULL DEFAULT nextval('wms_inven_inout_seq'), -- 재고_수불_SEQ
	"biz_seq"         int4          NOT NULL, -- 사업장_SEQ
	"prod_seq"        int4          NOT NULL, -- 품목_SEQ
	"proc_ymd"        varchar(8)    NOT NULL, -- 처리_연월일
	"proc_hmsms"      varchar(9)    NOT NULL, -- 처리_시분초밀리초
	"inout_type_cd"   varchar(50)   NOT NULL, -- 수불_유형_코드
	"inout_dtl_cd"    varchar(50)   NOT NULL, -- 수불_상세_코드
	"proc_qty"        decimal(10,2) NOT NULL DEFAULT 0, -- 처리_수량
	"proc_user_id"    varchar(20)   NOT NULL, -- 처리_자_ID
	"center_seq"      int4          NOT NULL, -- 센터_SEQ
	"fr_wh_seq"       int4          NULL,     -- FR_창고_SEQ
	"fr_loc_seq"      bigint        NULL,     -- FR_위치_SEQ
	"fr_sku1"         varchar(100)  NULL,     -- FR_SKU1
	"fr_sku2"         varchar(100)  NULL,     -- FR_SKU2
	"to_wh_seq"       int4          NULL,     -- TO_창고_SEQ
	"to_loc_seq"      bigint        NULL,     -- TO_위치_SEQ
	"to_sku1"         varchar(100)  NULL,     -- TO_SKU1
	"to_sku2"         varchar(100)  NULL,     -- TO_SKU2
	"fr_lot_no"       varchar(30)   NULL,     -- FR_LOT_번호
	"fr_mng_ymd"      varchar(8)    NULL,     -- FR_입고/제조일자
	"fr_exp_ymd"      varchar(8)    NULL,     -- FR_유통기한
	"to_lot_no"       varchar(30)   NULL,     -- TO_LOT_번호
	"to_mng_ymd"      varchar(8)    NULL,     -- TO_입고/제조일자
	"to_exp_ymd"      varchar(8)    NULL,     -- TO_유통기한
	"proc_bundle_no"  varchar(30)   NULL,     -- 처리_묶음_번호
	"req_seq"         int4          NOT NULL, -- 요청_SEQ
	"req_no"          varchar(30)   NOT NULL, -- 업무_번호
	"proc_sts_cd"     char(1)       NOT NULL DEFAULT 'Y', -- 처리_상태_코드
	"reg_id"          varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"          timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"          varchar(20)   NULL,     -- 수정_ID
	"mod_dt"          timestamp     NULL      -- 수정_일시
);

-- WMS_재고_수불
COMMENT ON TABLE "wms_inven_inout" IS 'WMS_재고_수불';

-- 재고_수불_SEQ
COMMENT ON COLUMN "wms_inven_inout"."inven_inout_seq" IS '수불번호';

-- 사업장_SEQ
COMMENT ON COLUMN "wms_inven_inout"."biz_seq" IS '사업장_ID';

-- 품목_SEQ
COMMENT ON COLUMN "wms_inven_inout"."prod_seq" IS '품목ID';

-- 처리_연월일
COMMENT ON COLUMN "wms_inven_inout"."proc_ymd" IS '처리일자';

-- 처리_시분초밀리초
COMMENT ON COLUMN "wms_inven_inout"."proc_hmsms" IS '처리시분초밀리초';

-- 수불_유형_코드
COMMENT ON COLUMN "wms_inven_inout"."inout_type_cd" IS '수불유형_코드';

-- 수불_상세_코드
COMMENT ON COLUMN "wms_inven_inout"."inout_dtl_cd" IS '처리_유형_코드';

-- 처리_수량
COMMENT ON COLUMN "wms_inven_inout"."proc_qty" IS '처리수량';

-- 처리_자_ID
COMMENT ON COLUMN "wms_inven_inout"."proc_user_id" IS '처리자_아이디';

-- 센터_SEQ
COMMENT ON COLUMN "wms_inven_inout"."center_seq" IS '센터_SEQ';

-- FR_창고_SEQ
COMMENT ON COLUMN "wms_inven_inout"."fr_wh_seq" IS '창고(FR)';

-- FR_위치_SEQ
COMMENT ON COLUMN "wms_inven_inout"."fr_loc_seq" IS '위치(FR)';

-- FR_SKU1
COMMENT ON COLUMN "wms_inven_inout"."fr_sku1" IS 'SKU1(FR)';

-- FR_SKU2
COMMENT ON COLUMN "wms_inven_inout"."fr_sku2" IS 'SKU2(FR)';

-- TO_창고_SEQ
COMMENT ON COLUMN "wms_inven_inout"."to_wh_seq" IS '창고(TO)';

-- TO_위치_SEQ
COMMENT ON COLUMN "wms_inven_inout"."to_loc_seq" IS '위치(TO)';

-- TO_SKU1
COMMENT ON COLUMN "wms_inven_inout"."to_sku1" IS 'SKU1(TO)';

-- TO_SKU2
COMMENT ON COLUMN "wms_inven_inout"."to_sku2" IS 'SKU2(TO)';

-- FR_LOT_번호
COMMENT ON COLUMN "wms_inven_inout"."fr_lot_no" IS 'FR_LOT_번호';

-- FR_입고/제조일자
COMMENT ON COLUMN "wms_inven_inout"."fr_mng_ymd" IS 'FR_입고/제조일자';

-- FR_유통기한
COMMENT ON COLUMN "wms_inven_inout"."fr_exp_ymd" IS 'FR_유통기한';

-- TO_LOT_번호
COMMENT ON COLUMN "wms_inven_inout"."to_lot_no" IS 'TO_LOT_번호';

-- TO_입고/제조일자
COMMENT ON COLUMN "wms_inven_inout"."to_mng_ymd" IS 'TO_입고/제조일자';

-- TO_유통기한
COMMENT ON COLUMN "wms_inven_inout"."to_exp_ymd" IS 'TO_유통기한';

-- 처리_묶음_번호
COMMENT ON COLUMN "wms_inven_inout"."proc_bundle_no" IS '문서번호';

-- 요청_SEQ
COMMENT ON COLUMN "wms_inven_inout"."req_seq" IS '관련번호';

-- 업무_번호
COMMENT ON COLUMN "wms_inven_inout"."req_no" IS '관련번호';

-- 처리_상태_코드
COMMENT ON COLUMN "wms_inven_inout"."proc_sts_cd" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "wms_inven_inout"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_inven_inout"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_inven_inout"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_inven_inout"."mod_dt" IS '수정일';

-- WMS_재고_수불_PK
CREATE UNIQUE INDEX "wms_inven_inout_PK"
	ON "wms_inven_inout"
	( -- WMS_재고_수불
		"inven_inout_seq" ASC -- 재고_수불_SEQ
	)
;
-- WMS_재고_수불
ALTER TABLE "wms_inven_inout"
	ADD CONSTRAINT "wms_inven_inout_PK"
		 -- WMS_재고_수불_PK
	PRIMARY KEY 
	USING INDEX "wms_inven_inout_PK";

-- WMS_재고_수불_PK
COMMENT ON CONSTRAINT "wms_inven_inout_PK" ON "wms_inven_inout" IS 'WMS_재고_수불_PK';

-- WMS_재고_예약
CREATE TABLE "wms_inven_holding"
(
	"inven_holding_seq" bigint        NOT NULL DEFAULT nextval('wms_inven_holding_seq'), -- 이력_SEQ
	"biz_seq"           int4          NOT NULL, -- 사업장_SEQ
	"center_seq"        int4          NOT NULL, -- 센터_SEQ
	"prod_seq"          int4          NOT NULL, -- 품목_SEQ
	"mng_ymd"           varchar(8)    NULL,     -- 입고/제조일자
	"exp_ymd"           varchar(8)    NULL,     -- 유통기한
	"lot_no"            varchar(30)   NULL,     -- LOT_NO
	"sku1"              varchar(100)  NULL,     -- SKU1
	"req_qty"           decimal(10,2) NULL     DEFAULT 0, -- 요청_수량
	"proc_qty"          decimal(10,2) NOT NULL DEFAULT 0, -- 처리_수량
	"proc_ymd"          varchar(8)    NULL,     -- 처리_연월일
	"proc_hmsms"        varchar(9)    NULL,     -- 처리_시분초밀리초
	"proc_user_id"      varchar(20)   NULL,     -- 처리_자_ID
	"proc_yn"           char(1)       NOT NULL DEFAULT 'N', -- 처리_여부
	"inout_type_cd"     varchar(50)   NULL,     -- 수불_유형_코드
	"inout_dtl_cd"      varchar(50)   NULL,     -- 수불_상세_코드
	"req_seq"           int4          NULL,     -- 요청_SEQ
	"req_prod_seq"      bigint        NULL,     -- 요청_품목_SEQ
	"req_no"            varchar(30)   NULL      -- 업무_번호
);

-- WMS_재고_예약
COMMENT ON TABLE "wms_inven_holding" IS 'WMS_재고_예약';

-- 이력_SEQ
COMMENT ON COLUMN "wms_inven_holding"."inven_holding_seq" IS '이력_SEQ';

-- 사업장_SEQ
COMMENT ON COLUMN "wms_inven_holding"."biz_seq" IS '사업장_ID';

-- 센터_SEQ
COMMENT ON COLUMN "wms_inven_holding"."center_seq" IS '센터_SEQ';

-- 품목_SEQ
COMMENT ON COLUMN "wms_inven_holding"."prod_seq" IS '품목ID';

-- 입고/제조일자
COMMENT ON COLUMN "wms_inven_holding"."mng_ymd" IS '입고/제조일자';

-- 유통기한
COMMENT ON COLUMN "wms_inven_holding"."exp_ymd" IS '유통기한';

-- LOT_NO
COMMENT ON COLUMN "wms_inven_holding"."lot_no" IS 'LOT_NO';

-- SKU1
COMMENT ON COLUMN "wms_inven_holding"."sku1" IS 'SKU1';

-- 요청_수량
COMMENT ON COLUMN "wms_inven_holding"."req_qty" IS '요청_수량';

-- 처리_수량
COMMENT ON COLUMN "wms_inven_holding"."proc_qty" IS '처리수량';

-- 처리_연월일
COMMENT ON COLUMN "wms_inven_holding"."proc_ymd" IS '처리일자';

-- 처리_시분초밀리초
COMMENT ON COLUMN "wms_inven_holding"."proc_hmsms" IS '처리시분초밀리초';

-- 처리_자_ID
COMMENT ON COLUMN "wms_inven_holding"."proc_user_id" IS '처리자_아이디';

-- 처리_여부
COMMENT ON COLUMN "wms_inven_holding"."proc_yn" IS '처리_여부';

-- 수불_유형_코드
COMMENT ON COLUMN "wms_inven_holding"."inout_type_cd" IS '수불유형_코드';

-- 수불_상세_코드
COMMENT ON COLUMN "wms_inven_holding"."inout_dtl_cd" IS '수불_상세_코드';

-- 요청_SEQ
COMMENT ON COLUMN "wms_inven_holding"."req_seq" IS '관련번호';

-- 요청_품목_SEQ
COMMENT ON COLUMN "wms_inven_holding"."req_prod_seq" IS '요청_품목_SEQ';

-- 업무_번호
COMMENT ON COLUMN "wms_inven_holding"."req_no" IS '관련번호';

-- WMS_재고_예약_PK
CREATE UNIQUE INDEX "wms_inven_holding_PK"
	ON "wms_inven_holding"
	( -- WMS_재고_예약
		"inven_holding_seq" ASC -- 이력_SEQ
	)
;
-- WMS_재고_예약
ALTER TABLE "wms_inven_holding"
	ADD CONSTRAINT "wms_inven_holding_PK"
		 -- WMS_재고_예약_PK
	PRIMARY KEY 
	USING INDEX "wms_inven_holding_PK";

-- WMS_재고_예약_PK
COMMENT ON CONSTRAINT "wms_inven_holding_PK" ON "wms_inven_holding" IS 'WMS_재고_예약_PK';

-- WMS_재고_월마감
CREATE TABLE "wms_inven_month"
(
	"inven_month_seq" bigint        NOT NULL DEFAULT nextval('wms_inven_month_seq'), -- 재고마감_SEQ
	"biz_seq"         int4          NOT NULL, -- 사업장_SEQ
	"center_seq"      int4          NOT NULL DEFAULT nextval('mdm_center_seq'), -- 센터_SEQ
	"prod_seq"        int4          NOT NULL, -- 품목_SEQ
	"wh_seq"          int4          NOT NULL, -- 창고_SEQ
	"yyyymm"          varchar(6)    NOT NULL, -- 년월(마감)
	"inven_qty"       decimal(10,2) NOT NULL DEFAULT 0, -- 재고_수량
	"inwh_qty"        decimal(10,2) NOT NULL DEFAULT 0, -- 입고_수량
	"outbiz_qty"      decimal(10,2) NOT NULL DEFAULT 0, -- 출하_수량
	"return_qty"      decimal(10,2) NOT NULL DEFAULT 0, -- 반품_수량
	"etc_qty"         decimal(10,2) NOT NULL DEFAULT 0, -- 예외출고_수량
	"mng_ymd"         varchar(8)    NULL,     -- 입고/제조일자
	"exp_ymd"         varchar(8)    NULL,     -- 유통기한
	"lot_no"          varchar(30)   NULL,     -- LOT_번호
	"reg_id"          varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"          timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"          varchar(20)   NULL,     -- 수정_ID
	"mod_dt"          timestamp     NULL      -- 수정_일시
);

-- WMS_재고_월마감
COMMENT ON TABLE "wms_inven_month" IS 'WMS_재고_월마감';

-- 재고마감_SEQ
COMMENT ON COLUMN "wms_inven_month"."inven_month_seq" IS '재고마감_SEQ';

-- 사업장_SEQ
COMMENT ON COLUMN "wms_inven_month"."biz_seq" IS '사업장_ID';

-- 센터_SEQ
COMMENT ON COLUMN "wms_inven_month"."center_seq" IS '센터_SEQ';

-- 품목_SEQ
COMMENT ON COLUMN "wms_inven_month"."prod_seq" IS '품목ID';

-- 창고_SEQ
COMMENT ON COLUMN "wms_inven_month"."wh_seq" IS '창고_ID';

-- 년월(마감)
COMMENT ON COLUMN "wms_inven_month"."yyyymm" IS '마감_년월';

-- 재고_수량
COMMENT ON COLUMN "wms_inven_month"."inven_qty" IS '재고_수량';

-- 입고_수량
COMMENT ON COLUMN "wms_inven_month"."inwh_qty" IS '입고_수량';

-- 출하_수량
COMMENT ON COLUMN "wms_inven_month"."outbiz_qty" IS '출하_수량';

-- 반품_수량
COMMENT ON COLUMN "wms_inven_month"."return_qty" IS '반품_수량';

-- 예외출고_수량
COMMENT ON COLUMN "wms_inven_month"."etc_qty" IS '예외출고_수량';

-- 입고/제조일자
COMMENT ON COLUMN "wms_inven_month"."mng_ymd" IS '입고/제조일자';

-- 유통기한
COMMENT ON COLUMN "wms_inven_month"."exp_ymd" IS '유통기한';

-- LOT_번호
COMMENT ON COLUMN "wms_inven_month"."lot_no" IS 'LOT_번호';

-- 등록_ID
COMMENT ON COLUMN "wms_inven_month"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_inven_month"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_inven_month"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_inven_month"."mod_dt" IS '수정일';

-- WMS_재고_월마감_PK
CREATE UNIQUE INDEX "wms_inven_month_PK"
	ON "wms_inven_month"
	( -- WMS_재고_월마감
		"inven_month_seq" ASC -- 재고마감_SEQ
	)
;
-- WMS_재고_월마감
ALTER TABLE "wms_inven_month"
	ADD CONSTRAINT "wms_inven_month_PK"
		 -- WMS_재고_월마감_PK
	PRIMARY KEY 
	USING INDEX "wms_inven_month_PK";

-- WMS_재고_월마감_PK
COMMENT ON CONSTRAINT "wms_inven_month_PK" ON "wms_inven_month" IS 'WMS_재고_월마감_PK';

-- WMS_재고실사_대상
CREATE TABLE "wms_st_target"
(
	"st_target_seq" int4        NOT NULL DEFAULT nextval('wms_st_target_seq'), -- 재고실사_대상_SEQ
	"st_sch_seq"    int4        NOT NULL, -- 재고실사_SEQ
	"target_seq"    int4        NOT NULL, -- 대상_SEQ
	"del_yn"        char(1)     NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"        varchar(20) NOT NULL, -- 등록_ID
	"reg_dt"        timestamp   NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"        varchar(20) NULL,     -- 수정_ID
	"mod_dt"        timestamp   NULL      -- 수정_일시
);

-- WMS_재고실사_대상
COMMENT ON TABLE "wms_st_target" IS 'WMS_재고실사_대상';

-- 재고실사_대상_SEQ
COMMENT ON COLUMN "wms_st_target"."st_target_seq" IS '조사대상_ID';

-- 재고실사_SEQ
COMMENT ON COLUMN "wms_st_target"."st_sch_seq" IS '재고실사_SEQ';

-- 대상_SEQ
COMMENT ON COLUMN "wms_st_target"."target_seq" IS '대상_SEQ';

-- 삭제_여부
COMMENT ON COLUMN "wms_st_target"."del_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "wms_st_target"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_st_target"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_st_target"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_st_target"."mod_dt" IS '수정일';

-- WMS_재고실사_대상 인덱스
CREATE INDEX "IX_wms_st_target"
	ON "wms_st_target"	( -- WMS_재고실사_대상
		"st_sch_seq" ASC -- 재고실사_SEQ
	);

-- WMS_재고실사_대상 인덱스
COMMENT ON INDEX "IX_wms_st_target" IS 'WMS_재고실사_대상 인덱스';

-- WMS_재고실사_대상_PK
CREATE UNIQUE INDEX "wms_st_target_PK"
	ON "wms_st_target"
	( -- WMS_재고실사_대상
		"st_target_seq" ASC, -- 재고실사_대상_SEQ
		"st_sch_seq" ASC -- 재고실사_SEQ
	)
;
-- WMS_재고실사_대상
ALTER TABLE "wms_st_target"
	ADD CONSTRAINT "wms_st_target_PK"
		 -- WMS_재고실사_대상_PK
	PRIMARY KEY 
	USING INDEX "wms_st_target_PK";

-- WMS_재고실사_대상_PK
COMMENT ON CONSTRAINT "wms_st_target_PK" ON "wms_st_target" IS 'WMS_재고실사_대상_PK';

-- WMS_재고실사_일정
CREATE TABLE "wms_st_sch"
(
	"st_sch_seq"    int4          NOT NULL DEFAULT nextval('wms_st_sch_seq'), -- 재고실사_SEQ
	"yyyy"          varchar(4)    NOT NULL, -- 년도
	"biz_seq"       int4          NOT NULL, -- 사업장_SEQ
	"center_seq"    int4          NOT NULL, -- 센터_SEQ
	"st_idx"        int2          NOT NULL DEFAULT 0, -- 재고실사_차수
	"st_target_cd"  varchar(50)   NOT NULL, -- 재고실사_대상_코드
	"st_sch_sts_cd" varchar(50)   NOT NULL, -- 재고실사_상태_코드
	"st_exp_ymd"    varchar(8)    NULL,     -- 재고실사_예정_연월일
	"st_end_ymd"    varchar(8)    NULL,     -- 재고실사_종료_연월일
	"inven_fix_ymd" varchar(8)    NULL,     -- 재고_고정_연월일
	"inven_fix_hms" varchar(6)    NULL,     -- 재고_고정_시분초
	"note"          varchar(1000) NULL,     -- 비고
	"del_yn"        char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"        varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"        timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"        varchar(20)   NULL,     -- 수정_ID
	"mod_dt"        timestamp     NULL      -- 수정_일시
);

-- WMS_재고실사_일정
COMMENT ON TABLE "wms_st_sch" IS 'WMS_재고실사_일정';

-- 재고실사_SEQ
COMMENT ON COLUMN "wms_st_sch"."st_sch_seq" IS '예외적요청번호';

-- 년도
COMMENT ON COLUMN "wms_st_sch"."yyyy" IS '해당년도';

-- 사업장_SEQ
COMMENT ON COLUMN "wms_st_sch"."biz_seq" IS '사업장_ID';

-- 센터_SEQ
COMMENT ON COLUMN "wms_st_sch"."center_seq" IS '센터_SEQ';

-- 재고실사_차수
COMMENT ON COLUMN "wms_st_sch"."st_idx" IS '재고실사_차수';

-- 재고실사_대상_코드
COMMENT ON COLUMN "wms_st_sch"."st_target_cd" IS '재고실사_대상_코드';

-- 재고실사_상태_코드
COMMENT ON COLUMN "wms_st_sch"."st_sch_sts_cd" IS '재고실사_상태_코드';

-- 재고실사_예정_연월일
COMMENT ON COLUMN "wms_st_sch"."st_exp_ymd" IS '재고실사_예정_일자';

-- 재고실사_종료_연월일
COMMENT ON COLUMN "wms_st_sch"."st_end_ymd" IS '재고실사_종료_일자';

-- 재고_고정_연월일
COMMENT ON COLUMN "wms_st_sch"."inven_fix_ymd" IS '재고_고정_일자';

-- 재고_고정_시분초
COMMENT ON COLUMN "wms_st_sch"."inven_fix_hms" IS '재고_고정_시간';

-- 비고
COMMENT ON COLUMN "wms_st_sch"."note" IS '비고';

-- 삭제_여부
COMMENT ON COLUMN "wms_st_sch"."del_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "wms_st_sch"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_st_sch"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_st_sch"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_st_sch"."mod_dt" IS '수정일';

-- WMS_재고실사_일정 유니크 인덱스
CREATE UNIQUE INDEX "UIX_wms_st_sch"
	ON "wms_st_sch"
	( -- WMS_재고실사_일정
		"yyyy" ASC, -- 년도
		"biz_seq" ASC, -- 사업장_SEQ
		"center_seq" ASC, -- 센터_SEQ
		"st_idx" ASC -- 재고실사_차수
	);

-- WMS_재고실사_일정 유니크 인덱스
COMMENT ON INDEX "UIX_wms_st_sch" IS 'WMS_재고실사_일정 유니크 인덱스';

-- WMS_재고실사_일정_PK
CREATE UNIQUE INDEX "wms_st_sch_PK"
	ON "wms_st_sch"
	( -- WMS_재고실사_일정
		"st_sch_seq" ASC -- 재고실사_SEQ
	)
;
-- WMS_재고실사_일정
ALTER TABLE "wms_st_sch"
	ADD CONSTRAINT "wms_st_sch_PK"
		 -- WMS_재고실사_일정_PK
	PRIMARY KEY 
	USING INDEX "wms_st_sch_PK";

-- WMS_재고실사_일정_PK
COMMENT ON CONSTRAINT "wms_st_sch_PK" ON "wms_st_sch" IS 'WMS_재고실사_일정_PK';

-- WMS_재고실사_일정
ALTER TABLE "wms_st_sch"
	ADD CONSTRAINT "UK_wms_st_sch" -- WMS_재고실사_일정 유니크 제약
	UNIQUE 
	USING INDEX "UIX_wms_st_sch";

-- WMS_재고실사_일정 유니크 제약
COMMENT ON CONSTRAINT "UK_wms_st_sch" ON "wms_st_sch" IS 'WMS_재고실사_일정 유니크 제약';

-- WMS_재고실사_재고
CREATE TABLE "wms_st_inven"
(
	"st_inven_seq" bigint        NOT NULL DEFAULT nextval('wms_st_inven_seq'), -- 재고실사_재고_SEQ
	"st_sch_seq"   int4          NOT NULL, -- 재고실사_SEQ
	"prod_seq"     int4          NOT NULL, -- 품목_SEQ
	"sku1"         varchar(100)  NOT NULL, -- SKU1
	"sku2"         varchar(100)  NOT NULL, -- SKU2
	"wh_seq"       int4          NOT NULL, -- 창고_SEQ
	"loc_seq"      bigint        NOT NULL, -- 위치_SEQ
	"inven_qty"    decimal(10,2) NOT NULL DEFAULT 0, -- 재고_수량
	"cfm_yn"       char(1)       NOT NULL DEFAULT 'N', -- 확정_여부
	"del_yn"       char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"       varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"       timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"       varchar(20)   NULL,     -- 수정_ID
	"mod_dt"       timestamp     NULL      -- 수정_일시
);

-- WMS_재고실사_재고
COMMENT ON TABLE "wms_st_inven" IS 'WMS_재고실사_재고';

-- 재고실사_재고_SEQ
COMMENT ON COLUMN "wms_st_inven"."st_inven_seq" IS '재고실사_재고_SEQ';

-- 재고실사_SEQ
COMMENT ON COLUMN "wms_st_inven"."st_sch_seq" IS '재고실사_SEQ';

-- 품목_SEQ
COMMENT ON COLUMN "wms_st_inven"."prod_seq" IS '품목ID';

-- SKU1
COMMENT ON COLUMN "wms_st_inven"."sku1" IS 'SKU1';

-- SKU2
COMMENT ON COLUMN "wms_st_inven"."sku2" IS 'SKU2';

-- 창고_SEQ
COMMENT ON COLUMN "wms_st_inven"."wh_seq" IS '창고_ID';

-- 위치_SEQ
COMMENT ON COLUMN "wms_st_inven"."loc_seq" IS '위치_ID';

-- 재고_수량
COMMENT ON COLUMN "wms_st_inven"."inven_qty" IS '재고_수량';

-- 확정_여부
COMMENT ON COLUMN "wms_st_inven"."cfm_yn" IS '확정_여부';

-- 삭제_여부
COMMENT ON COLUMN "wms_st_inven"."del_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "wms_st_inven"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_st_inven"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_st_inven"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_st_inven"."mod_dt" IS '수정일';

-- WMS_재고실사_재고_PK
CREATE UNIQUE INDEX "wms_st_inven_PK"
	ON "wms_st_inven"
	( -- WMS_재고실사_재고
		"st_inven_seq" ASC, -- 재고실사_재고_SEQ
		"st_sch_seq" ASC -- 재고실사_SEQ
	)
;
-- WMS_재고실사_재고
ALTER TABLE "wms_st_inven"
	ADD CONSTRAINT "wms_st_inven_PK"
		 -- WMS_재고실사_재고_PK
	PRIMARY KEY 
	USING INDEX "wms_st_inven_PK";

-- WMS_재고실사_재고_PK
COMMENT ON CONSTRAINT "wms_st_inven_PK" ON "wms_st_inven" IS 'WMS_재고실사_재고_PK';

-- WMS_재고실사_처리
CREATE TABLE "wms_st_tran"
(
	"st_tran_seq" bigint        NOT NULL DEFAULT nextval('wms_st_tran_seq'), -- 재고실사_처리_SEQ
	"st_sch_seq"  int4          NOT NULL, -- 재고실사_SEQ
	"prod_seq"    int4          NOT NULL, -- 품목_SEQ
	"sku1"        varchar(100)  NOT NULL, -- SKU1
	"sku2"        varchar(100)  NOT NULL, -- SKU2
	"wh_seq"      int4          NOT NULL, -- 창고_SEQ
	"loc_seq"     bigint        NOT NULL, -- 위치_SEQ
	"st_qty"      decimal(10,2) NOT NULL DEFAULT 0, -- 재고실사_수량
	"st_ymd"      varchar(8)    NOT NULL, -- 재고실사_연월일
	"st_hms"      varchar(6)    NOT NULL, -- 재고실사_시분초
	"st_user_id"  varchar(20)   NOT NULL, -- 재고_실사자_ID
	"del_yn"      char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"      varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"      timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"      varchar(20)   NULL,     -- 수정_ID
	"mod_dt"      timestamp     NULL      -- 수정_일시
);

-- WMS_재고실사_처리
COMMENT ON TABLE "wms_st_tran" IS 'WMS_재고실사_처리';

-- 재고실사_처리_SEQ
COMMENT ON COLUMN "wms_st_tran"."st_tran_seq" IS '재고실사_처리_SEQ';

-- 재고실사_SEQ
COMMENT ON COLUMN "wms_st_tran"."st_sch_seq" IS '재고실사_SEQ';

-- 품목_SEQ
COMMENT ON COLUMN "wms_st_tran"."prod_seq" IS '품목ID';

-- SKU1
COMMENT ON COLUMN "wms_st_tran"."sku1" IS 'SKU1';

-- SKU2
COMMENT ON COLUMN "wms_st_tran"."sku2" IS 'SKU2';

-- 창고_SEQ
COMMENT ON COLUMN "wms_st_tran"."wh_seq" IS '창고_ID';

-- 위치_SEQ
COMMENT ON COLUMN "wms_st_tran"."loc_seq" IS '위치_ID';

-- 재고실사_수량
COMMENT ON COLUMN "wms_st_tran"."st_qty" IS '재고실사_수량';

-- 재고실사_연월일
COMMENT ON COLUMN "wms_st_tran"."st_ymd" IS '재고실사_일자';

-- 재고실사_시분초
COMMENT ON COLUMN "wms_st_tran"."st_hms" IS '재고실사_시간';

-- 재고_실사자_ID
COMMENT ON COLUMN "wms_st_tran"."st_user_id" IS '재고실사자_아이디';

-- 삭제_여부
COMMENT ON COLUMN "wms_st_tran"."del_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "wms_st_tran"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_st_tran"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_st_tran"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_st_tran"."mod_dt" IS '수정일';

-- WMS_재고실사_처리_PK
CREATE UNIQUE INDEX "wms_st_tran_PK"
	ON "wms_st_tran"
	( -- WMS_재고실사_처리
		"st_tran_seq" ASC, -- 재고실사_처리_SEQ
		"st_sch_seq" ASC -- 재고실사_SEQ
	)
;
-- WMS_재고실사_처리
ALTER TABLE "wms_st_tran"
	ADD CONSTRAINT "wms_st_tran_PK"
		 -- WMS_재고실사_처리_PK
	PRIMARY KEY 
	USING INDEX "wms_st_tran_PK";

-- WMS_재고실사_처리_PK
COMMENT ON CONSTRAINT "wms_st_tran_PK" ON "wms_st_tran" IS 'WMS_재고실사_처리_PK';

-- WMS_재고이동
CREATE TABLE "wms_inven_mv"
(
	"mv_seq"      int4          NOT NULL DEFAULT nextval('wms_inven_mv_seq'), -- 재고이동_SEQ
	"biz_seq"     int4          NOT NULL, -- 사업장_SEQ
	"mv_no"       varchar(30)   NOT NULL, -- 재고이동_번호
	"center_seq"  int4          NOT NULL, -- 센터_SEQ
	"mv_type_cd"  varchar(50)   NOT NULL, -- 재고이동_유형_코드
	"mv_sts_cd"   varchar(50)   NOT NULL, -- 재고이동_상태_코드
	"req_ymd"     varchar(8)    NOT NULL, -- 예정_연월일(재고이동)
	"req_hms"     varchar(6)    NULL,     -- 예정_시분초(재고이동)
	"req_user_nm" varchar(100)  NULL,     -- 요청_사용자_명(재고이동)
	"req_dept_nm" varchar(100)  NULL,     -- 요청_부서_명
	"to_wh_seq"   int4          NULL,     -- 이동창고(TO)
	"fr_wh_seq"   int4          NULL,     -- 이동창고(FR)
	"req_no"      varchar(30)   NULL,     -- 문서_번호(타시스템)
	"note"        varchar(1000) NULL,     -- 비고
	"if_key"      varchar(50)   NULL,     -- IF_KEY
	"if_err_seq"  int4          NULL,     -- IF_에러_일련번호
	"if_send_yn"  char(1)       NOT NULL DEFAULT 'N', -- IF_송신_여부
	"del_yn"      char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"      varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"      timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"      varchar(20)   NULL,     -- 수정_ID
	"mod_dt"      timestamp     NULL      -- 수정_일시
);

-- WMS_재고이동
COMMENT ON TABLE "wms_inven_mv" IS 'WMS_재고이동';

-- 재고이동_SEQ
COMMENT ON COLUMN "wms_inven_mv"."mv_seq" IS '재고이동요청번호';

-- 사업장_SEQ
COMMENT ON COLUMN "wms_inven_mv"."biz_seq" IS '사업장_ID';

-- 재고이동_번호
COMMENT ON COLUMN "wms_inven_mv"."mv_no" IS '재고이동요청번호';

-- 센터_SEQ
COMMENT ON COLUMN "wms_inven_mv"."center_seq" IS '센터_SEQ';

-- 재고이동_유형_코드
COMMENT ON COLUMN "wms_inven_mv"."mv_type_cd" IS '재고_이동_유형_코드';

-- 재고이동_상태_코드
COMMENT ON COLUMN "wms_inven_mv"."mv_sts_cd" IS '처리_상태_코드';

-- 예정_연월일(재고이동)
COMMENT ON COLUMN "wms_inven_mv"."req_ymd" IS '입고_요청_일자';

-- 예정_시분초(재고이동)
COMMENT ON COLUMN "wms_inven_mv"."req_hms" IS '입고_요청_시간';

-- 요청_사용자_명(재고이동)
COMMENT ON COLUMN "wms_inven_mv"."req_user_nm" IS '입고_요청자_아이디';

-- 요청_부서_명
COMMENT ON COLUMN "wms_inven_mv"."req_dept_nm" IS '요청_부서_명';

-- 이동창고(TO)
COMMENT ON COLUMN "wms_inven_mv"."to_wh_seq" IS '이동창고(TO)';

-- 이동창고(FR)
COMMENT ON COLUMN "wms_inven_mv"."fr_wh_seq" IS '이동창고(FR)';

-- 문서_번호(타시스템)
COMMENT ON COLUMN "wms_inven_mv"."req_no" IS '증빙번호';

-- 비고
COMMENT ON COLUMN "wms_inven_mv"."note" IS '비고';

-- IF_KEY
COMMENT ON COLUMN "wms_inven_mv"."if_key" IS '발주내부_코드(ERP)';

-- IF_에러_일련번호
COMMENT ON COLUMN "wms_inven_mv"."if_err_seq" IS 'IF_에러_일련번호';

-- IF_송신_여부
COMMENT ON COLUMN "wms_inven_mv"."if_send_yn" IS 'ERP_송신_여부';

-- 삭제_여부
COMMENT ON COLUMN "wms_inven_mv"."del_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "wms_inven_mv"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_inven_mv"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_inven_mv"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_inven_mv"."mod_dt" IS '수정일';

-- WMS_MV_IDX01
CREATE UNIQUE INDEX "UIX_wms_inven_mv"
	ON "wms_inven_mv"
	( -- WMS_재고이동
		"biz_seq" ASC, -- 사업장_SEQ
		"mv_no" ASC -- 재고이동_번호
	);

-- WMS_MV_IDX01
COMMENT ON INDEX "UIX_wms_inven_mv" IS 'WMS_MV_IDX01';

-- WMS_MV_IDX02
CREATE INDEX "IX_wms_inven_mv"
	ON "wms_inven_mv"	( -- WMS_재고이동
		"biz_seq" ASC, -- 사업장_SEQ
		"center_seq" ASC, -- 센터_SEQ
		"req_ymd" ASC -- 예정_연월일(재고이동)
	);

-- WMS_MV_IDX02
COMMENT ON INDEX "IX_wms_inven_mv" IS 'WMS_MV_IDX02';

-- WMS_재고이동_PK
CREATE UNIQUE INDEX "wms_inven_mv_PK"
	ON "wms_inven_mv"
	( -- WMS_재고이동
		"mv_seq" ASC -- 재고이동_SEQ
	)
;
-- WMS_재고이동
ALTER TABLE "wms_inven_mv"
	ADD CONSTRAINT "wms_inven_mv_PK"
		 -- WMS_재고이동_PK
	PRIMARY KEY 
	USING INDEX "wms_inven_mv_PK";

-- WMS_재고이동_PK
COMMENT ON CONSTRAINT "wms_inven_mv_PK" ON "wms_inven_mv" IS 'WMS_재고이동_PK';

-- WMS_재고이동
ALTER TABLE "wms_inven_mv"
	ADD CONSTRAINT "UK_wms_inven_mv" -- WMS_재고이동 유니크 제약
	UNIQUE 
	USING INDEX "UIX_wms_inven_mv";

-- WMS_재고이동 유니크 제약
COMMENT ON CONSTRAINT "UK_wms_inven_mv" ON "wms_inven_mv" IS 'WMS_재고이동 유니크 제약';

-- WMS_재고이동_처리
CREATE TABLE "wms_inven_mv_tran"
(
	"mv_tran_seq"    bigint        NOT NULL DEFAULT nextval('wms_inven_mv_tran_seq'), -- 재고이동_처리_SEQ
	"mv_prod_seq"    bigint        NOT NULL, -- 재고이동_품목_SEQ
	"mv_seq"         int4          NOT NULL, -- 재고이동_SEQ
	"prod_seq"       int4          NOT NULL, -- 품목_SEQ
	"fr_wh_seq"      int4          NOT NULL, -- FR_창고_SEQ
	"fr_loc_seq"     bigint        NOT NULL, -- FR_위치_SEQ
	"fr_sku1"        varchar(100)  NOT NULL, -- FR_SKU1
	"fr_sku2"        varchar(100)  NOT NULL, -- FR_SKU2
	"proc_qty"       decimal(10,2) NOT NULL DEFAULT 0, -- 처리_수량(재고이동)
	"ex_qty"         decimal(10,2) NOT NULL DEFAULT 0, -- 기처리_수량(재고이동)
	"to_wh_seq"      int4          NOT NULL, -- TO_창고_SEQ
	"to_loc_seq"     bigint        NOT NULL, -- TO_위치_SEQ
	"to_sku2"        varchar(100)  NULL,     -- TO_SKU2
	"mng_ymd"        varchar(8)    NULL,     -- 제조/입고일자
	"exp_ymd"        varchar(8)    NULL,     -- 유통기한
	"lot_no"         varchar(30)   NULL,     -- LOT_번호
	"proc_bundle_no" varchar(30)   NULL,     -- 처리_묶음_번호
	"proc_ymd"       varchar(8)    NULL,     -- 처리_연월일(재고이동)
	"proc_hms"       varchar(6)    NULL,     -- 처리_시분초(재고이동)
	"proc_user_id"   varchar(20)   NULL,     -- 처리_자_ID(재고이동)
	"if_err_seq"     int4          NULL,     -- IF_에러_일련번호
	"if_send_yn"     char(1)       NOT NULL DEFAULT 'N', -- IF_송신_여부
	"del_yn"         char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"         varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"         timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"         varchar(20)   NULL,     -- 수정_ID
	"mod_dt"         timestamp     NULL      -- 수정_일시
);

-- WMS_재고이동_처리
COMMENT ON TABLE "wms_inven_mv_tran" IS 'WMS_재고이동_처리';

-- 재고이동_처리_SEQ
COMMENT ON COLUMN "wms_inven_mv_tran"."mv_tran_seq" IS '재고이동_처리_SEQ';

-- 재고이동_품목_SEQ
COMMENT ON COLUMN "wms_inven_mv_tran"."mv_prod_seq" IS '재고이동_품목_SEQ';

-- 재고이동_SEQ
COMMENT ON COLUMN "wms_inven_mv_tran"."mv_seq" IS '재고이동_SEQ';

-- 품목_SEQ
COMMENT ON COLUMN "wms_inven_mv_tran"."prod_seq" IS '품목ID';

-- FR_창고_SEQ
COMMENT ON COLUMN "wms_inven_mv_tran"."fr_wh_seq" IS '창고(FR)';

-- FR_위치_SEQ
COMMENT ON COLUMN "wms_inven_mv_tran"."fr_loc_seq" IS '위치(FR)';

-- FR_SKU1
COMMENT ON COLUMN "wms_inven_mv_tran"."fr_sku1" IS 'SKU1(FR)';

-- FR_SKU2
COMMENT ON COLUMN "wms_inven_mv_tran"."fr_sku2" IS 'SKU2(FR)';

-- 처리_수량(재고이동)
COMMENT ON COLUMN "wms_inven_mv_tran"."proc_qty" IS '요청수량';

-- 기처리_수량(재고이동)
COMMENT ON COLUMN "wms_inven_mv_tran"."ex_qty" IS '기_출하_수량';

-- TO_창고_SEQ
COMMENT ON COLUMN "wms_inven_mv_tran"."to_wh_seq" IS '창고(TO)';

-- TO_위치_SEQ
COMMENT ON COLUMN "wms_inven_mv_tran"."to_loc_seq" IS '위치(TO)';

-- TO_SKU2
COMMENT ON COLUMN "wms_inven_mv_tran"."to_sku2" IS 'SKU2(TO)';

-- 제조/입고일자
COMMENT ON COLUMN "wms_inven_mv_tran"."mng_ymd" IS '제조/입고일자';

-- 유통기한
COMMENT ON COLUMN "wms_inven_mv_tran"."exp_ymd" IS '유통기한';

-- LOT_번호
COMMENT ON COLUMN "wms_inven_mv_tran"."lot_no" IS 'LOT_번호';

-- 처리_묶음_번호
COMMENT ON COLUMN "wms_inven_mv_tran"."proc_bundle_no" IS '문서번호';

-- 처리_연월일(재고이동)
COMMENT ON COLUMN "wms_inven_mv_tran"."proc_ymd" IS '입고_일자';

-- 처리_시분초(재고이동)
COMMENT ON COLUMN "wms_inven_mv_tran"."proc_hms" IS '입고_시간';

-- 처리_자_ID(재고이동)
COMMENT ON COLUMN "wms_inven_mv_tran"."proc_user_id" IS '입고_작업자_아이디';

-- IF_에러_일련번호
COMMENT ON COLUMN "wms_inven_mv_tran"."if_err_seq" IS 'IF_에러_일련번호';

-- IF_송신_여부
COMMENT ON COLUMN "wms_inven_mv_tran"."if_send_yn" IS 'ERP_송신_여부';

-- 삭제_여부
COMMENT ON COLUMN "wms_inven_mv_tran"."del_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "wms_inven_mv_tran"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_inven_mv_tran"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_inven_mv_tran"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_inven_mv_tran"."mod_dt" IS '수정일';

-- WMS_재고이동_처리_PK
CREATE UNIQUE INDEX "wms_inven_mv_tran_PK"
	ON "wms_inven_mv_tran"
	( -- WMS_재고이동_처리
		"mv_tran_seq" ASC, -- 재고이동_처리_SEQ
		"mv_prod_seq" ASC, -- 재고이동_품목_SEQ
		"mv_seq" ASC -- 재고이동_SEQ
	)
;
-- WMS_재고이동_처리
ALTER TABLE "wms_inven_mv_tran"
	ADD CONSTRAINT "wms_inven_mv_tran_PK"
		 -- WMS_재고이동_처리_PK
	PRIMARY KEY 
	USING INDEX "wms_inven_mv_tran_PK";

-- WMS_재고이동_처리_PK
COMMENT ON CONSTRAINT "wms_inven_mv_tran_PK" ON "wms_inven_mv_tran" IS 'WMS_재고이동_처리_PK';

-- WMS_재고이동_품목
CREATE TABLE "wms_inven_mv_prod"
(
	"mv_prod_seq"    bigint        NOT NULL DEFAULT nextval('wms_inven_mv_prod_seq'), -- 재고이동_품목_SEQ
	"mv_seq"         int4          NOT NULL, -- 재고이동_SEQ
	"prod_seq"       int4          NOT NULL, -- 품목_SEQ
	"mv_prod_sts_cd" varchar(50)   NOT NULL, -- 재고이동_품목_상태_코드
	"req_qty"        decimal(10,2) NOT NULL DEFAULT 0, -- 요청_수량(재고이동)
	"ex_qty"         decimal(10,2) NOT NULL DEFAULT 0, -- 기처리_수량(재고이동)
	"est_mng_ymd"    varchar(8)    NULL,     -- 예상_입고/제조일자
	"est_exp_ymd"    varchar(8)    NULL,     -- 예상_유통기한
	"est_lot_no"     varchar(30)   NULL,     -- 예상_LOT_NO
	"est_cn"         varchar(1000) NULL,     -- 예상_CN
	"if_send_yn"     char(1)       NOT NULL DEFAULT 'N', -- IF_송신_여부
	"if_idx"         varchar(20)   NULL,     -- IF_내부순번
	"if_err_seq"     int4          NULL,     -- IF_에러_일련번호
	"del_yn"         char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"         varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"         timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"         varchar(20)   NULL,     -- 수정_ID
	"mod_dt"         timestamp     NULL      -- 수정_일시
);

-- WMS_재고이동_품목
COMMENT ON TABLE "wms_inven_mv_prod" IS 'WMS_재고이동_품목';

-- 재고이동_품목_SEQ
COMMENT ON COLUMN "wms_inven_mv_prod"."mv_prod_seq" IS '재고이동_품목_SEQ';

-- 재고이동_SEQ
COMMENT ON COLUMN "wms_inven_mv_prod"."mv_seq" IS '재고이동_SEQ';

-- 품목_SEQ
COMMENT ON COLUMN "wms_inven_mv_prod"."prod_seq" IS '품목ID';

-- 재고이동_품목_상태_코드
COMMENT ON COLUMN "wms_inven_mv_prod"."mv_prod_sts_cd" IS '처리_상태_코드';

-- 요청_수량(재고이동)
COMMENT ON COLUMN "wms_inven_mv_prod"."req_qty" IS '예외출고_요청_수량';

-- 기처리_수량(재고이동)
COMMENT ON COLUMN "wms_inven_mv_prod"."ex_qty" IS '기_출하_수량';

-- 예상_입고/제조일자
COMMENT ON COLUMN "wms_inven_mv_prod"."est_mng_ymd" IS '예상_입고/제조일자';

-- 예상_유통기한
COMMENT ON COLUMN "wms_inven_mv_prod"."est_exp_ymd" IS '예상_유통기한';

-- 예상_LOT_NO
COMMENT ON COLUMN "wms_inven_mv_prod"."est_lot_no" IS '예상_LOT_NO';

-- 예상_CN
COMMENT ON COLUMN "wms_inven_mv_prod"."est_cn" IS '예상_CN';

-- IF_송신_여부
COMMENT ON COLUMN "wms_inven_mv_prod"."if_send_yn" IS 'ERP_송신_여부';

-- IF_내부순번
COMMENT ON COLUMN "wms_inven_mv_prod"."if_idx" IS '순번 --';

-- IF_에러_일련번호
COMMENT ON COLUMN "wms_inven_mv_prod"."if_err_seq" IS 'IF_에러_일련번호';

-- 삭제_여부
COMMENT ON COLUMN "wms_inven_mv_prod"."del_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "wms_inven_mv_prod"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_inven_mv_prod"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_inven_mv_prod"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_inven_mv_prod"."mod_dt" IS '수정일';

-- WMS_재고이동_품목_PK
CREATE UNIQUE INDEX "wms_inven_mv_prod_PK"
	ON "wms_inven_mv_prod"
	( -- WMS_재고이동_품목
		"mv_prod_seq" ASC, -- 재고이동_품목_SEQ
		"mv_seq" ASC -- 재고이동_SEQ
	)
;
-- WMS_재고이동_품목
ALTER TABLE "wms_inven_mv_prod"
	ADD CONSTRAINT "wms_inven_mv_prod_PK"
		 -- WMS_재고이동_품목_PK
	PRIMARY KEY 
	USING INDEX "wms_inven_mv_prod_PK";

-- WMS_재고이동_품목_PK
COMMENT ON CONSTRAINT "wms_inven_mv_prod_PK" ON "wms_inven_mv_prod" IS 'WMS_재고이동_품목_PK';

-- WMS_재고조정
CREATE TABLE "wms_inven_ad"
(
	"ad_seq"      int4          NOT NULL DEFAULT nextval('wms_inven_ad_seq'), -- 재고조정_SEQ
	"biz_seq"     int4          NOT NULL, -- 사업장_SEQ
	"ad_no"       varchar(30)   NOT NULL, -- 재고조정_번호
	"center_seq"  int4          NOT NULL, -- 센터_SEQ
	"ad_type_cd"  varchar(50)   NOT NULL, -- 재고조정_유형_코드
	"ad_sts_cd"   varchar(50)   NOT NULL, -- 재고조정_상태_코드
	"req_ymd"     varchar(8)    NOT NULL, -- 예정_연월일(재고조정)
	"req_hms"     varchar(6)    NULL,     -- 예정_시분초(재고조정)
	"req_user_nm" varchar(100)  NULL,     -- 요청_사용자_명(재고조정)
	"req_dept_nm" varchar(100)  NULL,     -- 요청_부서_명
	"req_no"      varchar(30)   NULL,     -- 문서_번호(타시스템)
	"st_seq"      int4          NULL,     -- 재고실사_SEQ
	"note"        varchar(1000) NULL,     -- 비고
	"if_send_yn"  char(1)       NOT NULL DEFAULT 'N', -- IF_송신_여부
	"if_key"      varchar(50)   NULL,     -- IF_KEY
	"if_err_seq"  int4          NULL,     -- IF_에러_일련번호
	"del_yn"      char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"      varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"      timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"      varchar(20)   NULL,     -- 수정_ID
	"mod_dt"      timestamp     NULL      -- 수정_일시
);

-- WMS_재고조정
COMMENT ON TABLE "wms_inven_ad" IS 'WMS_재고조정';

-- 재고조정_SEQ
COMMENT ON COLUMN "wms_inven_ad"."ad_seq" IS '재고조정_요청번호';

-- 사업장_SEQ
COMMENT ON COLUMN "wms_inven_ad"."biz_seq" IS '사업장_ID';

-- 재고조정_번호
COMMENT ON COLUMN "wms_inven_ad"."ad_no" IS '재고조정_요청번호';

-- 센터_SEQ
COMMENT ON COLUMN "wms_inven_ad"."center_seq" IS '센터_SEQ';

-- 재고조정_유형_코드
COMMENT ON COLUMN "wms_inven_ad"."ad_type_cd" IS '처리_형태_코드';

-- 재고조정_상태_코드
COMMENT ON COLUMN "wms_inven_ad"."ad_sts_cd" IS '처리_상태_코드';

-- 예정_연월일(재고조정)
COMMENT ON COLUMN "wms_inven_ad"."req_ymd" IS '입고_요청_일자';

-- 예정_시분초(재고조정)
COMMENT ON COLUMN "wms_inven_ad"."req_hms" IS '입고_요청_시간';

-- 요청_사용자_명(재고조정)
COMMENT ON COLUMN "wms_inven_ad"."req_user_nm" IS '입고_요청자_아이디';

-- 요청_부서_명
COMMENT ON COLUMN "wms_inven_ad"."req_dept_nm" IS '요청_부서_명';

-- 문서_번호(타시스템)
COMMENT ON COLUMN "wms_inven_ad"."req_no" IS '증빙번호';

-- 재고실사_SEQ
COMMENT ON COLUMN "wms_inven_ad"."st_seq" IS '재고실사_SEQ';

-- 비고
COMMENT ON COLUMN "wms_inven_ad"."note" IS '비고';

-- IF_송신_여부
COMMENT ON COLUMN "wms_inven_ad"."if_send_yn" IS 'ERP_송신_여부';

-- IF_KEY
COMMENT ON COLUMN "wms_inven_ad"."if_key" IS '발주내부_코드(ERP)';

-- IF_에러_일련번호
COMMENT ON COLUMN "wms_inven_ad"."if_err_seq" IS 'IF_에러_일련번호';

-- 삭제_여부
COMMENT ON COLUMN "wms_inven_ad"."del_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "wms_inven_ad"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_inven_ad"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_inven_ad"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_inven_ad"."mod_dt" IS '수정일';

-- WMS_AD_IDX01
CREATE UNIQUE INDEX "UIX_wms_inven_ad"
	ON "wms_inven_ad"
	( -- WMS_재고조정
		"biz_seq" ASC, -- 사업장_SEQ
		"ad_no" ASC -- 재고조정_번호
	);

-- WMS_AD_IDX01
COMMENT ON INDEX "UIX_wms_inven_ad" IS 'WMS_AD_IDX01';

-- WMS_AD_IDX02
CREATE INDEX "IX_wms_inven_ad"
	ON "wms_inven_ad"	( -- WMS_재고조정
		"biz_seq" ASC, -- 사업장_SEQ
		"center_seq" ASC, -- 센터_SEQ
		"req_ymd" ASC -- 예정_연월일(재고조정)
	);

-- WMS_AD_IDX02
COMMENT ON INDEX "IX_wms_inven_ad" IS 'WMS_AD_IDX02';

-- WMS_재고조정_PK
CREATE UNIQUE INDEX "wms_inven_ad_PK"
	ON "wms_inven_ad"
	( -- WMS_재고조정
		"ad_seq" ASC -- 재고조정_SEQ
	)
;
-- WMS_재고조정
ALTER TABLE "wms_inven_ad"
	ADD CONSTRAINT "wms_inven_ad_PK"
		 -- WMS_재고조정_PK
	PRIMARY KEY 
	USING INDEX "wms_inven_ad_PK";

-- WMS_재고조정_PK
COMMENT ON CONSTRAINT "wms_inven_ad_PK" ON "wms_inven_ad" IS 'WMS_재고조정_PK';

-- WMS_재고조정
ALTER TABLE "wms_inven_ad"
	ADD CONSTRAINT "UK_wms_inven_ad" -- WMS_재고조정 유니크 제약
	UNIQUE 
	USING INDEX "UIX_wms_inven_ad";

-- WMS_재고조정 유니크 제약
COMMENT ON CONSTRAINT "UK_wms_inven_ad" ON "wms_inven_ad" IS 'WMS_재고조정 유니크 제약';

-- WMS_재고조정_처리
CREATE TABLE "wms_inven_ad_tran"
(
	"ad_tran_seq"    bigint        NOT NULL DEFAULT nextval('wms_inven_ad_tran_seq'), -- 재고조정_처리_SEQ
	"ad_prod_seq"    bigint        NOT NULL, -- 재고조정_품목_SEQ
	"ad_seq"         int4          NOT NULL, -- 재고조정_SEQ
	"prod_seq"       int4          NOT NULL, -- 품목_SEQ
	"wh_seq"         int4          NOT NULL, -- 창고_SEQ
	"loc_seq"        bigint        NOT NULL, -- 위치_SEQ
	"sku1"           varchar(100)  NOT NULL, -- SKU1
	"sku2"           varchar(100)  NOT NULL, -- SKU2
	"proc_qty"       decimal(10,2) NOT NULL DEFAULT 0, -- 처리_수량(재고조정)
	"ex_qty"         decimal(10,2) NOT NULL DEFAULT 0, -- 기처리_수량(재고조정)
	"mng_ymd"        varchar(8)    NULL,     -- 입고/제조일자
	"exp_ymd"        varchar(8)    NULL,     -- 유통기한_연월일
	"lot_no"         varchar(30)   NULL,     -- LOT_번호
	"cn"             int4          NULL,     -- C/N
	"proc_bundle_no" varchar(30)   NULL,     -- 처리_묶음_번호
	"proc_ymd"       varchar(8)    NULL,     -- 처리_연월일(재고조정)
	"proc_hms"       varchar(6)    NULL,     -- 처리_시분초(재고조정)
	"proc_user_id"   varchar(20)   NULL,     -- 처리_자_ID(재고조정)
	"if_err_seq"     int4          NULL,     -- IF_에러_일련번호
	"if_send_yn"     char(1)       NOT NULL DEFAULT 'N', -- IF_송신_여부
	"del_yn"         char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"         varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"         timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"         varchar(20)   NULL,     -- 수정_ID
	"mod_dt"         timestamp     NULL      -- 수정_일시
);

-- WMS_재고조정_처리
COMMENT ON TABLE "wms_inven_ad_tran" IS 'WMS_재고조정_처리';

-- 재고조정_처리_SEQ
COMMENT ON COLUMN "wms_inven_ad_tran"."ad_tran_seq" IS '재고조정_처리_SEQ';

-- 재고조정_품목_SEQ
COMMENT ON COLUMN "wms_inven_ad_tran"."ad_prod_seq" IS '재고조정_품목_SEQ';

-- 재고조정_SEQ
COMMENT ON COLUMN "wms_inven_ad_tran"."ad_seq" IS '재고조정_SEQ';

-- 품목_SEQ
COMMENT ON COLUMN "wms_inven_ad_tran"."prod_seq" IS '품목ID';

-- 창고_SEQ
COMMENT ON COLUMN "wms_inven_ad_tran"."wh_seq" IS '창고_ID';

-- 위치_SEQ
COMMENT ON COLUMN "wms_inven_ad_tran"."loc_seq" IS '위치_ID';

-- SKU1
COMMENT ON COLUMN "wms_inven_ad_tran"."sku1" IS 'SKU1(FR)';

-- SKU2
COMMENT ON COLUMN "wms_inven_ad_tran"."sku2" IS 'SKU2(FR)';

-- 처리_수량(재고조정)
COMMENT ON COLUMN "wms_inven_ad_tran"."proc_qty" IS '처리수량';

-- 기처리_수량(재고조정)
COMMENT ON COLUMN "wms_inven_ad_tran"."ex_qty" IS '기_출하_수량';

-- 입고/제조일자
COMMENT ON COLUMN "wms_inven_ad_tran"."mng_ymd" IS '입고/제조일자';

-- 유통기한_연월일
COMMENT ON COLUMN "wms_inven_ad_tran"."exp_ymd" IS '유통기한_연월일';

-- LOT_번호
COMMENT ON COLUMN "wms_inven_ad_tran"."lot_no" IS 'LOT_번호';

-- C/N
COMMENT ON COLUMN "wms_inven_ad_tran"."cn" IS 'C/N';

-- 처리_묶음_번호
COMMENT ON COLUMN "wms_inven_ad_tran"."proc_bundle_no" IS '문서번호';

-- 처리_연월일(재고조정)
COMMENT ON COLUMN "wms_inven_ad_tran"."proc_ymd" IS '입고_일자';

-- 처리_시분초(재고조정)
COMMENT ON COLUMN "wms_inven_ad_tran"."proc_hms" IS '입고_시간';

-- 처리_자_ID(재고조정)
COMMENT ON COLUMN "wms_inven_ad_tran"."proc_user_id" IS '입고_작업자_아이디';

-- IF_에러_일련번호
COMMENT ON COLUMN "wms_inven_ad_tran"."if_err_seq" IS 'IF_에러_일련번호';

-- IF_송신_여부
COMMENT ON COLUMN "wms_inven_ad_tran"."if_send_yn" IS 'ERP_송신_여부';

-- 삭제_여부
COMMENT ON COLUMN "wms_inven_ad_tran"."del_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "wms_inven_ad_tran"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_inven_ad_tran"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_inven_ad_tran"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_inven_ad_tran"."mod_dt" IS '수정일';

-- WMS_재고조정_처리_PK
CREATE UNIQUE INDEX "wms_inven_ad_tran_PK"
	ON "wms_inven_ad_tran"
	( -- WMS_재고조정_처리
		"ad_tran_seq" ASC, -- 재고조정_처리_SEQ
		"ad_prod_seq" ASC, -- 재고조정_품목_SEQ
		"ad_seq" ASC -- 재고조정_SEQ
	)
;
-- WMS_재고조정_처리
ALTER TABLE "wms_inven_ad_tran"
	ADD CONSTRAINT "wms_inven_ad_tran_PK"
		 -- WMS_재고조정_처리_PK
	PRIMARY KEY 
	USING INDEX "wms_inven_ad_tran_PK";

-- WMS_재고조정_처리_PK
COMMENT ON CONSTRAINT "wms_inven_ad_tran_PK" ON "wms_inven_ad_tran" IS 'WMS_재고조정_처리_PK';

-- WMS_재고조정_품목
CREATE TABLE "wms_inven_ad_prod"
(
	"ad_prod_seq"    bigint        NOT NULL DEFAULT nextval('wms_inven_ad_prod_seq'), -- 재고조정_품목_SEQ
	"ad_seq"         int4          NOT NULL, -- 재고조정_SEQ
	"prod_seq"       int4          NOT NULL, -- 품목_SEQ
	"ad_prod_sts_cd" varchar(50)   NOT NULL, -- 재고조정_품목_상태_코드
	"req_qty"        decimal(10,2) NOT NULL DEFAULT 0, -- 요청_수량(재고조정)
	"ex_qty"         decimal(10,2) NOT NULL DEFAULT 0, -- 기처리_수량(재고조정)
	"new_inven_yn"   char(1)       NOT NULL DEFAULT 'N', -- 신규재고_여부
	"est_wh_seq"     int4          NULL,     -- 예상_창고_SEQ
	"est_mng_ymd"    varchar(8)    NULL,     -- 예상_입고/제조일자
	"est_exp_ymd"    varchar(8)    NULL,     -- 예상_유통기한_연월일
	"est_lot_no"     varchar(30)   NULL,     -- 예상_LOT_번호
	"if_err_seq"     int4          NULL,     -- IF_에러_일련번호
	"if_idx"         varchar(20)   NULL,     -- IF_내부순번
	"if_send_yn"     char(1)       NOT NULL DEFAULT 'N', -- IF_송신_여부
	"del_yn"         char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"         varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"         timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"         varchar(20)   NULL,     -- 수정_ID
	"mod_dt"         timestamp     NULL      -- 수정_일시
);

-- WMS_재고조정_품목
COMMENT ON TABLE "wms_inven_ad_prod" IS 'WMS_재고조정_품목';

-- 재고조정_품목_SEQ
COMMENT ON COLUMN "wms_inven_ad_prod"."ad_prod_seq" IS '재고조정_품목_SEQ';

-- 재고조정_SEQ
COMMENT ON COLUMN "wms_inven_ad_prod"."ad_seq" IS '재고조정_SEQ';

-- 품목_SEQ
COMMENT ON COLUMN "wms_inven_ad_prod"."prod_seq" IS '품목ID';

-- 재고조정_품목_상태_코드
COMMENT ON COLUMN "wms_inven_ad_prod"."ad_prod_sts_cd" IS '처리_상태_코드';

-- 요청_수량(재고조정)
COMMENT ON COLUMN "wms_inven_ad_prod"."req_qty" IS '예외출고_요청_수량';

-- 기처리_수량(재고조정)
COMMENT ON COLUMN "wms_inven_ad_prod"."ex_qty" IS '기_출하_수량';

-- 신규재고_여부
COMMENT ON COLUMN "wms_inven_ad_prod"."new_inven_yn" IS '신규재고_여부';

-- 예상_창고_SEQ
COMMENT ON COLUMN "wms_inven_ad_prod"."est_wh_seq" IS '창고_ID';

-- 예상_입고/제조일자
COMMENT ON COLUMN "wms_inven_ad_prod"."est_mng_ymd" IS '예상_입고/제조일자';

-- 예상_유통기한_연월일
COMMENT ON COLUMN "wms_inven_ad_prod"."est_exp_ymd" IS '예상_유통기한_연월일';

-- 예상_LOT_번호
COMMENT ON COLUMN "wms_inven_ad_prod"."est_lot_no" IS '예상_LOT_번호';

-- IF_에러_일련번호
COMMENT ON COLUMN "wms_inven_ad_prod"."if_err_seq" IS 'IF_에러_일련번호';

-- IF_내부순번
COMMENT ON COLUMN "wms_inven_ad_prod"."if_idx" IS '순번 --';

-- IF_송신_여부
COMMENT ON COLUMN "wms_inven_ad_prod"."if_send_yn" IS 'ERP_송신_여부';

-- 삭제_여부
COMMENT ON COLUMN "wms_inven_ad_prod"."del_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "wms_inven_ad_prod"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_inven_ad_prod"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_inven_ad_prod"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_inven_ad_prod"."mod_dt" IS '수정일';

-- WMS_재고조정_품목_PK
CREATE UNIQUE INDEX "wms_inven_ad_prod_PK"
	ON "wms_inven_ad_prod"
	( -- WMS_재고조정_품목
		"ad_prod_seq" ASC, -- 재고조정_품목_SEQ
		"ad_seq" ASC -- 재고조정_SEQ
	)
;
-- WMS_재고조정_품목
ALTER TABLE "wms_inven_ad_prod"
	ADD CONSTRAINT "wms_inven_ad_prod_PK"
		 -- WMS_재고조정_품목_PK
	PRIMARY KEY 
	USING INDEX "wms_inven_ad_prod_PK";

-- WMS_재고조정_품목_PK
COMMENT ON CONSTRAINT "wms_inven_ad_prod_PK" ON "wms_inven_ad_prod" IS 'WMS_재고조정_품목_PK';

-- WMS_출고
CREATE TABLE "wms_outwh"
(
	"outwh_seq"          int4          NOT NULL DEFAULT nextval('wms_outwh_seq'), -- 출고_SEQ
	"biz_seq"            int4          NOT NULL, -- 사업장_SEQ
	"outwh_no"           varchar(30)   NOT NULL, -- 출고_번호
	"center_seq"         int4          NOT NULL, -- 센터_SEQ
	"outwh_type_cd"      varchar(50)   NOT NULL, -- 출고_유형_코드
	"outwh_sts_cd"       varchar(50)   NOT NULL, -- 출고_상태_코드
	"outwh_proc_type_cd" varchar(50)   NOT NULL DEFAULT 'B2B', -- 출고_처리_유형_코드
	"outwh_div_cd"       varchar(50)   NOT NULL, -- 출고_지시_유형_코드
	"outwh_div_key"      varchar(50)   NULL,     -- 출고_지시_분류키
	"outwh_div_id"       varchar(50)   NULL,     -- 출고_지시_분류값
	"strng_asgn_yn"      char(1)       NOT NULL DEFAULT 'N', -- 출고_강지정_여부
	"group_outwh_no"     varchar(30)   NOT NULL, -- 그룹_출고_번호
	"req_ymd"            varchar(8)    NOT NULL, -- 예정_연월일(출고)
	"req_hms"            varchar(6)    NULL,     -- 예정_시분초(출고)
	"req_user_nm"        varchar(100)  NOT NULL, -- 요청_사용자_명(출고)
	"req_dept_nm"        varchar(100)  NULL,     -- 요청_부서_명
	"cfm_ymd"            varchar(8)    NULL,     -- 확정_연월일(출고)
	"cfm_hms"            varchar(6)    NULL,     -- 확정_시분초(출고)
	"cfm_user_id"        varchar(20)   NULL,     -- 확정_자_ID(출고)
	"note"               varchar(1000) NULL,     -- 비고
	"if_key"             varchar(50)   NULL,     -- IF_KEY
	"if_err_seq"         int4          NULL,     -- IF_에러_일련번호
	"if_send_yn"         char(1)       NOT NULL DEFAULT 'N', -- IF_송신_여부
	"del_yn"             char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"             varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"             timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"             varchar(20)   NULL,     -- 수정_ID
	"mod_dt"             timestamp     NULL      -- 수정_일시
);

-- WMS_출고
COMMENT ON TABLE "wms_outwh" IS 'WMS_출고';

-- 출고_SEQ
COMMENT ON COLUMN "wms_outwh"."outwh_seq" IS '출고_요청_번호';

-- 사업장_SEQ
COMMENT ON COLUMN "wms_outwh"."biz_seq" IS '사업장_ID';

-- 출고_번호
COMMENT ON COLUMN "wms_outwh"."outwh_no" IS '출고_요청_번호';

-- 센터_SEQ
COMMENT ON COLUMN "wms_outwh"."center_seq" IS '센터_SEQ';

-- 출고_유형_코드
COMMENT ON COLUMN "wms_outwh"."outwh_type_cd" IS '출고_유형_코드';

-- 출고_상태_코드
COMMENT ON COLUMN "wms_outwh"."outwh_sts_cd" IS '출고_상태_코드';

-- 출고_처리_유형_코드
COMMENT ON COLUMN "wms_outwh"."outwh_proc_type_cd" IS '출고_처리_유형_코드';

-- 출고_지시_유형_코드
COMMENT ON COLUMN "wms_outwh"."outwh_div_cd" IS '출고_지시_유형_코드';

-- 출고_지시_분류키
COMMENT ON COLUMN "wms_outwh"."outwh_div_key" IS '출고_지시_분류키';

-- 출고_지시_분류값
COMMENT ON COLUMN "wms_outwh"."outwh_div_id" IS '출고_지시_분류값';

-- 출고_강지정_여부
COMMENT ON COLUMN "wms_outwh"."strng_asgn_yn" IS '출고_강지정_여부';

-- 그룹_출고_번호
COMMENT ON COLUMN "wms_outwh"."group_outwh_no" IS '그룹_출고_번호';

-- 예정_연월일(출고)
COMMENT ON COLUMN "wms_outwh"."req_ymd" IS '출고_요청_일자';

-- 예정_시분초(출고)
COMMENT ON COLUMN "wms_outwh"."req_hms" IS '출고_요청_시간';

-- 요청_사용자_명(출고)
COMMENT ON COLUMN "wms_outwh"."req_user_nm" IS '출고_요청자_아이디';

-- 요청_부서_명
COMMENT ON COLUMN "wms_outwh"."req_dept_nm" IS '요청_부서_명';

-- 확정_연월일(출고)
COMMENT ON COLUMN "wms_outwh"."cfm_ymd" IS '입고_확정_일자';

-- 확정_시분초(출고)
COMMENT ON COLUMN "wms_outwh"."cfm_hms" IS '입고_확정_시간';

-- 확정_자_ID(출고)
COMMENT ON COLUMN "wms_outwh"."cfm_user_id" IS '입고_확인자_아이디';

-- 비고
COMMENT ON COLUMN "wms_outwh"."note" IS '비고';

-- IF_KEY
COMMENT ON COLUMN "wms_outwh"."if_key" IS '발주내부_코드(ERP)';

-- IF_에러_일련번호
COMMENT ON COLUMN "wms_outwh"."if_err_seq" IS 'IF_에러_일련번호';

-- IF_송신_여부
COMMENT ON COLUMN "wms_outwh"."if_send_yn" IS 'ERP_송신_여부';

-- 삭제_여부
COMMENT ON COLUMN "wms_outwh"."del_yn" IS '삭제_여부';

-- 등록_ID
COMMENT ON COLUMN "wms_outwh"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_outwh"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_outwh"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_outwh"."mod_dt" IS '수정일';

-- WMS_출고_PK
CREATE UNIQUE INDEX "wms_outwh_PK"
	ON "wms_outwh"
	( -- WMS_출고
		"outwh_seq" ASC -- 출고_SEQ
	)
;
-- WMS_출고
ALTER TABLE "wms_outwh"
	ADD CONSTRAINT "wms_outwh_PK"
		 -- WMS_출고_PK
	PRIMARY KEY 
	USING INDEX "wms_outwh_PK";

-- WMS_출고_PK
COMMENT ON CONSTRAINT "wms_outwh_PK" ON "wms_outwh" IS 'WMS_출고_PK';

-- WMS_출고_처리
CREATE TABLE "wms_outwh_tran"
(
	"outwh_tran_seq" bigint        NOT NULL DEFAULT nextval('wms_outwh_tran_seq'), -- 출고_처리_SEQ
	"outwh_prod_seq" bigint        NOT NULL, -- 출고_품목_SEQ
	"outwh_seq"      int4          NOT NULL, -- 출고_SEQ
	"prod_seq"       int4          NOT NULL, -- 품목_SEQ
	"sku1"           varchar(100)  NOT NULL, -- SKU1
	"sku2"           varchar(100)  NOT NULL, -- SKU2
	"mng_ymd"        varchar(8)    NULL,     -- 입고/제조일자
	"exp_ymd"        varchar(8)    NULL,     -- 유통기한
	"lot_no"         varchar(30)   NULL,     -- LOT_번호
	"fr_wh_seq"      int4          NULL,     -- FR_창고_SEQ
	"fr_loc_seq"     bigint        NULL,     -- FR_위치_SEQ
	"proc_qty"       decimal(10,2) NOT NULL DEFAULT 0, -- 처리_수량(출고)
	"ex_qty"         decimal(10,2) NOT NULL DEFAULT 0, -- 기처리_수량(출고)
	"to_wh_seq"      int4          NULL,     -- TO_창고_SEQ
	"to_loc_seq"     bigint        NULL,     -- TO_위치_SEQ
	"proc_bundle_no" varchar(30)   NULL,     -- 처리_묶음_번호
	"proc_ymd"       varchar(8)    NULL,     -- 처리_연월일(출고)
	"proc_hms"       varchar(6)    NULL,     -- 처리_시분초(출고)
	"proc_user_id"   varchar(20)   NULL,     -- 처리_자_ID(출고)
	"if_err_seq"     int4          NULL,     -- IF_에러_일련번호
	"if_send_yn"     char(1)       NOT NULL DEFAULT 'N', -- IF_송신_여부
	"del_yn"         char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"         varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"         timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"         varchar(20)   NULL,     -- 수정_ID
	"mod_dt"         timestamp     NULL      -- 수정_일시
);

-- WMS_출고_처리
COMMENT ON TABLE "wms_outwh_tran" IS 'WMS_출고_처리';

-- 출고_처리_SEQ
COMMENT ON COLUMN "wms_outwh_tran"."outwh_tran_seq" IS '출고_처리_SEQ';

-- 출고_품목_SEQ
COMMENT ON COLUMN "wms_outwh_tran"."outwh_prod_seq" IS '출고_품목_SEQ';

-- 출고_SEQ
COMMENT ON COLUMN "wms_outwh_tran"."outwh_seq" IS '출고_SEQ';

-- 품목_SEQ
COMMENT ON COLUMN "wms_outwh_tran"."prod_seq" IS '품목ID';

-- SKU1
COMMENT ON COLUMN "wms_outwh_tran"."sku1" IS 'SKU1';

-- SKU2
COMMENT ON COLUMN "wms_outwh_tran"."sku2" IS 'SKU2';

-- 입고/제조일자
COMMENT ON COLUMN "wms_outwh_tran"."mng_ymd" IS '입고/제조일자';

-- 유통기한
COMMENT ON COLUMN "wms_outwh_tran"."exp_ymd" IS '유통기한';

-- LOT_번호
COMMENT ON COLUMN "wms_outwh_tran"."lot_no" IS 'LOT_번호';

-- FR_창고_SEQ
COMMENT ON COLUMN "wms_outwh_tran"."fr_wh_seq" IS '창고(FR)';

-- FR_위치_SEQ
COMMENT ON COLUMN "wms_outwh_tran"."fr_loc_seq" IS '위치(FR)';

-- 처리_수량(출고)
COMMENT ON COLUMN "wms_outwh_tran"."proc_qty" IS '출고_수량';

-- 기처리_수량(출고)
COMMENT ON COLUMN "wms_outwh_tran"."ex_qty" IS '출고_수량';

-- TO_창고_SEQ
COMMENT ON COLUMN "wms_outwh_tran"."to_wh_seq" IS '창고(TO)';

-- TO_위치_SEQ
COMMENT ON COLUMN "wms_outwh_tran"."to_loc_seq" IS '위치(TO)';

-- 처리_묶음_번호
COMMENT ON COLUMN "wms_outwh_tran"."proc_bundle_no" IS '처리_묶음_번호';

-- 처리_연월일(출고)
COMMENT ON COLUMN "wms_outwh_tran"."proc_ymd" IS '입고_일자';

-- 처리_시분초(출고)
COMMENT ON COLUMN "wms_outwh_tran"."proc_hms" IS '입고_시간';

-- 처리_자_ID(출고)
COMMENT ON COLUMN "wms_outwh_tran"."proc_user_id" IS '입고_작업자_아이디';

-- IF_에러_일련번호
COMMENT ON COLUMN "wms_outwh_tran"."if_err_seq" IS 'IF_에러_일련번호';

-- IF_송신_여부
COMMENT ON COLUMN "wms_outwh_tran"."if_send_yn" IS 'ERP_송신_여부';

-- 삭제_여부
COMMENT ON COLUMN "wms_outwh_tran"."del_yn" IS '삭제_여부';

-- 등록_ID
COMMENT ON COLUMN "wms_outwh_tran"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_outwh_tran"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_outwh_tran"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_outwh_tran"."mod_dt" IS '수정일';

-- WMS_출고_처리_PK
CREATE UNIQUE INDEX "wms_outwh_tran_PK"
	ON "wms_outwh_tran"
	( -- WMS_출고_처리
		"outwh_tran_seq" ASC, -- 출고_처리_SEQ
		"outwh_prod_seq" ASC, -- 출고_품목_SEQ
		"outwh_seq" ASC -- 출고_SEQ
	)
;
-- WMS_출고_처리
ALTER TABLE "wms_outwh_tran"
	ADD CONSTRAINT "wms_outwh_tran_PK"
		 -- WMS_출고_처리_PK
	PRIMARY KEY 
	USING INDEX "wms_outwh_tran_PK";

-- WMS_출고_처리_PK
COMMENT ON CONSTRAINT "wms_outwh_tran_PK" ON "wms_outwh_tran" IS 'WMS_출고_처리_PK';

-- WMS_출고_품목
CREATE TABLE "wms_outwh_prod"
(
	"outwh_prod_seq"    bigint        NOT NULL DEFAULT nextval('wms_outwh_prod_seq'), -- 출고_품목_SEQ
	"outwh_seq"         int4          NOT NULL, -- 출고_SEQ
	"prod_seq"          int4          NOT NULL, -- 품목_SEQ
	"outwh_prod_sts_cd" varchar(50)   NOT NULL, -- 출고_품목_상태_코드
	"req_qty"           decimal(10,2) NOT NULL DEFAULT 0, -- 요청_수량(출고)
	"ex_qty"            decimal(10,2) NOT NULL DEFAULT 0, -- 기처리_수량(출고)
	"est_mng_ymd"       varchar(8)    NULL,     -- 예상_입고/제조일자
	"est_exp_ymd"       varchar(8)    NULL,     -- 예상_유통기한
	"est_lot_no"        varchar(30)   NULL,     -- 예상_LOT_NO
	"est_cn"            varchar(1000) NULL,     -- 예상_CN
	"if_idx"            varchar(20)   NULL,     -- IF_내부순번
	"if_err_seq"        int4          NULL,     -- IF_에러_일련번호
	"if_send_yn"        char(1)       NOT NULL DEFAULT 'N', -- IF_송신_여부
	"del_yn"            char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"            varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"            timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"            varchar(20)   NULL,     -- 수정_ID
	"mod_dt"            timestamp     NULL      -- 수정_일시
);

-- WMS_출고_품목
COMMENT ON TABLE "wms_outwh_prod" IS 'WMS_출고_품목';

-- 출고_품목_SEQ
COMMENT ON COLUMN "wms_outwh_prod"."outwh_prod_seq" IS '출고_품목_SEQ';

-- 출고_SEQ
COMMENT ON COLUMN "wms_outwh_prod"."outwh_seq" IS '출고_SEQ';

-- 품목_SEQ
COMMENT ON COLUMN "wms_outwh_prod"."prod_seq" IS '품목ID';

-- 출고_품목_상태_코드
COMMENT ON COLUMN "wms_outwh_prod"."outwh_prod_sts_cd" IS '출고_품목_상태_코드';

-- 요청_수량(출고)
COMMENT ON COLUMN "wms_outwh_prod"."req_qty" IS '출고_요청_수량';

-- 기처리_수량(출고)
COMMENT ON COLUMN "wms_outwh_prod"."ex_qty" IS '기_출하_수량';

-- 예상_입고/제조일자
COMMENT ON COLUMN "wms_outwh_prod"."est_mng_ymd" IS '예상_입고/제조일자';

-- 예상_유통기한
COMMENT ON COLUMN "wms_outwh_prod"."est_exp_ymd" IS '예상_유통기한';

-- 예상_LOT_NO
COMMENT ON COLUMN "wms_outwh_prod"."est_lot_no" IS '예상_LOT_NO';

-- 예상_CN
COMMENT ON COLUMN "wms_outwh_prod"."est_cn" IS '예상_CN';

-- IF_내부순번
COMMENT ON COLUMN "wms_outwh_prod"."if_idx" IS '순번 --';

-- IF_에러_일련번호
COMMENT ON COLUMN "wms_outwh_prod"."if_err_seq" IS 'IF_에러_일련번호';

-- IF_송신_여부
COMMENT ON COLUMN "wms_outwh_prod"."if_send_yn" IS 'ERP_송신_여부';

-- 삭제_여부
COMMENT ON COLUMN "wms_outwh_prod"."del_yn" IS '삭제_여부';

-- 등록_ID
COMMENT ON COLUMN "wms_outwh_prod"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_outwh_prod"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_outwh_prod"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_outwh_prod"."mod_dt" IS '수정일';

-- WMS_출고_품목_PK
CREATE UNIQUE INDEX "wms_outwh_prod_PK"
	ON "wms_outwh_prod"
	( -- WMS_출고_품목
		"outwh_prod_seq" ASC, -- 출고_품목_SEQ
		"outwh_seq" ASC -- 출고_SEQ
	)
;
-- WMS_출고_품목
ALTER TABLE "wms_outwh_prod"
	ADD CONSTRAINT "wms_outwh_prod_PK"
		 -- WMS_출고_품목_PK
	PRIMARY KEY 
	USING INDEX "wms_outwh_prod_PK";

-- WMS_출고_품목_PK
COMMENT ON CONSTRAINT "wms_outwh_prod_PK" ON "wms_outwh_prod" IS 'WMS_출고_품목_PK';

-- WMS_출고지시
CREATE TABLE "wms_outwh_assign"
(
	"outwh_assign_seq" bigint        NOT NULL DEFAULT nextval('wms_outwh_assign_seq'), -- 지시_SEQ
	"biz_seq"          int4          NOT NULL, -- 사업장_SEQ
	"center_seq"       int4          NOT NULL, -- 센터_SEQ
	"req_seq"          int4          NOT NULL, -- 요청_SEQ
	"req_prod_seq"     bigint        NOT NULL, -- 요청_품목_SEQ
	"prod_seq"         int4          NOT NULL, -- 품목_SEQ
	"wh_seq"           int4          NULL,     -- 창고
	"loc_seq"          bigint        NULL,     -- 위치
	"sku1"             varchar(100)  NULL,     -- SKU1
	"sku2"             varchar(100)  NULL,     -- SKU2
	"req_qty"          decimal(10,2) NULL     DEFAULT 0, -- 요청_수량
	"mng_ymd"          varchar(8)    NULL,     -- 입고/제조일자
	"exp_ymd"          varchar(8)    NULL,     -- 유통기한
	"lot_no"           varchar(30)   NULL,     -- LOT_NO
	"req_no"           varchar(30)   NOT NULL, -- 업무_번호
	"strng_asgn_yn"    char(1)       NOT NULL DEFAULT 'N', -- 출고_강지정_여부
	"reg_id"           varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"           timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"           varchar(20)   NULL,     -- 수정_ID
	"mod_dt"           timestamp     NULL      -- 수정_일시
);

-- WMS_출고지시
COMMENT ON TABLE "wms_outwh_assign" IS 'WMS_출고지시';

-- 지시_SEQ
COMMENT ON COLUMN "wms_outwh_assign"."outwh_assign_seq" IS '지시_SEQ';

-- 사업장_SEQ
COMMENT ON COLUMN "wms_outwh_assign"."biz_seq" IS '사업장_ID';

-- 센터_SEQ
COMMENT ON COLUMN "wms_outwh_assign"."center_seq" IS '센터_SEQ';

-- 요청_SEQ
COMMENT ON COLUMN "wms_outwh_assign"."req_seq" IS '관련번호';

-- 요청_품목_SEQ
COMMENT ON COLUMN "wms_outwh_assign"."req_prod_seq" IS '요청_품목_SEQ';

-- 품목_SEQ
COMMENT ON COLUMN "wms_outwh_assign"."prod_seq" IS '품목ID';

-- 창고
COMMENT ON COLUMN "wms_outwh_assign"."wh_seq" IS '창고';

-- 위치
COMMENT ON COLUMN "wms_outwh_assign"."loc_seq" IS '위치';

-- SKU1
COMMENT ON COLUMN "wms_outwh_assign"."sku1" IS 'SKU1';

-- SKU2
COMMENT ON COLUMN "wms_outwh_assign"."sku2" IS 'SKU2';

-- 요청_수량
COMMENT ON COLUMN "wms_outwh_assign"."req_qty" IS '요청_수량';

-- 입고/제조일자
COMMENT ON COLUMN "wms_outwh_assign"."mng_ymd" IS '입고/제조일자';

-- 유통기한
COMMENT ON COLUMN "wms_outwh_assign"."exp_ymd" IS '유통기한';

-- LOT_NO
COMMENT ON COLUMN "wms_outwh_assign"."lot_no" IS 'LOT_NO';

-- 업무_번호
COMMENT ON COLUMN "wms_outwh_assign"."req_no" IS '관련번호';

-- 출고_강지정_여부
COMMENT ON COLUMN "wms_outwh_assign"."strng_asgn_yn" IS '출고_강지정_여부';

-- 등록_ID
COMMENT ON COLUMN "wms_outwh_assign"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_outwh_assign"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_outwh_assign"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_outwh_assign"."mod_dt" IS '수정일';

-- WMS_OW_ASSIGN_IDX
CREATE INDEX "IX_wms_outwh_assign"
	ON "wms_outwh_assign"	( -- WMS_출고지시
		"biz_seq" ASC, -- 사업장_SEQ
		"center_seq" ASC, -- 센터_SEQ
		"prod_seq" ASC -- 품목_SEQ
	);

-- WMS_OW_ASSIGN_IDX
COMMENT ON INDEX "IX_wms_outwh_assign" IS 'WMS_OW_ASSIGN_IDX';

-- WMS_OW_ASSIGIN_IDX2
CREATE INDEX "IX_wms_outwh_assign2"
	ON "wms_outwh_assign"	( -- WMS_출고지시
		"req_seq" ASC, -- 요청_SEQ
		"req_prod_seq" ASC -- 요청_품목_SEQ
	);

-- WMS_OW_ASSIGIN_IDX2
COMMENT ON INDEX "IX_wms_outwh_assign2" IS 'WMS_OW_ASSIGIN_IDX2';

-- WMS_출고지시_PK
CREATE UNIQUE INDEX "wms_outwh_assign_PK"
	ON "wms_outwh_assign"
	( -- WMS_출고지시
		"outwh_assign_seq" ASC -- 지시_SEQ
	)
;
-- WMS_출고지시
ALTER TABLE "wms_outwh_assign"
	ADD CONSTRAINT "wms_outwh_assign_PK"
		 -- WMS_출고지시_PK
	PRIMARY KEY 
	USING INDEX "wms_outwh_assign_PK";

-- WMS_출고지시_PK
COMMENT ON CONSTRAINT "wms_outwh_assign_PK" ON "wms_outwh_assign" IS 'WMS_출고지시_PK';

-- WMS_출하
CREATE TABLE "wms_outbiz"
(
	"outbiz_seq"          int4          NOT NULL DEFAULT nextval('wms_outbiz_seq'), -- 출하_SEQ
	"biz_seq"             int4          NOT NULL, -- 사업장_SEQ
	"outbiz_no"           varchar(30)   NOT NULL, -- 출하_번호
	"center_seq"          int4          NOT NULL, -- 센터_SEQ
	"outbiz_proc_type_cd" varchar(50)   NOT NULL, -- 배송_유형_코드
	"trn_type_cd"         varchar(50)   NULL,     -- 운송_구분_코드
	"outbiz_type_cd"      varchar(50)   NOT NULL, -- 출하_유형_코드
	"outbiz_sts_cd"       varchar(50)   NOT NULL, -- 출하_상태_코드
	"outwh_proc_yn"       char(1)       NOT NULL DEFAULT 'Y', -- 출고처리_유무
	"auto_outbiz_yn"      char(1)       NOT NULL DEFAULT 'N', -- 자동출하_유무
	"if_device_cd"        varchar(50)   NOT NULL DEFAULT '-', -- IF_장치_코드
	"outbiz_stop_yn"      char(1)       NOT NULL DEFAULT 'N', -- 출하중단_유무
	"sales_user_nm"       varchar(100)  NULL,     -- 영업_담당자_명
	"sales_dept_nm"       varchar(100)  NULL,     -- 영업_부서_명
	"req_ymd"             varchar(8)    NOT NULL, -- 예정_연월일(출하)
	"req_hms"             varchar(6)    NULL,     -- 예정_시분초(출하)
	"req_user_nm"         varchar(100)  NOT NULL, -- 요청_사용자_명(출하)
	"cont_seq"            int4          NULL,     -- 주문처_ID
	"so_ymd"              varchar(8)    NULL,     -- 주문_연월일
	"so_hms"              varchar(6)    NULL,     -- 주문_시분초
	"so_no"               varchar(30)   NULL,     -- 주문_번호
	"req_no"              varchar(30)   NULL,     -- 문서_번호(타시스템)
	"erp_wh_cd"           varchar(50)   NULL,     -- 출하처_CODE(타시스템)
	"delivery_nm"         varchar(100)  NULL,     -- 납품처_명
	"delivery_ymd"        varchar(8)    NULL,     -- 납품_연월일
	"delivery_hms"        varchar(6)    NULL,     -- 납품_시분초
	"delivery_mng_nm"     varchar(100)  NULL,     -- 납품처_담당자_명
	"delivery_tel"        varchar(500)  NULL,     -- 납품처_전화번호
	"delivery_addr"       varchar(200)  NULL,     -- 납품처_주소
	"delivery_addr_dtl"   varchar(200)  NULL,     -- 납품처_주소_상세
	"ord_nm"              varchar(100)  NULL,     -- 주문자_명
	"rcv_nm"              varchar(100)  NULL,     -- 받는자_명
	"rcv_tel"             varchar(500)  NULL,     -- 받는자_전화번호
	"rcv_addr"            varchar(200)  NULL,     -- 받는자_주소
	"rcv_addr_dtl"        varchar(200)  NULL,     -- 받는자_상세_주소
	"rcv_post_no"         varchar(10)   NULL,     -- 받는자_우편_번호
	"send_nm"             varchar(100)  NULL,     -- 보내는자_명
	"send_tel"            varchar(500)  NULL,     -- 보내는자_전화번호
	"invoice_info"        varchar(1000) NULL,     -- 송장_설정
	"cfm_ymd"             varchar(8)    NULL,     -- 확정_연월일(출하)
	"cfm_hms"             varchar(6)    NULL,     -- 확정_시분초(출하)
	"cfm_user_id"         varchar(20)   NULL,     -- 확정_자_ID(출하)
	"ship_msg"            varchar(1000) NULL,     -- 배송메세지
	"inwh_seq"            int4          NULL,     -- 입고_SEQ
	"dlv_config_seq"      int4          NULL,     -- 택배사_설정
	"note"                varchar(1000) NULL,     -- 비고
	"if_key"              varchar(50)   NULL,     -- IF_KEY
	"if_err_seq"          int4          NULL,     -- IF_에러_일련번호
	"if_send_yn"          char(1)       NOT NULL DEFAULT 'N', -- IF_송신_여부
	"del_yn"              char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"              varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"              timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"              varchar(20)   NULL,     -- 수정_ID
	"mod_dt"              timestamp     NULL      -- 수정_일시
);

-- WMS_출하
COMMENT ON TABLE "wms_outbiz" IS 'WMS_출하';

-- 출하_SEQ
COMMENT ON COLUMN "wms_outbiz"."outbiz_seq" IS '출하_예정_번호';

-- 사업장_SEQ
COMMENT ON COLUMN "wms_outbiz"."biz_seq" IS '사업장_ID';

-- 출하_번호
COMMENT ON COLUMN "wms_outbiz"."outbiz_no" IS '출하_예정_번호';

-- 센터_SEQ
COMMENT ON COLUMN "wms_outbiz"."center_seq" IS '센터_SEQ';

-- 배송_유형_코드
COMMENT ON COLUMN "wms_outbiz"."outbiz_proc_type_cd" IS '출하_처리_유형_코드';

-- 운송_구분_코드
COMMENT ON COLUMN "wms_outbiz"."trn_type_cd" IS '운송_구분_코드';

-- 출하_유형_코드
COMMENT ON COLUMN "wms_outbiz"."outbiz_type_cd" IS '출하_유형_코드(ERP)';

-- 출하_상태_코드
COMMENT ON COLUMN "wms_outbiz"."outbiz_sts_cd" IS '출하_상태_코드';

-- 출고처리_유무
COMMENT ON COLUMN "wms_outbiz"."outwh_proc_yn" IS '출고처리_유무';

-- 자동출하_유무
COMMENT ON COLUMN "wms_outbiz"."auto_outbiz_yn" IS '자동출하_유무';

-- IF_장치_코드
COMMENT ON COLUMN "wms_outbiz"."if_device_cd" IS 'IF_장치_코드';

-- 출하중단_유무
COMMENT ON COLUMN "wms_outbiz"."outbiz_stop_yn" IS '출하중단_유무';

-- 영업_담당자_명
COMMENT ON COLUMN "wms_outbiz"."sales_user_nm" IS '영업_담당자_아이디(ERP)';

-- 영업_부서_명
COMMENT ON COLUMN "wms_outbiz"."sales_dept_nm" IS '영업_부서_명';

-- 예정_연월일(출하)
COMMENT ON COLUMN "wms_outbiz"."req_ymd" IS '출고_요청_일자';

-- 예정_시분초(출하)
COMMENT ON COLUMN "wms_outbiz"."req_hms" IS '출고_요청_시간';

-- 요청_사용자_명(출하)
COMMENT ON COLUMN "wms_outbiz"."req_user_nm" IS '출고_요청자_아이디';

-- 주문처_ID
COMMENT ON COLUMN "wms_outbiz"."cont_seq" IS '주문처_코드(ERP)';

-- 주문_연월일
COMMENT ON COLUMN "wms_outbiz"."so_ymd" IS '출하_예정_일자(ERP)';

-- 주문_시분초
COMMENT ON COLUMN "wms_outbiz"."so_hms" IS '출하_예정_시간(ERP)';

-- 주문_번호
COMMENT ON COLUMN "wms_outbiz"."so_no" IS '주문_번호';

-- 문서_번호(타시스템)
COMMENT ON COLUMN "wms_outbiz"."req_no" IS '증빙번호';

-- 출하처_CODE(타시스템)
COMMENT ON COLUMN "wms_outbiz"."erp_wh_cd" IS '출하처_CODE(타시스템)';

-- 납품처_명
COMMENT ON COLUMN "wms_outbiz"."delivery_nm" IS '영업_담당자_아이디(ERP)';

-- 납품_연월일
COMMENT ON COLUMN "wms_outbiz"."delivery_ymd" IS '납품_연월일';

-- 납품_시분초
COMMENT ON COLUMN "wms_outbiz"."delivery_hms" IS '납품_시분초';

-- 납품처_담당자_명
COMMENT ON COLUMN "wms_outbiz"."delivery_mng_nm" IS '납품처_담당자_명';

-- 납품처_전화번호
COMMENT ON COLUMN "wms_outbiz"."delivery_tel" IS '납품처_전화번호';

-- 납품처_주소
COMMENT ON COLUMN "wms_outbiz"."delivery_addr" IS '납품처_주소';

-- 납품처_주소_상세
COMMENT ON COLUMN "wms_outbiz"."delivery_addr_dtl" IS '납품처_주소_상세';

-- 주문자_명
COMMENT ON COLUMN "wms_outbiz"."ord_nm" IS '주문자_명';

-- 받는자_명
COMMENT ON COLUMN "wms_outbiz"."rcv_nm" IS '받는자_명';

-- 받는자_전화번호
COMMENT ON COLUMN "wms_outbiz"."rcv_tel" IS '받는자_전화번호';

-- 받는자_주소
COMMENT ON COLUMN "wms_outbiz"."rcv_addr" IS '받는자_주소';

-- 받는자_상세_주소
COMMENT ON COLUMN "wms_outbiz"."rcv_addr_dtl" IS '받는자_상세_주소';

-- 받는자_우편_번호
COMMENT ON COLUMN "wms_outbiz"."rcv_post_no" IS '받는자_우편_번호';

-- 보내는자_명
COMMENT ON COLUMN "wms_outbiz"."send_nm" IS '보내는자_명';

-- 보내는자_전화번호
COMMENT ON COLUMN "wms_outbiz"."send_tel" IS '보내는자_전화번호';

-- 송장_설정
COMMENT ON COLUMN "wms_outbiz"."invoice_info" IS '비고';

-- 확정_연월일(출하)
COMMENT ON COLUMN "wms_outbiz"."cfm_ymd" IS '출하_확정_일자';

-- 확정_시분초(출하)
COMMENT ON COLUMN "wms_outbiz"."cfm_hms" IS '출하_확정_시간';

-- 확정_자_ID(출하)
COMMENT ON COLUMN "wms_outbiz"."cfm_user_id" IS '출하_확인자_아이디';

-- 배송메세지
COMMENT ON COLUMN "wms_outbiz"."ship_msg" IS '배송메세지';

-- 입고_SEQ
COMMENT ON COLUMN "wms_outbiz"."inwh_seq" IS '입고_SEQ';

-- 택배사_설정
COMMENT ON COLUMN "wms_outbiz"."dlv_config_seq" IS '택배사_설정';

-- 비고
COMMENT ON COLUMN "wms_outbiz"."note" IS '비고';

-- IF_KEY
COMMENT ON COLUMN "wms_outbiz"."if_key" IS '발주내부_코드(ERP)';

-- IF_에러_일련번호
COMMENT ON COLUMN "wms_outbiz"."if_err_seq" IS 'IF_에러_일련번호';

-- IF_송신_여부
COMMENT ON COLUMN "wms_outbiz"."if_send_yn" IS 'ERP_송신_여부';

-- 삭제_여부
COMMENT ON COLUMN "wms_outbiz"."del_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "wms_outbiz"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_outbiz"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_outbiz"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_outbiz"."mod_dt" IS '수정일';

-- WMS_출하_PK
CREATE UNIQUE INDEX "wms_outbiz_PK"
	ON "wms_outbiz"
	( -- WMS_출하
		"outbiz_seq" ASC -- 출하_SEQ
	)
;
-- WMS_출하
ALTER TABLE "wms_outbiz"
	ADD CONSTRAINT "wms_outbiz_PK"
		 -- WMS_출하_PK
	PRIMARY KEY 
	USING INDEX "wms_outbiz_PK";

-- WMS_출하_PK
COMMENT ON CONSTRAINT "wms_outbiz_PK" ON "wms_outbiz" IS 'WMS_출하_PK';

-- WMS_출하_상차
CREATE TABLE "wms_outbiz_load"
(
	"load_seq"        int4          NOT NULL, -- 상차_SEQ
	"load_prod_seq"   bigint        NOT NULL, -- 상차_품목_SEQ
	"outbiz_seq"      int4          NOT NULL, -- 출하_SEQ
	"outbiz_prod_seq" bigint        NOT NULL, -- 출하_품목_SEQ
	"load_qty"        decimal(10,2) NOT NULL DEFAULT 0, -- 상차_수량
	"del_yn"          char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"          varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"          timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"          varchar(20)   NULL,     -- 수정_ID
	"mod_dt"          timestamp     NULL      -- 수정_일시
);

-- WMS_출하_상차
COMMENT ON TABLE "wms_outbiz_load" IS 'WMS_출하_상차';

-- 상차_SEQ
COMMENT ON COLUMN "wms_outbiz_load"."load_seq" IS '상차_SEQ';

-- 상차_품목_SEQ
COMMENT ON COLUMN "wms_outbiz_load"."load_prod_seq" IS '상차_품목_SEQ';

-- 출하_SEQ
COMMENT ON COLUMN "wms_outbiz_load"."outbiz_seq" IS '출하_SEQ';

-- 출하_품목_SEQ
COMMENT ON COLUMN "wms_outbiz_load"."outbiz_prod_seq" IS '출하_품목_SEQ';

-- 상차_수량
COMMENT ON COLUMN "wms_outbiz_load"."load_qty" IS '상차_수량';

-- 삭제_여부
COMMENT ON COLUMN "wms_outbiz_load"."del_yn" IS '삭제_여부';

-- 등록_ID
COMMENT ON COLUMN "wms_outbiz_load"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_outbiz_load"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_outbiz_load"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_outbiz_load"."mod_dt" IS '수정일';

-- WMS_출하_상차_PK
CREATE UNIQUE INDEX "wms_outbiz_load_PK"
	ON "wms_outbiz_load"
	( -- WMS_출하_상차
		"load_seq" ASC, -- 상차_SEQ
		"load_prod_seq" ASC, -- 상차_품목_SEQ
		"outbiz_seq" ASC, -- 출하_SEQ
		"outbiz_prod_seq" ASC -- 출하_품목_SEQ
	)
;
-- WMS_출하_상차
ALTER TABLE "wms_outbiz_load"
	ADD CONSTRAINT "wms_outbiz_load_PK"
		 -- WMS_출하_상차_PK
	PRIMARY KEY 
	USING INDEX "wms_outbiz_load_PK";

-- WMS_출하_상차_PK
COMMENT ON CONSTRAINT "wms_outbiz_load_PK" ON "wms_outbiz_load" IS 'WMS_출하_상차_PK';

-- WMS_출하_송장
CREATE TABLE "wms_outbiz_invoice"
(
	"outbiz_seq"       int4          NOT NULL, -- 출하_SEQ
	"outbiz_prod_seq"  bigint        NOT NULL, -- 출하_품목_SEQ
	"invoice_seq"      int4          NOT NULL, -- 송장_SEQ
	"invoice_prod_seq" bigint        NOT NULL, -- 송장_품목_SEQ
	"outbiz_req_qty"   decimal(10,2) NOT NULL DEFAULT 0, -- 출하_요청_수량
	"outbiz_ex_qty"    decimal(10,2) NOT NULL DEFAULT 0, -- 출하_처리_수량
	"del_yn"           char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"           varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"           timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"           varchar(20)   NULL,     -- 수정_ID
	"mod_dt"           timestamp     NULL      -- 수정_일시
);

-- WMS_출하_송장
COMMENT ON TABLE "wms_outbiz_invoice" IS 'WMS_출하_송장';

-- 출하_SEQ
COMMENT ON COLUMN "wms_outbiz_invoice"."outbiz_seq" IS '출하_SEQ';

-- 출하_품목_SEQ
COMMENT ON COLUMN "wms_outbiz_invoice"."outbiz_prod_seq" IS '출하_품목_SEQ';

-- 송장_SEQ
COMMENT ON COLUMN "wms_outbiz_invoice"."invoice_seq" IS '송장_SEQ';

-- 송장_품목_SEQ
COMMENT ON COLUMN "wms_outbiz_invoice"."invoice_prod_seq" IS '송장_품목_SEQ';

-- 출하_요청_수량
COMMENT ON COLUMN "wms_outbiz_invoice"."outbiz_req_qty" IS '출고_요청_수량';

-- 출하_처리_수량
COMMENT ON COLUMN "wms_outbiz_invoice"."outbiz_ex_qty" IS '출하_처리_수량';

-- 삭제_여부
COMMENT ON COLUMN "wms_outbiz_invoice"."del_yn" IS '삭제_여부';

-- 등록_ID
COMMENT ON COLUMN "wms_outbiz_invoice"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_outbiz_invoice"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_outbiz_invoice"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_outbiz_invoice"."mod_dt" IS '수정일';

-- WMS_출하_송장_PK
CREATE UNIQUE INDEX "wms_outbiz_invoice_PK"
	ON "wms_outbiz_invoice"
	( -- WMS_출하_송장
		"outbiz_seq" ASC, -- 출하_SEQ
		"outbiz_prod_seq" ASC, -- 출하_품목_SEQ
		"invoice_seq" ASC, -- 송장_SEQ
		"invoice_prod_seq" ASC -- 송장_품목_SEQ
	)
;
-- WMS_출하_송장
ALTER TABLE "wms_outbiz_invoice"
	ADD CONSTRAINT "wms_outbiz_invoice_PK"
		 -- WMS_출하_송장_PK
	PRIMARY KEY 
	USING INDEX "wms_outbiz_invoice_PK";

-- WMS_출하_송장_PK
COMMENT ON CONSTRAINT "wms_outbiz_invoice_PK" ON "wms_outbiz_invoice" IS 'WMS_출하_송장_PK';

-- WMS_출하_처리
CREATE TABLE "wms_outbiz_tran"
(
	"outbiz_tran_seq" bigint        NOT NULL DEFAULT nextval('wms_outbiz_tran_seq'), -- 출하_처리_SEQ
	"outbiz_prod_seq" bigint        NOT NULL, -- 출하_품목_SEQ
	"outbiz_seq"      int4          NOT NULL, -- 출하_SEQ
	"prod_seq"        int4          NOT NULL, -- 품목_SEQ
	"sku1"            varchar(100)  NOT NULL, -- SKU1
	"sku2"            varchar(100)  NOT NULL, -- SKU2
	"mng_ymd"         varchar(8)    NULL,     -- 입고/제조일자
	"exp_ymd"         varchar(8)    NULL,     -- 유통기한_연월일
	"lot_no"          varchar(30)   NULL,     -- LOT_번호
	"fr_wh_seq"       int4          NULL,     -- FR_창고_SEQ
	"fr_loc_seq"      bigint        NULL,     -- FR_위치_SEQ
	"proc_qty"        decimal(10,2) NOT NULL DEFAULT 0, -- 처리_수량(출하)
	"ex_qty"          decimal(10,2) NOT NULL DEFAULT 0, -- 기처리_수량(출하)
	"to_wh_seq"       int4          NULL,     -- TO_창고_SEQ
	"to_loc_seq"      bigint        NULL,     -- TO_위치_SEQ
	"proc_bundle_no"  varchar(30)   NULL,     -- 처리_묶음_번호
	"proc_ymd"        varchar(8)    NULL,     -- 처리_연월일(출고)
	"proc_hms"        varchar(6)    NULL,     -- 처리_시분초(출고)
	"proc_user_id"    varchar(20)   NULL,     -- 처리_자_ID(출고)
	"group_outwh_no"  varchar(30)   NULL,     -- 그룹_출고_번호
	"invoice_seq"     int4          NULL,     -- 송장_SEQ
	"if_err_seq"      int4          NULL,     -- IF_에러_일련번호
	"if_send_yn"      char(1)       NOT NULL DEFAULT 'N', -- IF_송신_여부
	"del_yn"          char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"          varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"          timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"          varchar(20)   NULL,     -- 수정_ID
	"mod_dt"          timestamp     NULL      -- 수정_일시
);

-- WMS_출하_처리
COMMENT ON TABLE "wms_outbiz_tran" IS 'WMS_출하_처리';

-- 출하_처리_SEQ
COMMENT ON COLUMN "wms_outbiz_tran"."outbiz_tran_seq" IS '출하_처리_SEQ';

-- 출하_품목_SEQ
COMMENT ON COLUMN "wms_outbiz_tran"."outbiz_prod_seq" IS '출하_품목_SEQ';

-- 출하_SEQ
COMMENT ON COLUMN "wms_outbiz_tran"."outbiz_seq" IS '출하_SEQ';

-- 품목_SEQ
COMMENT ON COLUMN "wms_outbiz_tran"."prod_seq" IS '품목ID';

-- SKU1
COMMENT ON COLUMN "wms_outbiz_tran"."sku1" IS 'SKU1';

-- SKU2
COMMENT ON COLUMN "wms_outbiz_tran"."sku2" IS 'SKU2';

-- 입고/제조일자
COMMENT ON COLUMN "wms_outbiz_tran"."mng_ymd" IS '입고/제조일자';

-- 유통기한_연월일
COMMENT ON COLUMN "wms_outbiz_tran"."exp_ymd" IS '유통기한_연월일';

-- LOT_번호
COMMENT ON COLUMN "wms_outbiz_tran"."lot_no" IS 'LOT_번호';

-- FR_창고_SEQ
COMMENT ON COLUMN "wms_outbiz_tran"."fr_wh_seq" IS '창고(FR)';

-- FR_위치_SEQ
COMMENT ON COLUMN "wms_outbiz_tran"."fr_loc_seq" IS '위치(FR)';

-- 처리_수량(출하)
COMMENT ON COLUMN "wms_outbiz_tran"."proc_qty" IS '출고_수량';

-- 기처리_수량(출하)
COMMENT ON COLUMN "wms_outbiz_tran"."ex_qty" IS '출고_수량';

-- TO_창고_SEQ
COMMENT ON COLUMN "wms_outbiz_tran"."to_wh_seq" IS '창고(TO)';

-- TO_위치_SEQ
COMMENT ON COLUMN "wms_outbiz_tran"."to_loc_seq" IS '위치(TO)';

-- 처리_묶음_번호
COMMENT ON COLUMN "wms_outbiz_tran"."proc_bundle_no" IS '처리_묶음_번호';

-- 처리_연월일(출고)
COMMENT ON COLUMN "wms_outbiz_tran"."proc_ymd" IS '입고_일자';

-- 처리_시분초(출고)
COMMENT ON COLUMN "wms_outbiz_tran"."proc_hms" IS '입고_시간';

-- 처리_자_ID(출고)
COMMENT ON COLUMN "wms_outbiz_tran"."proc_user_id" IS '입고_작업자_아이디';

-- 그룹_출고_번호
COMMENT ON COLUMN "wms_outbiz_tran"."group_outwh_no" IS '그룹_출고_번호';

-- 송장_SEQ
COMMENT ON COLUMN "wms_outbiz_tran"."invoice_seq" IS '송장_SEQ';

-- IF_에러_일련번호
COMMENT ON COLUMN "wms_outbiz_tran"."if_err_seq" IS 'IF_에러_일련번호';

-- IF_송신_여부
COMMENT ON COLUMN "wms_outbiz_tran"."if_send_yn" IS 'ERP_송신_여부';

-- 삭제_여부
COMMENT ON COLUMN "wms_outbiz_tran"."del_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "wms_outbiz_tran"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_outbiz_tran"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_outbiz_tran"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_outbiz_tran"."mod_dt" IS '수정일';

-- WMS_출하_처리 유니크 인덱스
CREATE UNIQUE INDEX "UIX_wms_outbiz_tran"
	ON "wms_outbiz_tran"
	( -- WMS_출하_처리
		"outbiz_tran_seq" ASC -- 출하_처리_SEQ
	);

-- WMS_출하_처리 유니크 인덱스
COMMENT ON INDEX "UIX_wms_outbiz_tran" IS 'WMS_출하_처리 유니크 인덱스';

-- WMS_출하_처리_PK
CREATE UNIQUE INDEX "wms_outbiz_tran_PK"
	ON "wms_outbiz_tran"
	( -- WMS_출하_처리
		"outbiz_tran_seq" ASC, -- 출하_처리_SEQ
		"outbiz_prod_seq" ASC, -- 출하_품목_SEQ
		"outbiz_seq" ASC -- 출하_SEQ
	)
;
-- WMS_출하_처리
ALTER TABLE "wms_outbiz_tran"
	ADD CONSTRAINT "wms_outbiz_tran_PK"
		 -- WMS_출하_처리_PK
	PRIMARY KEY 
	USING INDEX "wms_outbiz_tran_PK";

-- WMS_출하_처리_PK
COMMENT ON CONSTRAINT "wms_outbiz_tran_PK" ON "wms_outbiz_tran" IS 'WMS_출하_처리_PK';

-- WMS_출하_처리
ALTER TABLE "wms_outbiz_tran"
	ADD CONSTRAINT "UK_wms_outbiz_tran" -- WMS_출하_처리 유니크 제약
	UNIQUE 
	USING INDEX "UIX_wms_outbiz_tran";

-- WMS_출하_처리 유니크 제약
COMMENT ON CONSTRAINT "UK_wms_outbiz_tran" ON "wms_outbiz_tran" IS 'WMS_출하_처리 유니크 제약';

-- WMS_출하_출고
CREATE TABLE "wms_outbiz_outwh"
(
	"outbiz_seq"      int4          NOT NULL, -- 출하_SEQ
	"outbiz_prod_seq" bigint        NOT NULL, -- 출하_품목_SEQ
	"outwh_seq"       int4          NOT NULL, -- 출고_SEQ
	"outwh_prod_seq"  bigint        NOT NULL, -- 출고_품목_SEQ
	"prod_seq"        int4          NOT NULL, -- 품목_SEQ
	"outwh_req_qty"   decimal(10,2) NOT NULL DEFAULT 0, -- 출고_요청_수량
	"del_yn"          char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"          varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"          timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"          varchar(20)   NULL,     -- 수정_ID
	"mod_dt"          timestamp     NULL      -- 수정_일시
);

-- WMS_출하_출고
COMMENT ON TABLE "wms_outbiz_outwh" IS 'WMS_출하_출고';

-- 출하_SEQ
COMMENT ON COLUMN "wms_outbiz_outwh"."outbiz_seq" IS '출하_SEQ';

-- 출하_품목_SEQ
COMMENT ON COLUMN "wms_outbiz_outwh"."outbiz_prod_seq" IS '출하_품목_SEQ';

-- 출고_SEQ
COMMENT ON COLUMN "wms_outbiz_outwh"."outwh_seq" IS '출고_SEQ';

-- 출고_품목_SEQ
COMMENT ON COLUMN "wms_outbiz_outwh"."outwh_prod_seq" IS '출고_품목_SEQ';

-- 품목_SEQ
COMMENT ON COLUMN "wms_outbiz_outwh"."prod_seq" IS '품목_SEQ';

-- 출고_요청_수량
COMMENT ON COLUMN "wms_outbiz_outwh"."outwh_req_qty" IS '출고_요청_수량';

-- 삭제_여부
COMMENT ON COLUMN "wms_outbiz_outwh"."del_yn" IS '삭제_여부';

-- 등록_ID
COMMENT ON COLUMN "wms_outbiz_outwh"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_outbiz_outwh"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_outbiz_outwh"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_outbiz_outwh"."mod_dt" IS '수정일';

-- WMS_출하_출고_PK
CREATE UNIQUE INDEX "wms_outbiz_outwh_PK"
	ON "wms_outbiz_outwh"
	( -- WMS_출하_출고
		"outbiz_seq" ASC, -- 출하_SEQ
		"outbiz_prod_seq" ASC, -- 출하_품목_SEQ
		"outwh_seq" ASC, -- 출고_SEQ
		"outwh_prod_seq" ASC -- 출고_품목_SEQ
	)
;
-- WMS_출하_출고
ALTER TABLE "wms_outbiz_outwh"
	ADD CONSTRAINT "wms_outbiz_outwh_PK"
		 -- WMS_출하_출고_PK
	PRIMARY KEY 
	USING INDEX "wms_outbiz_outwh_PK";

-- WMS_출하_출고_PK
COMMENT ON CONSTRAINT "wms_outbiz_outwh_PK" ON "wms_outbiz_outwh" IS 'WMS_출하_출고_PK';

-- WMS_출하_품목
CREATE TABLE "wms_outbiz_prod"
(
	"outbiz_prod_seq"    bigint        NOT NULL DEFAULT nextval('wms_outbiz_prod_seq'), -- 출하_품목_SEQ
	"outbiz_seq"         int4          NOT NULL, -- 출하_SEQ
	"prod_seq"           int4          NOT NULL, -- 품목_SEQ
	"outbiz_prod_sts_cd" varchar(50)   NOT NULL, -- 출하_품목_상태_코드
	"req_qty"            decimal(10,2) NOT NULL DEFAULT 0, -- 요청_수량(출하)
	"ex_qty"             decimal(10,2) NOT NULL DEFAULT 0, -- 기처리_수량(출하)
	"est_mng_ymd"        varchar(8)    NULL,     -- 예상_입고/제조일자
	"est_exp_ymd"        varchar(8)    NULL,     -- 예상_유통기한
	"est_lot_no"         varchar(30)   NULL,     -- 예상_LOT_NO
	"est_cn"             varchar(1000) NULL,     -- 예상_CN
	"if_send_yn"         char(1)       NOT NULL DEFAULT 'N', -- IF_송신_여부
	"if_idx"             varchar(20)   NULL,     -- IF_내부순번
	"if_err_seq"         int4          NULL,     -- IF_에러_일련번호
	"del_yn"             char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"             varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"             timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"             varchar(20)   NULL,     -- 수정_ID
	"mod_dt"             timestamp     NULL      -- 수정_일시
);

-- WMS_출하_품목
COMMENT ON TABLE "wms_outbiz_prod" IS 'WMS_출하_품목';

-- 출하_품목_SEQ
COMMENT ON COLUMN "wms_outbiz_prod"."outbiz_prod_seq" IS '출하_품목_SEQ';

-- 출하_SEQ
COMMENT ON COLUMN "wms_outbiz_prod"."outbiz_seq" IS '출하_SEQ';

-- 품목_SEQ
COMMENT ON COLUMN "wms_outbiz_prod"."prod_seq" IS '품목ID';

-- 출하_품목_상태_코드
COMMENT ON COLUMN "wms_outbiz_prod"."outbiz_prod_sts_cd" IS '출하_상태_코드';

-- 요청_수량(출하)
COMMENT ON COLUMN "wms_outbiz_prod"."req_qty" IS '출하_요청_수량';

-- 기처리_수량(출하)
COMMENT ON COLUMN "wms_outbiz_prod"."ex_qty" IS '기_출하_수량';

-- 예상_입고/제조일자
COMMENT ON COLUMN "wms_outbiz_prod"."est_mng_ymd" IS '예상_입고/제조일자';

-- 예상_유통기한
COMMENT ON COLUMN "wms_outbiz_prod"."est_exp_ymd" IS '예상_유통기한';

-- 예상_LOT_NO
COMMENT ON COLUMN "wms_outbiz_prod"."est_lot_no" IS '예상_LOT_NO';

-- 예상_CN
COMMENT ON COLUMN "wms_outbiz_prod"."est_cn" IS '예상_CN';

-- IF_송신_여부
COMMENT ON COLUMN "wms_outbiz_prod"."if_send_yn" IS 'ERP_송신_여부';

-- IF_내부순번
COMMENT ON COLUMN "wms_outbiz_prod"."if_idx" IS '순번 --';

-- IF_에러_일련번호
COMMENT ON COLUMN "wms_outbiz_prod"."if_err_seq" IS 'IF_에러_일련번호';

-- 삭제_여부
COMMENT ON COLUMN "wms_outbiz_prod"."del_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "wms_outbiz_prod"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_outbiz_prod"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_outbiz_prod"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_outbiz_prod"."mod_dt" IS '수정일';

-- WMS_출하_품목_PK
CREATE UNIQUE INDEX "wms_outbiz_prod_PK"
	ON "wms_outbiz_prod"
	( -- WMS_출하_품목
		"outbiz_prod_seq" ASC, -- 출하_품목_SEQ
		"outbiz_seq" ASC -- 출하_SEQ
	)
;
-- WMS_출하_품목
ALTER TABLE "wms_outbiz_prod"
	ADD CONSTRAINT "wms_outbiz_prod_PK"
		 -- WMS_출하_품목_PK
	PRIMARY KEY 
	USING INDEX "wms_outbiz_prod_PK";

-- WMS_출하_품목_PK
COMMENT ON CONSTRAINT "wms_outbiz_prod_PK" ON "wms_outbiz_prod" IS 'WMS_출하_품목_PK';

-- WMS_품목전환
CREATE TABLE "wms_inven_rp"
(
	"rp_seq"      int4          NOT NULL DEFAULT nextval('wms_inven_rp_seq'), -- 품목전환_SEQ
	"biz_seq"     int4          NOT NULL, -- 사업장_SEQ
	"rp_no"       varchar(30)   NOT NULL, -- 품목전환_번호
	"center_seq"  int4          NOT NULL, -- 센터_SEQ
	"rp_type_cd"  varchar(50)   NOT NULL, -- 품목전환_유형_코드
	"rp_sts_cd"   varchar(50)   NOT NULL, -- 품목전환_상태_코드
	"req_ymd"     varchar(8)    NOT NULL, -- 예정_연월일(품목전환)
	"req_hms"     varchar(6)    NULL,     -- 예정_시분초(품목전환)
	"req_user_nm" varchar(100)  NULL,     -- 요청_사용자_명(품목전환)
	"req_dept_nm" varchar(100)  NULL,     -- 요청_부서_명
	"note"        varchar(1000) NULL,     -- 비고
	"if_key"      varchar(50)   NULL,     -- IF_KEY
	"if_err_seq"  int4          NULL,     -- IF_에러_일련번호
	"if_send_yn"  char(1)       NOT NULL DEFAULT 'N', -- IF_송신_여부
	"del_yn"      char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"      varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"      timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"      varchar(20)   NULL,     -- 수정_ID
	"mod_dt"      timestamp     NULL      -- 수정_일시
);

-- WMS_품목전환
COMMENT ON TABLE "wms_inven_rp" IS 'WMS_품목전환';

-- 품목전환_SEQ
COMMENT ON COLUMN "wms_inven_rp"."rp_seq" IS '재고이동요청번호';

-- 사업장_SEQ
COMMENT ON COLUMN "wms_inven_rp"."biz_seq" IS '사업장_ID';

-- 품목전환_번호
COMMENT ON COLUMN "wms_inven_rp"."rp_no" IS '재고이동요청번호';

-- 센터_SEQ
COMMENT ON COLUMN "wms_inven_rp"."center_seq" IS '센터_SEQ';

-- 품목전환_유형_코드
COMMENT ON COLUMN "wms_inven_rp"."rp_type_cd" IS '재고_이동_유형_코드';

-- 품목전환_상태_코드
COMMENT ON COLUMN "wms_inven_rp"."rp_sts_cd" IS '처리_상태_코드';

-- 예정_연월일(품목전환)
COMMENT ON COLUMN "wms_inven_rp"."req_ymd" IS '입고_요청_일자';

-- 예정_시분초(품목전환)
COMMENT ON COLUMN "wms_inven_rp"."req_hms" IS '입고_요청_시간';

-- 요청_사용자_명(품목전환)
COMMENT ON COLUMN "wms_inven_rp"."req_user_nm" IS '입고_요청자_아이디';

-- 요청_부서_명
COMMENT ON COLUMN "wms_inven_rp"."req_dept_nm" IS '요청_부서_명';

-- 비고
COMMENT ON COLUMN "wms_inven_rp"."note" IS '비고';

-- IF_KEY
COMMENT ON COLUMN "wms_inven_rp"."if_key" IS '발주내부_코드(ERP)';

-- IF_에러_일련번호
COMMENT ON COLUMN "wms_inven_rp"."if_err_seq" IS 'IF_에러_일련번호';

-- IF_송신_여부
COMMENT ON COLUMN "wms_inven_rp"."if_send_yn" IS 'ERP_송신_여부';

-- 삭제_여부
COMMENT ON COLUMN "wms_inven_rp"."del_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "wms_inven_rp"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_inven_rp"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_inven_rp"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_inven_rp"."mod_dt" IS '수정일';

-- WMS_품목전환_PK
CREATE UNIQUE INDEX "wms_inven_rp_PK"
	ON "wms_inven_rp"
	( -- WMS_품목전환
		"rp_seq" ASC -- 품목전환_SEQ
	)
;
-- WMS_품목전환
ALTER TABLE "wms_inven_rp"
	ADD CONSTRAINT "wms_inven_rp_PK"
		 -- WMS_품목전환_PK
	PRIMARY KEY 
	USING INDEX "wms_inven_rp_PK";

-- WMS_품목전환_PK
COMMENT ON CONSTRAINT "wms_inven_rp_PK" ON "wms_inven_rp" IS 'WMS_품목전환_PK';

-- WMS_품목전환_처리
CREATE TABLE "wms_inven_rp_tran"
(
	"rp_tran_seq"    bigint        NOT NULL DEFAULT nextval('wms_inven_rp_tran_seq'), -- 품목전환_처리_SEQ
	"rp_prod_seq"    bigint        NOT NULL, -- 품목전환_품목_SEQ
	"rp_seq"         int4          NOT NULL, -- 품목전환_SEQ
	"st_yn"          char(1)       NOT NULL DEFAULT 'N', -- 기준품목_여부
	"prod_seq"       int4          NOT NULL, -- 품목_SEQ
	"wh_seq"         int4          NOT NULL, -- 창고_SEQ
	"loc_seq"        bigint        NOT NULL, -- 위치_SEQ
	"sku1"           varchar(100)  NOT NULL, -- SKU1
	"sku2"           varchar(100)  NOT NULL, -- SKU2
	"proc_qty"       decimal(10,2) NOT NULL DEFAULT 0, -- 처리_수량
	"lot_no"         varchar(30)   NULL,     -- LOT_번호
	"proc_bundle_no" varchar(30)   NULL,     -- 처리_묶음_번호
	"proc_ymd"       varchar(8)    NOT NULL, -- 처리_연월일(품목전환)
	"proc_hms"       varchar(6)    NOT NULL, -- 처리_시분초(품목전환)
	"proc_user_id"   varchar(20)   NOT NULL, -- 처리_자_ID(품목전환)
	"if_send_yn"     char(1)       NOT NULL DEFAULT 'N', -- IF_송신_여부
	"if_err_seq"     int4          NULL,     -- IF_에러_일련번호
	"del_yn"         char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"         varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"         timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"         varchar(20)   NULL,     -- 수정_ID
	"mod_dt"         timestamp     NULL      -- 수정_일시
);

-- WMS_품목전환_처리
COMMENT ON TABLE "wms_inven_rp_tran" IS 'WMS_품목전환_처리';

-- 품목전환_처리_SEQ
COMMENT ON COLUMN "wms_inven_rp_tran"."rp_tran_seq" IS '품목전환_처리_SEQ';

-- 품목전환_품목_SEQ
COMMENT ON COLUMN "wms_inven_rp_tran"."rp_prod_seq" IS '품목전환_품목_SEQ';

-- 품목전환_SEQ
COMMENT ON COLUMN "wms_inven_rp_tran"."rp_seq" IS '품목전환_SEQ';

-- 기준품목_여부
COMMENT ON COLUMN "wms_inven_rp_tran"."st_yn" IS '품목ID';

-- 품목_SEQ
COMMENT ON COLUMN "wms_inven_rp_tran"."prod_seq" IS '예외출고_요청_수량';

-- 창고_SEQ
COMMENT ON COLUMN "wms_inven_rp_tran"."wh_seq" IS '창고(FR)';

-- 위치_SEQ
COMMENT ON COLUMN "wms_inven_rp_tran"."loc_seq" IS '위치(FR)';

-- SKU1
COMMENT ON COLUMN "wms_inven_rp_tran"."sku1" IS 'SKU1(FR)';

-- SKU2
COMMENT ON COLUMN "wms_inven_rp_tran"."sku2" IS 'SKU2(FR)';

-- 처리_수량
COMMENT ON COLUMN "wms_inven_rp_tran"."proc_qty" IS '요청수량';

-- LOT_번호
COMMENT ON COLUMN "wms_inven_rp_tran"."lot_no" IS 'LOT_번호';

-- 처리_묶음_번호
COMMENT ON COLUMN "wms_inven_rp_tran"."proc_bundle_no" IS '문서번호';

-- 처리_연월일(품목전환)
COMMENT ON COLUMN "wms_inven_rp_tran"."proc_ymd" IS '입고_일자';

-- 처리_시분초(품목전환)
COMMENT ON COLUMN "wms_inven_rp_tran"."proc_hms" IS '입고_시간';

-- 처리_자_ID(품목전환)
COMMENT ON COLUMN "wms_inven_rp_tran"."proc_user_id" IS '입고_작업자_아이디';

-- IF_송신_여부
COMMENT ON COLUMN "wms_inven_rp_tran"."if_send_yn" IS 'ERP_송신_여부';

-- IF_에러_일련번호
COMMENT ON COLUMN "wms_inven_rp_tran"."if_err_seq" IS 'IF_에러_일련번호';

-- 삭제_여부
COMMENT ON COLUMN "wms_inven_rp_tran"."del_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "wms_inven_rp_tran"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_inven_rp_tran"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_inven_rp_tran"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_inven_rp_tran"."mod_dt" IS '수정일';

-- WMS_품목전환_처리_PK
CREATE UNIQUE INDEX "wms_inven_rp_tran_PK"
	ON "wms_inven_rp_tran"
	( -- WMS_품목전환_처리
		"rp_tran_seq" ASC, -- 품목전환_처리_SEQ
		"rp_prod_seq" ASC, -- 품목전환_품목_SEQ
		"rp_seq" ASC -- 품목전환_SEQ
	)
;
-- WMS_품목전환_처리
ALTER TABLE "wms_inven_rp_tran"
	ADD CONSTRAINT "wms_inven_rp_tran_PK"
		 -- WMS_품목전환_처리_PK
	PRIMARY KEY 
	USING INDEX "wms_inven_rp_tran_PK";

-- WMS_품목전환_처리_PK
COMMENT ON CONSTRAINT "wms_inven_rp_tran_PK" ON "wms_inven_rp_tran" IS 'WMS_품목전환_처리_PK';

-- WMS_품목전환_품목
CREATE TABLE "wms_inven_rp_prod"
(
	"rp_prod_seq"    bigint        NOT NULL DEFAULT nextval('wms_inven_rp_prod_seq'), -- 품목전환_품목_SEQ
	"rp_seq"         int4          NOT NULL, -- 품목전환_SEQ
	"rp_prod_sts_cd" varchar(50)   NOT NULL, -- 품목전환_품목_상태_코드
	"st_yn"          char(1)       NOT NULL DEFAULT 'N', -- 기준품목_여부
	"prod_seq"       int4          NOT NULL, -- 품목_SEQ
	"req_qty"        decimal(10,2) NOT NULL DEFAULT 0, -- 요청_수량(품목전환)
	"est_exp_ymd"    varchar(8)    NULL,     -- 예상_유통기한
	"est_mng_ymd"    varchar(8)    NULL,     -- 예상_입고/제조일자
	"est_lot_no"     varchar(30)   NULL,     -- 예상_LOT_NO
	"if_idx"         varchar(20)   NULL,     -- IF_내부순번
	"if_err_seq"     int4          NULL,     -- IF_에러_일련번호
	"if_send_yn"     char(1)       NOT NULL DEFAULT 'N', -- IF_송신_여부
	"del_yn"         char(1)       NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"         varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"         timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"         varchar(20)   NULL,     -- 수정_ID
	"mod_dt"         timestamp     NULL      -- 수정_일시
);

-- WMS_품목전환_품목
COMMENT ON TABLE "wms_inven_rp_prod" IS 'WMS_품목전환_품목';

-- 품목전환_품목_SEQ
COMMENT ON COLUMN "wms_inven_rp_prod"."rp_prod_seq" IS '품목전환_품목_SEQ';

-- 품목전환_SEQ
COMMENT ON COLUMN "wms_inven_rp_prod"."rp_seq" IS '품목전환_SEQ';

-- 품목전환_품목_상태_코드
COMMENT ON COLUMN "wms_inven_rp_prod"."rp_prod_sts_cd" IS '처리_상태_코드';

-- 기준품목_여부
COMMENT ON COLUMN "wms_inven_rp_prod"."st_yn" IS '품목ID';

-- 품목_SEQ
COMMENT ON COLUMN "wms_inven_rp_prod"."prod_seq" IS '예외출고_요청_수량';

-- 요청_수량(품목전환)
COMMENT ON COLUMN "wms_inven_rp_prod"."req_qty" IS '품목ID';

-- 예상_유통기한
COMMENT ON COLUMN "wms_inven_rp_prod"."est_exp_ymd" IS '예상_유통기한';

-- 예상_입고/제조일자
COMMENT ON COLUMN "wms_inven_rp_prod"."est_mng_ymd" IS '예상_입고/제조일자';

-- 예상_LOT_NO
COMMENT ON COLUMN "wms_inven_rp_prod"."est_lot_no" IS '예상_LOT_NO';

-- IF_내부순번
COMMENT ON COLUMN "wms_inven_rp_prod"."if_idx" IS '순번 --';

-- IF_에러_일련번호
COMMENT ON COLUMN "wms_inven_rp_prod"."if_err_seq" IS 'IF_에러_일련번호';

-- IF_송신_여부
COMMENT ON COLUMN "wms_inven_rp_prod"."if_send_yn" IS 'ERP_송신_여부';

-- 삭제_여부
COMMENT ON COLUMN "wms_inven_rp_prod"."del_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "wms_inven_rp_prod"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "wms_inven_rp_prod"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "wms_inven_rp_prod"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "wms_inven_rp_prod"."mod_dt" IS '수정일';

-- WMS_품목전환_품목_PK
CREATE UNIQUE INDEX "wms_inven_rp_prod_PK"
	ON "wms_inven_rp_prod"
	( -- WMS_품목전환_품목
		"rp_prod_seq" ASC, -- 품목전환_품목_SEQ
		"rp_seq" ASC -- 품목전환_SEQ
	)
;
-- WMS_품목전환_품목
ALTER TABLE "wms_inven_rp_prod"
	ADD CONSTRAINT "wms_inven_rp_prod_PK"
		 -- WMS_품목전환_품목_PK
	PRIMARY KEY 
	USING INDEX "wms_inven_rp_prod_PK";

-- WMS_품목전환_품목_PK
COMMENT ON CONSTRAINT "wms_inven_rp_prod_PK" ON "wms_inven_rp_prod" IS 'WMS_품목전환_품목_PK';

-- 시스템_게시판
CREATE TABLE "sm_board"
(
	"board_seq"        bigint       NOT NULL DEFAULT nextval('sm_board_seq'), -- 게시글SEQ
	"board_type_cd"    varchar(50)  NOT NULL, -- 게시판_유형_코드
	"board_cat_cd"     varchar(50)  NULL,     -- 게시판_카테고리_코드
	"board_cat_dtl_cd" varchar(50)  NULL,     -- 게시판_카테고리_상세_코드
	"title"            varchar(100) NULL,     -- 제목
	"contents"         text         NULL,     -- 내용
	"board_yn"         char(1)      NULL     DEFAULT 'N', -- 게시글_여부
	"top_board_seq"    bigint       NULL,     -- 부모_게시글SEQ
	"reply_cnt"        int4         NULL     DEFAULT 0, -- 답글 수
	"view_cnt"         int4         NULL     DEFAULT 0, -- 조회 수
	"file_seq"         int4         NULL,     -- 파일_SEQ(게시판)
	"disp_no"          int2         NOT NULL DEFAULT 1, -- 표시_순서
	"board_pwd"        varchar(500) NULL,     -- 비밀번호
	"disp_yn"          char(1)      NULL     DEFAULT 'N', -- 공개_여부
	"start_ymd"        varchar(8)   NULL,     -- 시작_연월일(게시)
	"end_ymd"          varchar(8)   NULL,     -- 종료_연월일(게시)
	"del_yn"           char(1)      NOT NULL DEFAULT 'N', -- 삭제_여부
	"reg_id"           varchar(20)  NOT NULL, -- 등록_ID
	"reg_dt"           timestamp    NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"           varchar(20)  NULL,     -- 수정_ID
	"mod_dt"           timestamp    NULL      -- 수정_일시
);

-- 시스템_게시판
COMMENT ON TABLE "sm_board" IS '시스템_게시판';

-- 게시글SEQ
COMMENT ON COLUMN "sm_board"."board_seq" IS '게시글SEQ';

-- 게시판_유형_코드
COMMENT ON COLUMN "sm_board"."board_type_cd" IS '게시판_유형_코드';

-- 게시판_카테고리_코드
COMMENT ON COLUMN "sm_board"."board_cat_cd" IS '게시판_카테고리_코드';

-- 게시판_카테고리_상세_코드
COMMENT ON COLUMN "sm_board"."board_cat_dtl_cd" IS '게시판_카테고리_상세_코드';

-- 제목
COMMENT ON COLUMN "sm_board"."title" IS '제목';

-- 내용
COMMENT ON COLUMN "sm_board"."contents" IS '내용';

-- 게시글_여부
COMMENT ON COLUMN "sm_board"."board_yn" IS '게시글_여부';

-- 부모_게시글SEQ
COMMENT ON COLUMN "sm_board"."top_board_seq" IS '부모_게시글SEQ';

-- 답글 수
COMMENT ON COLUMN "sm_board"."reply_cnt" IS '답글 수';

-- 조회 수
COMMENT ON COLUMN "sm_board"."view_cnt" IS '조회 수';

-- 파일_SEQ(게시판)
COMMENT ON COLUMN "sm_board"."file_seq" IS '파일_SEQ(게시판)';

-- 표시_순서
COMMENT ON COLUMN "sm_board"."disp_no" IS '順番';

-- 비밀번호
COMMENT ON COLUMN "sm_board"."board_pwd" IS '비밀번호';

-- 공개_여부
COMMENT ON COLUMN "sm_board"."disp_yn" IS '공개_여부';

-- 시작_연월일(게시)
COMMENT ON COLUMN "sm_board"."start_ymd" IS '시작_연월일(게시)';

-- 종료_연월일(게시)
COMMENT ON COLUMN "sm_board"."end_ymd" IS '종료_연월일(게시)';

-- 삭제_여부
COMMENT ON COLUMN "sm_board"."del_yn" IS '삭제_여부';

-- 등록_ID
COMMENT ON COLUMN "sm_board"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "sm_board"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "sm_board"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "sm_board"."mod_dt" IS '수정일';

-- 시스템_게시판_PK
CREATE UNIQUE INDEX "sm_board_PK"
	ON "sm_board"
	( -- 시스템_게시판
		"board_seq" ASC -- 게시글SEQ
	)
;
-- 시스템_게시판
ALTER TABLE "sm_board"
	ADD CONSTRAINT "sm_board_PK"
		 -- 시스템_게시판_PK
	PRIMARY KEY 
	USING INDEX "sm_board_PK";

-- 시스템_게시판_PK
COMMENT ON CONSTRAINT "sm_board_PK" ON "sm_board" IS '시스템_게시판_PK';

-- 시스템_공통코드
CREATE TABLE "sm_comm_h"
(
	"biz_seq"      int4         NOT NULL, -- 사업장_SEQ
	"comm_h_cd"    varchar(50)  NOT NULL, -- 상위_코드
	"comm_h_nm"    varchar(100) NOT NULL, -- 상위_코드_명
	"user_cd_yn"   char(1)      NOT NULL DEFAULT 'N', -- 사용자_코드_여부
	"user_edit_yn" char(1)      NOT NULL DEFAULT 'N', -- 사용자_수정_여부
	"use_yn"       char(1)      NOT NULL DEFAULT 'Y', -- 사용_여부
	"inout_cd"     varchar(50)  NULL,     -- 수불_유형_여부
	"reg_id"       varchar(20)  NOT NULL, -- 등록_ID
	"reg_dt"       timestamp    NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"       varchar(20)  NULL,     -- 수정_ID
	"mod_dt"       timestamp    NULL      -- 수정_일시
);

-- 시스템_공통코드
COMMENT ON TABLE "sm_comm_h" IS '시스템_공통코드';

-- 사업장_SEQ
COMMENT ON COLUMN "sm_comm_h"."biz_seq" IS '사업장_SEQ';

-- 상위_코드
COMMENT ON COLUMN "sm_comm_h"."comm_h_cd" IS '상위코드';

-- 상위_코드_명
COMMENT ON COLUMN "sm_comm_h"."comm_h_nm" IS '상위코드명';

-- 사용자_코드_여부
COMMENT ON COLUMN "sm_comm_h"."user_cd_yn" IS '삭제 여부';

-- 사용자_수정_여부
COMMENT ON COLUMN "sm_comm_h"."user_edit_yn" IS '사용자_수정_여부';

-- 사용_여부
COMMENT ON COLUMN "sm_comm_h"."use_yn" IS '삭제 여부';

-- 수불_유형_여부
COMMENT ON COLUMN "sm_comm_h"."inout_cd" IS '수불_유형_여부';

-- 등록_ID
COMMENT ON COLUMN "sm_comm_h"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "sm_comm_h"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "sm_comm_h"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "sm_comm_h"."mod_dt" IS '수정일';

-- 시스템_공통코드_PK
CREATE UNIQUE INDEX "sm_comm_h_PK"
	ON "sm_comm_h"
	( -- 시스템_공통코드
		"biz_seq" ASC, -- 사업장_SEQ
		"comm_h_cd" ASC -- 상위_코드
	)
;
-- 시스템_공통코드
ALTER TABLE "sm_comm_h"
	ADD CONSTRAINT "sm_comm_h_PK"
		 -- 시스템_공통코드_PK
	PRIMARY KEY 
	USING INDEX "sm_comm_h_PK";

-- 시스템_공통코드_PK
COMMENT ON CONSTRAINT "sm_comm_h_PK" ON "sm_comm_h" IS '시스템_공통코드_PK';

-- 시스템_공통코드_상세
CREATE TABLE "sm_comm_d"
(
	"biz_seq"   int4         NOT NULL, -- 사업장_SEQ
	"comm_h_cd" varchar(50)  NOT NULL, -- 상위_코드
	"comm_d_cd" varchar(50)  NOT NULL, -- 하위_코드
	"comm_d_nm" varchar(100) NOT NULL, -- 하위_코드_명
	"ref_h_cd"  varchar(50)  NULL,     -- 참조_상위_코드
	"ref_d_cd"  varchar(50)  NULL,     -- 참조_하위_코드
	"disp_no"   int2         NOT NULL DEFAULT 1, -- 표시_순서
	"disp_yn"   char(1)      NOT NULL DEFAULT 'Y', -- 표시_여부
	"fr_val"    varchar(100) NULL,     -- 시작_값
	"to_val"    varchar(100) NULL,     -- 종료_값
	"note1"     varchar(100) NULL,     -- 비고_1
	"note2"     varchar(100) NULL,     -- 비고_2
	"note3"     varchar(100) NULL,     -- 비고_3
	"use_yn"    char(1)      NOT NULL DEFAULT 'Y', -- 사용_여부
	"reg_id"    varchar(20)  NOT NULL, -- 등록_ID
	"reg_dt"    timestamp    NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"    varchar(20)  NULL,     -- 수정_ID
	"mod_dt"    timestamp    NULL      -- 수정_일시
);

-- 시스템_공통코드_상세
COMMENT ON TABLE "sm_comm_d" IS '시스템_공통코드_상세';

-- 사업장_SEQ
COMMENT ON COLUMN "sm_comm_d"."biz_seq" IS '사업장_SEQ';

-- 상위_코드
COMMENT ON COLUMN "sm_comm_d"."comm_h_cd" IS '상위코드';

-- 하위_코드
COMMENT ON COLUMN "sm_comm_d"."comm_d_cd" IS '하위코드';

-- 하위_코드_명
COMMENT ON COLUMN "sm_comm_d"."comm_d_nm" IS '하위코드명';

-- 참조_상위_코드
COMMENT ON COLUMN "sm_comm_d"."ref_h_cd" IS '참조상위코드';

-- 참조_하위_코드
COMMENT ON COLUMN "sm_comm_d"."ref_d_cd" IS '참조코드';

-- 표시_순서
COMMENT ON COLUMN "sm_comm_d"."disp_no" IS '표시순서';

-- 표시_여부
COMMENT ON COLUMN "sm_comm_d"."disp_yn" IS '표시여부';

-- 시작_값
COMMENT ON COLUMN "sm_comm_d"."fr_val" IS '하위코드값(fr)';

-- 종료_값
COMMENT ON COLUMN "sm_comm_d"."to_val" IS '하위코드값(to)';

-- 비고_1
COMMENT ON COLUMN "sm_comm_d"."note1" IS '비고_1';

-- 비고_2
COMMENT ON COLUMN "sm_comm_d"."note2" IS '비고_2';

-- 비고_3
COMMENT ON COLUMN "sm_comm_d"."note3" IS '비고_3';

-- 사용_여부
COMMENT ON COLUMN "sm_comm_d"."use_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "sm_comm_d"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "sm_comm_d"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "sm_comm_d"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "sm_comm_d"."mod_dt" IS '수정일';

-- 시스템_공통코드_상세_PK
CREATE UNIQUE INDEX "sm_comm_d_PK"
	ON "sm_comm_d"
	( -- 시스템_공통코드_상세
		"biz_seq" ASC, -- 사업장_SEQ
		"comm_h_cd" ASC, -- 상위_코드
		"comm_d_cd" ASC -- 하위_코드
	)
;
-- 시스템_공통코드_상세
ALTER TABLE "sm_comm_d"
	ADD CONSTRAINT "sm_comm_d_PK"
		 -- 시스템_공통코드_상세_PK
	PRIMARY KEY 
	USING INDEX "sm_comm_d_PK";

-- 시스템_공통코드_상세_PK
COMMENT ON CONSTRAINT "sm_comm_d_PK" ON "sm_comm_d" IS '시스템_공통코드_상세_PK';

-- 시스템_그룹
CREATE TABLE "sm_group"
(
	"group_seq"    int4         NOT NULL DEFAULT nextval('sm_group_seq'), -- 그룹_SEQ
	"biz_seq"      int4         NOT NULL, -- 사업장_SEQ
	"group_nm"     varchar(100) NOT NULL, -- 그룹_명
	"use_yn"       char(1)      NOT NULL DEFAULT 'Y', -- 사용_여부
	"biz_admin_yn" char(1)      NOT NULL DEFAULT 'N', -- 사업장_관리자_여부
	"reg_id"       varchar(20)  NOT NULL, -- 등록_ID
	"reg_dt"       timestamp    NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"       varchar(20)  NULL,     -- 수정_ID
	"mod_dt"       timestamp    NULL      -- 수정_일시
);

-- 시스템_그룹
COMMENT ON TABLE "sm_group" IS '시스템_그룹';

-- 그룹_SEQ
COMMENT ON COLUMN "sm_group"."group_seq" IS '파일SEQ';

-- 사업장_SEQ
COMMENT ON COLUMN "sm_group"."biz_seq" IS '사업장_SEQ';

-- 그룹_명
COMMENT ON COLUMN "sm_group"."group_nm" IS '모델명';

-- 사용_여부
COMMENT ON COLUMN "sm_group"."use_yn" IS '삭제 여부';

-- 사업장_관리자_여부
COMMENT ON COLUMN "sm_group"."biz_admin_yn" IS '사업장_관리자_여부';

-- 등록_ID
COMMENT ON COLUMN "sm_group"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "sm_group"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "sm_group"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "sm_group"."mod_dt" IS '수정일';

-- 시스템_그룹_PK
CREATE UNIQUE INDEX "sm_group_PK"
	ON "sm_group"
	( -- 시스템_그룹
		"group_seq" ASC -- 그룹_SEQ
	)
;
-- 시스템_그룹
ALTER TABLE "sm_group"
	ADD CONSTRAINT "sm_group_PK"
		 -- 시스템_그룹_PK
	PRIMARY KEY 
	USING INDEX "sm_group_PK";

-- 시스템_그룹_PK
COMMENT ON CONSTRAINT "sm_group_PK" ON "sm_group" IS '시스템_그룹_PK';

-- 시스템_로그_API
CREATE TABLE "sm_log_api"
(
	"log_api_seq"   bigint       NOT NULL DEFAULT nextval('sm_log_api_seq'), -- API_로그_SEQ
	"biz_seq"       int4         NOT NULL, -- 사업장_SEQ
	"user_id"       varchar(20)  NOT NULL, -- 사용자_ID
	"methods"       varchar(50)  NOT NULL, -- 메소드
	"menu_url"      varchar(512) NOT NULL, -- 메뉴_URL
	"req_dt"        timestamp    NOT NULL DEFAULT now(), -- 요청_일시
	"request_body"  text         NULL,     -- 요청_내용
	"query_param"   text         NULL,     -- 쿼리_파라미터
	"path_param"    text         NULL,     -- 패스_파라미터
	"res_dt"        timestamp    NULL     DEFAULT now(), -- 응답_일시
	"response_body" text         NULL      -- 응답_내용
);

-- 시스템_로그_API
COMMENT ON TABLE "sm_log_api" IS '시스템_로그_API';

-- API_로그_SEQ
COMMENT ON COLUMN "sm_log_api"."log_api_seq" IS '파일구분_코드';

-- 사업장_SEQ
COMMENT ON COLUMN "sm_log_api"."biz_seq" IS '사업장_SEQ';

-- 사용자_ID
COMMENT ON COLUMN "sm_log_api"."user_id" IS '순서';

-- 메소드
COMMENT ON COLUMN "sm_log_api"."methods" IS '메소드';

-- 메뉴_URL
COMMENT ON COLUMN "sm_log_api"."menu_url" IS '파일고유ID';

-- 요청_일시
COMMENT ON COLUMN "sm_log_api"."req_dt" IS '삭제_여부';

-- 요청_내용
COMMENT ON COLUMN "sm_log_api"."request_body" IS '요청_내용';

-- 쿼리_파라미터
COMMENT ON COLUMN "sm_log_api"."query_param" IS '쿼리_파라미터';

-- 패스_파라미터
COMMENT ON COLUMN "sm_log_api"."path_param" IS '패스_파라미터';

-- 응답_일시
COMMENT ON COLUMN "sm_log_api"."res_dt" IS '삭제_여부';

-- 응답_내용
COMMENT ON COLUMN "sm_log_api"."response_body" IS '응답_내용';

-- 시스템_로그_API_PK
CREATE UNIQUE INDEX "sm_log_api_PK"
	ON "sm_log_api"
	( -- 시스템_로그_API
		"log_api_seq" ASC -- API_로그_SEQ
	)
;
-- 시스템_로그_API
ALTER TABLE "sm_log_api"
	ADD CONSTRAINT "sm_log_api_PK"
		 -- 시스템_로그_API_PK
	PRIMARY KEY 
	USING INDEX "sm_log_api_PK";

-- 시스템_로그_API_PK
COMMENT ON CONSTRAINT "sm_log_api_PK" ON "sm_log_api" IS '시스템_로그_API_PK';

-- 시스템_로그_메뉴접근
CREATE TABLE "sm_log_menu"
(
	"biz_seq"  int4        NOT NULL, -- 사업장_SEQ
	"yyyymmdd" varchar(8)  NOT NULL, -- 연월일
	"menu_cd"  varchar(50) NOT NULL, -- 메뉴_코드
	"view_cnt" int2        NOT NULL DEFAULT 0, -- 조회_수
	"yyyy"     varchar(4)  NOT NULL, -- 연
	"mm"       char(2)     NOT NULL, -- 월
	"dd"       char(2)     NOT NULL  -- 일
);

-- 시스템_로그_메뉴접근
COMMENT ON TABLE "sm_log_menu" IS '시스템_로그_메뉴접근';

-- 사업장_SEQ
COMMENT ON COLUMN "sm_log_menu"."biz_seq" IS '사업장_SEQ';

-- 연월일
COMMENT ON COLUMN "sm_log_menu"."yyyymmdd" IS '삭제_여부';

-- 메뉴_코드
COMMENT ON COLUMN "sm_log_menu"."menu_cd" IS '수정일시';

-- 조회_수
COMMENT ON COLUMN "sm_log_menu"."view_cnt" IS '등록자';

-- 연
COMMENT ON COLUMN "sm_log_menu"."yyyy" IS '파일SEQ';

-- 월
COMMENT ON COLUMN "sm_log_menu"."mm" IS '파일구분_코드';

-- 일
COMMENT ON COLUMN "sm_log_menu"."dd" IS '파일고유ID';

-- 시스템_로그_메뉴접근_PK
CREATE UNIQUE INDEX "sm_log_menu_PK"
	ON "sm_log_menu"
	( -- 시스템_로그_메뉴접근
		"biz_seq" ASC, -- 사업장_SEQ
		"yyyymmdd" ASC, -- 연월일
		"menu_cd" ASC -- 메뉴_코드
	)
;
-- 시스템_로그_메뉴접근
ALTER TABLE "sm_log_menu"
	ADD CONSTRAINT "sm_log_menu_PK"
		 -- 시스템_로그_메뉴접근_PK
	PRIMARY KEY 
	USING INDEX "sm_log_menu_PK";

-- 시스템_로그_메뉴접근_PK
COMMENT ON CONSTRAINT "sm_log_menu_PK" ON "sm_log_menu" IS '시스템_로그_메뉴접근_PK';

-- 시스템_로그_에러
CREATE TABLE "sm_log_error"
(
	"log_error_seq" bigint       NOT NULL DEFAULT nextval('sm_log_conn_dtl_seq'), -- 에러_로그_SEQ
	"biz_seq"       int4         NOT NULL, -- 사업장_SEQ
	"user_id"       varchar(20)  NOT NULL, -- 사용자_ID
	"req_url"       varchar(512) NOT NULL, -- 요청_URL
	"req_dt"        timestamp    NOT NULL DEFAULT now(), -- 에러_일시
	"err_type"      varchar(100) NULL,     -- SwalType
	"err_title"     varchar(100) NULL,     -- SwalTitle
	"err_text"      text         NULL,     -- SwalText
	"ex_nm"         varchar(100) NULL,     -- Exception
	"sts_cd"        varchar(50)  NULL,     -- StatusCode
	"sts_nm"        varchar(100) NULL      -- StatusName
);

-- 시스템_로그_에러
COMMENT ON TABLE "sm_log_error" IS '시스템_로그_에러';

-- 에러_로그_SEQ
COMMENT ON COLUMN "sm_log_error"."log_error_seq" IS '파일구분_코드';

-- 사업장_SEQ
COMMENT ON COLUMN "sm_log_error"."biz_seq" IS '사업장_SEQ';

-- 사용자_ID
COMMENT ON COLUMN "sm_log_error"."user_id" IS '순서';

-- 요청_URL
COMMENT ON COLUMN "sm_log_error"."req_url" IS '파일고유ID';

-- 에러_일시
COMMENT ON COLUMN "sm_log_error"."req_dt" IS '삭제_여부';

-- SwalType
COMMENT ON COLUMN "sm_log_error"."err_type" IS 'SwalType';

-- SwalTitle
COMMENT ON COLUMN "sm_log_error"."err_title" IS 'SwalTitle';

-- SwalText
COMMENT ON COLUMN "sm_log_error"."err_text" IS 'SwalText';

-- Exception
COMMENT ON COLUMN "sm_log_error"."ex_nm" IS 'Exception';

-- StatusCode
COMMENT ON COLUMN "sm_log_error"."sts_cd" IS 'StatusCode';

-- StatusName
COMMENT ON COLUMN "sm_log_error"."sts_nm" IS 'StatusName';

-- 시스템_로그_에러_PK
CREATE UNIQUE INDEX "sm_log_error_PK"
	ON "sm_log_error"
	( -- 시스템_로그_에러
		"log_error_seq" ASC -- 에러_로그_SEQ
	)
;
-- 시스템_로그_에러
ALTER TABLE "sm_log_error"
	ADD CONSTRAINT "sm_log_error_PK"
		 -- 시스템_로그_에러_PK
	PRIMARY KEY 
	USING INDEX "sm_log_error_PK";

-- 시스템_로그_에러_PK
COMMENT ON CONSTRAINT "sm_log_error_PK" ON "sm_log_error" IS '시스템_로그_에러_PK';

-- 시스템_로그_접근
CREATE TABLE "sm_log_conn"
(
	"log_conn_seq" bigint       NOT NULL DEFAULT nextval('sm_log_conn_seq'), -- 접근_로그_SEQ
	"user_id"      varchar(20)  NOT NULL, -- 사용자_ID
	"conn_dt"      timestamp    NOT NULL, -- 접근_일시
	"conn_type_cd" varchar(50)  NOT NULL, -- 접근_유형_코드
	"ip_addr"      varchar(40)  NOT NULL, -- 아이피_주소
	"user_agent"   varchar(200) NOT NULL, -- 사용자_기기
	"device_type"  varchar(100) NOT NULL, -- 기기_유형
	"os_type"      varchar(100) NOT NULL, -- 운영체제
	"browser_type" varchar(100) NOT NULL, -- 브라우저
	"proc_user_id" varchar(20)  NULL     DEFAULT '-' -- 처리_자_ID
);

-- 시스템_로그_접근
COMMENT ON TABLE "sm_log_conn" IS '시스템_로그_접근';

-- 접근_로그_SEQ
COMMENT ON COLUMN "sm_log_conn"."log_conn_seq" IS '파일SEQ';

-- 사용자_ID
COMMENT ON COLUMN "sm_log_conn"."user_id" IS '순서';

-- 접근_일시
COMMENT ON COLUMN "sm_log_conn"."conn_dt" IS '파일구분_코드';

-- 접근_유형_코드
COMMENT ON COLUMN "sm_log_conn"."conn_type_cd" IS '접근_유형_코드';

-- 아이피_주소
COMMENT ON COLUMN "sm_log_conn"."ip_addr" IS '파일경로';

-- 사용자_기기
COMMENT ON COLUMN "sm_log_conn"."user_agent" IS '사용자_기기';

-- 기기_유형
COMMENT ON COLUMN "sm_log_conn"."device_type" IS '수정일시';

-- 운영체제
COMMENT ON COLUMN "sm_log_conn"."os_type" IS '운영체제';

-- 브라우저
COMMENT ON COLUMN "sm_log_conn"."browser_type" IS '브라우저';

-- 처리_자_ID
COMMENT ON COLUMN "sm_log_conn"."proc_user_id" IS '입고_작업자_아이디';

-- 시스템_로그_접근_PK
CREATE UNIQUE INDEX "sm_log_conn_PK"
	ON "sm_log_conn"
	( -- 시스템_로그_접근
		"log_conn_seq" ASC -- 접근_로그_SEQ
	)
;
-- 시스템_로그_접근
ALTER TABLE "sm_log_conn"
	ADD CONSTRAINT "sm_log_conn_PK"
		 -- 시스템_로그_접근_PK
	PRIMARY KEY 
	USING INDEX "sm_log_conn_PK";

-- 시스템_로그_접근_PK
COMMENT ON CONSTRAINT "sm_log_conn_PK" ON "sm_log_conn" IS '시스템_로그_접근_PK';

-- 시스템_로그_접근_상세
CREATE TABLE "sm_log_conn_dtl"
(
	"log_conn_seq"      bigint NOT NULL, -- 접근_로그_SEQ
	"log_conn_dtl_text" text   NULL      -- 접근_로그_상세_내역
);

-- 시스템_로그_접근_상세
COMMENT ON TABLE "sm_log_conn_dtl" IS '시스템_로그_접근_상세';

-- 접근_로그_SEQ
COMMENT ON COLUMN "sm_log_conn_dtl"."log_conn_seq" IS '접근_로그_SEQ';

-- 접근_로그_상세_내역
COMMENT ON COLUMN "sm_log_conn_dtl"."log_conn_dtl_text" IS '접근_로그_상세_내역';

-- 시스템_로그_접근_상세(NEW)_PK
CREATE UNIQUE INDEX "sm_log_conn_dtl_PK"
	ON "sm_log_conn_dtl"
	( -- 시스템_로그_접근_상세
		"log_conn_seq" ASC -- 접근_로그_SEQ
	)
;
-- 시스템_로그_접근_상세
ALTER TABLE "sm_log_conn_dtl"
	ADD CONSTRAINT "sm_log_conn_dtl_PK"
		 -- 시스템_로그_접근_상세(NEW)_PK
	PRIMARY KEY 
	USING INDEX "sm_log_conn_dtl_PK";

-- 시스템_로그_접근_상세(NEW)_PK
COMMENT ON CONSTRAINT "sm_log_conn_dtl_PK" ON "sm_log_conn_dtl" IS '시스템_로그_접근_상세(NEW)_PK';

-- 시스템_메뉴
CREATE TABLE "sm_menu"
(
	"menu_cd"          varchar(50)  NOT NULL, -- 메뉴_코드
	"menu_nm"          varchar(100) NOT NULL, -- 메뉴_명
	"h_menu_cd"        varchar(50)  NOT NULL, -- 상위_메뉴_코드
	"menu_idx"         int2         NOT NULL DEFAULT 0, -- 메뉴_순서
	"menu_type_cd"     varchar(50)  NOT NULL, -- 메뉴_유형_코드
	"menu_url"         varchar(512) NULL,     -- 메뉴_URL
	"ui_type_cd"       varchar(50)  NULL,     -- UI_유형_코드
	"alarm_use_yn"     char(1)      NOT NULL DEFAULT 'N', -- 알람_사용_여부
	"proc_ymd_chng_yn" char(1)      NOT NULL DEFAULT 'N', -- 처리일자_변경_여부
	"sch_ymd_set_yn"   char(1)      NOT NULL DEFAULT 'N', -- 조회일자_설정_여부
	"menu_icon"        varchar(512) NULL,     -- 메뉴_아이콘
	"pda_disp_no"      int2         NULL     DEFAULT 0, -- PDA_표시_순서
	"login_acc_yn"     char(1)      NULL     DEFAULT 'Y', -- 로그인_접근_여부
	"login_disp_yn"    char(1)      NULL     DEFAULT 'Y', -- 로그인_표시_여부
	"def_menu_yn"      char(1)      NOT NULL DEFAULT 'Y', -- 기본메뉴_여부
	"use_yn"           char(1)      NOT NULL DEFAULT 'Y', -- 사용_여부
	"reg_id"           varchar(20)  NOT NULL, -- 등록_ID
	"reg_dt"           timestamp    NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"           varchar(20)  NULL,     -- 수정_ID
	"mod_dt"           timestamp    NULL      -- 수정_일시
);

-- 시스템_메뉴
COMMENT ON TABLE "sm_menu" IS '시스템_메뉴';

-- 메뉴_코드
COMMENT ON COLUMN "sm_menu"."menu_cd" IS '메뉴코드';

-- 메뉴_명
COMMENT ON COLUMN "sm_menu"."menu_nm" IS '메뉴명';

-- 상위_메뉴_코드
COMMENT ON COLUMN "sm_menu"."h_menu_cd" IS '참조메뉴';

-- 메뉴_순서
COMMENT ON COLUMN "sm_menu"."menu_idx" IS '메뉴순서';

-- 메뉴_유형_코드
COMMENT ON COLUMN "sm_menu"."menu_type_cd" IS '메뉴유형';

-- 메뉴_URL
COMMENT ON COLUMN "sm_menu"."menu_url" IS '메뉴URL';

-- UI_유형_코드
COMMENT ON COLUMN "sm_menu"."ui_type_cd" IS 'UI 유형_코드';

-- 알람_사용_여부
COMMENT ON COLUMN "sm_menu"."alarm_use_yn" IS '알람_사용_여부';

-- 처리일자_변경_여부
COMMENT ON COLUMN "sm_menu"."proc_ymd_chng_yn" IS '처리일자_변경_여부';

-- 조회일자_설정_여부
COMMENT ON COLUMN "sm_menu"."sch_ymd_set_yn" IS '조회일자_설정_여부';

-- 메뉴_아이콘
COMMENT ON COLUMN "sm_menu"."menu_icon" IS '메뉴아이콘';

-- PDA_표시_순서
COMMENT ON COLUMN "sm_menu"."pda_disp_no" IS '시스템타입';

-- 로그인_접근_여부
COMMENT ON COLUMN "sm_menu"."login_acc_yn" IS '로그인_접근_여부';

-- 로그인_표시_여부
COMMENT ON COLUMN "sm_menu"."login_disp_yn" IS '로그인_표시_여부';

-- 기본메뉴_여부
COMMENT ON COLUMN "sm_menu"."def_menu_yn" IS '기본메뉴_여부';

-- 사용_여부
COMMENT ON COLUMN "sm_menu"."use_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "sm_menu"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "sm_menu"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "sm_menu"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "sm_menu"."mod_dt" IS '수정일';

-- 시스템_메뉴_PK
CREATE UNIQUE INDEX "sm_menu_PK"
	ON "sm_menu"
	( -- 시스템_메뉴
		"menu_cd" ASC -- 메뉴_코드
	)
;
-- 시스템_메뉴
ALTER TABLE "sm_menu"
	ADD CONSTRAINT "sm_menu_PK"
		 -- 시스템_메뉴_PK
	PRIMARY KEY 
	USING INDEX "sm_menu_PK";

-- 시스템_메뉴_PK
COMMENT ON CONSTRAINT "sm_menu_PK" ON "sm_menu" IS '시스템_메뉴_PK';

-- 시스템_메뉴_그룹
CREATE TABLE "sm_menu_group"
(
	"menu_cd"        varchar(50) NOT NULL, -- 메뉴_코드
	"group_seq"      int4        NOT NULL, -- 그룹_SEQ
	"ui_type_cd"     varchar(50) NOT NULL, -- UI_유형_코드
	"read_auth_yn"   char(1)     NOT NULL DEFAULT 'Y', -- 조회_권한_여부
	"create_auth_yn" char(1)     NOT NULL DEFAULT 'Y', -- 등록_권한_여부
	"alarm_auth_yn"  char(1)     NOT NULL DEFAULT 'N', -- 알람_권한_여부
	"reg_id"         varchar(20) NOT NULL, -- 등록_ID
	"reg_dt"         timestamp   NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"         varchar(20) NULL,     -- 수정_ID
	"mod_dt"         timestamp   NULL      -- 수정_일시
);

-- 시스템_메뉴_그룹
COMMENT ON TABLE "sm_menu_group" IS '시스템_메뉴_그룹';

-- 메뉴_코드
COMMENT ON COLUMN "sm_menu_group"."menu_cd" IS '메뉴코드';

-- 그룹_SEQ
COMMENT ON COLUMN "sm_menu_group"."group_seq" IS '그룹_SEQ';

-- UI_유형_코드
COMMENT ON COLUMN "sm_menu_group"."ui_type_cd" IS 'UI 유형_코드';

-- 조회_권한_여부
COMMENT ON COLUMN "sm_menu_group"."read_auth_yn" IS '조회';

-- 등록_권한_여부
COMMENT ON COLUMN "sm_menu_group"."create_auth_yn" IS '등록';

-- 알람_권한_여부
COMMENT ON COLUMN "sm_menu_group"."alarm_auth_yn" IS '알람_권한_여부';

-- 등록_ID
COMMENT ON COLUMN "sm_menu_group"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "sm_menu_group"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "sm_menu_group"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "sm_menu_group"."mod_dt" IS '수정일';

-- 시스템_메뉴_그룹_PK
CREATE UNIQUE INDEX "sm_menu_group_PK"
	ON "sm_menu_group"
	( -- 시스템_메뉴_그룹
		"menu_cd" ASC, -- 메뉴_코드
		"group_seq" ASC -- 그룹_SEQ
	)
;
-- 시스템_메뉴_그룹
ALTER TABLE "sm_menu_group"
	ADD CONSTRAINT "sm_menu_group_PK"
		 -- 시스템_메뉴_그룹_PK
	PRIMARY KEY 
	USING INDEX "sm_menu_group_PK";

-- 시스템_메뉴_그룹_PK
COMMENT ON CONSTRAINT "sm_menu_group_PK" ON "sm_menu_group" IS '시스템_메뉴_그룹_PK';

-- 시스템_메뉴_옵션_설정
CREATE TABLE "sm_menu_opt_config"
(
	"biz_seq"          int4        NOT NULL, -- 사업장_SEQ
	"menu_cd"          varchar(50) NOT NULL, -- 메뉴_코드
	"search_start_ymd" smallint    NOT NULL DEFAULT 0, -- 검색_시작_일
	"search_end_ymd"   smallint    NOT NULL DEFAULT 0, -- 검색_종료_일
	"proc_ymd_edit_yn" char(1)     NOT NULL DEFAULT 'N', -- 처리일자_수정_여부
	"reg_id"           varchar(20) NOT NULL, -- 등록_ID
	"reg_dt"           timestamp   NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"           varchar(20) NULL,     -- 수정_ID
	"mod_dt"           timestamp   NULL      -- 수정_일시
);

-- 시스템_메뉴_옵션_설정
COMMENT ON TABLE "sm_menu_opt_config" IS '시스템_메뉴_옵션_설정';

-- 사업장_SEQ
COMMENT ON COLUMN "sm_menu_opt_config"."biz_seq" IS '사업장_ID';

-- 메뉴_코드
COMMENT ON COLUMN "sm_menu_opt_config"."menu_cd" IS '메뉴코드';

-- 검색_시작_일
COMMENT ON COLUMN "sm_menu_opt_config"."search_start_ymd" IS '검색_시작_일';

-- 검색_종료_일
COMMENT ON COLUMN "sm_menu_opt_config"."search_end_ymd" IS '검색_종료_일';

-- 처리일자_수정_여부
COMMENT ON COLUMN "sm_menu_opt_config"."proc_ymd_edit_yn" IS '처리일자_수정_여부';

-- 등록_ID
COMMENT ON COLUMN "sm_menu_opt_config"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "sm_menu_opt_config"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "sm_menu_opt_config"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "sm_menu_opt_config"."mod_dt" IS '수정일';

-- 시스템_메뉴_옵션_설정_PK
CREATE UNIQUE INDEX "sm_menu_opt_config_PK"
	ON "sm_menu_opt_config"
	( -- 시스템_메뉴_옵션_설정
		"biz_seq" ASC, -- 사업장_SEQ
		"menu_cd" ASC -- 메뉴_코드
	)
;
-- 시스템_메뉴_옵션_설정
ALTER TABLE "sm_menu_opt_config"
	ADD CONSTRAINT "sm_menu_opt_config_PK"
		 -- 시스템_메뉴_옵션_설정_PK
	PRIMARY KEY 
	USING INDEX "sm_menu_opt_config_PK";

-- 시스템_메뉴_옵션_설정_PK
COMMENT ON CONSTRAINT "sm_menu_opt_config_PK" ON "sm_menu_opt_config" IS '시스템_메뉴_옵션_설정_PK';

-- 시스템_사업장_설정
CREATE TABLE "sm_biz_config"
(
	"biz_seq"                 int4         NOT NULL, -- 사업장_SEQ
	"mail_host"               varchar(512) NULL,     -- 메일_호스트
	"mail_port"               char(5)      NULL,     -- 메일_포트
	"mail_user"               varchar(20)  NULL,     -- 메일_유저
	"mail_pass"               bytea        NULL,     -- 메일_패스워드
	"mail_sender"             varchar(20)  NULL,     -- 메일_보내는사람
	"system_lock_cnt"         int2         NOT NULL DEFAULT 5, -- 시스템_로그인_실패_허용
	"system_dormancy_cycle"   int2         NOT NULL DEFAULT 30, -- 시스템_관리자_휴면전환주기
	"system_pwd_cycle"        int2         NOT NULL DEFAULT 90, -- 시스템_로그인_암호변경주기
	"pwd_caps"                char(1)      NOT NULL DEFAULT 'N', -- 암호_대문자포함
	"pwd_small"               char(1)      NOT NULL DEFAULT 'N', -- 암호_소문자포함
	"pwd_num"                 char(1)      NOT NULL DEFAULT 'Y', -- 암호_숫자포함
	"pwd_special"             char(1)      NOT NULL DEFAULT 'N', -- 암호_특수문자포함
	"pwd_min_len"             int2         NOT NULL DEFAULT 4, -- 암호_최소자리수
	"pwd_init"                varchar(20)  NOT NULL DEFAULT '1111', -- 암호_초기비밀번호
	"pwd_reuse_lmt"           int2         NOT NULL DEFAULT 3, -- 암호_재사용불가_횟수(기본3회)
	"api_key"                 varchar(500) NULL,     -- API_KEY
	"api_key_exp_ymd"         varchar(8)   NULL,     -- API_KEY_만료일
	"session_timeout_yn"      char(1)      NOT NULL DEFAULT 'N', -- 세션_타임아웃_여부
	"session_timeout_minutes" int2         NULL     DEFAULT 0, -- 세션_타임아웃_분
	"reg_id"                  varchar(20)  NOT NULL, -- 등록_ID
	"reg_dt"                  timestamp    NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"                  varchar(20)  NULL,     -- 수정_ID
	"mod_dt"                  timestamp    NULL      -- 수정_일시
);

-- 시스템_사업장_설정
COMMENT ON TABLE "sm_biz_config" IS '시스템_사업장_설정';

-- 사업장_SEQ
COMMENT ON COLUMN "sm_biz_config"."biz_seq" IS '사업장_ID';

-- 메일_호스트
COMMENT ON COLUMN "sm_biz_config"."mail_host" IS '메일_호스트';

-- 메일_포트
COMMENT ON COLUMN "sm_biz_config"."mail_port" IS '메일_포트';

-- 메일_유저
COMMENT ON COLUMN "sm_biz_config"."mail_user" IS '메일_유저';

-- 메일_패스워드
COMMENT ON COLUMN "sm_biz_config"."mail_pass" IS '메일_패스워드';

-- 메일_보내는사람
COMMENT ON COLUMN "sm_biz_config"."mail_sender" IS '메일_보내는사람';

-- 시스템_로그인_실패_허용
COMMENT ON COLUMN "sm_biz_config"."system_lock_cnt" IS '시스템_로그인_실패_허용';

-- 시스템_관리자_휴면전환주기
COMMENT ON COLUMN "sm_biz_config"."system_dormancy_cycle" IS '시스템_관리자_휴면전환주기';

-- 시스템_로그인_암호변경주기
COMMENT ON COLUMN "sm_biz_config"."system_pwd_cycle" IS '시스템_로그인_암호변경주기';

-- 암호_대문자포함
COMMENT ON COLUMN "sm_biz_config"."pwd_caps" IS '암호_대문자포함';

-- 암호_소문자포함
COMMENT ON COLUMN "sm_biz_config"."pwd_small" IS '암호_소문자포함';

-- 암호_숫자포함
COMMENT ON COLUMN "sm_biz_config"."pwd_num" IS '암호_숫자포함';

-- 암호_특수문자포함
COMMENT ON COLUMN "sm_biz_config"."pwd_special" IS '암호_특수문자포함';

-- 암호_최소자리수
COMMENT ON COLUMN "sm_biz_config"."pwd_min_len" IS '암호_최소자리수';

-- 암호_초기비밀번호
COMMENT ON COLUMN "sm_biz_config"."pwd_init" IS '암호_초기비밀번호';

-- 암호_재사용불가_횟수(기본3회)
COMMENT ON COLUMN "sm_biz_config"."pwd_reuse_lmt" IS '암호_재사용불가_횟수(기본3회)';

-- API_KEY
COMMENT ON COLUMN "sm_biz_config"."api_key" IS 'API_KEY';

-- API_KEY_만료일
COMMENT ON COLUMN "sm_biz_config"."api_key_exp_ymd" IS 'API_KEY_만료일';

-- 세션_타임아웃_여부
COMMENT ON COLUMN "sm_biz_config"."session_timeout_yn" IS '세션_타임아웃_여부';

-- 세션_타임아웃_분
COMMENT ON COLUMN "sm_biz_config"."session_timeout_minutes" IS '세션_타임아웃_분';

-- 등록_ID
COMMENT ON COLUMN "sm_biz_config"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "sm_biz_config"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "sm_biz_config"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "sm_biz_config"."mod_dt" IS '수정일';

-- 시스템_사업장_설정(NEW)_PK
CREATE UNIQUE INDEX "sm_biz_config_PK"
	ON "sm_biz_config"
	( -- 시스템_사업장_설정
		"biz_seq" ASC -- 사업장_SEQ
	)
;
-- 시스템_사업장_설정
ALTER TABLE "sm_biz_config"
	ADD CONSTRAINT "sm_biz_config_PK"
		 -- 시스템_사업장_설정(NEW)_PK
	PRIMARY KEY 
	USING INDEX "sm_biz_config_PK";

-- 시스템_사업장_설정(NEW)_PK
COMMENT ON CONSTRAINT "sm_biz_config_PK" ON "sm_biz_config" IS '시스템_사업장_설정(NEW)_PK';

-- 시스템_알람_이력
CREATE TABLE "sm_alarm_history"
(
	"alarm_history_seq" bigint        NOT NULL DEFAULT nextval('sm_alarm_history_seq'), -- 알람_이력_SEQ
	"biz_seq"           int4          NOT NULL, -- 사업장_SEQ
	"biz_nm"            varchar(100)  NOT NULL, -- 사업장_명
	"center_seq"        int4          NOT NULL, -- 센터_SEQ
	"center_nm"         varchar(100)  NOT NULL, -- 센터_명
	"menu_cd"           varchar(50)   NOT NULL, -- 메뉴_코드
	"menu_nm"           varchar(100)  NOT NULL, -- 메뉴_명
	"req_seq"           int4          NULL,     -- 업무_SEQ
	"req_no"            varchar(30)   NOT NULL, -- 업무_번호
	"alarm_message"     varchar(1000) NOT NULL, -- 알람_내용
	"group_seq"         int4          NULL,     -- 그룹_SEQ
	"proc_user_id"      varchar(20)   NOT NULL, -- 처리자_ID
	"proc_user_nm"      varchar(100)  NOT NULL, -- 처리자_명
	"reg_id"            varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"            timestamp     NOT NULL DEFAULT now() -- 등록_일시
);

-- 시스템_알람_이력
COMMENT ON TABLE "sm_alarm_history" IS '시스템_알람_이력';

-- 알람_이력_SEQ
COMMENT ON COLUMN "sm_alarm_history"."alarm_history_seq" IS '파일SEQ';

-- 사업장_SEQ
COMMENT ON COLUMN "sm_alarm_history"."biz_seq" IS '사업장_SEQ';

-- 사업장_명
COMMENT ON COLUMN "sm_alarm_history"."biz_nm" IS '사업장_명';

-- 센터_SEQ
COMMENT ON COLUMN "sm_alarm_history"."center_seq" IS '센터_SEQ';

-- 센터_명
COMMENT ON COLUMN "sm_alarm_history"."center_nm" IS '센터_명';

-- 메뉴_코드
COMMENT ON COLUMN "sm_alarm_history"."menu_cd" IS '거래처_ID';

-- 메뉴_명
COMMENT ON COLUMN "sm_alarm_history"."menu_nm" IS '메뉴_명';

-- 업무_SEQ
COMMENT ON COLUMN "sm_alarm_history"."req_seq" IS '업무_SEQ';

-- 업무_번호
COMMENT ON COLUMN "sm_alarm_history"."req_no" IS '품목ID';

-- 알람_내용
COMMENT ON COLUMN "sm_alarm_history"."alarm_message" IS '알람_내용';

-- 그룹_SEQ
COMMENT ON COLUMN "sm_alarm_history"."group_seq" IS '단위_코드';

-- 처리자_ID
COMMENT ON COLUMN "sm_alarm_history"."proc_user_id" IS '처리자_ID';

-- 처리자_명
COMMENT ON COLUMN "sm_alarm_history"."proc_user_nm" IS '입고_요청_수량';

-- 등록_ID
COMMENT ON COLUMN "sm_alarm_history"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "sm_alarm_history"."reg_dt" IS '등록일';

-- 시스템_알람_이력_PK
CREATE UNIQUE INDEX "sm_alarm_history_PK"
	ON "sm_alarm_history"
	( -- 시스템_알람_이력
		"alarm_history_seq" ASC -- 알람_이력_SEQ
	)
;
-- 시스템_알람_이력
ALTER TABLE "sm_alarm_history"
	ADD CONSTRAINT "sm_alarm_history_PK"
		 -- 시스템_알람_이력_PK
	PRIMARY KEY 
	USING INDEX "sm_alarm_history_PK";

-- 시스템_알람_이력_PK
COMMENT ON CONSTRAINT "sm_alarm_history_PK" ON "sm_alarm_history" IS '시스템_알람_이력_PK';

-- 시스템_알람_미수신
CREATE TABLE "sm_alarm_unrcv"
(
	"user_id" varchar(20) NOT NULL, -- 유저ID
	"menu_cd" varchar(50) NOT NULL, -- 메뉴_코드
	"reg_id"  varchar(20) NOT NULL, -- 등록_ID
	"reg_dt"  timestamp   NOT NULL DEFAULT now() -- 등록_일시
);

-- 시스템_알람_미수신
COMMENT ON TABLE "sm_alarm_unrcv" IS '시스템_알람_미수신';

-- 유저ID
COMMENT ON COLUMN "sm_alarm_unrcv"."user_id" IS '유저ID';

-- 메뉴_코드
COMMENT ON COLUMN "sm_alarm_unrcv"."menu_cd" IS '메뉴_코드';

-- 등록_ID
COMMENT ON COLUMN "sm_alarm_unrcv"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "sm_alarm_unrcv"."reg_dt" IS '등록일';

-- 시스템_알람_미수신_PK
CREATE UNIQUE INDEX "sm_alarm_unrcv_PK"
	ON "sm_alarm_unrcv"
	( -- 시스템_알람_미수신
		"user_id" ASC, -- 유저ID
		"menu_cd" ASC -- 메뉴_코드
	)
;
-- 시스템_알람_미수신
ALTER TABLE "sm_alarm_unrcv"
	ADD CONSTRAINT "sm_alarm_unrcv_PK"
		 -- 시스템_알람_미수신_PK
	PRIMARY KEY 
	USING INDEX "sm_alarm_unrcv_PK";

-- 시스템_알람_미수신_PK
COMMENT ON CONSTRAINT "sm_alarm_unrcv_PK" ON "sm_alarm_unrcv" IS '시스템_알람_미수신_PK';

-- 시스템_출력물_설정
CREATE TABLE "sm_opt_config"
(
	"biz_seq"               int4        NOT NULL, -- 사업장_SEQ
	"outbiz_inven_check_yn" char(1)     NOT NULL DEFAULT 'Y', -- (출하)재고확인_여부
	"outbiz_label_yn"       char(1)     NOT NULL DEFAULT 'Y', -- (출하)출하라벨_여부
	"outwh_div_cd"          varchar(50) NOT NULL DEFAULT '-', -- 출고지시_유형_코드
	"strng_asgn_yn"         char(1)     NOT NULL DEFAULT 'N', -- 출고지시_지정유형_여부
	"def_barcode_type1"     varchar(50) NOT NULL, -- 1D_바코드_기본타입
	"def_barcode_type2"     varchar(50) NOT NULL, -- 2D_바코드_기본타입
	"reg_id"                varchar(20) NOT NULL, -- 등록_ID
	"reg_dt"                timestamp   NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"                varchar(20) NULL,     -- 수정_ID
	"mod_dt"                timestamp   NULL      -- 수정_일시
);

-- 시스템_출력물_설정
COMMENT ON TABLE "sm_opt_config" IS '시스템_출력물_설정';

-- 사업장_SEQ
COMMENT ON COLUMN "sm_opt_config"."biz_seq" IS '사업장_ID';

-- (출하)재고확인_여부
COMMENT ON COLUMN "sm_opt_config"."outbiz_inven_check_yn" IS '(출하)재고확인_여부';

-- (출하)출하라벨_여부
COMMENT ON COLUMN "sm_opt_config"."outbiz_label_yn" IS '(출하)출하라벨_여부';

-- 출고지시_유형_코드
COMMENT ON COLUMN "sm_opt_config"."outwh_div_cd" IS '출고지시_유형_코드';

-- 출고지시_지정유형_여부
COMMENT ON COLUMN "sm_opt_config"."strng_asgn_yn" IS '출고지시_지정유형_여부';

-- 1D_바코드_기본타입
COMMENT ON COLUMN "sm_opt_config"."def_barcode_type1" IS '1D_바코드_기본타입';

-- 2D_바코드_기본타입
COMMENT ON COLUMN "sm_opt_config"."def_barcode_type2" IS '2D_바코드_기본타입';

-- 등록_ID
COMMENT ON COLUMN "sm_opt_config"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "sm_opt_config"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "sm_opt_config"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "sm_opt_config"."mod_dt" IS '수정일';

-- 시스템_출력물_설정_PK
CREATE UNIQUE INDEX "sm_opt_config_PK"
	ON "sm_opt_config"
	( -- 시스템_출력물_설정
		"biz_seq" ASC -- 사업장_SEQ
	)
;
-- 시스템_출력물_설정
ALTER TABLE "sm_opt_config"
	ADD CONSTRAINT "sm_opt_config_PK"
		 -- 시스템_출력물_설정_PK
	PRIMARY KEY 
	USING INDEX "sm_opt_config_PK";

-- 시스템_출력물_설정_PK
COMMENT ON CONSTRAINT "sm_opt_config_PK" ON "sm_opt_config" IS '시스템_출력물_설정_PK';

-- 시스템_출하_처리_옵션_설정
CREATE TABLE "sm_ob_proc_opt_config"
(
	"biz_seq"             int4        NOT NULL, -- 사업장_SEQ
	"outbiz_type_cd"      varchar(50) NOT NULL, -- 출하_유형_코드
	"outbiz_proc_type_cd" varchar(50) NOT NULL DEFAULT 'N', -- 배송_유형_코드
	"outbiz_auto_yn"      char(1)     NOT NULL DEFAULT 'N', -- 자동_출하_여부
	"outwh_proc_yn"       char(1)     NOT NULL DEFAULT 'Y', -- 출고처리_여부
	"if_device_cd"        varchar(50) NOT NULL DEFAULT '-', -- IF_장치_코드
	"reg_id"              varchar(20) NOT NULL, -- 등록_ID
	"reg_dt"              timestamp   NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"              varchar(20) NULL,     -- 수정_ID
	"mod_dt"              timestamp   NULL      -- 수정_일시
);

-- 시스템_출하_처리_옵션_설정
COMMENT ON TABLE "sm_ob_proc_opt_config" IS '시스템_출하_처리_옵션_설정';

-- 사업장_SEQ
COMMENT ON COLUMN "sm_ob_proc_opt_config"."biz_seq" IS '사업장_ID';

-- 출하_유형_코드
COMMENT ON COLUMN "sm_ob_proc_opt_config"."outbiz_type_cd" IS '출하_유형_코드';

-- 배송_유형_코드
COMMENT ON COLUMN "sm_ob_proc_opt_config"."outbiz_proc_type_cd" IS '배송_유형_코드';

-- 자동_출하_여부
COMMENT ON COLUMN "sm_ob_proc_opt_config"."outbiz_auto_yn" IS '자동_출하_여부';

-- 출고처리_여부
COMMENT ON COLUMN "sm_ob_proc_opt_config"."outwh_proc_yn" IS '출고처리_여부';

-- IF_장치_코드
COMMENT ON COLUMN "sm_ob_proc_opt_config"."if_device_cd" IS 'IF_장치_코드';

-- 등록_ID
COMMENT ON COLUMN "sm_ob_proc_opt_config"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "sm_ob_proc_opt_config"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "sm_ob_proc_opt_config"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "sm_ob_proc_opt_config"."mod_dt" IS '수정일';

-- 시스템_출하_처리_옵션_설정_PK
CREATE UNIQUE INDEX "sm_ob_proc_opt_config_PK"
	ON "sm_ob_proc_opt_config"
	( -- 시스템_출하_처리_옵션_설정
		"biz_seq" ASC, -- 사업장_SEQ
		"outbiz_type_cd" ASC -- 출하_유형_코드
	)
;
-- 시스템_출하_처리_옵션_설정
ALTER TABLE "sm_ob_proc_opt_config"
	ADD CONSTRAINT "sm_ob_proc_opt_config_PK"
		 -- 시스템_출하_처리_옵션_설정_PK
	PRIMARY KEY 
	USING INDEX "sm_ob_proc_opt_config_PK";

-- 시스템_출하_처리_옵션_설정_PK
COMMENT ON CONSTRAINT "sm_ob_proc_opt_config_PK" ON "sm_ob_proc_opt_config" IS '시스템_출하_처리_옵션_설정_PK';

-- 시스템_쿼츠_변경_이력
CREATE TABLE "sm_qrtz_change_log"
(
	"qrtz_change_log_seq" bigint        NOT NULL DEFAULT nextval('sm_qrtz_change_log_seq'), -- 쿼츠변경이력SEQ
	"job_nm"              varchar(100)  NULL,     -- 작업_명
	"job_cls_nm"          varchar(100)  NULL,     -- 작업_클래스_명
	"job_data"            text          NULL,     -- 작업_데이터
	"description"         varchar(1000) NULL,     -- 설명
	"qrtz_type_cd"        varchar(100)  NULL,     -- 변경_유형_코드
	"cron"                varchar(100)  NULL,     -- 크론
	"trigger_nm"          varchar(100)  NULL,     -- 트리거
	"proc_ymd"            varchar(8)    NULL,     -- 처리_연월일
	"proc_hms"            varchar(6)    NULL,     -- 처리_시분초
	"proc_user_id"        varchar(20)   NULL      -- 처리_자_ID
);

-- 시스템_쿼츠_변경_이력
COMMENT ON TABLE "sm_qrtz_change_log" IS '시스템_쿼츠_변경_이력';

-- 쿼츠변경이력SEQ
COMMENT ON COLUMN "sm_qrtz_change_log"."qrtz_change_log_seq" IS '쿼츠변경이력SEQ';

-- 작업_명
COMMENT ON COLUMN "sm_qrtz_change_log"."job_nm" IS '작업_명';

-- 작업_클래스_명
COMMENT ON COLUMN "sm_qrtz_change_log"."job_cls_nm" IS '작업_클래스_명';

-- 작업_데이터
COMMENT ON COLUMN "sm_qrtz_change_log"."job_data" IS '에러_메세지';

-- 설명
COMMENT ON COLUMN "sm_qrtz_change_log"."description" IS '에러_메세지';

-- 변경_유형_코드
COMMENT ON COLUMN "sm_qrtz_change_log"."qrtz_type_cd" IS '변경_유형_코드';

-- 크론
COMMENT ON COLUMN "sm_qrtz_change_log"."cron" IS '크론';

-- 트리거
COMMENT ON COLUMN "sm_qrtz_change_log"."trigger_nm" IS '트리거';

-- 처리_연월일
COMMENT ON COLUMN "sm_qrtz_change_log"."proc_ymd" IS '요청_일자';

-- 처리_시분초
COMMENT ON COLUMN "sm_qrtz_change_log"."proc_hms" IS '요청_시간';

-- 처리_자_ID
COMMENT ON COLUMN "sm_qrtz_change_log"."proc_user_id" IS '등록자';

-- 시스템_쿼츠_변경_이력_PK
CREATE UNIQUE INDEX "sm_qrtz_change_log_PK"
	ON "sm_qrtz_change_log"
	( -- 시스템_쿼츠_변경_이력
		"qrtz_change_log_seq" ASC -- 쿼츠변경이력SEQ
	)
;
-- 시스템_쿼츠_변경_이력
ALTER TABLE "sm_qrtz_change_log"
	ADD CONSTRAINT "sm_qrtz_change_log_PK"
		 -- 시스템_쿼츠_변경_이력_PK
	PRIMARY KEY 
	USING INDEX "sm_qrtz_change_log_PK";

-- 시스템_쿼츠_변경_이력_PK
COMMENT ON CONSTRAINT "sm_qrtz_change_log_PK" ON "sm_qrtz_change_log" IS '시스템_쿼츠_변경_이력_PK';

-- 시스템_쿼츠_실행_이력
CREATE TABLE "sm_qrtz_exec_log"
(
	"qrtz_exec_log_seq" bigint        NOT NULL DEFAULT nextval('sm_qrtz_exec_log_seq'), -- 쿼츠실행이력SEQ
	"instance_id"       varchar(100)  NULL,     -- 인스턴스_ID
	"qrtz_status_cd"    varchar(100)  NULL,     -- 쿼츠_상태_코드
	"err_msg"           text          NULL,     -- 에러_메세지
	"job_nm"            varchar(100)  NULL,     -- 작업_명
	"job_cls_nm"        varchar(100)  NULL,     -- 작업_클래스_명
	"job_data"          text          NULL,     -- 작업_데이터
	"description"       varchar(1000) NULL,     -- 설명
	"cron"              varchar(100)  NULL,     -- 크론
	"trigger_nm"        varchar(100)  NULL,     -- 트리거_명
	"start_ymd"         varchar(8)    NULL,     -- 시작_연월일
	"start_hms"         varchar(6)    NULL,     -- 시작_시분초
	"end_ymd"           varchar(8)    NULL,     -- 종료_연월일
	"end_hms"           varchar(6)    NULL      -- 종료_시분초
);

-- 시스템_쿼츠_실행_이력
COMMENT ON TABLE "sm_qrtz_exec_log" IS '시스템_쿼츠_실행_이력';

-- 쿼츠실행이력SEQ
COMMENT ON COLUMN "sm_qrtz_exec_log"."qrtz_exec_log_seq" IS '쿼츠실행이력SEQ';

-- 인스턴스_ID
COMMENT ON COLUMN "sm_qrtz_exec_log"."instance_id" IS '인스턴스_ID';

-- 쿼츠_상태_코드
COMMENT ON COLUMN "sm_qrtz_exec_log"."qrtz_status_cd" IS '쿼츠_상태_코드';

-- 에러_메세지
COMMENT ON COLUMN "sm_qrtz_exec_log"."err_msg" IS '에러_메세지';

-- 작업_명
COMMENT ON COLUMN "sm_qrtz_exec_log"."job_nm" IS '작업_명';

-- 작업_클래스_명
COMMENT ON COLUMN "sm_qrtz_exec_log"."job_cls_nm" IS '작업_클래스_명';

-- 작업_데이터
COMMENT ON COLUMN "sm_qrtz_exec_log"."job_data" IS '에러_메세지';

-- 설명
COMMENT ON COLUMN "sm_qrtz_exec_log"."description" IS '에러_메세지';

-- 크론
COMMENT ON COLUMN "sm_qrtz_exec_log"."cron" IS '크론';

-- 트리거_명
COMMENT ON COLUMN "sm_qrtz_exec_log"."trigger_nm" IS '트리거_명';

-- 시작_연월일
COMMENT ON COLUMN "sm_qrtz_exec_log"."start_ymd" IS '요청_일자';

-- 시작_시분초
COMMENT ON COLUMN "sm_qrtz_exec_log"."start_hms" IS '요청_시간';

-- 종료_연월일
COMMENT ON COLUMN "sm_qrtz_exec_log"."end_ymd" IS '종료_일자';

-- 종료_시분초
COMMENT ON COLUMN "sm_qrtz_exec_log"."end_hms" IS '종료_시간';

-- 시스템_쿼츠_실행_이력_PK
CREATE UNIQUE INDEX "sm_qrtz_exec_log_PK"
	ON "sm_qrtz_exec_log"
	( -- 시스템_쿼츠_실행_이력
		"qrtz_exec_log_seq" ASC -- 쿼츠실행이력SEQ
	)
;
-- 시스템_쿼츠_실행_이력
ALTER TABLE "sm_qrtz_exec_log"
	ADD CONSTRAINT "sm_qrtz_exec_log_PK"
		 -- 시스템_쿼츠_실행_이력_PK
	PRIMARY KEY 
	USING INDEX "sm_qrtz_exec_log_PK";

-- 시스템_쿼츠_실행_이력_PK
COMMENT ON CONSTRAINT "sm_qrtz_exec_log_PK" ON "sm_qrtz_exec_log" IS '시스템_쿼츠_실행_이력_PK';

-- 시스템_택배_설정
CREATE TABLE "sm_dlv_config"
(
	"dlv_config_seq"         int4        NOT NULL DEFAULT nextval('sm_dlv_config_seq'::regclass), -- 택배_설정_SEQ
	"center_seq"             int4        NOT NULL, -- 출고센터_SEQ
	"contract_biz_seq"       int4        NOT NULL, -- 계약_사업장_SEQ
	"dlv_co_cd"              varchar(50) NOT NULL, -- 택배_업체_코드
	"use_yn"                 char(1)     NOT NULL DEFAULT 'Y', -- 사용_여부
	"cust_id"                varchar(20) NULL,     -- 고객_ID
	"biz_no"                 varchar(20) NULL,     -- 사업자_번호
	"invoice_assign_type_cd" varchar(50) NOT NULL DEFAULT 'MANUAL', -- 송장_발급_유형_코드
	"token_num"              varchar(50) NULL,     -- 토큰_번호
	"token_exprtn_dtm"       varchar(14) NULL,     -- 토큰_유효_일시
	"invoice_no_start"       varchar(30) NULL,     -- 송장_번호_시작
	"invoice_no_end"         varchar(30) NULL,     -- 송장_번호_종료
	"invoice_no_current"     varchar(30) NULL,     -- 송장_번호_현재값
	"invoice_no_add"         varchar(30) NULL,     -- 송장_번호_추가대역
	"box_type_cd"            varchar(50) NULL,     -- 박스_유형_코드
	"frt_dv_cd"              varchar(50) NULL,     -- 정산_코드
	"frt"                    varchar(50) NULL,     -- 운임
	"reg_id"                 varchar(20) NOT NULL, -- 등록_ID
	"reg_dt"                 timestamp   NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"                 varchar(20) NULL,     -- 수정_ID
	"mod_dt"                 timestamp   NULL      -- 수정_일시
);

-- 시스템_택배_설정
COMMENT ON TABLE "sm_dlv_config" IS '시스템_택배_설정';

-- 택배_설정_SEQ
COMMENT ON COLUMN "sm_dlv_config"."dlv_config_seq" IS '택배_설정_SEQ';

-- 출고센터_SEQ
COMMENT ON COLUMN "sm_dlv_config"."center_seq" IS '출고센터_SEQ';

-- 계약_사업장_SEQ
COMMENT ON COLUMN "sm_dlv_config"."contract_biz_seq" IS '계약_사업장_SEQ';

-- 택배_업체_코드
COMMENT ON COLUMN "sm_dlv_config"."dlv_co_cd" IS '택배_업체_코드';

-- 사용_여부
COMMENT ON COLUMN "sm_dlv_config"."use_yn" IS '사용_여부';

-- 고객_ID
COMMENT ON COLUMN "sm_dlv_config"."cust_id" IS '고객_ID';

-- 사업자_번호
COMMENT ON COLUMN "sm_dlv_config"."biz_no" IS '사업자_번호';

-- 송장_발급_유형_코드
COMMENT ON COLUMN "sm_dlv_config"."invoice_assign_type_cd" IS '송장_발급_유형_코드';

-- 토큰_번호
COMMENT ON COLUMN "sm_dlv_config"."token_num" IS '토큰_번호';

-- 토큰_유효_일시
COMMENT ON COLUMN "sm_dlv_config"."token_exprtn_dtm" IS '토큰_유효_일시';

-- 송장_번호_시작
COMMENT ON COLUMN "sm_dlv_config"."invoice_no_start" IS '송장_번호_시작';

-- 송장_번호_종료
COMMENT ON COLUMN "sm_dlv_config"."invoice_no_end" IS '송장_번호_종료';

-- 송장_번호_현재값
COMMENT ON COLUMN "sm_dlv_config"."invoice_no_current" IS '송장_번호_현재값';

-- 송장_번호_추가대역
COMMENT ON COLUMN "sm_dlv_config"."invoice_no_add" IS '송장_번호_추가대역';

-- 박스_유형_코드
COMMENT ON COLUMN "sm_dlv_config"."box_type_cd" IS '박스_유형_코드';

-- 정산_코드
COMMENT ON COLUMN "sm_dlv_config"."frt_dv_cd" IS '정산_코드';

-- 운임
COMMENT ON COLUMN "sm_dlv_config"."frt" IS '운임';

-- 등록_ID
COMMENT ON COLUMN "sm_dlv_config"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "sm_dlv_config"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "sm_dlv_config"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "sm_dlv_config"."mod_dt" IS '수정일';

-- 시스템_택배_설정_PK
CREATE UNIQUE INDEX "sm_dlv_config_PK"
	ON "sm_dlv_config"
	( -- 시스템_택배_설정
		"dlv_config_seq" ASC -- 택배_설정_SEQ
	)
;
-- 시스템_택배_설정
ALTER TABLE "sm_dlv_config"
	ADD CONSTRAINT "sm_dlv_config_PK"
		 -- 시스템_택배_설정_PK
	PRIMARY KEY 
	USING INDEX "sm_dlv_config_PK";

-- 시스템_택배_설정_PK
COMMENT ON CONSTRAINT "sm_dlv_config_PK" ON "sm_dlv_config" IS '시스템_택배_설정_PK';

-- 시스템_택배_적용
CREATE TABLE "sm_dlv_config_applied"
(
	"dlv_config_applied_seq" int4        NOT NULL DEFAULT nextval('sm_dlv_config_applied_seq'::regclass), -- 택배_적용_SEQ
	"dlv_config_seq"         int4        NOT NULL, -- 택배_설정_SEQ
	"center_seq"             int4        NOT NULL, -- 센터_SEQ
	"biz_seq"                int4        NOT NULL, -- 사업장_SEQ
	"disp_no"                int2        NOT NULL DEFAULT 0, -- 우선_순위
	"reg_id"                 varchar(20) NOT NULL, -- 등록_ID
	"reg_dt"                 timestamp   NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"                 varchar(20) NULL,     -- 수정_ID
	"mod_dt"                 timestamp   NULL      -- 수정_일시
);

-- 시스템_택배_적용
COMMENT ON TABLE "sm_dlv_config_applied" IS '시스템_택배_적용';

-- 택배_적용_SEQ
COMMENT ON COLUMN "sm_dlv_config_applied"."dlv_config_applied_seq" IS '택배_적용_SEQ';

-- 택배_설정_SEQ
COMMENT ON COLUMN "sm_dlv_config_applied"."dlv_config_seq" IS '택배_설정_SEQ';

-- 센터_SEQ
COMMENT ON COLUMN "sm_dlv_config_applied"."center_seq" IS '센터_SEQ';

-- 사업장_SEQ
COMMENT ON COLUMN "sm_dlv_config_applied"."biz_seq" IS '사업장_ID';

-- 우선_순위
COMMENT ON COLUMN "sm_dlv_config_applied"."disp_no" IS '우선_순위';

-- 등록_ID
COMMENT ON COLUMN "sm_dlv_config_applied"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "sm_dlv_config_applied"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "sm_dlv_config_applied"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "sm_dlv_config_applied"."mod_dt" IS '수정일';

-- 시스템_택배_적용 유니크 인덱스
CREATE UNIQUE INDEX "UIX_sm_dlv_config_applied"
	ON "sm_dlv_config_applied"
	( -- 시스템_택배_적용
		"dlv_config_seq" ASC, -- 택배_설정_SEQ
		"center_seq" ASC, -- 센터_SEQ
		"biz_seq" ASC -- 사업장_SEQ
	);

-- 시스템_택배_적용 유니크 인덱스
COMMENT ON INDEX "UIX_sm_dlv_config_applied" IS '시스템_택배_적용 유니크 인덱스';

-- 시스템_택배_적용_PK
CREATE UNIQUE INDEX "sm_dlv_config_applied_PK"
	ON "sm_dlv_config_applied"
	( -- 시스템_택배_적용
		"dlv_config_applied_seq" ASC -- 택배_적용_SEQ
	)
;
-- 시스템_택배_적용
ALTER TABLE "sm_dlv_config_applied"
	ADD CONSTRAINT "sm_dlv_config_applied_PK"
		 -- 시스템_택배_적용_PK
	PRIMARY KEY 
	USING INDEX "sm_dlv_config_applied_PK";

-- 시스템_택배_적용_PK
COMMENT ON CONSTRAINT "sm_dlv_config_applied_PK" ON "sm_dlv_config_applied" IS '시스템_택배_적용_PK';

-- 시스템_택배_적용
ALTER TABLE "sm_dlv_config_applied"
	ADD CONSTRAINT "UK_sm_dlv_config_applied" -- 시스템_택배_적용 유니크 제약
	UNIQUE 
	USING INDEX "UIX_sm_dlv_config_applied";

-- 시스템_택배_적용 유니크 제약
COMMENT ON CONSTRAINT "UK_sm_dlv_config_applied" ON "sm_dlv_config_applied" IS '시스템_택배_적용 유니크 제약';

-- 시스템_파일
CREATE TABLE "sm_file"
(
	"file_seq"       int4         NOT NULL DEFAULT nextval('sm_file_seq'), -- 파일_SEQ
	"biz_seq"        int4         NOT NULL, -- 사업장_SEQ
	"file_div_cd"    varchar(50)  NULL,     -- 파일_구분_코드
	"file_uuid"      varchar(300) NOT NULL, -- 파일_고유ID
	"file_nm"        varchar(100) NULL,     -- 파일_명
	"file_path"      varchar(512) NULL,     -- 파일_경로
	"disp_no"        int2         NOT NULL DEFAULT 0, -- 표시_순서
	"file_size"      int4         NULL,     -- 파일_크기(KB)
	"file_extension" varchar(100) NULL,     -- 파일_확장자
	"use_yn"         char(1)      NOT NULL DEFAULT 'Y', -- 사용_여부
	"reg_id"         varchar(20)  NOT NULL, -- 등록_ID
	"reg_dt"         timestamp    NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"         varchar(20)  NULL,     -- 수정_ID
	"mod_dt"         timestamp    NULL      -- 수정_일시
);

-- 시스템_파일
COMMENT ON TABLE "sm_file" IS '시스템_파일';

-- 파일_SEQ
COMMENT ON COLUMN "sm_file"."file_seq" IS '파일SEQ';

-- 사업장_SEQ
COMMENT ON COLUMN "sm_file"."biz_seq" IS '사업장_SEQ';

-- 파일_구분_코드
COMMENT ON COLUMN "sm_file"."file_div_cd" IS '파일구분_코드';

-- 파일_고유ID
COMMENT ON COLUMN "sm_file"."file_uuid" IS '파일고유ID';

-- 파일_명
COMMENT ON COLUMN "sm_file"."file_nm" IS '파일이름';

-- 파일_경로
COMMENT ON COLUMN "sm_file"."file_path" IS '파일경로';

-- 표시_순서
COMMENT ON COLUMN "sm_file"."disp_no" IS '순서';

-- 파일_크기(KB)
COMMENT ON COLUMN "sm_file"."file_size" IS '파일크기';

-- 파일_확장자
COMMENT ON COLUMN "sm_file"."file_extension" IS '파일확장자';

-- 사용_여부
COMMENT ON COLUMN "sm_file"."use_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "sm_file"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "sm_file"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "sm_file"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "sm_file"."mod_dt" IS '수정일';

-- 시스템_파일 유니크 인덱스
CREATE UNIQUE INDEX "UIX_sm_file"
	ON "sm_file"
	( -- 시스템_파일
		"file_uuid" ASC -- 파일_고유ID
	);

-- 시스템_파일 유니크 인덱스
COMMENT ON INDEX "UIX_sm_file" IS '시스템_파일 유니크 인덱스';

-- 시스템_파일_PK
CREATE UNIQUE INDEX "sm_file_PK"
	ON "sm_file"
	( -- 시스템_파일
		"file_seq" ASC -- 파일_SEQ
	)
;
-- 시스템_파일
ALTER TABLE "sm_file"
	ADD CONSTRAINT "sm_file_PK"
		 -- 시스템_파일_PK
	PRIMARY KEY 
	USING INDEX "sm_file_PK";

-- 시스템_파일_PK
COMMENT ON CONSTRAINT "sm_file_PK" ON "sm_file" IS '시스템_파일_PK';

-- 시스템_파일
ALTER TABLE "sm_file"
	ADD CONSTRAINT "UK_sm_file" -- 시스템_파일 유니크 제약
	UNIQUE 
	USING INDEX "UIX_sm_file";

-- 시스템_파일 유니크 제약
COMMENT ON CONSTRAINT "UK_sm_file" ON "sm_file" IS '시스템_파일 유니크 제약';

-- 시스템_품목_옵션_설정
CREATE TABLE "sm_prod_opt_config"
(
	"biz_seq"                int4        NOT NULL, -- 사업장_SEQ
	"prod_div_cd"            varchar(50) NOT NULL, -- 품목_분류_코드
	"prod_sku_mng_cd"        varchar(50) NOT NULL DEFAULT 'N', -- SKU_관리_유형_코드
	"prod_mng_ymd_yn"        char(1)     NOT NULL DEFAULT 'N', -- 제조일자_여부
	"prod_eff_mng_yn"        char(1)     NOT NULL DEFAULT 'N', -- 유통기한관리_여부
	"prod_lot_no_yn"         char(1)     NOT NULL DEFAULT 'N', -- LOT_여부
	"prod_cn_mng_yn"         char(1)     NOT NULL DEFAULT 'N', -- C/N관리_여부
	"prod_sku2_mng_yn"       char(1)     NOT NULL DEFAULT 'N', -- 파렛트관리_여부
	"label_paper_seq"        int4        NOT NULL, -- 라벨용지_SEQ
	"parent_label_paper_seq" int4        NULL,     -- 상위_라벨용지_SEQ
	"reg_id"                 varchar(20) NOT NULL, -- 등록_ID
	"reg_dt"                 timestamp   NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"                 varchar(20) NULL,     -- 수정_ID
	"mod_dt"                 timestamp   NULL      -- 수정_일시
);

-- 시스템_품목_옵션_설정
COMMENT ON TABLE "sm_prod_opt_config" IS '시스템_품목_옵션_설정';

-- 사업장_SEQ
COMMENT ON COLUMN "sm_prod_opt_config"."biz_seq" IS '사업장_ID';

-- 품목_분류_코드
COMMENT ON COLUMN "sm_prod_opt_config"."prod_div_cd" IS '품목_분류_코드';

-- SKU_관리_유형_코드
COMMENT ON COLUMN "sm_prod_opt_config"."prod_sku_mng_cd" IS 'SKU_관리_유형_코드';

-- 제조일자_여부
COMMENT ON COLUMN "sm_prod_opt_config"."prod_mng_ymd_yn" IS '제조일자_여부';

-- 유통기한관리_여부
COMMENT ON COLUMN "sm_prod_opt_config"."prod_eff_mng_yn" IS '유통기한관리_여부';

-- LOT_여부
COMMENT ON COLUMN "sm_prod_opt_config"."prod_lot_no_yn" IS 'LOT_여부';

-- C/N관리_여부
COMMENT ON COLUMN "sm_prod_opt_config"."prod_cn_mng_yn" IS 'C/N관리_여부';

-- 파렛트관리_여부
COMMENT ON COLUMN "sm_prod_opt_config"."prod_sku2_mng_yn" IS '파렛트관리_여부';

-- 라벨용지_SEQ
COMMENT ON COLUMN "sm_prod_opt_config"."label_paper_seq" IS '품목ID';

-- 상위_라벨용지_SEQ
COMMENT ON COLUMN "sm_prod_opt_config"."parent_label_paper_seq" IS '상위_라벨용지_SEQ';

-- 등록_ID
COMMENT ON COLUMN "sm_prod_opt_config"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "sm_prod_opt_config"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "sm_prod_opt_config"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "sm_prod_opt_config"."mod_dt" IS '수정일';

-- 시스템_품목_옵션_설정_PK
CREATE UNIQUE INDEX "sm_prod_opt_config_PK"
	ON "sm_prod_opt_config"
	( -- 시스템_품목_옵션_설정
		"biz_seq" ASC, -- 사업장_SEQ
		"prod_div_cd" ASC -- 품목_분류_코드
	)
;
-- 시스템_품목_옵션_설정
ALTER TABLE "sm_prod_opt_config"
	ADD CONSTRAINT "sm_prod_opt_config_PK"
		 -- 시스템_품목_옵션_설정_PK
	PRIMARY KEY 
	USING INDEX "sm_prod_opt_config_PK";

-- 시스템_품목_옵션_설정_PK
COMMENT ON CONSTRAINT "sm_prod_opt_config_PK" ON "sm_prod_opt_config" IS '시스템_품목_옵션_설정_PK';

-- 임시 테이블
CREATE TABLE "Temporary"
(
	"last_login_jti" char(36) NULL -- 마지막_로그인_JWT키
);

-- 임시 테이블
COMMENT ON TABLE "Temporary" IS '임시 테이블';

-- 마지막_로그인_JWT키
COMMENT ON COLUMN "Temporary"."last_login_jti" IS '부서_코드';

-- 시스템_비밀번호_변경_이력
CREATE TABLE "sm_user_pwd_history"
(
	"user_pwd_history_seq" int4         NOT NULL DEFAULT nextval('sm_user_pwd_history_seq'), -- 사용자_비밀변호_변경_이력_SEQ
	"user_id"              varchar(20)  NOT NULL, -- 사용자_ID
	"password"             varchar(500) NOT NULL, -- 패스워드
	"pwd_upd_date"         timestamp    NOT NULL, -- 비밀번호_수정_일시
	"reg_id"               varchar(20)  NOT NULL, -- 등록_ID
	"reg_dt"               timestamp    NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"               varchar(20)  NULL,     -- 수정_ID
	"mod_dt"               timestamp    NULL      -- 수정_일시
);

-- 시스템_비밀번호_변경_이력
COMMENT ON TABLE "sm_user_pwd_history" IS '시스템_비밀번호_변경_이력';

-- 사용자_비밀변호_변경_이력_SEQ
COMMENT ON COLUMN "sm_user_pwd_history"."user_pwd_history_seq" IS '사용자_비밀변호_변경_이력_SEQ';

-- 사용자_ID
COMMENT ON COLUMN "sm_user_pwd_history"."user_id" IS '사용자ID';

-- 패스워드
COMMENT ON COLUMN "sm_user_pwd_history"."password" IS '패스워드';

-- 비밀번호_수정_일시
COMMENT ON COLUMN "sm_user_pwd_history"."pwd_upd_date" IS '비밀번호_수정_일시';

-- 등록_ID
COMMENT ON COLUMN "sm_user_pwd_history"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "sm_user_pwd_history"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "sm_user_pwd_history"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "sm_user_pwd_history"."mod_dt" IS '수정일';

-- 시스템_비밀번호_변경_이력(NEW)_PK
CREATE UNIQUE INDEX "sm_user_pwd_history_PK"
	ON "sm_user_pwd_history"
	( -- 시스템_비밀번호_변경_이력
		"user_pwd_history_seq" ASC -- 사용자_비밀변호_변경_이력_SEQ
	)
;
-- 시스템_비밀번호_변경_이력
ALTER TABLE "sm_user_pwd_history"
	ADD CONSTRAINT "sm_user_pwd_history_PK"
		 -- 시스템_비밀번호_변경_이력(NEW)_PK
	PRIMARY KEY 
	USING INDEX "sm_user_pwd_history_PK";

-- 시스템_비밀번호_변경_이력(NEW)_PK
COMMENT ON CONSTRAINT "sm_user_pwd_history_PK" ON "sm_user_pwd_history" IS '시스템_비밀번호_변경_이력(NEW)_PK';

-- 시스템_푸시_이력
CREATE TABLE "sm_push_history"
(
	"push_history_seq" bigint        NOT NULL DEFAULT nextval('sm_push_history_seq'), -- 푸시_이력_SEQ
	"push_cycle_seq"   int4          NULL     DEFAULT nextval('mdm_prod_seq'), -- 푸시_주기_SEQ
	"biz_seq"          int4          NOT NULL, -- 사업장_SEQ
	"center_seq"       int4          NOT NULL, -- 센터_SEQ
	"group_seq"        int4          NOT NULL, -- 그룹_SEQ
	"push_type_cd"     varchar(50)   NOT NULL, -- 푸시_유형_코드
	"push_message"     varchar(1000) NOT NULL, -- 푸시_내용
	"send_dt"          timestamp     NOT NULL, -- 보낸_일시
	"prod_seq"         int4          NULL     DEFAULT nextval('mdm_prod_seq'), -- 품목_SEQ
	"req_no"           varchar(30)   NULL,     -- 업무_번호
	"cfm_dt"           timestamp     NULL,     -- 확인_일시
	"reg_id"           varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"           timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"           varchar(20)   NULL,     -- 수정_ID
	"mod_dt"           timestamp     NULL      -- 수정_일시
);

-- 시스템_푸시_이력
COMMENT ON TABLE "sm_push_history" IS '시스템_푸시_이력';

-- 푸시_이력_SEQ
COMMENT ON COLUMN "sm_push_history"."push_history_seq" IS '파일SEQ';

-- 푸시_주기_SEQ
COMMENT ON COLUMN "sm_push_history"."push_cycle_seq" IS '품목ID';

-- 사업장_SEQ
COMMENT ON COLUMN "sm_push_history"."biz_seq" IS '사업장_SEQ';

-- 센터_SEQ
COMMENT ON COLUMN "sm_push_history"."center_seq" IS '단위_코드';

-- 그룹_SEQ
COMMENT ON COLUMN "sm_push_history"."group_seq" IS '단위_코드';

-- 푸시_유형_코드
COMMENT ON COLUMN "sm_push_history"."push_type_cd" IS '푸시_유형_코드';

-- 푸시_내용
COMMENT ON COLUMN "sm_push_history"."push_message" IS '푸시_내용';

-- 보낸_일시
COMMENT ON COLUMN "sm_push_history"."send_dt" IS '등록일';

-- 품목_SEQ
COMMENT ON COLUMN "sm_push_history"."prod_seq" IS '품목ID';

-- 업무_번호
COMMENT ON COLUMN "sm_push_history"."req_no" IS '품목ID';

-- 확인_일시
COMMENT ON COLUMN "sm_push_history"."cfm_dt" IS '수정일';

-- 등록_ID
COMMENT ON COLUMN "sm_push_history"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "sm_push_history"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "sm_push_history"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "sm_push_history"."mod_dt" IS '수정일';

-- 시스템_푸시_이력(NEW)_PK
CREATE UNIQUE INDEX "sm_push_history_PK"
	ON "sm_push_history"
	( -- 시스템_푸시_이력
		"push_history_seq" ASC -- 푸시_이력_SEQ
	)
;
-- 시스템_푸시_이력
ALTER TABLE "sm_push_history"
	ADD CONSTRAINT "sm_push_history_PK"
		 -- 시스템_푸시_이력(NEW)_PK
	PRIMARY KEY 
	USING INDEX "sm_push_history_PK";

-- 시스템_푸시_이력(NEW)_PK
COMMENT ON CONSTRAINT "sm_push_history_PK" ON "sm_push_history" IS '시스템_푸시_이력(NEW)_PK';

-- 시스템_푸시_미수신
CREATE TABLE "sm_push_unrcv"
(
	"user_id"      varchar(20) NOT NULL, -- 유저ID
	"push_type_cd" varchar(50) NOT NULL, -- 푸시_유형_코드
	"reg_id"       varchar(20) NOT NULL, -- 등록_ID
	"reg_dt"       timestamp   NOT NULL DEFAULT now() -- 등록_일시
);

-- 시스템_푸시_미수신
COMMENT ON TABLE "sm_push_unrcv" IS '시스템_푸시_미수신';

-- 유저ID
COMMENT ON COLUMN "sm_push_unrcv"."user_id" IS '유저ID';

-- 푸시_유형_코드
COMMENT ON COLUMN "sm_push_unrcv"."push_type_cd" IS '푸시_유형_코드';

-- 등록_ID
COMMENT ON COLUMN "sm_push_unrcv"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "sm_push_unrcv"."reg_dt" IS '등록일';

-- 시스템_푸시_미수신(NEW)_PK
CREATE UNIQUE INDEX "sm_push_unrcv_PK"
	ON "sm_push_unrcv"
	( -- 시스템_푸시_미수신
		"user_id" ASC, -- 유저ID
		"push_type_cd" ASC -- 푸시_유형_코드
	)
;
-- 시스템_푸시_미수신
ALTER TABLE "sm_push_unrcv"
	ADD CONSTRAINT "sm_push_unrcv_PK"
		 -- 시스템_푸시_미수신(NEW)_PK
	PRIMARY KEY 
	USING INDEX "sm_push_unrcv_PK";

-- 시스템_푸시_미수신(NEW)_PK
COMMENT ON CONSTRAINT "sm_push_unrcv_PK" ON "sm_push_unrcv" IS '시스템_푸시_미수신(NEW)_PK';

-- 시스템_푸시_주기
CREATE TABLE "sm_push_cycle"
(
	"push_cycle_seq" int4          NOT NULL DEFAULT nextval('sm_push_cycle_seq'), -- 푸시_주기_SEQ
	"biz_seq"        int4          NOT NULL, -- 사업장_SEQ
	"center_seq_str" varchar(1000) NULL,     -- 센터_SEQ_문자열
	"group_seq_str"  varchar(1000) NULL,     -- 그룹_SEQ_문자열
	"push_type_cd"   varchar(50)   NOT NULL, -- 푸시_유형_코드
	"push_cycle_cd"  varchar(50)   NOT NULL, -- 푸시_주기_코드
	"push_note"      varchar(1000) NOT NULL, -- 푸시_내용
	"mon"            char(1)       NULL     DEFAULT 'N', -- 월_요일
	"tue"            char(1)       NULL     DEFAULT 'N', -- 화_요일
	"wed"            char(1)       NULL     DEFAULT 'N', -- 수_요일
	"thu"            char(1)       NULL     DEFAULT 'N', -- 목_요일
	"fri"            char(1)       NULL     DEFAULT 'N', -- 금_요일
	"sat"            char(1)       NULL     DEFAULT 'N', -- 토_요일
	"sun"            char(1)       NULL     DEFAULT 'N', -- 일_요일
	"push_cycle_dd"  char(2)       NULL,     -- 푸시_반복_일
	"push_start_ymd" varchar(8)    NULL,     -- 푸시_시작_연월일
	"push_end_ymd"   varchar(8)    NULL,     -- 푸시_종료_연월일
	"push_send_hms1" varchar(6)    NULL,     -- 푸시_발송_시분초1
	"push_send_hms2" varchar(6)    NULL,     -- 푸시_발송_시분초2
	"use_yn"         char(1)       NOT NULL DEFAULT 'Y', -- 사용_여부
	"reg_id"         varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"         timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"         varchar(20)   NULL,     -- 수정_ID
	"mod_dt"         timestamp     NULL      -- 수정_일시
);

-- 시스템_푸시_주기
COMMENT ON TABLE "sm_push_cycle" IS '시스템_푸시_주기';

-- 푸시_주기_SEQ
COMMENT ON COLUMN "sm_push_cycle"."push_cycle_seq" IS '품목ID';

-- 사업장_SEQ
COMMENT ON COLUMN "sm_push_cycle"."biz_seq" IS '사업장_SEQ';

-- 센터_SEQ_문자열
COMMENT ON COLUMN "sm_push_cycle"."center_seq_str" IS '센터_SEQ_문자열';

-- 그룹_SEQ_문자열
COMMENT ON COLUMN "sm_push_cycle"."group_seq_str" IS '그룹_SEQ_문자열';

-- 푸시_유형_코드
COMMENT ON COLUMN "sm_push_cycle"."push_type_cd" IS '푸시_유형_코드';

-- 푸시_주기_코드
COMMENT ON COLUMN "sm_push_cycle"."push_cycle_cd" IS '푸시_주기_코드';

-- 푸시_내용
COMMENT ON COLUMN "sm_push_cycle"."push_note" IS '備考';

-- 월_요일
COMMENT ON COLUMN "sm_push_cycle"."mon" IS '삭제_여부';

-- 화_요일
COMMENT ON COLUMN "sm_push_cycle"."tue" IS '삭제_여부';

-- 수_요일
COMMENT ON COLUMN "sm_push_cycle"."wed" IS '삭제_여부';

-- 목_요일
COMMENT ON COLUMN "sm_push_cycle"."thu" IS '삭제_여부';

-- 금_요일
COMMENT ON COLUMN "sm_push_cycle"."fri" IS '삭제_여부';

-- 토_요일
COMMENT ON COLUMN "sm_push_cycle"."sat" IS '삭제_여부';

-- 일_요일
COMMENT ON COLUMN "sm_push_cycle"."sun" IS '삭제_여부';

-- 푸시_반복_일
COMMENT ON COLUMN "sm_push_cycle"."push_cycle_dd" IS '출고_요청_일자';

-- 푸시_시작_연월일
COMMENT ON COLUMN "sm_push_cycle"."push_start_ymd" IS '출고_요청_일자';

-- 푸시_종료_연월일
COMMENT ON COLUMN "sm_push_cycle"."push_end_ymd" IS '출고_요청_일자';

-- 푸시_발송_시분초1
COMMENT ON COLUMN "sm_push_cycle"."push_send_hms1" IS '푸시_발송_시분초1';

-- 푸시_발송_시분초2
COMMENT ON COLUMN "sm_push_cycle"."push_send_hms2" IS '푸시_발송_시분초2';

-- 사용_여부
COMMENT ON COLUMN "sm_push_cycle"."use_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "sm_push_cycle"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "sm_push_cycle"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "sm_push_cycle"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "sm_push_cycle"."mod_dt" IS '수정일';

-- 시스템_푸시_주기(NEW)_PK
CREATE UNIQUE INDEX "sm_push_cycle_PK"
	ON "sm_push_cycle"
	( -- 시스템_푸시_주기
		"push_cycle_seq" ASC -- 푸시_주기_SEQ
	)
;
-- 시스템_푸시_주기
ALTER TABLE "sm_push_cycle"
	ADD CONSTRAINT "sm_push_cycle_PK"
		 -- 시스템_푸시_주기(NEW)_PK
	PRIMARY KEY 
	USING INDEX "sm_push_cycle_PK";

-- 시스템_푸시_주기(NEW)_PK
COMMENT ON CONSTRAINT "sm_push_cycle_PK" ON "sm_push_cycle" IS '시스템_푸시_주기(NEW)_PK';

-- 시스템_쿼츠_작업_현황
CREATE TABLE "sm_qrtz_job_state"
(
	"job_cls_nm"    varchar(100) NOT NULL, -- 작업_클래스_명
	"job_nm"        varchar(100) NULL,     -- 작업_명
	"job_status_cd" varchar(100) NULL,     -- 작업_상태_코드
	"proc_ymd"      varchar(8)   NULL,     -- 처리_연월일
	"proc_hms"      varchar(6)   NULL      -- 처리_시분초
);

-- 시스템_쿼츠_작업_현황
COMMENT ON TABLE "sm_qrtz_job_state" IS '시스템_쿼츠_작업_현황';

-- 작업_클래스_명
COMMENT ON COLUMN "sm_qrtz_job_state"."job_cls_nm" IS '작업_클래스_명';

-- 작업_명
COMMENT ON COLUMN "sm_qrtz_job_state"."job_nm" IS '작업_명';

-- 작업_상태_코드
COMMENT ON COLUMN "sm_qrtz_job_state"."job_status_cd" IS '작업_상태_코드';

-- 처리_연월일
COMMENT ON COLUMN "sm_qrtz_job_state"."proc_ymd" IS '요청_일자';

-- 처리_시분초
COMMENT ON COLUMN "sm_qrtz_job_state"."proc_hms" IS '요청_시간';

-- 시스템_쿼츠_작업_현황(NEW)_PK
CREATE UNIQUE INDEX "sm_qrtz_job_state_PK"
	ON "sm_qrtz_job_state"
	( -- 시스템_쿼츠_작업_현황
		"job_cls_nm" ASC -- 작업_클래스_명
	)
;
-- 시스템_쿼츠_작업_현황
ALTER TABLE "sm_qrtz_job_state"
	ADD CONSTRAINT "sm_qrtz_job_state_PK"
		 -- 시스템_쿼츠_작업_현황(NEW)_PK
	PRIMARY KEY 
	USING INDEX "sm_qrtz_job_state_PK";

-- 시스템_쿼츠_작업_현황(NEW)_PK
COMMENT ON CONSTRAINT "sm_qrtz_job_state_PK" ON "sm_qrtz_job_state" IS '시스템_쿼츠_작업_현황(NEW)_PK';

-- 시스템_파일_업무
CREATE TABLE "sm_file_req"
(
	"file_seq"    int4        NOT NULL, -- 파일_SEQ
	"req_type_cd" varchar(50) NOT NULL, -- 업무_유형_코드
	"req_seq"     int4        NOT NULL, -- 업무_SEQ
	"reg_id"      varchar(20) NOT NULL, -- 등록_ID
	"reg_dt"      timestamp   NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"      varchar(20) NULL,     -- 수정_ID
	"mod_dt"      timestamp   NULL      -- 수정_일시
);

-- 시스템_파일_업무
COMMENT ON TABLE "sm_file_req" IS '시스템_파일_업무';

-- 파일_SEQ
COMMENT ON COLUMN "sm_file_req"."file_seq" IS '파일_SEQ';

-- 업무_유형_코드
COMMENT ON COLUMN "sm_file_req"."req_type_cd" IS '파일SEQ';

-- 업무_SEQ
COMMENT ON COLUMN "sm_file_req"."req_seq" IS '파일SEQ';

-- 등록_ID
COMMENT ON COLUMN "sm_file_req"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "sm_file_req"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "sm_file_req"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "sm_file_req"."mod_dt" IS '수정일';

-- 시스템_파일_업무(NEW)_PK
CREATE UNIQUE INDEX "sm_file_req_PK"
	ON "sm_file_req"
	( -- 시스템_파일_업무
		"file_seq" ASC, -- 파일_SEQ
		"req_type_cd" ASC, -- 업무_유형_코드
		"req_seq" ASC -- 업무_SEQ
	)
;
-- 시스템_파일_업무
ALTER TABLE "sm_file_req"
	ADD CONSTRAINT "sm_file_req_PK"
		 -- 시스템_파일_업무(NEW)_PK
	PRIMARY KEY 
	USING INDEX "sm_file_req_PK";

-- 시스템_파일_업무(NEW)_PK
COMMENT ON CONSTRAINT "sm_file_req_PK" ON "sm_file_req" IS '시스템_파일_업무(NEW)_PK';

-- 시스템_API_설정
CREATE TABLE "sm_api_config"
(
	"biz_seq"         int4         NOT NULL, -- 사업장_SEQ
	"if_id"           varchar(50)  NOT NULL, -- IF_ID
	"if_nm"           varchar(100) NOT NULL, -- IF_명
	"api_url_dev"     varchar(512) NOT NULL, -- IF_URL(dev)
	"api_url_test"    varchar(512) NOT NULL, -- IF_URL(test)
	"api_url"         varchar(512) NOT NULL, -- IF_URL(prod)
	"api_method_cd"   varchar(50)  NOT NULL, -- 메소드
	"if_type_cd"      varchar(50)  NOT NULL DEFAULT 'N', -- IF_유형_코드
	"if_proc_type_cd" varchar(50)  NOT NULL DEFAULT 'N', -- IF_처리_유형_코드
	"req_json_data"   text         NULL,     -- 요청_데이터(샘플)
	"use_yn"          char(1)      NOT NULL DEFAULT 'Y', -- 사용_유무
	"reg_id"          varchar(20)  NOT NULL, -- 등록_ID
	"reg_dt"          timestamp    NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"          varchar(20)  NULL,     -- 수정_ID
	"mod_dt"          timestamp    NULL      -- 수정_일시
);

-- 시스템_API_설정
COMMENT ON TABLE "sm_api_config" IS '시스템_API_설정';

-- 사업장_SEQ
COMMENT ON COLUMN "sm_api_config"."biz_seq" IS '사업장_SEQ';

-- IF_ID
COMMENT ON COLUMN "sm_api_config"."if_id" IS 'IF_ID';

-- IF_명
COMMENT ON COLUMN "sm_api_config"."if_nm" IS 'IF_명';

-- IF_URL(dev)
COMMENT ON COLUMN "sm_api_config"."api_url_dev" IS '파일고유ID';

-- IF_URL(test)
COMMENT ON COLUMN "sm_api_config"."api_url_test" IS '파일고유ID';

-- IF_URL(prod)
COMMENT ON COLUMN "sm_api_config"."api_url" IS '파일고유ID';

-- 메소드
COMMENT ON COLUMN "sm_api_config"."api_method_cd" IS '메소드';

-- IF_유형_코드
COMMENT ON COLUMN "sm_api_config"."if_type_cd" IS '배치_유형_코드';

-- IF_처리_유형_코드
COMMENT ON COLUMN "sm_api_config"."if_proc_type_cd" IS '배치_유형_코드';

-- 요청_데이터(샘플)
COMMENT ON COLUMN "sm_api_config"."req_json_data" IS '요청_데이터';

-- 사용_유무
COMMENT ON COLUMN "sm_api_config"."use_yn" IS '사용_유무';

-- 등록_ID
COMMENT ON COLUMN "sm_api_config"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "sm_api_config"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "sm_api_config"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "sm_api_config"."mod_dt" IS '수정일';

-- 시스템_API_설정_PK
CREATE UNIQUE INDEX "sm_api_config_PK"
	ON "sm_api_config"
	( -- 시스템_API_설정
		"biz_seq" ASC, -- 사업장_SEQ
		"if_id" ASC -- IF_ID
	)
;
-- 시스템_API_설정
ALTER TABLE "sm_api_config"
	ADD CONSTRAINT "sm_api_config_PK"
		 -- 시스템_API_설정_PK
	PRIMARY KEY 
	USING INDEX "sm_api_config_PK";

-- 시스템_API_설정_PK
COMMENT ON CONSTRAINT "sm_api_config_PK" ON "sm_api_config" IS '시스템_API_설정_PK';

-- MDM_세트_구성
CREATE TABLE "mdm_st_config"
(
	"st_config_seq" int4          NOT NULL DEFAULT nextval('mdm_st_config_seq'), -- 세트_구성_SEQ
	"biz_seq"       int4          NOT NULL, -- 사업장_SEQ
	"st_prod_seq"   int4          NOT NULL, -- 세트_품목_SEQ
	"note"          varchar(1000) NULL,     -- 비고
	"use_yn"        char(1)       NOT NULL DEFAULT 'Y', -- 사용_여부
	"reg_id"        varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"        timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"        varchar(20)   NULL,     -- 수정_ID
	"mod_dt"        timestamp     NULL      -- 수정_일시
);

-- MDM_세트_구성
COMMENT ON TABLE "mdm_st_config" IS 'MDM_세트_구성';

-- 세트_구성_SEQ
COMMENT ON COLUMN "mdm_st_config"."st_config_seq" IS '세트_구성_SEQ';

-- 사업장_SEQ
COMMENT ON COLUMN "mdm_st_config"."biz_seq" IS '사업장_SEQ';

-- 세트_품목_SEQ
COMMENT ON COLUMN "mdm_st_config"."st_prod_seq" IS '세트_품목_SEQ';

-- 비고
COMMENT ON COLUMN "mdm_st_config"."note" IS '비고';

-- 사용_여부
COMMENT ON COLUMN "mdm_st_config"."use_yn" IS '삭제 여부';

-- 등록_ID
COMMENT ON COLUMN "mdm_st_config"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "mdm_st_config"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "mdm_st_config"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "mdm_st_config"."mod_dt" IS '수정일';

-- MDM_세트_구성 기본키
CREATE UNIQUE INDEX "PK_mdm_st_config"
	ON "mdm_st_config"
	( -- MDM_세트_구성
		"st_config_seq" ASC -- 세트_구성_SEQ
	)
;
-- MDM_세트_구성
ALTER TABLE "mdm_st_config"
	ADD CONSTRAINT "PK_mdm_st_config"
		 -- MDM_세트_구성 기본키
	PRIMARY KEY 
	USING INDEX "PK_mdm_st_config";

-- MDM_세트_구성 기본키
COMMENT ON CONSTRAINT "PK_mdm_st_config" ON "mdm_st_config" IS 'MDM_세트_구성 기본키';

-- MDM_세트구성_상세
CREATE TABLE "mdm_st_config_dtl"
(
	"st_config_dtl_seq" bigint        NOT NULL DEFAULT nextval('mdm_st_config_dtl_seq'), -- 세트_구성_상세_SEQ
	"st_config_seq"     int4          NOT NULL, -- 세트_구성_SEQ
	"prod_seq"          int4          NOT NULL, -- 품목_SEQ
	"config_qty"        decimal(10,2) NOT NULL DEFAULT 1.00, -- 구성_수량
	"reg_id"            varchar(20)   NOT NULL, -- 등록_ID
	"reg_dt"            timestamp     NOT NULL DEFAULT now(), -- 등록_일시
	"mod_id"            varchar(20)   NULL,     -- 수정_ID
	"mod_dt"            timestamp     NULL      -- 수정_일시
);

-- MDM_세트구성_상세
COMMENT ON TABLE "mdm_st_config_dtl" IS 'MDM_세트구성_상세';

-- 세트_구성_상세_SEQ
COMMENT ON COLUMN "mdm_st_config_dtl"."st_config_dtl_seq" IS '세트_구성_상세_SEQ';

-- 세트_구성_SEQ
COMMENT ON COLUMN "mdm_st_config_dtl"."st_config_seq" IS '세트_구성_SEQ';

-- 품목_SEQ
COMMENT ON COLUMN "mdm_st_config_dtl"."prod_seq" IS '품목_SEQ';

-- 구성_수량
COMMENT ON COLUMN "mdm_st_config_dtl"."config_qty" IS '구성_수량';

-- 등록_ID
COMMENT ON COLUMN "mdm_st_config_dtl"."reg_id" IS '등록자';

-- 등록_일시
COMMENT ON COLUMN "mdm_st_config_dtl"."reg_dt" IS '등록일';

-- 수정_ID
COMMENT ON COLUMN "mdm_st_config_dtl"."mod_id" IS '수정자';

-- 수정_일시
COMMENT ON COLUMN "mdm_st_config_dtl"."mod_dt" IS '수정일';

-- MDM_세트구성_상세 기본키
CREATE UNIQUE INDEX "PK_mdm_st_config_dtl"
	ON "mdm_st_config_dtl"
	( -- MDM_세트구성_상세
		"st_config_dtl_seq" ASC -- 세트_구성_상세_SEQ
	)
;
-- MDM_세트구성_상세
ALTER TABLE "mdm_st_config_dtl"
	ADD CONSTRAINT "PK_mdm_st_config_dtl"
		 -- MDM_세트구성_상세 기본키
	PRIMARY KEY 
	USING INDEX "PK_mdm_st_config_dtl";

-- MDM_세트구성_상세 기본키
COMMENT ON CONSTRAINT "PK_mdm_st_config_dtl" ON "mdm_st_config_dtl" IS 'MDM_세트구성_상세 기본키';

-- MDM_세트구성_상세
ALTER TABLE "mdm_st_config_dtl"
	ADD CONSTRAINT "FK_mdm_st_config_TO_mdm_st_config_dtl"
	 -- MDM_세트_구성 -> MDM_세트구성_상세
		FOREIGN KEY (
			"st_config_seq" -- 세트_구성_SEQ
		)
		REFERENCES "mdm_st_config" ( -- MDM_세트_구성
			"st_config_seq" -- 세트_구성_SEQ
		),
	ADD INDEX "FK_mdm_st_config_TO_mdm_st_config_dtl" (
		"st_config_seq" ASC -- 세트_구성_SEQ
	);

-- MDM_세트_구성 -> MDM_세트구성_상세
COMMENT ON CONSTRAINT "FK_mdm_st_config_TO_mdm_st_config_dtl" ON "mdm_st_config_dtl" IS 'MDM_세트_구성 -> MDM_세트구성_상세';

-- MDM_거래처_품목
ALTER TABLE "mdm_cont_prod"
	ADD CONSTRAINT "mdm_cont_TO_mdm_cont_prod"
	 -- MDM_거래처_TO_MDM_거래처_품목
		FOREIGN KEY (
			"cont_seq" -- 거래처_SEQ
		)
		REFERENCES "mdm_cont" ( -- MDM_거래처
			"cont_seq" -- 거래처_SEQ
		);

-- MDM_거래처_TO_MDM_거래처_품목
COMMENT ON CONSTRAINT "mdm_cont_TO_mdm_cont_prod" ON "mdm_cont_prod" IS 'MDM_거래처_TO_MDM_거래처_품목';

-- MDM_거래처_품목
ALTER TABLE "mdm_cont_prod"
	ADD CONSTRAINT "mdm_prod_TO_mdm_cont_prod"
	 -- MDM_품목_TO_MDM_거래처_품목
		FOREIGN KEY (
			"prod_seq" -- 품목_SEQ
		)
		REFERENCES "mdm_prod" ( -- MDM_품목
			"prod_seq" -- 품목_SEQ
		);

-- MDM_품목_TO_MDM_거래처_품목
COMMENT ON CONSTRAINT "mdm_prod_TO_mdm_cont_prod" ON "mdm_cont_prod" IS 'MDM_품목_TO_MDM_거래처_품목';

-- MDM_거래처_품목
ALTER TABLE "mdm_cont_prod"
	ADD CONSTRAINT "mdm_biz_TO_mdm_cont_prod"
	 -- MDM_사업장_TO_MDM_거래처_품목
		FOREIGN KEY (
			"biz_seq" -- 사업장_SEQ
		)
		REFERENCES "mdm_biz" ( -- MDM_사업장
			"biz_seq" -- 사업장_SEQ
		);

-- MDM_사업장_TO_MDM_거래처_품목
COMMENT ON CONSTRAINT "mdm_biz_TO_mdm_cont_prod" ON "mdm_cont_prod" IS 'MDM_사업장_TO_MDM_거래처_품목';

-- MDM_권한사업장
ALTER TABLE "mdm_user_biz"
	ADD CONSTRAINT "mdm_biz_TO_mdm_user_biz"
	 -- MDM_사업장_TO_MDM_권한사업장
		FOREIGN KEY (
			"biz_seq" -- 사업장_SEQ
		)
		REFERENCES "mdm_biz" ( -- MDM_사업장
			"biz_seq" -- 사업장_SEQ
		);

-- MDM_사업장_TO_MDM_권한사업장
COMMENT ON CONSTRAINT "mdm_biz_TO_mdm_user_biz" ON "mdm_user_biz" IS 'MDM_사업장_TO_MDM_권한사업장';

-- MDM_권한사업장
ALTER TABLE "mdm_user_biz"
	ADD CONSTRAINT "mdm_user_TO_mdm_user_biz"
	 -- MDM_사용자(NEW)_TO_MDM_권한사업장
		FOREIGN KEY (
			"user_id" -- 사용자_ID
		)
		REFERENCES "mdm_user" ( -- MDM_사용자
			"user_id" -- 사용자_ID
		);

-- MDM_사용자(NEW)_TO_MDM_권한사업장
COMMENT ON CONSTRAINT "mdm_user_TO_mdm_user_biz" ON "mdm_user_biz" IS 'MDM_사용자(NEW)_TO_MDM_권한사업장';

-- MDM_권한센터
ALTER TABLE "mdm_user_center"
	ADD CONSTRAINT "mdm_center_TO_mdm_user_center"
	 -- MDM_센터_TO_MDM_권한센터
		FOREIGN KEY (
			"center_seq" -- 센터_SEQ
		)
		REFERENCES "mdm_center" ( -- MDM_센터
			"center_seq" -- 센터_SEQ
		);

-- MDM_센터_TO_MDM_권한센터
COMMENT ON CONSTRAINT "mdm_center_TO_mdm_user_center" ON "mdm_user_center" IS 'MDM_센터_TO_MDM_권한센터';

-- MDM_권한센터
ALTER TABLE "mdm_user_center"
	ADD CONSTRAINT "mdm_user_TO_mdm_user_center"
	 -- MDM_사용자(NEW)_TO_MDM_권한센터
		FOREIGN KEY (
			"user_id" -- 사용자_ID
		)
		REFERENCES "mdm_user" ( -- MDM_사용자
			"user_id" -- 사용자_ID
		);

-- MDM_사용자(NEW)_TO_MDM_권한센터
COMMENT ON CONSTRAINT "mdm_user_TO_mdm_user_center" ON "mdm_user_center" IS 'MDM_사용자(NEW)_TO_MDM_권한센터';

-- MDM_문서번호
ALTER TABLE "mdm_doc_no"
	ADD CONSTRAINT "mdm_biz_TO_mdm_doc_no"
	 -- MDM_사업장_TO_MDM_문서번호
		FOREIGN KEY (
			"biz_seq" -- 사업장_SEQ
		)
		REFERENCES "mdm_biz" ( -- MDM_사업장
			"biz_seq" -- 사업장_SEQ
		);

-- MDM_사업장_TO_MDM_문서번호
COMMENT ON CONSTRAINT "mdm_biz_TO_mdm_doc_no" ON "mdm_doc_no" IS 'MDM_사업장_TO_MDM_문서번호';

-- MDM_사업장_거래처
ALTER TABLE "mdm_biz_cont"
	ADD CONSTRAINT "mdm_biz_TO_mdm_biz_cont"
	 -- MDM_사업장_TO_MDM_사업장_거래처
		FOREIGN KEY (
			"biz_seq" -- 사업장_SEQ
		)
		REFERENCES "mdm_biz" ( -- MDM_사업장
			"biz_seq" -- 사업장_SEQ
		);

-- MDM_사업장_TO_MDM_사업장_거래처
COMMENT ON CONSTRAINT "mdm_biz_TO_mdm_biz_cont" ON "mdm_biz_cont" IS 'MDM_사업장_TO_MDM_사업장_거래처';

-- MDM_사업장_거래처
ALTER TABLE "mdm_biz_cont"
	ADD CONSTRAINT "mdm_cont_TO_mdm_biz_cont"
	 -- MDM_거래처_TO_MDM_사업장_거래처
		FOREIGN KEY (
			"cont_seq" -- 거래처_SEQ
		)
		REFERENCES "mdm_cont" ( -- MDM_거래처
			"cont_seq" -- 거래처_SEQ
		);

-- MDM_거래처_TO_MDM_사업장_거래처
COMMENT ON CONSTRAINT "mdm_cont_TO_mdm_biz_cont" ON "mdm_biz_cont" IS 'MDM_거래처_TO_MDM_사업장_거래처';

-- MDM_사업장_사업장
ALTER TABLE "mdm_biz_biz"
	ADD CONSTRAINT "mdm_biz_TO_mdm_biz_biz"
	 -- MDM_사업장_TO_MDM_사업장_사업장
		FOREIGN KEY (
			"biz_seq" -- 사업장_SEQ
		)
		REFERENCES "mdm_biz" ( -- MDM_사업장
			"biz_seq" -- 사업장_SEQ
		);

-- MDM_사업장_TO_MDM_사업장_사업장
COMMENT ON CONSTRAINT "mdm_biz_TO_mdm_biz_biz" ON "mdm_biz_biz" IS 'MDM_사업장_TO_MDM_사업장_사업장';

-- MDM_사업장_사업장
ALTER TABLE "mdm_biz_biz"
	ADD CONSTRAINT "mdm_biz_TO_mdm_biz_biz2"
	 -- MDM_사업장_TO_MDM_사업장_사업장2
		FOREIGN KEY (
			"ref_biz_seq" -- 상위_사업장_SEQ
		)
		REFERENCES "mdm_biz" ( -- MDM_사업장
			"biz_seq" -- 사업장_SEQ
		);

-- MDM_사업장_TO_MDM_사업장_사업장2
COMMENT ON CONSTRAINT "mdm_biz_TO_mdm_biz_biz2" ON "mdm_biz_biz" IS 'MDM_사업장_TO_MDM_사업장_사업장2';

-- MDM_사업장_센터
ALTER TABLE "mdm_biz_center"
	ADD CONSTRAINT "mdm_biz_TO_mdm_biz_center"
	 -- MDM_사업장_TO_MDM_사업장_센터
		FOREIGN KEY (
			"biz_seq" -- 사업장_SEQ
		)
		REFERENCES "mdm_biz" ( -- MDM_사업장
			"biz_seq" -- 사업장_SEQ
		);

-- MDM_사업장_TO_MDM_사업장_센터
COMMENT ON CONSTRAINT "mdm_biz_TO_mdm_biz_center" ON "mdm_biz_center" IS 'MDM_사업장_TO_MDM_사업장_센터';

-- MDM_사업장_센터
ALTER TABLE "mdm_biz_center"
	ADD CONSTRAINT "mdm_center_TO_mdm_biz_center"
	 -- MDM_센터_TO_MDM_사업장_센터
		FOREIGN KEY (
			"center_seq" -- 센터_SEQ
		)
		REFERENCES "mdm_center" ( -- MDM_센터
			"center_seq" -- 센터_SEQ
		);

-- MDM_센터_TO_MDM_사업장_센터
COMMENT ON CONSTRAINT "mdm_center_TO_mdm_biz_center" ON "mdm_biz_center" IS 'MDM_센터_TO_MDM_사업장_센터';

-- MDM_사업장_창고
ALTER TABLE "mdm_biz_wh"
	ADD CONSTRAINT "mdm_biz_TO_mdm_biz_wh"
	 -- MDM_사업장_TO_MDM_사업장_창고
		FOREIGN KEY (
			"biz_seq" -- 사업장_SEQ
		)
		REFERENCES "mdm_biz" ( -- MDM_사업장
			"biz_seq" -- 사업장_SEQ
		);

-- MDM_사업장_TO_MDM_사업장_창고
COMMENT ON CONSTRAINT "mdm_biz_TO_mdm_biz_wh" ON "mdm_biz_wh" IS 'MDM_사업장_TO_MDM_사업장_창고';

-- MDM_사업장_창고
ALTER TABLE "mdm_biz_wh"
	ADD CONSTRAINT "mdm_wh_TO_mdm_biz_wh"
	 -- MDM_창고_TO_MDM_사업장_창고
		FOREIGN KEY (
			"wh_seq" -- 창고_SEQ
		)
		REFERENCES "mdm_wh" ( -- MDM_창고
			"wh_seq" -- 창고_SEQ
		);

-- MDM_창고_TO_MDM_사업장_창고
COMMENT ON CONSTRAINT "mdm_wh_TO_mdm_biz_wh" ON "mdm_biz_wh" IS 'MDM_창고_TO_MDM_사업장_창고';

-- MDM_사업장_품목
ALTER TABLE "mdm_biz_prod"
	ADD CONSTRAINT "mdm_biz_TO_mdm_biz_prod"
	 -- MDM_사업장_TO_MDM_사업장_품목
		FOREIGN KEY (
			"biz_seq" -- 사업장_SEQ
		)
		REFERENCES "mdm_biz" ( -- MDM_사업장
			"biz_seq" -- 사업장_SEQ
		);

-- MDM_사업장_TO_MDM_사업장_품목
COMMENT ON CONSTRAINT "mdm_biz_TO_mdm_biz_prod" ON "mdm_biz_prod" IS 'MDM_사업장_TO_MDM_사업장_품목';

-- MDM_사업장_품목
ALTER TABLE "mdm_biz_prod"
	ADD CONSTRAINT "mdm_prod_TO_mdm_biz_prod"
	 -- MDM_품목_TO_MDM_사업장_품목
		FOREIGN KEY (
			"prod_seq" -- 품목_SEQ
		)
		REFERENCES "mdm_prod" ( -- MDM_품목
			"prod_seq" -- 품목_SEQ
		);

-- MDM_품목_TO_MDM_사업장_품목
COMMENT ON CONSTRAINT "mdm_prod_TO_mdm_biz_prod" ON "mdm_biz_prod" IS 'MDM_품목_TO_MDM_사업장_품목';

-- MDM_사용자
ALTER TABLE "mdm_user"
	ADD CONSTRAINT "sm_group_TO_mdm_user"
	 -- 시스템_그룹_TO_MDM_사용자(NEW)
		FOREIGN KEY (
			"group_seq" -- 그룹_SEQ
		)
		REFERENCES "sm_group" ( -- 시스템_그룹
			"group_seq" -- 그룹_SEQ
		);

-- 시스템_그룹_TO_MDM_사용자(NEW)
COMMENT ON CONSTRAINT "sm_group_TO_mdm_user" ON "mdm_user" IS '시스템_그룹_TO_MDM_사용자(NEW)';

-- MDM_세트구성
ALTER TABLE "mdm_st_prod"
	ADD CONSTRAINT "mdm_st_prod_TO_mdm_st_prod"
	 -- MDM_세트구성_TO_MDM_세트구성
		FOREIGN KEY (
			"ref_st_prod_seq" -- 상위_세트구성_SEQ
		)
		REFERENCES "mdm_st_prod" ( -- MDM_세트구성
			"st_prod_seq" -- 세트구성_SEQ
		);

-- MDM_세트구성_TO_MDM_세트구성
COMMENT ON CONSTRAINT "mdm_st_prod_TO_mdm_st_prod" ON "mdm_st_prod" IS 'MDM_세트구성_TO_MDM_세트구성';

-- MDM_위치
ALTER TABLE "mdm_loc"
	ADD CONSTRAINT "mdm_wh_TO_mdm_loc"
	 -- MDM_창고_TO_MDM_위치
		FOREIGN KEY (
			"wh_seq" -- 창고_SEQ
		)
		REFERENCES "mdm_wh" ( -- MDM_창고
			"wh_seq" -- 창고_SEQ
		);

-- MDM_창고_TO_MDM_위치
COMMENT ON CONSTRAINT "mdm_wh_TO_mdm_loc" ON "mdm_loc" IS 'MDM_창고_TO_MDM_위치';

-- MDM_전환품목
ALTER TABLE "mdm_rp_prod"
	ADD CONSTRAINT "mdm_prod_TO_mdm_rp_prod"
	 -- MDM_품목_TO_MDM_전환품목
		FOREIGN KEY (
			"prod_seq" -- 품목_SEQ
		)
		REFERENCES "mdm_prod" ( -- MDM_품목
			"prod_seq" -- 품목_SEQ
		);

-- MDM_품목_TO_MDM_전환품목
COMMENT ON CONSTRAINT "mdm_prod_TO_mdm_rp_prod" ON "mdm_rp_prod" IS 'MDM_품목_TO_MDM_전환품목';

-- MDM_전환품목
ALTER TABLE "mdm_rp_prod"
	ADD CONSTRAINT "mdm_rp_prod_TO_mdm_rp_prod"
	 -- MDM_전환품목_TO_MDM_전환품목
		FOREIGN KEY (
			"ref_rp_prod_seq" -- 상위_전환품목_SEQ
		)
		REFERENCES "mdm_rp_prod" ( -- MDM_전환품목
			"rp_prod_seq" -- 전환품목_SEQ
		);

-- MDM_전환품목_TO_MDM_전환품목
COMMENT ON CONSTRAINT "mdm_rp_prod_TO_mdm_rp_prod" ON "mdm_rp_prod" IS 'MDM_전환품목_TO_MDM_전환품목';

-- MDM_차량
ALTER TABLE "mdm_car"
	ADD CONSTRAINT "mdm_biz_TO_mdm_car"
	 -- MDM_사업장_TO_MDM_차량
		FOREIGN KEY (
			"biz_seq" -- 사업장_SEQ
		)
		REFERENCES "mdm_biz" ( -- MDM_사업장
			"biz_seq" -- 사업장_SEQ
		);

-- MDM_사업장_TO_MDM_차량
COMMENT ON CONSTRAINT "mdm_biz_TO_mdm_car" ON "mdm_car" IS 'MDM_사업장_TO_MDM_차량';

-- MDM_창고
ALTER TABLE "mdm_wh"
	ADD CONSTRAINT "mdm_center_TO_mdm_wh"
	 -- MDM_센터_TO_MDM_창고
		FOREIGN KEY (
			"center_seq" -- 센터_SEQ
		)
		REFERENCES "mdm_center" ( -- MDM_센터
			"center_seq" -- 센터_SEQ
		);

-- MDM_센터_TO_MDM_창고
COMMENT ON CONSTRAINT "mdm_center_TO_mdm_wh" ON "mdm_wh" IS 'MDM_센터_TO_MDM_창고';

-- MDM_품목
ALTER TABLE "mdm_prod"
	ADD CONSTRAINT "mdm_label_paper_TO_mdm_prod"
	 -- MDM_라벨_용지_TO_MDM_품목
		FOREIGN KEY (
			"label_paper_seq" -- 라벨용지_SEQ
		)
		REFERENCES "mdm_label_paper" ( -- MDM_라벨_용지
			"label_paper_seq" -- 라벨용지_SEQ
		);

-- MDM_라벨_용지_TO_MDM_품목
COMMENT ON CONSTRAINT "mdm_label_paper_TO_mdm_prod" ON "mdm_prod" IS 'MDM_라벨_용지_TO_MDM_품목';

-- MDM_품목
ALTER TABLE "mdm_prod"
	ADD CONSTRAINT "mdm_label_paper_TO_mdm_prod2"
	 -- MDM_라벨_용지_TO_MDM_품목2
		FOREIGN KEY (
			"parent_label_paper_seq" -- 상위_라벨용지_SEQ
		)
		REFERENCES "mdm_label_paper" ( -- MDM_라벨_용지
			"label_paper_seq" -- 라벨용지_SEQ
		);

-- MDM_라벨_용지_TO_MDM_품목2
COMMENT ON CONSTRAINT "mdm_label_paper_TO_mdm_prod2" ON "mdm_prod" IS 'MDM_라벨_용지_TO_MDM_품목2';

-- WMS_반품_처리
ALTER TABLE "wms_return_tran"
	ADD CONSTRAINT "wms_return_prod_TO_wms_return_tran"
	 -- WMS_반품_품목_TO_WMS_반품_처리
		FOREIGN KEY (
			"return_prod_seq", -- 반품_품목_SEQ
			"return_seq"       -- 반품_SEQ
		)
		REFERENCES "wms_return_prod" ( -- WMS_반품_품목
			"return_prod_seq", -- 반품_품목_SEQ
			"return_seq"       -- 반품_SEQ
		);

-- WMS_반품_품목_TO_WMS_반품_처리
COMMENT ON CONSTRAINT "wms_return_prod_TO_wms_return_tran" ON "wms_return_tran" IS 'WMS_반품_품목_TO_WMS_반품_처리';

-- WMS_반품_품목
ALTER TABLE "wms_return_prod"
	ADD CONSTRAINT "wms_return_TO_wms_return_prod"
	 -- WMS_반품_TO_WMS_반품_품목
		FOREIGN KEY (
			"return_seq" -- 반품_SEQ
		)
		REFERENCES "wms_return" ( -- WMS_반품
			"return_seq" -- 반품_SEQ
		);

-- WMS_반품_TO_WMS_반품_품목
COMMENT ON CONSTRAINT "wms_return_TO_wms_return_prod" ON "wms_return_prod" IS 'WMS_반품_TO_WMS_반품_품목';

-- WMS_상차
ALTER TABLE "wms_load"
	ADD CONSTRAINT "mdm_car_TO_wms_load"
	 -- MDM_차량_TO_WMS_상차
		FOREIGN KEY (
			"car_seq" -- 차량_SEQ
		)
		REFERENCES "mdm_car" ( -- MDM_차량
			"car_seq" -- 차량_SEQ
		);

-- MDM_차량_TO_WMS_상차
COMMENT ON CONSTRAINT "mdm_car_TO_wms_load" ON "wms_load" IS 'MDM_차량_TO_WMS_상차';

-- WMS_상차_처리
ALTER TABLE "wms_load_tran"
	ADD CONSTRAINT "wms_load_prod_TO_wms_load_tran"
	 -- WMS_상차_품목_TO_WMS_상차_처리
		FOREIGN KEY (
			"load_prod_seq", -- 상차_품목_SEQ
			"load_seq"       -- 상차_SEQ
		)
		REFERENCES "wms_load_prod" ( -- WMS_상차_품목
			"load_prod_seq", -- 상차_품목_SEQ
			"load_seq"       -- 상차_SEQ
		);

-- WMS_상차_품목_TO_WMS_상차_처리
COMMENT ON CONSTRAINT "wms_load_prod_TO_wms_load_tran" ON "wms_load_tran" IS 'WMS_상차_품목_TO_WMS_상차_처리';

-- WMS_상차_처리
ALTER TABLE "wms_load_tran"
	ADD CONSTRAINT "wms_outbiz_tran_TO_wms_load_tran"
	 -- WMS_출하_처리_TO_WMS_상차_처리
		FOREIGN KEY (
			"outbiz_tran_seq" -- 출하_처리_SEQ
		)
		REFERENCES "wms_outbiz_tran" ( -- WMS_출하_처리
			"outbiz_tran_seq" -- 출하_처리_SEQ
		);

-- WMS_출하_처리_TO_WMS_상차_처리
COMMENT ON CONSTRAINT "wms_outbiz_tran_TO_wms_load_tran" ON "wms_load_tran" IS 'WMS_출하_처리_TO_WMS_상차_처리';

-- WMS_상차_품목
ALTER TABLE "wms_load_prod"
	ADD CONSTRAINT "wms_load_TO_wms_load_prod"
	 -- WMS_상차_TO_WMS_상차_품목
		FOREIGN KEY (
			"load_seq" -- 상차_SEQ
		)
		REFERENCES "wms_load" ( -- WMS_상차
			"load_seq" -- 상차_SEQ
		);

-- WMS_상차_TO_WMS_상차_품목
COMMENT ON CONSTRAINT "wms_load_TO_wms_load_prod" ON "wms_load_prod" IS 'WMS_상차_TO_WMS_상차_품목';

-- WMS_세트작업_처리
ALTER TABLE "wms_inven_st_tran"
	ADD CONSTRAINT "wms_inven_st_prod_TO_wms_inven_st_tran"
	 -- WMS_세트작업_품목_TO_WMS_세트작업_처리
		FOREIGN KEY (
			"st_prod_seq", -- 세트작업_품목_SEQ
			"st_seq"       -- 세트작업_SEQ
		)
		REFERENCES "wms_inven_st_prod" ( -- WMS_세트작업_품목
			"st_prod_seq", -- 세트작업_품목_SEQ
			"st_seq"       -- 세트작업_SEQ
		);

-- WMS_세트작업_품목_TO_WMS_세트작업_처리
COMMENT ON CONSTRAINT "wms_inven_st_prod_TO_wms_inven_st_tran" ON "wms_inven_st_tran" IS 'WMS_세트작업_품목_TO_WMS_세트작업_처리';

-- WMS_세트작업_품목
ALTER TABLE "wms_inven_st_prod"
	ADD CONSTRAINT "wms_inven_st_TO_wms_inven_st_prod"
	 -- WMS_세트작업_TO_WMS_세트작업_품목
		FOREIGN KEY (
			"st_seq" -- 세트작업_SEQ
		)
		REFERENCES "wms_inven_st" ( -- WMS_세트작업
			"st_seq" -- 세트작업_SEQ
		);

-- WMS_세트작업_TO_WMS_세트작업_품목
COMMENT ON CONSTRAINT "wms_inven_st_TO_wms_inven_st_prod" ON "wms_inven_st_prod" IS 'WMS_세트작업_TO_WMS_세트작업_품목';

-- WMS_세트작업_품목
ALTER TABLE "wms_inven_st_prod"
	ADD CONSTRAINT "mdm_st_prod_TO_wms_inven_st_prod"
	 -- MDM_세트구성_TO_WMS_세트작업_품목
		FOREIGN KEY (
			"mdm_st_prod_seq" -- 세트구성_SEQ
		)
		REFERENCES "mdm_st_prod" ( -- MDM_세트구성
			"st_prod_seq" -- 세트구성_SEQ
		);

-- MDM_세트구성_TO_WMS_세트작업_품목
COMMENT ON CONSTRAINT "mdm_st_prod_TO_wms_inven_st_prod" ON "wms_inven_st_prod" IS 'MDM_세트구성_TO_WMS_세트작업_품목';

-- WMS_송장_처리
ALTER TABLE "wms_invoice_tran"
	ADD CONSTRAINT "wms_invoice_prod_TO_wms_invoice_tran"
	 -- WMS_송장_품목_TO_WMS_송장_처리
		FOREIGN KEY (
			"invoice_prod_seq", -- 송장_품목_SEQ
			"invoice_seq"       -- 송장_SEQ
		)
		REFERENCES "wms_invoice_prod" ( -- WMS_송장_품목
			"invoice_prod_seq", -- 송장_품목_SEQ
			"invoice_seq"       -- 송장_SEQ
		);

-- WMS_송장_품목_TO_WMS_송장_처리
COMMENT ON CONSTRAINT "wms_invoice_prod_TO_wms_invoice_tran" ON "wms_invoice_tran" IS 'WMS_송장_품목_TO_WMS_송장_처리';

-- WMS_송장_처리
ALTER TABLE "wms_invoice_tran"
	ADD CONSTRAINT "wms_outbiz_tran_TO_wms_invoice_tran"
	 -- WMS_출하_처리_TO_WMS_송장_처리
		FOREIGN KEY (
			"outbiz_tran_seq" -- 출하_처리_SEQ
		)
		REFERENCES "wms_outbiz_tran" ( -- WMS_출하_처리
			"outbiz_tran_seq" -- 출하_처리_SEQ
		);

-- WMS_출하_처리_TO_WMS_송장_처리
COMMENT ON CONSTRAINT "wms_outbiz_tran_TO_wms_invoice_tran" ON "wms_invoice_tran" IS 'WMS_출하_처리_TO_WMS_송장_처리';

-- WMS_송장_품목
ALTER TABLE "wms_invoice_prod"
	ADD CONSTRAINT "wms_invoice_TO_wms_invoice_prod"
	 -- WMS_송장_TO_WMS_송장_품목
		FOREIGN KEY (
			"invoice_seq" -- 송장_SEQ
		)
		REFERENCES "wms_invoice" ( -- WMS_송장
			"invoice_seq" -- 송장_SEQ
		);

-- WMS_송장_TO_WMS_송장_품목
COMMENT ON CONSTRAINT "wms_invoice_TO_wms_invoice_prod" ON "wms_invoice_prod" IS 'WMS_송장_TO_WMS_송장_품목';

-- WMS_예외출고_처리
ALTER TABLE "wms_inven_etc_tran"
	ADD CONSTRAINT "wms_inven_etc_prod_TO_wms_inven_etc_tran"
	 -- WMS_예외출고_품목_TO_WMS_예외출고_처리
		FOREIGN KEY (
			"etc_prod_seq", -- 예외출고_품목_SEQ
			"etc_seq"       -- 예외출고_SEQ
		)
		REFERENCES "wms_inven_etc_prod" ( -- WMS_예외출고_품목
			"etc_prod_seq", -- 예외출고_품목_SEQ
			"etc_seq"       -- 예외출고_SEQ
		);

-- WMS_예외출고_품목_TO_WMS_예외출고_처리
COMMENT ON CONSTRAINT "wms_inven_etc_prod_TO_wms_inven_etc_tran" ON "wms_inven_etc_tran" IS 'WMS_예외출고_품목_TO_WMS_예외출고_처리';

-- WMS_예외출고_품목
ALTER TABLE "wms_inven_etc_prod"
	ADD CONSTRAINT "wms_inven_etc_TO_wms_inven_etc_prod"
	 -- WMS_예외출고_TO_WMS_예외출고_품목
		FOREIGN KEY (
			"etc_seq" -- 예외출고_SEQ
		)
		REFERENCES "wms_inven_etc" ( -- WMS_예외출고
			"etc_seq" -- 예외출고_SEQ
		);

-- WMS_예외출고_TO_WMS_예외출고_품목
COMMENT ON CONSTRAINT "wms_inven_etc_TO_wms_inven_etc_prod" ON "wms_inven_etc_prod" IS 'WMS_예외출고_TO_WMS_예외출고_품목';

-- WMS_입고_처리
ALTER TABLE "wms_inwh_tran"
	ADD CONSTRAINT "wms_inwh_prod_TO_wms_inwh_tran"
	 -- WMS_입고_품목_TO_WMS_입고_처리
		FOREIGN KEY (
			"inwh_prod_seq", -- 입고_품목_SEQ
			"inwh_seq"       -- 입고_SEQ
		)
		REFERENCES "wms_inwh_prod" ( -- WMS_입고_품목
			"inwh_prod_seq", -- 입고_품목_SEQ
			"inwh_seq"       -- 입고_SEQ
		);

-- WMS_입고_품목_TO_WMS_입고_처리
COMMENT ON CONSTRAINT "wms_inwh_prod_TO_wms_inwh_tran" ON "wms_inwh_tran" IS 'WMS_입고_품목_TO_WMS_입고_처리';

-- WMS_입고_품목
ALTER TABLE "wms_inwh_prod"
	ADD CONSTRAINT "wms_inwh_TO_wms_inwh_prod"
	 -- WMS_입고_TO_WMS_입고_품목
		FOREIGN KEY (
			"inwh_seq" -- 입고_SEQ
		)
		REFERENCES "wms_inwh" ( -- WMS_입고
			"inwh_seq" -- 입고_SEQ
		);

-- WMS_입고_TO_WMS_입고_품목
COMMENT ON CONSTRAINT "wms_inwh_TO_wms_inwh_prod" ON "wms_inwh_prod" IS 'WMS_입고_TO_WMS_입고_품목';

-- WMS_입하_입고
ALTER TABLE "wms_inbiz_inwh"
	ADD CONSTRAINT "wms_inbiz_prod_TO_wms_inbiz_inwh"
	 -- WMS_입하_품목_TO_WMS_입하_입고
		FOREIGN KEY (
			"inbiz_prod_seq", -- 입하_품목_SEQ
			"inbiz_seq"       -- 입하_SEQ
		)
		REFERENCES "wms_inbiz_prod" ( -- WMS_입하_품목
			"inbiz_prod_seq", -- 입하_품목_SEQ
			"inbiz_seq"       -- 입하_SEQ
		);

-- WMS_입하_품목_TO_WMS_입하_입고
COMMENT ON CONSTRAINT "wms_inbiz_prod_TO_wms_inbiz_inwh" ON "wms_inbiz_inwh" IS 'WMS_입하_품목_TO_WMS_입하_입고';

-- WMS_입하_입고
ALTER TABLE "wms_inbiz_inwh"
	ADD CONSTRAINT "wms_inwh_prod_TO_wms_inbiz_inwh"
	 -- WMS_입고_품목_TO_WMS_입하_입고
		FOREIGN KEY (
			"inwh_prod_seq", -- 입고_품목_SEQ
			"inwh_seq"       -- 입고_SEQ
		)
		REFERENCES "wms_inwh_prod" ( -- WMS_입고_품목
			"inwh_prod_seq", -- 입고_품목_SEQ
			"inwh_seq"       -- 입고_SEQ
		);

-- WMS_입고_품목_TO_WMS_입하_입고
COMMENT ON CONSTRAINT "wms_inwh_prod_TO_wms_inbiz_inwh" ON "wms_inbiz_inwh" IS 'WMS_입고_품목_TO_WMS_입하_입고';

-- WMS_입하_품목
ALTER TABLE "wms_inbiz_prod"
	ADD CONSTRAINT "wms_inbiz_TO_wms_inbiz_prod"
	 -- WMS_입하_TO_WMS_입하_품목
		FOREIGN KEY (
			"inbiz_seq" -- 입하_SEQ
		)
		REFERENCES "wms_inbiz" ( -- WMS_입하
			"inbiz_seq" -- 입하_SEQ
		);

-- WMS_입하_TO_WMS_입하_품목
COMMENT ON CONSTRAINT "wms_inbiz_TO_wms_inbiz_prod" ON "wms_inbiz_prod" IS 'WMS_입하_TO_WMS_입하_품목';

-- WMS_재고실사_대상
ALTER TABLE "wms_st_target"
	ADD CONSTRAINT "wms_st_sch_TO_wms_st_target"
	 -- WMS_재고실사_일정_TO_WMS_재고실사_대상
		FOREIGN KEY (
			"st_sch_seq" -- 재고실사_SEQ
		)
		REFERENCES "wms_st_sch" ( -- WMS_재고실사_일정
			"st_sch_seq" -- 재고실사_SEQ
		);

-- WMS_재고실사_일정_TO_WMS_재고실사_대상
COMMENT ON CONSTRAINT "wms_st_sch_TO_wms_st_target" ON "wms_st_target" IS 'WMS_재고실사_일정_TO_WMS_재고실사_대상';

-- WMS_재고실사_재고
ALTER TABLE "wms_st_inven"
	ADD CONSTRAINT "wms_st_sch_TO_wms_st_inven"
	 -- WMS_재고실사_일정_TO_WMS_재고실사_재고
		FOREIGN KEY (
			"st_sch_seq" -- 재고실사_SEQ
		)
		REFERENCES "wms_st_sch" ( -- WMS_재고실사_일정
			"st_sch_seq" -- 재고실사_SEQ
		);

-- WMS_재고실사_일정_TO_WMS_재고실사_재고
COMMENT ON CONSTRAINT "wms_st_sch_TO_wms_st_inven" ON "wms_st_inven" IS 'WMS_재고실사_일정_TO_WMS_재고실사_재고';

-- WMS_재고실사_처리
ALTER TABLE "wms_st_tran"
	ADD CONSTRAINT "wms_st_sch_TO_wms_st_tran"
	 -- WMS_재고실사_일정_TO_WMS_재고실사_처리
		FOREIGN KEY (
			"st_sch_seq" -- 재고실사_SEQ
		)
		REFERENCES "wms_st_sch" ( -- WMS_재고실사_일정
			"st_sch_seq" -- 재고실사_SEQ
		);

-- WMS_재고실사_일정_TO_WMS_재고실사_처리
COMMENT ON CONSTRAINT "wms_st_sch_TO_wms_st_tran" ON "wms_st_tran" IS 'WMS_재고실사_일정_TO_WMS_재고실사_처리';

-- WMS_재고이동_처리
ALTER TABLE "wms_inven_mv_tran"
	ADD CONSTRAINT "wms_inven_mv_prod_TO_wms_inven_mv_tran"
	 -- WMS_재고이동_품목_TO_WMS_재고이동_처리
		FOREIGN KEY (
			"mv_prod_seq", -- 재고이동_품목_SEQ
			"mv_seq"       -- 재고이동_SEQ
		)
		REFERENCES "wms_inven_mv_prod" ( -- WMS_재고이동_품목
			"mv_prod_seq", -- 재고이동_품목_SEQ
			"mv_seq"       -- 재고이동_SEQ
		);

-- WMS_재고이동_품목_TO_WMS_재고이동_처리
COMMENT ON CONSTRAINT "wms_inven_mv_prod_TO_wms_inven_mv_tran" ON "wms_inven_mv_tran" IS 'WMS_재고이동_품목_TO_WMS_재고이동_처리';

-- WMS_재고이동_품목
ALTER TABLE "wms_inven_mv_prod"
	ADD CONSTRAINT "wms_inven_mv_TO_wms_inven_mv_prod"
	 -- WMS_재고이동_TO_WMS_재고이동_품목
		FOREIGN KEY (
			"mv_seq" -- 재고이동_SEQ
		)
		REFERENCES "wms_inven_mv" ( -- WMS_재고이동
			"mv_seq" -- 재고이동_SEQ
		);

-- WMS_재고이동_TO_WMS_재고이동_품목
COMMENT ON CONSTRAINT "wms_inven_mv_TO_wms_inven_mv_prod" ON "wms_inven_mv_prod" IS 'WMS_재고이동_TO_WMS_재고이동_품목';

-- WMS_재고조정_처리
ALTER TABLE "wms_inven_ad_tran"
	ADD CONSTRAINT "wms_inven_ad_prod_TO_wms_inven_ad_tran"
	 -- WMS_재고조정_품목_TO_WMS_재고조정_처리
		FOREIGN KEY (
			"ad_prod_seq", -- 재고조정_품목_SEQ
			"ad_seq"       -- 재고조정_SEQ
		)
		REFERENCES "wms_inven_ad_prod" ( -- WMS_재고조정_품목
			"ad_prod_seq", -- 재고조정_품목_SEQ
			"ad_seq"       -- 재고조정_SEQ
		);

-- WMS_재고조정_품목_TO_WMS_재고조정_처리
COMMENT ON CONSTRAINT "wms_inven_ad_prod_TO_wms_inven_ad_tran" ON "wms_inven_ad_tran" IS 'WMS_재고조정_품목_TO_WMS_재고조정_처리';

-- WMS_재고조정_품목
ALTER TABLE "wms_inven_ad_prod"
	ADD CONSTRAINT "wms_inven_ad_TO_wms_inven_ad_prod"
	 -- WMS_재고조정_TO_WMS_재고조정_품목
		FOREIGN KEY (
			"ad_seq" -- 재고조정_SEQ
		)
		REFERENCES "wms_inven_ad" ( -- WMS_재고조정
			"ad_seq" -- 재고조정_SEQ
		);

-- WMS_재고조정_TO_WMS_재고조정_품목
COMMENT ON CONSTRAINT "wms_inven_ad_TO_wms_inven_ad_prod" ON "wms_inven_ad_prod" IS 'WMS_재고조정_TO_WMS_재고조정_품목';

-- WMS_출고_처리
ALTER TABLE "wms_outwh_tran"
	ADD CONSTRAINT "wms_outwh_prod_TO_wms_outwh_tran"
	 -- WMS_출고_품목_TO_WMS_출고_처리
		FOREIGN KEY (
			"outwh_prod_seq", -- 출고_품목_SEQ
			"outwh_seq"       -- 출고_SEQ
		)
		REFERENCES "wms_outwh_prod" ( -- WMS_출고_품목
			"outwh_prod_seq", -- 출고_품목_SEQ
			"outwh_seq"       -- 출고_SEQ
		);

-- WMS_출고_품목_TO_WMS_출고_처리
COMMENT ON CONSTRAINT "wms_outwh_prod_TO_wms_outwh_tran" ON "wms_outwh_tran" IS 'WMS_출고_품목_TO_WMS_출고_처리';

-- WMS_출고_품목
ALTER TABLE "wms_outwh_prod"
	ADD CONSTRAINT "wms_outwh_TO_wms_outwh_prod"
	 -- WMS_출고_TO_WMS_출고_품목
		FOREIGN KEY (
			"outwh_seq" -- 출고_SEQ
		)
		REFERENCES "wms_outwh" ( -- WMS_출고
			"outwh_seq" -- 출고_SEQ
		);

-- WMS_출고_TO_WMS_출고_품목
COMMENT ON CONSTRAINT "wms_outwh_TO_wms_outwh_prod" ON "wms_outwh_prod" IS 'WMS_출고_TO_WMS_출고_품목';

-- WMS_출하_상차
ALTER TABLE "wms_outbiz_load"
	ADD CONSTRAINT "wms_load_prod_TO_wms_outbiz_load"
	 -- WMS_상차_품목_TO_WMS_출하_상차
		FOREIGN KEY (
			"load_prod_seq", -- 상차_품목_SEQ
			"load_seq"       -- 상차_SEQ
		)
		REFERENCES "wms_load_prod" ( -- WMS_상차_품목
			"load_prod_seq", -- 상차_품목_SEQ
			"load_seq"       -- 상차_SEQ
		);

-- WMS_상차_품목_TO_WMS_출하_상차
COMMENT ON CONSTRAINT "wms_load_prod_TO_wms_outbiz_load" ON "wms_outbiz_load" IS 'WMS_상차_품목_TO_WMS_출하_상차';

-- WMS_출하_상차
ALTER TABLE "wms_outbiz_load"
	ADD CONSTRAINT "wms_outbiz_prod_TO_wms_outbiz_load"
	 -- WMS_출하_품목_TO_WMS_출하_상차
		FOREIGN KEY (
			"outbiz_prod_seq", -- 출하_품목_SEQ
			"outbiz_seq"       -- 출하_SEQ
		)
		REFERENCES "wms_outbiz_prod" ( -- WMS_출하_품목
			"outbiz_prod_seq", -- 출하_품목_SEQ
			"outbiz_seq"       -- 출하_SEQ
		);

-- WMS_출하_품목_TO_WMS_출하_상차
COMMENT ON CONSTRAINT "wms_outbiz_prod_TO_wms_outbiz_load" ON "wms_outbiz_load" IS 'WMS_출하_품목_TO_WMS_출하_상차';

-- WMS_출하_송장
ALTER TABLE "wms_outbiz_invoice"
	ADD CONSTRAINT "wms_invoice_prod_TO_wms_outbiz_invoice"
	 -- WMS_송장_품목_TO_WMS_출하_송장
		FOREIGN KEY (
			"invoice_prod_seq", -- 송장_품목_SEQ
			"invoice_seq"       -- 송장_SEQ
		)
		REFERENCES "wms_invoice_prod" ( -- WMS_송장_품목
			"invoice_prod_seq", -- 송장_품목_SEQ
			"invoice_seq"       -- 송장_SEQ
		);

-- WMS_송장_품목_TO_WMS_출하_송장
COMMENT ON CONSTRAINT "wms_invoice_prod_TO_wms_outbiz_invoice" ON "wms_outbiz_invoice" IS 'WMS_송장_품목_TO_WMS_출하_송장';

-- WMS_출하_송장
ALTER TABLE "wms_outbiz_invoice"
	ADD CONSTRAINT "wms_outbiz_prod_TO_wms_outbiz_invoice"
	 -- WMS_출하_품목_TO_WMS_출하_송장
		FOREIGN KEY (
			"outbiz_prod_seq", -- 출하_품목_SEQ
			"outbiz_seq"       -- 출하_SEQ
		)
		REFERENCES "wms_outbiz_prod" ( -- WMS_출하_품목
			"outbiz_prod_seq", -- 출하_품목_SEQ
			"outbiz_seq"       -- 출하_SEQ
		);

-- WMS_출하_품목_TO_WMS_출하_송장
COMMENT ON CONSTRAINT "wms_outbiz_prod_TO_wms_outbiz_invoice" ON "wms_outbiz_invoice" IS 'WMS_출하_품목_TO_WMS_출하_송장';

-- WMS_출하_처리
ALTER TABLE "wms_outbiz_tran"
	ADD CONSTRAINT "wms_outbiz_prod_TO_wms_outbiz_tran"
	 -- WMS_출하_품목_TO_WMS_출하_처리
		FOREIGN KEY (
			"outbiz_prod_seq", -- 출하_품목_SEQ
			"outbiz_seq"       -- 출하_SEQ
		)
		REFERENCES "wms_outbiz_prod" ( -- WMS_출하_품목
			"outbiz_prod_seq", -- 출하_품목_SEQ
			"outbiz_seq"       -- 출하_SEQ
		);

-- WMS_출하_품목_TO_WMS_출하_처리
COMMENT ON CONSTRAINT "wms_outbiz_prod_TO_wms_outbiz_tran" ON "wms_outbiz_tran" IS 'WMS_출하_품목_TO_WMS_출하_처리';

-- WMS_출하_출고
ALTER TABLE "wms_outbiz_outwh"
	ADD CONSTRAINT "wms_outwh_prod_TO_wms_outbiz_outwh"
	 -- WMS_출고_품목_TO_WMS_출하_출고
		FOREIGN KEY (
			"outwh_prod_seq", -- 출고_품목_SEQ
			"outwh_seq"       -- 출고_SEQ
		)
		REFERENCES "wms_outwh_prod" ( -- WMS_출고_품목
			"outwh_prod_seq", -- 출고_품목_SEQ
			"outwh_seq"       -- 출고_SEQ
		);

-- WMS_출고_품목_TO_WMS_출하_출고
COMMENT ON CONSTRAINT "wms_outwh_prod_TO_wms_outbiz_outwh" ON "wms_outbiz_outwh" IS 'WMS_출고_품목_TO_WMS_출하_출고';

-- WMS_출하_출고
ALTER TABLE "wms_outbiz_outwh"
	ADD CONSTRAINT "wms_outbiz_prod_TO_wms_outbiz_outwh"
	 -- WMS_출하_품목_TO_WMS_출하_출고
		FOREIGN KEY (
			"outbiz_prod_seq", -- 출하_품목_SEQ
			"outbiz_seq"       -- 출하_SEQ
		)
		REFERENCES "wms_outbiz_prod" ( -- WMS_출하_품목
			"outbiz_prod_seq", -- 출하_품목_SEQ
			"outbiz_seq"       -- 출하_SEQ
		);

-- WMS_출하_품목_TO_WMS_출하_출고
COMMENT ON CONSTRAINT "wms_outbiz_prod_TO_wms_outbiz_outwh" ON "wms_outbiz_outwh" IS 'WMS_출하_품목_TO_WMS_출하_출고';

-- WMS_출하_품목
ALTER TABLE "wms_outbiz_prod"
	ADD CONSTRAINT "wms_outbiz_TO_wms_outbiz_prod"
	 -- WMS_출하_TO_WMS_출하_품목
		FOREIGN KEY (
			"outbiz_seq" -- 출하_SEQ
		)
		REFERENCES "wms_outbiz" ( -- WMS_출하
			"outbiz_seq" -- 출하_SEQ
		);

-- WMS_출하_TO_WMS_출하_품목
COMMENT ON CONSTRAINT "wms_outbiz_TO_wms_outbiz_prod" ON "wms_outbiz_prod" IS 'WMS_출하_TO_WMS_출하_품목';

-- WMS_품목전환_처리
ALTER TABLE "wms_inven_rp_tran"
	ADD CONSTRAINT "wms_inven_rp_prod_TO_wms_inven_rp_tran"
	 -- WMS_품목전환_품목_TO_WMS_품목전환_처리
		FOREIGN KEY (
			"rp_prod_seq", -- 품목전환_품목_SEQ
			"rp_seq"       -- 품목전환_SEQ
		)
		REFERENCES "wms_inven_rp_prod" ( -- WMS_품목전환_품목
			"rp_prod_seq", -- 품목전환_품목_SEQ
			"rp_seq"       -- 품목전환_SEQ
		);

-- WMS_품목전환_품목_TO_WMS_품목전환_처리
COMMENT ON CONSTRAINT "wms_inven_rp_prod_TO_wms_inven_rp_tran" ON "wms_inven_rp_tran" IS 'WMS_품목전환_품목_TO_WMS_품목전환_처리';

-- WMS_품목전환_품목
ALTER TABLE "wms_inven_rp_prod"
	ADD CONSTRAINT "wms_inven_rp_TO_wms_inven_rp_prod"
	 -- WMS_품목전환_TO_WMS_품목전환_품목
		FOREIGN KEY (
			"rp_seq" -- 품목전환_SEQ
		)
		REFERENCES "wms_inven_rp" ( -- WMS_품목전환
			"rp_seq" -- 품목전환_SEQ
		);

-- WMS_품목전환_TO_WMS_품목전환_품목
COMMENT ON CONSTRAINT "wms_inven_rp_TO_wms_inven_rp_prod" ON "wms_inven_rp_prod" IS 'WMS_품목전환_TO_WMS_품목전환_품목';

-- 시스템_공통코드_상세
ALTER TABLE "sm_comm_d"
	ADD CONSTRAINT "sm_comm_h_TO_sm_comm_d"
	 -- 시스템_공통코드_TO_시스템_공통코드_상세
		FOREIGN KEY (
			"biz_seq",   -- 사업장_SEQ
			"comm_h_cd"  -- 상위_코드
		)
		REFERENCES "sm_comm_h" ( -- 시스템_공통코드
			"biz_seq",   -- 사업장_SEQ
			"comm_h_cd"  -- 상위_코드
		);

-- 시스템_공통코드_TO_시스템_공통코드_상세
COMMENT ON CONSTRAINT "sm_comm_h_TO_sm_comm_d" ON "sm_comm_d" IS '시스템_공통코드_TO_시스템_공통코드_상세';

-- 시스템_그룹
ALTER TABLE "sm_group"
	ADD CONSTRAINT "mdm_biz_TO_sm_group"
	 -- MDM_사업장_TO_시스템_그룹
		FOREIGN KEY (
			"biz_seq" -- 사업장_SEQ
		)
		REFERENCES "mdm_biz" ( -- MDM_사업장
			"biz_seq" -- 사업장_SEQ
		);

-- MDM_사업장_TO_시스템_그룹
COMMENT ON CONSTRAINT "mdm_biz_TO_sm_group" ON "sm_group" IS 'MDM_사업장_TO_시스템_그룹';

-- 시스템_로그_접근_상세
ALTER TABLE "sm_log_conn_dtl"
	ADD CONSTRAINT "sm_log_conn_TO_sm_log_conn_dtl"
	 -- 시스템_로그_접근_TO_시스템_로그_접근_상세(NEW)
		FOREIGN KEY (
			"log_conn_seq" -- 접근_로그_SEQ
		)
		REFERENCES "sm_log_conn" ( -- 시스템_로그_접근
			"log_conn_seq" -- 접근_로그_SEQ
		);

-- 시스템_로그_접근_TO_시스템_로그_접근_상세(NEW)
COMMENT ON CONSTRAINT "sm_log_conn_TO_sm_log_conn_dtl" ON "sm_log_conn_dtl" IS '시스템_로그_접근_TO_시스템_로그_접근_상세(NEW)';

-- 시스템_메뉴_그룹
ALTER TABLE "sm_menu_group"
	ADD CONSTRAINT "sm_menu_TO_sm_menu_group"
	 -- 시스템_메뉴_TO_시스템_메뉴_그룹
		FOREIGN KEY (
			"menu_cd" -- 메뉴_코드
		)
		REFERENCES "sm_menu" ( -- 시스템_메뉴
			"menu_cd" -- 메뉴_코드
		);

-- 시스템_메뉴_TO_시스템_메뉴_그룹
COMMENT ON CONSTRAINT "sm_menu_TO_sm_menu_group" ON "sm_menu_group" IS '시스템_메뉴_TO_시스템_메뉴_그룹';

-- 시스템_메뉴_그룹
ALTER TABLE "sm_menu_group"
	ADD CONSTRAINT "sm_group_TO_sm_menu_group"
	 -- 시스템_그룹_TO_시스템_메뉴_그룹
		FOREIGN KEY (
			"group_seq" -- 그룹_SEQ
		)
		REFERENCES "sm_group" ( -- 시스템_그룹
			"group_seq" -- 그룹_SEQ
		);

-- 시스템_그룹_TO_시스템_메뉴_그룹
COMMENT ON CONSTRAINT "sm_group_TO_sm_menu_group" ON "sm_menu_group" IS '시스템_그룹_TO_시스템_메뉴_그룹';

-- 시스템_메뉴_옵션_설정
ALTER TABLE "sm_menu_opt_config"
	ADD CONSTRAINT "sm_menu_TO_sm_menu_opt_config"
	 -- 시스템_메뉴_TO_시스템_메뉴_옵션_설정
		FOREIGN KEY (
			"menu_cd" -- 메뉴_코드
		)
		REFERENCES "sm_menu" ( -- 시스템_메뉴
			"menu_cd" -- 메뉴_코드
		);

-- 시스템_메뉴_TO_시스템_메뉴_옵션_설정
COMMENT ON CONSTRAINT "sm_menu_TO_sm_menu_opt_config" ON "sm_menu_opt_config" IS '시스템_메뉴_TO_시스템_메뉴_옵션_설정';

-- 시스템_알람_이력
ALTER TABLE "sm_alarm_history"
	ADD CONSTRAINT "mdm_biz_TO_sm_alarm_history"
	 -- MDM_사업장_TO_시스템_알람_이력
		FOREIGN KEY (
			"biz_seq" -- 사업장_SEQ
		)
		REFERENCES "mdm_biz" ( -- MDM_사업장
			"biz_seq" -- 사업장_SEQ
		);

-- MDM_사업장_TO_시스템_알람_이력
COMMENT ON CONSTRAINT "mdm_biz_TO_sm_alarm_history" ON "sm_alarm_history" IS 'MDM_사업장_TO_시스템_알람_이력';

-- 시스템_택배_적용
ALTER TABLE "sm_dlv_config_applied"
	ADD CONSTRAINT "sm_dlv_config_TO_sm_dlv_config_applied"
	 -- 시스템_택배_설정_TO_시스템_택배_적용
		FOREIGN KEY (
			"dlv_config_seq" -- 택배_설정_SEQ
		)
		REFERENCES "sm_dlv_config" ( -- 시스템_택배_설정
			"dlv_config_seq" -- 택배_설정_SEQ
		);

-- 시스템_택배_설정_TO_시스템_택배_적용
COMMENT ON CONSTRAINT "sm_dlv_config_TO_sm_dlv_config_applied" ON "sm_dlv_config_applied" IS '시스템_택배_설정_TO_시스템_택배_적용';

-- 시스템_파일
ALTER TABLE "sm_file"
	ADD CONSTRAINT "mdm_biz_TO_sm_file"
	 -- MDM_사업장_TO_시스템_파일
		FOREIGN KEY (
			"biz_seq" -- 사업장_SEQ
		)
		REFERENCES "mdm_biz" ( -- MDM_사업장
			"biz_seq" -- 사업장_SEQ
		);

-- MDM_사업장_TO_시스템_파일
COMMENT ON CONSTRAINT "mdm_biz_TO_sm_file" ON "sm_file" IS 'MDM_사업장_TO_시스템_파일';

-- 시스템_파일_업무
ALTER TABLE "sm_file_req"
	ADD CONSTRAINT "sm_file_TO_sm_file_req"
	 -- 시스템_파일_TO_시스템_파일_업무(NEW)
		FOREIGN KEY (
			"file_seq" -- 파일_SEQ
		)
		REFERENCES "sm_file" ( -- 시스템_파일
			"file_seq" -- 파일_SEQ
		);

-- 시스템_파일_TO_시스템_파일_업무(NEW)
COMMENT ON CONSTRAINT "sm_file_TO_sm_file_req" ON "sm_file_req" IS '시스템_파일_TO_시스템_파일_업무(NEW)';