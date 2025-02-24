BEGIN;
SELECT plan(7);

select function_returns('distance_from_origin',array['real','real'],'setof record');
select isnt_definer('distance_from_origin');
select is_strict('distance_from_origin');

select results_eq(
  'select *  from  distance_from_origin(16.904594, 121.057139);',
  $$VALUES ('2701','2704',1734::real,array['2701','2704'])$$
);
select is_empty(
  'select * from distance_from_origin(0, 125.122222)'
);
select function_privs_are('distance_from_origin',array['real','real'],'anon',null);
select function_privs_are('distance_from_origin',array['real','real'],'authenticated',null);
SELECT * FROM finish();
ROLLBACK;