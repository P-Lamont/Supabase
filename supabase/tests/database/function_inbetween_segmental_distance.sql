BEGIN;
SELECT plan(15);


select isnt_definer('inbetween_segmental_distance');
select is_strict('inbetween_segmental_distance');
select is(
    public.inbetween_segmental_distance(array['2704','2703A','2705','5003A'],1,2),
    2486::real
);
select is(
    public.inbetween_segmental_distance(array['2704','2703A','2705','5003A'],1,3),
    25701::real
);
select is(
    public.inbetween_segmental_distance(array['2704','2703A','2705','5003A'],1,4),
    35432::real
);
select is(
    public.inbetween_segmental_distance(array['2704','2703A','2705','5003A'],2,4),
    32947::real
);
select is(
    public.inbetween_segmental_distance(array['2704','2703A','2705','5003A'],3,4),
    9732::real
);
select is(
    public.inbetween_segmental_distance(array['2704','2703A','2705','5003A'],2,3),
    23216::real
);
select is(
    public.inbetween_segmental_distance(array['2704','2703A','2705','5003A'],3,2),
    23216::real
);
select is(
    public.inbetween_segmental_distance(array['2704','2703A','2705','5003A'],4,2),
    32947::real
);
select is(
    public.inbetween_segmental_distance(array['2704','2703A','2705','5003A'],5,2),
    32947::real
);
-- select skip(1);
-- prepare invalid_value as select public.inbetween_segmental_distance(array['2704','2703A','2705','5003A'],5,7);
-- select is(
--    'invalid_value',0::real
-- );
select function_returns('inbetween_segmental_distance',array['text[]','integer','integer'],'real');
select volatility_is('inbetween_segmental_distance',array['text[]','integer','integer'],'stable');
select function_privs_are('inbetween_segmental_distance',array['text[]','integer','integer'],'anon',null);
select function_privs_are('inbetween_segmental_distance',array['text[]','integer','integer'],'authenticated',null);
SELECT * FROM finish();
ROLLBACK;