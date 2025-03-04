BEGIN;
SELECT plan(10);

select function_returns('monthly_agg','boolean');
select is_definer('monthly_agg');
-- set role postgres;
select is(monthly_agg(),true);
select volatility_is('monthly_agg',array[''],'volatile');
select function_privs_are('monthly_agg',array[''],'anon',null);
select function_privs_are('monthly_agg',array[''],'authenticated',null);
update public.pasada
set counter=1200
where driver = '5b996de3-b0e1-4c0f-bcbb-7125b21dcee3'::uuid;
update public.pasada
set counter=15
where driver = 'd61f502b-79d4-48c2-98a6-3b4c9cd980fc'::uuid;
select monthly_agg();
prepare agg_func_check as 
    select counter 
    from public.pasada 
    where driver='5b996de3-b0e1-4c0f-bcbb-7125b21dcee3'::uuid;
prepare insert_check as 
    select counter 
    from public.monthly_report 
    where driver_id='5b996de3-b0e1-4c0f-bcbb-7125b21dcee3'::uuid;
prepare agg_func_check2 as 
    select counter 
    from public.pasada 
    where driver='d61f502b-79d4-48c2-98a6-3b4c9cd980fc'::uuid;
prepare insert_check2 as 
    select counter 
    from public.monthly_report 
    where driver_id='d61f502b-79d4-48c2-98a6-3b4c9cd980fc'::uuid;
select results_eq('agg_func_check',array[0::bigint]);
select results_eq('insert_check',array[1200::bigint]);
select results_eq('agg_func_check2',array[0::bigint]);
select results_eq('insert_check2',array[15::bigint]);
SELECT * FROM finish();
ROLLBACK;
