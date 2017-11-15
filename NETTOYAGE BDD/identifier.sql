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


--=====================================================================================
-- PACKAGE 2
--=====================================================================================

--------------------------------------------
--Creation d'un tablespace pour EMODE_INC
--------------------------------------------
CREATE TABLESPACE EMODE_INC_DATA
DATAFILE 'E:\app\oracle\oradata\prod\EMODE_INC.dbf' size 100M
AUTOEXTEND ON
NEXT 1M
MAXSIZE 1024M
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
SEGMENT SPACE MANAGEMENT AUTO;

--------------------------------------------
--Creation du User EMODE_INC
--------------------------------------------
CREATE USER EMODE_INC
IDENTIFIED BY EMODE_INC
DEFAULT TABLESPACE EMODE_INC_DATA;

-- rôles
GRANT connect, resource to EMODE_INC;

-- connexion à la nouvelle base
CONNECT EMODE_INC/EMODE_INC;

--------------------------------------------
--Creation des nouvelles tables EMODE_INC
--------------------------------------------

CREATE TABLE ARTICLE_COLOR_LOOKUP_INC (
   ARTICLE_CODE   NUMBER(6)
  ,COLOR_CODE     NUMBER(4)
  ,ARTICLE_LABEL  VARCHAR2(45)
  ,COLOR_LABEL    VARCHAR2(30)
  ,CATEGORY       VARCHAR2(25)
  ,SALE_PRICE     NUMBER(8,2)
  ,FAMILY_NAME    VARCHAR2(20)
  ,FAMILY_CODE    VARCHAR2(3)
  ,OPERATION      VARCHAR2(1)
  ,CONSTRAINT ACLI_CHECK_OPERATION CHECK (OPERATION IN('I' , 'D' , 'U' ))
);


CREATE TABLE SHOP_FACTS_INC (
   ID             NUMBER(5)
  ,ARTICLE_CODE   NUMBER(6)
  ,COLOR_CODE     NUMBER(4)
  ,WEEK_KEY       NUMBER(3)
  ,SHOP_CODE      NUMBER(4)
  ,MARGIN         NUMBER(13,2)
  ,AMOUNT_SOLD    NUMBER(13,2)
  ,QUANTITY_SOLD  NUMBER(13,2)
  ,OPERATION      VARCHAR2(1)
  ,CONSTRAINT SFI_CHECK_OPERATION CHECK (OPERATION IN('I' , 'D' , 'U' ))
);

CREATE TABLE OUTLET_LOOKUP_INC (
   SHOP_NAME           VARCHAR2(30) 
  ,ADDRESS_1           VARCHAR2(20) 
  ,MANAGER             VARCHAR2(10) 
  ,DATE_OPEN           DATE         
  ,OPEN                VARCHAR2(1)  
  ,OWNED_OUTRIGHT      VARCHAR2(1)  
  ,FLOOR_SPACE         NUMBER(4)    
  ,ZIP_CODE            VARCHAR2(6)  
  ,CITY                VARCHAR2(20) 
  ,STATE               VARCHAR2(20) 
  ,SHOP_CODE           NUMBER(3)
  ,OPERATION          VARCHAR2(1)
  ,CONSTRAINT OLI_CHECK_OPERATION CHECK (OPERATION IN('I' , 'D' , 'U' ))
);

CREATE TABLE ARTICLE_LOOKUP_INC (
   ARTICLE_CODE       NUMBER(6)    
  ,ARTICLE_LABEL      VARCHAR2(45) 
  ,CATEGORY           VARCHAR2(25) 
  ,SALE_PRICE         NUMBER(8,2)  
  ,FAMILY_NAME        VARCHAR2(20) 
  ,FAMILY_CODE        VARCHAR2(3) 
  ,OPERATION          VARCHAR2(1)
  ,CONSTRAINT ALI_CHECK_OPERATION CHECK (OPERATION IN('I' , 'D' , 'U' ))
);

CREATE TABLE CALENDAR_YEAR_LOOKUP_INC (
   WEEK_KEY           NUMBER(3)    
  ,WEEK_IN_YEAR       NUMBER(2)    
  ,YEAR               NUMBER(4)    
  ,FISCAL_PERIOD      VARCHAR2(4)  
  ,YEAR_WEEK          VARCHAR2(7)  
  ,QUARTER            NUMBER(1)    
  ,MONTH_NAME         VARCHAR2(10) 
  ,MONTH              NUMBER(2)    
  ,HOLIDAY_FLAG       VARCHAR2(1) 
  ,OPERATION          VARCHAR2(1)
  ,CONSTRAINT CYLI_CHECK_OPERATION CHECK (OPERATION IN('I' , 'D' , 'U' ))
);


