BEGIN;
SELECT plan(3);

select function_returns('combine_segment_array',ARRAY['text[]','integer','integer'],'text[]');
select isnt_definer('combine_segment_array');
select is_strict('combine_segment_array');

SELECT * FROM finish();
ROLLBACK;