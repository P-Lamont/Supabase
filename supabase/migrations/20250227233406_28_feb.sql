set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.check_is_driver()
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE
 SET search_path TO ''
AS $function$declare
conditions_met boolean:=false;
begin
select exists(
  select p.id,r.roles,p.username
  from public.profile p
  inner join public.roles r on p.role=r.id 
  where (r.roles='driver'and (( SELECT auth.uid() AS uid) = p.id))
) into conditions_met;
return conditions_met;
end;$function$
;

CREATE OR REPLACE FUNCTION public.drv_min(lat real, long real, upd_tme timestamp without time zone, spd integer)
	RETURNS void
	LANGUAGE plpgsql
	SECURITY DEFINER
	SET search_path TO ''
	strict
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


	Insert into public.driver_updates ("datetime","lat","long","drv")
	values(upd_tme,lat,long,auth.uid());
END;$function$
;

CREATE OR REPLACE FUNCTION public.update_daily_credit()
	RETURNS boolean
	LANGUAGE plpgsql
	SET search_path TO ''
AS $function$
declare
	is_credible boolean;
	counts integer;
	daily_id uuid;
begin
	with updated as(
		UPDATE public.profile
		SET 
			last_query = CASE 
				WHEN  subscription>=current_date THEN current_date
				-- WHEN last_query = current_date AND daily_credits > 0 THEN last_query
				-- ELSE last_query
			END,
			daily_credits = CASE 
				WHEN  (subscription>=current_date and (current_date>last_query or last_query is null)) THEN 9 
				WHEN (last_query = current_date AND daily_credits > 0) THEN daily_credits - 1 
				ELSE daily_credits
			end
		where (
		((daily_credits>0 and last_query=current_date) or 
		(last_query<current_date and subscription>=current_date)
		or (subscription>current_date and last_query is null)
		) and
		(( SELECT auth.uid() AS uid) = id))

		returning *
	)

	SELECT daily_credits INTO counts FROM updated;
	if counts>0 then
		is_credible:=true;
	else
		is_credible:=false;
	end if;
	if counts=9 then
		update public.profile
		set identifier =gen_random_uuid()
		where ( SELECT auth.uid() AS uid) = profile.id;
	end if;
	return is_credible;
end;
$function$;
