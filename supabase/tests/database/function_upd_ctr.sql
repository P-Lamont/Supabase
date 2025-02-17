BEGIN;
SELECT plan(4);

select function_returns('upd_ctr','boolean');
select is_definer('upd_ctr');
-- select is_strict('upd_ctr');
select function_privs_are('upd_ctr',array['uuid'],'anon',null);
select function_privs_are('upd_ctr',array['uuid'],'authenticated',null);
SELECT * FROM finish();
ROLLBACK;