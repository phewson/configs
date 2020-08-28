-- Deploy official_stats:accidents to pg

BEGIN;
create table dft.stats19_accidents (
        accident_index text not null,
        grid_x int,
        grid_y int,
        longitude float8,
        latitude float8,
        geom geometry(point, 4326),
        police_force int,
        accident_severity dft.stats19_severity,
        number_of_vehicles int,
        number_of_casualties int,
        obs_date timestamp,
        lad_stats19 int,
        lah_ons text,
        first_road_class dft.stats19_first_road_class,
        first_road_number int,
        road_type dft.stats19_road_type,
        speed_limit_mph int,
        junction_detail dft.stats19_junction_type,
        junction_control dft.stats19_junction_control,
        second_road_class dft.stats19_second_road_class,
        second_road_number int,
        pedestrian_crossing_human_control dft.stats19_pedestrian_crossing_human_control,
        pedestrian_crossing_physical_facilities dft.stats19_pedestrian_crossing_physical_control,
        light_conditions dft.stats19_light,
        weather_conditions dft.stats19_weather,
        road_surface_conditions dft.stats19_road_surface,
        special_conditions_at_site dft.stats19_special_conditions_at_site,
        carriageway_hazards dft.stats19_carriageway_hazards,
        urban_or_rural_area dft.stats19_urban_rural,
        did_police_officer_attend_scene_of_accident dft.stats19_did_police_officer_attend,
        lsoa_of_accident_location text,
        primary key(accident_index)
        --comment out foreign key constrains as causes issues with truncate and update functions
        --foreign key(police_force) references public.dft_stats19_lookup_police_force(stats19_code),
        --foreign key(lad_stats19) references public.dft_stats19_lookup_lad(stats19_code)
);

-- table is so large it is quite slow, add some indexes on common filter terms
create unique index on dft.stats19_accidents (accident_index);
create index dft_stats19_accidents_gix on dft.stats19_accidents using gist (geom);
create index on dft.stats19_accidents (police_force);
create index on dft.stats19_accidents (obs_date);
create index on dft.stats19_accidents (lad_stats19);
create index on dft.stats19_accidents (lah_ons);
create index on dft.stats19_accidents (lsoa_of_accident_location);

create function dft.import_dft_stats19_accidents() returns void
as $$
declare
begin
    insert into dft.stats19_accidents(
        accident_index,
        grid_x,
        grid_y,
        longitude,
        latitude,
        geom,
        police_force,
        accident_severity,
        number_of_vehicles,
        number_of_casualties,
        obs_date,
        lad_stats19,
        lah_ons,
        first_road_class,
        first_road_number,
        road_type,
        speed_limit_mph,
        junction_detail,
        junction_control,
        second_road_class,
        second_road_number,
        pedestrian_crossing_human_control,
        pedestrian_crossing_physical_facilities,
        light_conditions,
        weather_conditions,
        road_surface_conditions,
        special_conditions_at_site,
        carriageway_hazards,
        urban_or_rural_area,
        did_police_officer_attend_scene_of_accident,
        lsoa_of_accident_location
        )
        select
            accident_index,
            nullif(nullif(location_easting_osgr, ''), 'NULL')::int,
            nullif(nullif(location_northing_osgr, ''), 'NULL')::int,
            nullif(nullif(longitude, ''), 'NULL')::float,
            nullif(nullif(latitude, ''), 'NULL')::float,
            st_transform(
                st_setsrid(
                    st_makepoint(nullif(nullif(location_easting_osgr, ''), 'NULL')::int,
                                 nullif(nullif(location_northing_osgr, ''), 'NULL')::int), 27700), 4326),
            police_force,
            (enum_range(null::dft.stats19_severity))[accident_severity],
            number_of_vehicles,
            number_of_casualties,
            to_timestamp(date::text || ' ' || time::text, 'DD/MM/YYYY HH24:MI'),
            local_authority_xdistrictx,
            local_authority_xhighwaysx,
            (enum_range(null::dft.stats19_first_road_class))[first_road_class],
            nullif(first_road_number, 0),
            (enum_range(null::dft.stats19_road_type))[road_type],
            nullif(nullif(speed_limit, ''), 'NULL')::int,
            (enum_range(null::dft.stats19_junction_type))[nullif(junction_detail,-1)+1],
            (enum_range(null::dft.stats19_junction_control))[nullif(junction_control, -1)+1],
            (enum_range(null::dft.stats19_second_road_class))[nullif(second_road_class,-1)],
            nullif(second_road_number, 0),
            (enum_range(null::dft.stats19_pedestrian_crossing_human_control))[pedestrian_crossing_human_control+1],
            (enum_range(null::dft.stats19_pedestrian_crossing_physical_control))[pedestrian_crossing_physical_facilities+1],
            (enum_range(null::dft.stats19_light))[light_conditions],
            (enum_range(null::dft.stats19_weather))[weather_conditions],
            (enum_range(null::dft.stats19_road_surface))[road_surface_conditions],
            (enum_range(null::dft.stats19_special_conditions_at_site))[special_conditions_at_site+1],
            (enum_range(null::dft.stats19_carriageway_hazards))[carriageway_hazards+1],
            (enum_range(null::dft.stats19_urban_rural))[urban_or_rural_area],
            (enum_range(null::dft.stats19_did_police_officer_attend))[did_police_officer_attend_scene_of_accident],
            lsoa_of_accident_location
            from staging.dft_stats19_accidents
            ;
    end
