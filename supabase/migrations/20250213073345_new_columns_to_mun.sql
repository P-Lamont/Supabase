alter table "public"."municipalities" add column "province" smallint;
alter table "public"."municipalities" add constraint "municipalities_province_fkey" FOREIGN KEY (province) REFERENCES provinces(id) ON UPDATE CASCADE ON DELETE SET NULL not valid;

alter table "public"."municipalities" validate constraint "municipalities_province_fkey";

set check_function_bodies = off;


