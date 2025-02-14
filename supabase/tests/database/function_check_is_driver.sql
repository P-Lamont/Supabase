BEGIN;
SELECT plan(2);

select function_returns('check_is_driver','boolean');
select isnt_definer('check_is_driver');
-- set role postgres;
-- select is(check_is_driver(),false,'given postgres role, function must return false');
-- set role authenticated;
-- select is(check_is_driver(),true,'given auth role, function must return true');
-- select is(check_is_driver(),false,'given auth role, function must return false');
-- set role anon;
-- select is(check_is_driver(),false,'given anon role, function must return false');
SELECT * FROM finish();
ROLLBACK;