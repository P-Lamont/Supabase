
BEGIN;
SELECT plan( 25 );

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
SELECT * FROM finish();
ROLLBACK;