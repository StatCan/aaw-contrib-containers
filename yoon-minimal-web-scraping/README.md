# Summary

Custom Jupyter server built with Chrome and selenium for web scraping.  Extends a pinned version of the `minimal-notebook-cpu` image.

# Build/Update Instructions

(must have permission to push to k8scc01covidacr)

```
# Edit build.sh to set image VERSION
# Edit build.sh to pin to the desired minimal-nobook-cpu image

az acr login --name k8scc01covidacr

./build.sh 
```
