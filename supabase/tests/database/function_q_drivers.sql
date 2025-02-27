BEGIN;
SELECT plan( 19);


select function_returns('q_drivers',array['real','real','text'],'setof record');
select is_definer('q_drivers');
select is_strict('q_drivers');
select function_privs_are('q_drivers',array['real','real','text'],'anon',null);
select volatility_is('q_drivers',array['real','real','text'],'volatile');
select function_privs_are(
    'q_drivers',array['real','real','text'],'authenticated',array['EXECUTE']
);


update public.profile
set role = 3
where id = any(
  array[
    '004064d7-1f03-4ac4-9f01-17332dce1b0b'::uuid,
    '00b4d952-80b7-42a4-93b6-4f65b6949593'::uuid,
    '00c2bd15-ea3f-40fc-860e-c6524ff4ed00'::uuid,
    '01150444-8b0d-4d69-bb45-3ed9b7c402ea'::uuid,
    '014e2f62-d756-4652-8201-118cfaacd5ea'::uuid,
    '0154bad3-1a36-4215-9d8c-a85dcee40c45'::uuid,
    '019bf4d3-ba93-49b3-b229-27c6470374c3'::uuid
  ]
);


set role postgres;
prepare validate_number as select count(*) from public.pasada;
select results_eq('validate_number',array[9]::bigint[]);
-- driver in tam an to lagawe, user bocoh to lagawe
update public.pasada
set 
    latitude =16.902499,longitude=121.053332,segment_distance= 2304,speed =15,
    is_reversed_route=false,driver_route=4, segment=array['2701','2704'],
    time=now()::timestamp
where driver ='004064d7-1f03-4ac4-9f01-17332dce1b0b'::uuid;
prepare one_result as 
    select drv, vhc, spd  from  q_drivers(16.886394,121.059343,'Lagawe');
select results_eq(
  'one_result',
  $$VALUES ('Alvera','Unknown',15::smallint)$$
);


update public.pasada
set 
    latitude =null,longitude=null,segment_distance= null,
    is_reversed_route=null,driver_route=null, segment=null,
    time=null,speed =null
;
--driver in bocoh to lagawe, user tam an to lagawe
update public.pasada
set 
    latitude =16.886394,longitude=121.059343,segment_distance= 5051,
    is_reversed_route=false,driver_route=4, segment=array['2701','2704'],
    time=now()::timestamp,speed =15
where driver ='004064d7-1f03-4ac4-9f01-17332dce1b0b'::uuid;
prepare none_result as 
    select drv, vhc, spd from  q_drivers(16.902499,121.053332,'Lagawe');
select is_empty(
  'none_result'
);
update public.pasada
set 
    latitude =null,longitude=null,segment_distance= null,
    is_reversed_route=null,driver_route=null, segment=null,
    time=null,speed =null
;
--driver not appear in reverse
update public.pasada
set 
    latitude =16.902499,longitude=121.053332,segment_distance= 2304,speed =15,
    is_reversed_route=false,driver_route=4, segment=array['2701','2704'],
    time=now()::timestamp
where driver ='004064d7-1f03-4ac4-9f01-17332dce1b0b'::uuid;
prepare none_result_reverse as 
    select drv, vhc, spd  from  q_drivers(16.886394,121.059343,'Banaue');
select is_empty(
  'none_result_reverse'
);
update public.pasada
set 
    latitude =null,longitude=null,segment_distance= null,
    is_reversed_route=null,driver_route=null, segment=null,
    time=null,speed =null
;


--raise error lat,long
prepare lat_throw as 
    select drv, vhc, spd  from  q_drivers(0.12523,121.059343,'Banaue');
select throws_ok(
  'lat_throw','P0004'
);
prepare long_throw as 
    select drv, vhc, spd  from  q_drivers(14.12523,101.059343,'Banaue');
select throws_ok(
  'long_throw','P0004'
);
prepare dest_throw as 
    select drv, vhc, spd  from  q_drivers(14.12523,101.059343,'Banau');
select throws_ok(
  'dest_throw','P0004'
);
update public.pasada
set 
    latitude =null,longitude=null,segment_distance= null,
    is_reversed_route=null,driver_route=null, segment=null,
    time=null,speed =null
;


--2drivers->1 ban-sol,1lag-sol, customer lamut to solano
update public.pasada
set 
    latitude =16.902499,longitude=121.053332,segment_distance= 2304,speed =15,
    is_reversed_route=false,driver_route=3, segment=array['2701','2704'],
    time=now()::timestamp
where driver ='004064d7-1f03-4ac4-9f01-17332dce1b0b'::uuid;

update public.pasada
set 
    latitude =16.783425	,longitude=121.120624,segment_distance= 1257,speed =15,
    is_reversed_route=false,driver_route=2, segment=array['2704','2703A'],
    time=now()::timestamp
where driver ='00b4d952-80b7-42a4-93b6-4f65b6949593'::uuid;

prepare two_result as 
    select drv, vhc, spd  
    from  q_drivers(16.652538,121.216915,'Solano');
