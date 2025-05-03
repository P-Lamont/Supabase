begin;
select plan (59);
select function_returns('update_profile',array['text'],'boolean');
select is_definer('update_profile');
select function_privs_are('update_profile',array['text'],'anon',null);
select volatility_is('update_profile',array['text'],'volatile');
select function_privs_are('update_profile',array['text'],'authenticated',array['EXECUTE']);
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
    bday='26d84676-d603-4923-94e8-65d682e1e4e6'::uuid,
    username ='Terijo'
where id = 'e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid;
set role authenticated;
select set_config('role', 'authenticated', true),
set_config('request.jwt.claims', 
    '{"aal":"aal1","amr":[{"method":"password","timestamp":2840570787}],"app_metadata":{"provider":"email","providers":["email"]},"aud":"authenticated","email":"galoAug00@gmail.com","exp":2840574387,"iat":2840570787,"iss":"https://default.supabase.co/auth/v1","phone":null,"role":"authenticated","session_id":"8a2787e7-ae95-435a-948f-b96543b4681b","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","user_metadata":{"ext":"","mun":"Tuba","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","bday":"2000-08-18 00:00:00000000+00","brgy":"Camp 4","prov":"Benguet","email":"galoAug00@gmail.com","phone":"09582808115","f_name":"Terrijo","l_name":"Galo","street":"165 J. B. Miguel Street","is_male":false,"username":"Terrijo","email_verified":false,"phone_verified":false},"is_anonymous":false}', true),
set_config('request.method', 'POST', true),
set_config('request.path', '/impersonation-example-request-path', true),
set_config('request.headers', '{"accept": "*/*"}', true);
select 1 as "ROLE_IMPERSONATION_NO_RESULTS";
prepare one_result as select update_profile('{"nme":["DI","De"]}'); 
select results_eq('one_result',array[true]);

select is(
    public.view_profile(),
    row(
        'De, Di'::text,'165 J. B. Miguel Street'::text,
        'Camp 4, Tuba, Benguet'::text,'09582808115'::text,
        '2000-08-18 00:00:00000000+00'::text,'false'::text,'Terijo'::text
    )
);
reset role;
prepare verify_update as 
    select updated_at 
    from public.profile 
    where id ='e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid; 
select set_ne('verify_update',array[null::timestamp with time zone]);
update public.profile
set updated_at=null
where id = 'e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid;
set role authenticated;
select set_config('role', 'authenticated', true),
set_config('request.jwt.claims', 
    '{"aal":"aal1","amr":[{"method":"password","timestamp":2840570787}],"app_metadata":{"provider":"email","providers":["email"]},"aud":"authenticated","email":"galoAug00@gmail.com","exp":2840574387,"iat":2840570787,"iss":"https://default.supabase.co/auth/v1","phone":null,"role":"authenticated","session_id":"8a2787e7-ae95-435a-948f-b96543b4681b","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","user_metadata":{"ext":"","mun":"Tuba","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","bday":"2000-08-18 00:00:00000000+00","brgy":"Camp 4","prov":"Benguet","email":"galoAug00@gmail.com","phone":"09582808115","f_name":"Terrijo","l_name":"Galo","street":"165 J. B. Miguel Street","is_male":false,"username":"Terrijo","email_verified":false,"phone_verified":false},"is_anonymous":false}', true),
