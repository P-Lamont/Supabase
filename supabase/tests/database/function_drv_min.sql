BEGIN;
SELECT plan(2);

select function_returns('drv_min',array['real','real','timestamp without time zone','integer'],'void');
select is_definer('drv_min');
-- select is_strict('drv_min');

SELECT * FROM finish();
ROLLBACK;