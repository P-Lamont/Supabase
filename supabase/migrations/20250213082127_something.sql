set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$declare
prov smallint;
mun  smallint;
brgy  int;
Begin
Select id into prov
from provinces
where province=new.raw_user_meta_data ->> 'province';
Select id into mun
from municipalities
where municipality=new.raw_user_meta_data ->> 'municipality' and province =prov;

Select id into brgy
from barangays
where barangay = new.raw_user_meta_data ->> 'barangay' and barangays.municipality=mun and barangays.province=prov;
Insert into public.profile(id,firstname,lastname,province,municipality,barangay,bday,username)
Values (
  new.id, new.raw_user_meta_data ->> 'first_name', new.raw_user_meta_data ->> 'last_name',
  prov, mun,
  brgy, new.raw_user_meta_data ->> 'bday',
  new.raw_user_meta_data ->> 'username'
);
RETURN new;  
END;$function$
;


