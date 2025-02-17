BEGIN;
SELECT plan(5);

select function_returns('insert_to_driver_table','trigger');
select isnt_definer('insert_to_driver_table');
select trigger_is('profile','add_driver_on_profile_update','insert_to_driver_table');
select function_privs_are('insert_to_driver_table',array[''],'anon',null);
select function_privs_are('insert_to_driver_table',array[''],'authenticated',null);
SELECT * FROM finish();
ROLLBACK;