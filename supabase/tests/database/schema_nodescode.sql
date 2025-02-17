BEGIN;
SELECT plan(11 );

SELECT has_table( 'nodescode' );

SELECT has_column( 'nodescode', 'nodes' );
SELECT has_column( 'nodescode', 'code' );

select col_type_is('nodescode','nodes','text');
select col_type_is('nodescode','code','text');

select col_is_pk('nodescode','code');

select has_unique('nodescode','code');
select has_unique('nodescode','nodes');
select isnt_empty('select * from public.nodescode;');

select table_privs_are(
    'nodescode','anon',
    null
);
select table_privs_are(
    'nodescode','authenticated',
    null
);
SELECT * FROM finish();
ROLLBACK;