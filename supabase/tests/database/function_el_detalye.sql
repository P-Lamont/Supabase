BEGIN;
SELECT plan(7);

select function_returns('el_detalye','setof record');
select is_definer('el_detalye');
-- set role postgres;
-- select is(el_detalye(),true);
select volatility_is('el_detalye',array[''],'stable');
select function_privs_are('el_detalye',array[''],'anon',null);
select function_privs_are('el_detalye',array[''],'authenticated',array['EXECUTE']);
select function_privs_are('el_detalye',array[''],'postgres',array['EXECUTE']);

update public.profile
set role=1,username='DDD',subscription=current_date::date,daily_credits=6,last_query=current_date::date
where id ='e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid;

set role authenticated;
select set_config('role', 'authenticated', true),
set_config('request.jwt.claims', 
    '{"aal":"aal1","amr":[{"method":"password","timestamp":2840570787}],"app_metadata":{"provider":"email","providers":["email"]},"aud":"authenticated","email":"galoAug00@gmail.com","exp":2840574387,"iat":2840570787,"iss":"https://default.supabase.co/auth/v1","phone":null,"role":"authenticated","session_id":"8a2787e7-ae95-435a-948f-b96543b4681b","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","user_metadata":{"ext":"","mun":"Tuba","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","bday":"2000-08-18 00:00:00000000+00","brgy":"Camp 4","prov":"Benguet","email":"galoAug00@gmail.com","phone":"09582808115","f_name":"Terrijo","l_name":"Galo","street":"165 J. B. Miguel Street","is_male":false,"username":"Terrijo","email_verified":false,"phone_verified":false},"is_anonymous":false}', true),
set_config('request.method', 'POST', true),
set_config('request.path', '/impersonation-example-request-path', true),
set_config('request.headers', '{"accept": "*/*"}', true);
select 1 as "ROLE_IMPERSONATION_NO_RESULTS";
-- prepare xdata as select el_detalye();
select is(public.el_detalye(),row (1::smallint,'DDD'::text,current_date::date,6::smallint,current_date::date));

SELECT * FROM finish();
ROLLBACK;
