BEGIN;
SELECT plan(5);

select function_returns('drv_set',array['text','text','real','real','timestamp without time zone','integer'],'void');
select is_definer('drv_set');
select is_strict('drv_set');
select function_privs_are('drv_set',array['text','text','real','real','timestamp without time zone','integer'],'anon',null);
select function_privs_are('drv_set',array['text','text','real','real','timestamp without time zone','integer'],'authenticated',array['EXECUTE']);
SELECT * FROM finish();
ROLLBACK;