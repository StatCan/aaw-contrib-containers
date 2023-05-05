#!/usr/bin/env bash
set -e

# add OMPP_USER and group
#
groupadd -g ${OMPP_GID} ${OMPP_GROUP}
useradd --no-log-init -g ${OMPP_GROUP} -u ${OMPP_UID} ${OMPP_USER}

# set environment: home directory
#
export HOME=/home/${OMPP_USER}

chown ${OMPP_UID}:${OMPP_GID} ${HOME}
cd ${HOME}

# step down from root to OMPP_USER
#
exec setpriv --reuid ${OMPP_UID} --regid ${OMPP_GID} --clear-groups "${@}"
