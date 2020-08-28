-- Revert official_stats:vehicles from pg

BEGIN;
drop table dft.stats19_vehicles cascade;
drop function dft.import_dft_stats19_vehicles();
COMMIT;
