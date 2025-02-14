BEGIN;
SELECT plan( 2 );

select function_returns('update_daily_credit','boolean');
select isnt_definer('update_daily_credit');

SELECT * FROM finish();
ROLLBACK;