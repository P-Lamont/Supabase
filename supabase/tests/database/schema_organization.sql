BEGIN;
SELECT plan( 11 );

SELECT has_table( 'organization' );

SELECT has_column( 'organization', 'id' );
SELECT has_column( 'organization', 'orgName' );
SELECT has_column( 'organization', 'officialName' );

select col_type_is('organization','id','integer');
select col_type_is('organization','orgName','text');
select col_type_is('organization','officialName','text');

select col_is_pk('organization','id');

select has_unique('organization','id');

select has_unique('organization','orgName');
select has_unique('organization','officialName');
SELECT * FROM finish();
ROLLBACK;