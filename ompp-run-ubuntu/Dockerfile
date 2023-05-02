# Docker image to run openM++ models on latest Ubuntu LTS
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

# update base image
RUN apt-get update
RUN apt-get install -y apt-utils
RUN apt-get upgrade -y

# install Open MPI and SQLite
RUN apt-get install -y sqlite3 && \
  apt-get install -y openmpi-bin && \
  apt-get autoclean

# download and install unixODBC (optional)
RUN apt-get install -y unixodbc && \
  apt-get autoclean

# set local openM++ timezone
RUN rm -f /etc/localtime && \
  ln -s /usr/share/zoneinfo/America/Toronto /etc/localtime

# copy entry point and build scripts
COPY entrypoint.sh /scripts/

RUN chmod 755 /scripts/entrypoint.sh

# Done with installation
# set user, work directory and entry point
#
ARG OMPP_USER=ompp
ARG OMPP_GROUP=ompp
ARG OMPP_UID=1999
ARG OMPP_GID=1999

ENV OMPP_USER  ${OMPP_USER}
ENV OMPP_GROUP ${OMPP_GROUP}
ENV OMPP_UID   ${OMPP_UID}
ENV OMPP_GID   ${OMPP_GID}

# home directory and user are set by entrypoint.sh

ENTRYPOINT ["/scripts/entrypoint.sh"]
