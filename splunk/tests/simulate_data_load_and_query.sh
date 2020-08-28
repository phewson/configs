TOKEN="$1"
QUERY=$(cat test.spl)
FULLQUERY="search=search $QUERY"

curl -k -H "Authorization: Splunk $TOKEN" --request DELETE https://localhost:8089/services/data/indexes/testing > errors.xml
curl -k -H "Authorization: Splunk $TOKEN" https://localhost:8089/servicesNS/phewson@wifispark.com/search/data/indexes -d name=testing >> errors.xml
curl -k -H "Authorization: Splunk $TOKEN" https://192.168.31.31:8089/services/data/inputs/oneshot  --data-urlencode name='/home/vagrant/simulations.json' -d host=testing -d sourcetype=testing_json -d index=testing >> errors.xml
curl -k -H "Authorization: Splunk $TOKEN" https://localhost:8089/services/search/jobs/export --data-urlencode "$FULLQUERY" -d output_mode=csv > out.csv
