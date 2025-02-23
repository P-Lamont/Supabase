
BEGIN;
SELECT plan( 37 );

SELECT has_table( 'driverlogs' );
select columns_are('public','driverlogs',
    array[
        'id','latEnd','longEnd','route','starttime','endtime','driver_id',
        'latStart','longStart'
    ]
);

SELECT has_column( 'driverlogs', 'id' );
SELECT has_column( 'driverlogs', 'latEnd' );
SELECT has_column( 'driverlogs', 'longEnd' );
SELECT has_column( 'driverlogs', 'route' );
SELECT has_column( 'driverlogs', 'starttime' );
SELECT has_column( 'driverlogs', 'endtime' );
SELECT has_column( 'driverlogs', 'driver_id' );
SELECT has_column( 'driverlogs', 'latStart' );
SELECT has_column( 'driverlogs', 'longStart' );

SELECT col_type_is('driverlogs', 'id','bigint');
SELECT col_type_is('driverlogs', 'latEnd','double precision');
SELECT col_type_is('driverlogs', 'longEnd','double precision');
SELECT col_type_is('driverlogs', 'route','smallint');
SELECT col_type_is('driverlogs', 'starttime','timestamp without time zone');
SELECT col_type_is('driverlogs', 'endtime','timestamp without time zone');
SELECT col_type_is('driverlogs', 'driver_id','uuid');
SELECT col_type_is('driverlogs', 'latStart','double precision');
SELECT col_type_is('driverlogs', 'longStart','double precision');

select col_is_pk('driverlogs','id');

select col_is_fk('driverlogs','route');

select isnt_empty('select * from public.driverlogs;');
select table_privs_are(
    'driverlogs','anon',
    null
);
select table_privs_are(
    'driverlogs','authenticated',
    null
);

select col_has_check('driverlogs',array['latStart']);
select col_has_check('driverlogs',array['longStart']);
select col_has_check('driverlogs',array['latEnd']);
select col_has_check('driverlogs',array['longEnd']);
prepare latSlower as insert into public.driverlogs (
    "id","latEnd","longEnd","route","starttime","endtime","driver_id",
    "latStart","longStart"
)
values
    (
        '1','16.5487', '121.2419','1','2024-11-12 06:24:48.476456+00',
        '2024-11-12 07:05:48.476456+00','5b996de3-b0e1-4c0f-bcbb-7125b21dcee3',
        '0', '121.21757'
    );
prepare latSupper as insert into public.driverlogs (
    "id","latEnd","longEnd","route","starttime","endtime","driver_id",
    "latStart","longStart"
)
values
    (
        '1','16.5487', '121.2419','1','2024-11-12 06:24:48.476456+00',
        '2024-11-12 07:05:48.476456+00','5b996de3-b0e1-4c0f-bcbb-7125b21dcee3',
        '23', '121.21757'
    );
prepare longSlower as insert into public.driverlogs (
    "id","latEnd","longEnd","route","starttime","endtime","driver_id",
    "latStart","longStart"
)
values
    (
        '1','16.5487', '121.2419','1','2024-11-12 06:24:48.476456+00',
        '2024-11-12 07:05:48.476456+00','5b996de3-b0e1-4c0f-bcbb-7125b21dcee3',
        '16.652222', '115'
    );
prepare longSupper as insert into public.driverlogs (
    "id","latEnd","longEnd","route","starttime","endtime","driver_id",
    "latStart","longStart"
)
values
    (
        '1','16.5487', '121.2419','1','2024-11-12 06:24:48.476456+00',
        '2024-11-12 07:05:48.476456+00','5b996de3-b0e1-4c0f-bcbb-7125b21dcee3',
        '16.652222', '129'
    );
prepare latElower as insert into public.driverlogs (
    "id","latEnd","longEnd","route","starttime","endtime","driver_id",
    "latStart","longStart"
)
values
    (
        '1','0', '121.2419','1','2024-11-12 06:24:48.476456+00',
        '2024-11-12 07:05:48.476456+00','5b996de3-b0e1-4c0f-bcbb-7125b21dcee3',
        '16.652222', '121.21757'
    );
prepare latEupper as insert into public.driverlogs (
    "id","latEnd","longEnd","route","starttime","endtime","driver_id",
    "latStart","longStart"
)
values
    (
        '1','23', '121.2419','1','2024-11-12 06:24:48.476456+00',
        '2024-11-12 07:05:48.476456+00','5b996de3-b0e1-4c0f-bcbb-7125b21dcee3',
        '16.652222', '121.21757'
    );
prepare longElower as insert into public.driverlogs (
    "id","latEnd","longEnd","route","starttime","endtime","driver_id",
    "latStart","longStart"
)
values
    (
        '1','16.5487', '115','1','2024-11-12 06:24:48.476456+00',
        '2024-11-12 07:05:48.476456+00','5b996de3-b0e1-4c0f-bcbb-7125b21dcee3',
        '16.652222', '121.21757'
    );
prepare longEupper as insert into public.driverlogs (
    "id","latEnd","longEnd","route","starttime","endtime","driver_id",
    "latStart","longStart"
)
values
    (
        '1','16.5487', '129','1','2024-11-12 06:24:48.476456+00',
        '2024-11-12 07:05:48.476456+00','5b996de3-b0e1-4c0f-bcbb-7125b21dcee3',
        '16.652222', '121.21757'
    );

SELECT throws_ok('latSlower','23514');
SELECT throws_ok('latSupper','23514');
SELECT throws_ok('longSlower','23514');
SELECT throws_ok('longSupper','23514');
SELECT throws_ok('latElower','23514');
SELECT throws_ok('latEupper','23514');
SELECT throws_ok('longElower','23514');
SELECT throws_ok('longElower','23514');
SELECT * FROM finish();
ROLLBACK;