alter table "public"."driver_updates" add column "spd" smallint;

alter table "public"."driver_updates" add constraint "driver_updates_spd_check" CHECK ((spd > 0)) not valid;

alter table "public"."driver_updates" validate constraint "driver_updates_spd_check";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.drv_min(lat real, long real, upd_tme timestamp without time zone, spd integer)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 Strict
 SET search_path TO ''
AS $function$DECLARE 
	origin_count INT; 
	destination_count INT;
	average_distance double precision;
	segment_var text[];
BEGIN
	if public.check_is_driver()=false then
		raise EXCEPTION 'code:1';
	end if;
	assert lat>=1,'code:1';
	assert lat<=22,'code:1';
	assert long>=116,'code:1';
	assert long<=128,'code:1';
	WITH distance_from_origin_table as(
		SELECT *
		FROM public.distance_from_origin(lat,long)
	)

	select
	 	FLOOR( AVG(total_distance)) as avg_distance,
		COUNT(DISTINCT origin) as origin_count,
		COUNT(DISTINCT destination) as destination_count,
		MODE() WITHIN GROUP (ORDER BY new_segment_text) AS segment_var
	into
		average_distance, 
		origin_count, 
		destination_count,
		segment_var
	FROM distance_from_origin_table;
	
	IF origin_count = 1 AND destination_count = 1 THEN 
		UPDATE public.pasada 
		SET segment = segment_var
		WHERE driver =( SELECT auth.uid() AS uid);
	end if;
	UPDATE public.pasada 
	SET segment_distance =  average_distance,time=upd_tme,
	latitude= lat,longitude=long,speed=spd
	WHERE driver = ( SELECT auth.uid() AS uid);


	Insert into public.driver_updates ("datetime","lat","long","drv","spd")
	values(upd_tme,lat,long,auth.uid(),spd);
END;$function$
;


