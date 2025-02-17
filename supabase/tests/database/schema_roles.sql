BEGIN;
SELECT plan( 11 );

SELECT has_table( 'roles' );

SELECT has_column( 'roles', 'id' );
SELECT has_column( 'roles', 'roles' );

select col_type_is('roles','id','bigint');
select col_type_is('roles','roles','text');

select col_is_pk('roles','id');

select has_unique('roles','id');

select col_is_unique('roles','roles');

select isnt_empty('select * from public.roles;');

select table_privs_are(
    'roles','anon',
    null
);
select table_privs_are(
    'roles','authenticated',
    null
);
SELECT * FROM finish();
ROLLBACK;