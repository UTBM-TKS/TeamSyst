-----------------------
--- Emode
-----------------------

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

-- Ces doublons sont ceux ci :
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
-- 14 res



