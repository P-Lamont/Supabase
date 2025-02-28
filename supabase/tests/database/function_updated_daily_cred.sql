BEGIN;
SELECT plan( 16 );

select function_returns('update_daily_credit','boolean');
select isnt_definer('update_daily_credit');
select volatility_is('update_daily_credit',array[''],'volatile');
select function_privs_are('update_daily_credit',array[''],'anon',null);
select function_privs_are('update_daily_credit',array[''],'authenticated',null);
set role postgres;
create or replace function sample_update_daily()
returns boolean as $$
declare
data2 boolean;
begin
select update_daily_credit() into data2;
return data2;
end;
$$ LANGUAGE plpgsql security definer;
grant execute on function sample_update_daily to authenticated;
grant all on table public.profile to authenticated;


update public.profile
set subscription =current_date+ interval '30 days',daily_credits=0,
    identifier=null, last_query=current_date-interval '1 day',role=1
where id ='e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid;

set role authenticated;
select set_config('role', 'authenticated', true),
set_config('request.jwt.claims', 
    '{"aal":"aal1","amr":[{"method":"password","timestamp":2840570787}],"app_metadata":{"provider":"email","providers":["email"]},"aud":"authenticated","email":"galoAug00@gmail.com","exp":2840574387,"iat":2840570787,"iss":"https://default.supabase.co/auth/v1","phone":null,"role":"authenticated","session_id":"8a2787e7-ae95-435a-948f-b96543b4681b","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","user_metadata":{"ext":"","mun":"Tuba","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","bday":"2000-08-18 00:00:00000000+00","brgy":"Camp 4","prov":"Benguet","email":"galoAug00@gmail.com","phone":"09582808115","f_name":"Terrijo","l_name":"Galo","street":"165 J. B. Miguel Street","is_male":false,"username":"Terrijo","email_verified":false,"phone_verified":false},"is_anonymous":false}', true),
set_config('request.method', 'POST', true),
set_config('request.path', '/impersonation-example-request-path', true),
set_config('request.headers', '{"accept": "*/*"}', true);
select 1 as "ROLE_IMPERSONATION_NO_RESULTS";

prepare is_true as select sample_update_daily();
select results_eq('is_true',array[true]);
-- select sample_update_daily();
prepare validate1 as 
    select last_query,daily_credits
    from public.profile
    where id ='e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid 
        and identifier is not null;

select results_eq('validate1',$$ values (current_date,9::smallint)$$);


reset role;
update public.profile
set subscription =current_date+ interval '30 days',daily_credits=9,
    identifier='11111111-1111-1111-1111-111111111111'::uuid, 
    last_query=current_date ,role=1
where id ='e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid;

set role authenticated;
select set_config('role', 'authenticated', true),
set_config('request.jwt.claims', 
    '{"aal":"aal1","amr":[{"method":"password","timestamp":2840570787}],"app_metadata":{"provider":"email","providers":["email"]},"aud":"authenticated","email":"galoAug00@gmail.com","exp":2840574387,"iat":2840570787,"iss":"https://default.supabase.co/auth/v1","phone":null,"role":"authenticated","session_id":"8a2787e7-ae95-435a-948f-b96543b4681b","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","user_metadata":{"ext":"","mun":"Tuba","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","bday":"2000-08-18 00:00:00000000+00","brgy":"Camp 4","prov":"Benguet","email":"galoAug00@gmail.com","phone":"09582808115","f_name":"Terrijo","l_name":"Galo","street":"165 J. B. Miguel Street","is_male":false,"username":"Terrijo","email_verified":false,"phone_verified":false},"is_anonymous":false}', true),
set_config('request.method', 'POST', true),
set_config('request.path', '/impersonation-example-request-path', true),
set_config('request.headers', '{"accept": "*/*"}', true);
select 1 as "ROLE_IMPERSONATION_NO_RESULTS";

select sample_update_daily();
prepare validate2 as 
    select last_query,daily_credits,identifier
    from public.profile
    where id ='e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid;

select results_eq(
    'validate2',
    $$ values (
        current_date,8::smallint,
        '11111111-1111-1111-1111-111111111111'::uuid
    )$$
);

