#!/bin/bash
# shellcheck disable=SC2039
# shellcheck disable=SC1091
source /home/FUTURES.CITY/phewson/Documents/paul_sketches/paul_sketch/slack_env.sh

CURRENT=$(df / | grep / | awk '{ print $5}' | sed 's/%//g')
THRESHOLD=50

echo Currently using "$CURRENT" percent, with threshold "$THRESHOLD" percent

if [ "$CURRENT" -gt "$THRESHOLD" ] ; then
    curl -X POST -H 'Content-type: application/json' --data \
        "{\"text\": \":exclamation: Disc space at $CURRENT percent\"}" \
        "https://hooks.slack.com/services/$MY_SLACK_CHANNEL/$MY_SLACK_TOKEN"
fi
