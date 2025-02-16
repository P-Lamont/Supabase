CREATE UNIQUE INDEX barangays_id_key ON public.barangays USING btree (id);

CREATE UNIQUE INDEX distancetable_id_key ON public.distancetable USING btree (id);

CREATE UNIQUE INDEX driverlogs_id_key ON public.driverlogs USING btree (id);

CREATE UNIQUE INDEX kmsegments_table_id_key ON public.kmsegments USING btree (table_id);

CREATE UNIQUE INDEX municipalities_id_key ON public.municipalities USING btree (id);

CREATE UNIQUE INDEX nodescode_code_key ON public.nodescode USING btree (code);

CREATE UNIQUE INDEX nodescode_nodes_key ON public.nodescode USING btree (nodes);

CREATE UNIQUE INDEX organization_id_key ON public.organization USING btree (id);

CREATE UNIQUE INDEX pasada_driver_key ON public.pasada USING btree (driver);

CREATE UNIQUE INDEX profile_id_key ON public.profile USING btree (id);

CREATE UNIQUE INDEX provinces_province_key ON public.provinces USING btree (province);

CREATE UNIQUE INDEX roles_id_key ON public.roles USING btree (id);

CREATE UNIQUE INDEX roles_roles_key ON public.roles USING btree (roles);

CREATE UNIQUE INDEX route_table_id_key ON public.route_table USING btree (id);

CREATE UNIQUE INDEX v_types_id_key ON public.v_types USING btree (id);

CREATE UNIQUE INDEX v_types_type_key ON public.v_types USING btree (type);

alter table "public"."barangays" add constraint "barangays_id_key" UNIQUE using index "barangays_id_key";

alter table "public"."distancetable" add constraint "distancetable_id_key" UNIQUE using index "distancetable_id_key";

alter table "public"."driverlogs" add constraint "driverlogs_id_key" UNIQUE using index "driverlogs_id_key";

alter table "public"."kmsegments" add constraint "kmsegments_table_id_key" UNIQUE using index "kmsegments_table_id_key";

alter table "public"."municipalities" add constraint "municipalities_id_key" UNIQUE using index "municipalities_id_key";

alter table "public"."nodescode" add constraint "nodescode_code_key" UNIQUE using index "nodescode_code_key";

alter table "public"."nodescode" add constraint "nodescode_nodes_key" UNIQUE using index "nodescode_nodes_key";

alter table "public"."organization" add constraint "organization_id_key" UNIQUE using index "organization_id_key";

alter table "public"."pasada" add constraint "pasada_driver_key" UNIQUE using index "pasada_driver_key";

alter table "public"."profile" add constraint "profile_id_key" UNIQUE using index "profile_id_key";

alter table "public"."provinces" add constraint "provinces_province_key" UNIQUE using index "provinces_province_key";

alter table "public"."roles" add constraint "roles_id_key" UNIQUE using index "roles_id_key";

alter table "public"."roles" add constraint "roles_roles_key" UNIQUE using index "roles_roles_key";

alter table "public"."route_table" add constraint "route_table_id_key" UNIQUE using index "route_table_id_key";

alter table "public"."v_types" add constraint "v_types_id_key" UNIQUE using index "v_types_id_key";

alter table "public"."v_types" add constraint "v_types_type_key" UNIQUE using index "v_types_type_key";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.distance_driver_passenger(segment_array text[])
 RETURNS real
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$DECLARE
	partial_sum real;
BEGIN
    -- Transform input_array to segment_array

	with filtered_distance as(
		select distance,
			start_node||'-'||end_node as start_end
		from public.distancetable
	)
	select ceil(sum(distance)) into partial_sum
	from filtered_distance
	where start_end = any(segment_array);
	return partial_sum;	
END;$function$
;

CREATE OR REPLACE FUNCTION public.inbetween_segmental_distance(input_array text[], driver_index integer, passenger_index integer)
 RETURNS real
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$DECLARE
    segment_array TEXT[] := '{}';
    partial_sum real;
BEGIN
    -- Transform input_array to segment_array
	segment_array :=public.combine_segment_array(
		input_array,least(driver_index,passenger_index),greatest(driver_index,passenger_index)
		);
	partial_sum:=public.distance_driver_passenger(segment_array);
	return partial_sum;
END;$function$
;


