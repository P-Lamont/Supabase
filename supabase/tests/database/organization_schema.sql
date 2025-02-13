BEGIN;
SELECT plan( 8 );

SELECT has_table( 'organization' );

SELECT has_column( 'organization', 'id' );
SELECT has_column( 'organization', 'orgName' );
SELECT has_column( 'organization', 'officialName' );

select col_type_is('organization','id','integer');
select col_type_is('organization','orgName','text');
select col_type_is('organization','officialName','text');

select col_is_pk('organization','id');

SELECT * FROM finish();
ROLLBACK;