set_config('request.method', 'POST', true),
set_config('request.path', '/impersonation-example-request-path', true),
set_config('request.headers', '{"accept": "*/*"}', true);
select 1 as "ROLE_IMPERSONATION_NO_RESULTS";
prepare name_err as select update_profile('{"nme":["","d"]}'); 
select throws_ok(
    'name_err',
    'Invalid name'
);
prepare name_err2 as select update_profile('{"nme":["D",""]}'); 
select throws_ok(
    'name_err2',
    'Invalid name'
);
prepare name_err3 as select update_profile('{"nme":[null,"d"]}'); 
select throws_ok(
    'name_err3',
    'Invalid name'
);
prepare name_err4 as select update_profile('{"nme":["D",null]}'); 
select throws_ok(
    'name_err4',
    'Invalid name'
);
prepare name_err5 as select update_profile('{"nme":["D"]}'); 
select throws_ok(
    'name_err5',
    'Invalid name'
);
prepare code_err as select update_profile('{"ne":["D","d"]}'); 
select throws_ok(
    'code_err',
    'Invalid code'
);
prepare ads_err as select update_profile('{"st":"B","ads":["","Banaue","Ifugao"]}'); 
select throws_ok(
    'ads_err',
    'Invalid address'
);
prepare ads_err2 as select update_profile('{"st":"B","ads":["Balawis","","Ifugao"]}'); 
select throws_ok(
    'ads_err2',
    'Invalid address'
);
prepare ads_err3 as select update_profile('{"st":"B","ads":["Balawis","Banaue",""]}'); 
select throws_ok(
    'ads_err3',
    'Invalid address'
);
prepare ads_err4 as select update_profile('{"st":"B","ads":["B",null,"Banaue","Ifugao"]}'); 
select throws_ok(
    'ads_err4',
    'Invalid address'
);
prepare ads_err5 as select update_profile('{"st":"B","ads":["B","Balawis",null,"Ifugao"]}'); 
select throws_ok(
    'ads_err5',
    'Invalid address'
);
prepare ads_err6 as select update_profile('{"st":"B","ads":["B","Balawis","Banaue",null]}'); 
select throws_ok(
    'ads_err6',
    'Invalid address'
);
prepare ads_err7 as select update_profile('{"st":"B","ads":["B","Balawi","Banaue","Ifugao"]}'); 
select throws_ok(
    'ads_err7',
    'Invalid address'
);
prepare ads_err8 as select update_profile('{"st":"B","ads":["Balawi","Banaue","Ifugao"]}'); 
select throws_ok(
    'ads_err8',
    'Invalid address'
);
reset role;
update public.profile
set updated_at=null
where id = 'e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid;
set role authenticated;
select set_config('role', 'authenticated', true),
set_config('request.jwt.claims', 
    '{"aal":"aal1","amr":[{"method":"password","timestamp":2840570787}],"app_metadata":{"provider":"email","providers":["email"]},"aud":"authenticated","email":"galoAug00@gmail.com","exp":2840574387,"iat":2840570787,"iss":"https://default.supabase.co/auth/v1","phone":null,"role":"authenticated","session_id":"8a2787e7-ae95-435a-948f-b96543b4681b","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","user_metadata":{"ext":"","mun":"Tuba","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","bday":"2000-08-18 00:00:00000000+00","brgy":"Camp 4","prov":"Benguet","email":"galoAug00@gmail.com","phone":"09582808115","f_name":"Terrijo","l_name":"Galo","street":"165 J. B. Miguel Street","is_male":false,"username":"Terrijo","email_verified":false,"phone_verified":false},"is_anonymous":false}', true),
set_config('request.method', 'POST', true),
set_config('request.path', '/impersonation-example-request-path', true),
set_config('request.headers', '{"accept": "*/*"}', true);
select 1 as "ROLE_IMPERSONATION_NO_RESULTS";
prepare one_result2 as select update_profile('{"st":"B","ads":["Balawis","Banaue","Ifugao"]}'); 
select results_eq('one_result2',array[true]);
reset role;
update public.profile
set updated_at=null
where id = 'e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid;
set role authenticated;
select set_config('role', 'authenticated', true),
set_config('request.jwt.claims', 
    '{"aal":"aal1","amr":[{"method":"password","timestamp":2840570787}],"app_metadata":{"provider":"email","providers":["email"]},"aud":"authenticated","email":"galoAug00@gmail.com","exp":2840574387,"iat":2840570787,"iss":"https://default.supabase.co/auth/v1","phone":null,"role":"authenticated","session_id":"8a2787e7-ae95-435a-948f-b96543b4681b","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","user_metadata":{"ext":"","mun":"Tuba","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","bday":"2000-08-18 00:00:00000000+00","brgy":"Camp 4","prov":"Benguet","email":"galoAug00@gmail.com","phone":"09582808115","f_name":"Terrijo","l_name":"Galo","street":"165 J. B. Miguel Street","is_male":false,"username":"Terrijo","email_verified":false,"phone_verified":false},"is_anonymous":false}', true),
