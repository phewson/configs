-- Revert official_stats:casualties from pg

BEGIN;
drop table dft.stats19_casualties cascade;
drop function dft.import_dft_stats19_casualties();
COMMIT;
