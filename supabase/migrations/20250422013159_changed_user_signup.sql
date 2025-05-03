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
is_male_secret uuid;
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
address_fmt:= concat(new.raw_user_meta_data ->> 'st',', ', brgy);

name_secret:=vault.create_secret(name_fmt)::uuid;
address_secret:=vault.create_secret(address_fmt)::uuid;
bday_secret:=vault.create_secret(new.raw_user_meta_data ->> 'bday')::uuid;
phone_secret:=vault.create_secret(new.raw_user_meta_data ->> 'phn')::uuid;
is_male_secret:= vault.create_secret(new.raw_user_meta_data ->> 'gdr')::uuid;
Insert into public.profile(id,name,address,phone,bday,username,is_male)
Values (
  new.id,name_secret,address_secret,phone_secret,bday_secret,
  new.raw_user_meta_data ->> 'u_name',is_male_secret
);

RETURN new;  
END;$function$
;


