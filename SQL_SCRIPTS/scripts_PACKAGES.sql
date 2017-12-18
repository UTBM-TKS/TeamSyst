

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
insert into CALENDAR_YEAR_LOOKUP values (263,1,2018,'FY01','2018/1',1,'January',1,'n');
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
