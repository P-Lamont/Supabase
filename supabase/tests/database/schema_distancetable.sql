BEGIN;
SELECT plan( 18 );

SELECT has_table( 'distancetable' );
select columns_are('public','distancetable',array['id','start_node','end_node','distance']);

SELECT has_column( 'distancetable', 'id' );
SELECT has_column( 'distancetable', 'start_node' );
SELECT has_column( 'distancetable', 'end_node' );
SELECT has_column( 'distancetable', 'distance' );

select col_type_is('distancetable','id','bigint');
select col_type_is('distancetable','start_node','text');
select col_type_is('distancetable','end_node','text');
select col_type_is('distancetable','distance','double precision');

select col_is_pk('distancetable','id');

select col_is_fk('distancetable','start_node');
select col_is_fk('distancetable','end_node');

select fk_ok('distancetable','start_node','nodescode','code');
select fk_ok('distancetable','end_node','nodescode','code');


select table_privs_are(
    'distancetable','anon',
    null
);
select isnt_empty('select * from public.distancetable;');
select table_privs_are(
    'distancetable','authenticated',
    null
);
SELECT * FROM finish();
ROLLBACK;