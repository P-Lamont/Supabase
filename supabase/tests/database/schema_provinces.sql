BEGIN;
SELECT plan( 8 );

SELECT has_table( 'provinces' );

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

SELECT * FROM finish();
ROLLBACK;