reset role;
update public.profile
set subscription =current_date- interval '30 days',daily_credits=null,
    identifier='11111111-1111-1111-1111-111111111111'::uuid, 
    last_query=current_date-interval '30 days' ,role=1
where id ='e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid;

set role authenticated;
select set_config('role', 'authenticated', true),
set_config('request.jwt.claims', 
    '{"aal":"aal1","amr":[{"method":"password","timestamp":2840570787}],"app_metadata":{"provider":"email","providers":["email"]},"aud":"authenticated","email":"galoAug00@gmail.com","exp":2840574387,"iat":2840570787,"iss":"https://default.supabase.co/auth/v1","phone":null,"role":"authenticated","session_id":"8a2787e7-ae95-435a-948f-b96543b4681b","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","user_metadata":{"ext":"","mun":"Tuba","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","bday":"2000-08-18 00:00:00000000+00","brgy":"Camp 4","prov":"Benguet","email":"galoAug00@gmail.com","phone":"09582808115","f_name":"Terrijo","l_name":"Galo","street":"165 J. B. Miguel Street","is_male":false,"username":"Terrijo","email_verified":false,"phone_verified":false},"is_anonymous":false}', true),
set_config('request.method', 'POST', true),
set_config('request.path', '/impersonation-example-request-path', true),
set_config('request.headers', '{"accept": "*/*"}', true);
select 1 as "ROLE_IMPERSONATION_NO_RESULTS";

prepare validate3 as select sample_update_daily();
prepare validate_no_change as 
    select daily_credits,last_query,identifier
    from public.profile
    where id ='e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid;
select results_eq(
    'validate_no_change',
    $$ values(
        null::smallint,(current_date-interval '30 days')::date,
        '11111111-1111-1111-1111-111111111111'::uuid
    )$$
);
select results_eq('validate3',array[false]);

reset role;
update public.profile
set subscription =current_date- interval '30 days',daily_credits=null,
    identifier='11111111-1111-1111-1111-111111111111'::uuid, 
    last_query=null ,role=1
where id ='e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid;

set role authenticated;
select set_config('role', 'authenticated', true),
set_config('request.jwt.claims', 
    '{"aal":"aal1","amr":[{"method":"password","timestamp":2840570787}],"app_metadata":{"provider":"email","providers":["email"]},"aud":"authenticated","email":"galoAug00@gmail.com","exp":2840574387,"iat":2840570787,"iss":"https://default.supabase.co/auth/v1","phone":null,"role":"authenticated","session_id":"8a2787e7-ae95-435a-948f-b96543b4681b","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","user_metadata":{"ext":"","mun":"Tuba","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","bday":"2000-08-18 00:00:00000000+00","brgy":"Camp 4","prov":"Benguet","email":"galoAug00@gmail.com","phone":"09582808115","f_name":"Terrijo","l_name":"Galo","street":"165 J. B. Miguel Street","is_male":false,"username":"Terrijo","email_verified":false,"phone_verified":false},"is_anonymous":false}', true),
set_config('request.method', 'POST', true),
set_config('request.path', '/impersonation-example-request-path', true),
set_config('request.headers', '{"accept": "*/*"}', true);
select 1 as "ROLE_IMPERSONATION_NO_RESULTS";

prepare validate4 as select sample_update_daily();
prepare validate_no_change2 as 
    select daily_credits,last_query,identifier
    from public.profile
    where id ='e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid;
select results_eq(
    'validate_no_change2',
    $$ values(
        null::smallint,null::date,
        '11111111-1111-1111-1111-111111111111'::uuid
    )$$
);
select results_eq('validate4',array[false]);


reset role;
update public.profile
set subscription =current_date+ interval '15 days',daily_credits=0,
    identifier='11111111-1111-1111-1111-111111111111'::uuid, 
    last_query=current_date ,role=1
where id ='e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid;

