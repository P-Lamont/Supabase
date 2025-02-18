BEGIN;
SELECT plan( 15 );

SELECT has_table( 'municipalities' );
select columns_are('public','municipalities',
    array[
        'id','municipality','province'
    ]
);
SELECT has_column( 'municipalities', 'id' );
SELECT has_column( 'municipalities', 'municipality' );
SELECT has_column( 'municipalities', 'province' );

select col_type_is('municipalities','id','smallint');
select col_type_is('municipalities','municipality','text');
select col_type_is('municipalities','province','smallint');

select col_is_pk('municipalities','id');

select col_is_fk('municipalities','province');

select fk_ok('municipalities','province','provinces','id');

select has_unique('municipalities','id');
select isnt_empty('select * from public.municipalities;');

select table_privs_are(
    'municipalities','anon',
    null
);
select table_privs_are(
    'municipalities','authenticated',
    null
);
SELECT * FROM finish();
ROLLBACK;