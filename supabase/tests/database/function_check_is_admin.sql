BEGIN;
SELECT plan(5);

select function_returns('check_is_admin','boolean');
select isnt_definer('check_is_admin');
set role postgres;
select is(check_is_admin(),true);
set role authenticated;
select is(check_is_admin(),false);
set role anon;
select is(check_is_admin(),false);
SELECT * FROM finish();
ROLLBACK;