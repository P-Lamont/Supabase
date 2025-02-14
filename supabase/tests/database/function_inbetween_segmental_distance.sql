BEGIN;
SELECT plan(3);

select function_returns('inbetween_segmental_distance',array['text[]','integer','integer'],'trigger');
select isnt_definer('inbetween_segmental_distance');
select is_strict('inbetween_segmental_distance');

SELECT * FROM finish();
ROLLBACK;