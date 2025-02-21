BEGIN;
SELECT plan( 14 );

SELECT has_table( 'organization' );
select columns_are('public','organization',
    array[
        'id','orgName','officialName'
    ]
);
SELECT has_column( 'organization', 'id' );
SELECT has_column( 'organization', 'orgName' );
SELECT has_column( 'organization', 'officialName' );

select col_type_is('organization','id','integer');
select col_type_is('organization','orgName','text');
select col_type_is('organization','officialName','text');

select col_is_pk('organization','id');


select has_unique('organization','orgName');
select has_unique('organization','officialName');
select isnt_empty('select * from public.organization;');

select table_privs_are(
    'organization','anon',
    null
);
select table_privs_are(
    'organization','authenticated',
    null
);
SELECT * FROM finish();
ROLLBACK;