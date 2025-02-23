BEGIN;
SELECT plan(4);
select function_returns('handle_new_user','trigger');
select function_privs_are('handle_new_user',array[''],'anon',null);
select function_privs_are('handle_new_user',array[''],'authenticated',null);
select is_definer('handle_new_user');
SELECT * FROM finish();
ROLLBACK;