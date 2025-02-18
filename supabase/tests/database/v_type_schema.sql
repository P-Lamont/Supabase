BEGIN;
SELECT plan( 11 );

SELECT has_table( 'v_types' );
select columns_are('public','v_types',
    array[
        'id','type'
    ]
);
SELECT has_column( 'v_types', 'id' );
SELECT has_column( 'v_types', 'type' );

select col_type_is('v_types','id','smallint');
select col_type_is('v_types','type','text');

select col_is_pk('v_types','id');

select col_is_unique('v_types','type');

select isnt_empty('select * from public.v_types;');

select table_privs_are(
    'v_types','anon',
    null
);
select table_privs_are(
    'v_types','authenticated',
    null
);
SELECT * FROM finish();
ROLLBACK;