select results_eq(
  'two_result',
  $$VALUES ('Janifer','Unknown',15::smallint),('Alvera','Unknown',15::smallint)$$
);
update public.pasada
set 
    latitude =null,longitude=null,segment_distance= null,
    is_reversed_route=null,driver_route=null, segment=null,
    time=null,speed =null
;


--6 drivers, 5 must be shown
update public.pasada
set 
    latitude =16.911553,longitude=121.060724,segment_distance= 15,speed =15,
    is_reversed_route=false,driver_route=4, segment=array['2701','2704'],
    time=now()::timestamp
where driver ='004064d7-1f03-4ac4-9f01-17332dce1b0b'::uuid;

update public.pasada
set 
    latitude =16.902499,longitude=121.053332,segment_distance= 2304,speed =15,
    is_reversed_route=false,driver_route=4, segment=array['2701','2704'],
    time=now()::timestamp
where driver ='00b4d952-80b7-42a4-93b6-4f65b6949593'::uuid;

update public.pasada
set 
    latitude =16.902499,longitude=121.053332,segment_distance= 15,speed =15,
    is_reversed_route=false,driver_route=4, segment=array['2701','2704'],
    time=now()::timestamp
where driver ='00c2bd15-ea3f-40fc-860e-c6524ff4ed00'::uuid;

update public.pasada
set 
    latitude =16.895005,longitude=121.058449,segment_distance= 3942,speed =15,
    is_reversed_route=false,driver_route=4, segment=array['2701','2704'],
    time=now()::timestamp
where driver ='01150444-8b0d-4d69-bb45-3ed9b7c402ea'::uuid;

update public.pasada
set 
    latitude =16.886394,longitude=121.059343,segment_distance= 5051,speed =15,
    is_reversed_route=false,driver_route=4, segment=array['2701','2704'],
    time=now()::timestamp
where driver ='014e2f62-d756-4652-8201-118cfaacd5ea'::uuid;

update public.pasada
set 
    latitude =16.843579,longitude=121.090399,segment_distance= 15624,speed =15,
    is_reversed_route=false,driver_route=4, segment=array['2701','2704'],
    time=now()::timestamp
where driver ='0154bad3-1a36-4215-9d8c-a85dcee40c45'::uuid;

prepare five_result as 
    select drv , vhc, spd , eta  
    from  q_drivers(16.852971,121.075162,'Lagawe');
select results_eq(
  'five_result',
  $$VALUES 
    ('Hephzibah','Unknown',15::smallint,29),('Ianthe','Unknown',15::smallint,34),
    ('Janifer','Unknown',15::smallint,40),('Alvera','Unknown',15::smallint,49),
    ('Daniella','Unknown',15::smallint,49)
  $$
);
update public.pasada
set 
    latitude =null,longitude=null,segment_distance= null,
    is_reversed_route=null,driver_route=null, segment=null,
    time=null,speed =null
;


--must not show short trip than user destination
update public.pasada
set 
    latitude =16.902499	,longitude=121.053332,segment_distance= 2304,speed =15,
    is_reversed_route=false,driver_route=3, segment=array['2701','2704'],
    time=now()::timestamp
where driver ='004064d7-1f03-4ac4-9f01-17332dce1b0b'::uuid;

update public.pasada
set 
    latitude =16.902499	,longitude=121.053332,segment_distance= 2304,speed =15,
    is_reversed_route=false,driver_route=4, segment=array['2701','2704'],
    time=now()::timestamp
where driver ='00b4d952-80b7-42a4-93b6-4f65b6949593'::uuid;

prepare one_result_short as 
    select drv, vhc, spd  
    from  q_drivers(16.652538,121.216915,'Solano');
select results_eq(
  'one_result_short',
  $$VALUES ('Alvera','Unknown',15::smallint)$$
);


--user impersonation returns one
set role postgres;
update public.pasada
set 
    latitude =null,longitude=null,segment_distance= null,
    is_reversed_route=null,driver_route=null, segment=null,
    time=null,speed =null
;
update public.pasada
set 
    latitude =16.902499	,longitude=121.053332,segment_distance= 15,speed =1,
    is_reversed_route=false,driver_route=3, segment=array['2701','2704'],
    time=now()::timestamp
where driver ='00b4d952-80b7-42a4-93b6-4f65b6949593'::uuid;
update public.profile
set daily_credits=1, subscription=now()+ interval '15 days'
where id ='e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid;

--settings for timetamp,exp and iat hard coded to 2060
set role authenticated;
select set_config('role', 'authenticated', true),
set_config('request.jwt.claims', 
    '{"aal":"aal1","amr":[{"method":"password","timestamp":2840570787}],"app_metadata":{"provider":"email","providers":["email"]},"aud":"authenticated","email":"galoAug00@gmail.com","exp":2840574387,"iat":2840570787,"iss":"https://default.supabase.co/auth/v1","phone":null,"role":"authenticated","session_id":"8a2787e7-ae95-435a-948f-b96543b4681b","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","user_metadata":{"ext":"","mun":"Tuba","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","bday":"2000-08-18 00:00:00000000+00","brgy":"Camp 4","prov":"Benguet","email":"galoAug00@gmail.com","phone":"09582808115","f_name":"Terrijo","l_name":"Galo","street":"165 J. B. Miguel Street","is_male":false,"username":"Terrijo","email_verified":false,"phone_verified":false},"is_anonymous":false}', true),
