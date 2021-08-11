#Parameters for the build, must be defined before any FROM statement in Dockerfile.
ARG MINICONDA_VERSION=4.9.2
ARG MINICONDA_DIGEST_SHA=7838d0ce65783b0d944c19d193e2e6232196bada9e5f3762dc7a9f07dc271179

ARG UBUNTU_VERSION=20.04
ARG UBUNTU_DIGEST_SHA=1e48201ccc2ab83afc435394b3bf70af0fa0055215c1e26a5da9b50a1ae367c9

#Miniconda environment for building the image for agriculture crop area data pipeline project.
#Only use for build, not the actual run.
FROM continuumio/miniconda3:${MINICONDA_VERSION}@sha256:${MINICONDA_DIGEST_SHA} as build

#Create the virtual environment for the installation with the necessary packages.
COPY environment.yml .
RUN conda env create -f environment.yml

#Install conda-pack.
RUN conda install -c conda-forge conda-pack

#Use conda-pack to create a standalone virtual environment in /venv.
RUN conda-pack -n cropenv -o /tmp/env.tar && \
    mkdir /venv && \
    cd /venv && \
    tar xf /tmp/env.tar && \
    rm /tmp/env.tar

#We've put venv in same path it'll be in final image, so fix up the paths.
RUN /venv/bin/conda-unpack

#The runtime base image.
FROM ubuntu:${UBUNTU_VERSION}@sha256:${UBUNTU_DIGEST_SHA} AS runtime

#Install necessary packages.
RUN apt-get update -y && \
    apt-get install wget -y && \
    rm -rf /var/lib/apt/lists/* 

#Create non-root user for container.
ARG USER=crops
ARG USER_HOME=/home/crops

RUN adduser --system --group $USER \
    && mkdir -p $USER_HOME \
    && chown -R $USER:$USER $USER_HOME

#Copy virtual environment /venv from the previous stage.
COPY --from=build /venv ${USER_HOME}/src/venv
COPY . ${USER_HOME}/src
WORKDIR ${USER_HOME}/src

#Download and install MinIO client.
RUN wget https://dl.min.io/client/mc/release/linux-amd64/mc && \
    chmod +x mc && \
    mv mc /bin/mc

#Start container as non-root user.
USER $USER

#Activate the virtual environment in the image.
SHELL ["/bin/bash", "-c"]
RUN source venv/bin/activate

