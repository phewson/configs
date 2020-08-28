#!/bin/bash
set -eu
QUERYFILE=$1
TESTUSER="vagrant"
SERVER="https://192.168.31.31:8089/services/search/jobs/export"
AUTHINFO="$TESTUSER:$TESTUSER$TESTUSER"
QUERY=$(cat "$QUERYFILE")
FULLQUERY="search=search $QUERY"
curl -k -u $AUTHINFO $SERVER --data-urlencode "$FULLQUERY" --get -d output_mode=csv

# GET TOKEN
# curl -k https://splunk-search-dev.wifispark.net:8089/services/auth/login -d username=phewson@wifispark.com -d password=<PASSWORD>
# USE TOKEN
# curl -k -H "Authorization: Splunk 6Kmh1M2aMALFH62SyWU7fEkmIOdKHQhaey6NhOp717Z1TvAHhmn1X8kigb^gdU8kS0V66ZeW5HFnPlg_2x32mi5NtnTf5gZRY0FJmUSaHOAtoDbhA33v^YKKr03" "https://splunk-search-dev.wifispark.net:8089/services/search/jobs/export" --data-urlencode 'search=search sourcetype="spark_data" earliest="11/01/2019:00:00:00" latest="11/08/2019:00:00:00" | stats count by device_mac_address | table device_mac_address, count' --get -d output_mode=csv