set_config('request.method', 'POST', true),
set_config('request.path', '/impersonation-example-request-path', true),
set_config('request.headers', '{"accept": "*/*"}', true);
select 1 as "ROLE_IMPERSONATION_NO_RESULTS";
prepare one_result3 as select update_profile('{"st":"","ads":["Balawis","Banaue","Ifugao"]}'); 
select results_eq('one_result3',array[true]);
select is(
    public.view_profile(),
    row(
        'De, Di'::text,''::text,
        'Balawis, Banaue, Ifugao'::text,'09582808115'::text,
        '2000-08-18 00:00:00000000+00'::text,'false'::text,'Terijo'::text
    )
);
reset role;
update public.profile
set updated_at=null
where id = 'e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid;
set role authenticated;
select set_config('role', 'authenticated', true),
set_config('request.jwt.claims', 
    '{"aal":"aal1","amr":[{"method":"password","timestamp":2840570787}],"app_metadata":{"provider":"email","providers":["email"]},"aud":"authenticated","email":"galoAug00@gmail.com","exp":2840574387,"iat":2840570787,"iss":"https://default.supabase.co/auth/v1","phone":null,"role":"authenticated","session_id":"8a2787e7-ae95-435a-948f-b96543b4681b","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","user_metadata":{"ext":"","mun":"Tuba","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","bday":"2000-08-18 00:00:00000000+00","brgy":"Camp 4","prov":"Benguet","email":"galoAug00@gmail.com","phone":"09582808115","f_name":"Terrijo","l_name":"Galo","street":"165 J. B. Miguel Street","is_male":false,"username":"Terrijo","email_verified":false,"phone_verified":false},"is_anonymous":false}', true),
set_config('request.method', 'POST', true),
set_config('request.path', '/impersonation-example-request-path', true),
set_config('request.headers', '{"accept": "*/*"}', true);
select 1 as "ROLE_IMPERSONATION_NO_RESULTS";
prepare one_result4 as select update_profile('{"st":"","ads":["Poitan","Banaue","Ifugao"]}'); 
select results_eq('one_result4',array[true]);

select is(
    public.view_profile(),
    row(
        'De, Di'::text,''::text,
        'Poitan, Banaue, Ifugao'::text,'09582808115'::text,
        '2000-08-18 00:00:00000000+00'::text,'false'::text,'Terijo'::text
    )
);
reset role;
update public.profile
set updated_at=null
where id = 'e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid;
set role authenticated;
select set_config('role', 'authenticated', true),
set_config('request.jwt.claims', 
    '{"aal":"aal1","amr":[{"method":"password","timestamp":2840570787}],"app_metadata":{"provider":"email","providers":["email"]},"aud":"authenticated","email":"galoAug00@gmail.com","exp":2840574387,"iat":2840570787,"iss":"https://default.supabase.co/auth/v1","phone":null,"role":"authenticated","session_id":"8a2787e7-ae95-435a-948f-b96543b4681b","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","user_metadata":{"ext":"","mun":"Tuba","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","bday":"2000-08-18 00:00:00000000+00","brgy":"Camp 4","prov":"Benguet","email":"galoAug00@gmail.com","phone":"09582808115","f_name":"Terrijo","l_name":"Galo","street":"165 J. B. Miguel Street","is_male":false,"username":"Terrijo","email_verified":false,"phone_verified":false},"is_anonymous":false}', true),
set_config('request.method', 'POST', true),
set_config('request.path', '/impersonation-example-request-path', true),
set_config('request.headers', '{"accept": "*/*"}', true);
select 1 as "ROLE_IMPERSONATION_NO_RESULTS";
prepare phn_err as select update_profile('{"phn":"2"}'); 
select throws_ok(
    'phn_err',
    'Invalid phone'
);
prepare phn_err2 as select update_profile('{"phn":["09123456789"]}'); 
select throws_ok(
    'phn_err2',
    'Invalid phone'
);
prepare phn_err3 as select update_profile('{"phn":"08123456789"}'); 
select throws_ok(
    'phn_err3',
    'Invalid phone'
);
prepare phn_err4 as select update_profile('{"phn":""}'); 
select throws_ok(
    'phn_err4',
    'Invalid phone'
);
prepare phn_err5 as select update_profile('{"phn":null}'); 
select throws_ok(
    'phn_err5',
    'Invalid phone'
);
prepare phn_err6 as select update_profile('{"phn":"0912345678a"}'); 
select throws_ok(
    'phn_err6',
    'Invalid phone'
);
prepare phn_ok as select update_profile('{"phn":"09123456789"}');
select results_eq('phn_ok',array[true]);
select is(
    public.view_profile(),
    row(
        'De, Di'::text,''::text,
        'Poitan, Banaue, Ifugao'::text,'09123456789'::text,
        '2000-08-18 00:00:00000000+00'::text,'false'::text,'Terijo'::text
    )
);
reset role;
update public.profile
set updated_at=null
where id = 'e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid;
set role authenticated;
select set_config('role', 'authenticated', true),
set_config('request.jwt.claims', 
    '{"aal":"aal1","amr":[{"method":"password","timestamp":2840570787}],"app_metadata":{"provider":"email","providers":["email"]},"aud":"authenticated","email":"galoAug00@gmail.com","exp":2840574387,"iat":2840570787,"iss":"https://default.supabase.co/auth/v1","phone":null,"role":"authenticated","session_id":"8a2787e7-ae95-435a-948f-b96543b4681b","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","user_metadata":{"ext":"","mun":"Tuba","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","bday":"2000-08-18 00:00:00000000+00","brgy":"Camp 4","prov":"Benguet","email":"galoAug00@gmail.com","phone":"09582808115","f_name":"Terrijo","l_name":"Galo","street":"165 J. B. Miguel Street","is_male":false,"username":"Terrijo","email_verified":false,"phone_verified":false},"is_anonymous":false}', true),
