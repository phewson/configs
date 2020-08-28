-- Deploy official_stats:casualties to pg

BEGIN;
create table dft.stats19_casualties (
     accident_index text,
     vehicle_reference  int,
     casualty_reference int,
     casualty_class  dft.stats19_casualty_class ,
     sex_of_casualty dft.stats19_sex_of_casualty,
     age_of_casualty int,
     age_band_of_casualty dft.stats19_age_band_of_driver,
     casualty_severity dft.stats19_severity,
     pedestrian_location dft.stats19_pedestrian_location,
     pedestrian_movement dft.stats19_pedestrian_movement,
     car_passenger dft.stats19_car_passenger,
     bus_or_coach_passenger dft.stats19_bus_passenger,
     pedestrian_road_maintenance_worker dft.stats19_ped_road_maintenance_worker,
     casualty_type int,
     casualty_home_area_type dft.stats19_home_area_type ---,
     ---primary key(accident_index, casualty_reference, vehicle_reference)
     --comment out foreign key constrains as causes issues with truncate and update functions
     --foreign key(accident_index) references public.dft_stats19_accidents(accident_index),
     --foreign key(casualty_type) references public.dft_stats19_lookup_vehicle_type(stats19_code)
);

create index on dft.stats19_casualties (accident_index, casualty_reference);

--- for reasons i don't understand i can't apply the primary key (accident_index, casualty_reference)
--- there are about 12 accidents with badly numbered casualties
--- revisit accident_index at some stage 200597ec70504

create function dft.import_dft_stats19_casualties() returns void
as $$
declare
begin
    insert into dft.stats19_casualties (
        accident_index,
        vehicle_reference,
        casualty_reference,
        casualty_class,
        sex_of_casualty,
        age_of_casualty,
        age_band_of_casualty,
        casualty_severity,
        pedestrian_location,
        pedestrian_movement,
        car_passenger,
        bus_or_coach_passenger,
        pedestrian_road_maintenance_worker,
        casualty_type,
        casualty_home_area_type)
        select
            accident_index,
            vehicle_reference,
            casualty_reference,
            (enum_range(null::dft.stats19_casualty_class))[casualty_class],
            (enum_range(null::dft.stats19_sex_of_casualty))[nullif(sex_of_casualty,-1)] ,
            age_of_casualty,
            (enum_range(null::dft.stats19_age_band_of_driver))[nullif(age_band_of_casualty,-1)],
            (enum_range(null::dft.stats19_severity))[casualty_severity] ,
            (enum_range(null::dft.stats19_pedestrian_location))[nullif(pedestrian_location,-1)+1],
            (enum_range(null::dft.stats19_pedestrian_movement))[nullif(pedestrian_movement,-1)+1],
            (enum_range(null::dft.stats19_car_passenger))[nullif(car_passenger,-1)+1],
            (enum_range(null::dft.stats19_bus_passenger))[nullif(bus_or_coach_passenger,-1)+1],
            (enum_range(null::dft.stats19_ped_road_maintenance_worker))[nullif(pedestrian_road_maintenance_worker,-1)+1] ,
            nullif(casualty_type,-1),
            (enum_range(null::dft.stats19_home_area_type))[nullif(casualty_home_area_type,-1)]
            from staging.dft_stats19_casualties1518
    ;
    insert into dft.stats19_casualties (
        accident_index,
        vehicle_reference,
        casualty_reference,
        casualty_class,
        sex_of_casualty,
        age_of_casualty,
        age_band_of_casualty,
        casualty_severity,
        pedestrian_location,
        pedestrian_movement,
        car_passenger,
        bus_or_coach_passenger,
        pedestrian_road_maintenance_worker,
        casualty_type,
        casualty_home_area_type)
        select
            accident_index,
            vehicle_reference,
            casualty_reference,
            (enum_range(null::dft.stats19_casualty_class))[casualty_class],
            (enum_range(null::dft.stats19_sex_of_casualty))[nullif(sex_of_casualty,-1)] ,
            age_of_casualty,
            (enum_range(null::dft.stats19_age_band_of_driver))[nullif(age_band_of_casualty,-1)],
            (enum_range(null::dft.stats19_severity))[casualty_severity] ,
            (enum_range(null::dft.stats19_pedestrian_location))[nullif(pedestrian_location,-1)+1],
            (enum_range(null::dft.stats19_pedestrian_movement))[nullif(pedestrian_movement,-1)+1],
            (enum_range(null::dft.stats19_car_passenger))[nullif(car_passenger,-1)+1],
            (enum_range(null::dft.stats19_bus_passenger))[nullif(bus_or_coach_passenger,-1)+1],
            (enum_range(null::dft.stats19_ped_road_maintenance_worker))[nullif(pedestrian_road_maintenance_worker,-1)+1] ,
            nullif(casualty_type,-1),
            (enum_range(null::dft.stats19_home_area_type))[nullif(casualty_home_area_type,-1)]
            from staging.dft_stats19_casualties0514
    ;
    insert into dft.stats19_casualties (
        accident_index,
        vehicle_reference,
        casualty_reference,
        casualty_class,
        sex_of_casualty,
        age_band_of_casualty,
        casualty_severity,
        pedestrian_location,
        pedestrian_movement,
        car_passenger,
        bus_or_coach_passenger,
        pedestrian_road_maintenance_worker,
        casualty_type,
        casualty_home_area_type)
        select
            accident_index,
            vehicle_reference,
            casualty_reference,
            (enum_range(null::dft.stats19_casualty_class))[casualty_class],
            (enum_range(null::dft.stats19_sex_of_casualty))[nullif(sex_of_casualty,-1)] ,
            (enum_range(null::dft.stats19_age_band_of_driver))[nullif(age_band_of_casualty,-1)],
            (enum_range(null::dft.stats19_severity))[casualty_severity] ,
            (enum_range(null::dft.stats19_pedestrian_location))[nullif(pedestrian_location,-1)+1],
            (enum_range(null::dft.stats19_pedestrian_movement))[nullif(pedestrian_movement,-1)+1],
            (enum_range(null::dft.stats19_car_passenger))[nullif(car_passenger,-1)+1],
            (enum_range(null::dft.stats19_bus_passenger))[nullif(bus_or_coach_passenger,-1)+1],
            (enum_range(null::dft.stats19_ped_road_maintenance_worker))[nullif(pedestrian_road_maintenance_worker,-1)+1] ,
            nullif(casualty_type,-1),
            (enum_range(null::dft.stats19_home_area_type))[nullif(casualty_home_area_type,-1)]
            from staging.dft_stats19_casualties7904
    ;
end
$$ language plpgsql;
COMMIT;
