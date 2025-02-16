BEGIN;
SELECT plan(2);

select function_returns('update_search_counter',array['uuid[]'],'void');
select is_definer('update_search_counter');
-- select is_strict('update_search_counter');

SELECT * FROM finish();
ROLLBACK;