BEGIN;
SELECT plan( 3);

select function_returns('q_drivers',array['real','real','text'],'setof record');
select is_definer('q_drivers');
select is_strict('q_drivers');

SELECT * FROM finish();
ROLLBACK;