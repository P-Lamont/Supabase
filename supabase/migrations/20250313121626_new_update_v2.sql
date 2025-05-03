set check_function_bodies = off;
drop function public.update_profile(jsonb);
CREATE OR REPLACE FUNCTION public.update_profile(data text)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$declare
  arr_key text[];
  nme_trim text[]:= array[null,null];
  ads_trim text[]:= array[null,null,null,null];
  str_trim text[];
  bday_trim text;
  phn_trim text;
  gdr_trim text;
  usname text;
  secrets text[];
  uuids uuid[]:=array[null,null,null,null,null];
  has_null int;
  has_empty int;
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
  arr_err text[] := array[null,null,null,null,null,null];
  error_msg text;
  update_date date;
  next_update text;
  to_update boolean;
  usercheck boolean;
  gdr_check boolean;
  data_json jsonb;
  result boolean:=false;
begin
  select updated_at into update_date
  from public.profile
  where id = (select auth.uid());
  if update_date+ interval '1 hour'<current_timestamp and
   update_date+ interval '90 days'>current_timestamp and update_date is not null then
   select To_Char(update_date+ interval '90 days','yyyy/mm/dd hh:mm') into next_update;
   raise exception 'Try after %', next_update;
  elseif update_date+ interval '1 hour'>current_timestamp then
    to_update =false;
  elseif update_date+ interval '90 days'<current_timestamp or update_date is null then
    to_update=true;
  end if;
  begin
    data_json:= data::jsonb;
    exception
      when others then
      raise exception 'Value is not Valid';
  end;
  select ARRAY(SELECT jsonb_object_keys(data_json)) into arr_key;
  if (arr_key <@ array['nme','ads','bday','phn','st','gdr','usr'])=false then
    raise exception 'Invalid code';
  end if;
  select array[name,address,phone,bday] 
  into secrets
  from public.profile
  where id= (select auth.uid());

  SELECT ARRAY(
      SELECT trim(initcap(x)) 
      FROM jsonb_array_elements_text(jsonb_extract_path(data_json,'nme')) AS x
  ) INTO nme_trim;
  SELECT ARRAY(
      SELECT trim(initcap(x)) 
      FROM jsonb_array_elements_text(jsonb_extract_path(data_json,'ads')) AS x
  ) INTO ads_trim;
  SELECT ARRAY(
      SELECT trim(initcap(x)) 
      FROM unnest(string_to_array(data_json->>'st',',')) AS x
  ) INTO str_trim;
  SELECT TRIM(jsonb_extract_path(data_json,'bday')::text) INTO bday_trim;
  SELECT TRIM(data_json->>'phn') INTO phn_trim;
  SELECT TRIM(data_json->>'gdr') INTO gdr_trim;
  SELECT TRIM(data_json->>'usr') INTO usname;
  -- select trim(unnest(n_det)) into arr_trim;
  if nme_trim is not null then
    select array_position(nme_trim, NULL) into has_null;
    select array_position(nme_trim, '') into has_empty;
    if has_null is not null  or 
      array_length(nme_trim,1) !=2 or 
      has_empty is not null then
        arr_err[1]:= 'Invalid name';
    end if;
  end if;
  if ads_trim[1] is not null then
    select array_position(ads_trim, NULL) into has_null;
    select array_position(ads_trim, '') into has_empty;
    if array_length(ads_trim,1) !=3  or 
      has_null != null or 
      has_empty != null then
      arr_err[2]='Invalid address';
    else
      select id into prov_i
      from public.provinces
      where province= ads_trim[3];
      if prov_i is not null then
        select id into mun_i
        from public.municipalities
        where municipality=ads_trim[2]::text and "province"=prov_i;
      end if;
      if mun_i is not null then
        select id into brgy_i
        from public.barangays
        where barangay=ads_trim[1]::text and province = prov_i and municipality=mun_i;
      end if;
      if (brgy_i is null) or ((str_trim[1] is not null or str_trim[1]!='') and brgy_i is null) then
        arr_err[2]= 'Invalid address';
      end if;
    end if;
  end if;
  if data_json?'bday' then
    -- select array_position(bday_trim, NULL) into has_null;
    -- select array_position(bday_trim, '') into has_empty;
    bday_trim =replace(bday_trim,'"','');
    SELECT bday_trim ~ '^\d{4}/\d{2}/\d{2}$' into bday_fmt;
    if bday_fmt =false or bday_trim is null then
        arr_err[3]:= 'Invalid birthday';
    else
      begin
        SELECT TO_DATE(bday_trim, 'YYYY/MM/DD')into bday_str;
      exception
        when others then
          arr_err[3]:= 'Invalid birthday';
      end;
      -- SELECT TO_CHAR(arr_trim[1], 'YYYY-MM-DD') into bday_str;
      select DATE_PART('YEAR', AGE(current_date, bday_str)) into age;
      if age<10 then
        arr_err[3]:= 'Age under 10';
      elseif age>80 then
        arr_err[3]:= 'Age over 80';
      end if;
    end if;
  end if;
  if data_json ? 'phn' then
    SELECT phn_trim ~ '^09[0-9]+$' into is_numeric;
    select length(phn_trim) into len_check;
    -- raise exception '% %, %',is_numeric,len_check,phn_trim;
    if is_numeric=false or len_check!=11 or phn_trim is null  then
      arr_err[4]='Invalid phone';
    end if;
  end if;
  
  if data_json ?'gdr' then
    SELECT gdr_trim = ANY (ARRAY['true', 'false']) INTO gdr_check;
    if gdr_check =false or gdr_trim is null then
      arr_err[5] = 'Invalid gender';
    end if;
  end if;
  if data_json ?'usr' then
    select usname ~ '[!@#$%^&*(),.?":{}|<>]' into usercheck;
    if usercheck =true or length(usname)<6 or length(usname)>15 or usname is null then 
      arr_err[6] = 'Invalid username';
    end if;
  end if;
  error_msg :=array_to_string(arr_err,', ');
  if error_msg !='' then
    raise exception '%', error_msg;
  else
    if nme_trim[2] is not null and arr_err[1] is  null then
      c_name =array_to_string(array[nme_trim[2],nme_trim[1]],', ');
      if  secrets[1] is null then
        uuids[1]:=vault.create_secret(c_name)::uuid;
        update public.profile
        set name = uuids[1]
        where id= (select auth.uid());
        result =true;
      else
        perform vault.update_secret(secrets[1]::uuid,c_name);
        result =true;
      end if;
    end if;

    if ads_trim[1] is not null and arr_err[2] is null then
      if str_trim[1] is not null or str_trim[1]!='' then
        c_address:=array_to_string(array[str_trim[1],brgy_i::text],', ');
      else
        c_address:=brgy_i::text;      
      end if;
      if c_address is not null then
        if secrets[2] is null then
          uuids[2]:=vault.create_secret(trim(c_address))::uuid;
          update public.profile
          set address = uuids[2]
          where id= (select auth.uid());
          result =true;
        else
          perform vault.update_secret(secrets[2]::uuid,c_address);
          result =true;
        end if;
      end if;
    end if;
    if phn_trim is not null and arr_err[3] is null  then
      if secrets[3] is null then
        uuids[3]:=vault.create_secret(phn_trim)::uuid;
        update public.profile
        set phone = uuids[3]
        where id= (select auth.uid());
        result =true;
      else   
        perform vault.update_secret(secrets[3]::uuid,phn_trim);
        result =true;
      end if;
    end if;
    if bday_trim is not null and arr_err[4] is null then
      if secrets[4] is null and bday_trim is not null  then
        uuids[4]:=vault.create_secret(bday_trim)::uuid;
        update public.profile
        set bday = uuids[4]
        where id= (select auth.uid());
        result =true;
      elseif bday_trim is not null then
        perform vault.update_secret(secrets[4]::uuid,bday_trim);
        result =true;
      end if;
    end if;
    if gdr_trim is not null and arr_err[5] is null then
      if secrets[5] is null then
        uuids[5]:=vault.create_secret(gdr_trim)::uuid;
        update public.profile
        set is_male = uuids[5]
        where id= (select auth.uid());
        result =true;
      else
        perform vault.update_secret(secrets[5]::uuid,gdr_trim);
        result =true;
      end if;
    end if;
    if usname is not null and arr_err[6] is null then
      update public.profile
      set "username" = usname
      where id =(select auth.uid());
      result = true;
    end if;
    if to_update=true then
      update public.profile
      set updated_at = current_timestamp
      where id =(select auth.uid());
    end if;
  end if;
return result;
end$function$
;
revoke EXECUTE on function public.update_profile(text) from anon,authenticated,public;
grant EXECUTE on function public.update_profile(text) to authenticated,postgres;