set_config('request.method', 'POST', true),
set_config('request.path', '/impersonation-example-request-path', true),
set_config('request.headers', '{"accept": "*/*"}', true);
select 1 as "ROLE_IMPERSONATION_NO_RESULTS";

prepare userfake as 
    select drv, vhc, spd  
    from  q_drivers(16.843579,121.090399,'Solano');
select results_eq(
  'userfake',
  $$VALUES ('Janifer','Unknown',1::smallint)$$
);


--user impersonation returns one, zero daily credit, lastquery yesterday
set role postgres;
update public.pasada
set 
    latitude =null,longitude=null,segment_distance= null,
    is_reversed_route=null,driver_route=null, segment=null,
    time=null,speed =null
;
update public.pasada
set 
    latitude =16.902499	,longitude=121.053332,segment_distance= 15,speed =1,
    is_reversed_route=false,driver_route=3, segment=array['2701','2704'],
    time=now()::timestamp
where driver ='00b4d952-80b7-42a4-93b6-4f65b6949593'::uuid;
update public.profile
set daily_credits=0, subscription=now()+ interval '15 days',last_query=now()-interval '1 days'
where id ='e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid;

--settings for timetamp,exp and iat hard coded to 2060
set role authenticated;
select set_config('role', 'authenticated', true),
set_config('request.jwt.claims', 
    '{"aal":"aal1","amr":[{"method":"password","timestamp":2840570787}],"app_metadata":{"provider":"email","providers":["email"]},"aud":"authenticated","email":"galoAug00@gmail.com","exp":2840574387,"iat":2840570787,"iss":"https://default.supabase.co/auth/v1","phone":null,"role":"authenticated","session_id":"8a2787e7-ae95-435a-948f-b96543b4681b","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","user_metadata":{"ext":"","mun":"Tuba","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","bday":"2000-08-18 00:00:00000000+00","brgy":"Camp 4","prov":"Benguet","email":"galoAug00@gmail.com","phone":"09582808115","f_name":"Terrijo","l_name":"Galo","street":"165 J. B. Miguel Street","is_male":false,"username":"Terrijo","email_verified":false,"phone_verified":false},"is_anonymous":false}', true),
set_config('request.method', 'POST', true),
set_config('request.path', '/impersonation-example-request-path', true),
set_config('request.headers', '{"accept": "*/*"}', true);
select 1 as "ROLE_IMPERSONATION_NO_RESULTS";

prepare userfakeYesterdayLast as 
    select drv, vhc, spd  
    from  q_drivers(16.843579,121.090399,'Solano');
select results_eq(
  'userfakeYesterdayLast',
  $$VALUES ('Janifer','Unknown',1::smallint)$$
);


--user impersonation returns none
set role postgres;
update public.pasada
set 
    latitude =null,longitude=null,segment_distance= null,
    is_reversed_route=null,driver_route=null, segment=null,
    time=null,speed =null
;
update public.pasada
set 
    latitude =16.902499	,longitude=121.053332,segment_distance= 15,speed =1,
    is_reversed_route=false,driver_route=3, segment=array['2701','2704'],
    time=now()::timestamp
where driver ='00b4d952-80b7-42a4-93b6-4f65b6949593'::uuid;
update public.profile
set daily_credits=0, subscription=now()+ interval '15 days'
where id ='e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid;

--settings for timetamp,exp and iat hard coded to 2060
set role authenticated;
select set_config('role', 'authenticated', true),
set_config('request.jwt.claims', 
    '{"aal":"aal1","amr":[{"method":"password","timestamp":2840570787}],"app_metadata":{"provider":"email","providers":["email"]},"aud":"authenticated","email":"galoAug00@gmail.com","exp":2840574387,"iat":2840570787,"iss":"https://default.supabase.co/auth/v1","phone":null,"role":"authenticated","session_id":"8a2787e7-ae95-435a-948f-b96543b4681b","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","user_metadata":{"ext":"","mun":"Tuba","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","bday":"2000-08-18 00:00:00000000+00","brgy":"Camp 4","prov":"Benguet","email":"galoAug00@gmail.com","phone":"09582808115","f_name":"Terrijo","l_name":"Galo","street":"165 J. B. Miguel Street","is_male":false,"username":"Terrijo","email_verified":false,"phone_verified":false},"is_anonymous":false}', true),
set_config('request.method', 'POST', true),
set_config('request.path', '/impersonation-example-request-path', true),
set_config('request.headers', '{"accept": "*/*"}', true);
select 1 as "ROLE_IMPERSONATION_NO_RESULTS";

prepare userfakeFail as 
    select drv, vhc, spd  
    from  q_drivers(16.843579,121.090399,'Solano');
select throws_ok(
  'userfakeFail',
  'code:2'
);

SELECT * FROM finish();
ROLLBACK;