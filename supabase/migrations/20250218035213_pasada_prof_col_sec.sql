REVOKE ALL on public.profile FROM public;
Revoke all on public.profile from authenticated,anon;
grant all on public.profile to postgres;
grant select ("barangay","username","subscription","daily_credits","phone","bday","municipality","province") on table public.profile to authenticated;
grant update ("barangay","username","phone","municipality","province") on table public.profile to authenticated;
REVOKE ALL on public.pasada FROM public;
Revoke all on public.pasada from authenticated,anon;
grant all on public.pasada to postgres;

