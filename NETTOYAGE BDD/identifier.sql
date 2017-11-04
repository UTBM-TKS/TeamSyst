-----------------------
--- Emode
-----------------------

-------------------------------------------------------------
-- IDENTIFICATION

-- Deux problèmes de données sur la BDD
--
-- I)
--

-- affiche les différences entre "nb de lignes" et "nb de PK"
SELECT
  'SHOP_FACTS'              NAME_table
  ,COUNT(*)                 NB_rows
  ,COUNT(distinct(SHF.id))  PK_distinct
FROM
  SHOP_FACTS SHF
UNION
SELECT
  'CALENDAR_YEAR_LOOKUP'          NAME_table
  ,COUNT(*)                       NB_rows
  ,COUNT(distinct(CYL.week_key))  PK_distinct
FROM
  CALENDAR_YEAR_LOOKUP CYL
UNION
SELECT
  'OUTLET_LOOKUP'                   NAME_table
  ,COUNT(*)                         NB_rows
  ,COUNT(distinct(OTL.shop_code ))  PK_distinct
FROM
  OUTLET_LOOKUP OTL
UNION
SELECT
  'ARTICLE_COLOR_LOOKUP'                                      NAME_table
  ,COUNT(*)                                                   NB_rows
  ,COUNT(distinct(concat(ACL.ARTICLE_CODE,ACL.COLOR_CODE)))   PK_distinct
FROM
  ARTICLE_COLOR_LOOKUP ACL
UNION
SELECT
  'ARTICLE_LOOKUP'                    NAME_table
  ,COUNT(*)                           NB_rows
  ,COUNT(distinct(ATL. article_code)) PK_distinct
FROM
  ARTICLE_LOOKUP ATL;

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
  ARTICLE_COLOR_LOOKUP ACL
WHERE
  ACL.ARTICLE_CODE=170016
AND 
  (ACL.COLOR_CODE=210
  OR
  ACL.COLOR_CODE=902)
ORDER BY 
  1,2;

-- supprime les doublons (PK)
DELETE
FROM
  ARTICLE_COLOR_LOOKUP ACL
WHERE
  (ACL.article_code = 170016 and ACL.color_code = 210 and ACL.CATEGORY = 'T-Shirts') 
OR
  (ACL.article_code = 170016 and ACL.color_code = 902 and ACL.CATEGORY = 'T-Shirts')
;

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

------------------------------------------------------------------------------------------------------------
-- méthode INSERT ROWS
------------------------------------------------------------------------------------------------------------

-- insertion des 14 lignes manquantes dans ARTICLE_COLOR_LOOKUP
INSERT ALL 
  INTO ARTICLE_COLOR_LOOKUP 
    VALUES(177264,627,'Long-Sleeved Crewneck T-Shirt','Tomato','T-Shirts',188,'Sweat-T-Shirts','F36')  
  INTO ARTICLE_COLOR_LOOKUP 
    VALUES(177264,182,'Long-Sleeved Crewneck T-Shirt','Blue Powder','T-Shirts',188,'Sweat-T-Shirts','F36')
  INTO ARTICLE_COLOR_LOOKUP 
    VALUES(177264,1103,'Long-Sleeved Crewneck T-Shirt','Ink','T-Shirts',188,'Sweat-T-Shirts','F36')
  INTO ARTICLE_COLOR_LOOKUP 
    VALUES(177264,199,'Long-Sleeved Crewneck T-Shirt','Ardoise Blue','T-Shirts',188,'Sweat-T-Shirts','F36')
  INTO ARTICLE_COLOR_LOOKUP 
    VALUES(177264,1224,'Long-Sleeved Crewneck T-Shirt','Jungle','T-Shirts',188,'Sweat-T-Shirts','F36')
  INTO ARTICLE_COLOR_LOOKUP 
    VALUES(177264,308,'Long-Sleeved Crewneck T-Shirt','Gold','T-Shirts',188,'Sweat-T-Shirts','F36')
  INTO ARTICLE_COLOR_LOOKUP 
    VALUES(177264,138,'Long-Sleeved Crewneck T-Shirt','Clay','T-Shirts',188,'Sweat-T-Shirts','F36')
  INTO ARTICLE_COLOR_LOOKUP 
    VALUES(177264,423,'Long-Sleeved Crewneck T-Shirt','Raspberry','T-Shirts',188,'Sweat-T-Shirts','F36')
  INTO ARTICLE_COLOR_LOOKUP 
    VALUES(177264,901,'Long-Sleeved Crewneck T-Shirt','White','T-Shirts',188,'Sweat-T-Shirts','F36')
  INTO ARTICLE_COLOR_LOOKUP 
    VALUES(177264,731,'Long-Sleeved Crewneck T-Shirt','Natural','T-Shirts',188,'Sweat-T-Shirts','F36')
  INTO ARTICLE_COLOR_LOOKUP 
    VALUES(177264,210,'Long-Sleeved Crewneck T-Shirt','Bottle Green','T-Shirts',188,'Sweat-T-Shirts','F36')
  INTO ARTICLE_COLOR_LOOKUP 
    VALUES(177264,1228,'Long-Sleeved Crewneck T-Shirt','Clear Ceramic','T-Shirts',188,'Sweat-T-Shirts','F36')
  INTO ARTICLE_COLOR_LOOKUP 
    VALUES(177264,902,'Long-Sleeved Crewneck T-Shirt','Black','T-Shirts',188,'Sweat-T-Shirts','F36')
  INTO ARTICLE_COLOR_LOOKUP 
    VALUES(177264,612,'Long-Sleeved Crewneck T-Shirt','Melon','T-Shirts',188,'Sweat-T-Shirts','F36')
