BEGIN;
SELECT plan( 28 );

SELECT has_table( 'kmsegments' );

select columns_are('public','kmsegments',
    array[
        'table_id','distance','latitude','longitude','origin','destination'
    ]
);
SELECT has_column( 'kmsegments', 'table_id' );
SELECT has_column( 'kmsegments', 'distance' );
SELECT has_column( 'kmsegments', 'latitude' );
SELECT has_column( 'kmsegments', 'longitude' );
SELECT has_column( 'kmsegments', 'origin' );
SELECT has_column( 'kmsegments', 'destination' );

SELECT col_type_is('kmsegments', 'table_id','bigint');
SELECT col_type_is('kmsegments', 'distance','double precision');
SELECT col_type_is('kmsegments', 'latitude','double precision');
SELECT col_type_is('kmsegments', 'longitude','double precision');
SELECT col_type_is('kmsegments', 'origin','text');
SELECT col_type_is('kmsegments', 'destination','text');

select col_is_pk('kmsegments','table_id');

select col_is_fk('kmsegments','origin');
select col_is_fk('kmsegments','destination');

select fk_ok('kmsegments','origin','nodescode','code');
select fk_ok('kmsegments','destination','nodescode','code');


select isnt_empty('select * from public.kmsegments;');

select table_privs_are(
    'kmsegments','anon',
    null
);
select table_privs_are(
    'kmsegments','authenticated',
    null
);

select col_has_check('kmsegments',array['latitude']);
select col_has_check('kmsegments',array['longitude']);

PREPARE lat_lower_bound AS INSERT INTO public.kmsegments
    ("table_id", "distance", "latitude", "longitude", "origin", "destination") 
VALUES 
    ('1', '100', '0', '121.06033', '2701', '2704');
SELECT throws_ok(
    'lat_lower_bound',
    '23514'
);
PREPARE lat_upper_bound AS INSERT INTO public.kmsegments
    ("table_id", "distance", "latitude", "longitude", "origin", "destination") 
VALUES 
    ('1', '100', '23', '121.06033', '2701', '2704');
SELECT throws_ok(
    'lat_upper_bound',
    '23514'
);
PREPARE long_lower_bound AS INSERT INTO public.kmsegments
    ("table_id", "distance", "latitude", "longitude", "origin", "destination") 
VALUES 
    ('1', '100', '16.91048', '115', '2701', '2704');
SELECT throws_ok(
    'long_lower_bound',
    '23514'
);
PREPARE long_upper_bound AS INSERT INTO public.kmsegments
    ("table_id", "distance", "latitude", "longitude", "origin", "destination") 
VALUES 
    ('1', '100', '16.91048', '129', '2701', '2704');
SELECT throws_ok(
    'long_upper_bound',
    '23514'
);
SELECT * FROM finish();
ROLLBACK;