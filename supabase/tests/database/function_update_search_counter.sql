BEGIN;
SELECT plan(4);

select function_returns('update_search_counter',array['uuid[]'],'void');
select is_definer('update_search_counter');
-- select is_strict('update_search_counter');
select function_privs_are('update_search_counter',array['uuid[]'],'anon',null);
select function_privs_are('update_search_counter',array['uuid[]'],'authenticated',null);
SELECT * FROM finish();
ROLLBACK;