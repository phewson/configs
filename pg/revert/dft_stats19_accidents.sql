-- Revert official_stats:accidents from pg

BEGIN;
drop table dft.stats19_accidents cascade;
drop function dft.import_dft_stats19_accidents();
drop function dft.import_dft_stats19_accidents_7904_0514();

COMMIT;
