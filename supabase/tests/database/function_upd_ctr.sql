BEGIN;
SELECT plan(2);

select function_returns('upd_ctr','boolean');
select is_definer('upd_ctr');
-- select is_strict('upd_ctr');

SELECT * FROM finish();
ROLLBACK;