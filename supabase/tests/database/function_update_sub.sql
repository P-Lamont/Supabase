BEGIN;
SELECT plan(6);

select function_returns('update_sub',array['text','boolean','integer'],'boolean');
select is_definer('update_sub');
select is_strict('update_sub');
select function_privs_are('update_sub',array['text','boolean','integer'],'anon',null);
select volatility_is('update_sub',array['text','boolean','integer'],'volatile');
select function_privs_are('update_sub',array['text','boolean','integer'],'authenticated',null);
SELECT * FROM finish();
ROLLBACK;