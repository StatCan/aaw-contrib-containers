# Image for executing python workloads, provided by databricks
#
# https://github.com/databricks/containers/blob/master/ubuntu/python/Dockerfile

FROM databricksruntime/python

RUN groupadd -g 1000 jovyan && useradd -u 1000 jovyan -g jovyan

USER jovyan:jovyan
