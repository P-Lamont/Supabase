set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.q_drivers(lat real, long real, dest text)
 RETURNS TABLE(drv text, vhc text, spd smallint, dst integer, eta integer)
 LANGUAGE plpgsql
 SECURITY DEFINER
 Strict
 SET search_path TO ''
AS $function$DECLARE 
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

CREATE OR REPLACE FUNCTION public.update_daily_credit()
 RETURNS boolean
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$declare
	is_credible boolean;
	counts integer;
	daily_id uuid;
	is_driver boolean;
begin
	is_driver:=public.check_is_driver();
	with updated as(
		UPDATE public.profile
		SET 
			last_query = CASE 
				WHEN  subscription>=current_date THEN current_date
				-- WHEN last_query = current_date AND daily_credits > 0 THEN last_query
				-- ELSE last_query
				When is_driver=true then current_date
			END,
			daily_credits = CASE 
				WHEN  (subscription>=current_date and (current_date>last_query or last_query is null)) THEN 9 
				WHEN (last_query = current_date AND daily_credits > 0) THEN daily_credits - 1 
				when (is_driver=true and last_query=current_date) then daily_credits-1
				when (is_driver=true and last_query<current_date) then 9
				when(is_driver=true) then 9
				ELSE daily_credits
			end
		where (
		(
			(daily_credits>0 and last_query=current_date) or 
			(last_query<current_date and subscription>=current_date) or
			(subscription>current_date and last_query is null) or
			(is_driver=true)
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
end;$function$
;