set_config('request.method', 'POST', true),
set_config('request.path', '/impersonation-example-request-path', true),
set_config('request.headers', '{"accept": "*/*"}', true);
select 1 as "ROLE_IMPERSONATION_NO_RESULTS";
prepare bday_err as select update_profile('{"bday":"2"}'); 
select throws_ok(
    'bday_err',
    'Invalid birthday'
);
prepare bday_err2 as select update_profile('{"bday":["B"]}'); 
select throws_ok(
    'bday_err2',
    'Invalid birthday'
);
prepare bday_err3 as select update_profile('{"bday":"1994/01/0q"}'); 
select throws_ok(
    'bday_err3',
    'Invalid birthday'
);
prepare bday_err4 as select update_profile('{"bday":""}'); 
select throws_ok(
    'bday_err4',
    'Invalid birthday'
);
prepare bday_err5 as select update_profile('{"bday":null}'); 
select throws_ok(
    'bday_err5',
    'Invalid birthday'
);
prepare bday_err6 as select update_profile('{"bday":["1990/12/12"]}'); 
select throws_ok(
    'bday_err6',
    'Invalid birthday'
);
prepare bday_err7 as select update_profile('{"bday":"2024/12/12"}'); 
select throws_ok(
    'bday_err7',
    'Age under 10'
);
prepare bday_err8 as select update_profile('{"bday":"1924/12/12"}'); 
select throws_ok(
    'bday_err8',
    'Age over 80'
);
prepare bday_err9 as select update_profile('{"bday":"1994/13/12"}'); 
select throws_ok(
    'bday_err9',
    'Invalid birthday'
);
prepare bday_ok as select update_profile('{"bday":"2010/12/12"}');
select results_eq('bday_ok',array[true]);
select is(
    public.view_profile(),
    row(
        'De, Di'::text,''::text,
        'Poitan, Banaue, Ifugao'::text,'09123456789'::text,
        '2010/12/12'::text,'false'::text,'Terijo'::text
    )
);
reset role;
update public.profile
set updated_at=null
where id = 'e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid;
set role authenticated;
select set_config('role', 'authenticated', true),
set_config('request.jwt.claims', 
    '{"aal":"aal1","amr":[{"method":"password","timestamp":2840570787}],"app_metadata":{"provider":"email","providers":["email"]},"aud":"authenticated","email":"galoAug00@gmail.com","exp":2840574387,"iat":2840570787,"iss":"https://default.supabase.co/auth/v1","phone":null,"role":"authenticated","session_id":"8a2787e7-ae95-435a-948f-b96543b4681b","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","user_metadata":{"ext":"","mun":"Tuba","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","bday":"2000-08-18 00:00:00000000+00","brgy":"Camp 4","prov":"Benguet","email":"galoAug00@gmail.com","phone":"09582808115","f_name":"Terrijo","l_name":"Galo","street":"165 J. B. Miguel Street","is_male":false,"username":"Terrijo","email_verified":false,"phone_verified":false},"is_anonymous":false}', true),
