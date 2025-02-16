BEGIN;
SELECT plan( 8 );

SELECT has_table( 'nodescode' );

SELECT has_column( 'nodescode', 'nodes' );
SELECT has_column( 'nodescode', 'code' );

select col_type_is('nodescode','nodes','text');
select col_type_is('nodescode','code','text');

select col_is_pk('nodescode','code');

select has_unique('nodescode','code');
select has_unique('nodescode','nodes');
SELECT * FROM finish();
ROLLBACK;