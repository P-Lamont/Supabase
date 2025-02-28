BEGIN;
SELECT plan(10);

select isnt_definer('distance_driver_passenger');
select is_strict('distance_driver_passenger');
select is(
  public.distance_driver_passenger(array['2705-5003A']),9732::real);
select is(
  public.distance_driver_passenger(array['270-5003A']),null);
select is(
  public.distance_driver_passenger(array['2703A-2705']),23216::real);
select is(
  public.distance_driver_passenger(array['260']),null);

select volatility_is('distance_driver_passenger',array['text[]'],'stable');
select function_returns('distance_driver_passenger',array['text[]'],'real');
select function_privs_are(
  'distance_driver_passenger',array['text[]'],'anon',null
);
select function_privs_are(
  'distance_driver_passenger',array['text[]'],'authenticated',null
);
SELECT * FROM finish();
ROLLBACK;