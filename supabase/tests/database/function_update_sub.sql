BEGIN;
SELECT plan(2);

select function_returns('update_sub',array['text','boolean','integer'],'boolean');
select is_definer('update_sub');
select is_strict('update_sub');

SELECT * FROM finish();
ROLLBACK;