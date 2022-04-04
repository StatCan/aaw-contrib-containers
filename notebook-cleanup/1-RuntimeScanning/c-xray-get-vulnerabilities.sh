#!/bin/bash

###############################################
# Purpose: Get a list of vulnerabilities via XRAY Rest API
###
#####
# Actions:
# Requires:
## Configuration for username and apikey to get information from XRAY
# Extra Info
####
###############################################

URL="https://jfrog.aaw.cloud.statcan.ca/xray/api/v1/violations" # manage-watches must be set

# Mount as a secret
curl -u $JFROG_USERNAME:$JFROG_PASSWORD -X POST $URL -H "Content-Type: application/json" -d @xray-query.json > c-vulnerabilities.json

# Format the vulnerabilities into just a list of impacted artifacts
jq -c '.violations[].impacted_artifacts[]' < c-vulnerabilities.json | sort | uniq > c-impacted-artifacts.txt

sed -i 's/\"//g' c-impacted-artifacts.txt

#Remove the leading `default/` in the `impacted_artifacts`
awk '{gsub("default/","");print}' <<< cat c-impacted-artifacts.txt >> c-formatted-impacted-artifacts.txt
# There's also a trailing slash for whatever reason at the end get rid of it
sed -i 's/.$//' c-formatted-impacted-artifacts.txt
