BEGIN;
SELECT plan(4);

select function_returns('drv_min',array['real','real','timestamp without time zone','integer'],'void');
select is_definer('drv_min');
-- select is_strict('drv_min');
select function_privs_are('drv_min',array['real','real','timestamp without time zone','integer'],'anon',null);
select function_privs_are('drv_min',array['real','real','timestamp without time zone','integer'],'authenticated',array['EXECUTE']);
SELECT * FROM finish();
ROLLBACK;