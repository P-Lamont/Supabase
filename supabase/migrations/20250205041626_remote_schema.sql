

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE EXTENSION IF NOT EXISTS "pgsodium" WITH SCHEMA "pgsodium";






COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE SCHEMA IF NOT EXISTS "use";


ALTER SCHEMA "use" OWNER TO "postgres";


CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgtap" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE OR REPLACE FUNCTION "public"."check_is_admin"() RETURNS boolean
    LANGUAGE "plpgsql" STABLE STRICT
    SET "search_path" TO ''
    AS $$
declare
conditions_met boolean:=false;
begin
if current_user ='postgres' then
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
$$;


ALTER FUNCTION "public"."check_is_admin"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."check_is_driver"() RETURNS boolean
    LANGUAGE "plpgsql" STABLE
    SET "search_path" TO ''
    AS $$declare
conditions_met boolean:=false;
begin
select exists(
  select p.id,r.roles,p.username
  from public.profile p
  inner join public.roles r on p.role=r.id 
  where (r.roles='driver'and (( SELECT auth.uid() AS uid) = p.id))
) into conditions_met;
return conditions_met;
end;$$;


ALTER FUNCTION "public"."check_is_driver"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."combine_segment_array"("input_array" "text"[], "driver_index" integer, "passenger_index" integer) RETURNS "text"[]
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$DECLARE

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
	        segment_array := array_append(segment_array, segment);
    	END LOOP;

	return segment_array;
END;$$;


