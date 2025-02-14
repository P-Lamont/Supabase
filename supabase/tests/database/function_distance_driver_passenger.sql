BEGIN;
SELECT plan(3);

select function_returns('distance_driver_passenger',array['text[]'],'real');
select isnt_definer('distance_driver_passenger');
select is_strict('distance_driver_passenger');

SELECT * FROM finish();
ROLLBACK;