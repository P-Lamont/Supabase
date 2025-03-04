begin;
select plan (10);
select function_returns('view_profile',array[''],'record');
select is_definer('view_profile');
select function_privs_are('view_profile',array[''],'anon',null);
select volatility_is('view_profile',array[''],'stable');
select function_privs_are('view_profile',array[''],'authenticated',array['EXECUTE']);

insert into vault.secrets(secret,id)
values
    ('Galo, Terrijo '::text,'c9a4ef99-97d9-406b-bc28-6bd218b5903c'::uuid),
    ('165 J. B. Miguel Street, 4444'::text,'c1e5bf6a-b7f2-4de4-84ae-09769346adee'::uuid),
    ('09582808115'::text,'a574a529-5cf9-49db-881c-264c9158c074'::uuid),
    ('2000-08-18 00:00:00000000+00'::text,'26d84676-d603-4923-94e8-65d682e1e4e6'::uuid);
update public.profile
set name='c9a4ef99-97d9-406b-bc28-6bd218b5903c'::uuid,
    address='c1e5bf6a-b7f2-4de4-84ae-09769346adee'::uuid,
    phone='a574a529-5cf9-49db-881c-264c9158c074'::uuid,
    bday='26d84676-d603-4923-94e8-65d682e1e4e6'::uuid
where id = 'e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid;
set role authenticated;
select set_config('role', 'authenticated', true),
set_config('request.jwt.claims', 
    '{"aal":"aal1","amr":[{"method":"password","timestamp":2840570787}],"app_metadata":{"provider":"email","providers":["email"]},"aud":"authenticated","email":"galoAug00@gmail.com","exp":2840574387,"iat":2840570787,"iss":"https://default.supabase.co/auth/v1","phone":null,"role":"authenticated","session_id":"8a2787e7-ae95-435a-948f-b96543b4681b","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","user_metadata":{"ext":"","mun":"Tuba","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","bday":"2000-08-18 00:00:00000000+00","brgy":"Camp 4","prov":"Benguet","email":"galoAug00@gmail.com","phone":"09582808115","f_name":"Terrijo","l_name":"Galo","street":"165 J. B. Miguel Street","is_male":false,"username":"Terrijo","email_verified":false,"phone_verified":false},"is_anonymous":false}', true),
set_config('request.method', 'POST', true),
set_config('request.path', '/impersonation-example-request-path', true),
set_config('request.headers', '{"accept": "*/*"}', true);
select 1 as "ROLE_IMPERSONATION_NO_RESULTS";
select is(
    public.view_profile(),
    row(
        'Galo, Terrijo '::text,'165 J. B. Miguel Street'::text,
        'Camp 4, Tuba, Benguet'::text,'09582808115'::text,
        '2000-08-18 00:00:00000000+00'::text
    )
);
reset role;

update public.profile
set name=null
where name='c9a4ef99-97d9-406b-bc28-6bd218b5903c'::uuid;

delete 
from vault.secrets
where id = 'c9a4ef99-97d9-406b-bc28-6bd218b5903c'::uuid;
set role authenticated;
select set_config('role', 'authenticated', true),
set_config('request.jwt.claims', 
    '{"aal":"aal1","amr":[{"method":"password","timestamp":2840570787}],"app_metadata":{"provider":"email","providers":["email"]},"aud":"authenticated","email":"galoAug00@gmail.com","exp":2840574387,"iat":2840570787,"iss":"https://default.supabase.co/auth/v1","phone":null,"role":"authenticated","session_id":"8a2787e7-ae95-435a-948f-b96543b4681b","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","user_metadata":{"ext":"","mun":"Tuba","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","bday":"2000-08-18 00:00:00000000+00","brgy":"Camp 4","prov":"Benguet","email":"galoAug00@gmail.com","phone":"09582808115","f_name":"Terrijo","l_name":"Galo","street":"165 J. B. Miguel Street","is_male":false,"username":"Terrijo","email_verified":false,"phone_verified":false},"is_anonymous":false}', true),
set_config('request.method', 'POST', true),
set_config('request.path', '/impersonation-example-request-path', true),
set_config('request.headers', '{"accept": "*/*"}', true);
select 1 as "ROLE_IMPERSONATION_NO_RESULTS";

select is(
    public.view_profile(),
    row(
        null::text,'165 J. B. Miguel Street'::text,
        'Camp 4, Tuba, Benguet'::text,'09582808115'::text,
        '2000-08-18 00:00:00000000+00'::text
    )
);

reset role;
update public.profile
set address=null
where address='c1e5bf6a-b7f2-4de4-84ae-09769346adee'::uuid;

