BEGIN;
SELECT plan(25);
select tables_are(
    'public',
    array[
        'barangays','distancetable','driverlogs','kmsegments','municipalities',
        'nodescode','organization','pasada','profile','provinces','roles',
        'route_table','v_types','user_search','driver_updates','monthly_report'
    ]
);
SELECT roles_are(
    ARRAY[ 
        'postgres', 'authenticated', 'anon','authenticator','dashboard_user',
        'pg_checkpoint','pg_database_owner','pg_execute_server_program',
        'pg_monitor','pg_read_all_data','pg_read_all_settings',
        'pg_read_all_stats','pg_read_server_files','pg_signal_backend',
        'pg_stat_scan_tables','pg_write_all_data','pg_write_server_files',
        'pgbouncer','pgsodium_keyholder','pgsodium_keyiduser',
        'pgsodium_keymaker','service_role','supabase_admin',
        'supabase_auth_admin','supabase_functions_admin',
        'supabase_read_only_user','supabase_realtime_admin',
        'supabase_replication_admin','supabase_storage_admin'
    ]
);
SELECT users_are(
    ARRAY[ 
        'postgres','authenticator','pgbouncer','supabase_admin',
        'supabase_auth_admin','supabase_functions_admin',
        'supabase_read_only_user','supabase_replication_admin',
        'supabase_storage_admin'
    ]
);
SELECT groups_are(
    ARRAY[
        'anon','authenticated','dashboard_user','pg_checkpoint','pg_database_owner',
        'pg_execute_server_program','pg_monitor','pg_read_all_data',
        'pg_read_all_settings','pg_read_all_stats','pg_read_server_files',
        'pg_signal_backend','pg_stat_scan_tables','pg_write_all_data',
        'pg_write_server_files','pgsodium_keyholder','pgsodium_keyiduser',
        'pgsodium_keymaker','service_role','supabase_realtime_admin'
    ]
);
SELECT schemas_are(
    ARRAY[
    '_realtime','auth','extensions','graphql','graphql_public','net',
    'realtime','storage','supabase_functions','supabase_migrations','use',
    'vault','public'
    ]
);
SELECT views_are(
    'public',
    ARRAY[]::text[]
);
SELECT materialized_views_are(
    'public',
    ARRAY[]::text[]
);
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
select hasnt_trigger('public','monthly_report');
select functions_are(
    'public', ARRAY[
        'check_is_admin','check_is_driver','combine_segment_array',
        'distance_driver_passenger','distance_from_origin','drv_min','drv_set',
        'get_text_code','handle_new_user','inbetween_segmental_distance',
        'insert_to_driver_table','q_drivers','setlog','upd_ctr',
        'update_daily_credit','update_sub',
        'custom_access_token_hook','update_profile','view_profile','monthly_agg',
        'el_detalye'
    ]
);

SELECT * FROM finish();
ROLLBACK;