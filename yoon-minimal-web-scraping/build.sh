#!/usr/bin/env bash
# VERSION can be anything, just don't overwrite previous items
VERSION="YYYY-MM-DD_VERSIONNUMBER"  
IMAGE_TAG="k8scc01covidacr.azurecr.io/yoon-minimal-web-scraping:$VERSION"
BASE_CONTAINER="k8scc01covidacr.azurecr.io/minimal-notebook-cpu:5ef877ea13789f64594c219ef0a302dc97c21bb4"
docker build -t $IMAGE_TAG --build-arg BASE_CONTAINER=$BASE_CONTAINER .
# docker run -p 8888:8888 $IMAGE_TAG

# Must be logged into az acr (az acr login --name k8scc01covidacr)
docker push $IMAGE_TAG
