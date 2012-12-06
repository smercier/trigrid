--------------------------------
--Test SQL ----
--------------------------------
insert into mytabe (61,61,1,ST_GeomFromText( 'POLYGON((16476.5403855637 115,16476.5403855637 125,16485.2006396016 120,16476.5403855637 115))'))  
create table trigrid(gid as integer,tx as integer, ty as integer);
SELECT AddGeometryColumn ('','trigrid','the_geom',32198,'POLYGON',2);

drop table trigrid;
create table trigrid(gid integer,tx integer, ty integer);
SELECT AddGeometryColumn ('','trigrid','the_geom',32198,'POLYGON',2);
insert into trigrid VALUES (61,61,1,ST_GeomFromText( 'POLYGON((16476.5403855637 115,16476.5403855637 125,16485.2006396016 120,16476.5403855637 115))',32198)) ;

-- en degrés
drop table trigrid;
create table trigrid(gid integer,tx integer, ty integer);
SELECT AddGeometryColumn ('','trigrid','the_geom',4326,'POLYGON',2);

truncate trigrid;
truncate tmp;
select trigrid (-150,36,100,44,13,4326);
--select * from tmp;

--------------------------------
 --- Fonction
CREATE or replace FUNCTION trigrid(pt_x double precision, pt_y double precision, gx double precision, gy double precision, c double precision, epsg numeric,table_ char(100))
  RETURNS character varying AS
$BODY$
--/******************************************************************************************
--D Description: create a triangle geom base on input parameters.  Il est préférable de produire le grid en degre
--A Argus     : pt_x, pty = coord start grid
--              gx = largeur grid
--              gy = heuteur grid
--              c = longueur des côtés
--              epsg = epsg of x, y and distance
--              table_ = output table name
--           approx 200 m = 0.002 deg
--                  1 km = 0.013 deg
--O Output : A triangle geometry.
-- Spec :  voir http://pinterest.com/pin/145170787958002611/
-- Blog post : 
--******************************************************************************************/
DECLARE
tg_geom geometry;
h DOUBLE PRECISION;
nbt_x DOUBLE PRECISION;
nbt_y DOUBLE PRECISION;
ori_x DOUBLE PRECISION;
gid integer;
tg_string varchar(1000) ;
BEGIN

gid := 0;
h := c*sqrt(3)/2;
nbt_x := round(cast (gx/(2*h) as numeric),0);
nbt_y := round(cast (gy/(2*c) as numeric),0);
ori_x= pt_x;