SELECT 1 FROM dual; 

------------------------------------------------------------------------------------------------------------
-- méthode REJECT TABLES
------------------------------------------------------------------------------------------------------------
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
  ,MAX(ACL.ARTICLE_LABEL) "ARTICLE_LABEL"
  ,MAX(ACL.COLOR_LABEL) "COLOR_LABEL"
  ,MAX(ACL.CATEGORY)    "CATEGORY"
  ,MAX(ACL.SALE_PRICE)  "SALE_PRICE"
  ,MAX(ACL.FAMILY_NAME) "FAMILY_NAME"
  ,MAX(ACL.FAMILY_CODE) "FAMILY_CODE"
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


-- suppression des clés étrangères


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

------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------

-- identification des color_label différents
SELECT
   ACL.COLOR_CODE
  ,COUNT(DISTINCT ACL.COLOR_LABEL)

FROM
  ARTICLE_COLOR_LOOKUP ACL
GROUP BY
  ACL.COLOR_CODE
  HAVING COUNT(DISTINCT ACL.COLOR_LABEL) > 1
;


-- update des color_label
UPDATE 
  ARTICLE_COLOR_LOOKUP
SET
  COLOR_LABEL = case COLOR_CODE
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
WHERE COLOR_CODE IN(901,785,7004,1103,1200,702,1101,902,333,1109)
;



-- PACKAGE 1 TABLE SQL SERVER



CREATE TABLE [dbo].[SHOP_FACTS_REJECT](
  [ID] [numeric](5, 0) NULL,
  [ARTICLE_CODE] [numeric](6, 0) NULL,
  [COLOR_CODE] [numeric](4, 0) NULL,
  [WEEK_KEY] [numeric](3, 0) NULL,
  [SHOP_CODE] [numeric](4, 0) NULL,
  [MARGIN] [numeric](13, 2) NULL,
  [AMOUNT_SOLD] [numeric](13, 2) NULL,
  [QUANTITY_SOLD] [numeric](13, 2) NULL
) ON [PRIMARY]

CREATE TABLE [dbo].[ARTICLE_COLOR_LOOKUP_REJECT](
  [ARTICLE_CODE] [numeric](6, 0) NULL,
  [COLOR_CODE] [numeric](4, 0) NULL,
  [ARTICLE_LABEL] [nvarchar](45) NULL,
  [COLOR_LABEL] [nvarchar](30) NULL,
  [CATEGORY] [nvarchar](25) NULL,
  [SALE_PRICE] [numeric](8, 2) NULL,
  [FAMILY_NAME] [nvarchar](20) NULL,
  [FAMILY_CODE] [nvarchar](3) NULL
) ON [PRIMARY]
