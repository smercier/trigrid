CREATE OR REPLACE FUNCTION trigrid(pt_x double precision, pt_y double precision, gx double precision, gy double precision, c double precision, epsg numeric,tbl varchar(25))
  RETURNS character varying AS
$BODY$
--/******************************************************************************************
--D Description: Créer un grid de triangle.  Ce grid s'inspire de cette image 
--               (http://pinterest.com/pin/145170787958002611/).  Il est préférable de 
--               produire le grid en degrés.
--A Argus     : pt_x, pty = coord start grid
--              gx = largeur grid
--              gy = heuteur grid
--              c = longueur des côtés
--              epsg = code epsg des unités de mesures
--              tbl = nom de table de sortie
--           approx 200 m = 0.002 degr
--                  1 km = 0.013 degr
--
--E Exemple:  select trigrid (-150,36,100,44,0.13,4326,'trigrid_l1');
--
--O Output : A triangle geometry.
--Blog post :  http://simonmercier.net/blog/?p=1245
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

create table  IF NOT EXISTS  tmp (cmd char(1000));

 FOR ty IN 1..nbt_y+1 LOOP

   FOR tx IN 1..nbt_x+1 LOOP
   
        -- tri 1  ----------------
        tg_string:='POLYGON(('|| pt_x ||' '|| pt_y ||','|| pt_x-h ||' '|| pt_y+c/2 ||','|| pt_x-h ||' '|| pt_y-(c/2) ||','|| pt_x ||' '||pt_y||'))'; 
        gid := gid+1;
        tg_string:= 'insert into '||tbl||' VALUES ('||gid||','|| tx||','|| ty||',ST_GeomFromText( '''||tg_string||''','||epsg||'))'; 
        EXECUTE tg_string;

        -- tri 2  ----------------
        tg_string:='POLYGON(('|| pt_x ||' '|| pt_y ||','|| pt_x-h ||' '|| pt_y-c/2 ||','|| pt_x ||' '|| pt_y-c ||','|| pt_x ||' '||pt_y||'))'; 
        gid := gid+1;
        tg_string:= 'insert into '||tbl||' VALUES ('||gid||','|| tx||','|| ty||',ST_GeomFromText( '''||tg_string||''','||epsg||'))';
        EXECUTE tg_string;

        -- tri 3  ----------------
        tg_string:='POLYGON(('|| pt_x ||' '|| pt_y ||','|| pt_x ||' '|| pt_y-c ||','|| pt_x+h ||' '|| pt_y-(c/2) ||','|| pt_x ||' '||pt_y||'))'; 
        gid := gid+1;
        tg_string:= 'insert into '||tbl||' VALUES ('||gid||','|| tx||','|| ty||',ST_GeomFromText( '''||tg_string||''','||epsg||'))';
        EXECUTE tg_string;

        -- tri 4  ----------------
        tg_string:='POLYGON(('|| pt_x ||' '|| pt_y ||','|| pt_x+h ||' '|| pt_y-c/2 ||','|| pt_x+h ||' '|| pt_y+(c/2) ||','|| pt_x ||' '||pt_y||'))'; 
        gid := gid+1;
        tg_string:= 'insert into '||tbl||' VALUES ('||gid||','|| tx||','|| ty||',ST_GeomFromText( '''||tg_string||''','||epsg||'))';
        EXECUTE tg_string;

        -- tri 5  ----------------
        tg_string:='POLYGON(('|| pt_x ||' '|| pt_y ||','|| pt_x+h ||' '|| pt_y+c/2 ||','|| pt_x ||' '|| pt_y+c ||','|| pt_x ||' '||pt_y||'))'; 
        gid := gid+1;
        tg_string:= 'insert into '||tbl||' VALUES ('||gid||','|| tx||','|| ty||',ST_GeomFromText( '''||tg_string||''','||epsg||'))';
        EXECUTE tg_string;

        -- tri 6 ----------------
        tg_string:='POLYGON(('|| pt_x ||' '|| pt_y ||','|| pt_x ||' '|| pt_y+c ||','|| pt_x-h ||' '|| pt_y+(c/2) ||','|| pt_x ||' '||pt_y||'))'; 
        gid := gid+1;
        tg_string:= 'insert into '||tbl||' VALUES ('||gid||','|| tx||','|| ty||',ST_GeomFromText( '''||tg_string||''','||epsg||'))';
        EXECUTE tg_string;

        -- tri 7 ----------------
        tg_string:='POLYGON(('|| pt_x ||' '|| pt_y -c ||','|| pt_x -h ||' '|| pt_y-c+(c/2) ||','|| pt_x-h ||' '|| pt_y-c-(c/2) ||','|| pt_x ||' '||pt_y-c||'))'; 
        gid := gid+1;
        tg_string:= 'insert into '||tbl||' VALUES ('||gid||','|| tx||','|| ty||',ST_GeomFromText( '''||tg_string||''','||epsg||'))';
        EXECUTE tg_string;

        -- tri 8 ----------------
        tg_string:='POLYGON(('|| pt_x ||' '|| pt_y-c ||','|| pt_x +h ||' '|| pt_y -c+(c/2) ||','|| pt_x+h ||' '|| pt_y-c -(c/2) ||','|| pt_x ||' '||pt_y-c||'))';
        gid := gid+1; 
        tg_string:= 'insert into '||tbl||' VALUES ('||gid||','|| tx||','|| ty||',ST_GeomFromText( '''||tg_string||''','||epsg||'))';
        EXECUTE tg_string;
        ------------------------- 

        --ajuster la valeur de x en fonction de l'itération. en x deux fois la hauteur
        pt_x := pt_x + (2*h);       


   END LOOP;

   --ajuster la valeur de y en fonction de l'itération. en y deux fois un côté
   pt_y := pt_y + (2 * c);  
   -- et en x on revient au départ 
   pt_x := ori_x;


END LOOP;

 return cast (nbt_x as character varying);
END; 

 $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
