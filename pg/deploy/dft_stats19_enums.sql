-- Deploy analytics-queries:enums to pg

BEGIN;
do $$ begin
    if not exists (select 1 from pg_type where typname = 'stats19_first_road_class' and typnamespace::regnamespace = 'dft'::regnamespace) then
        create type dft.stats19_first_road_class as enum ('M', 'A(M)', 'A', 'B', 'C', 'U');
    --- the codebook has different codes for first road class and second road class.
    end if;
    if not exists (select 1 from pg_type where typname = 'stats19_second_road_class' and typnamespace::regnamespace = 'dft'::regnamespace) then
        create type dft.stats19_second_road_class as enum ('Not at junction', 'M', 'A(M)', 'A', 'B', 'C' ,'U');
    --- the codebook has different codes for first road class and second road class.
    end if;
    if not exists (select 1 from pg_type where typname = 'stats19_severity' and typnamespace::regnamespace = 'dft'::regnamespace) then
        create type dft.stats19_severity as enum ('Fatal', 'Serious', 'Slight');
    end if;
    if not exists (select 1 from pg_type where typname = 'stats19_junction_type' and typnamespace::regnamespace = 'dft'::regnamespace) then
        create type dft.stats19_junction_type as enum ('Not a junction', 'Roundabout', 'Mini-roundabout', 'T or staggered junction','Not used', 'Slip road', 'Crossroads',
            'More than 4 arms (not roundabout)', 'Private drive or entrance', 'Other junction');
    -- the codebook has a zero code for not a junction.
    end if;
    if not exists (select 1 from pg_type where typname = 'stats19_junction_control' and typnamespace::regnamespace = 'dft'::regnamespace) then
        create type dft.stats19_junction_control as enum ('Not a junction', 'Authorised person', 'Auto traffic signal', 'Stop sign', 'Give way or uncontrolled');
    end if;
    --- the codebook has a zero code for not a junction.
    if not exists (select 1 from pg_type where typname = 'stats19_road_type' and typnamespace::regnamespace = 'dft'::regnamespace) then
        create type dft.stats19_road_type as enum ('Roundabout', 'One way street', 'Dual carriageway', 'Placeholder 4', 'Placeholder 5',
        'Single carriageway', 'Slip road', 'Placeholder 8', 'Unknown', 'Placeholder 10',
        'Placeholder 11' ,'One way street or Slip road');
    end if;
    -- the codebook has a zero code for not a junction.
    if not exists (select 1 from pg_type where typname = 'stats19_pedestrian_crossing_human_control' and typnamespace::regnamespace = 'dft'::regnamespace) then
        create type dft.stats19_pedestrian_crossing_human_control as enum ('None', 'Control by school crossing patrol', 'Control by other authorised person');
    end if;
    --- the codebook has 0 for none within 50 metres
    if not exists (select 1 from pg_type where typname = 'stats19_pedestrian_crossing_physical_control' and typnamespace::regnamespace = 'dft'::regnamespace) then
        create type dft.stats19_pedestrian_crossing_physical_control as enum ('None', 'Zebra', 'Placeholder 2' ,'Placeholder 3' ,'Pelican',
        'Pedestrian phase at traffic signal junction', 'Placeholder 6', 'Footbridge or subway' ,'Central Refuge');
    end if;
    --- the codebook has 0 for none within 50 metres
    if not exists (select 1 from pg_type where typname = 'stats19_light' and typnamespace::regnamespace = 'dft'::regnamespace) then
        create type dft.stats19_light as enum ('Daylight', 'Placeholder 2', 'Placeholder 3', 'Darkness - lights lit', 'Darkness - lights unlit',
        'Darkness - no lighting' ,'Darkness - lighting unknown');
    end if;
    if not exists (select 1 from pg_type where typname = 'stats19_weather' and typnamespace::regnamespace = 'dft'::regnamespace) then
        create type dft.stats19_weather as enum ('Fine no high winds', 'Raining no high winds', 'Snowing no high winds', 'Fine high winds', 'Raining high winds',
        'Snowing high winds' ,'Fog or mist', 'Other', 'Unknown');
       end if;
    if not exists (select 1 from pg_type where typname = 'stats19_road_surface' and typnamespace::regnamespace = 'dft'::regnamespace) then
        create type dft.stats19_road_surface as enum ('Dry', 'Wet or damp', 'Snow', 'Frost or ice', 'Flood over 3cm. deep', 'Oil or diesel', 'Mud');
       end if;
    if not exists (select 1 from pg_type where typname = 'stats19_special_conditions_at_site' and typnamespace::regnamespace = 'dft'::regnamespace) then
        create type dft.stats19_special_conditions_at_site as enum ('None', 'Auto traffic signal - out', 'Auto signal part defective',
        'Road sign or marking defective or obscured', 'Roadworks', 'Road surface defective', 'Oil or diesel', 'Mud');
    --- the codebook has a zero for none
    end if;
    if not exists (select 1 from pg_type where typname = 'stats19_carriageway_hazards' and typnamespace::regnamespace = 'dft'::regnamespace) then
        create type dft.stats19_carriageway_hazards as enum ('None', 'Vehicle load on road', 'Other object on road', 'Previous accident',
        'Dog on road', 'Other animal on road', 'Pedestrian in carriageway - not injured', 'Any animal in carriageway except ridden horse');
    end if;
    if not exists (select 1 from pg_type where typname = 'stats19_urban_rural' and typnamespace::regnamespace = 'dft'::regnamespace) then
        create type dft.stats19_urban_rural as enum ('Urban', 'Rural', 'Unallocated');
    end if;
    if not exists (select 1 from pg_type where typname = 'stats19_did_police_officer_attend' and typnamespace::regnamespace = 'dft'::regnamespace) then
        create type dft.stats19_did_police_officer_attend as enum ('Yes', 'No', 'No - accident was reported on self completed form');
    end if;
    if not exists (select 1 from pg_type where typname = 'stats19_casualty_class' and typnamespace::regnamespace = 'dft'::regnamespace) then
        create type dft.stats19_casualty_class as enum ('Driver or Rider', 'Passenger', 'Pedestrian');
    end if;
    if not exists (select 1 from pg_type where typname = 'stats19_sex_of_casualty' and typnamespace::regnamespace = 'dft'::regnamespace) then
        create type dft.stats19_sex_of_casualty as enum ('Male' ,'Female');
    end if;

    if not exists (select 1 from pg_type where typname = 'stats19_pedestrian_location' and typnamespace::regnamespace = 'dft'::regnamespace) then
        create type dft.stats19_pedestrian_location as enum ('Not a Pedestrian', 'On pedestrian crossing facility',
        'On zig-zag approach lines', 'On zig-zag exit lines', 'Within 50m. of crossing',
        'In carriageway, crossing elsewhere', 'On footway or verge', 'On refuge or similar',
        'Centre of carriageway without refuge', 'In carriageway, not crossing',
        'Unknown or other');
    end if;
    --- this has a 0 not a pedestrian
    if not exists (select 1 from pg_type where typname = 'stats19_pedestrian_movement' and typnamespace::regnamespace = 'dft'::regnamespace) then
        create type dft.stats19_pedestrian_movement as enum ('Not a Pedestrian', 'From drivers nearside',
        'From nearside masked by vehicle', 'From drivers offside',
        'From offside masked by vehicle', 'In carriageway, stationary',
        'In carriageway, stationary, masked',
        'Walking facing traffic', 'Walking back to traffic', 'Unknown or other'
        );
    end if;
    --- this has a zero code for not a pedestrian
    if not exists (select 1 from pg_type where typname = 'stats19_car_passenger' and typnamespace::regnamespace = 'dft'::regnamespace) then
        create type dft.stats19_car_passenger as enum ('Not a Car Passenger', 'Front seat Passenger',
        'Rear seat passenger');
    end if;
    --- this has a zero code for not a passenger
    if not exists (select 1 from pg_type where typname = 'stats19_bus_passenger' and typnamespace::regnamespace = 'dft'::regnamespace) then
        create type dft.stats19_bus_passenger as enum ('Not a bus or coach passenger', 'Boarding', 'Alighting',
        'Standing passenger', 'Seated passenger');
    end if;
    --- this has a zero code for not a passenger
    if not exists (select 1 from pg_type where typname = 'stats19_ped_road_maintenance_worker' and typnamespace::regnamespace = 'dft'::regnamespace) then
        create type dft.stats19_ped_road_maintenance_worker as enum ('No or not applicable', 'Yes', 'Unknown');
    end if;
    --- this has a zero code for not a maintenance worker or not applicable