--------------------------------------------------------------
-- Attribution des privilèges à EMODE : A FAIRE DANS EMODE_INC
--------------------------------------------------------------
GRANT select, delete, insert, update on ARTICLE_COLOR_LOOKUP_INC to EMODE;
GRANT select, delete, insert, update on ARTICLE_LOOKUP_INC to EMODE;
GRANT select, delete, insert, update on OUTLET_LOOKUP_INC to EMODE;
GRANT select, delete, insert, update on SHOP_FACTS_INC to EMODE;
GRANT select, delete, insert, update on CALENDAR_YEAR_LOOKUP_INC to EMODE;

-- A FAIRE DANS EMODE
ALTER USER EMODE quota unlimited on EMODE_INC_DATA; 
ALTER USER EMODE_INC quota unlimited on EMODE_INC_DATA; 

-----------------------------------------------------------
-- création des triggers dans EMODE pour EMODE_INC (ORACLE)
-----------------------------------------------------------
-- /!\ Après modification : il faut COMMIT pour que les triggers s'exécutent /!\ 

-----------
CREATE OR REPLACE TRIGGER "TR_ARTICLE_COLOR_LOOKUP"
  AFTER INSERT OR UPDATE OR DELETE ON ARTICLE_COLOR_LOOKUP
  FOR EACH ROW
    BEGIN
    CASE
      WHEN INSERTING THEN
        INSERT INTO EMODE_INC.ARTICLE_COLOR_LOOKUP_INC (ARTICLE_CODE, COLOR_CODE, ARTICLE_LABEL, COLOR_LABEL, CATEGORY, SALE_PRICE, FAMILY_NAME, FAMILY_CODE, OPERATION)
        VALUES (:NEW.ARTICLE_CODE, :NEW.COLOR_CODE, :NEW.ARTICLE_LABEL, :NEW.COLOR_LABEL, :NEW.CATEGORY, :NEW.SALE_PRICE, :NEW.FAMILY_NAME, :NEW.FAMILY_CODE, 'I');
      WHEN UPDATING THEN
        INSERT INTO EMODE_INC.ARTICLE_COLOR_LOOKUP_INC (ARTICLE_CODE, COLOR_CODE, ARTICLE_LABEL, COLOR_LABEL, CATEGORY, SALE_PRICE, FAMILY_NAME, FAMILY_CODE, OPERATION)
        VALUES (:NEW.ARTICLE_CODE, :NEW.COLOR_CODE, :NEW.ARTICLE_LABEL, :NEW.COLOR_LABEL, :NEW.CATEGORY, :NEW.SALE_PRICE, :NEW.FAMILY_NAME, :NEW.FAMILY_CODE, 'U');
      WHEN DELETING THEN
        INSERT INTO EMODE_INC.ARTICLE_COLOR_LOOKUP_INC (ARTICLE_CODE, COLOR_CODE, ARTICLE_LABEL, COLOR_LABEL, CATEGORY, SALE_PRICE, FAMILY_NAME, FAMILY_CODE, OPERATION)
        VALUES (:OLD.ARTICLE_CODE, :OLD.COLOR_CODE, :OLD.ARTICLE_LABEL, :OLD.COLOR_LABEL, :OLD.CATEGORY, :OLD.SALE_PRICE, :OLD.FAMILY_NAME, :OLD.FAMILY_CODE, 'D');
    END CASE;
END TR_ARTICLE_COLOR_LOOKUP;