-- on va systématiquement créer la table en fonction du EPSG
--tg_string :=  'BEGIN; drop table IF EXISTS ' ||table_;
--EXECUTE tg_string;
--tg_string :=  'create table ' ||table_||'(gid integer,tx integer, ty integer)';
--EXECUTE tg_string;
--tg_string :=  'SELECT AddGeometryColumn ('''',''' ||table_||''',''the_geom'',' ||epsg||',''POLYGON'',2)';
--EXECUTE tg_string;

--tg_string :=  'BEGIN; drop table IF EXISTS ' ||table_||';create table ' ||table_||'(gid integer,tx integer, ty integer);commit;SELECT AddGeometryColumn ('''',''' ||table_||''',''the_geom'',' ||epsg||',''POLYGON'',2);commit; END;';
--EXECUTE tg_string;

 FOR ty IN 1..nbt_y+1 LOOP

   FOR tx IN 1..nbt_x+1 LOOP
  
        -- tri 1  ----------------
        tg_string:='POLYGON(('|| pt_x ||' '|| pt_y ||','|| pt_x-h ||' '|| pt_y+c/2 ||','|| pt_x-h ||' '|| pt_y-(c/2) ||','|| pt_x ||' '||pt_y||'))'; 
       gid := gid+1;
        --ajouter tg à la table de données 
        tg_string:= 'insert into ' ||table_||' VALUES ('||gid||','|| tx||','|| ty||',ST_GeomFromText( '''||tg_string||''','||epsg||'))';
        EXECUTE tg_string;

        -- tri 2  ----------------
        tg_string:='POLYGON(('|| pt_x ||' '|| pt_y ||','|| pt_x-h ||' '|| pt_y-c/2 ||','|| pt_x ||' '|| pt_y-c ||','|| pt_x ||' '||pt_y||'))'; 
        gid := gid+1;
       --ajouter tg à la table de données 
        tg_string:= 'insert into ' ||table_||' VALUES ('||gid||','|| tx||','|| ty||',ST_GeomFromText( '''||tg_string||''','||epsg||'))';
       EXECUTE tg_string;

        -- tri 3  ----------------
        tg_string:='POLYGON(('|| pt_x ||' '|| pt_y ||','|| pt_x ||' '|| pt_y-c ||','|| pt_x+h ||' '|| pt_y-(c/2) ||','|| pt_x ||' '||pt_y||'))'; 
       gid := gid+1;
       --ajouter tg à la table de données 
        tg_string:= 'insert into ' ||table_||' VALUES ('||gid||','|| tx||','|| ty||',ST_GeomFromText( '''||tg_string||''','||epsg||'))';
       EXECUTE tg_string;

        -- tri 4  ----------------
        tg_string:='POLYGON(('|| pt_x ||' '|| pt_y ||','|| pt_x+h ||' '|| pt_y-c/2 ||','|| pt_x+h ||' '|| pt_y+(c/2) ||','|| pt_x ||' '||pt_y||'))'; 
       gid := gid+1;
       --ajouter tg à la table de données 
        tg_string:= 'insert into ' ||table_||' VALUES ('||gid||','|| tx||','|| ty||',ST_GeomFromText( '''||tg_string||''','||epsg||'))';
       EXECUTE tg_string;

        -- tri 5  ----------------
        tg_string:='POLYGON(('|| pt_x ||' '|| pt_y ||','|| pt_x+h ||' '|| pt_y+c/2 ||','|| pt_x ||' '|| pt_y+c ||','|| pt_x ||' '||pt_y||'))'; 
       gid := gid+1;
       --ajouter tg à la table de données 
        tg_string:= 'insert into ' ||table_||' VALUES ('||gid||','|| tx||','|| ty||',ST_GeomFromText( '''||tg_string||''','||epsg||'))';
       EXECUTE tg_string;

        -- tri 6 ----------------
        tg_string:='POLYGON(('|| pt_x ||' '|| pt_y ||','|| pt_x ||' '|| pt_y+c ||','|| pt_x-h ||' '|| pt_y+(c/2) ||','|| pt_x ||' '||pt_y||'))'; 
       gid := gid+1;
       --ajouter tg à la table de données 
        tg_string:= 'insert into ' ||table_||' VALUES ('||gid||','|| tx||','|| ty||',ST_GeomFromText( '''||tg_string||''','||epsg||'))';
       EXECUTE tg_string;

        -- tri 7 ----------------
        tg_string:='POLYGON(('|| pt_x ||' '|| pt_y -c ||','|| pt_x -h ||' '|| pt_y-c+(c/2) ||','|| pt_x-h ||' '|| pt_y-c-(c/2) ||','|| pt_x ||' '||pt_y-c||'))'; 
       gid := gid+1;
       --ajouter tg à la table de données 
        tg_string:= 'insert into ' ||table_||' VALUES ('||gid||','|| tx||','|| ty||',ST_GeomFromText( '''||tg_string||''','||epsg||'))';
       EXECUTE tg_string;

        -- tri 8 ----------------
        tg_string:='POLYGON(('|| pt_x ||' '|| pt_y-c ||','|| pt_x +h ||' '|| pt_y -c+(c/2) ||','|| pt_x+h ||' '|| pt_y-c -(c/2) ||','|| pt_x ||' '||pt_y-c||'))';
       gid := gid+1; 
       --ajouter tg à la table de données 
        tg_string:= 'insert into ' ||table_||' VALUES ('||gid||','|| tx||','|| ty||',ST_GeomFromText( '''||tg_string||''','||epsg||'))';
       EXECUTE tg_string;
      ------------------------- 

       --ajuster la valeur de x en fonction de l'itération. en x deux fois la hauteur
       pt_x := pt_x + (2*h);       


   END LOOP;

   --ajuster la valeur de y en fonction de l'itération. en y deux fois un côté
   pt_y := pt_y + (2 * c);  
  -- et en x on reviens au départ 
  pt_x := ori_x;


END LOOP;

 return cast (nbt_y*nbt_y as character varying)||' triangles';
END; $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;




