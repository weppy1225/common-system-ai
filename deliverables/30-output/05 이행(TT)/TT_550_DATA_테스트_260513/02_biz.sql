-- =============================================================
-- TT_550_WIN: 02_biz (사업장)
-- 고객사:     테스트
-- 생성일시:   2026-05-13 10:38:44
-- 실행 모드:  PYTHON (psycopg2 2.9.12 (dt dec pq3 ext lo64))
-- 원본 DB:   localhost:15432/wms-bnk-local (schema=public, PG 15.17)
-- 대상 테이블: mdm_biz, mdm_biz_biz
-- 적용 방법: psql -h <host> -U <user> -d <db> -f 02_biz.sql
-- =============================================================
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
BEGIN;

-- FK 역순 DELETE
DELETE FROM "public"."mdm_biz_biz";
DELETE FROM "public"."mdm_biz";

-- FK 정순 INSERT
INSERT INTO "public"."mdm_biz" ("biz_seq","biz_nm","biz_nm_short","ceo_nm","biz_no","sub_biz_no","biz_type","biz_item","biz_div_cd","contract_ymd","hq_yn","email","tel","fax","post_no","addr","addr_dtl","stamp_file_seq","logo_file_seq","if_biz_id","biz_color","note","use_yn","reg_id","reg_dt","mod_id","mod_dt") VALUES (1,'반다이남코 코리아','반다이남코 코리아','야마미치 후미아키','106-81-86950',NULL,'도매업','장난감','OWN',NULL,'Y',NULL,'1544-4607',NULL,'18150','경기 오산시 동부대로 446','풍농 오산물류센터 4층 반다이남코코리아',35,NULL,NULL,'#00afec','04516  서울 중구 서소문로 89   5층 (순화동, 순화빌딩)','Y','bnk','2026-02-02 15:27:54'::timestamp,'sjkim','2026-05-12 13:36:38'::timestamp);

INSERT INTO "public"."mdm_biz_biz" ("biz_seq","ref_biz_seq","use_yn","reg_id","reg_dt","mod_id","mod_dt") VALUES (1,1,'Y','SYSTEM','2026-02-03 11:40:33'::timestamp,NULL,NULL);

COMMIT;

-- 적용 후 검증
SELECT 'mdm_biz' AS tbl, COUNT(*) FROM "public"."mdm_biz"
UNION ALL
SELECT 'mdm_biz_biz' AS tbl, COUNT(*) FROM "public"."mdm_biz_biz";
