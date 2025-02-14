BEGIN;
SELECT plan(3);

select function_returns('setlog',array['real','real','real','real','timestamp without time zone','timestamp without time zone'],'void');
select is_definer('setlog');
select is_strict('setlog');

SELECT * FROM finish();
ROLLBACK;