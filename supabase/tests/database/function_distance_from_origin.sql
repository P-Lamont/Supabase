BEGIN;
SELECT plan(3);

select function_returns('distance_from_origin',array['real','real'],'setof record');
select isnt_definer('distance_from_origin');
select is_strict('distance_from_origin');

SELECT * FROM finish();
ROLLBACK;