# Summary

Custom Jupyter server built with Chrome and selenium for web scraping.  Extends a pinned version of the `minimal-notebook-cpu` image.

# Existing versions

Paste these into the custom notebook image in the `New Server` page to use them

* k8scc01covidacr.azurecr.io/yoon-minimal-web-scraping:2020-09-17_1

# Build/Update Instructions

(must have permission to push to k8scc01covidacr)

```
# Edit build.sh to set image VERSION
# Edit build.sh to pin to the desired minimal-nobook-cpu image

az acr login --name k8scc01covidacr

./build.sh 
# Add to Existing versions above if sharing with others
```
