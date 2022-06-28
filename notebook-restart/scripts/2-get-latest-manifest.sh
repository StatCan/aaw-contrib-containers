#!/bin/bash

###############################################
# Goal: Obtain the 
# "imageID":"k8scc01covidacr.azurecr.io/rstudio@sha256:b4465e2f5a92ee0505d01401516d9ba6e8084801700177f4ecad62be8fe23d9a"
# of the current / most recently pushed tag (in our case v1). 
#####
# Actions: Pull the latest image digest from the acr
###############################################


#Cleanup files
rm 2-registry-images-with-shas.txt
rm 2-shas-to-remove.txt

# Add the argument to the end of each file
if [ -z "$1" ]; then
    echo "No arguments provided will assume v1"
    sed s/$/:v1/ 1-aaw-images.txt > 2-images-with-tags.txt
    else
    sed s/$/:${1}/ 1-aaw-images.txt > 2-images-with-tags.txt
fi

# IMPORTANT
## IF I CHOOSE TO USE THE ACR. I will need to also format the images to become like
# jupyterlab-cpu:v1 (aka no repository) as this works
#  az acr repository show -n k8scc01covidacr --image jupyterlab-cpu:v1 but using 
# k8scc01covidacr.azurecr.io/jupyterlab-cpu:v1 for --image will not.
# Regardless if I use artifactory or acr, I will need to iterate through the 2-images-with-tags.txt file

# Retrieve just the digest, as we can get images that share the "sha" meaning they do not need to be restarted.
while IFS= read -r line; do
    imageTag=${line#*/}
    repository=${line%%/*}
    imageSha=$(az acr repository show -n $repository --image $imageTag --username $ACR_READ_METADATA_USERNAME --password $ACR_READ_METADATA_PASSWORD | jq -r '.digest') 
    echo $imageSha >> 2-shas-to-remove.txt
done < 2-images-with-tags.txt

# Other implementation Notes / possibilities (Using Artifactory)
# In Artifactory Digest:sha256:95e1b3d264e67b417e6a2f3c6b64bb8a2b55d8e495fca1fd97a312135e2af6fa
# Will need crane for this I think https://github.com/google/go-containerregistry/blob/main/cmd/crane/doc/crane.md
# that or I use https://www.jfrog.com/confluence/display/JFROG/Artifactory+REST+API

# IF USING ARTIFACTORY
# We can use the `1-aaw-images.txt` and append a `:v1` to the end to check it.
# If we truly want to be safe, we can _pull_ before we run queries to get it.
# But with the automated scanning running each night, it should do that anyways.
# Use JFrog (will need to do a pull to confirm it's the most recent version of `v1`)
# ^ that may be an intermediary 2-A step, keep this as just querying Artifactory for the sha