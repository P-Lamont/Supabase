BEGIN;
SELECT plan( 21 );

SELECT has_table( 'barangays' );
select columns_are('public','barangays',array['id','barangay','province','municipality']);

SELECT has_column( 'barangays', 'id' );
SELECT has_column( 'barangays', 'barangay' );
SELECT has_column( 'barangays', 'province' );
SELECT has_column( 'barangays', 'municipality' );

SELECT col_type_is('barangays', 'id','integer');
SELECT col_type_is('barangays', 'barangay','text');
SELECT col_type_is('barangays', 'province','smallint');
SELECT col_type_is('barangays', 'municipality','smallint');

select col_is_pk('barangays','id');

select col_is_fk('barangays','municipality');
select col_is_fk('barangays','province');

select col_is_null('barangays','municipality');
select col_is_null('barangays','province');

select fk_ok('barangays','municipality','municipalities','id');
select fk_ok('barangays','province','provinces','id');


select policies_are('barangays',array['anon_auth_restrict']);
select isnt_empty('select * from public.barangays;');
select table_privs_are(
    'barangays','anon',
    null
);
select table_privs_are(
    'barangays','authenticated',
    null
);
SELECT * FROM finish();
ROLLBACK;