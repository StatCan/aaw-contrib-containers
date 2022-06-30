#!/bin/bash

###############################################
# Use what is in 2-registry-images-with-shas.txt and narrow down the 
# 1-simple-output.txt to only contain entries which 
# A) The repository name (ex jupyterlab-cpu) matches the image name and
# B) Do not MATCH what we have from 2-registry-images-with-shas in the sha category.

#Cleanup make sure everything is clean
rm 3-reduce-to-wanted-image-tags.txt

# Now the way we match on the imageTag itself may change depending on if we use artifactory or the acr

# Will have a separate job to migrate all workspaces to the long lived tag.
# So we do a full match on the image tag, and then a negative match on the sha's that do not match.

# Step 1 List 1
# Reduce the list (1-simple-output.txt) by using what we have in 2-images-with-tags
# Given the example of calling script `./2-xyz.sh v1` where we specify the tag of the image we want
# We reduce the 1-simple-output.txt to a text file that only has those in 2-images-with-tags
while IFS= read -r line; do
    grep $line 1-simple-output.txt >> 3-reduce-to-wanted-image-tags.txt
done < 2-images-with-tags.txt

# Step 2 List 2 
# Reduce the list (3-reduce-to-wanted-image-tags.txt) by iterating through the 
# 2-registry-images-with-shas.txt and removing any sts that contain the EXACT sha256:...
# Make a copy of the 3-reduce-to-wanted-images.txt can remove later, keeping it for testing
cp 3-reduce-to-wanted-image-tags.txt 3-statefulsets-to-restart.txt 

# 2-shas-to-remove is a list of shas that match up to the current long lived tag (ex v1)
# And thus we do not want to restart these so we take them off the list.
readarray -t shas < 2-shas-to-remove.txt 
for i in "${shas[@]}"
do
   shaToRemove=$(echo $i | xargs)
   sed -i "/$shaToRemove/d" 3-statefulsets-to-restart.txt
done

# Gist for for loop test https://gist.github.com/Jose-Matsuda/e0b339d115ad25b36b8b9f455dbacf02