set_config('request.method', 'POST', true),
set_config('request.path', '/impersonation-example-request-path', true),
set_config('request.headers', '{"accept": "*/*"}', true);
select 1 as "ROLE_IMPERSONATION_NO_RESULTS";
prepare gdr_err as select update_profile('{"gdr":"f"}'); 
select throws_ok(
    'gdr_err',
    'Invalid gender'
);
prepare gdr_ok as select update_profile('{"gdr":"true"}'); 
select results_eq('gdr_ok',array[true]);
select is(
    public.view_profile(),
    row(
        'De, Di'::text,''::text,
        'Poitan, Banaue, Ifugao'::text,'09123456789'::text,
        '2010/12/12'::text,'true'::text,'Terijo'::text
    )
);
reset role;
update public.profile
set updated_at=null
where id = 'e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid;
set role authenticated;
select set_config('role', 'authenticated', true),
set_config('request.jwt.claims', 
    '{"aal":"aal1","amr":[{"method":"password","timestamp":2840570787}],"app_metadata":{"provider":"email","providers":["email"]},"aud":"authenticated","email":"galoAug00@gmail.com","exp":2840574387,"iat":2840570787,"iss":"https://default.supabase.co/auth/v1","phone":null,"role":"authenticated","session_id":"8a2787e7-ae95-435a-948f-b96543b4681b","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","user_metadata":{"ext":"","mun":"Tuba","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","bday":"2000-08-18 00:00:00000000+00","brgy":"Camp 4","prov":"Benguet","email":"galoAug00@gmail.com","phone":"09582808115","f_name":"Terrijo","l_name":"Galo","street":"165 J. B. Miguel Street","is_male":false,"username":"Terrijo","email_verified":false,"phone_verified":false},"is_anonymous":false}', true),
set_config('request.method', 'POST', true),
set_config('request.path', '/impersonation-example-request-path', true),
set_config('request.headers', '{"accept": "*/*"}', true);
select 1 as "ROLE_IMPERSONATION_NO_RESULTS";
prepare uname_err as select update_profile('{"usr":"f"}'); 
select throws_ok(
    'uname_err',
    'Invalid username'
);
prepare uname_err1 as select update_profile('{"usr":"fffff*"}'); 
select throws_ok(
    'uname_err1',
    'Invalid username'
);
prepare uname_err2 as select update_profile('{"usr":"fffff "}'); 
select throws_ok(
    'uname_err2',
    'Invalid username'
);
prepare uname_err3 as select update_profile('{"usr":"srtrd rst12341ar"}'); 
select throws_ok(
    'uname_err3',
    'Invalid username'
);
prepare uname_ok as select update_profile('{"usr":"fffff1"}'); 
select results_eq('uname_ok',array[true]);
select is(
    public.view_profile(),
    row(
        'De, Di'::text,''::text,
        'Poitan, Banaue, Ifugao'::text,'09123456789'::text,
        '2010/12/12'::text,'true'::text,'fffff1'::text
    )
);
reset role;
update public.profile
set updated_at=null
where id = 'e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid;
set role authenticated;
select set_config('role', 'authenticated', true),
set_config('request.jwt.claims', 
    '{"aal":"aal1","amr":[{"method":"password","timestamp":2840570787}],"app_metadata":{"provider":"email","providers":["email"]},"aud":"authenticated","email":"galoAug00@gmail.com","exp":2840574387,"iat":2840570787,"iss":"https://default.supabase.co/auth/v1","phone":null,"role":"authenticated","session_id":"8a2787e7-ae95-435a-948f-b96543b4681b","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","user_metadata":{"ext":"","mun":"Tuba","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","bday":"2000-08-18 00:00:00000000+00","brgy":"Camp 4","prov":"Benguet","email":"galoAug00@gmail.com","phone":"09582808115","f_name":"Terrijo","l_name":"Galo","street":"165 J. B. Miguel Street","is_male":false,"username":"Terrijo","email_verified":false,"phone_verified":false},"is_anonymous":false}', true),
