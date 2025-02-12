INSERT INTO
    auth.users (
        instance_id,
        id,
        aud,
        role,
        email,
        encrypted_password,
        email_confirmed_at,
        recovery_sent_at,
        last_sign_in_at,
        raw_app_meta_data,
        raw_user_meta_data,
        created_at,
        updated_at,
        confirmation_token,
        email_change,
        email_change_token_new,
        recovery_token
    ) (
        select
            '00000000-0000-0000-0000-000000000000',
            uuid_generate_v4 (),
            'authenticated',
            'authenticated',
            'user' || (ROW_NUMBER() OVER ()) || '@example.com',
            crypt ('password123', gen_salt ('bf')),
            current_timestamp,
            current_timestamp,
            current_timestamp,
            '{"provider":"email","providers":["email"]}',
            '{}',
            current_timestamp,
            current_timestamp,
            '',
            '',
            '',
            ''
        FROM
            generate_series(1, 1000)
    );

INSERT INTO
    auth.identities (
        id,
        user_id,
        -- New column
        provider_id,
        identity_data,
        provider,
        last_sign_in_at,
        created_at,
        updated_at
    ) (
        select
            uuid_generate_v4 (),
            id,
            id,
            format('{"sub":"%s","email":"%s"}', id :: text, email) :: jsonb,
            'email',
            current_timestamp,
            current_timestamp,
            current_timestamp
        from
            auth.users
    );
INSERT INTO
    public.profiles (
    id,
    created_at,
    firstname,
    lastname,
    province,
    municipality,
    barangay,
    bday,
    username,
    roles,
    subscription,
    v_type,
    daily_credits,
    last_query,
    phone,
    has_paid
    ) (
        select
            uuid_generate_v4 (),
            current_timestamp,
            substring(md5(random()::text), 1, 7),
            substring(md5(random()::text), 1, 10),
            substring(md5(random()::text), 1, 15),
            substring(md5(random()::text), 1, 12),
            substring(md5(random()::text), 1, 12),
            substring(md5(random()::text), 1, 12),
            CURRENT_DATE + (random() * (30 - 1) + 1)::int,
            substring(md5(random()::text), 1, 7),
            CASE 
                WHEN RANDOM() <= 0.10 THEN 1
                ELSE 3
            end,
            null,
            CASE 
                WHEN roles = 3 THEN 5
                ELSE null
            END,
            null,
            null,
            substring(md5(random()::text), 1, 11),
            false
        from
            auth.users
    );
INSERT INTO
    public.pasada (
    driver,
    speed,
    'time' ,
    segment_distance,
    is_reversed_route,
    driver_route,
    segment,
    latitude ,
    longitude,
    organization,
    'counter'
    ) (
        select
            uuid_generate_v4 (),
            FLOOR(RANDOM() * 100),
            current_timestamp - (random() * (TIMESTAMP '2023-12-31' - TIMESTAMP '2023-01-01')),
            
        from
            auth.users
    );