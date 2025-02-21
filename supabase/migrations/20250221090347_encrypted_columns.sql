alter table "public"."barangays" drop constraint "barangays_id_key";

alter table "public"."distancetable" drop constraint "distancetable_id_key";

alter table "public"."driverlogs" drop constraint "driverlogs_id_key";

alter table "public"."kmsegments" drop constraint "kmsegments_table_id_key";

alter table "public"."municipalities" drop constraint "municipalities_id_key";

alter table "public"."nodescode" drop constraint "nodescode_code_key";

alter table "public"."organization" drop constraint "organization_id_key";

alter table "public"."pasada" drop constraint "pasada_driver_key";

alter table "public"."profile" drop constraint "profile_barangay_fkey";

alter table "public"."profile" drop constraint "profile_id_key";

alter table "public"."profile" drop constraint "profile_phone_check";

alter table "public"."roles" drop constraint "roles_id_key";

alter table "public"."route_table" drop constraint "route_table_id_key";

alter table "public"."v_types" drop constraint "v_types_id_key";

drop index if exists "public"."barangays_id_key";

drop index if exists "public"."distancetable_id_key";

drop index if exists "public"."driverlogs_id_key";

drop index if exists "public"."kmsegments_table_id_key";

drop index if exists "public"."municipalities_id_key";

drop index if exists "public"."nodescode_code_key";

drop index if exists "public"."organization_id_key";

drop index if exists "public"."pasada_driver_key";

drop index if exists "public"."profile_id_key";

drop index if exists "public"."roles_id_key";

drop index if exists "public"."route_table_id_key";

drop index if exists "public"."v_types_id_key";

alter table "public"."nodescode" alter column "nodes" set not null;

alter table "public"."profile" drop column "barangay";

alter table "public"."profile" drop column "firstname";

alter table "public"."profile" drop column "lastname";

alter table "public"."profile" drop column "municipality";

alter table "public"."profile" drop column "province";

alter table "public"."profile" add column "address" uuid;

alter table "public"."profile" add column "is_male" boolean;

alter table "public"."profile" add column "name" uuid;

alter table "public"."profile" alter column "bday" set data type uuid using "bday"::uuid;

alter table "public"."profile" alter column "phone" set data type uuid using "phone"::uuid;
revoke select ("phone","bday") on table public.profile from authenticated;
revoke update ("phone","bday") on table public.profile from authenticated;

ALTER TABLE public.profile
ADD CONSTRAINT profile_name_fkey
FOREIGN KEY (name) REFERENCES vault.secrets(id) ON UPDATE CASCADE;
ALTER TABLE public.profile
ADD CONSTRAINT profile_address_fkey
FOREIGN KEY (address) REFERENCES vault.secrets(id) ON UPDATE CASCADE;
ALTER TABLE public.profile
ADD CONSTRAINT profile_phone_fkey
FOREIGN KEY (phone) REFERENCES vault.secrets(id) ON UPDATE CASCADE;
ALTER TABLE public.profile
ADD CONSTRAINT profile_bday_fkey
FOREIGN KEY (bday) REFERENCES vault.secrets(id)ON UPDATE CASCADE;



set check_function_bodies = off;


CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$declare

prov smallint;
mun  smallint;
brgy  int;
name_fmt text;
address_fmt text;
bday_fmt text;
phone_fmt text;
name_secret uuid;
address_secret uuid;
bday_secret uuid;
phone_secret uuid;
is_male_value boolean;
Begin

Select id into prov
from public.provinces
where province=new.raw_user_meta_data ->> 'prov';

Select id into mun
from public.municipalities
where municipality=new.raw_user_meta_data ->> 'mun' and province =prov;

Select id into brgy
from public.barangays
where barangay = new.raw_user_meta_data ->> 'brgy' and barangays.municipality=mun and barangays.province=prov;

name_fmt:=concat(new.raw_user_meta_data ->> 'l_name',', ',new.raw_user_meta_data ->> 'f_name',' ',new.raw_user_meta_data ->> 'ext');
address_fmt:= concat(new.raw_user_meta_data ->> 'street',', ', brgy);

name_secret:=vault.create_secret(name_fmt)::uuid;
address_secret:=vault.create_secret(address_fmt)::uuid;
bday_secret:=vault.create_secret(new.raw_user_meta_data ->> 'bday')::uuid;
phone_secret:=vault.create_secret(new.raw_user_meta_data ->> 'phone')::uuid;
is_male_value:= new.raw_user_meta_data ->> 'is_male';
Insert into public.profile(id,name,address,phone,bday,username,is_male)
Values (
  new.id,name_secret,address_secret,phone_secret,bday_secret,
  new.raw_user_meta_data ->> 'username',is_male_value
);

RETURN new;  
END;$function$
;


