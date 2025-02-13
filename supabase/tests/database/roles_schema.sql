BEGIN;
SELECT plan( 6 );

SELECT has_table( 'roles' );

SELECT has_column( 'roles', 'id' );
SELECT has_column( 'roles', 'roles' );

select col_type_is('roles','id','bigint');
select col_type_is('roles','roles','text');

select col_is_pk('roles','id');


SELECT * FROM finish();
ROLLBACK;