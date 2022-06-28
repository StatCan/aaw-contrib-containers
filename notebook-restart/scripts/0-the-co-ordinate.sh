#!/bin/bash

## This co-ordinates everything.
# Possible idea is that if we want to check for multiple tags (say v1 and v2)
# then we just put the entire thing in a loop (clean up at end of each loop).

# This is a preventative measure against myself personally
if [ -z $1 ]; then
    echo "Must specify what you want to run with, either dry-run or execute"
    echo "Nothing will happen kubectl run-wise without it"
    exit 0
fi

echo "Starting..."
echo "Taking the input file 0-list-of-tags.txt and using that to sort through"
readarray -t tagsToRead < 0-list-of-tags.txt
for i in "${tagsToRead[@]}"
do
    ./1-get-notebooks.sh
    ./2-get-latest-manifest.sh $i
    ./3-compare-live-to-recent.sh
    ./4-rolling-restart.sh $1
done

echo "Ending..."
