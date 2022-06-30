# patch-notebook-sts
https://github.com/StatCan/daaas/issues/957

### IMPORTANT MAKE SURE THAT THE INPUT FILES HAVE THE LF ENDING AND NOT CRLF ENDING PLEASE 

This will be in a cronjob

Maybe give the whole thing an argument say we can specify, "look for these tags" or something.
^ might not be necessary on the assumption that everyone is on a v1 tag or some other long lived tag.
^ that or if they for whatever reason are not on a long lived tag then in that case we go and update to one.

## Pre-requisites
1) We need all our aaw-kubeflow-container images being used to be updated to use the long-lived tag `v1`
2) We need the `imagePullPolicy` to be changed to `Always` for all notebook pods.


## Requirements
Must be ran with `execute` in the arguments for it to not do a dry run

## General Flow of it all
### Step 1 Get the list of notebook statefulsets and their digest
Using `kubectl` get a list of notebook statefulsets and their digests. This will be a file
with each line being valid json for easy comprehension. The line will look like this for example

```{"stsName":"othernotebook","image":{"containerID":"containerd://8324ffc23ab255fc1afbff9c7b0005c2ec024c5dcbeefa2b5a5f46807e1915f9","image":"k8scc01covidacr.azurecr.io/rstudio:c5b7982c","imageID":"k8scc01covidacr.azurecr.io/rstudio@sha256:b4465e2f5a92ee0505d01401516d9ba6e8084801700177f4ecad62be8fe23d9a","lastState":{},"name":"othernotebook","ready":true,"restartCount":0,"started":true,"state":{"running":{"startedAt":"2022-06-16T11:24:04Z"}}}}```

### Step 2 Retrieve the digest of the "latest" long-lived tag of the AAW-provisioned images
*IMPORTANT* This must be called with an argument of the long-lived tag. For example with `v1`
In this current case it will be `v1`. We will use either the AZ cli or the JFROG Rest API to retrieve this.
The `v1` tag itself is long-lived and gets overwritten with each push to the aaw-kubeflow-containers `master` branch.
This `digest` which corresponds to the `imageID` from above is how we will know if a users `statefulset` has to be restarted. If it does not match then it has to be restarted


### Step 3 Compare the outputs of Step 1 and Step 2
We reduce the list `1-simple-output.txt` first by using the `2-images-with-tags.txt` to only _keep_ the images from `1-simple-output.txt` that contain that image and the tag. This is helpful for when we have multiple tags
say `v1` and `v2`, both of which we want to update.


### Step 4 Execute rolling restarts of the statefulsets from Step 3
Go line by line and kubectl restart them
