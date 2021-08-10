#Miniconda environment for running all code for agriculture crop area data pipeline project.
ARG VERSION=4.9.2
ARG DIGEST_SHA=7838d0ce65783b0d944c19d193e2e6232196bada9e5f3762dc7a9f07dc271179
FROM continuumio/miniconda3:${VERSION}@sha256:${DIGEST_SHA}

#Install necessary packages.
RUN conda install --channel conda-forge \
      gdal==3.3.1 \
      geopandas==0.9.0 \
      pyarrow==5.0.0 \
      pygeos==0.10.1 \
      rasterio==1.2.6 \
      s3fs==2021.7.0

#Create user for agriculture crops data pipleline.
RUN adduser crops
USER crops

