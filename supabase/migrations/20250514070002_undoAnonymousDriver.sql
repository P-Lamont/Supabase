set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.setlog(lats real, longs real, late real, longe real, stime timestamp without time zone, etime timestamp without time zone)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 strict
 SET search_path TO ''
AS $function$DECLARE 
	uidd text;
	route int;
	max_int int;
BEGIN
	select p.driver,p.driver_route into uidd, route
	from public.pasada p
	where (( SELECT auth.uid() AS uid) = p.driver);
	select max(id) into max_int from public.driverlogs;
	if uidd is not null then
		insert into public.driverlogs("id","latStart","longStart","latEnd","longEnd","route","starttime","endtime","driver_id")
		values(max_int+1,latS,longS,latE,longE,route,Stime,Etime,uidd::uuid);
		
		update public.driver_updates
		set log_number=max_int+1
		-- set drv = null,log_number=max_int+1
		where ( SELECT auth.uid() AS uid) = drv;
	end if;
END;$function$
;