delete 
from vault.secrets
where id = 'c1e5bf6a-b7f2-4de4-84ae-09769346adee'::uuid;

set role authenticated;
select set_config('role', 'authenticated', true),
set_config('request.jwt.claims', 
    '{"aal":"aal1","amr":[{"method":"password","timestamp":2840570787}],"app_metadata":{"provider":"email","providers":["email"]},"aud":"authenticated","email":"galoAug00@gmail.com","exp":2840574387,"iat":2840570787,"iss":"https://default.supabase.co/auth/v1","phone":null,"role":"authenticated","session_id":"8a2787e7-ae95-435a-948f-b96543b4681b","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","user_metadata":{"ext":"","mun":"Tuba","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","bday":"2000-08-18 00:00:00000000+00","brgy":"Camp 4","prov":"Benguet","email":"galoAug00@gmail.com","phone":"09582808115","f_name":"Terrijo","l_name":"Galo","street":"165 J. B. Miguel Street","is_male":false,"username":"Terrijo","email_verified":false,"phone_verified":false},"is_anonymous":false}', true),
set_config('request.method', 'POST', true),
set_config('request.path', '/impersonation-example-request-path', true),
set_config('request.headers', '{"accept": "*/*"}', true);
select 1 as "ROLE_IMPERSONATION_NO_RESULTS";

select is(
    public.view_profile(),
    row(
        null::text,null::text,
        ''::text,'09582808115'::text,
        '2000-08-18 00:00:00000000+00'::text
    )
);

reset role;
update public.profile
set phone=null
where phone='a574a529-5cf9-49db-881c-264c9158c074'::uuid;

delete 
from vault.secrets
where id = 'a574a529-5cf9-49db-881c-264c9158c074'::uuid;

set role authenticated;
select set_config('role', 'authenticated', true),
set_config('request.jwt.claims', 
    '{"aal":"aal1","amr":[{"method":"password","timestamp":2840570787}],"app_metadata":{"provider":"email","providers":["email"]},"aud":"authenticated","email":"galoAug00@gmail.com","exp":2840574387,"iat":2840570787,"iss":"https://default.supabase.co/auth/v1","phone":null,"role":"authenticated","session_id":"8a2787e7-ae95-435a-948f-b96543b4681b","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","user_metadata":{"ext":"","mun":"Tuba","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","bday":"2000-08-18 00:00:00000000+00","brgy":"Camp 4","prov":"Benguet","email":"galoAug00@gmail.com","phone":"09582808115","f_name":"Terrijo","l_name":"Galo","street":"165 J. B. Miguel Street","is_male":false,"username":"Terrijo","email_verified":false,"phone_verified":false},"is_anonymous":false}', true),
set_config('request.method', 'POST', true),
set_config('request.path', '/impersonation-example-request-path', true),
set_config('request.headers', '{"accept": "*/*"}', true);
select 1 as "ROLE_IMPERSONATION_NO_RESULTS";

select is(
    public.view_profile(),
    row(
        null::text,null::text,
        ''::text,null::text,
        '2000-08-18 00:00:00000000+00'::text
    )
);


reset role;
update public.profile
set bday=null
where bday='26d84676-d603-4923-94e8-65d682e1e4e6'::uuid;

delete 
from vault.secrets
where id = '26d84676-d603-4923-94e8-65d682e1e4e6'::uuid;

set role authenticated;
select set_config('role', 'authenticated', true),
set_config('request.jwt.claims', 
    '{"aal":"aal1","amr":[{"method":"password","timestamp":2840570787}],"app_metadata":{"provider":"email","providers":["email"]},"aud":"authenticated","email":"galoAug00@gmail.com","exp":2840574387,"iat":2840570787,"iss":"https://default.supabase.co/auth/v1","phone":null,"role":"authenticated","session_id":"8a2787e7-ae95-435a-948f-b96543b4681b","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","user_metadata":{"ext":"","mun":"Tuba","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","bday":"2000-08-18 00:00:00000000+00","brgy":"Camp 4","prov":"Benguet","email":"galoAug00@gmail.com","phone":"09582808115","f_name":"Terrijo","l_name":"Galo","street":"165 J. B. Miguel Street","is_male":false,"username":"Terrijo","email_verified":false,"phone_verified":false},"is_anonymous":false}', true),
set_config('request.method', 'POST', true),
set_config('request.path', '/impersonation-example-request-path', true),
set_config('request.headers', '{"accept": "*/*"}', true);
select 1 as "ROLE_IMPERSONATION_NO_RESULTS";

select is(
    public.view_profile(),
    row(
        null::text,null::text,
        ''::text,null::text,
        null::text
    )
);
SELECT * FROM finish();
ROLLBACK;