set_config('request.method', 'POST', true),
set_config('request.path', '/impersonation-example-request-path', true),
set_config('request.headers', '{"accept": "*/*"}', true);
select 1 as "ROLE_IMPERSONATION_NO_RESULTS";
prepare combi_err as select update_profile('{"usr":"ffff1","gdr":"true"}'); 
select throws_ok(
    'combi_err',
    'Invalid username'
);
reset role;
update public.profile
set updated_at=current_timestamp-interval '1 hour'
where id = 'e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid;
set role authenticated;
select set_config('role', 'authenticated', true),
set_config('request.jwt.claims', 
    '{"aal":"aal1","amr":[{"method":"password","timestamp":2840570787}],"app_metadata":{"provider":"email","providers":["email"]},"aud":"authenticated","email":"galoAug00@gmail.com","exp":2840574387,"iat":2840570787,"iss":"https://default.supabase.co/auth/v1","phone":null,"role":"authenticated","session_id":"8a2787e7-ae95-435a-948f-b96543b4681b","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","user_metadata":{"ext":"","mun":"Tuba","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","bday":"2000-08-18 00:00:00000000+00","brgy":"Camp 4","prov":"Benguet","email":"galoAug00@gmail.com","phone":"09582808115","f_name":"Terrijo","l_name":"Galo","street":"165 J. B. Miguel Street","is_male":false,"username":"Terrijo","email_verified":false,"phone_verified":false},"is_anonymous":false}', true),
set_config('request.method', 'POST', true),
set_config('request.path', '/impersonation-example-request-path', true),
set_config('request.headers', '{"accept": "*/*"}', true);
select 1 as "ROLE_IMPERSONATION_NO_RESULTS";
prepare limit_err as select update_profile('{"usr":"ffff1","gdr":"true"}'); 
select throws_like(
    'limit_err',
    'Try after%'
);
reset role;
update public.profile
set updated_at=current_timestamp-interval '10 minutes'
where id = 'e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid;
set role authenticated;
select set_config('role', 'authenticated', true),
set_config('request.jwt.claims', 
    '{"aal":"aal1","amr":[{"method":"password","timestamp":2840570787}],"app_metadata":{"provider":"email","providers":["email"]},"aud":"authenticated","email":"galoAug00@gmail.com","exp":2840574387,"iat":2840570787,"iss":"https://default.supabase.co/auth/v1","phone":null,"role":"authenticated","session_id":"8a2787e7-ae95-435a-948f-b96543b4681b","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","user_metadata":{"ext":"","mun":"Tuba","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","bday":"2000-08-18 00:00:00000000+00","brgy":"Camp 4","prov":"Benguet","email":"galoAug00@gmail.com","phone":"09582808115","f_name":"Terrijo","l_name":"Galo","street":"165 J. B. Miguel Street","is_male":false,"username":"Terrijo","email_verified":false,"phone_verified":false},"is_anonymous":false}', true),
set_config('request.method', 'POST', true),
set_config('request.path', '/impersonation-example-request-path', true),
set_config('request.headers', '{"accept": "*/*"}', true);
select 1 as "ROLE_IMPERSONATION_NO_RESULTS";
prepare limit_ok as select update_profile('{"usr":"ffff1","gdr":"true"}'); 
select throws_ok(
    'limit_ok'
);
reset role;
update public.profile
set updated_at=current_timestamp-interval '91 days'
where id = 'e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid;
set role authenticated;
select set_config('role', 'authenticated', true),
set_config('request.jwt.claims', 
    '{"aal":"aal1","amr":[{"method":"password","timestamp":2840570787}],"app_metadata":{"provider":"email","providers":["email"]},"aud":"authenticated","email":"galoAug00@gmail.com","exp":2840574387,"iat":2840570787,"iss":"https://default.supabase.co/auth/v1","phone":null,"role":"authenticated","session_id":"8a2787e7-ae95-435a-948f-b96543b4681b","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","user_metadata":{"ext":"","mun":"Tuba","sub":"e7c20bff-c372-4384-aa6b-b8263c53f405","bday":"2000-08-18 00:00:00000000+00","brgy":"Camp 4","prov":"Benguet","email":"galoAug00@gmail.com","phone":"09582808115","f_name":"Terrijo","l_name":"Galo","street":"165 J. B. Miguel Street","is_male":false,"username":"Terrijo","email_verified":false,"phone_verified":false},"is_anonymous":false}', true),
set_config('request.method', 'POST', true),
set_config('request.path', '/impersonation-example-request-path', true),
set_config('request.headers', '{"accept": "*/*"}', true);
select 1 as "ROLE_IMPERSONATION_NO_RESULTS";
prepare limit_ok2 as select update_profile('{"usr":"ffff1","gdr":"true"}'); 
select throws_ok(
    'limit_ok2'
);
--  add gender and username update
SELECT * FROM finish();
ROLLBACK;