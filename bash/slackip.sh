#!/bin/bash
# shellcheck disable=SC2039
# shellcheck disable=SC1091
source /home/FUTURES.CITY/phewson/Documents/paul_sketches/paul_sketch/slack_env.sh

ipt=$(/sbin/ifconfig enp1s0|grep -Po 't addr:\K[\d.]+')

curl -X POST -H 'Content-type: application/json' --data \
     "{\"text\": \":exclamation: IP Address $ipt\"}" \
     "https://hooks.slack.com/services/$MY_SLACK_CHANNEL/$MY_SLACK_TOKEN"

