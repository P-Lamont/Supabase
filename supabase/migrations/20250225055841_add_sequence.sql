create sequence "public"."user_search_sequence";

alter table "public"."user_search" alter column "id" drop identity;
alter table "public"."user_search" alter column "id" set default nextval('user_search_sequence'::regclass);
alter sequence "public"."user_search_sequence" owned by "public"."user_search"."id";

set check_function_bodies = off;
drop function if exists "public"."q_drivers2"(lat real, long real, dest text);
drop function if exists "public"."q_drivers"(lat real, long real, dest text);
drop function if exists "public"."update_search_counter"(uuids uuid[]);

CREATE OR REPLACE FUNCTION public.check_is_admin()
	RETURNS boolean
	LANGUAGE plpgsql
	STABLE STRICT
	SET search_path TO ''
	AS $function$
	declare
	conditions_met boolean:=false;
	begin
	if auth.role() is null then
			conditions_met := true;
	end if;
	if conditions_met = false then
		select exists(
		select p.id,r.roles,p.username
		from public.profile p
		inner join public.roles r on p.role=r.id 
		where (r.roles='admin'and (( SELECT auth.uid() AS uid) = p.id))
		) into conditions_met;
	end if;
	return conditions_met;
	end;
	$function$
;

CREATE OR REPLACE FUNCTION public.check_is_driver()
	RETURNS boolean
		LANGUAGE plpgsql
		STABLE
		SET search_path TO ''
		AS $function$
	declare
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

CREATE OR REPLACE FUNCTION public.distance_from_origin(lat real, long real)
	RETURNS TABLE(origin text, destination text, total_distance real, new_segment_text text[])
	LANGUAGE plpgsql
	STABLE STRICT ROWS 2
	SET search_path TO ''
AS $function$
BEGIN
  return query
	WITH CloseCheckpoints AS (
        select latitude,
		longitude,
		distance,
		public.kmsegments.origin,
		public.kmsegments.destination,
	    6371 * acos(
	        cos(radians(lat)) * cos(radians(latitude)) * 
	        cos(radians(longitude) - radians(long)) +
	        sin(radians(lat)) * sin(radians(latitude))
	    )*1000 as additional_distance,
		row_number() over (order by table_id) as rowNum
		from public.kmsegments
        WHERE latitude between lat-0.000449 and lat+0.000449
        and longitude between long-0.000477 and long+0.000477
		limit 2
    )
	
  Select CloseCheckpoints.origin,CloseCheckpoints.destination,
	case
		when rowNum = 1 then floor(distance+additional_distance)::real
	 	when rowNum = 2 then floor(distance-additional_distance)::real
		else distance::real
	end as total_distance,
	array[CloseCheckpoints.origin]||array[CloseCheckpoints.destination] as new_segment_text 
    From CloseCheckpoints;
END
$function$
;

CREATE OR REPLACE FUNCTION public.drv_min(lat real, long real, upd_tme timestamp without time zone, spd integer)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 STRICT
 SET search_path TO ''
AS $function$DECLARE 
	origin_count INT; 
	destination_count INT;
	average_distance double precision;
	segment_var text[];
BEGIN
if public.check_is_driver()=false then
	raise EXCEPTION 'code:1';
assert lat>=1,'code:1';
assert lat<=22,'code:1';
assert long>=116,'code:1';
assert long<=128,'code:1';
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
 SECURITY DEFINER
 SET search_path TO ''
 STRICT
AS $function$declare
origin_code text;
destination_code text;
is_route_reversed boolean;
route_id int;

begin
if public.check_is_driver()=false then
	raise EXCEPTION 'code:1';
end if;
assert lat>=1,'code:1';
assert lat<=22,'code:1';
assert long>=116,'code:1';
assert long<=128,'code:1';
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

