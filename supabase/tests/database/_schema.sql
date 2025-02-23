BEGIN;
SELECT plan(17);
select tables_are(
    'public',
    array[
        'barangays','distancetable','driverlogs','kmsegments','municipalities',
        'nodescode','organization','pasada','profile','provinces','roles',
        'route_table','v_types','user_search','driver_updates'
    ]
);
-- SELECT roles_are(ARRAY[ 'postgres', 'authenticated', 'anon' ]);
SELECT triggers_are( 'public','profile', array['add_driver_on_profile_update'] );
SELECT triggers_are( 'auth','users', array['after_user_signup'] );
select hasnt_trigger('public','barangay');
select hasnt_trigger('public','distancetable');
select hasnt_trigger('public','driverlogs');
select hasnt_trigger('public','kmsegments');
select hasnt_trigger('public','municipalities');
select hasnt_trigger('public','nodescode');
select hasnt_trigger('public','organization');
select hasnt_trigger('public','pasada');
select hasnt_trigger('public','provinces');
select hasnt_trigger('public','roles');
select hasnt_trigger('public','route_table');
select hasnt_trigger('public','v_types');
select hasnt_trigger('public','user_search');
select hasnt_trigger('public','driver_updates');
SELECT * FROM finish();
ROLLBACK;