BEGIN;
SELECT plan(2);

select function_returns('check_is_admin','boolean');
select isnt_definer('check_is_admin');

SELECT * FROM finish();
ROLLBACK;