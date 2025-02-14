BEGIN;
SELECT plan(2);

select function_returns('inbetween_segmental_distance',array['text[]','integer','integer'],'real');
select isnt_definer('inbetween_segmental_distance');
-- select is_strict('inbetween_segmental_distance');

SELECT * FROM finish();
ROLLBACK;