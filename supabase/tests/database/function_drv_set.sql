BEGIN;
SELECT plan(2);

select function_returns('drv_set',array['text','text','real','real','timestamp without time zone','integer'],'void');
select is_definer('drv_set');
-- select is_strict('drv_set');


SELECT * FROM finish();
ROLLBACK;