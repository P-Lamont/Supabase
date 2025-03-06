set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.el_detalye()
 RETURNS TABLE(rl smallint, nme text, sub date, crd smallint, lsq date)
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
return query
select role,username,subscription,daily_credits,last_query
from public.profile
where id =(select auth.uid())
limit 1;
end $function$
;
revoke execute on function el_detalye() from public,anon,authenticated;
grant execute on function el_detalye() to postgres, authenticated;