-----------
CREATE OR REPLACE TRIGGER "TR_ARTICLE_LOOKUP"
  AFTER INSERT OR UPDATE OR DELETE ON ARTICLE_LOOKUP
  FOR EACH ROW
    BEGIN
    CASE
      WHEN INSERTING THEN
        INSERT INTO EMODE_INC.ARTICLE_LOOKUP_INC (ARTICLE_CODE, ARTICLE_LABEL, CATEGORY, SALE_PRICE, FAMILY_NAME, FAMILY_CODE, OPERATION)
        VALUES (:NEW.ARTICLE_CODE,:NEW.ARTICLE_LABEL, :NEW.CATEGORY, :NEW.SALE_PRICE, :NEW.FAMILY_NAME, :NEW.FAMILY_CODE, 'I');
      WHEN UPDATING THEN
        INSERT INTO EMODE_INC.ARTICLE_LOOKUP_INC (ARTICLE_CODE, ARTICLE_LABEL, CATEGORY, SALE_PRICE, FAMILY_NAME, FAMILY_CODE, OPERATION)
        VALUES (:NEW.ARTICLE_CODE, :NEW.ARTICLE_LABEL, :NEW.CATEGORY, :NEW.SALE_PRICE, :NEW.FAMILY_NAME, :NEW.FAMILY_CODE, 'U');
      WHEN DELETING THEN
        INSERT INTO EMODE_INC.ARTICLE_LOOKUP_INC (ARTICLE_CODE, ARTICLE_LABEL, CATEGORY, SALE_PRICE, FAMILY_NAME, FAMILY_CODE, OPERATION)
        VALUES (:OLD.ARTICLE_CODE,:OLD.ARTICLE_LABEL, :OLD.CATEGORY, :OLD.SALE_PRICE,:OLD.FAMILY_NAME, :OLD.FAMILY_CODE, 'D');
    END CASE;
END TR_ARTICLE_LOOKUP;

-----------
CREATE OR REPLACE TRIGGER "TR_CALENDAR_YEAR_LOOKUP"
  AFTER INSERT OR UPDATE OR DELETE ON CALENDAR_YEAR_LOOKUP
  FOR EACH ROW
    BEGIN
    CASE
      WHEN INSERTING THEN
        INSERT INTO EMODE_INC.CALENDAR_YEAR_LOOKUP_INC (WEEK_KEY, WEEK_IN_YEAR, YEAR, FISCAL_PERIOD, YEAR_WEEK, QUARTER, MONTH_NAME, MONTH, HOLIDAY_FLAG, OPERATION)
        VALUES (:NEW.WEEK_KEY,:NEW.WEEK_IN_YEAR, :NEW.YEAR, :NEW.FISCAL_PERIOD, :NEW.YEAR_WEEK, :NEW.QUARTER, :NEW.MONTH_NAME, :NEW.MONTH, :NEW.HOLIDAY_FLAG, 'I');
      WHEN UPDATING THEN
        INSERT INTO EMODE_INC.CALENDAR_YEAR_LOOKUP_INC (WEEK_KEY, WEEK_IN_YEAR, YEAR, FISCAL_PERIOD, YEAR_WEEK, QUARTER, MONTH_NAME, MONTH, HOLIDAY_FLAG, OPERATION)
        VALUES (:NEW.WEEK_KEY,:NEW.WEEK_IN_YEAR, :NEW.YEAR, :NEW.FISCAL_PERIOD, :NEW.YEAR_WEEK, :NEW.QUARTER, :NEW.MONTH_NAME, :NEW.MONTH, :NEW.HOLIDAY_FLAG, 'U');
      WHEN DELETING THEN
        INSERT INTO EMODE_INC.CALENDAR_YEAR_LOOKUP_INC (WEEK_KEY, WEEK_IN_YEAR, YEAR, FISCAL_PERIOD, YEAR_WEEK, QUARTER, MONTH_NAME, MONTH, HOLIDAY_FLAG, OPERATION)
        VALUES (:OLD.WEEK_KEY,:OLD.WEEK_IN_YEAR, :OLD.YEAR, :OLD.FISCAL_PERIOD, :OLD.YEAR_WEEK, :OLD.QUARTER, :OLD.MONTH_NAME, :OLD.MONTH, :OLD.HOLIDAY_FLAG, 'D');
    END CASE;
END TR_CALENDAR_YEAR_LOOKUP;

