# Image for executing R workloads provided by databricks
#
# https://github.com/databricks/containers/blob/master/ubuntu/R/Dockerfile

FROM databricksruntime/rbase:10.4-LTS

RUN groupadd -g 1000 jovyan && useradd -u 1000 jovyan -g jovyan

USER jovyan:jovyan
