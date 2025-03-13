set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.view_profile()
 RETURNS record
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$declare
  nme text;
  ads text;
  phn text;
  bdy text;
  gdr text;
  ads_fmt text[];
  nme_d text;
  ads_d text;
  phn_d text;
  bdy_d text;
  gdr_d text;
  prov_id smallint;
  mun_id smallint;
  street text;
  brgy text;
  mun text;
  prov text;
  c_brgy text;
  unme text;
  result record;
begin
  select name,address,phone,bday,is_male,username into nme,ads,phn,bdy,gdr,unme
  from public.profile
  where id =(select auth.uid())::uuid;

  select decrypted_secret into nme_d 
  from vault.decrypted_secrets
  where id = nme::uuid;

  select decrypted_secret into ads_d 
  from vault.decrypted_secrets
  where id = ads::uuid;

  select decrypted_secret into phn_d 
  from vault.decrypted_secrets
  where id = phn::uuid;

  select decrypted_secret into bdy_d 
  from vault.decrypted_secrets
  where id = bdy::uuid;

  select decrypted_secret into gdr_d 
  from vault.decrypted_secrets
  where id = gdr::uuid;

  if ads_d is not null then
    ads_fmt = string_to_array(ads_d,',');
  end if;
  if ads_fmt is not null then
    street = array_to_string(ads_fmt[:array_length(ads_fmt,1)-1],',');
    select barangay,province,municipality into brgy, prov_id,mun_id
    from public.barangays
    where id = trim(ads_fmt[array_upper(ads_fmt, 1)])::integer;
    select province into prov
    from public.provinces
    where id = prov_id;
    select municipality into mun
    from public.municipalities
    where id = mun_id;
  end if;
  c_brgy=array_to_string(array[brgy,mun,prov],', ');
  select nme_d::text,street::text,c_brgy::text,phn_d::text,bdy_d::text,gdr_d::text,unme::text into result;
  return result;
  end$function$
;


