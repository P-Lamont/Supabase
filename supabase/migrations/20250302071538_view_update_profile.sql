set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.update_profile(n_det text[], d_type text)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$declare
  arr_trim text[];
  has_null integer;
  has_empty integer;
  nme_s text;
  ads_s text;
  bdy_s text;
  phn_s text;
  prov_i smallint;
  mun_i smallint;
  brgy_i integer;
  is_numeric boolean;
  len_check integer;
  bday_str date;
  bday_fmt boolean;
  age int;
  c_name text;
  c_address text;
  nme_uuid uuid;
  phn_uuid uuid;
  ads_uuid uuid;
  bdy_uuid uuid;
  result boolean;
begin
  if array[d_type] <@ array['nme','ads','bday','phn']=false then
    raise exception 'Invalid code';
  end if;
  result =false;
  select name,address,phone,bday 
  into nme_s,ads_s,phn_s,bdy_s
  from public.profile
  where id= (select auth.uid());
  SELECT ARRAY(
      SELECT trim(x) 
      FROM unnest(n_det) AS x
  ) INTO arr_trim;
  -- select trim(unnest(n_det)) into arr_trim;
  select array_position(arr_trim, NULL) into has_null;
  select array_position(arr_trim, '') into has_empty;
  if d_type='nme' then
    if has_null is not null  or 
      array_length(arr_trim,1) !=2 or 
      has_empty is not null then
        raise exception 'Invalid name';
    else
      c_name =array_to_string(array[arr_trim[2],arr_trim[1]],', ');
      if  nme_s is null then
        nme_uuid:=vault.create_secret(c_name)::uuid;
        update public.profile
        set name = nme_uuid
        where id= (select auth.uid());
        result =true;
      else
        perform vault.update_secret(nme_s::uuid,c_name);
        result =true;
      end if;
    end if;

  elseif d_type='ads' then
    if array_length(arr_trim,1) !=4  or 
      has_null != 1 or 
      has_empty != 1 then
      raise exception 'Invalid address';  
    end if;
    select id into prov_i
    from public.provinces
    where province= arr_trim[4];
    if prov_i is not null then
      select id into mun_i
      from public.municipalities
      where municipality=arr_trim[3] and "province"=prov_i;
    end if;
    if mun_i is not null then
      select id into brgy_i
      from public.barangays
      where barangay=arr_trim[2] and province = prov_i and municipality=mun_i;
    end if;
    if (brgy_i is null) or ((arr_trim[1] is not null or arr_trim[1]!='') and arr_trim[2] is null) then
      raise Exception 'Invalid address';
    end if;
    if arr_trim[1] is not null or arr_trim[1]!='' then
      c_address:=array_to_string(array[arr_trim[1],brgy_i::text],', ');
    else
      c_address:=brgy_i::text;      
    end if;
    if c_address is not null then
      if ads_s is null then
        ads_uuid:=vault.create_secret(trim(c_address))::uuid;
        update public.profile
        set address = ads_uuid
        where id= (select auth.uid());
        result =true;
      else
        perform vault.update_secret(ads_s::uuid,c_address);
        result =true;
      end if;
    end if;

  elseif d_type='phn' then
    if array_length(arr_trim,1) !=1  or 
      has_null is not null or 
      has_empty is not null  then
      raise exception 'Invalid phone';
    end if;
    SELECT arr_trim[1] ~ '^09[0-9]+$' into is_numeric;
    select length(arr_trim[1]) into len_check;
    if is_numeric=false or len_check!=11  then
      raise Exception 'Invalid phone';
    end if;
    if phn_s is null then
      phn_uuid:=vault.create_secret(arr_trim[1])::uuid;
      update public.profile
      set phone = phn_uuid
      where id= (select auth.uid());
      result =true;
    else   
      perform vault.update_secret(phn_s::uuid,arr_trim[1]);
      result =true;
    end if;

  elseif d_type='bday' then
    SELECT arr_trim[1] ~ '^\d{4}/\d{2}/\d{2}$' into bday_fmt;
    if array_length(arr_trim,1) !=1  or 
      has_null is not null or 
      has_empty is not null  or
      bday_fmt =false then
        raise exception 'Invalid birthday';
    end if;
    begin
      SELECT TO_DATE(arr_trim[1], 'YYYY/MM/DD')into bday_str;
    exception
      when others then
        raise 'Invalid birthday';
    end;
    -- SELECT TO_CHAR(arr_trim[1], 'YYYY-MM-DD') into bday_str;
    select DATE_PART('YEAR', AGE(current_date, bday_str)) into age;
    if age<10 then
      raise exception 'Age under 10';
    elseif age>80 then
      raise exception 'Age over 80';
    elseif bdy_s is null and arr_trim[1] is not null  then
      bdy_uuid:=vault.create_secret(arr_trim[1])::uuid;
      update public.profile
      set bday = bdy_uuid
      where id= (select auth.uid());
      result =true;
    elseif arr_trim[1] is not null then
      perform vault.update_secret(bdy_s::uuid,arr_trim[1]);
      result =true;
    end if;
  end if;
return result;
end$function$
;


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
  ads_fmt text[];
  nme_d text;
  ads_d text;
  phn_d text;
  bdy_d text;
  prov_id smallint;
  mun_id smallint;
  street text;
  brgy text;
  mun text;
  prov text;
  complete_brgy text;
  result record;
begin
  select name,address,phone,bday into nme,ads,phn,bdy
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
  complete_brgy=array_to_string(array[brgy,mun,prov],', ');
  select nme_d::text,street::text,complete_brgy::text,phn_d::text,bdy_d::text into result;
  return result;
  end$function$
;
revoke execute on function update_profile(text[],text) from public,anon,authenticated;
revoke execute on function view_profile() from public,anon,authenticated;
grant execute on function update_profile(text[],text) to authenticated;
grant execute on function view_profile() to authenticated;

