-- =============================================================
-- TT_550_WIN: 03_center (센터)
-- 고객사:     테스트
-- 생성일시:   2026-05-13 10:38:44
-- 실행 모드:  PYTHON (psycopg2 2.9.12 (dt dec pq3 ext lo64))
-- 원본 DB:   localhost:15432/wms-bnk-local (schema=public, PG 15.17)
-- 대상 테이블: mdm_center
-- 적용 방법: psql -h <host> -U <user> -d <db> -f 03_center.sql
-- =============================================================
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
BEGIN;

-- FK 역순 DELETE
DELETE FROM "public"."mdm_center";

-- FK 정순 INSERT
INSERT INTO "public"."mdm_center" ("center_seq","center_nm","tel","email","post_no","addr","addr_dtl","center_file_seq","tpl_yn","note","use_yn","reg_id","reg_dt","mod_id","mod_dt") VALUES (1,'오산 물류센터',NULL,NULL,'18150','경기 오산시 동부대로 446','풍농 오산물류센터 4층',NULL,'N',NULL,'Y','SYSTEM','2026-02-03 11:40:33'::timestamp,NULL,NULL);

COMMIT;

-- 적용 후 검증
SELECT 'mdm_center' AS tbl, COUNT(*) FROM "public"."mdm_center";
