BEGIN;
SELECT plan( 6 );

SELECT has_table( 'v_types' );

SELECT has_column( 'v_types', 'id' );
SELECT has_column( 'v_types', 'type' );

select col_type_is('v_types','id','smallint');
select col_type_is('v_types','type','text');

select col_is_pk('v_types','id');

SELECT * FROM finish();
ROLLBACK;