-----------
CREATE OR REPLACE TRIGGER "TR_OUTLET_LOOKUP"
  AFTER INSERT OR UPDATE OR DELETE ON OUTLET_LOOKUP
  FOR EACH ROW
    BEGIN
    CASE
      WHEN INSERTING THEN
        INSERT INTO EMODE_INC.OUTLET_LOOKUP_INC (SHOP_NAME, ADDRESS_1, MANAGER, DATE_OPEN, OPEN, OWNED_OUTRIGHT, FLOOR_SPACE, ZIP_CODE, CITY, STATE, SHOP_CODE, OPERATION)
        VALUES (:NEW.SHOP_NAME, :NEW.ADDRESS_1, :NEW.MANAGER, :NEW.DATE_OPEN, :NEW.OPEN, :NEW.OWNED_OUTRIGHT, :NEW.FLOOR_SPACE, :NEW.ZIP_CODE, :NEW.CITY, :NEW.STATE, :NEW.SHOP_CODE, 'I');

      WHEN UPDATING THEN
        INSERT INTO EMODE_INC.OUTLET_LOOKUP_INC (SHOP_NAME, ADDRESS_1, MANAGER, DATE_OPEN, OPEN, OWNED_OUTRIGHT, FLOOR_SPACE, ZIP_CODE, CITY, STATE, SHOP_CODE, OPERATION)
        VALUES (:NEW.SHOP_NAME, :NEW.ADDRESS_1, :NEW.MANAGER, :NEW.DATE_OPEN, :NEW.OPEN, :NEW.OWNED_OUTRIGHT, :NEW.FLOOR_SPACE, :NEW.ZIP_CODE, :NEW.CITY, :NEW.STATE, :NEW.SHOP_CODE, 'U');

      WHEN DELETING THEN
        INSERT INTO EMODE_INC.OUTLET_LOOKUP_INC (SHOP_NAME, ADDRESS_1, MANAGER, DATE_OPEN, OPEN, OWNED_OUTRIGHT, FLOOR_SPACE, ZIP_CODE, CITY, STATE, SHOP_CODE, OPERATION)
        VALUES (:OLD.SHOP_NAME, :OLD.ADDRESS_1, :OLD.MANAGER, :OLD.DATE_OPEN, :OLD.OPEN, :OLD.OWNED_OUTRIGHT, :OLD.FLOOR_SPACE, :OLD.ZIP_CODE, :OLD.CITY, :OLD.STATE, :OLD.SHOP_CODE, 'D');
    END CASE;
END TR_OUTLET_LOOKUP;

-----------
CREATE OR REPLACE TRIGGER "TR_SHOP_FACTS"
  AFTER INSERT OR UPDATE OR DELETE ON SHOP_FACTS
  FOR EACH ROW
    BEGIN
    CASE
      WHEN INSERTING THEN
        INSERT INTO EMODE_INC.SHOP_FACTS_INC (ID, ARTICLE_CODE, COLOR_CODE, WEEK_KEY, SHOP_CODE, MARGIN, AMOUNT_SOLD, QUANTITY_SOLD, OPERATION)
        VALUES (:NEW.ID, :NEW.ARTICLE_CODE, :NEW.COLOR_CODE, :NEW.WEEK_KEY, :NEW.SHOP_CODE, :NEW.MARGIN, :NEW.AMOUNT_SOLD, :NEW.QUANTITY_SOLD, 'I');
      WHEN UPDATING THEN
        INSERT INTO EMODE_INC.SHOP_FACTS_INC (ID, ARTICLE_CODE, COLOR_CODE, WEEK_KEY, SHOP_CODE, MARGIN, AMOUNT_SOLD, QUANTITY_SOLD, OPERATION)
        VALUES (:NEW.ID, :NEW.ARTICLE_CODE, :NEW.COLOR_CODE, :NEW.WEEK_KEY, :NEW.SHOP_CODE, :NEW.MARGIN, :NEW.AMOUNT_SOLD, :NEW.QUANTITY_SOLD, 'U');
      WHEN DELETING THEN
        INSERT INTO EMODE_INC.SHOP_FACTS_INC (ID, ARTICLE_CODE, COLOR_CODE, WEEK_KEY, SHOP_CODE, MARGIN, AMOUNT_SOLD, QUANTITY_SOLD, OPERATION)
        VALUES (:OLD.ID, :OLD.ARTICLE_CODE, :OLD.COLOR_CODE, :OLD.WEEK_KEY, :OLD.SHOP_CODE, :OLD.MARGIN, :OLD.AMOUNT_SOLD, :OLD.QUANTITY_SOLD, 'D');
    END CASE;
END TR_SHOP_FACTS;

--------
-- TESTS
--------

-----------
insert into ARTICLE_COLOR_LOOKUP values (100,627,'Long-Sleeved Crewneck T-Shirt','Tomato','T-Shirts',188,'Sweat-T-Shirts','F36');
insert into ARTICLE_COLOR_LOOKUP values (102,627,'Long-Sleeved Crewneck T-Shirt','Tomato','T-Shirts',188,'Sweat-T-Shirts','F36');
insert into ARTICLE_COLOR_LOOKUP values (101,627,'Long-Sleeved Crewneck T-Shirt','Tomato','T-Shirts',188,'Sweat-T-Shirts','F36');
delete ARTICLE_COLOR_LOOKUP where ARTICLE_CODE=102;
update ARTICLE_COLOR_LOOKUP set COLOR_LABEL='YOLO' where ARTICLE_CODE=101;
commit;

