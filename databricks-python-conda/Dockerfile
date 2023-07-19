# Image for executing Python workloads with conda support, provided by databricks
#
# https://github.com/databricks/containers/blob/master/ubuntu/python-conda/Dockerfile

FROM databricksruntime/python-conda

RUN groupadd -g 1000 jovyan && useradd -u 1000 jovyan -g jovyan

USER jovyan:jovyan
