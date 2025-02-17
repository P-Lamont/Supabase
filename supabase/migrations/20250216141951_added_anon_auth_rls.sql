drop policy "anon_restrict" on "public"."barangays";

drop policy "auth_restrict" on "public"."barangays";

drop policy "restrict_all" on "public"."municipalities";

create policy "anon_auth_restrict"
on "public"."barangays"
as restrictive
for all
to authenticated, anon
using (false)
with check (false);


create policy "anon_auth_restrict"
on "public"."distancetable"
as restrictive
for all
to anon, authenticated
using (false)
with check (false);


create policy "anon_restric"
on "public"."driverlogs"
as restrictive
for all
to anon
using (false)
with check (false);


create policy "auth"
on "public"."driverlogs"
as restrictive
for select
to authenticated
using (false);


create policy "auth_del"
on "public"."driverlogs"
as restrictive
for delete
to authenticated
using (false);


create policy "auth_update"
on "public"."driverlogs"
as restrictive
for update
to authenticated
using (false)
with check (false);


create policy "anon_auth_restrict"
on "public"."kmsegments"
as restrictive
for all
to anon, authenticated
using (false)
with check (false);


create policy "anon_auth_restrict"
on "public"."municipalities"
as restrictive
for all
to anon, authenticated
using (false)
with check (false);


create policy "anon_auth_restrict"
on "public"."nodescode"
as restrictive
for all
to anon, authenticated
using (false)
with check (false);


create policy "anon_auth_restrict"
on "public"."organization"
as restrictive
for all
to anon, authenticated
using (false)
with check (false);


create policy "anon_auth_restrict"
on "public"."pasada"
as restrictive
for all
to anon, authenticated
using (false)
with check (false);


create policy "anon_auth_del"
on "public"."roles"
as restrictive
for delete
to anon, authenticated
using (false);


create policy "anon_auth_insert"
on "public"."roles"
as restrictive
for insert
to anon, authenticated
with check (false);


create policy "anon_auth_update"
on "public"."roles"
as restrictive
for update
to anon, authenticated
using (false)
with check (false);


create policy "anon_auth_restrict"
on "public"."route_table"
as restrictive
for all
to anon, authenticated
using (false)
with check (false);


create policy "anon_auth_restrict"
on "public"."v_types"
as restrictive
for all
to anon, authenticated
using (false)
with check (false);



