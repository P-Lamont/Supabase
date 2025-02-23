alter table "public"."driver_updates" add constraint "driver_updates_lat_check" CHECK (((lat >= ('1'::integer)::double precision) AND (lat <= (22)::double precision))) not valid;

alter table "public"."driver_updates" validate constraint "driver_updates_lat_check";

alter table "public"."driver_updates" add constraint "driver_updates_long_check" CHECK (((long >= ('116'::integer)::double precision) AND (long <= (128)::double precision))) not valid;

alter table "public"."driver_updates" validate constraint "driver_updates_long_check";

alter table "public"."driverlogs" add constraint "latend_constraint" CHECK ((("latEnd" >= ('1'::numeric)::double precision) AND ("latEnd" <= (22.0)::double precision))) not valid;

alter table "public"."driverlogs" validate constraint "latend_constraint";

alter table "public"."driverlogs" add constraint "latstart_constraint" CHECK ((("latStart" >= ('1'::numeric)::double precision) AND ("latStart" <= (22.0)::double precision))) not valid;

alter table "public"."driverlogs" validate constraint "latstart_constraint";

alter table "public"."driverlogs" add constraint "longend_constraint" CHECK ((("longEnd" >= ('116.0'::numeric)::double precision) AND ("longEnd" <= (128.0)::double precision))) not valid;

alter table "public"."driverlogs" validate constraint "longend_constraint";

alter table "public"."driverlogs" add constraint "longstart_constraint" CHECK ((("longStart" >= ('116.0'::numeric)::double precision) AND ("longStart" <= (128.0)::double precision))) not valid;

alter table "public"."driverlogs" validate constraint "longstart_constraint";

alter table "public"."pasada" add constraint "lat_constraint" CHECK ((("latitude" >= ('1'::numeric)::double precision) AND ("latitude" <= (22.0)::double precision))) not valid;

alter table "public"."pasada" validate constraint "lat_constraint";

alter table "public"."pasada" add constraint "long_constraint" CHECK ((("longitude" >= ('116.0'::numeric)::double precision) AND ("longitude" <= (128.0)::double precision))) not valid;

alter table "public"."pasada" validate constraint "long_constraint";

alter table "public"."kmsegments" add constraint "lat_constraint" CHECK ((("latitude" >= ('1'::numeric)::double precision) AND ("latitude" <= (22.0)::double precision))) not valid;

alter table "public"."kmsegments" validate constraint "lat_constraint";

alter table "public"."kmsegments" add constraint "long_constraint" CHECK ((("longitude" >= ('116.0'::numeric)::double precision) AND ("longitude" <= (128.0)::double precision))) not valid;

alter table "public"."kmsegments" validate constraint "long_constraint";

alter table "public"."user_search" add constraint "lat_constraint" CHECK ((("lat" >= ('1'::numeric)::double precision) AND ("lat" <= (22.0)::double precision))) not valid;

alter table "public"."user_search" validate constraint "lat_constraint";

alter table "public"."user_search" add constraint "long_constraint" CHECK ((("long" >= ('116.0'::numeric)::double precision) AND ("long" <= (128.0)::double precision))) not valid;

alter table "public"."user_search" validate constraint "long_constraint";
