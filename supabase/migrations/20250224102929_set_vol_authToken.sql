set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.custom_access_token_hook(event jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
  declare
    original_claims jsonb;
    new_claims jsonb;
    claim text;
  begin
    original_claims = event->'claims';
    new_claims = '{}'::jsonb;

    foreach claim in array array[
      -- add claims you want to keep here
      'iss',
      'aud',
      'exp',
      'iat',
      'sub',
      'role',
      'aal',
      'session_id'
   ] loop
      if original_claims ? claim then
        -- original_claims contains one of the listed claims, set it on new_claims
        new_claims = jsonb_set(new_claims, array[claim], original_claims->claim);
      end if;
    end loop;

    return jsonb_build_object('claims', new_claims);
  end
$function$
;

CREATE OR REPLACE FUNCTION public.combine_segment_array(input_array text[], driver_index integer, passenger_index integer)
 RETURNS text[]
 LANGUAGE plpgsql
 STABLE STRICT
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
 STABLE STRICT
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

CREATE OR REPLACE FUNCTION public.get_text_code(node_var text)
 RETURNS text
 LANGUAGE plpgsql
 STABLE STRICT
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
 STABLE STRICT
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

-- Grant access to function to supabase_auth_admin
grant execute
  on function public.custom_access_token_hook
  to supabase_auth_admin;

-- Grant access to schema to supabase_auth_admin
grant usage on schema public to supabase_auth_admin;

-- Revoke function permissions from authenticated, anon and public
revoke execute
  on function public.custom_access_token_hook
  from authenticated, anon, public;
