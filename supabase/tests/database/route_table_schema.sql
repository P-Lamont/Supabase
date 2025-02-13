BEGIN;
SELECT plan( 12 );

SELECT has_table( 'route_table' );

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

SELECT * FROM finish();
ROLLBACK;