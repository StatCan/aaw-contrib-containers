#!/bin/bash

###############################################
# Purpose: Run Scripts in sequence
#####
#####
# TODO:
###############################################

# All these scripts would be copied to the generic landing area of the docker container
echo "Starting Artifactory cleanup"

echo "Obtaining a list of notebook images being used in the cluster------------------"
./a-get-list-of-notebook-img.sh

echo "List of uniqe notebook images present in cluster-------------------------------"
cat a-uniqe-nb-images.txt

echo "Initiating Pulls---------------------------------------------------------------"
./b-pull.sh

echo "Getting a list of vulnerabilities----------------------------------------------"
./c-xray-get-vulnerabilities.sh

echo "Comparing and outputting a list of vulnerable images in the cluster------------"
./d-compare.sh

echo "List of images not found in the ACR and could not be pulled--------------------"
cat b-images-not-found.txt
echo "Ending Artifactory cleanup"
