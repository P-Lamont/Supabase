BEGIN;
SELECT plan(3);

select function_returns('insert_to_driver_table','trigger');
select isnt_definer('insert_to_driver_table');
select trigger_is('profile','add_driver_on_profile_update','insert_to_driver_table');
SELECT * FROM finish();
ROLLBACK;