BEGIN;
SELECT plan( 43 );

SELECT has_table( 'profile' );

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
SELECT has_column( 'profile', 'v_type' );
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
select col_type_is('profile','role','bigint');
select col_type_is('profile','subscription','date');
select col_type_is('profile','v_type','smallint');
select col_type_is('profile','daily_credits','smallint');
select col_type_is('profile','last_query','date');
select col_type_is('profile','phone','text');
select col_type_is('profile','has_paid','boolean');

select col_is_pk('profile','id');

select col_is_fk('profile','barangay');
select col_is_fk('profile','id');
select col_is_fk('profile','role');
select col_is_fk('profile','v_type');

select fk_ok('profile','barangay','barangays','id');
select fk_ok('public','profile','id','auth','users','id');
select fk_ok('profile','role','roles','id');
select fk_ok('profile','v_type','v_types','id');

select has_unique('profile','id');
SELECT * FROM finish();
ROLLBACK;