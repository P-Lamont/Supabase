BEGIN;
SELECT plan( 57 );

SELECT has_table( 'profile' );
select columns_are('public','profile',
    array[
        'id','created_at','firstname','lastname','province','municipality',
        'barangay','bday','username','role','subscription',
        'daily_credits','last_query','phone','has_paid'
    ]
);
SELECT has_column( 'profile', 'id' );
SELECT has_column( 'profile', 'created_at' );
SELECT has_column( 'profile', 'firstname' );
SELECT has_column( 'profile', 'lastname' );
SELECT has_column( 'profile', 'province' );
SELECT has_column( 'profile', 'municipality' );
SELECT has_column( 'profile', 'barangay' );
SELECT has_column( 'profile', 'bday' );
SELECT has_column( 'profile', 'username' );
SELECT has_column( 'profile', 'role' );
SELECT has_column( 'profile', 'subscription' );
SELECT has_column( 'profile', 'daily_credits' );
SELECT has_column( 'profile', 'last_query' );
SELECT has_column( 'profile', 'phone' );
SELECT has_column( 'profile', 'has_paid' );

select col_type_is('profile','id','uuid');
select col_type_is('profile','created_at','timestamp with time zone');
select col_type_is('profile','firstname','text');
select col_type_is('profile','lastname','text');
select col_type_is('profile','province','smallint');
select col_type_is('profile','municipality','smallint');
select col_type_is('profile','barangay','integer');
select col_type_is('profile','bday','text');
select col_type_is('profile','username','text');
select col_type_is('profile','role','smallint');
select col_type_is('profile','subscription','date');
select col_type_is('profile','daily_credits','smallint');
select col_type_is('profile','last_query','date');
select col_type_is('profile','phone','text');
select col_type_is('profile','has_paid','boolean');

select col_is_pk('profile','id');

select col_is_fk('profile','barangay');
select col_is_fk('profile','id');
select col_is_fk('profile','role');


select fk_ok('profile','barangay','barangays','id');
select fk_ok('public','profile','id','auth','users','id');
select fk_ok('profile','role','roles','id');

select has_unique('profile','id');

select isnt_empty('select * from public.profile;');
select table_privs_are(
    'profile','anon',
    null
);
SELECT column_privs_are(
    'profile','barangay', 'authenticated', ARRAY['SELECT', 'UPDATE'],
    'auth should be able to select and update columns in barangay'
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
    'profile','phone', 'authenticated', ARRAY['SELECT', 'UPDATE'],
    'auth should be able to select and update columns in phone'
);
SELECT column_privs_are(
    'profile','bday', 'authenticated', ARRAY['SELECT'],
    'auth should be able to select and update columns in bday'
);
SELECT column_privs_are(
    'profile','municipality', 'authenticated', ARRAY['SELECT', 'UPDATE'],
    'auth should be able to select and update columns in municipality'
);
SELECT column_privs_are(
    'profile','province', 'authenticated', ARRAY['SELECT', 'UPDATE'],
    'auth should be able to select and update columns in province'
);
-- select todo('array empty also returns missing empty',8);
SELECT column_privs_are(
    'profile','firstname', 'authenticated', null
);
SELECT column_privs_are(
    'profile','lastname', 'authenticated', null
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