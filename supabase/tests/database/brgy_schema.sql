BEGIN;
SELECT plan( 14 );

SELECT has_table( 'barangays' );

SELECT has_column( 'barangays', 'id' );
SELECT has_column( 'barangays', 'barangay' );
SELECT has_column( 'barangays', 'province' );
SELECT has_column( 'barangays', 'municipality' );

SELECT col_type_is('barangays', 'id','integer');
SELECT col_type_is('barangays', 'barangay','text');
SELECT col_type_is('barangays', 'province','smallint');
SELECT col_type_is('barangays', 'municipality','smallint');

select col_is_pk('barangays','id');

select col_is_fk('barangays','municipality');
select col_is_fk('barangays','province');

select col_is_null('barangays','municipality');
select col_is_null('barangays','province');
SELECT * FROM finish();
ROLLBACK;