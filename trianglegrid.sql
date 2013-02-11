
-- créer une table tirgrid level 1
drop table trigrid_l1;
create table trigrid_l1(gid integer,tx integer, ty integer);
SELECT AddGeometryColumn ('','trigrid_l1','the_geom',4326,'POLYGON',2);
select trigrid (-150,36,100,44,0.13,4326,'trigrid_l1');
CREATE INDEX sidx_trigrid_l1 ON trigrid_l1 USING GIST ( the_geom ); 
CREATE UNIQUE INDEX idx_trigrid_l1
  ON trigrid_l1
  USING btree
  (gid);
select count(*) from trigrid_l1;
-- 605200

-- créer une table tirgrid level 2
drop table trigrid_l2;
create table trigrid_l2(gid integer,tx integer, ty integer);
SELECT AddGeometryColumn ('','trigrid_l2','the_geom',4326,'POLYGON',2);
select trigrid (-150,36,100,44,0.065,4326,'trigrid_l2');
CREATE INDEX sidx_trigrid_l2 ON trigrid_l2 USING GIST ( the_geom ); 
CREATE UNIQUE INDEX idx_trigrid_l2
  ON trigrid_l2
  USING btree
  (gid);
select count(*) from trigrid_l2;
-- 2410968


-- J'ai créer un table basée sur Census 2011 et je veux créer des classes Quantiles rapidement.
-- http://stackoverflow.com/questions/8529985/postgresql-aggregates-with-multiple-parameters
SELECT ntile, avg(nb) AS avgAmount, max(nb) AS maxAmount, min(nb) AS  minAmount 
FROM (SELECT nb, ntile(5) OVER (ORDER BY nb) AS ntile FROM census_pop_2012_division) x
GROUP BY ntile ORDER BY ntile

ntile	avgamount	   maxamount	minamount
1       11736.7796610169   18000        629
2       23135.5593220339   31138        18036
3       39888.5762711864   50512        31333
4       72870.1206896552   104075       50900
5       428264.25862069    2615060      105719


create table census_pop_2012_division_gen01 as 
select gid, "CDUID" as cduid,
  "CDNAME" as cdname,
  "CDTYPE" as cdtype,
  "PRUID" as pruid,
  "PRNAME" as prname,
  "PROV" as priv,
  "DIV_NAME" as div_name,
  "NB" as nb,
  ST_SimplifyPreserveTopology(the_geom, 0.1) as the_geom
from census_pop_2012_division;


SELECT pg_size_pretty(pg_relation_size('census_pop_2012_division_gen01_shp')) as table_size;
SELECT pg_relation_size('census_pop_2012_division_gen01') as table_size;
SELECT pg_relation_size('census_pop_2012_division') as table_size;

ssh smercier@qc.mapgears.com

-- j'ai traité un table de census pour le besoin de ce test.  Voir le fichier dans répertoire projet cencus

ALTER table trigrid_l1 add column cls integer;
update trigrid_l1 SET cls=5 FROM census_pop_2012_division_gen01 WHERE ST_Intersects( trigrid_l1.the_geom,census_pop_2012_division_gen01.the_geom) and census_pop_2012_division_gen01.nb >105719;
-- 
update trigrid_l1 SET cls=4 FROM census_pop_2012_division_gen01 WHERE ST_Intersects( trigrid_l1.the_geom,census_pop_2012_division_gen01.the_geom) and census_pop_2012_division_gen01.nb >50900 and census_pop_2012_division_gen01.nb <=105719 ;
-- 
update trigrid_l1 SET cls=3 FROM census_pop_2012_division_gen01 WHERE ST_Intersects( trigrid_l1.the_geom,census_pop_2012_division_gen01.the_geom) and census_pop_2012_division_gen01.nb > 31333 and census_pop_2012_division_gen01.nb <= 50900 ;
-- 
update trigrid_l1 SET cls=2 FROM census_pop_2012_division_gen01 WHERE ST_Intersects( trigrid_l1.the_geom,census_pop_2012_division_gen01.the_geom) and census_pop_2012_division_gen01.nb > 18036 and census_pop_2012_division_gen01.nb <=31333;
-- 
update trigrid_l1 SET cls=1 FROM census_pop_2012_division_gen01 WHERE ST_Intersects( trigrid_l1.the_geom,census_pop_2012_division_gen01.the_geom) and census_pop_2012_division_gen01.nb <=18036;

select;
-- NOTE :: faire une recherche sur driven table pour voir si ya une différence dans postgresql

--cette requête ne répond pas, je vais simplifier pour voir
--SELECT count(*) from census_pop_2012_division c
--select count(*) from census_pop_2012_division_005;
--293
--select count(*) from census_pop_2012_division_01 where the_geom is null;
--0

--create table census_pop_2012_division_005 as select  gid serial ,cduid ,cdname,cdtype ,pruid,prname,prov,div_name,nb , ST_SimplifyPreserveTopology(the_geom, 0.005 ) from census_pop_2012_division;
--create table census_pop_2012_division_01 as select  gid serial ,cduid ,cdname,cdtype ,pruid,prname,prov,div_name,nb , ST_SimplifyPreserveTopology(the_geom, 0.01 ) as the_geom from census_pop_2012_division;
--SELECT pg_size_pretty(pg_total_relation_size('census_pop_2012_division_01'));
--3824 kb
--SELECT pg_size_pretty(pg_total_relation_size('census_pop_2012_division_005'));
--4904 kb
--SELECT pg_size_pretty(pg_total_relation_size('census_pop_2012_division'));
--71 mb
--select count(*) from trigrid_l1 
-- 605200

SELECT count(*) from census_pop_2012_division_01 c, trigrid_l1 g WHERE ST_Intersects(g.the_geom,c.the_geom) and c.nb <=18036)


--
ALTER table trigrid_l2 add column cls integer;
update trigrid_l2 SET cls=5 FROM census_pop_2012_division_gen01 WHERE ST_Intersects( trigrid_l2.the_geom,census_pop_2012_division_gen01.the_geom) and census_pop_2012_division_gen01.nb >105719;
-- 36498 
update trigrid_l2 SET cls=4 FROM census_pop_2012_division_gen01 WHERE ST_Intersects( trigrid_l2.the_geom,census_pop_2012_division_gen01.the_geom) and census_pop_2012_division_gen01.nb >50900 and census_pop_2012_division_gen01.nb <=105719 ;
-- 114643
update trigrid_l2 SET cls=3 FROM census_pop_2012_division_gen01 WHERE ST_Intersects( trigrid_l2.the_geom,census_pop_2012_division_gen01.the_geom) and census_pop_2012_division_gen01.nb > 31333 and census_pop_2012_division_gen01.nb <= 50900 ;
-- 216082
update trigrid_l2 SET cls=2 FROM census_pop_2012_division_gen01 WHERE ST_Intersects( trigrid_l2.the_geom,census_pop_2012_division_gen01.the_geom) and census_pop_2012_division_gen01.nb > 18036 and census_pop_2012_division_gen01.nb <=31333;
-- 81383
update trigrid_l2 SET cls=1 FROM census_pop_2012_division_gen01 WHERE ST_Intersects( trigrid_l2.the_geom,census_pop_2012_division_gen01.the_geom) and census_pop_2012_division_gen01.nb <=18036;
-- 490743
