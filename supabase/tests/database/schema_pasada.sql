BEGIN;
SELECT plan( 34 );

SELECT has_table( 'pasada' );
select columns_are('public','pasada',
    array[
        'driver','speed','time','segment_distance','is_reversed_route',
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

select col_is_pk('pasada','driver');

select col_is_fk('pasada','driver');
select col_is_fk('pasada','driver_route');
select col_is_fk('pasada','organization');

select fk_ok('public','pasada','driver','auth','users','id');
select fk_ok('pasada','driver_route','route_table','id');
select fk_ok('pasada','organization','organization','id');

select has_unique('pasada','driver');

-- select isnt_empty('select * from public.pasada;');

select table_privs_are(
    'pasada','anon',
    null
);
select table_privs_are(
    'pasada','authenticated',
    null
);
SELECT * FROM finish();
ROLLBACK;