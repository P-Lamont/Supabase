BEGIN;
SELECT plan(2);

select function_returns('check_is_driver','boolean');
select isnt_definer('check_is_driver');

SELECT * FROM finish();
ROLLBACK;