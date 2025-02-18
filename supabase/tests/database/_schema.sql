BEGIN;
SELECT plan(1);
select tables_are(
    'public',
    array[
        'barangays','distancetable','driverlogs','kmsegments','municipalities',
        'nodescode','organization','pasada','profile','provinces','roles',
        'route_table','v_types'
    ]
);
-- SELECT roles_are(ARRAY[ 'postgres', 'authenticated', 'anon' ]);
SELECT * FROM finish();
ROLLBACK;