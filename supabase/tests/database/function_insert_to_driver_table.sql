BEGIN;
SELECT plan(2);

select function_returns('insert_to_driver_table','trigger');
select isnt_definer('insert_to_driver_table');

SELECT * FROM finish();
ROLLBACK;