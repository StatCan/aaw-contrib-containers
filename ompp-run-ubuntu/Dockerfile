# Docker image to run openM++ models on latest Ubuntu 22.04
#
# https://github.com/openmpp/docker/blob/master/ompp-run-ubuntu/
#
# Examples of build and arguments default values:
#   sudo docker build -t openmpp/openmpp-run:ubuntu .
#   sudo docker build -t openmpp/openmpp-run:ubuntu --build-arg OMPP_USER=ompp .
#   sudo docker build -t openmpp/openmpp-run:ubuntu --build-arg OMPP_GROUP=ompp .
#   sudo docker build -t openmpp/openmpp-run:ubuntu --build-arg OMPP_UID=1999 .
#   sudo docker build -t openmpp/openmpp-run:ubuntu --build-arg OMPP_GID=1999 .
#
# Examples of run:
#   sudo docker run \
#     -v $HOME/models:/home/models \
#     -e OMPP_USER=models -e OMPP_GROUP=models -e OMPP_UID=$UID -e OMPP_GID=`id -g` \
#     openmpp/openmpp-run:ubuntu \
#     ./MyModel
#
#   sudo docker run \
#     -v $HOME/models:/home/models \
#     -e OMPP_USER=models -e OMPP_GROUP=models -e OMPP_UID=$UID -e OMPP_GID=`id -g` \
#     openmpp/openmpp-run:ubuntu \
#     mpiexec -n 2 MyModel_mpi -OpenM.SubValues 16
#
#   sudo docker run -it openmpp/openmpp-run:ubuntu bash
#
#   sudo docker run \
#     -v $HOME:/home/${USER} \
#     -e OMPP_USER=${USER} -e OMPP_GROUP=`id -gn` -e OMPP_UID=$UID -e OMPP_GID=`id -g` \
#     -it openmpp/openmpp-run:ubuntu \
#     bash

FROM ubuntu:22.04

# disable debconf terminal input
ARG DEBIAN_FRONTEND=noninteractive

# For OncoSim MPI inject to the default bashrc as non other exist, can change later
RUN echo "ulimit -S -s 65536" >> etc/bash.bashrc && \
# update base image, install dependencies, cleanup
    apt-get update && \
    apt-get install -y \
    apt-utils \
    curl \
    jq \
    htop \
    tree \
    zip \
    sqlite3 \
    openmpi-bin \
    unixodbc && \
    apt-get upgrade -y && \
    rm -rf /var/lib/apt/lists/*

ARG KUBECTL_VERSION=v1.28.2
ARG KUBECTL_URL=https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl
ARG KUBECTL_SHA=c922440b043e5de1afa3c1382f8c663a25f055978cbc6e8423493ec157579ec5

RUN curl -LO "${KUBECTL_URL}" \
    && echo "${KUBECTL_SHA} kubectl" | sha256sum -c - \
    && chmod +x ./kubectl \
    && mv ./kubectl /usr/local/bin/kubectl

# set local openM++ timezone
RUN rm -f /etc/localtime && \
    ln -s /usr/share/zoneinfo/America/Toronto /etc/localtime

# Done with installation
# set user, work directory and entry point
#
ARG OMPP_USER=ompp
ARG OMPP_GROUP=ompp
ARG OMPP_UID=1999
ARG OMPP_GID=1999

ENV OMPP_USER=${OMPP_USER} \
    OMPP_GROUP=${OMPP_GROUP} \
    OMPP_UID=${OMPP_UID} \
    OMPP_GID=${OMPP_GID} \
    HOME=/home/${OMPP_USER}

RUN groupadd -g ${OMPP_GID} ${OMPP_GROUP} && \
    useradd --no-log-init -g ${OMPP_GROUP} -u ${OMPP_UID} ${OMPP_USER}

RUN mkdir cd ${HOME} && \
    chown ${OMPP_UID}:${OMPP_GID} ${HOME}

USER $OMPP_USER

SHELL ["/bin/bash"]

# default command check MPIEXEC verson, when used as a kubernetes container override with custom mpiexec execution
CMD mpiexec -V && ulimit -S -s