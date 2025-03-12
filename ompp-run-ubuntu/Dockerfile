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

FROM ubuntu:24.04

# disable debconf terminal input
ARG DEBIAN_FRONTEND=noninteractive
ARG OMPP_USER=ompp
ARG OMPP_GROUP=ompp
ARG OMPP_UID=1999
ARG OMPP_GID=1999

# For OncoSim MPI inject to the default bashrc as non other exist, can change later
RUN echo "ulimit -S -s 65536" >> etc/bash.bashrc && \
# update base image, install dependencies, cleanup, install OpenSSH for MPI to communicate between containers
    apt-get update && \
    apt-get install -y \
    openssh-client \
    openssh-server \
    apt-utils \
    curl \
    jq \
    htop \
    tree \
    zip \
    sqlite3 \
    g++ \
    make \
    unixodbc && \
    apt-get upgrade -y && \
    rm -rf /var/lib/apt/lists/*

# download and install Go
RUN GO_VER=1.22.5; \
  curl -L -o /tmp/go_setup.tar.gz https://dl.google.com/go/go${GO_VER}.linux-amd64.tar.gz && \
  tar -xzf /tmp/go_setup.tar.gz -C /tmp && \
  mv /tmp/go / && \
  rm -rf /tmp/gocache /tmp/tmp && \
  rm /tmp/go_setup.tar.gz

# Install kubectl cli to be able to utilize file transfer functionality between containers
ARG KUBECTL_VERSION=v1.28.11
ARG KUBECTL_URL=https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl
ARG KUBECTL_SHA=1dba63e1a5c9520fc516c6e817924d927b9b83b8e08254c8fe2a2edb65da7a9c

RUN curl -LO "${KUBECTL_URL}" \
    && echo "${KUBECTL_SHA} kubectl" | sha256sum -c - \
    && chmod +x ./kubectl \
    && mv ./kubectl /usr/local/bin/kubectl

# set local openM++ timezone
RUN rm -f /etc/localtime && \
    ln -s /usr/share/zoneinfo/America/Toronto /etc/localtime

# set user, create home/work directories
ENV OMPP_USER=${OMPP_USER} \
    OMPP_GROUP=${OMPP_GROUP} \
    OMPP_UID=${OMPP_UID} \
    OMPP_GID=${OMPP_GID} \
    HOME=/home/${OMPP_USER}

RUN groupadd -g ${OMPP_GID} ${OMPP_GROUP} && \
    useradd --no-log-init -m -g ${OMPP_GROUP} -u ${OMPP_UID} ${OMPP_USER} && \
    mkdir ${HOME}/work

# Install OpenM++ into user home directory
ARG OMPP_VERSION=v1.17.5
ARG OMPP_DATE=20241021
ARG OMPP_URL=https://github.com/openmpp/main/releases/download/${OMPP_VERSION}/openmpp_debian-11_${OMPP_DATE}.tar.gz
ARG OMPP_SHA=79084a009f3bad3c0d81cb12ccc844458d29b70d199352233aad3d94489427c9

RUN curl -LO "${OMPP_URL}" \
    && echo "${OMPP_SHA} openmpp_debian-11_${OMPP_DATE}.tar.gz" | sha256sum -c - \
    && tar -xf ./openmpp_debian-11_${OMPP_DATE}.tar.gz -C ${HOME}

USER $OMPP_USER

SHELL ["/bin/bash"]

# default command check MPIEXEC verson, when used as a kubernetes container override with custom mpiexec execution
CMD mpiexec -V && ulimit -S -s
