BEGIN;
SELECT plan(4);

select function_returns('check_is_admin','boolean');
select isnt_definer('check_is_admin');
-- set role postgres;
select is(check_is_admin(),true);
-- Create a role paul.
-- insert into auth.users(
--     instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, 
--     last_sign_in_at, raw_app_meta_data, raw_user_meta_data, 
--     created_at, updated_at,is_sso_user,is_anonymous)
-- values
-- (
--     '00000000-0000-0000-0000-000000000000','742ae67b-abaf-4176-ad88-d328e9123304','authenticated','authenticated','bullan1965@gmail.com','$2b$12$lOB6WSs2Wxw888qKtAfWqeVAXfJ1K6CzxAbPAwqXUWfrBveMjG8zm','2025-01-11 16:41:03.228170+00',
--     '2025-01-17 17:47:11.506251+00','{"provider": "email","providers": ["email"]}','
--         {
--         "sub": "742ae67b-abaf-4176-ad88-d328e9123304",
--         "bday": "1965-11-10 00:00:00000000+00",
--         "email": "bullan1965@gmail.com",
--         "barangay": "Candaping B",
--         "province": "Siquijor",
--         "username": "Amina",
--         "last_name": "Bullan",
--         "first_name": "Amina",
--         "municipality": "Maria",
--         "email_verified": false,
--         "phone_verified": false
--         }','2025-01-11 16:40:03.228170+00','2025-01-17 17:47:11.506251+00',
--     'false','false'
--     );
-- insert into auth.identities(
--     id,provider_id,user_id,identity_data,provider,last_sign_in_at,created_at,updated_at
--     )
-- values
-- (
--     '1d9dc483-ddd1-4565-9c40-5d91b75c6f82','742ae67b-abaf-4176-ad88-d328e9123304','742ae67b-abaf-4176-ad88-d328e9123304','
--         {
--         "sub": "742ae67b-abaf-4176-ad88-d328e9123304",
--         "bday": "1965-11-10 00:00:00000000+00",
--         "email": "bullan1965@gmail.com",
--         "barangay": "Candaping B",
--         "province": "Siquijor",
--         "username": "Amina",
--         "last_name": "Bullan",
--         "first_name": "Amina",
--         "municipality": "Maria",
--         "email_verified": false,
--         "phone_verified": false
--         }','email',
--     '2025-01-11 16:40:03.228170+00','2025-01-17 17:47:11.506251+00','2025-01-17 17:47:11.506251+00');
-- select results_eq('select username from public.profile where firstname =''Amina'' and lastname=''Bullan''',array['Amina']);
-- update public.profile
-- set "role" =3
-- where id = '742ae67b-abaf-4176-ad88-d328e9123304'::uuid;
-- CREATE ROLE test_driver;
-- grant authenticated to test_driver;
-- grant

-- set role test_driver;
-- set role authenticated;
-- SET SESSION request.jwt.claims.sub = '742ae67b-abaf-4176-ad88-d328e9123304';
-- perform set_config('request.jwt.claim.sub', '742ae67b-abaf-4176-ad88-d328e9123304', false);
-- select is(check_is_admin(),false);
set role anon;
select is(check_is_admin(),false);
SELECT * FROM finish();
ROLLBACK;