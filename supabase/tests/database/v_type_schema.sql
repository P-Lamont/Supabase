BEGIN;
SELECT plan( 7 );

SELECT has_table( 'v_types' );

SELECT has_column( 'v_types', 'id' );
SELECT has_column( 'v_types', 'type' );

select col_type_is('v_types','id','smallint');
select col_type_is('v_types','type','text');

select col_is_pk('v_types','id');

select col_is_unique('v_types','type');
SELECT * FROM finish();
ROLLBACK;