---    if not exists (select 1 from pg_type where typname = 'stats19_imd_decile') then
---        create type dft.stats19__imd_decile as enum ('decile 1 (lowest)', 'decile 2 (low)', 'decile 3 (low)',
---        'decile 4 (low)', 'decile 5', 'decile 6 (high)', 'decile 7 (high)', 'decile 8 (high)', 'decile 9 (high)', 'decile 10 (highest)');
---       end if;
---     this rarely seems filled in, and is missing pre-2015 so dropped

    if not exists (select 1 from pg_type where typname = 'stats19_home_area_type' and typnamespace::regnamespace = 'dft'::regnamespace) then
        create type dft.stats19_home_area_type as enum ('Urban area', 'Small town', 'Rural');
    end if;

    if not exists (select 1 from pg_type where typname = 'stats19_towing_and_articulation' and typnamespace::regnamespace = 'dft'::regnamespace) then
        create type dft.stats19_towing_and_articulation as enum ('No tow', 'Articulated vehicle', 'Double or multiple trailer',
        'Caravan', 'Single trailer', 'Other tow');
    end if;
       --- there is a zero code for no tow

    if not exists (select 1 from pg_type where typname = 'stats19_vehicle_manoeuvre' and typnamespace::regnamespace = 'dft'::regnamespace) then
        create type dft.stats19_vehicle_manoeuvre as enum ('Reversing', 'Parked', 'Waiting to go - held up',
        'Slowing or stopping', 'Moving off', 'U-turn', 'Turning left', 'Waiting to turn left', 'Turning right',
        'Waiting to turn right', 'Changing lane to left', 'Changing lane to right', 'Overtaking moving vehicle - offside',
        'Overtaking static vehicle - offside', 'Overtaking - nearside', 'Going ahead left-hand bend', 'Going ahead right-hand bend');
    end if;

    if not exists (select 1 from pg_type where typname = 'stats19_vehicle_location' and typnamespace::regnamespace = 'dft'::regnamespace) then
        create type dft.stats19_vehicle_location as enum ('On main cway not in restricted lane', 'Tram or light rail track',
        'Bus lane', 'Busway (including guided busway)', 'Cycle lane carriageway', 'Cycleway or shared use footway not carriageway',
        'On lay-by or hard shoulder', 'Entering lay-by or hard shoulder', 'Leaving lay-by or hard shoulder', 'Footway (pavement)',
        'Not on carriageway');
    end if;
       --- this coding starts at zero

    if not exists (select 1 from pg_type where typname = 'stats19_vehicle_junction_location' and typnamespace::regnamespace = 'dft'::regnamespace) then
        create type dft.stats19_vehicle_junction_location as enum ('Not at or within 20 metres of junction',
        'Approaching junction or held at junction approach', 'Cleared junction or held at junction exit', 'Leaving roundabout',
        'Entering roundabout', 'Leaving main road', 'Entering main road', 'Entering from slip road', 'Mid Junction - on roundabout or on main road');
    end if;
    --- this has a start from zero

    if not exists (select 1 from pg_type where typname = 'stats19_skidding_and_overturning' and typnamespace::regnamespace = 'dft'::regnamespace) then
        create type dft.stats19_skidding_and_overturning as enum ('None', 'Skidded', 'Skidded and overturned',
        'Jackknifed', 'Jackknifed and overturned', 'Overturned');
    end if;
    --- this has a start from zero

    if not exists (select 1 from pg_type where typname = 'stats19_hit_object_in_carriageway' and typnamespace::regnamespace = 'dft'::regnamespace) then
        create type dft.stats19_hit_object_in_carriageway as enum ('None', 'Previous accident', 'Road works', 'Parked vehicle',
        'Bridge roof', 'Bridge side', 'Bollard or refuge', 'Open door of vehicle', 'Central island of roundabout', 'Kerb', 'Other object',
        'Any animal except ridden horse');
    end if;
    --- this has a start from zero
    if not exists (select 1 from pg_type where typname = 'stats19_vehicle_leaving_carriageway' and typnamespace::regnamespace = 'dft'::regnamespace) then
        create type dft.stats19_vehicle_leaving_carriageway as enum ('Did not leave carriageway', 'Nearside', 'Nearside and rebounded',
        'Straight ahead at junction', 'Offside on to central reservation', 'Offside on to centrl res and rebounded', 'Offside - crossed central reservation',
        'Offside', 'Offside and rebounded');
    end if;
    --- this has a start from zero
    if not exists (select 1 from pg_type where typname = 'stats19_hit_object_off_carriageway' and typnamespace::regnamespace = 'dft'::regnamespace) then
        create type dft.stats19_hit_object_off_carriageway as enum ('None', 'Road sign or traffic signal',
        'Lamp post', 'Telegraph or electricity pole', 'Tree', 'Bus stop or bus shelter', 'Central crash barrier',
        'Near or Offside crash barrier', 'Submerged in water', 'Entered ditch', 'Other permanent object', 'Wall or fence');
   end if;
    --- this has a start from zero
   if not exists (select 1 from pg_type where typname = 'stats19_first_point_of_impact' and typnamespace::regnamespace = 'dft'::regnamespace) then
        create type dft.stats19_first_point_of_impact as enum ('Did not impact', 'Front', 'Back', 'Offside', 'Nearside');
       end if;
    --- this has a start from zero

   if not exists (select 1 from pg_type where typname = 'stats19_was_vehicle_left_hand_drive' and typnamespace::regnamespace = 'dft'::regnamespace) then
        create type dft.stats19_was_vehicle_left_hand_drive as enum ('No', 'Yes');
   end if;

   if not exists (select 1 from pg_type where typname = 'stats19_journey_purpose' and typnamespace::regnamespace = 'dft'::regnamespace) then
        create type dft.stats19_journey_purpose as enum ('Journey as part of work', 'Commuting to from work', 'Taking pupil to from school',
        'Pupil riding to from school', 'Other', 'Not known', 'p7', 'p8', 'p9', 'p10', 'p11', 'p12', 'p13', 'p14', 'Other or Not known');
   end if;

   if not exists (select 1 from pg_type where typname = 'stats19_propulsion_code' and typnamespace::regnamespace = 'dft'::regnamespace) then
        create type dft.stats19_propulsion_code as enum ('Petrol', 'Heavy oil', 'Electric', 'Steam', 'Gas',
        'LPG', 'Gas or Bi-fuel', 'Hybrid electric', 'Gas Diesel', 'New fuel technology', 'Fuel cells', 'Electric diesel');
   end if;
    --- this is a mildly worrying hack - the codebook lists a letter m for undefined here.   there are no m in the data, but there are -1


   if not exists (select 1 from pg_type where typname = 'stats19_sex_of_driver' and typnamespace::regnamespace = 'dft'::regnamespace) then
        create type dft.stats19_sex_of_driver as enum ('Male', 'Female', 'Not known');
   end if;

   if not exists (select 1 from pg_type where typname = 'stats19_age_band_of_driver' and typnamespace::regnamespace = 'dft'::regnamespace) then
        create type dft.stats19_age_band_of_driver as enum ('0 - 5', '6 - 10', '11 - 15', '16 - 20', '21 - 25',
        '26 - 35', '36 - 45', '46 - 55', '56 - 65', '66 - 75', 'Over 75');
   end if;

end $$;
COMMIT;
