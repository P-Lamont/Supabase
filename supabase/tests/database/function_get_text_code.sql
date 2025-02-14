BEGIN;
SELECT plan(8);

select function_returns('get_text_code',array['text'],'text');
select isnt_definer('get_text_code');
-- select is_strict('get_text_code');
set role postgres;
select is(get_text_code('Banaue'),'2701');
select is(get_text_code('Baaue'),null);
set role authenticated;
select is(get_text_code('Banaue'),null);
select is(get_text_code('Baaue'),null);
set role authenticated;
select is(get_text_code('Banaue'),null);
select is(get_text_code('Baaue'),null);
SELECT * FROM finish();
ROLLBACK;