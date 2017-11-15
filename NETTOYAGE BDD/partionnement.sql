--Récupération du max WEEK_KEY :

select max(WEEK_KEY) from SHOP_FACTS

-- 262


select min(WEEK_KEY), max(WEEK_KEY) from CALENDAR_YEAR_LOOKUP
-- min : 1 , max : 262


-- On va effectuer un partionnement sur week_key à partir de l'année 1997. Une année correspond à 52 semaines 
-- On commence par 1 .. 53 .. 105........ 

-- 1. création des espaces de stockage du partitionnement

ALTER DATABASE EMODE 
   ADD FILEGROUP DATA_PART_1997; 
 
ALTER DATABASE EMODE 
   ADD FILEGROUP DATA_PART_1998; 
 
ALTER DATABASE EMODE 
   ADD FILEGROUP DATA_PART_1999; 
 
ALTER DATABASE EMODE 
   ADD FILEGROUP DATA_PART_2000; 
 
ALTER DATABASE EMODE 
   ADD FILEGROUP DATA_PART_2001; 

ALTER DATABASE EMODE 
   ADD FILEGROUP DATA_PART_2002; 
 
--ajouts de fichiers aux storages : 
ALTER DATABASE EMODE 
   ADD FILE (NAME       = 'F_PART_1997', 
             FILENAME   = 'E:\bases\Partitions\F_part_1997.ndf', 
             SIZE       = 150 GB,  
             FILEGROWTH = 10 MB)  
TO FILEGROUP DATA_PART_1997; 
 
ALTER DATABASE EMODE 
   ADD FILE (NAME       = 'F_PART_1998', 
             FILENAME   = 'E:\bases\Partitions\F_part_1998.ndf', 
             SIZE       = 150 GB,  
             FILEGROWTH = 10 MB)  
TO FILEGROUP DATA_PART_1998; 
 
ALTER DATABASE EMODE 
   ADD FILE (NAME       = 'F_PART_1999', 
             FILENAME   = 'E:\bases\Partitions\F_part_1999.ndf', 
             SIZE       = 150 GB,  
             FILEGROWTH = 10 MB)  
TO FILEGROUP DATA_PART_1999; 
 
ALTER DATABASE EMODE 
   ADD FILE (NAME       = 'F_PART_2000', 
             FILENAME   = 'E:\bases\Partitions\F_part_2000.ndf', 
             SIZE       = 150 GB,  
             FILEGROWTH = 10 MB)  
TO FILEGROUP DATA_PART_2000; 
 
ALTER DATABASE EMODE 
   ADD FILE (NAME       = 'F_PART_2001', 
             FILENAME   = 'E:\bases\Partitions\F_part_2001.ndf', 
             SIZE       = 150 GB,  
             FILEGROWTH = 10 MB)  
TO FILEGROUP DATA_PART_2001;

ALTER DATABASE EMODE 
   ADD FILE (NAME       = 'F_PART_2002', 
             FILENAME   = 'E:\bases\Partitions\F_part_2002.ndf', 
             SIZE       = 150 GB,  
             FILEGROWTH = 10 MB)  
TO FILEGROUP DATA_PART_2002;

--6 storage ont été créé et dans chacun de ces espaces de stockage on a créé un fichier de 1 Go avec uns stratégie de croissance par pas de 10 Mo. 

-- 2.  création d’une fonction de partitionnement

CREATE PARTITION FUNCTION F_PART_SHOPFACTS (WEEK_KEY) 
AS 
  RANGE LEFT 
  FOR VALUES (53,105,157,209,263);

-- On a défini 5 valeurs pivot ce qui impose au moins  6 partitions :

partition 1, de 0 à 53
partition 2, de 54 à 105
partition 3, de 106 à 157
partition 4, de 158 à 209
partition 5, de 210 à 263
partition 6, de 264 a infini


-- RANGE LEFT signifie que la valeur borne est incluse dans la partition à droite.

--3. création du schéma de partitionnement

CREATE PARTITION SCHEME SCH_PART_SHOPFACTS
AS PARTITION F_PART_SHOPFACTS
TO ( DATA_PART_1997, DATA_PART_1998, DATA_PART_1999, DATA_PART_2000,
DATA_PART_2001, DATA_PART_2002 )

-- 4 - création de de la table partitionné

CREATE TABLE SHOP_FACTS_PART(
ID numeric(5, 0) NOT NULL,
ARTICLE_CODE numeric(6, 0) NULL,
COLOR_CODE numeric(4, 0) NULL,
WEEK_KEY numeric(3, 0) NULL,
SHOP_CODE numeric(3, 0) NULL,
MARGIN numeric(18, 0) NULL,
AMOUNT_SOLD numeric(13, 2) NULL,
QUANTITY_SOLD numeric(13, 2) NULL
)ON SCH_PART_SHOPFACTS ([WEEK_KEY])


--5 transfert des données de la table shop_facts vers la table partitionné.

INSERT INTO SHOP_FACTS_PART SELECT * FROM SHOP_FACTS;


