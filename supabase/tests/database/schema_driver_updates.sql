BEGIN;
SELECT plan( 30 );

SELECT has_table( 'driver_updates' );
select columns_are('public','driver_updates',
    array[
        'id','datetime','lat','long','drv','log_number','spd'
    ]
);
SELECT has_column( 'driver_updates', 'id' );
SELECT has_column( 'driver_updates', 'datetime' );
SELECT has_column( 'driver_updates', 'lat' );
SELECT has_column( 'driver_updates', 'long' );
SELECT has_column( 'driver_updates', 'drv' );
SELECT has_column( 'driver_updates', 'log_number' );
SELECT has_column( 'driver_updates', 'spd' );

select col_type_is('driver_updates','id','uuid');
select col_type_is('driver_updates','datetime','timestamp without time zone');
select col_type_is('driver_updates','lat','double precision');
select col_type_is('driver_updates','long','double precision');
select col_type_is('driver_updates','drv','uuid');
select col_type_is('driver_updates','log_number','bigint');
select col_type_is('driver_updates','spd','smallint');

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

select col_has_check('driver_updates',array['long']);
select col_has_check('driver_updates',array['long']);

PREPARE lat_lower_bound AS insert into public.driver_updates("id","datetime","lat","long","drv","log_number")
values(
    gen_random_uuid(),'2024-11-12 06:28:48.476456+00','0', 
    '121.22465','5b996de3-b0e1-4c0f-bcbb-7125b21dcee3','1'
);
SELECT throws_ok(
    'lat_lower_bound',
    '23514'
);
PREPARE lat_upper_bound AS insert into public.driver_updates("id","datetime","lat","long","drv","log_number")
values(
    gen_random_uuid(),'2024-11-12 06:28:48.476456+00','23', 
    '121.22465','5b996de3-b0e1-4c0f-bcbb-7125b21dcee3','1'
);
SELECT throws_ok(
    'lat_upper_bound',
    '23514'
);
PREPARE long_lower_bound AS insert into public.driver_updates("id","datetime","lat","long","drv","log_number")
values(
    gen_random_uuid(),'2024-11-12 06:28:48.476456+00','4', 
    '115','5b996de3-b0e1-4c0f-bcbb-7125b21dcee3','1'
);
SELECT throws_ok(
    'long_lower_bound',
    '23514'
);
PREPARE long_upper_bound AS insert into public.driver_updates("id","datetime","lat","long","drv","log_number")
values(
    gen_random_uuid(),'2024-11-12 06:28:48.476456+00','23', 
    '129','5b996de3-b0e1-4c0f-bcbb-7125b21dcee3','1'
);
SELECT throws_ok(
    'long_upper_bound',
    '23514'
);
SELECT * FROM finish();
ROLLBACK;