#!/bin/bash
set -e; set -u;

INPUTc2015z="$HOME/data/dft/RoadSafetyData_Casualties_2015.zip"
[[ -f "$INPUTc2015z" ]] || { >&2 echo "Missing input file: [$INPUTc2015z]" ; exit 5 ; }

INPUTc2016z="$HOME/data/dft/dftRoadSafetyData_Casualties_2016.zip"
[[ -f "$INPUTc2016z" ]] || { >&2 echo "Missing input file: [$INPUTc2016z]" ; exit 5 ; }

INPUTc2017z="$HOME/data/dft/dftRoadSafetyData_Casualties_2017.zip"
[[ -f "$INPUTc2017z" ]] || { >&2 echo "Missing input file: [$INPUTc2017z]" ; exit 5 ; }

INPUTc2018="$HOME/data/dft/dftRoadSafetyData_Casualties_2018.csv"
[[ -f "$INPUTc2018" ]] || { >&2 echo "Missing input file: [$INPUTc2018]" ; exit 5 ; }

INPUTc7904="$HOME/data/dft/Casualty7904.csv"
[[ -f "$INPUTc7904" ]] || { >&2 echo "Missing input file: [$INPUTc7904]" ; exit 5 ; }

INPUT0514z="$HOME/data/dft/Stats19_Data_2005-2014.zip"
[[ -f "$INPUT0514z" ]] || { >&2 echo "Missing input file: [$INPUT0514z]" ; exit 5 ; }


cat <<EOF
    DROP TABLE if exists staging.dft_stats19_casualties1518;
    CREATE UNLOGGED TABLE staging.dft_stats19_casualties1518 (
        Accident_Index text,
        Vehicle_Reference  int,
        Casualty_Reference int,
        Casualty_Class int,
        Sex_of_Casualty int,
        Age_of_Casualty int,
        Age_Band_of_Casualty int,
        Casualty_Severity int,
        Pedestrian_Location int,
        Pedestrian_Movement int,
        Car_Passenger int,
        Bus_or_Coach_Passenger int,
        Pedestrian_Road_Maintenance_Worker int,
        Casualty_Type int,
        Casualty_Home_Area_Type int,
        Casualty_IMD_Decile int
    );

    DROP TABLE if exists staging.dft_stats19_casualties0514;
    CREATE UNLOGGED TABLE staging.dft_stats19_casualties0514 (
        Accident_Index text,
        Vehicle_Reference  int,
        Casualty_Reference int,
        Casualty_Class int,
        Sex_of_Casualty int,
        Age_of_Casualty int,
        Age_Band_of_Casualty int,
        Casualty_Severity int,
        Pedestrian_Location int,
        Pedestrian_Movement int,
        Car_Passenger int,
        Bus_or_Coach_Passenger int,
        Pedestrian_Road_Maintenance_Worker int,
        Casualty_Type int,
        Casualty_Home_Area_Type int
    );

    DROP TABLE if exists staging.dft_stats19_casualties7904;
    CREATE UNLOGGED TABLE staging.dft_stats19_casualties7904 (
        Accident_Index text,
        Vehicle_Reference  int,
        Casualty_Reference int,
        Casualty_Class int,
        Sex_of_Casualty int,
        Age_Band_of_Casualty int,
        Casualty_Severity int,
        Pedestrian_Location int,
        Pedestrian_Movement int,
        Car_Passenger int,
        Bus_or_Coach_Passenger int,
        Pedestrian_Road_Maintenance_Worker int,
        Casualty_Type int,
        Casualty_Home_Area_Type int
    );

EOF

   echo "\\copy staging.dft_stats19_casualties1518 FROM stdin delimiter ',' csv header;"
   unzip -p "$INPUTc2015z" Casualties_2015.csv && echo '\.'
   echo "\\copy staging.dft_stats19_casualties1518 FROM stdin delimiter ',' csv header;"
   unzip -p "$INPUTc2016z" Cas.csv && echo '\.'
   echo "\\copy staging.dft_stats19_casualties1518 FROM stdin delimiter ',' csv header;"
   unzip -p "$INPUTc2017z" Cas.csv && echo '\.'

   echo "\\copy staging.dft_stats19_casualties1518 FROM '$INPUTc2018' delimiter ',' csv header;"

   echo "\\copy staging.dft_stats19_casualties0514 FROM stdin delimiter ',' csv header;"
   unzip -p "$INPUT0514z" Casualties0514.csv && echo '\.'

   echo "\\copy staging.dft_stats19_casualties7904 FROM '$INPUTc7904' delimiter ',' csv header;"
   
   echo "SELECT dft.import_dft_stats19_casualties();"

