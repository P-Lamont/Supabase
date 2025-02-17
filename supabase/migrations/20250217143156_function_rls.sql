REVOKE all on function public.check_is_admin() from public;
REVOKE all on function public.check_is_admin() from anon,authenticated;
grant all on function public.check_is_admin() to postgres;

REVOKE all on function public.check_is_driver() from public;
REVOKE all on function public.check_is_driver() from anon,authenticated;
grant all on function public.check_is_driver() to postgres;

REVOKE all on function public.combine_segment_array(text[],integer,integer) from public;
REVOKE all on function public.combine_segment_array(text[],integer,integer) from anon,authenticated;
grant all on function public.combine_segment_array(text[],integer,integer) to postgres;

REVOKE all on function public.distance_driver_passenger(text[]) from public;
REVOKE all on function public.distance_driver_passenger(text[]) from anon,authenticated;
grant all on function public.distance_driver_passenger(text[]) to postgres;

REVOKE all on function public.distance_from_origin(real,real) from public;
REVOKE all on function public.distance_from_origin(real,real) from anon,authenticated;
grant all on function public.distance_from_origin(real,real) to postgres;

REVOKE all on function public.drv_min(real,real,timestamp without time zone, integer) from public;
REVOKE all on function public.drv_min(real,real,timestamp without time zone, integer) from anon,authenticated;
grant all on function public.drv_min(real,real,timestamp without time zone, integer) to postgres;
grant all on function public.drv_min(real,real,timestamp without time zone, integer) to authenticated;


REVOKE all on function public.drv_set(text,text,real,real,timestamp without time zone, integer) from public;
REVOKE all on function public.drv_set(text,text,real,real,timestamp without time zone, integer) from anon,authenticated;
grant all on function public.drv_set(text,text,real,real,timestamp without time zone, integer) to postgres;
grant all on function public.drv_set(text,text,real,real,timestamp without time zone, integer) to authenticated;

REVOKE all on function public.get_text_code(text) from public;
REVOKE all on function public.get_text_code(text) from anon,authenticated;
grant all on function public.get_text_code(text) to postgres;

REVOKE all on function public.handle_new_user() from public;
REVOKE all on function public.handle_new_user() from anon,authenticated;
grant all on function public.handle_new_user() to postgres;

REVOKE all on function public.insert_to_driver_table() from public;
REVOKE all on function public.insert_to_driver_table() from anon,authenticated;
grant all on function public.insert_to_driver_table() to postgres;

REVOKE all on function public.inbetween_segmental_distance(text[],integer,integer) from public;
REVOKE all on function public.inbetween_segmental_distance(text[],integer,integer) from anon,authenticated;
grant all on function public.inbetween_segmental_distance(text[],integer,integer) to postgres;

REVOKE all on function public.q_drivers(real,real,text) from public;
REVOKE all on function public.q_drivers(real,real,text) from anon,authenticated;
grant all on function public.q_drivers(real,real,text) to postgres;
grant all on function public.q_drivers(real,real,text) to authenticated;


REVOKE all on function public.setlog(real,real,real,real,timestamp without time zone, timestamp without time zone) from public;
REVOKE all on function public.setlog(real,real,real,real,timestamp without time zone, timestamp without time zone) from anon,authenticated;
grant all on function public.setlog(real,real,real,real,timestamp without time zone, timestamp without time zone) to postgres;

REVOKE all on function public.upd_ctr(uuid) from public;
REVOKE all on function public.upd_ctr(uuid) from anon,authenticated;
grant all on function public.upd_ctr(uuid) to postgres;

REVOKE all on function public.update_daily_credit() from public;
REVOKE all on function public.update_daily_credit() from anon,authenticated;
grant all on function public.update_daily_credit() to postgres;

REVOKE all on function public.update_search_counter(uuid[]) from public;
REVOKE all on function public.update_search_counter(uuid[]) from anon,authenticated;
grant all on function public.update_search_counter(uuid[]) to postgres;

REVOKE all on function public.update_sub(text,boolean,integer) from public;
REVOKE all on function public.update_sub(text,boolean,integer) from anon,authenticated;
grant all on function public.update_sub(text,boolean,integer) to postgres;
