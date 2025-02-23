BEGIN;
SELECT plan( 22 );

SELECT has_table( 'driver_updates' );
select columns_are('public','driver_updates',
    array[
        'id','datetime','lat','long','drv','log_number'
    ]
);
SELECT has_column( 'driver_updates', 'id' );
SELECT has_column( 'driver_updates', 'datetime' );
SELECT has_column( 'driver_updates', 'lat' );
SELECT has_column( 'driver_updates', 'long' );
SELECT has_column( 'driver_updates', 'drv' );
SELECT has_column( 'driver_updates', 'log_number' );

select col_type_is('driver_updates','id','uuid');
select col_type_is('driver_updates','datetime','timestamp without time zone');
select col_type_is('driver_updates','lat','double precision');
select col_type_is('driver_updates','long','double precision');
select col_type_is('driver_updates','drv','uuid');
select col_type_is('driver_updates','log_number','bigint');

select col_is_pk('driver_updates','id');

select col_is_fk('driver_updates','drv');
select col_is_fk('driver_updates','log_number');

select fk_ok('public','driver_updates','drv','auth','users','id');
select fk_ok('driver_updates','log_number','driverlogs','id');

select isnt_empty('select * from public.driver_updates;');

select table_privs_are(
    'driver_updates','anon',
    null
);
select table_privs_are(
    'driver_updates','authenticated',
    null
);
SELECT * FROM finish();
ROLLBACK;