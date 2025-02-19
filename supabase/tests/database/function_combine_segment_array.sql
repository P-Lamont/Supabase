BEGIN;
SELECT plan(9);

select function_returns('combine_segment_array',ARRAY['text[]','integer','integer'],'text[]');
select isnt_definer('combine_segment_array');
-- select is_strict('combine_segment_array');
select is(
  public.combine_segment_array(array['2703A','2705','5003A'],1,2),
  array['2703A-2705']
);
select is(
  public.combine_segment_array(array['2703A','2705','5003A'],1,3),
  array['2703A-2705','2705-5003A']
);
select is(
  public.combine_segment_array(array['2703A','2705','5003A'],2,3),
  array['2705-5003A']
);
select is(
  public.combine_segment_array(array['2703A','2705','5003A'],1,1),
  array[]::text[]
);
select is(
  public.combine_segment_array(array['2703A','2705','5003A'],2,1),
  array[]::text[]
);
-- select skip('must not return null after data',1);
-- select is(
--   public.combine_segment_array(array['2703A','2705','5003A'],2,99),
--   null
-- );
select function_privs_are('combine_segment_array',array['text[]','integer','integer'],'anon',null);
select function_privs_are('combine_segment_array',array['text[]','integer','integer'],'authenticated',null);
SELECT * FROM finish();
ROLLBACK;