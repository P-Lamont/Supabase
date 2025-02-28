BEGIN;
SELECT plan(13);

select function_returns(
    'update_sub',array['text','boolean','integer'],'boolean'
);
select is_definer('update_sub');
select is_strict('update_sub');
select function_privs_are(
    'update_sub',array['text','boolean','integer'],'anon',null
);
select volatility_is(
    'update_sub',array['text','boolean','integer'],'volatile'
);
select function_privs_are(
    'update_sub',array['text','boolean','integer'],'authenticated',null
);
prepare empty_error as 
    select update_sub('galoAug00@gmail.com',false,1);
select lives_ok('empty_error');
select results_eq('empty_error',array[true]);

select public.update_sub('galoAug00@gmail.com',false,1);


update public.profile
set subscription=null,daily_credits =null
where id ='e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid;

select update_sub('galoAug00@gmail.com',false,1);
prepare result_ok2 as
    select subscription,daily_credits,has_paid
    from public.profile
    where id ='e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid;
select results_eq(
    'result_ok2',
    $$values ((current_date + interval '1 day')::date,10::smallint,false)$$
);


update public.profile
set subscription=null,daily_credits =null
where id ='e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid;

select update_sub('galoAug00@gmail.com',true,1);
prepare result_ok3 as
    select subscription,daily_credits,has_paid
    from public.profile
    where id ='e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid;
select results_eq(
    'result_ok3',
    $$values ((current_date + interval '1 day')::date,10::smallint,true)$$
);

prepare user_not_exist as 
    select user_id
    from auth.identities
    where email =any(array['galoAug00111111@gmail.com','galoaug00111111@gmail.com']);

select is_empty('user_not_exist');
update public.profile
set subscription=null,daily_credits =null,has_paid=false
where id ='e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid;


select update_sub('galoAug00111111@gmail.com',true,1);
prepare result_ok4 as
    select subscription,daily_credits,has_paid
    from public.profile
    where id ='e7c20bff-c372-4384-aa6b-b8263c53f405'::uuid;
select results_eq(
    'result_ok4',
    $$values (null::date,null::smallint,false)$$
);

prepare results_ok5 as select update_sub('galoAug00111111@gmail.com',true,1);
select results_eq('results_ok5',array[false]);
SELECT * FROM finish();
ROLLBACK;