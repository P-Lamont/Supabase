BEGIN;
SELECT plan( 19 );

SELECT has_table( 'kmsegments' );

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

select has_unique('kmsegments','table_id');

SELECT * FROM finish();
ROLLBACK;