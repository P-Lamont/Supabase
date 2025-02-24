grant EXECUTE on function setlog(real, real, real, real, timestamp without time zone, timestamp without time zone) to authenticated;
set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.combine_segment_array(input_array text[], driver_index integer, passenger_index integer)
 RETURNS text[]
 LANGUAGE plpgsql
 STRICT
 SET search_path TO ''
AS $function$DECLARE

    segment_array TEXT[] := '{}';
    segment TEXT;
    i INT;
	-- start_segment text;
	-- end_segment text;
BEGIN
    -- Transform input_array to segment_array
    FOR i IN driver_index..passenger_index-1
		LOOP
			-- start_segment:=public.get_text_code(input_array[i]);
			-- end_segment:=public.get_text_code(input_array[i+1]);
	        segment :=  input_array[i]|| '-' || input_array[i+1];
					if segment is not null then
						segment_array := array_append(segment_array, segment);
					end if;
    	END LOOP;

	return segment_array;
END;$function$
;

CREATE OR REPLACE FUNCTION public.distance_driver_passenger(segment_array text[])
 RETURNS real
 LANGUAGE plpgsql
 STRICT
 SET search_path TO ''
AS $function$DECLARE
	partial_sum real;
BEGIN
    -- Transform input_array to segment_array

	with filtered_distance as(
		select distance,
			start_node||'-'||end_node as start_end
		from public.distancetable
	)
	select ceil(sum(distance)) into partial_sum
	from filtered_distance
	where start_end = any(segment_array);
	return partial_sum;	
END;$function$
;

CREATE OR REPLACE FUNCTION public.drv_min(lat real, long real, upd_tme timestamp without time zone, spd integer)
 RETURNS void
 LANGUAGE plpgsql
 strict
 SECURITY DEFINER
 SET search_path TO ''
AS $function$DECLARE 
	origin_count INT; 
	destination_count INT;
	average_distance double precision;
	segment_var text[];
BEGIN
if public.check_is_driver()=false then
	raise EXCEPTION 'Unauthorized';
end if;
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

CREATE OR REPLACE FUNCTION public.drv_set(ogn text, dest text, lat real, long real, tme timestamp without time zone, spd integer)
 RETURNS void
 LANGUAGE plpgsql
 STRICT SECURITY DEFINER
 SET search_path TO ''
AS $function$declare
origin_code text;
destination_code text;
is_route_reversed boolean;
route_id int;

begin
if public.check_is_driver()=false then
	raise EXCEPTION 'Unauthorized';
end if;
origin_code:=public.get_text_code(ogn);
destination_code:=public.get_text_code(dest);
assert origin_code is not null, 'Origin not found.';
assert destination_code is not null, 'Destination not found';
SELECT route_table.id into route_id
FROM public.route_table
WHERE (
	route_table.destination = any(array[origin_code,destination_code]) 
	and route_table.origin =any(array[origin_code,destination_code])
	and origin_code!=destination_code
);

if route_id is not null
	then
		SELECT EXISTS (
			SELECT route_table.id FROM public.route_table
				WHERE (route_table.origin = destination_code and route_table.id =route_id)
		) into is_route_reversed;
		
		insert into public.pasada (driver,is_reversed_route,driver_route)
		values (auth.uid()::uuid,is_route_reversed,route_id)
		on conflict(driver)
		do update set
			is_reversed_route = excluded.is_reversed_route,
			driver_route = route_id;
		perform public.drv_min(lat::real ,long::real,tme::timestamp,spd::int);
	else
		raise EXCEPTION 'Route not found';
	end if;
end$function$
;

CREATE OR REPLACE FUNCTION public.get_text_code(node_var text)
 RETURNS text
 LANGUAGE plpgsql
 STRICT
 SET search_path TO ''
AS $function$DECLARE 
	code_text text; 
BEGIN 
	select code into code_text
	FROM public.nodescode 
	WHERE nodes = node_var
	Limit 1;
	RETURN code_text;
END;$function$
;

CREATE OR REPLACE FUNCTION public.inbetween_segmental_distance(input_array text[], driver_index integer, passenger_index integer)
 RETURNS real
 LANGUAGE plpgsql
 STRICT
 SET search_path TO ''
AS $function$DECLARE
    segment_array TEXT[] := '{}';
    partial_sum real;
BEGIN
    -- Transform input_array to segment_array
	segment_array :=public.combine_segment_array(
		input_array,least(driver_index,passenger_index),greatest(driver_index,passenger_index)
		);
	partial_sum:=public.distance_driver_passenger(segment_array);
	return partial_sum;
END;$function$
;

CREATE OR REPLACE FUNCTION public.setlog(lats real, longs real, late real, longe real, stime timestamp without time zone, etime timestamp without time zone)
 RETURNS void
 LANGUAGE plpgsql
 STRICT SECURITY DEFINER
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
		set drv = null,log_number=max_int+1
		where ( SELECT auth.uid() AS uid) = drv;
	end if;
END;$function$
;

CREATE OR REPLACE FUNCTION public.upd_ctr(uid uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 STRICT SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  is_paid boolean;
  is_set boolean:= false;
begin
  select has_paid into is_paid
  from public.profile
  where id=auth.uid();
  if is_paid=true then
  	update public.pasada
  	set counter = counter+1
  	where id = uid;
	is_set =true;
	end if;
  return is_set;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.update_search_counter(uuids uuid[])
 RETURNS void
 LANGUAGE plpgsql
 STRICT SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  is_paid boolean;
begin
  select has_paid into is_paid
  from public.profile
  where id=auth.id();
  if is_paid=true then
	  update public.pasada
	  set counter = counter+1
	  where id = any(uuids);
	end if;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.update_sub(mail text, is_paid boolean, days integer)
 RETURNS boolean
 LANGUAGE plpgsql
 STRICT SECURITY DEFINER
 SET search_path TO ''
AS $function$declare
  user_uuid uuid;
begin
  if not public.check_is_admin() then
    raise exception 'Unauthorized';
  end if;
  
  SELECT id INTO user_uuid
  FROM auth.users
  WHERE email = mail;
  if user_uuid is null then
    return false;
  end if;
  update public.profile
  set subscription = current_date+days,
    has_paid =is_paid,
    daily_credits =10
  where id =user_uuid;
  return true;
end;$function$
;


