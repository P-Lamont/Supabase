BEGIN;
SELECT plan(6);

select function_returns('insert_to_driver_table','trigger');
select isnt_definer('insert_to_driver_table');
select trigger_is('profile','add_driver_on_profile_update','insert_to_driver_table');
select function_privs_are('insert_to_driver_table',array[''],'anon',null);
select function_privs_are('insert_to_driver_table',array[''],'authenticated',null);

update  public.profile 
set role = 3
where id ='01a9e11c-7622-4d6a-aadb-afce525dc18d'::uuid;
prepare validate as 
    select * 
    from public.pasada 
    where driver='01a9e11c-7622-4d6a-aadb-afce525dc18d'::uuid;
select isnt_empty('validate');

SELECT * FROM finish();
ROLLBACK;