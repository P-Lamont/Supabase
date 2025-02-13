BEGIN;
SELECT plan( 12 );

SELECT has_table( 'distancetable' );

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

SELECT * FROM finish();
ROLLBACK;