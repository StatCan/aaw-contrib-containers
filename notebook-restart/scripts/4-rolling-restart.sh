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
function dryrun() {
  while IFS= read -r line; do
    namespace=$(echo $line | jq -r '.namespace')
    statefulsetname=$(echo $line | jq -r '.stsName')
    echo "kubectl rollout restart statefulset/$statefulsetname -n $namespace"
  done < 3-statefulsets-to-restart.txt
}

function execute() {
  while IFS= read -r line; do
    namespace=$(echo $line | jq -r '.namespace')
    statefulsetname=$(echo $line | jq -r '.stsName')
    kubectl rollout restart statefulset/$statefulsetname -n $namespace
  done < 3-statefulsets-to-restart.txt
}


if [ $1 == "execute" ]; then
  execute
  else
  dryrun
fi
