BEGIN;
SELECT plan( 4);

select function_returns('custom_access_token_hook',array['jsonb'],'jsonb');
select is_definer('custom_access_token_hook');
-- select is_strict('custom_access_token_hook');
select function_privs_are(
    'custom_access_token_hook',array['jsonb'],'anon',null
);
select function_privs_are(
    'custom_access_token_hook',array['jsonb'],'authenticated',null
);

SELECT * FROM finish();
ROLLBACK;