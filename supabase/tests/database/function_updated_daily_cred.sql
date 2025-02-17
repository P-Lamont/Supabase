BEGIN;
SELECT plan( 4 );

select function_returns('update_daily_credit','boolean');
select isnt_definer('update_daily_credit');
select function_privs_are('update_daily_credit',array[''],'anon',null);
select function_privs_are('update_daily_credit',array[''],'authenticated',null);
SELECT * FROM finish();
ROLLBACK;