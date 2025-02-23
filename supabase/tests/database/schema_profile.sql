BEGIN;
SELECT plan( 56 );

SELECT has_table( 'profile' );
select columns_are('public','profile',
    array[
        'id','created_at','name','address','bday','username','role','subscription',
        'daily_credits','last_query','phone','has_paid','is_male','identifier'
    ]
);
SELECT has_column( 'profile', 'id' );
SELECT has_column( 'profile', 'created_at' );
SELECT has_column( 'profile', 'name' );
SELECT has_column( 'profile', 'address' );
SELECT has_column( 'profile', 'bday' );
SELECT has_column( 'profile', 'username' );
SELECT has_column( 'profile', 'role' );
SELECT has_column( 'profile', 'subscription' );
SELECT has_column( 'profile', 'daily_credits' );
SELECT has_column( 'profile', 'last_query' );
SELECT has_column( 'profile', 'phone' );
SELECT has_column( 'profile', 'has_paid' );
SELECT has_column( 'profile', 'identifier' );

select col_type_is('profile','id','uuid');
select col_type_is('profile','identifier','uuid');
select col_type_is('profile','created_at','timestamp with time zone');
select col_type_is('profile','name','uuid');
select col_type_is('profile','address','uuid');
select col_type_is('profile','bday','uuid');
select col_type_is('profile','username','text');
select col_type_is('profile','role','smallint');
select col_type_is('profile','subscription','date');
select col_type_is('profile','daily_credits','smallint');
select col_type_is('profile','last_query','date');
select col_type_is('profile','phone','uuid');
select col_type_is('profile','has_paid','boolean');

select col_is_pk('profile','id');

select col_is_fk('profile','name');
select col_is_fk('profile','address');
select col_is_fk('profile','bday');
select col_is_fk('profile','phone');
select col_is_fk('profile','id');
select col_is_fk('profile','role');


select fk_ok('public','profile','name','vault','secrets','id');
select fk_ok('public','profile','address','vault','secrets','id');
select fk_ok('public','profile','bday','vault','secrets','id');
select fk_ok('public','profile','phone','vault','secrets','id');
select fk_ok('public','profile','id','auth','users','id');
select fk_ok('profile','role','roles','id');


select isnt_empty('select * from public.profile;');
select table_privs_are(
    'profile','anon',
    null
);
SELECT column_privs_are(
    'profile','address', 'authenticated', null
);
SELECT column_privs_are(
    'profile','username', 'authenticated', ARRAY['SELECT', 'UPDATE'],
    'auth should be able to select and update columns in username'
);
SELECT column_privs_are(
    'profile','subscription', 'authenticated', ARRAY['SELECT'],
    'auth should be able to select and update columns in subscription'
);
SELECT column_privs_are(
    'profile','daily_credits', 'authenticated', ARRAY['SELECT'],
    'auth should be able to select and update columns in daily_credits'
);
SELECT column_privs_are(
    'profile','phone', 'authenticated', null
);
SELECT column_privs_are(
    'profile','identifier', 'authenticated', null
);
SELECT column_privs_are(
    'profile','bday', 'authenticated', null
);
-- select todo('array empty also returns missing empty',8);
SELECT column_privs_are(
    'profile','name', 'authenticated', null
);
SELECT column_privs_are(
    'profile','role', 'authenticated',null
);
SELECT column_privs_are(
    'profile','last_query', 'authenticated', null
);
SELECT column_privs_are(
    'profile','id', 'authenticated', null
);
SELECT column_privs_are(
    'profile','created_at', 'authenticated',null
);

SELECT column_privs_are(
    'profile','has_paid', 'authenticated', null
);

SELECT * FROM finish();
ROLLBACK;