CREATE OR REPLACE FUNCTION public.insert_to_driver_table()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
declare
role_text text;
BEGIN
  select roles into role_text 
  from public.roles 
  where id=NEW.role;

  if role_text = 'driver' then
    INSERT INTO public.pasada (driver)
    VALUES (NEW.id)
    ON CONFLICT (driver) DO nothing;
  end if;
  return NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.q_drivers(lat real, long real, dest text)
 RETURNS TABLE(drv text, vhc text, spd smallint, dst integer, eta integer)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
 STRICT
 rows 5
AS $function$
DECLARE 
	query_time timestamp:=now()::timestamp;
	origin_count INT;
	destination_count INT;
	average_user_distance real;
	user_segment_array TEXT[];
	user_total_segment_distance real;
	credit int;
	query_identifier uuid;
BEGIN
	if COALESCE(public.check_is_admin(), FALSE) 
			OR COALESCE(public.check_is_driver(), FALSE) 
			OR COALESCE(public.update_daily_credit(), FALSE) THEN 
				NULL;
		ELSE 
				RAISE EXCEPTION 'code:2';
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
		MODE() WITHIN GROUP (ORDER BY new_segment_text) AS user_segment_array
	INTO
		average_user_distance,
		origin_count,
		destination_count,
		user_segment_array
	FROM distance_from_origin_table;

	select distance 
	from public.distancetable 
	where (start_node = any(user_segment_array) and end_node = any(user_segment_array)) into user_total_segment_distance;

	select code 
	from public.nodescode 
	where nodes=dest into dest;

	select daily_credits,identifier 
	into credit,query_identifier
	from public.profile
	where((SELECT auth.uid() AS uid)=profile.id);

	insert into public.user_search("datetime","lat","long","credit","destination","identifier")
	values(
		query_time,lat,long,credit+1,dest,query_identifier
	);
	return query	
	with initial_table as(
		SELECT p.driver,p.speed,is_reversed_route,p.segment as current_segment,
			public.distancetable.distance as total_segment_distance,-- driver
			query_time-p.time as time_active,p.v_type,
			floor
				(
				(1000*(p.speed) * (EXTRACT(EPOCH FROM (query_time-p.time)) / 3600))+
				p.segment_distance
			) as extrapolated_distance,--driver distance traveled with time queried and driver-time_updated
			array[r.origin]||r.route|| array[r.destination] as complete_driver_routes--routes of driver from origin to destination
			-- string_to_array(segment,',') as current_segment--current segment of driver
		FROM public.pasada p
		inner join  public.route_table r on p.driver_route= r.id
		inner join public.distancetable on p.segment = array[public.distancetable.start_node]||array[public.distancetable.end_node]
	),
	segments_table as(
		select *,
			array_position(complete_driver_routes,current_segment[1]) as pos_current_segment_one,--leg segment of driver starting
			array_position(complete_driver_routes,current_segment[2]) as pos_current_segment_two,--leg segment of driver ending
			array_position(complete_driver_routes,user_segment_array[1]) as pos_user_segment_one,--leg segment of user starting
			array_position(complete_driver_routes,user_segment_array[2]) as pos_user_segment_two,--leg segment of user ending
			array_position(complete_driver_routes,dest) as pos_user_destination--position of user destination
		from initial_table
		where (
			dest =any(complete_driver_routes)
			and time_active<interval '30 minutes'
			and time_active>interval '-30 minutes'
			and user_segment_array<@complete_driver_routes --user segment in complete driver route
		)
	),
	filtered_table as(
		select*
		from
			segments_table
		where (complete_driver_routes[1]=any(user_segment_array) and complete_driver_routes[array_length(complete_driver_routes, 1)]=any(user_segment_array) --same segment for both user and driver 
			and case
				when is_reversed_route=true 
					and dest= complete_driver_routes[1] and average_user_distance<segments_table.extrapolated_distance
				then 1
				when is_reversed_route=false 
				and dest = complete_driver_routes[array_length(complete_driver_routes, 1)] and average_user_distance>segments_table.extrapolated_distance
				then 1
				else 0
			end= 1
			) or
			(
				-- (
				-- dest = any(complete_driver_routes) --user destination in complete driver route
				-- and current_segment is not null
			case
				when is_reversed_route=false  --driver to lagawe, user to lagawe
					and dest= any(complete_driver_routes[greatest(pos_user_segment_two,pos_current_segment_two):])
					and case
						when pos_user_destination=pos_current_segment_two 
							and average_user_distance<segments_table.extrapolated_distance
						then 0
						else 1
					end =1
				then 1
				when is_reversed_route=true --driver to banaue user to banaue
					and dest= any(complete_driver_routes[:least(pos_user_segment_one,pos_current_segment_one)])
					and pos_current_segment_one-pos_user_segment_two>1
					and case
						when pos_user_destination=pos_current_segment_one 
							and average_user_distance>segments_table.extrapolated_distance
						then 0
						else 1
					end=1
				then 1
				else 0
			end =1
		)
	),
	-- calculate the distance and eta, segment considered
	user_driver_distance_table as(
		select driver,filtered_table.speed,filtered_table.extrapolated_distance, average_user_distance,filtered_table.v_type,
			case
				when pos_user_segment_one=pos_current_segment_one 
				then floor(abs(average_user_distance-filtered_table.extrapolated_distance)) --same segment
				when pos_user_segment_one-pos_current_segment_one=1
					and is_reversed_route= false
				then floor (average_user_distance+(total_segment_distance-filtered_table.extrapolated_distance)) --adjacent segment
				when pos_user_segment_one-pos_current_segment_one>1 
					and is_reversed_route= false
				then floor (average_user_distance+(total_segment_distance-filtered_table.extrapolated_distance))+ --inbetween segment
					public.inbetween_segmental_distance(
						complete_driver_routes,pos_user_segment_one,
						pos_current_segment_one)
				when pos_current_segment_one-pos_user_segment_one=1 
					and is_reversed_route= true
				then floor ((user_total_segment_distance-average_user_distance)+filtered_table.extrapolated_distance) --adjacent segment
				when pos_current_segment_one-pos_user_segment_one>1 
					and is_reversed_route= true
				then floor ((user_total_segment_distance-average_user_distance)+filtered_table.extrapolated_distance)+ --inbetween segment
					public.inbetween_segmental_distance(
						complete_driver_routes,pos_user_segment_one,
						pos_current_segment_one)
				-- else 0
			end as user_driver_distance
		from filtered_table
	),
	eta_calculations as(
		select *,
			floor(((user_driver_distance_table.user_driver_distance/1000)/user_driver_distance_table.speed)*60)::integer as eta
		from user_driver_distance_table
		ORDER BY eta
	),
  user_tables as(
    select COALESCE(p.username, 'Mr.Driver') as drv, 
    	v.type as vhc, 
		e.speed as spd, 
		e.user_driver_distance as dst, 
		e.eta,
		p.id as drv_id
    from eta_calculations e
    inner join public.profile p on e.driver=p.id
		inner join public.v_types v on e.v_type = v.id
  ),
	res_table as (
	SELECT user_tables.drv,user_tables.vhc,user_tables.spd,user_tables.dst::integer,user_tables.eta, public.upd_ctr(drv_id)
	FROM user_tables
  )
  select res_table.drv,res_table.vhc,res_table.spd,res_table.dst,res_table.eta
  from res_table
  order by eta asc,dst asc,drv asc;
END;$function$
;

CREATE OR REPLACE FUNCTION public.upd_ctr(uid uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
 strict
AS $function$declare
  is_paid boolean;
  is_set boolean:= false;
  counter_number integer;
begin
  select has_paid into is_paid
  from public.profile
  where id=auth.uid();
  if is_paid=true then
    select counter into counter_number
    from public.pasada
    where driver = uid;
	end if;
  if (is_paid=true) and (counter_number is null) then
    update public.pasada
  	set counter = 1
  	where driver = uid;
	  is_set =true;
  else if is_paid= true then
    update public.pasada
  	set counter = counter+1
  	where driver = uid;
	  is_set =true;
    end if;
  end if;
  return is_set;
end;$function$
;
revoke execute on function public.q_drivers from anon,authenticated,public;
grant execute on function public.q_drivers to postgres,authenticated;

