#!/bin/bash

###############################################
# Goal: Obtain a consumable list of entries that we can use to compare against the 
# most recent "v1" tag with information necessary to restart the statefulset as well
#####
# Actions: kubectl to obtain a json valid line (by line) of images. The file in its entirety is not valid json each line
# is valid json. 
# Required Files: 1-aaw-images.txt, full image name of registry and repository.
# This must be line separated and must contain a newline at the end
## EXAMPLE
#k8scc01covidacr.azurecr.io/rstudio
#k8scc01covidacr.azurecr.io/jupyterlab-cpu
## END EXAMPLE
# Notes: You cannot simply use .status.containerStatuses[1] because it's not guaranteed
# for the [1]th element to be the notebook.
###############################################

## CLEANUP (for when iterating through a list of tags)
rm 1-simple-output.txt

# Get a list of pods that have the label 'notebook-name' across all namespaces.

# .items[] | {stsName: (.metadata.ownerReferences[].name), image: (.status.containerStatuses[])}
# ^will give 3 entries per thing but it almost seems unavoidable.
# I don't like the option of `.status.containerStatuses` because it is harder to remove what I don't need
kubectl get pods -l 'notebook-name' -A -o json | 
 jq -c '.items[] | select(.status.containerStatuses != null) | {stsName: (.metadata.ownerReferences[].name), namespace: (.metadata.namespace), image: (.status.containerStatuses[])}' > 1-full-list.txt

# Using newline separated list of images, make a variable containing all the images we want to look out for
# These images will ideally have long-lived tags
readarray -t images < 1-aaw-images.txt
unset list_to_grep_for
for i in "${images[@]}"
do
   if [[ $i == ${images[-1]} ]]; then
     list_to_grep_for+=$i
   else 
     list_to_grep_for+=${i}:'\'\|
   fi 
done

grep $list_to_grep_for  1-full-list.txt > 1-pared-down-list.txt

### Now we want to format this output into something easier to understand.
# {stsName: .stsName, namespace: .namespace, image: .image.image, imageSHA: .image.imageID}
# I do not think there is a good simple way of doing this in an earlier step
# as the file itself is not valid json, only each line is.

while IFS= read -r line; do
    echo $line | jq -c '{stsName: .stsName, namespace: .namespace, image: .image.image, imageSHA: .image.imageID}' >> 1-simple-output.txt
done < 1-pared-down-list.txt
