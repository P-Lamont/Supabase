BEGIN;
SELECT plan(17);

select function_returns(
    'drv_set',
    array[
        'text','text','real','real','timestamp without time zone','integer'
    ],
    'void'
);
select is_definer('drv_set');
select is_strict('drv_set');
select volatility_is(
    'drv_set',
    array[
        'text','text','real','real','timestamp without time zone','integer'
    ],
    'volatile'
);
select function_privs_are(
    'drv_set',
    array[
        'text','text','real','real','timestamp without time zone','integer'
    ],
    'anon',
    null
);
select function_privs_are(
    'drv_set',
    array[
        'text','text','real','real','timestamp without time zone','integer'
    ],
    'authenticated',
    array['EXECUTE']
);
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

prepare fail_non_driver as 
    select drv_set('Banaue','Lagawe',16.911553,121.060724,now()::timestamp,10); 
select throws_ok(
    'fail_non_driver',
    'code:1'
);

reset role;
update public.profile
set role=3
where id ='e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid;

set role authenticated;
select set_config('role', 'authenticated', true),
set_config('request.jwt.claims', 
    '{"aal":"aal1","amr":[{"method":"password","timestamp":2840570787}],"app_metadata":{"provider":"email","providers":["email"]},"aud":"authenticated","email":"galoAug00@gmail.com","exp":2840574387,"iat":2840570787,"iss":"https://default.supabase.co/auth/v1","phone":null,"role":"authenticated","session_id":"8a2787e7-ae95-435a-948f-b96543b4681b","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","user_metadata":{"ext":"","mun":"Tuba","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","bday":"2000-08-18 00:00:00000000+00","brgy":"Camp 4","prov":"Benguet","email":"galoAug00@gmail.com","phone":"09582808115","f_name":"Terrijo","l_name":"Galo","street":"165 J. B. Miguel Street","is_male":false,"username":"Terrijo","email_verified":false,"phone_verified":false},"is_anonymous":false}', true),
set_config('request.method', 'POST', true),
set_config('request.path', '/impersonation-example-request-path', true),
set_config('request.headers', '{"accept": "*/*"}', true);
select 1 as "ROLE_IMPERSONATION_NO_RESULTS";

prepare success_driver as 
    select drv_set('Banaue','Lagawe',16.911553,121.060724,now()::timestamp,10); 
select lives_ok(
    'success_driver'
);
select drv_set('Banaue','Lagawe',16,121,now()::timestamp,5); 
prepare must_exist as 
    select speed,latitude,longitude 
    from pasada 
    where driver ='e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid
        and speed=5 and latitude=16 and longitude=121;
set role postgres;
select isnt_empty('must_exist');


reset role;
update public.profile
set role=3
where id ='e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid;

set role authenticated;
select set_config('role', 'authenticated', true),
set_config('request.jwt.claims', 
    '{"aal":"aal1","amr":[{"method":"password","timestamp":2840570787}],"app_metadata":{"provider":"email","providers":["email"]},"aud":"authenticated","email":"galoAug00@gmail.com","exp":2840574387,"iat":2840570787,"iss":"https://default.supabase.co/auth/v1","phone":null,"role":"authenticated","session_id":"8a2787e7-ae95-435a-948f-b96543b4681b","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","user_metadata":{"ext":"","mun":"Tuba","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","bday":"2000-08-18 00:00:00000000+00","brgy":"Camp 4","prov":"Benguet","email":"galoAug00@gmail.com","phone":"09582808115","f_name":"Terrijo","l_name":"Galo","street":"165 J. B. Miguel Street","is_male":false,"username":"Terrijo","email_verified":false,"phone_verified":false},"is_anonymous":false}', true),
set_config('request.method', 'POST', true),
set_config('request.path', '/impersonation-example-request-path', true),
set_config('request.headers', '{"accept": "*/*"}', true);
select 1 as "ROLE_IMPERSONATION_NO_RESULTS";

select drv_set('Banaue','Lagawe',16,121,now()::timestamp,5); 
prepare must_exist2 as 
    select *
    from driver_updates 
    where drv ='e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid
        and lat=16 and long=121;
set role postgres;
select isnt_empty('must_exist2');


reset role;
update public.profile
set role=3
where id ='e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid;

set role authenticated;
select set_config('role', 'authenticated', true),
set_config('request.jwt.claims', 
    '{"aal":"aal1","amr":[{"method":"password","timestamp":2840570787}],"app_metadata":{"provider":"email","providers":["email"]},"aud":"authenticated","email":"galoAug00@gmail.com","exp":2840574387,"iat":2840570787,"iss":"https://default.supabase.co/auth/v1","phone":null,"role":"authenticated","session_id":"8a2787e7-ae95-435a-948f-b96543b4681b","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","user_metadata":{"ext":"","mun":"Tuba","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","bday":"2000-08-18 00:00:00000000+00","brgy":"Camp 4","prov":"Benguet","email":"galoAug00@gmail.com","phone":"09582808115","f_name":"Terrijo","l_name":"Galo","street":"165 J. B. Miguel Street","is_male":false,"username":"Terrijo","email_verified":false,"phone_verified":false},"is_anonymous":false}', true),
set_config('request.method', 'POST', true),
set_config('request.path', '/impersonation-example-request-path', true),
set_config('request.headers', '{"accept": "*/*"}', true);
select 1 as "ROLE_IMPERSONATION_NO_RESULTS";

prepare invalid_lat as select drv_set('Banaue','Lagawe',0.1,121,now()::timestamp,5);  
select throws_ok('invalid_lat','code:1');


prepare invalid_lat2 as select drv_set('Banaue','Lagawe',22.1,121,now()::timestamp,5);  
select throws_ok('invalid_lat2','code:1');


prepare invalid_long as select drv_set('Banaue','Lagawe',1,115.9,now()::timestamp,5);  
select throws_ok('invalid_long','code:1');


prepare invalid_long2 as select drv_set('Banaue','Lagawe',21,128.1,now()::timestamp,5);  
select throws_ok('invalid_long2','code:1');


prepare invalid_orig as select drv_set('Banae','Lagawe',16,119,now()::timestamp,5);  
select throws_ok('invalid_orig','Origin not found.');


prepare invalid_dest as select drv_set('Banaue','Lagae',21,128,now()::timestamp,5);  
select throws_ok('invalid_dest','Destination not found');

prepare invalid_route as select drv_set('Banaue','Banaue',21,128,now()::timestamp,5);  
select throws_ok('invalid_route','Route not found');
SELECT * FROM finish();
ROLLBACK;