ALTER FUNCTION "public"."combine_segment_array"("input_array" "text"[], "driver_index" integer, "passenger_index" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."distance_driver_passenger"("segment_array" "text"[]) RETURNS real
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$
DECLARE
	partial_sum real;
BEGIN
    -- Transform input_array to segment_array

	with filtered_distance as(
		select distance,
			start_node||'-'||end_node as start_end
		from distancetable
	)
	select ceil(sum(distance)) into partial_sum
	from filtered_distance
	where start_end = any(segment_array);
	return partial_sum;	
END;
$$;


ALTER FUNCTION "public"."distance_driver_passenger"("segment_array" "text"[]) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."distance_from_origin"("lat" real, "long" real) RETURNS TABLE("origin" "text", "destination" "text", "total_distance" real, "new_segment_text" "text"[])
    LANGUAGE "plpgsql" STABLE STRICT ROWS 2
    SET "search_path" TO ''
    AS $$
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
$$;


ALTER FUNCTION "public"."distance_from_origin"("lat" real, "long" real) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."drv_min"("lat" real, "long" real, "upd_tme" timestamp without time zone, "spd" integer) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
DECLARE 
	origin_count INT; 
	destination_count INT;
	average_distance double precision;
	segment_var text[];
BEGIN
if public.check_is_driver()=false then
	return;
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
END;
$$;


ALTER FUNCTION "public"."drv_min"("lat" real, "long" real, "upd_tme" timestamp without time zone, "spd" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."drv_set"("ogn" "text", "dest" "text", "lat" real, "long" real, "tme" timestamp without time zone, "spd" integer) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
declare
origin_code text;
destination_code text;
is_route_reversed boolean;
route_id int;

begin
if public.check_is_driver()=false then
	return;
end if;
origin_code:=public.get_text_code(ogn);
destination_code:=public.get_text_code(dest);

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
		raise notice 'null';
	end if;
end
$$;


ALTER FUNCTION "public"."drv_set"("ogn" "text", "dest" "text", "lat" real, "long" real, "tme" timestamp without time zone, "spd" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_text_code"("node_var" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$DECLARE 
	code_text text; 
BEGIN 
	select code into code_text
	FROM public.nodescode 
	WHERE nodes = node_var
	Limit 1;
	RETURN code_text;
END;$$;


ALTER FUNCTION "public"."get_text_code"("node_var" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
Begin
Insert into public.profile(id,firstname,lastname,province,municipality,barangay,bday,username)
Values (
  new.id, new.raw_user_meta_data ->> 'first_name', new.raw_user_meta_data ->> 'last_name',
  new.raw_user_meta_data ->> 'province', new.raw_user_meta_data ->> 'municipality',
  new.raw_user_meta_data ->> 'barangay', new.raw_user_meta_data ->> 'bday',
  new.raw_user_meta_data ->> 'username'
);
return new;
End;
$$;


ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."inbetween_segmental_distance"("input_array" "text"[], "driver_index" integer, "passenger_index" integer) RETURNS real
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$DECLARE
    segment_array TEXT[] := '{}';
    partial_sum real;
BEGIN
    -- Transform input_array to segment_array
	segment_array :=public.combine_segment_array(
		input_array,least(driver_index,passenger_index),greatest(driver_index,passenger_index)
		);
	raise notice 'distances to add:%',segment_array;
	partial_sum:=public.distance_driver_passenger(segment_array);
	raise notice '%',partial_sum;
	return partial_sum;
END;$$;


ALTER FUNCTION "public"."inbetween_segmental_distance"("input_array" "text"[], "driver_index" integer, "passenger_index" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."insert_to_driver_table"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$
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
$$;


ALTER FUNCTION "public"."insert_to_driver_table"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."q_drivers"("lat" real, "long" real, "dest" "text") RETURNS TABLE("driver_id" "text", "type" "text", "speed" smallint, "user_driver_distance" double precision, "eta" integer)
    LANGUAGE "plpgsql" STRICT SECURITY DEFINER ROWS 10
    SET "search_path" TO ''
    AS $$
DECLARE 
	query_time timestamp:=now()::timestamp;
	origin_count INT;
	destination_count INT;
	average_user_distance real;
	user_segment_array TEXT[];
	data_record record;
	user_total_segment_distance real;

BEGIN
	if (public.check_is_admin() or public.check_is_driver() or public.update_daily_credit())=false then
		return;
	end if;
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

	return query	
	with initial_table as(
		SELECT p.driver,p.speed,is_reversed_route,p.segment as current_segment,
			public.distancetable.distance as total_segment_distance,-- driver
			query_time-p.time as time_active,
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
		select driver,filtered_table.speed,filtered_table.extrapolated_distance, average_user_distance,
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
    select COALESCE(p.username, 'Mr.Driver') AS driver_name, 
    v.type, 
		e.speed, 
		e.user_driver_distance, 
		e.eta
    from eta_calculations e
    inner join public.profile p on e.driver=p.id
		inner join public.v_types v on p.v_type = v.id
  )
	SELECT *
	FROM user_tables;
END;
$$;


ALTER FUNCTION "public"."q_drivers"("lat" real, "long" real, "dest" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."q_drivers2"("lat" real, "long" real, "dest" "text") RETURNS TABLE("driver_name" "text", "v_type" "text", "speed" smallint, "user_driver_distance" integer, "eta" integer)
    LANGUAGE "plpgsql" SECURITY DEFINER ROWS 5
    SET "search_path" TO ''
    AS $$
DECLARE 
	query_time timestamp:=now()::timestamp;
	origin_count INT;
	destination_count INT;
	average_user_distance real;
	user_segment_array TEXT[];
	data_record record;
	user_total_segment_distance real;
	driver_name text;
BEGIN
	if (public.check_is_admin() or public.check_is_driver() or public.update_daily_credit())=false then
		raise exception 'Limit Reached';
	end if;
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

	return query	
	with initial_table as(
		SELECT p.driver,p.speed,is_reversed_route,p.segment as current_segment,
			public.distancetable.distance as total_segment_distance,-- driver
			query_time-p.time as time_active,
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
		select driver,filtered_table.speed,filtered_table.extrapolated_distance, average_user_distance,
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
		inner join public.v_types v on p.v_type = v.id
  ),
	res_table as (
	SELECT drv,vhc,spd,dst::integer,user_tables.eta, public.upd_ctr(drv_id)
	FROM user_tables
  )
  select res_table.drv,res_table.vhc,res_table.spd,res_table.dst,res_table.eta
  from res_table;
END;
$$;


ALTER FUNCTION "public"."q_drivers2"("lat" real, "long" real, "dest" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."setlog"("lats" real, "longs" real, "late" real, "longe" real, "stime" timestamp without time zone, "etime" timestamp without time zone) RETURNS "void"
    LANGUAGE "plpgsql" STRICT SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
DECLARE 
	uidd text;
	route int;
BEGIN
	select p.driver,p.driver_route into uidd, route
	from public.pasada p
	where (( SELECT auth.uid() AS uid) = p.driver);
	insert into public.driverlogs("driver_id","latStart","longStart","latEnd","longEnd","route","starttime","endtime")
	values(auth.uid(),latS,longS,latE,longE,route,Stime,Etime);
END;
$$;


ALTER FUNCTION "public"."setlog"("lats" real, "longs" real, "late" real, "longe" real, "stime" timestamp without time zone, "etime" timestamp without time zone) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."upd_ctr"("uid" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
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
$$;


ALTER FUNCTION "public"."upd_ctr"("uid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_daily_credit"() RETURNS boolean
    LANGUAGE "plpgsql" STRICT
    SET "search_path" TO ''
    AS $$
declare
is_credible boolean;
counts integer;

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
SELECT COUNT(*) INTO counts FROM updated;
if counts>0 then
  is_credible:=true;
else
  is_credible:=false;
end if;
return is_credible;
end;
$$;


ALTER FUNCTION "public"."update_daily_credit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_search_counter"("uuids" "uuid"[]) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
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
$$;


ALTER FUNCTION "public"."update_search_counter"("uuids" "uuid"[]) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_sub"("mail" "text", "is_paid" boolean, "days" integer) RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$declare
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
end;$$;


ALTER FUNCTION "public"."update_sub"("mail" "text", "is_paid" boolean, "days" integer) OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."organization" (
    "id" integer NOT NULL,
    "orgName" "text" NOT NULL
);


ALTER TABLE "public"."organization" OWNER TO "postgres";


COMMENT ON TABLE "public"."organization" IS 'org of drivers';



ALTER TABLE "public"."organization" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."Organization_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."distancetable" (
    "id" bigint NOT NULL,
    "start_node" "text",
    "end_node" "text",
    "distance" double precision
);


ALTER TABLE "public"."distancetable" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."driverlogs" (
    "id" bigint NOT NULL,
    "latEnd" double precision,
    "longEnd" double precision,
    "route" smallint,
    "starttime" timestamp without time zone,
    "endtime" timestamp without time zone,
    "driver_id" "uuid" DEFAULT "auth"."uid"(),
    "latStart" double precision,
    "longStart" double precision NOT NULL
);


ALTER TABLE "public"."driverlogs" OWNER TO "postgres";


ALTER TABLE "public"."driverlogs" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."driverlogs_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."kmsegments" (
    "table_id" bigint NOT NULL,
    "distance" double precision,
    "latitude" double precision,
    "longitude" double precision,
    "origin" "text",
    "destination" "text"
);


ALTER TABLE "public"."kmsegments" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."nodescode" (
    "nodes" "text",
    "code" "text" NOT NULL
);


ALTER TABLE "public"."nodescode" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."pasada" (
    "driver" "uuid" NOT NULL,
    "speed" smallint,
    "time" timestamp with time zone,
    "segment_distance" numeric,
    "is_reversed_route" boolean,
    "driver_route" smallint,
    "segment" "text"[],
    "latitude" double precision,
    "longitude" double precision,
    "organization" integer,
    "counter" bigint
);


ALTER TABLE "public"."pasada" OWNER TO "postgres";


COMMENT ON COLUMN "public"."pasada"."counter" IS 'number of times searched';



CREATE TABLE IF NOT EXISTS "public"."profile" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "firstname" "text",
    "lastname" "text",
    "province" "text",
    "municipality" "text",
    "barangay" "text",
    "bday" "date",
    "username" "text",
    "role" bigint,
    "subscription" "date",
    "v_type" smallint DEFAULT '5'::smallint,
    "daily_credits" smallint,
    "last_query" "date",
    "phone" "text",
    "has_paid" boolean DEFAULT false NOT NULL,
    CONSTRAINT "profile_phone_check" CHECK (("length"("phone") = 11)),
    CONSTRAINT "profile_username_check" CHECK (("length"("username") <= 50))
);


ALTER TABLE "public"."profile" OWNER TO "postgres";


COMMENT ON COLUMN "public"."profile"."v_type" IS 'vehicle_type';



CREATE TABLE IF NOT EXISTS "public"."roles" (
    "id" bigint NOT NULL,
    "roles" "text" NOT NULL
);


ALTER TABLE "public"."roles" OWNER TO "postgres";


ALTER TABLE "public"."roles" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."roles_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."route_table" (
    "id" bigint NOT NULL,
    "origin" "text",
    "destination" "text",
    "route" "text"[]
);


ALTER TABLE "public"."route_table" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."v_types" (
    "id" smallint NOT NULL,
    "type" "text" NOT NULL
);


ALTER TABLE "public"."v_types" OWNER TO "postgres";


ALTER TABLE "public"."v_types" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."v_types_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



ALTER TABLE ONLY "public"."organization"
    ADD CONSTRAINT "Organization_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."distancetable"
    ADD CONSTRAINT "distancetable_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."driverlogs"
    ADD CONSTRAINT "driverlogs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."kmsegments"
    ADD CONSTRAINT "kmsegments_pkey" PRIMARY KEY ("table_id");



ALTER TABLE ONLY "public"."nodescode"
    ADD CONSTRAINT "nodescode_pkey" PRIMARY KEY ("code");



ALTER TABLE ONLY "public"."organization"
    ADD CONSTRAINT "organization_Organization_key" UNIQUE ("orgName");



ALTER TABLE ONLY "public"."profile"
    ADD CONSTRAINT "profile_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."pasada"
    ADD CONSTRAINT "road_drivers_pkey" PRIMARY KEY ("driver");



ALTER TABLE ONLY "public"."roles"
    ADD CONSTRAINT "roles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."route_table"
    ADD CONSTRAINT "route_table_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."v_types"
    ADD CONSTRAINT "v_types_pkey" PRIMARY KEY ("id");



CREATE OR REPLACE TRIGGER "add_driver_on_profile_update" AFTER UPDATE OF "role" ON "public"."profile" FOR EACH ROW EXECUTE FUNCTION "public"."insert_to_driver_table"();



ALTER TABLE ONLY "public"."distancetable"
    ADD CONSTRAINT "distancetable_end_node_fkey" FOREIGN KEY ("end_node") REFERENCES "public"."nodescode"("code");



ALTER TABLE ONLY "public"."distancetable"
    ADD CONSTRAINT "distancetable_start_node_fkey" FOREIGN KEY ("start_node") REFERENCES "public"."nodescode"("code");



ALTER TABLE ONLY "public"."driverlogs"
    ADD CONSTRAINT "driverlogs_route_fkey" FOREIGN KEY ("route") REFERENCES "public"."route_table"("id");



ALTER TABLE ONLY "public"."kmsegments"
    ADD CONSTRAINT "kmsegments_destination_fkey" FOREIGN KEY ("destination") REFERENCES "public"."nodescode"("code") ON UPDATE CASCADE;



ALTER TABLE ONLY "public"."kmsegments"
    ADD CONSTRAINT "kmsegments_origin_fkey" FOREIGN KEY ("origin") REFERENCES "public"."nodescode"("code") ON UPDATE CASCADE;



ALTER TABLE ONLY "public"."pasada"
    ADD CONSTRAINT "pasada_driver_fkey" FOREIGN KEY ("driver") REFERENCES "auth"."users"("id") ON UPDATE CASCADE;



ALTER TABLE ONLY "public"."pasada"
    ADD CONSTRAINT "pasada_driver_route_fkey" FOREIGN KEY ("driver_route") REFERENCES "public"."route_table"("id");



ALTER TABLE ONLY "public"."pasada"
    ADD CONSTRAINT "pasada_organization_fkey" FOREIGN KEY ("organization") REFERENCES "public"."organization"("id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."profile"
    ADD CONSTRAINT "profile_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."profile"
    ADD CONSTRAINT "profile_role_fkey" FOREIGN KEY ("role") REFERENCES "public"."roles"("id") ON UPDATE CASCADE;



ALTER TABLE ONLY "public"."profile"
    ADD CONSTRAINT "profile_v_type_fkey" FOREIGN KEY ("v_type") REFERENCES "public"."v_types"("id") ON UPDATE CASCADE;



ALTER TABLE ONLY "public"."route_table"
    ADD CONSTRAINT "route_table_destination_fkey" FOREIGN KEY ("destination") REFERENCES "public"."nodescode"("code") ON UPDATE CASCADE;



ALTER TABLE ONLY "public"."route_table"
    ADD CONSTRAINT "route_table_origin_fkey" FOREIGN KEY ("origin") REFERENCES "public"."nodescode"("code") ON UPDATE CASCADE;



CREATE POLICY "Enable delete for users based on user_id" ON "public"."profile" FOR DELETE TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "id"));



CREATE POLICY "Enable insert for authenticated users only" ON "public"."driverlogs" FOR INSERT TO "authenticated" WITH CHECK (true);



CREATE POLICY "Enable insert for authenticated users only" ON "public"."profile" FOR INSERT TO "authenticated" WITH CHECK (true);



CREATE POLICY "Enable users to view their own data only" ON "public"."profile" FOR SELECT TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "id"));



CREATE POLICY "Users can view their classification based on profile.id" ON "public"."roles" FOR SELECT TO "authenticated" USING ((( SELECT "profile"."role"
   FROM "public"."profile"
  WHERE ("profile"."id" = ( SELECT "auth"."uid"() AS "uid"))) = "id"));



CREATE POLICY "can_update_own_data" ON "public"."profile" FOR UPDATE TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "id")) WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "id"));



