BEGIN;
SELECT plan(3);

select function_returns('get_text_code',array['text'],'text');
select isnt_definer('get_text_code');
select is_strict('get_text_code');

SELECT * FROM finish();
ROLLBACK;