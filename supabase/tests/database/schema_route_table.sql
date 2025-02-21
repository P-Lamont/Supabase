BEGIN;
SELECT plan( 18 );

SELECT has_table( 'route_table' );
select columns_are('public','route_table',
    array[
        'id','origin','destination','route'
    ]
);
SELECT has_column( 'route_table', 'id' );
SELECT has_column( 'route_table', 'origin' );
SELECT has_column( 'route_table', 'destination' );
SELECT has_column( 'route_table', 'route' );

select col_type_is('route_table','id','bigint');
select col_type_is('route_table','origin','text');
select col_type_is('route_table','destination','text');
select col_type_is('route_table','route','text[]');

select col_is_pk('route_table','id');

select col_is_fk('route_table','origin');
select col_is_fk('route_table','destination');

select fk_ok('route_table','origin','nodescode','code');
select fk_ok('route_table','destination','nodescode','code');

select isnt_empty('select * from public.route_table;');

select table_privs_are(
    'route_table','anon',
    null
);
select table_privs_are(
    'route_table','authenticated',
    null
);
SELECT * FROM finish();
ROLLBACK;