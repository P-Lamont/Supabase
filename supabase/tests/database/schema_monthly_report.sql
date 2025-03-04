BEGIN;
SELECT plan(15 );

SELECT has_table( 'monthly_report' );
select columns_are('public','monthly_report',
    array[
        'id','created_at','driver_id','counter'
    ]
);
SELECT has_column( 'monthly_report', 'id' );
SELECT has_column( 'monthly_report', 'created_at' );
SELECT has_column( 'monthly_report', 'driver_id' );
SELECT has_column( 'monthly_report', 'counter' );

select col_type_is('monthly_report','id','bigint');
select col_type_is('monthly_report','created_at','date');
select col_type_is('monthly_report','driver_id','uuid');
select col_type_is('monthly_report','counter','bigint');

select col_is_pk('monthly_report','id');
select fk_ok('public','monthly_report','driver_id','auth','users','id');

select table_privs_are(
    'monthly_report','anon',
    null
);
select table_privs_are(
    'monthly_report','authenticated',
    null
);
select table_privs_are(
    'monthly_report','postgres',
    array[
        'DELETE','INSERT','REFERENCES','SELECT','TRIGGER','TRUNCATE',
        'UPDATE'
    ]
);
SELECT * FROM finish();
ROLLBACK;