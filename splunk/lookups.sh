#!/bin/bash
set -eu

sudo unzip lookups.zip -d "$SPLUNK_HOME/etc/apps/search/lookups"

cat <<- EOS | sudo tee -a "$SPLUNK_HOME/etc/apps/search/local/transforms.conf"

[LookupDataCountryCodes]
filename = LookupDataCountryCodes.csv

[spark_data_lu000001_nhs_digital_reporting_site_lookup.csv]
filename = spark_data_lu000001_nhs_digital_reporting_site_lookup.csv

[buy_time_plan_charges.csv]
filename = buy_time_plan_charges.csv

[lookupData-East_Renfrewshire_Interface_Names.csv]
file = lookupData-East_Renfrewshire_Interface_Names.csv
EOS

cat <<- EOT | sudo tee -a "$SPLUNK_HOME/etc/apps/search/local/props.conf"

[spark_data]
DATETIME_CONFIG =
EVAL-cf_customer_id = case(type="Portal", 'customer.id', 1=1, customer_id)
EVAL-cf_event_type = case( type="Start" AND termination_cause!="Resumed", "session_start_actual", type="Stop" AND termination_cause="Suspect-Logout", "session_stop_interim", type="Start" AND termination_cause="Resumed", "session_start_interim", type="Stop" AND termination_cause!="Suspect-Logout", "session_stop_actual", type="Portal" AND view="NewUser" AND NOT (user_id="false" OR user_id="duplicate"), "new_user", type="Portal" AND view="NewUser" AND (user_id="false" OR user_id="duplicate"), "new_user_invalid", type="Portal" AND view="NewDevice", "new_device", type="Portal" AND view="EmailValidation", "email_validation", type="Portal" AND view="ForgetDevice", "forget_device", type="Portal" AND view="ResetUser", "reset_user", type="Portal" AND view="PortalView" AND isnotnull(page), "page_view_" + page, type="Portal" AND view like("PortalView_%"),  lower(view), 1=1, "unknown")
EVAL-cf_event_type_group = case( (type="Start" OR type="Stop"), "session_event", type="Portal" AND (view="NewUser" OR view="NewDevice" OR view="EmailValidation" OR view="ForgetDevice" OR view="ResetUser"), "registration_event", type="Portal" AND (view="PortalView" AND isnotnull(page)) OR (view like("PortalView_%")), "page_view_event", 1=1, "unknown" )
EVAL-cf_event_type_validation = case( type="Start" AND termination_cause!="Resumed" AND NOT (isnull('device_mac_address') OR device_mac_address=""), "session_start_actual", type="Start" AND termination_cause!="Resumed" AND (isnull('device_mac_address') OR device_mac_address=""), "session_start_actual_invalid", type="Stop" AND termination_cause="Suspect-Logout" AND NOT (isnull('device_mac_address') OR device_mac_address=""), "session_stop_interim", type="Stop" AND termination_cause="Suspect-Logout" AND (isnull('device_mac_address') OR device_mac_address=""), "session_stop_interim_invalid", type="Start" AND termination_cause="Resumed" AND NOT (isnull('device_mac_address') OR device_mac_address=""), "session_start_interim", type="Start" AND termination_cause="Resumed" AND (isnull('device_mac_address') OR device_mac_address=""), "session_start_interim_invalid", type="Stop" AND termination_cause!="Suspect-Logout" AND NOT (isnull('device_mac_address') OR device_mac_address=""), "session_stop_actual", type="Stop" AND termination_cause!="Suspect-Logout" AND (isnull('device_mac_address') OR device_mac_address=""), "session_stop_actual_invalid", type="Portal" AND view="NewUser" AND NOT (user_id="false" OR user_id="duplicate" OR isnull(user_id) OR user_id="null" OR isnull('device_mac_address') OR device_mac_address=""), "new_user", type="Portal" AND view="NewUser" AND (user_id="false" OR user_id="duplicate" OR isnull(user_id) OR user_id="null" OR isnull('device_mac_address') OR device_mac_address=""), "new_user_invalid", type="Portal" AND view="NewDevice" AND NOT (user_id="false" OR user_id="duplicate" OR isnull(user_id) OR user_id="null" OR isnull('device_mac_address') OR device_mac_address=""), "new_device", type="Portal" AND view="NewDevice" AND (user_id="false" OR user_id="duplicate" OR isnull(user_id) OR user_id="null" OR isnull('device_mac_address') OR device_mac_address=""), "new_device_invalid", type="Portal" AND view="EmailValidation" AND NOT (user_id="false" OR user_id="duplicate" OR isnull(user_id) OR user_id="null" OR isnull('device_mac_address') OR device_mac_address=""), "email_validation", type="Portal" AND view="EmailValidation" AND (user_id="false" OR user_id="duplicate" OR isnull(user_id) OR user_id="null" OR isnull('device_mac_address') OR device_mac_address=""), "email_validation_invalid", type="Portal" AND view="ForgetDevice" AND NOT (user_id="false" OR user_id="duplicate" OR isnull(user_id) OR user_id="null" OR isnull('device_mac_address') OR device_mac_address=""), "forget_device", type="Portal" AND view="ForgetDevice" AND (user_id="false" OR user_id="duplicate" OR isnull(user_id) OR user_id="null" OR isnull('device_mac_address') OR device_mac_address=""), "forget_device_invalid", type="Portal" AND view="ResetUser" AND NOT (user_id="false" OR user_id="duplicate" OR isnull(user_id) OR user_id="null" OR isnull('device_mac_address') OR device_mac_address=""), "reset_user", type="Portal" AND view="ResetUser" AND (user_id="false" OR user_id="duplicate" OR isnull(user_id) OR user_id="null" OR isnull('device_mac_address') OR device_mac_address=""), "reset_user", type="Portal" AND view IN ("IcomeraLogin","IcomeraValidation"), 'view', type="Portal" AND view="PortalView" AND isnotnull(page), "page_view_" + page, type="Portal" AND view like("PortalView_%"), lower(view), 1=1, "unknown")
EVAL-cf_hotspot_id = case(type="Portal", 'hotspot.id', 1=1, hotspot_id)
EVAL-cf_interface_id = case(type="Portal", 'interface.id', 1=1, interface_id)
EVAL-cf_session_downloaded_data_gb = case( type="Stop" AND termination_cause!="Suspect-Logout", (((input_gigawords * 4294967296) + input_octets)/1073741824),1==1, 0)
EVAL-cf_session_termination_cause = case( isnull(termination_cause) or termination_cause = "", "Not-Applicable", 1=1, 'termination_cause')
EVAL-cf_session_unique_session_id = case( isnull(unique_session_id) OR unique_session_id="","Not-Applicable",1=1,unique_session_id)
EVAL-cf_session_uploaded_data_gb = case(type="Stop" AND termination_cause!="Suspect-Logout", (((output_gigawords * 4294967296) + output_octets)/1073741824),1==1, 0)
EVAL-cf_spark_data_site_code_1 = case ( type="Portal", 'customer.id' + "-" + 'hotspot.id', type!="Portal", 'customer_id' + "-" + 'hotspot_id', 1=1,"error")
EVAL-cf_spark_data_site_code_2 = case ( type="Portal" AND isnull('interface.id'), 'customer.id' + "-" + 'hotspot.id' + "-" + "null", type="Portal" AND isnotnull('interface.id'), 'customer.id' + "-" + 'hotspot.id' + "-" + 'interface.id', type!="Portal" AND isnull('interface_id'), 'customer_id' + "-" + 'hotspot_id' + "-" + "null", type!="Portal" AND isnotnull('interface_id'), 'customer_id' + "-" + 'hotspot_id' + "-" + 'interface_id', 1=1,"error")
EVAL-cf_ssid_egton = case(   type IN ("Portal") AND substr(lower(username),1,9) = "egton-lab", "NHS Digital Public", type IN ("Start","Stop") AND substr(lower(username),len(realm) + 2,9) = "egton-lab", "NHS Digital Public", type IN ("Portal") AND substr(lower(username),1,11) = "egton-guest", "NHS Digital Guest", type IN ("Start","Stop") AND substr(lower(username), len(realm) + 2,11) = "egton-guest", "NHS Digital Guest", 1=1,"Unknown")
EVAL-cf_time_month_year_alpha = strftime(_time,"%B %Y")
EVAL-cf_time_year_month_alpha = strftime(_time,"%Y %B")
EVAL-cf_time_year_month_day_numeric = strftime(_time,"%Y_%m_%d")
EVAL-cf_time_year_month_numeric = strftime(_time,"%Y-%m")
EVAL-cf_user_id = case (isnull(user_id) or user_id = "", "Not-Applicable", 1=1, 'user_id')
EVAL-cf_user_payment_method_desc = case( (view=="PortalView_Process_BuyTime" OR view=="PortalView_Process_BuyTimeCancelled") AND 'form_data.payment_method' = "cc", "credit card", (view=="PortalView_Process_BuyTime" OR view=="PortalView_Process_BuyTimeCancelled") AND 'form_data.payment_method' = "pp", "paypal", 1==1, "unknown")
EVAL-cf_user_reg_login_type_desc = case( isnull(login_type), "unknown", login_type="free_sub", "free subscriber", 1==1, login_type)
EVAL-cf_user_session_login_type = case( index="cloud_spark_143" AND (substr('username', (len(realm) +2))) = device_mac_address, "free subscriber", index="cloud_spark_143" AND 1==1, "subscriber")
EVAL-form_data.allow_email_marketing = case( index=="cloud_spark_500", 'form_data.allow_email', 1=1, 'form_data.allow_email_marketing')
EVAL-form_data.gender = case (index=="cloud_spark_394" OR index=="cloud_spark_505", 'form_data.user_def05', index=="cloud_spark_52", 'form_data.user_def02', 1==1, 'form_data.gender')
EVAL-form_data.year_of_birth = case ( index=="cloud_spark_394", 'form_data.user_def06', index=="cloud_spark_505", 'form_data.user_def07', index=="cloud_spark_52", 'form_data.user_def01', 1==1, 'form_data.year_of_birth')
FIELDALIAS-af_user_agent_browser = "user_agent.Browser" AS af_user_agent_browser
FIELDALIAS-af_user_agent_browser_maker = "user_agent.Browser_Maker" AS af_user_agent_browser_maker
FIELDALIAS-af_user_agent_browser_name = "user_agent.browser_name" AS af_user_agent_browser_name
FIELDALIAS-af_user_agent_browser_name_pattern = "user_agent.browser_name_pattern" AS af_user_agent_browser_name_pattern
FIELDALIAS-af_user_agent_browser_name_regex = "user_agent.user_agent.browser_name_regex" AS af_user_agent_browser_name_regex
FIELDALIAS-af_user_agent_comment = "user_agent.Comment" AS af_user_agent_comment
FIELDALIAS-af_user_agent_crawler = "user_agent.Crawler" AS af_user_agent_crawler
FIELDALIAS-af_user_agent_device_pointing_method = "user_agent.Device_Pointing_Method" AS af_user_agent_device_pointing_method
FIELDALIAS-af_user_agent_device_type = "user_agent.Device_Type" AS af_user_agent_device_type
FIELDALIAS-af_user_agent_is_mobile_device = "user_agent.isMobileDevice" AS af_user_agent_is_mobile_device
FIELDALIAS-af_user_agent_is_tablet = "user_agent.isTablet" AS af_user_agent_is_tablet
FIELDALIAS-af_user_agent_major_ver = "user_agent.MajorVer" AS af_user_agent_major_ver
FIELDALIAS-af_user_agent_minor_ver = "user_agent.MinorVer" AS af_user_agent_minor_ver
FIELDALIAS-af_user_agent_parent = "user_agent.Parent" AS af_user_agent_parent
FIELDALIAS-af_user_agent_platform = "user_agent.Platform" AS af_user_agent_platform
FIELDALIAS-af_user_agent_version = "user_agent.Version" AS af_user_agent_version
LINE_BREAKER = ([\r\n]+)
LOOKUP-LookupDataCountryCodes = LookupDataCountryCodes "form_data.country" OUTPUTNEW country_name
LOOKUP-buy_time_plan_charges = buy_time_plan_charges.csv "form_data.plan" OUTPUTNEW plan_bandwidth_type plan_charge plan_description plan_name
LOOKUP-port_lookup = lookupData-East_Renfrewshire_Interface_Names.csv port_id OUTPUTNEW interface_name
LOOKUP-spark_data_lu000001_nhs_digital_reporting_site_lookup = spark_data_lu000001_nhs_digital_reporting_site_lookup.csv spark_data_lu000001_b001_pk_spark_data_site_code_2 AS cf_spark_data_site_code_2 OUTPUTNEW spark_data_lu000001_a001_lookup_name spark_data_lu000001_a002_lookup_sourcetype spark_data_lu000001_c001_nhs_digital_reporting_site_name spark_data_lu000001_c002_nhs_digital_reporting_ods_code spark_data_lu000001_c003_nhs_digital_reporting_ssid spark_data_lu000001_c004_nhs_digital_reporting_required spark_data_lu000001_c005_nhs_digital_reporting_site_level spark_data_lu000001_d001_nhs_digital_reporting_site_name_2 spark_data_lu000001_d002_nhs_digital_reporting_ods_code_2 spark_data_lu000001_d003_nhs_digital_reporting_ssid_2 spark_data_lu000001_d004_nhs_digital_reporting_required_2 spark_data_lu000001_d005_nhs_digital_reporting_site_level_2
NO_BINARY_CHECK = true
TIME_FORMAT = %s
TIME_PREFIX = "timestamp":
category = Custom
description = SPARK Analytics Registered WiFi User Data
pulldown_type = 1
disabled = false
EOT
