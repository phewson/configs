-- Revert official_stats:stats19_lookups from pg

BEGIN;
drop table dft.stats19_lookup_police_force;
drop table dft.stats19_lookup_lad;
drop table dft.stats19_lookup_vehicle_type;
drop function dft.import_dft_stats19_lookups();
COMMIT;
