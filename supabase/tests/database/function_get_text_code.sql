BEGIN;
SELECT plan(6);

select function_returns('get_text_code',array['text'],'text');
select isnt_definer('get_text_code');
-- select is_strict('get_text_code');
set role postgres;
select is(get_text_code('Banaue'),'2701');
select is(get_text_code('Baaue'),null);

select function_privs_are('get_text_code',array['text'],'anon',null);
select function_privs_are('get_text_code',array['text'],'authenticated',null);
SELECT * FROM finish();
ROLLBACK;