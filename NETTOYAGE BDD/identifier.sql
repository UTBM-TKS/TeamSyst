-----------------------
--- Emode
-----------------------

-------------------------------------------------------------
-- IDENTIFICATION

-- Deux problèmes de données sur la BDD
--
-- I)
--
-- La table ARTICLE_COLOR_LOOKUP contient 2 doublons car pas de contraintes de type PK
SELECT
  count(*)
FROM
  ARTICLE_COLOR_LOOKUP C
;
-- 663

SELECT
   count( DISTINCT CONCAT(C.ARTICLE_CODE,C.COLOR_CODE))
FROM
  ARTICLE_COLOR_LOOKUP C
;
-- 661

-- Ces doublons sont :
SELECT
   C.ARTICLE_CODE
  ,C.COLOR_CODE
  ,count(*)
FROM
   ARTICLE_COLOR_LOOKUP C
GROUP BY
   C.ARTICLE_CODE
  ,C.COLOR_CODE
  HAVING
    count(*) > 1
;

SELECT
  *
FROM
  ARTICLE_COLOR_LOOKUP C
WHERE
  C.ARTICLE_CODE=170016
AND (
  C.COLOR_CODE=210
OR
  C.COLOR_CODE=902);


--
-- II)
--
-- Il existe des factures liées à des codes-couleurs inexistants :
SELECT DISTINCT
   F.ARTICLE_CODE
  ,F.COLOR_CODE
FROM
   SHOP_FACTS F
WHERE
  CONCAT(F.ARTICLE_CODE,F.COLOR_CODE) NOT IN (
      SELECT CONCAT(C.ARTICLE_CODE,C.COLOR_CODE) FROM ARTICLE_COLOR_LOOKUP C
    )
ORDER BY
  1
;
-- 14 lignes distinctes

-------------------------------------------------------------
-- NETTOYAGE

-- On crée des tables de rejet  : 

CREATE TABLE SHOP_FACTS_REJECT (
	 ID NUMBER(5)
	,ARTICLE_CODE NUMBER(6)
	,COLOR_CODE NUMBER(4)
	,WEEK_KEY NUMBER(3)
	,SHOP_CODE NUMBER(4)
	,MARGIN NUMBER(13,2)
	,AMOUNT_SOLD NUMBER(13,2)
	,QUANTITY_SOLD NUMBER(13,2)
);

CREATE TABLE ARTICLE_COLOR_LOOKUP_REJECT (
	 ARTICLE_CODE NUMBER(6)
	,COLOR_CODE NUMBER(4)
	,ARTICLE_LABEL VARCHAR2(45)
	,COLOR_LABEL VARCHAR2(30)
	,CATEGORY VARCHAR2(25)
	,SALE_PRICE NUMBER(8,2)
	,FAMILY_NAME VARCHAR2(20)
	,FAMILY_CODE VARCHAR2(3)
);



INSERT INTO SHOP_FACTS_REJECT 
SELECT 
   *
FROM
   SHOP_FACTS F
WHERE
  CONCAT(F.ARTICLE_CODE,F.COLOR_CODE) NOT IN (
      SELECT CONCAT(C.ARTICLE_CODE,C.COLOR_CODE) FROM ARTICLE_COLOR_LOOKUP C
    )
ORDER BY
  1
;
-- 6 494 lignes insérées.

DELETE FROM SHOP_FACTS F
WHERE
  CONCAT(F.ARTICLE_CODE,F.COLOR_CODE) NOT IN (
      SELECT CONCAT(C.ARTICLE_CODE,C.COLOR_CODE) FROM ARTICLE_COLOR_LOOKUP C
    )

;
-- 6 494 lignes supprimées


-- INSERTION
INSERT INTO 
	ARTICLE_COLOR_LOOKUP_REJECT
SELECT 
	* 
FROM  
	(SELECT 
	 ACL.ARTICLE_CODE
	,ACL.COLOR_CODE
	,MAX(ACL.ARTICLE_LABEL)	"ARTICLE_LABEL"
	,MAX(ACL.COLOR_LABEL)	"COLOR_LABEL"
	,MAX(ACL.CATEGORY)		"CATEGORY"
	,MAX(ACL.SALE_PRICE)	"SALE_PRICE"
	,MAX(ACL.FAMILY_NAME)	"FAMILY_NAME"
	,MAX(ACL.FAMILY_CODE)	"FAMILY_CODE"
	FROM
	       article_color_lookup ACL
	GROUP BY 
	        article_code
	        ,color_code 
	HAVING
	        count(*) > 1 
	) AD 
WHERE 
	NOT EXISTS (
        select 
            AL.article_code
        from 
            article_lookup AL 
        where 
            AL.article_code= AD.article_code
        and   
            AL.family_name != AD.family_name
        );
-- 2 lignes insérées.


-- SUPPRESSION
-- A VOIR
DELETE FROM
ARTICLE_COLOR_LOOKUP aa
WHERE
concat(concat(aa.article_code,aa.color_code),aa.family_name) in
(
 With ArticleDoublon AS(
 select 
	concat(concat(ACL.article_code,ACL.color_code),ACL.family_name)
  from
       article_color_lookup ACL
  group by 
        article_code
        ,color_code 
  having
        count(*) > 1 
)
select * from ArticleDoublon AD where NOT EXISTS (
    select 
        AL.article_code
    from 
        article_lookup AL 
    where 
        AL.article_code= AD.article_code
    and   
        AL.family_name != AD.family_name
    )
)


-- identification des color_label différents
select
	 acl.COLOR_CODE
	,count(DISTINCT acl.COLOR_LABEL)

from
	ARTICLE_COLOR_LOOKUP acl
group by
	acl.COLOR_CODE
	having count(DISTINCT acl.COLOR_LABEL) > 1;


-- update des color_label
update 
	ARTICLE_COLOR_LOOKUP
set
	color_label = case color_code
				  when 901 then 'White'
				  when 785 then 'White'
				  when 7004 then 'Earth'
				  when 1103 then 'Ink'
				  when 1200 then 'Grass'
				  when 702 then 'Ivory'
				  when 1101 then 'Porcelain'
				  when 902 then 'Black'
				  when 333 then 'Honey'
				  when 1109 then 'Forget-me-not'
				  end
where color_code in(901,785,7004,1103,1200,702,1101,902,333,1109);




