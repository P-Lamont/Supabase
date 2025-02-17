BEGIN;
SELECT plan(5);

select function_returns('setlog',array['real','real','real','real','timestamp without time zone','timestamp without time zone'],'void');
select is_definer('setlog');
select is_strict('setlog');

select function_privs_are('setlog',array['real','real','real','real','timestamp without time zone','timestamp without time zone'],'anon',null);
select function_privs_are('setlog',array['real','real','real','real','timestamp without time zone','timestamp without time zone'],'authenticated',null);
SELECT * FROM finish();
ROLLBACK;