set role authenticated;
select set_config('role', 'authenticated', true),
set_config('request.jwt.claims', 
    '{"aal":"aal1","amr":[{"method":"password","timestamp":2840570787}],"app_metadata":{"provider":"email","providers":["email"]},"aud":"authenticated","email":"galoAug00@gmail.com","exp":2840574387,"iat":2840570787,"iss":"https://default.supabase.co/auth/v1","phone":null,"role":"authenticated","session_id":"8a2787e7-ae95-435a-948f-b96543b4681b","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","user_metadata":{"ext":"","mun":"Tuba","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","bday":"2000-08-18 00:00:00000000+00","brgy":"Camp 4","prov":"Benguet","email":"galoAug00@gmail.com","phone":"09582808115","f_name":"Terrijo","l_name":"Galo","street":"165 J. B. Miguel Street","is_male":false,"username":"Terrijo","email_verified":false,"phone_verified":false},"is_anonymous":false}', true),
set_config('request.method', 'POST', true),
set_config('request.path', '/impersonation-example-request-path', true),
set_config('request.headers', '{"accept": "*/*"}', true);
select 1 as "ROLE_IMPERSONATION_NO_RESULTS";

prepare validate5 as select sample_update_daily();
prepare validate_no_change3 as 
    select daily_credits,last_query,identifier
    from public.profile
    where id ='e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid;
select results_eq(
    'validate_no_change3',
    $$ values(
        0::smallint,current_date,
        '11111111-1111-1111-1111-111111111111'::uuid
    )$$
);
select results_eq('validate5',array[false]);


reset role;
update public.profile
set subscription =null,daily_credits=null,
    identifier='11111111-1111-1111-1111-111111111111'::uuid, 
    last_query=null ,role=1
where id ='e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid;

set role authenticated;
select set_config('role', 'authenticated', true),
set_config('request.jwt.claims', 
    '{"aal":"aal1","amr":[{"method":"password","timestamp":2840570787}],"app_metadata":{"provider":"email","providers":["email"]},"aud":"authenticated","email":"galoAug00@gmail.com","exp":2840574387,"iat":2840570787,"iss":"https://default.supabase.co/auth/v1","phone":null,"role":"authenticated","session_id":"8a2787e7-ae95-435a-948f-b96543b4681b","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","user_metadata":{"ext":"","mun":"Tuba","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","bday":"2000-08-18 00:00:00000000+00","brgy":"Camp 4","prov":"Benguet","email":"galoAug00@gmail.com","phone":"09582808115","f_name":"Terrijo","l_name":"Galo","street":"165 J. B. Miguel Street","is_male":false,"username":"Terrijo","email_verified":false,"phone_verified":false},"is_anonymous":false}', true),
set_config('request.method', 'POST', true),
set_config('request.path', '/impersonation-example-request-path', true),
set_config('request.headers', '{"accept": "*/*"}', true);
select 1 as "ROLE_IMPERSONATION_NO_RESULTS";

prepare validate6 as select sample_update_daily();

select results_eq('validate6',array[false]);


reset role;
update public.profile
set subscription =current_date+ interval '30 days',daily_credits=0,
    identifier='11111111-1111-1111-1111-111111111111'::uuid, 
    last_query=current_date,role=1
where id ='e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid;

set role authenticated;
select set_config('role', 'authenticated', true),
set_config('request.jwt.claims', 
    '{"aal":"aal1","amr":[{"method":"password","timestamp":2840570787}],"app_metadata":{"provider":"email","providers":["email"]},"aud":"authenticated","email":"galoAug00@gmail.com","exp":2840574387,"iat":2840570787,"iss":"https://default.supabase.co/auth/v1","phone":null,"role":"authenticated","session_id":"8a2787e7-ae95-435a-948f-b96543b4681b","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","user_metadata":{"ext":"","mun":"Tuba","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","bday":"2000-08-18 00:00:00000000+00","brgy":"Camp 4","prov":"Benguet","email":"galoAug00@gmail.com","phone":"09582808115","f_name":"Terrijo","l_name":"Galo","street":"165 J. B. Miguel Street","is_male":false,"username":"Terrijo","email_verified":false,"phone_verified":false},"is_anonymous":false}', true),
set_config('request.method', 'POST', true),
set_config('request.path', '/impersonation-example-request-path', true),
set_config('request.headers', '{"accept": "*/*"}', true);
select 1 as "ROLE_IMPERSONATION_NO_RESULTS";

prepare validate7 as select sample_update_daily();

select results_eq('validate7',array[false]);
SELECT * FROM finish();
ROLLBACK;