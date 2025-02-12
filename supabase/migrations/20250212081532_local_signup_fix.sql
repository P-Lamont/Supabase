alter table "public"."profile" alter column "bday" set data type text using "bday"::text;

alter table "public"."profile" alter column "municipality" set not null;

alter table "public"."profile" alter column "province" set not null;

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.get_text_code(node_var text)
 RETURNS text
 LANGUAGE plpgsql
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

CREATE OR REPLACE FUNCTION public.setlog(lats real, longs real, late real, longe real, stime timestamp without time zone, etime timestamp without time zone)
 RETURNS void
 LANGUAGE plpgsql
 STRICT SECURITY DEFINER
 SET search_path TO ''
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.update_daily_credit()
 RETURNS boolean
 LANGUAGE plpgsql
 STRICT
 SET search_path TO ''
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.update_sub(mail text, is_paid boolean, days integer)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
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