ALTER TABLE "public"."distancetable" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."driverlogs" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."kmsegments" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."nodescode" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."organization" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."pasada" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."profile" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."roles" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."route_table" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."v_types" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";










































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































GRANT ALL ON FUNCTION "public"."check_is_admin"() TO "service_role";



GRANT ALL ON FUNCTION "public"."check_is_driver"() TO "service_role";



REVOKE ALL ON FUNCTION "public"."combine_segment_array"("input_array" "text"[], "driver_index" integer, "passenger_index" integer) FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."combine_segment_array"("input_array" "text"[], "driver_index" integer, "passenger_index" integer) TO "service_role";



REVOKE ALL ON FUNCTION "public"."distance_driver_passenger"("segment_array" "text"[]) FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."distance_driver_passenger"("segment_array" "text"[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."distance_from_origin"("lat" real, "long" real) TO "service_role";



GRANT ALL ON FUNCTION "public"."drv_min"("lat" real, "long" real, "upd_tme" timestamp without time zone, "spd" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."drv_set"("ogn" "text", "dest" "text", "lat" real, "long" real, "tme" timestamp without time zone, "spd" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_text_code"("node_var" "text") TO "service_role";



REVOKE ALL ON FUNCTION "public"."handle_new_user"() FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";



REVOKE ALL ON FUNCTION "public"."inbetween_segmental_distance"("input_array" "text"[], "driver_index" integer, "passenger_index" integer) FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."inbetween_segmental_distance"("input_array" "text"[], "driver_index" integer, "passenger_index" integer) TO "service_role";



REVOKE ALL ON FUNCTION "public"."insert_to_driver_table"() FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."insert_to_driver_table"() TO "service_role";



GRANT ALL ON FUNCTION "public"."q_drivers"("lat" real, "long" real, "dest" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."q_drivers2"("lat" real, "long" real, "dest" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."setlog"("lats" real, "longs" real, "late" real, "longe" real, "stime" timestamp without time zone, "etime" timestamp without time zone) TO "service_role";



GRANT ALL ON FUNCTION "public"."upd_ctr"("uid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_daily_credit"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_search_counter"("uuids" "uuid"[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."update_sub"("mail" "text", "is_paid" boolean, "days" integer) TO "service_role";


















GRANT ALL ON TABLE "public"."organization" TO "anon";
GRANT ALL ON TABLE "public"."organization" TO "authenticated";
GRANT ALL ON TABLE "public"."organization" TO "service_role";



GRANT ALL ON SEQUENCE "public"."Organization_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."Organization_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."Organization_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."distancetable" TO "anon";
GRANT ALL ON TABLE "public"."distancetable" TO "authenticated";
GRANT ALL ON TABLE "public"."distancetable" TO "service_role";



GRANT ALL ON TABLE "public"."driverlogs" TO "anon";
GRANT ALL ON TABLE "public"."driverlogs" TO "authenticated";
GRANT ALL ON TABLE "public"."driverlogs" TO "service_role";



GRANT ALL ON SEQUENCE "public"."driverlogs_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."driverlogs_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."driverlogs_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."kmsegments" TO "anon";
GRANT ALL ON TABLE "public"."kmsegments" TO "authenticated";
GRANT ALL ON TABLE "public"."kmsegments" TO "service_role";



GRANT ALL ON TABLE "public"."nodescode" TO "anon";
GRANT ALL ON TABLE "public"."nodescode" TO "authenticated";
GRANT ALL ON TABLE "public"."nodescode" TO "service_role";



GRANT ALL ON TABLE "public"."pasada" TO "anon";
GRANT ALL ON TABLE "public"."pasada" TO "authenticated";
GRANT ALL ON TABLE "public"."pasada" TO "service_role";



GRANT ALL ON TABLE "public"."profile" TO "anon";
GRANT ALL ON TABLE "public"."profile" TO "authenticated";
GRANT ALL ON TABLE "public"."profile" TO "service_role";



GRANT ALL ON TABLE "public"."roles" TO "anon";
GRANT ALL ON TABLE "public"."roles" TO "authenticated";
GRANT ALL ON TABLE "public"."roles" TO "service_role";



GRANT ALL ON SEQUENCE "public"."roles_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."roles_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."roles_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."route_table" TO "anon";
GRANT ALL ON TABLE "public"."route_table" TO "authenticated";
GRANT ALL ON TABLE "public"."route_table" TO "service_role";



GRANT ALL ON TABLE "public"."v_types" TO "anon";
GRANT ALL ON TABLE "public"."v_types" TO "authenticated";
GRANT ALL ON TABLE "public"."v_types" TO "service_role";



GRANT ALL ON SEQUENCE "public"."v_types_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."v_types_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."v_types_id_seq" TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";






























RESET ALL;
