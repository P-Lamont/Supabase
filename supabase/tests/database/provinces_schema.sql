BEGIN;
SELECT plan( 6 );

SELECT has_table( 'provinces' );

SELECT has_column( 'provinces', 'id' );
SELECT has_column( 'provinces', 'province' );

select col_type_is('provinces','id','smallint');
select col_type_is('provinces','province','text');

select col_is_pk('provinces','id');



SELECT * FROM finish();
ROLLBACK;