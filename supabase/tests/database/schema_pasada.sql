BEGIN;
SELECT plan( 44 );

SELECT has_table( 'pasada' );
select columns_are('public','pasada',
    array[
        'driver','speed','time','segment_distance','is_reversed_route','v_type',
        'driver_route','segment','latitude','longitude','organization','counter'
    ]
);
SELECT has_column( 'pasada', 'driver' );
SELECT has_column( 'pasada', 'speed' );
SELECT has_column( 'pasada', 'time' );
SELECT has_column( 'pasada', 'segment_distance' );
SELECT has_column( 'pasada', 'is_reversed_route' );
SELECT has_column( 'pasada', 'driver_route' );
SELECT has_column( 'pasada', 'segment' );
SELECT has_column( 'pasada', 'latitude' );
SELECT has_column( 'pasada', 'longitude' );
SELECT has_column( 'pasada', 'organization' );
SELECT has_column( 'pasada', 'counter' );
SELECT has_column( 'pasada', 'v_type' );

select col_type_is('pasada','driver','uuid');
select col_type_is('pasada','speed','smallint');
select col_type_is('pasada','time','timestamp with time zone');
select col_type_is('pasada','segment_distance','numeric');
select col_type_is('pasada','is_reversed_route','boolean');
select col_type_is('pasada','driver_route','smallint');
select col_type_is('pasada','segment','text[]');
select col_type_is('pasada','latitude','double precision');
select col_type_is('pasada','longitude','double precision');
select col_type_is('pasada','organization','integer');
select col_type_is('pasada','counter','bigint');
select col_type_is('pasada','v_type','smallint');

select col_is_pk('pasada','driver');

select col_is_fk('pasada','driver');
select col_is_fk('pasada','driver_route');
select col_is_fk('pasada','organization');
select col_is_fk('pasada','v_type');

select fk_ok('pasada','v_type','v_types','id');
select fk_ok('public','pasada','driver','auth','users','id');
select fk_ok('pasada','driver_route','route_table','id');
select fk_ok('pasada','organization','organization','id');


select isnt_empty('select * from public.pasada;');

select table_privs_are(
    'pasada','anon',
    null
);
select table_privs_are(
    'pasada','authenticated',
    null
);
select col_has_check('pasada',array['latitude']);
select col_has_check('pasada',array['longitude']);

PREPARE lat_lower_bound AS INSERT INTO public.pasada
    ("driver", "latitude", "longitude") 
VALUES 
    (gen_random_uuid(), '0', '121.06033');
SELECT throws_ok(
    'lat_lower_bound',
    '23514'
);
PREPARE lat_upper_bound AS INSERT INTO public.pasada
    ("driver", "latitude", "longitude") 
VALUES 
    (gen_random_uuid(), '23', '121.06033');
SELECT throws_ok(
    'lat_upper_bound',
    '23514'
);
PREPARE long_lower_bound AS INSERT INTO public.pasada
    ("driver", "latitude", "longitude") 
VALUES 
    (gen_random_uuid(), '16.91048', '115');
SELECT throws_ok(
    'long_lower_bound',
    '23514'
);
PREPARE long_upper_bound AS INSERT INTO public.pasada
    ("driver", "latitude", "longitude") 
VALUES 
    (gen_random_uuid(), '16.91048', '129');
SELECT throws_ok(
    'long_upper_bound',
    '23514'
);
SELECT * FROM finish();
ROLLBACK;