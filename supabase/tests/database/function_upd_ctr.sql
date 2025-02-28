BEGIN;
SELECT plan(12);

select function_returns('upd_ctr','boolean');
select is_definer('upd_ctr');
select is_strict('upd_ctr');
select function_privs_are('upd_ctr',array['uuid'],'anon',null);
select volatility_is('upd_ctr',array['uuid'],'volatile');
select function_privs_are('upd_ctr',array['uuid'],'authenticated',null);


update public.profile
set has_paid =true
where id = 'e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid;

update public.pasada
set counter = null
where driver = '5b996de3-b0e1-4c0f-bcbb-7125b21dcee3'::uuid;

grant EXECUTE on function public.upd_ctr(uuid) to authenticated;
set role authenticated;
select set_config('role', 'authenticated', true),
set_config('request.jwt.claims', 
    '{"aal":"aal1","amr":[{"method":"password","timestamp":2840570787}],"app_metadata":{"provider":"email","providers":["email"]},"aud":"authenticated","email":"galoAug00@gmail.com","exp":2840574387,"iat":2840570787,"iss":"https://default.supabase.co/auth/v1","phone":null,"role":"authenticated","session_id":"8a2787e7-ae95-435a-948f-b96543b4681b","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","user_metadata":{"ext":"","mun":"Tuba","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","bday":"2000-08-18 00:00:00000000+00","brgy":"Camp 4","prov":"Benguet","email":"galoAug00@gmail.com","phone":"09582808115","f_name":"Terrijo","l_name":"Galo","street":"165 J. B. Miguel Street","is_male":false,"username":"Terrijo","email_verified":false,"phone_verified":false},"is_anonymous":false}', true),
set_config('request.method', 'POST', true),
set_config('request.path', '/impersonation-example-request-path', true),
set_config('request.headers', '{"accept": "*/*"}', true);
select 1 as "ROLE_IMPERSONATION_NO_RESULTS";

-- select upd_ctr('5b996de3-b0e1-4c0f-bcbb-7125b21dcee3'::uuid);
prepare is_true as select upd_ctr('5b996de3-b0e1-4c0f-bcbb-7125b21dcee3'::uuid);
select results_eq('is_true',array[true]);

reset role;
prepare not_empty as 
    select counter
    from pasada 
    where driver ='5b996de3-b0e1-4c0f-bcbb-7125b21dcee3'::uuid;
select results_eq('not_empty',    $$VALUES 
    (1::bigint)
  $$);

update public.profile
set has_paid =true
where id ='e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid;

update public.pasada
set counter = 1
where driver ='5b996de3-b0e1-4c0f-bcbb-7125b21dcee3'::uuid;

set role authenticated;
select set_config('role', 'authenticated', true),
set_config('request.jwt.claims', 
    '{"aal":"aal1","amr":[{"method":"password","timestamp":2840570787}],"app_metadata":{"provider":"email","providers":["email"]},"aud":"authenticated","email":"galoAug00@gmail.com","exp":2840574387,"iat":2840570787,"iss":"https://default.supabase.co/auth/v1","phone":null,"role":"authenticated","session_id":"8a2787e7-ae95-435a-948f-b96543b4681b","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","user_metadata":{"ext":"","mun":"Tuba","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","bday":"2000-08-18 00:00:00000000+00","brgy":"Camp 4","prov":"Benguet","email":"galoAug00@gmail.com","phone":"09582808115","f_name":"Terrijo","l_name":"Galo","street":"165 J. B. Miguel Street","is_male":false,"username":"Terrijo","email_verified":false,"phone_verified":false},"is_anonymous":false}', true),
set_config('request.method', 'POST', true),
set_config('request.path', '/impersonation-example-request-path', true),
set_config('request.headers', '{"accept": "*/*"}', true);
select 1 as "ROLE_IMPERSONATION_NO_RESULTS";

-- select upd_ctr('5b996de3-b0e1-4c0f-bcbb-7125b21dcee3'::uuid);
prepare is_true2 as select upd_ctr('5b996de3-b0e1-4c0f-bcbb-7125b21dcee3'::uuid);
select results_eq('is_true2',array[true]);
reset role;
prepare not_empty2 as 
    select * 
    from pasada 
    where driver ='5b996de3-b0e1-4c0f-bcbb-7125b21dcee3'::uuid and counter=2::bigint;
select isnt_empty('not_empty2');


update public.profile
set has_paid =false
where id ='e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid;

update public.pasada
set counter = 1
where driver ='5b996de3-b0e1-4c0f-bcbb-7125b21dcee3'::uuid;

set role authenticated;
select set_config('role', 'authenticated', true),
set_config('request.jwt.claims', 
    '{"aal":"aal1","amr":[{"method":"password","timestamp":2840570787}],"app_metadata":{"provider":"email","providers":["email"]},"aud":"authenticated","email":"galoAug00@gmail.com","exp":2840574387,"iat":2840570787,"iss":"https://default.supabase.co/auth/v1","phone":null,"role":"authenticated","session_id":"8a2787e7-ae95-435a-948f-b96543b4681b","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","user_metadata":{"ext":"","mun":"Tuba","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","bday":"2000-08-18 00:00:00000000+00","brgy":"Camp 4","prov":"Benguet","email":"galoAug00@gmail.com","phone":"09582808115","f_name":"Terrijo","l_name":"Galo","street":"165 J. B. Miguel Street","is_male":false,"username":"Terrijo","email_verified":false,"phone_verified":false},"is_anonymous":false}', true),
set_config('request.method', 'POST', true),
set_config('request.path', '/impersonation-example-request-path', true),
set_config('request.headers', '{"accept": "*/*"}', true);
select 1 as "ROLE_IMPERSONATION_NO_RESULTS";

-- select upd_ctr('5b996de3-b0e1-4c0f-bcbb-7125b21dcee3'::uuid);
prepare is_false as select upd_ctr('5b996de3-b0e1-4c0f-bcbb-7125b21dcee3'::uuid);
select results_eq('is_false',array[false]);
reset role;
prepare no_change as 
    select * 
    from pasada 
    where driver ='5b996de3-b0e1-4c0f-bcbb-7125b21dcee3'::uuid and counter=1::bigint;
select isnt_empty('no_change');
SELECT * FROM finish();
ROLLBACK;