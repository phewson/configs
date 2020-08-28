#!/bin/bash
set -e; set -u;

INPUTa2015z="$HOME/data/dft/RoadSafetyData_Accidents_2015.zip"
[[ -f "$INPUTa2015z" ]] || { >&2 echo "Missing input file: [$INPUTa2015z]" ; exit 5 ; }

INPUTa2016z="$HOME/data/dft/dftRoadSafety_Accidents_2016.zip"
[[ -f "$INPUTa2016z" ]] || { >&2 echo "Missing input file: [$INPUTa2016z]" ; exit 5 ; }

INPUTa2017z="$HOME/data/dft/dftRoadSafetyData_Accidents_2017.zip"
[[ -f "$INPUTa2017z" ]] || { >&2 echo "Missing input file: [$INPUTa2017z]" ; exit 5 ; }

INPUTa2018="$HOME/data/dft/dftRoadSafetyData_Accidents_2018.csv"
[[ -f "$INPUTa2018" ]] || { >&2 echo "Missing input file: [$INPUTa2018]" ; exit 5 ; }

INPUT0514z="$HOME/data/dft/Stats19_Data_2005-2014.zip"
[[ -f "$INPUT0514z" ]] || { >&2 echo "Missing input file: [$INPUT0514z]" ; exit 5 ; }

INPUTa7904="$HOME/data/dft/Accidents7904.csv"
[[ -f "$INPUT0514z" ]] || { >&2 echo "Missing input file: [$INPUT0514z]" ; exit 5 ; }


cat <<EOF
    DROP TABLE if exists staging.dft_stats19_accidents;
    CREATE UNLOGGED TABLE staging.dft_stats19_accidents (
        Accident_Index text,
        Location_Easting_OSGR text,
        Location_Northing_OSGR text,
        Longitude text,
        Latitude text,
        Police_Force int,
        Accident_Severity int,
        Number_of_Vehicles int,
        Number_of_Casualties int,
        Date text,
        Day_of_Week int,
        Time text,
        Local_Authority_xDistrictx int,
        Local_Authority_xHighwaysx text,
        First_Road_Class int,
        First_Road_Number int,
        Road_Type int,
        Speed_limit text,
        Junction_Detail int,
        Junction_Control int,
        Second_Road_Class int,
        Second_Road_Number int,
        Pedestrian_Crossing_Human_Control int,
        Pedestrian_Crossing_Physical_Facilities int,
        Light_Conditions int,
        Weather_Conditions int,
        Road_Surface_Conditions int,
        Special_Conditions_at_Site int,
        Carriageway_Hazards int,
        Urban_or_Rural_Area int,
        Did_Police_Officer_Attend_Scene_of_Accident int,
        LSOA_of_Accident_Location text
     );

    DROP TABLE if exists staging.dft_stats19_accidents_7904_0514;
    CREATE UNLOGGED TABLE staging.dft_stats19_accidents_7904_0514 (
        Accident_Index text,
        Location_Easting_OSGR text,
        Location_Northing_OSGR text,
        Longitude text,
        Latitude text,
        Police_Force int,
        Accident_Severity int,
        Number_of_Vehicles int,
        Number_of_Casualties int,
        Date text,
        Day_of_Week int,
        Time text,
        Local_Authority_xDistrictx int,
        Local_Authority_xHighwaysx text,
        First_Road_Class int,
        First_Road_Number int,
        Road_Type int,
        Speed_limit text,
        Junction_Detail int,
        Junction_Control int,
        Second_Road_Class int,
        Second_Road_Number int,
        Pedestrian_Crossing_Human_Control int,
        Pedestrian_Crossing_Physical_Facilities int,
        Light_Conditions int,
        Weather_Conditions int,
        Road_Surface_Conditions int,
        Special_Conditions_at_Site int,
        Carriageway_Hazards int,
        Urban_or_Rural_Area int,
        Did_Police_Officer_Attend_Scene_of_Accident int,
        LSOA_of_Accident_Location text
    );

EOF
   echo "\\copy staging.dft_stats19_accidents FROM stdin delimiter ',' csv header;"
   unzip -p "$INPUTa2015z" Accidents_2015.csv && echo '\.'
   echo "\\copy staging.dft_stats19_accidents FROM stdin delimiter ',' csv header;"
   unzip -p "$INPUTa2016z" dftRoadSafety_Accidents_2016.csv && echo '\.'
   echo "\\copy staging.dft_stats19_accidents FROM stdin delimiter ',' csv header ;"
   unzip -p "$INPUTa2017z" Acc.csv && echo '\.'

   echo "\\copy staging.dft_stats19_accidents FROM '$INPUTa2018' delimiter ',' csv header;"

   echo "\\copy staging.dft_stats19_accidents_7904_0514 FROM stdin delimiter ',' csv header;"
   unzip -p "$INPUT0514z" Accidents0514.csv && echo '\.'

   echo "\\copy staging.dft_stats19_accidents_7904_0514 FROM '$INPUTa7904' delimiter ',' csv header;"
  
   echo "SELECT dft.import_dft_stats19_accidents();"
   echo "SELECT dft.import_dft_stats19_accidents_7904_0514();"
