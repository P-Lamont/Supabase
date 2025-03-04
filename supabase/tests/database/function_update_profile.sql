begin;
select plan (44);
select function_returns('update_profile',array['text[]','text'],'boolean');
select is_definer('update_profile');
select function_privs_are('update_profile',array['text[]','text'],'anon',null);
select volatility_is('update_profile',array['text[]','text'],'volatile');
select function_privs_are('update_profile',array['text[]','text'],'authenticated',array['EXECUTE']);
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
prepare one_result as select update_profile(array['D','d'],'nme'); 
select results_eq('one_result',array[true]);

select is(
    public.view_profile(),
    row(
        'd, D'::text,'165 J. B. Miguel Street'::text,
        'Camp 4, Tuba, Benguet'::text,'09582808115'::text,
        '2000-08-18 00:00:00000000+00'::text
    )
);
prepare name_err as select update_profile(array['','d'],'nme'); 
select throws_ok(
    'name_err',
    'Invalid name'
);
prepare name_err2 as select update_profile(array['D',''],'nme'); 
select throws_ok(
    'name_err2',
    'Invalid name'
);
prepare name_err3 as select update_profile(array[null,'d'],'nme'); 
select throws_ok(
    'name_err3',
    'Invalid name'
);
prepare name_err4 as select update_profile(array['D',null],'nme'); 
select throws_ok(
    'name_err4',
    'Invalid name'
);
prepare name_err5 as select update_profile(array['D'],'nme'); 
select throws_ok(
    'name_err5',
    'Invalid name'
);
prepare code_err as select update_profile(array['D','d'],'ne'); 
select throws_ok(
    'code_err',
    'Invalid code'
);
prepare ads_err as select update_profile(array['B','','Banaue','Ifugao'],'ads'); 
select throws_ok(
    'ads_err',
    'Invalid address'
);
prepare ads_err2 as select update_profile(array['B','Balawis','','Ifugao'],'ads'); 
select throws_ok(
    'ads_err2',
    'Invalid address'
);
prepare ads_err3 as select update_profile(array['B','Balawis','Banaue',''],'ads'); 
select throws_ok(
    'ads_err3',
    'Invalid address'
);
prepare ads_err4 as select update_profile(array['B',null,'Banaue','Ifugao'],'ads'); 
select throws_ok(
    'ads_err4',
    'Invalid address'
);
prepare ads_err5 as select update_profile(array['B','Balawis',null,'Ifugao'],'ads'); 
select throws_ok(
    'ads_err5',
    'Invalid address'
);
prepare ads_err6 as select update_profile(array['B','Balawis','Banaue',null],'ads'); 
select throws_ok(
    'ads_err6',
    'Invalid address'
);
prepare ads_err7 as select update_profile(array['B','Balawi','Banaue','Ifugao'],'ads'); 
select throws_ok(
    'ads_err7',
    'Invalid address'
);
prepare ads_err8 as select update_profile(array['Balawi','Banaue','Ifugao'],'ads'); 
select throws_ok(
    'ads_err8',
    'Invalid address'
);
prepare one_result2 as select update_profile(array['','Balawis','Banaue','Ifugao'],'ads'); 
select results_eq('one_result2',array[true]);

select is(
    public.view_profile(),
    row(
        'd, D'::text,''::text,
        'Balawis, Banaue, Ifugao'::text,'09582808115'::text,
        '2000-08-18 00:00:00000000+00'::text
    )
);
prepare one_result3 as select update_profile(array[null,'Poitan','Banaue','Ifugao'],'ads'); 
select results_eq('one_result3',array[true]);

select is(
    public.view_profile(),
    row(
        'd, D'::text,''::text,
        'Poitan, Banaue, Ifugao'::text,'09582808115'::text,
        '2000-08-18 00:00:00000000+00'::text
    )
);
prepare phn_err as select update_profile(array['2'],'phn'); 
select throws_ok(
    'phn_err',
    'Invalid phone'
);
prepare phn_err2 as select update_profile(array['B',''],'phn'); 
select throws_ok(
    'phn_err2',
    'Invalid phone'
);
prepare phn_err3 as select update_profile(array['08123456789'],'phn'); 
select throws_ok(
    'phn_err3',
    'Invalid phone'
);
prepare phn_err4 as select update_profile(array[''],'phn'); 
select throws_ok(
    'phn_err4',
    'Invalid phone'
);
prepare phn_err5 as select update_profile(array[null],'phn'); 
select throws_ok(
    'phn_err5',
    'Invalid phone'
);
prepare phn_err6 as select update_profile(array['0912345678a'],'phn'); 
select throws_ok(
    'phn_err6',
    'Invalid phone'
);
prepare phn_ok as select update_profile(array['09123456789'],'phn');
select results_eq('phn_ok',array[true]);
select is(
    public.view_profile(),
    row(
        'd, D'::text,''::text,
        'Poitan, Banaue, Ifugao'::text,'09123456789'::text,
        '2000-08-18 00:00:00000000+00'::text
    )
);
prepare bday_err as select update_profile(array['2'],'bday'); 
select throws_ok(
    'bday_err',
    'Invalid birthday'
);
prepare bday_err2 as select update_profile(array['B',''],'bday'); 
select throws_ok(
    'bday_err2',
    'Invalid birthday'
);
prepare bday_err3 as select update_profile(array['1994/01/0q'],'bday'); 
select throws_ok(
    'bday_err3',
    'Invalid birthday'
);
prepare bday_err4 as select update_profile(array[''],'bday'); 
select throws_ok(
    'bday_err4',
    'Invalid birthday'
);
prepare bday_err5 as select update_profile(array[null],'bday'); 
select throws_ok(
    'bday_err5',
    'Invalid birthday'
);
prepare bday_err6 as select update_profile(array['1990/12/12',''],'bday'); 
select throws_ok(
    'bday_err6',
    'Invalid birthday'
);
prepare bday_err7 as select update_profile(array['2024/12/12'],'bday'); 
select throws_ok(
    'bday_err7',
    'Age under 10'
);
prepare bday_err8 as select update_profile(array['1924/12/12'],'bday'); 
select throws_ok(
    'bday_err8',
    'Age over 80'
);
prepare bday_err9 as select update_profile(array['1924/13/12'],'bday'); 
select throws_ok(
    'bday_err9',
    'Invalid birthday'
);
prepare bday_ok as select update_profile(array['2010/12/12'],'bday');
select results_eq('bday_ok',array[true]);
select is(
    public.view_profile(),
    row(
        'd, D'::text,''::text,
        'Poitan, Banaue, Ifugao'::text,'09123456789'::text,
        '2010/12/12'::text
    )
);
SELECT * FROM finish();
ROLLBACK;