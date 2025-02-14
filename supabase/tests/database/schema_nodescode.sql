BEGIN;
SELECT plan( 6 );

SELECT has_table( 'nodescode' );

SELECT has_column( 'nodescode', 'nodes' );
SELECT has_column( 'nodescode', 'code' );

select col_type_is('nodescode','nodes','text');
select col_type_is('nodescode','code','text');

select col_is_pk('nodescode','code');


SELECT * FROM finish();
ROLLBACK;