-----------
insert into ARTICLE_LOOKUP values (102,'Long-Sleeved Crewneck T-Shirt','T-Shirts',188,'Sweat-T-Shirts','F36');
insert into ARTICLE_LOOKUP values (104,'Long-Sleeved Crewneck T-Shirt','T-Shirts',188,'Sweat-T-Shirts','F36');
insert into ARTICLE_LOOKUP values (103,'Long-Sleeved Crewneck T-Shirt','T-Shirts',188,'Sweat-T-Shirts','F36');
delete ARTICLE_LOOKUP where ARTICLE_CODE=104;
update ARTICLE_LOOKUP set ARTICLE_LABEL='YOLO' where ARTICLE_CODE=103;
commit;

-----------
insert into CALENDAR_YEAR_LOOKUP values (263,1,2001,'FY01','2001/1',1,'January',1,'n');
insert into CALENDAR_YEAR_LOOKUP values (265,1,2001,'FY01','2001/1',1,'January',1,'n');
insert into CALENDAR_YEAR_LOOKUP values (264,2,2001,'FY01','2001/2',1,'January',1,'n');
delete CALENDAR_YEAR_LOOKUP where WEEK_KEY=265;
update CALENDAR_YEAR_LOOKUP set MONTH_NAME='YOLO' where WEEK_KEY=264;
commit;

-----------
insert into OUTLET_LOOKUP values ('e-Fashion BELFORT','10, BELFORT Avenue','Lucie','21/11/95','Y','N',1950,280941,'BELFORT','France',400);
insert into OUTLET_LOOKUP values ('e-Fashion BELFORT','10, BELFORT Avenue','Lucie','21/11/95','Y','N',1950,280941,'BELFORT','France',402);
insert into OUTLET_LOOKUP values ('e-Fashion STRASBOURG','11, STRASBOURG Avn','Mika','21/11/94','Y','Y',1950,280941,'STRASBOURG','France',401);
delete OUTLET_LOOKUP where SHOP_CODE=402;
update OUTLET_LOOKUP set SHOP_NAME='YOLO' where SHOP_CODE=401;
commit;

-----------
insert into SHOP_FACTS values (90000,150850,212,158,110,20.6,99,1);
insert into SHOP_FACTS values (90002,150850,212,158,110,20.6,99,1);
insert into SHOP_FACTS values (90001,150850,212,158,110,40,199,11);
delete SHOP_FACTS where ID=90002;
update SHOP_FACTS set COLOR_CODE=606 where ID=90001;
commit;

-------------------------------------------
-- création des tables d'audit (SQL server)
-------------------------------------------
CREATE TABLE TRANSFER_AUDIT (
   TRANSFERID NUMERIC(10) IDENTITY(1, 1) NOT NULL
  ,START_DATE DATE
  ,CONSTRAINT PK_TRANSFER_AUDIT PRIMARY KEY (TRANSFERID)
);

-----------
CREATE TABLE LINE_AUDIT (
   LINEID NUMERIC(10) IDENTITY(1, 1) NOT NULL 
  ,TRANSFERID NUMERIC(10)
  ,TABLE_NAME VARCHAR(20)
  ,INSERTED_NB NUMERIC(10)
  ,DELETED_NB NUMERIC(10)
  ,UPDATED_NB NUMERIC(10)
  ,REJECTED_NB NUMERIC(10)
  ,CONSTRAINT PK_LINE_AUDIT PRIMARY KEY (LINEID)
  ,CONSTRAINT FK_LINE_AUDIT FOREIGN KEY (TRANSFERID)
    REFERENCES TRANSFER_AUDIT (TRANSFERID)
);

-----------
CREATE TABLE ERROR_AUDIT (
   ERRORID NUMERIC(10) IDENTITY(1, 1) NOT NULL
  ,TRANSFERID NUMERIC(10)
  ,TABLE_NAME VARCHAR(20)
  ,LINE_PK NUMERIC(10)
  ,INFO_ERROR VARCHAR(100)
  ,CONSTRAINT PK_ERROR_AUDIT PRIMARY KEY (ERRORID)
  ,CONSTRAINT FK_ERROR_AUDIT FOREIGN KEY (TRANSFERID)
    REFERENCES TRANSFER_AUDIT (TRANSFERID)
);
