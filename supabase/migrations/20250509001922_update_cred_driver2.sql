set check_function_bodies = off;

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
	if counts>-1 then
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


