#!/bin/bash

###############################################
# Purpose: Pull images from artifactory
#####
# Actions: Pull images, but also quit out once it tries to pull (ie pass artif scanning)
# Requires:
## A txt file with a newline containing a list of notebook images in cluster (uniq'd)
### a-uniqe-nb-images.txt
## Configuration to pull from Artifactory. 
# Extra Info
### each line in text file should represent an image looking like k8s...io/jupyterlab-cpu:f25cad42
### The artifactory remote repository should share the same name as the ACR
### crane pull jfrog.aaw.cloud.statcan.ca/k8s...io/jupyterlab-cpu:f25cad42
### In the event that the output does not match what we expect break after 10 sleeps
###############################################

# 04/04/2022 note
# Note, this may not work well ATM due to https://github.com/StatCan/daaas/issues/960
# Right now it will "pull" but be left with a '.marker' for the image layers
# There will be no actual 'scanning' because the actual layers are not being pulled

crane auth login -u $JFROG_USER -p $JFROG_PASSWORD jfrog.aaw.cloud.statcan.ca
while IFS= read -r line; do
  crane pull jfrog.aaw.cloud.statcan.ca/$line temporary 
  if rm temporary 2>&1 | grep -m 1 "cannot remove 'temporary'"; then # add something here so if "cannot remove 'temporary write to file'"
    echo "The following image could not be found --> "$line >> b-images-not-found.txt
  fi
done < a-uniqe-nb-images.txt
