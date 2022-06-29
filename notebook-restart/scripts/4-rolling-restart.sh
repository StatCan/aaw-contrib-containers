#!/bin/bash

###############################################
# Goal: Perform a rolling restart using the entries in 3-statefulsets-to-restart.txt
# The line should look something like (a one liner)
# {"stsName":"othernotebook", "namespace": "jose-matsuda", "imageSHA":
# "k8scc01covidacr.azurecr.io/rstudio@sha256:b4465e2f5a92ee0505d01401516d9ba6e8084801700177f4ecad62be8fe23d9a"}
# It is also at this point which we could probably implement any "exclusions"
# on any namespaces or statefulsets, but do not do that now.
#kubectl rollout restart statefulset/$line -n blah

# -r for raw, without it keeps the quotes, tested can confirm it works
# This is a job so the sleep does not matter as much, half a second should be ok
function dryrun() {
  loopCounter=0
  while IFS= read -r line; do
    namespace=$(echo $line | jq -r '.namespace')
    statefulsetname=$(echo $line | jq -r '.stsName')
    if [ $loopCounter -eq 20 ]; then
        echo "Triggered 20 restarts sleeping for 10 seconds"
        sleep 10
        loopCounter=0
    fi
    echo "kubectl rollout restart statefulset/$statefulsetname -n $namespace"
    ((loopCounter=loopCounter+1))
  done < 3-statefulsets-to-restart.txt
}

function execute() {
  loopCounter=0
  while IFS= read -r line; do
    namespace=$(echo $line | jq -r '.namespace')
    statefulsetname=$(echo $line | jq -r '.stsName')
    if [ $loopCounter -eq 20 ]; then
        echo "Triggered 20 restarts sleeping for 10 seconds"
        sleep 10
        loopCounter=0
    fi
    kubectl rollout restart statefulset/$statefulsetname -n $namespace
    ((loopCounter=loopCounter+1))
  done < 3-statefulsets-to-restart.txt
}


if [ $1 == "execute" ]; then
  execute
  else
  dryrun
fi
