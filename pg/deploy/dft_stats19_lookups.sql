-- Deploy official_stats:stats19_lookups to pg

BEGIN;
create table dft.stats19_lookup_police_force (
    stats19_code int,
    name text,
    primary key(stats19_code)
);

create table dft.stats19_lookup_lad (
    stats19_code int,
    name text,
    primary key(stats19_code)
);

create table dft.stats19_lookup_vehicle_type (
    stats19_code int,
    vehicle_name text,
    occupant_name text,
    primary key(stats19_code)
);

create function dft.import_dft_stats19_lookups() returns void
as $$
declare
begin
    insert into dft.stats19_lookup_police_force (
        stats19_code,
        name
    )
    select stats19_code,
           name
        from staging.dft_stats19_lookup_police_force
    ;
    insert into dft.stats19_lookup_lad (
        stats19_code,
        name
    )
    select stats19_code,
           name
        from staging.dft_stats19_lookup_lad
    ;
    insert into dft.stats19_lookup_vehicle_type (
        stats19_code,
        vehicle_name,
        occupant_name
    )
    select stats19_code,
           vehicle_name,
           occupant_name
        from staging.dft_stats19_lookup_vehicle_type
    ;
end
$$ language plpgsql;
COMMIT;
