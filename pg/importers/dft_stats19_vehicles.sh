#!/bin/bash
set -e; set -u;

INPUTv2015z="$HOME/data/dft/RoadSafetyData_Vehicles_2015.zip"
[[ -f "$INPUTv2015z" ]] || { >&2 echo "Missing input file: [$INPUTv2015z]" ; exit 5 ; }

INPUTv2016z="$HOME/data/dft/dftRoadSafetyData_Vehicles_2016.zip"
[[ -f "$INPUTv2016z" ]] || { >&2 echo "Missing input file: [$INPUTv2016z]" ; exit 5 ; }

INPUTv2017z="$HOME/data/dft/dftRoadSafetyData_Vehicles_2017.zip"
[[ -f "$INPUTv2017z" ]] || { >&2 echo "Missing input file: [$INPUTv2017z]" ; exit 5 ; }

INPUTv2018="$HOME/data/dft/dftRoadSafetyData_Vehicles_2018.csv"
[[ -f "$INPUTv2018" ]] || { >&2 echo "Missing input file: [$INPUTv2018]" ; exit 5 ; }

INPUTv7904="$HOME/data/dft/Vehicles7904.csv"
[[ -f "$INPUTv7904" ]] || { >&2 echo "Missing input file: [$INPUTv7904]" ; exit 5 ; }

INPUT0514z="$HOME/data/dft/Stats19_Data_2005-2014.zip"
[[ -f "$INPUT0514z" ]] || { >&2 echo "Missing input file: [$INPUT0514z]" ; exit 5 ; }


cat <<EOF
    DROP TABLE if exists staging.dft_stats19_vehicles;
    CREATE UNLOGGED TABLE staging.dft_stats19_vehicles (
        Accident_Index text,
        Vehicle_Reference int,
        Vehicle_Type int,
        Towing_and_Articulation int,
        Vehicle_Manoeuvre int,
        Vehicle_Location_Restricted_Lane int,
        Junction_Location int,
        Skidding_and_Overturning int,
        Hit_Object_in_Carriageway int,
        Vehicle_Leaving_Carriageway int,
        Hit_Object_off_Carriageway int,
        First_Point_of_Impact int,
        Was_Vehicle_Left_Hand_Drivex int,
        Journey_Purpose_of_Driver int,
        Sex_of_Driver int,
        Age_of_Driver int,
        Age_Band_of_Driver int,
        Engine_Capacity_xCCx float8,
        Propulsion_Code int,
        Age_of_Vehicle int,
        Driver_IMD_Decile int,
        Driver_Home_Area_Type int,
        Vehicle_IMD_Decile int
    );

    DROP TABLE if exists staging.dft_stats19_vehicles0514;
    CREATE UNLOGGED TABLE staging.dft_stats19_vehicles0514 (
         Accident_Index text,
         Vehicle_Reference int,
         Vehicle_Type int,
         Towing_and_Articulation int,
         Vehicle_Manoeuvre int,
         Vehicle_Location_Restricted_Lane int,
         Junction_Location int,
         Skidding_and_Overturning int,
         Hit_Object_in_Carriageway int,
         Vehicle_Leaving_Carriageway int,
         Hit_Object_off_Carriageway int,
         First_Point_of_Impact int,
         Was_Vehicle_Left_Hand_Drivex int,
         Journey_Purpose_of_Driver int,
         Sex_of_Driver int,
         Age_of_Driver int,
         Age_Band_of_Driver int,
         Engine_Capacity_xCCx float8,
         Propulsion_Code int,
         Age_of_Vehicle int,
         Driver_IMD_Decile int,
         Driver_Home_Area_Type int
    );

    DROP TABLE if exists staging.dft_stats19_vehicles7904;
    CREATE UNLOGGED TABLE staging.dft_stats19_vehicles7904 (
         Accident_Index text,
         Vehicle_Reference int,
         Vehicle_Type int,
         Towing_and_Articulation int,
         Vehicle_Manoeuvre int,
         Vehicle_Location_Restricted_Lane int,
         Junction_Location int,
         Skidding_and_Overturning int,
         Hit_Object_in_Carriageway int,
         Vehicle_Leaving_Carriageway int,
         Hit_Object_off_Carriageway int,
         First_Point_of_Impact int,
         Was_Vehicle_Left_Hand_Drivex int,
         Journey_Purpose_of_Driver int,
         Sex_of_Driver int,
         Age_Band_of_Driver int,
         Engine_Capacity_xCCx float8,
         Propulsion_Code int,
         Age_of_Vehicle int,
         Driver_IMD_Decile int,
         Driver_Home_Area_Type int
    );

EOF

   echo "\\copy staging.dft_stats19_vehicles FROM stdin delimiter ',' csv header;"
   unzip -p "$INPUTv2015z" Vehicles_2015.csv && echo '\.'
   echo "\\copy staging.dft_stats19_vehicles FROM stdin delimiter ',' csv header;"
   unzip -p "$INPUTv2016z" Veh.csv && echo '\.'
   echo "\\copy staging.dft_stats19_vehicles FROM stdin delimiter ',' csv header;"
   unzip -p "$INPUTv2017z" Veh.csv && echo '\.'

   echo "\\copy staging.dft_stats19_vehicles FROM '$INPUTv2018' delimiter ',' csv header;"

   echo "\\copy staging.dft_stats19_vehicles0514 FROM stdin delimiter ',' csv header;"
   unzip -p "$INPUT0514z" Vehicles0514.csv && echo '\.'

   echo "\\copy staging.dft_stats19_vehicles7904 FROM '$INPUTv7904' delimiter ',' csv header;"
   
   echo "SELECT dft.import_dft_stats19_vehicles();"

