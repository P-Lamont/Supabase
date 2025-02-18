BEGIN;
SELECT plan( 12 );

SELECT has_table( 'provinces' );
select columns_are('public','provinces',
    array[
        'id','province'
    ]
);
SELECT has_column( 'provinces', 'id' );
SELECT has_column( 'provinces', 'province' );

select col_type_is('provinces','id','smallint');
select col_type_is('provinces','province','text');

select col_is_pk('provinces','id');

select has_unique('provinces','id');
select col_is_unique('provinces','province');
-- select results_eq(table_privs_are(
--     'provinces','anon',
--     ARRAY['CONNECT','SELECT','INSERT']),'TRUE'
-- );
select isnt_empty('select * from public.provinces;');

select table_privs_are(
    'provinces','anon',
    null
);
select table_privs_are(
    'provinces','authenticated',
    null
);

SELECT * FROM finish();
ROLLBACK;