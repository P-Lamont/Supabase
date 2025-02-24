BEGIN;
SELECT plan( 6);

select function_returns('q_drivers',array['real','real','text'],'setof record');
select is_definer('q_drivers');
select is_strict('q_drivers');
select function_privs_are('q_drivers',array['real','real','text'],'anon',null);
select volatility_is('q_drivers',array['real','real','text'],'volatile');
select function_privs_are('q_drivers',array['real','real','text'],'authenticated',array['EXECUTE']);
SELECT * FROM finish();
ROLLBACK;