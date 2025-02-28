BEGIN;
SELECT plan(9);

select function_returns('setlog',array['real','real','real','real','timestamp without time zone','timestamp without time zone'],'void');
select is_definer('setlog');
select is_strict('setlog');

select function_privs_are('setlog',array['real','real','real','real','timestamp without time zone','timestamp without time zone'],'anon',null);
select function_privs_are('setlog',
    array[
        'real','real','real','real','timestamp without time zone',
        'timestamp without time zone'
    ],
    'authenticated',array['EXECUTE']
);
reset role;
update public.profile
set role=1
where id ='e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid;

set role authenticated;
select set_config('role', 'authenticated', true),
set_config('request.jwt.claims', 
    '{"aal":"aal1","amr":[{"method":"password","timestamp":2840570787}],"app_metadata":{"provider":"email","providers":["email"]},"aud":"authenticated","email":"galoAug00@gmail.com","exp":2840574387,"iat":2840570787,"iss":"https://default.supabase.co/auth/v1","phone":null,"role":"authenticated","session_id":"8a2787e7-ae95-435a-948f-b96543b4681b","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","user_metadata":{"ext":"","mun":"Tuba","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","bday":"2000-08-18 00:00:00000000+00","brgy":"Camp 4","prov":"Benguet","email":"galoAug00@gmail.com","phone":"09582808115","f_name":"Terrijo","l_name":"Galo","street":"165 J. B. Miguel Street","is_male":false,"username":"Terrijo","email_verified":false,"phone_verified":false},"is_anonymous":false}', true),
set_config('request.method', 'POST', true),
set_config('request.path', '/impersonation-example-request-path', true),
set_config('request.headers', '{"accept": "*/*"}', true);
select 1 as "ROLE_IMPERSONATION_NO_RESULTS";


select setlog(
    16.911553::real,121.060724::real,16.7998::real,121.122159::real,
    now()::timestamp,(current_timestamp+ interval '1 hour')::TIMESTAMP WITHOUT TIME ZONE
);
reset role;
prepare must_empty as 
    select * 
    from driver_updates 
    where drv ='e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid;
select is_empty('must_empty');


reset role;
update public.profile
set role=3
where id ='e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid;

insert into public.driver_updates ("datetime","lat","long","drv")
	values(now()::timestamp,15,120,'e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid);

set role authenticated;
select set_config('role', 'authenticated', true),
set_config('request.jwt.claims', 
    '{"aal":"aal1","amr":[{"method":"password","timestamp":2840570787}],"app_metadata":{"provider":"email","providers":["email"]},"aud":"authenticated","email":"galoAug00@gmail.com","exp":2840574387,"iat":2840570787,"iss":"https://default.supabase.co/auth/v1","phone":null,"role":"authenticated","session_id":"8a2787e7-ae95-435a-948f-b96543b4681b","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","user_metadata":{"ext":"","mun":"Tuba","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","bday":"2000-08-18 00:00:00000000+00","brgy":"Camp 4","prov":"Benguet","email":"galoAug00@gmail.com","phone":"09582808115","f_name":"Terrijo","l_name":"Galo","street":"165 J. B. Miguel Street","is_male":false,"username":"Terrijo","email_verified":false,"phone_verified":false},"is_anonymous":false}', true),
set_config('request.method', 'POST', true),
set_config('request.path', '/impersonation-example-request-path', true),
set_config('request.headers', '{"accept": "*/*"}', true);
select 1 as "ROLE_IMPERSONATION_NO_RESULTS";


select setlog(
    16,121,16.7998::real,121.122159::real,
    now()::timestamp,(current_timestamp+ interval '1 hour')::TIMESTAMP WITHOUT TIME ZONE
);
set role postgres;
prepare not_empty as 
    select * 
    from driverlogs 
    where driver_id ='e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid 
        and "latStart" =16 and "longStart"=121;
select isnt_empty('not_empty');


update public.profile
set role=3
where id ='e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid;

insert into public.driver_updates ("datetime","lat","long","drv")
	values(now()::timestamp,15,120,'e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid);

set role authenticated;
select set_config('role', 'authenticated', true),
set_config('request.jwt.claims', 
    '{"aal":"aal1","amr":[{"method":"password","timestamp":2840570787}],"app_metadata":{"provider":"email","providers":["email"]},"aud":"authenticated","email":"galoAug00@gmail.com","exp":2840574387,"iat":2840570787,"iss":"https://default.supabase.co/auth/v1","phone":null,"role":"authenticated","session_id":"8a2787e7-ae95-435a-948f-b96543b4681b","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","user_metadata":{"ext":"","mun":"Tuba","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","bday":"2000-08-18 00:00:00000000+00","brgy":"Camp 4","prov":"Benguet","email":"galoAug00@gmail.com","phone":"09582808115","f_name":"Terrijo","l_name":"Galo","street":"165 J. B. Miguel Street","is_male":false,"username":"Terrijo","email_verified":false,"phone_verified":false},"is_anonymous":false}', true),
set_config('request.method', 'POST', true),
set_config('request.path', '/impersonation-example-request-path', true),
set_config('request.headers', '{"accept": "*/*"}', true);
select 1 as "ROLE_IMPERSONATION_NO_RESULTS";


select setlog(
    16,121,16.7998::real,121.122159::real,
    now()::timestamp,(current_timestamp+ interval '1 hour')::TIMESTAMP WITHOUT TIME ZONE
);
set role postgres;
prepare not_empty2 as 
    select drv,lat,long
    from driver_updates 
    where  "lat" =15 and "long"=120;
select results_eq('not_empty2',
    $$VALUES 
    (null::uuid,15::double precision,120::double precision),
    (null::uuid,15::double precision,120::double precision)
  $$
);

prepare empty_error as 
    select setlog(
        16,121,16.7998::real,121.122159::real,
        now()::timestamp,(current_timestamp+ interval '1 hour')::TIMESTAMP WITHOUT TIME ZONE
    );
select lives_ok('empty_error');
SELECT * FROM finish();
ROLLBACK;