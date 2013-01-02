
-- créer une table tirgrid level 1
drop table trigrid_l1;
create table trigrid_l1(gid integer,tx integer, ty integer);
SELECT AddGeometryColumn ('','trigrid_l1','the_geom',4326,'POLYGON',2);
select trigrid (-150,36,100,44,0.13,4326,'trigrid_l1');
select count(*) from trigrid_l1;
-- 605200

-- créer une table tirgrid level 2
drop table trigrid_l2;
create table trigrid_l2(gid integer,tx integer, ty integer);
SELECT AddGeometryColumn ('','trigrid_l2','the_geom',4326,'POLYGON',2);
select trigrid (-150,36,100,44,0.065,4326,'trigrid_l2');
select count(*) from trigrid_l2;
-- 2410968


-- J'ai créer un table basée sur Census 2011 et je veux créer des classe Quantils rapidement.
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


ssh smercier@qc.mapgears.com

-- j'ai traité un table de census pour le besoin de ce test.  Voir le fichier dans répertoire projet cencus

ALTER table trigrid_l1 add column cls integer;
update trigrid_l1 SET cls=5 where gid in(SELECT g.gid from census_pop_2012_division c, trigrid_l1 g WHERE ST_Intersects(c.the_geom,g.the_geom) and c.nb >105719);
--
update trigrid_l1 SET cls=4 where gid in(SELECT g.gid from census_pop_2012_division c, trigrid_l1 g WHERE ST_Intersects(c.the_geom,g.the_geom) and (c.nb> 50900 or c.nb <=105719));
--
update trigrid_l1 SET cls=3 where gid in(SELECT g.gid from census_pop_2012_division c, trigrid_l1 g WHERE ST_Intersects(c.the_geom,g.the_geom) and (c.nb> 31333 or c.nb <=50900));
--
update trigrid_l1 SET cls=2 where gid in(SELECT g.gid from census_pop_2012_division c, trigrid_l1 g WHERE ST_Intersects(c.the_geom,g.the_geom) and (c.nb> 18036 or c.nb <=31333));
--
update trigrid_l1 SET cls=1 where gid in(SELECT g.gid from census_pop_2012_division c, trigrid_l1 g WHERE ST_Intersects(c.the_geom,g.the_geom) and c.nb <=18036);
--
ALTER table trigrid_l2 add column cls integer;
update trigrid_l2 SET cls=5 where gid in(SELECT g.gid from census_pop_2012_division c, trigrid_l2 g WHERE ST_Intersects(c.the_geom,g.the_geom) and c.nb >105719);
--
update trigrid_l2 SET cls=4 where gid in(SELECT g.gid from census_pop_2012_division c, trigrid_l2 g WHERE ST_Intersects(c.the_geom,g.the_geom) and (c.nb> 50900 or c.nb <=105719));
--
update trigrid_l2 SET cls=3 where gid in(SELECT g.gid from census_pop_2012_division c, trigrid_l2 g WHERE ST_Intersects(c.the_geom,g.the_geom) and (c.nb> 31333 or c.nb <=50900));
--
update trigrid_l2 SET cls=2 where gid in(SELECT g.gid from census_pop_2012_division c, trigrid_l2 g WHERE ST_Intersects(c.the_geom,g.the_geom) and (c.nb> 18036 or c.nb <=31333));
--
update trigrid_l2 SET cls=1 where gid in(SELECT g.gid from census_pop_2012_division c, trigrid_l2 g WHERE ST_Intersects(c.the_geom,g.the_geom) and c.nb <=18036);
-