$$ language plpgsql;


create function dft.import_dft_stats19_accidents_7904_0514() returns void
as $$
declare
begin
insert into dft.stats19_accidents(
        accident_index,
        grid_x,
        grid_y,
        longitude,
        latitude,
        geom,
        police_force,
        accident_severity,
        number_of_vehicles,
        number_of_casualties,
        obs_date,
        lad_stats19,
        lah_ons,
        first_road_class,
        first_road_number,
        road_type,
        speed_limit_mph,
        junction_detail,
        junction_control,
        second_road_class,
        second_road_number,
        pedestrian_crossing_human_control,
        pedestrian_crossing_physical_facilities,
        light_conditions,
        weather_conditions,
        road_surface_conditions,
        special_conditions_at_site,
        carriageway_hazards,
        urban_or_rural_area,
        did_police_officer_attend_scene_of_accident,
        lsoa_of_accident_location
        )
        select
            accident_index,
            nullif(nullif(location_easting_osgr, ''), 'NULL')::int,
            nullif(nullif(location_northing_osgr, ''), 'NULL')::int,
            nullif(nullif(longitude, ''), 'NULL')::float,
            nullif(nullif(latitude, ''), 'NULL')::float,
            st_transform(
                st_setsrid(
                    st_makepoint(nullif(nullif(location_easting_osgr, ''), 'NULL')::int,
                                 nullif(nullif(location_northing_osgr, ''), 'NULL')::int), 27700), 4326),
            police_force,
            (enum_range(null::dft.stats19_severity))[accident_severity],
            number_of_vehicles,
            number_of_casualties,
            to_timestamp(date::text || ' ' || time::text, 'DD/MM/YYYY HH24:MI'),
            local_authority_xdistrictx,
            local_authority_xhighwaysx,
            (enum_range(null::dft.stats19_first_road_class))[first_road_class],
            first_road_number,
            (enum_range(null::dft.stats19_road_type))[road_type],
            nullif(nullif(nullif(speed_limit, ''), '-1'), 'NULL')::int,
            (enum_range(null::dft.stats19_junction_type))[nullif(junction_detail,-1)+1],
            (enum_range(null::dft.stats19_junction_control))[nullif(junction_control, -1)+1],
            (enum_range(null::dft.stats19_second_road_class))[nullif(second_road_class,-1)],
            second_road_number,
            (enum_range(null::dft.stats19_pedestrian_crossing_human_control))[pedestrian_crossing_human_control+1],
            (enum_range(null::dft.stats19_pedestrian_crossing_physical_control))[pedestrian_crossing_physical_facilities+1],
            (enum_range(null::dft.stats19_light))[light_conditions],
            (enum_range(null::dft.stats19_weather))[weather_conditions],
            (enum_range(null::dft.stats19_road_surface))[road_surface_conditions],
            (enum_range(null::dft.stats19_special_conditions_at_site))[special_conditions_at_site+1],
            (enum_range(null::dft.stats19_carriageway_hazards))[carriageway_hazards+1],
            (enum_range(null::dft.stats19_urban_rural))[urban_or_rural_area],
            (enum_range(null::dft.stats19_did_police_officer_attend))[did_police_officer_attend_scene_of_accident],
            lsoa_of_accident_location
            from staging.dft_stats19_accidents_7904_0514
            where time != 'NULL'
    ;
    end
$$ language plpgsql;
COMMIT;
