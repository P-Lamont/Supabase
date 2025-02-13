BEGIN;
SELECT plan( 9 );

SELECT has_table( 'municipalities' );

SELECT has_column( 'municipalities', 'id' );
SELECT has_column( 'municipalities', 'municipality' );
SELECT has_column( 'municipalities', 'province' );

select col_type_is('municipalities','id','smallint');
select col_type_is('municipalities','municipality','text');
select col_type_is('municipalities','province','smallint');

select col_is_pk('municipalities','id');

select col_is_fk('municipalities','province');

SELECT * FROM finish();
ROLLBACK;